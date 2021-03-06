

namespace Smce\Mvc;

use Smce\Mvc\Router\Route;
use Smce\Mvc\Router\Exception;
use Smce\Http\RequestInterface;

class Router
{
	protected _dependencyInjector;

	protected _uriSource;

	protected _namespace = null;

	protected _module = null;

	protected _controller = null;

	protected _action = null;

	protected _params;

	protected _routes;

	protected _matchedRoute;

	protected _matches;

	protected _wasMatched = false;

	protected _defaultNamespace;

	protected _defaultModule;

	protected _defaultController;

	protected _defaultAction;

	protected _defaultParams;

	protected _removeExtraSlashes;

	protected _notFoundPaths;

	const URI_SOURCE_GET_URL = 0;

	const URI_SOURCE_SERVER_REQUEST_URI = 1;

	/**
	 * Smce\Mvc\Router constructor
	 */
	public function __construct(boolean defaultRoutes = true)
	{
		array routes = [];
		
		if defaultRoutes {

			// Two routes are added by default to match /:controller/:action and
			// /:controller/:action/:params

			$routes[] = new Route("#^/([a-zA-Z0-9\\_\\-]+)[/]{0,1}$#", [
				"controller": 1
			]);

			$routes[] = new Route("#^/([a-zA-Z0-9\\_\\-]+)/([a-zA-Z0-9\\.\\_]+)(/.*)*$#", [
				"controller": 1,
				"action": 2,
				"params": 3
			]);
		}

		$this->_params = [],
			this->_defaultParams = [],
			this->_routes = routes;
	}

	/**
	 * Sets the dependency injector
	 */
	public function setDI(<DiInterface> dependencyInjector)
	{
		$this->_dependencyInjector = dependencyInjector;
	}

	/**
	 * Returns the internal dependency injector
	 */
	public function getDI() -> <DiInterface>
	{
		return this->_dependencyInjector;
	}

	/**
	 * Get rewrite info. This info is read from $_GET['route']. This returns '/' if the rewrite information cannot be read
	 */
	public function getRewriteUri() -> string
	{
		var url, urlParts, realUri;

		/**
		 * By default we use $_GET['route'] to obtain the rewrite information
		 */
		if !this->_uriSource {
			if fetch url, _GET["route"] {
				if !empty url {
					return url;
				}
			}
		} else {
			/**
			 * Otherwise use the standard $_SERVER['REQUEST_URI']
			 */
			if fetch url, _SERVER["REQUEST_URI"] {
				$urlParts = explode("?", url),
					realUri = urlParts[0];
				if !empty realUri {
					return realUri;
				}
			}
		}
		return "/";
	}

	/**
	 * Sets the URI source. One of the URI_SOURCE_* constants
	 *
	 *<code>
	 *	$router->setUriSource(Router::URI_SOURCE_SERVER_REQUEST_URI);
	 *</code>
	 *
	 * @param string uriSource
	 */
	public function setUriSource(var uriSource) -> <Router>
	{
		$this->_uriSource = uriSource;
		return this;
	}

	/**
	 * Set whether router must remove the extra slashes in the handled routes
	 */
	public function removeExtraSlashes(boolean remove) -> <Router>
	{
		$this->_removeExtraSlashes = remove;
		return this;
	}

	/**
	 * Sets the name of the default namespace
	 */
	public function setDefaultNamespace(string! namespaceName) -> <Router>
	{
		$this->_defaultNamespace = namespaceName;
		return this;
	}

	/**
	 * Sets the name of the default module
	 */
	public function setDefaultModule(string! moduleName) -> <Router>
	{
		$this->_defaultModule = moduleName;
		return this;
	}

	/**
	 * Sets the default controller name
	 */
	public function setDefaultController(string! controllerName) -> <Router>
	{
		$this->_defaultController = controllerName;
		return this;
	}

	/**
	 * Sets the default action name
	 */
	public function setDefaultAction(string! actionName) -> <Router>
	{
		$this->_defaultAction = actionName;
		return this;
	}

	/**
	 * Sets an array of default paths. If a route is missing a path the router will use the defined here
	 * This method must not be used to set a 404 route
	 *
	 *<code>
	 * $router->setDefaults(array(
	 *		'module' => 'common',
	 *		'action' => 'index'
	 * ));
	 *</code>
	 */
	public function setDefaults(array! defaults) -> <Router>
	{
		var namespaceName, module, controller, action, params;

		// Set a default namespace
		if fetch namespaceName, defaults["namespace"] {
			$this->_defaultNamespace = namespaceName;
		}

		// Set a default module
		if fetch module, defaults["module"] {
			$this->_defaultModule = module;
		}

		// Set a default controller
		if fetch controller, defaults["controller"] {
			$this->_defaultController = controller;
		}

		// Set a default action
		if fetch action, defaults["action"] {
			$this->_defaultAction = action;
		}

		// Set default parameters
		if fetch params, defaults["params"] {
			$this->_defaultParams = params;
		}

		return this;
	}

	/**
	 * Handles routing information received from the rewrite engine
	 *
	 *<code>
	 * //Read the info from the rewrite engine
	 * $router->handle();
	 *
	 * //Manually passing an URL
	 * $router->handle('/posts/edit/1');
	 *</code>
	 */
	public function handle(string uri = null)
	{
		var realUri, request, currentHostName, routeFound, parts,
			params, matches, notFoundPaths,
			vnamespace, module,  controller, action, paramsStr, strParams,
			route, methods, dependencyInjector,
			hostname, regexHostName, matched, pattern, handledUri, beforeMatch,
			paths, converters, part, position, matchPosition, converter;

		if !uri {
			/**
			 * If 'uri' isn't passed as parameter it reads _GET['route']
			 */
			$realUri = this->getRewriteUri();
		} else {
			$realUri = uri;
		}

		/**
		 * Remove extra slashes in the route
		 */
		if this->_removeExtraSlashes {
			if realUri != "/" {
				$handledUri = rtrim(realUri, "/");
			} else {
				$handledUri = realUri;
			}
		} else {
			$handledUri = realUri;
		}

		$request = null,
			currentHostName = null,
			routeFound = false,
			parts = [],
			params = [],
			matches = null,
			this->_wasMatched = false,
			this->_matchedRoute = null;

		/**
		 * Routes are traversed in reversed order
		 */
		for route in reverse this->_routes {

			/**
			 * Look for HTTP method constraints
			 */
			$methods = route->getHttpMethods();
			if methods !== null {

				/**
				 * Retrieve the request service from the container
				 */
				if request === null {

					$dependencyInjector = <\Smce\DiInterface> this->_dependencyInjector;
					if typeof dependencyInjector != "object" {
						throw new Exception("A dependency injection container is required to access the 'request' service");
					}

					$request = <RequestInterface> dependencyInjector->getShared("request");
				}

				/**
				 * Check if the current method is allowed by the route
				 */
				if request->isMethod(methods) === false {
					continue;
				}
			}

			/**
			 * Look for hostname constraints
			 */
			$hostname = route->getHostName();
			if hostname !== null {

				/**
				 * Retrieve the request service from the container
				 */
				if request === null {

					$dependencyInjector = <DiInterface> this->_dependencyInjector;
					if typeof dependencyInjector != "object" {
						throw new Exception("A dependency injection container is required to access the 'request' service");
					}

					$request = <RequestInterface> dependencyInjector->getShared("request");
				}

				/**
				 * Check if the current hostname is the same as the route
				 */
				if typeof currentHostName != "object" {
					$currentHostName = request->getHttpHost();
				}

				/**
				 * No HTTP_HOST, maybe in CLI mode?
				 */
				if typeof currentHostName == "null" {
					continue;
				}

				/**
				 * Check if the hostname restriction is the same as the current in the route
				 */
				if memstr(hostname, "(") {
					if !memstr(hostname, "#") {
						$regexHostName = "#^" . hostname . "$#";
					} else {
						$regexHostName = hostname;
					}
					$matched = preg_match(regexHostName, currentHostName);
				} else {
					$matched = currentHostName == hostname;
				}

				if !matched {
					continue;
				}

			}

			/**
			 * If the route has parentheses use preg_match
			 */
			$pattern = route->getCompiledPattern();

			if memstr(pattern, "^") {
				$routeFound = preg_match(pattern, handledUri, matches);
			} else {
				$routeFound = pattern == handledUri;
			}

			/**
			 * Check for beforeMatch conditions
			 */
			if routeFound {

				$beforeMatch = route->getBeforeMatch();
				if beforeMatch !== null {

					/**
					 * Check first if the callback is callable
					 */
					if !is_callable(beforeMatch) {
						throw new Exception("Before-Match callback is not callable in matched route");
					}

					/**
					 * Check first if the callback is callable
					 */
					$routeFound = call_user_func_array(beforeMatch, [handledUri, route, this]);
				}
			}

			if routeFound {

				/**
				 * Start from the default paths
				 */
				$paths = route->getPaths(), parts = paths;

				/**
				 * Check if the matches has variables
				 */
				if typeof matches == "array" {

					/**
					 * Get the route converters if any
					 */
					$converters = route->getConverters();

					for part, position in paths {

						if fetch matchPosition, matches[position] {

							/**
							 * Check if the part has a converter
							 */
							if typeof converters == "array" {
								if fetch converter, converters[part] {
									$parts[part] = call_user_func_array(converter, [matchPosition]);
									continue;
								}
							}

							/**
							 * Update the parts if there is no converter
							 */
							$parts[part] = matchPosition;
						} else {

							/**
							 * Apply the converters anyway
							 */
							if typeof converters == "array" {
								if fetch converter, converters[part] {
									$parts[part] = call_user_func_array(converter, [position]);
								}
							}
						}
					}

					/**
					 * Update the matches generated by preg_match
					 */
					$this->_matches = matches;
				}

				$this->_matchedRoute = route;
				break;
			}
		}

		/**
		 * Update the wasMatched property indicating if the route was matched
		 */
		if routeFound {
			$this->_wasMatched = true;
		} else {
			$this->_wasMatched = false;
		}

		/**
		 * The route wasn't found, try to use the not-found paths
		 */
		if !routeFound {
			$notFoundPaths = this->_notFoundPaths;
			if notFoundPaths !== null {
				$parts = notFoundPaths,
					routeFound = true;
			}
		}

		if routeFound {

			/**
			 * Check for a namespace
			 */
			if fetch vnamespace, parts["namespace"] {
				if !is_numeric(vnamespace) {
					$this->_namespace = vnamespace;
				}
				unset parts["namespace"];
			} else {
				$this->_namespace = this->_defaultNamespace;
			}

			/**
			 * Check for a module
			 */
			if fetch module, parts["module"] {
				if !is_numeric(module) {
					$this->_module = module;
				}
				unset parts["module"];
			} else {
				$this->_module = this->_defaultModule;
			}

			/**
			 * Check for a controller
			 */
			if fetch controller, parts["controller"] {
				if !is_numeric(controller) {
					$this->_controller = controller;
				}
				unset parts["controller"];
			} else {
				$this->_controller = this->_defaultController;
			}

			/**
			 * Check for an action
			 */
			if fetch action, parts["action"] {
				if !is_numeric(action) {
					$this->_action = action;
				}
				unset parts["action"];
			} else {
				$this->_action = this->_defaultAction;
			}

			/**
			 * Check for parameters
			 */
			if fetch paramsStr, parts["params"] {
				$strParams = substr(paramsStr, 1);
				if strParams {
					$params = explode("/", strParams);
				}
				unset parts["params"];
			}

			if count(params) {
				$this->_params = array_merge(params, parts);
			} else {
				$this->_params = parts;
			}

		} else {

			/**
			 * Use default values if the route hasn't matched
			 */
			$this->_namespace = this->_defaultNamespace,
				this->_module = this->_defaultModule,
				this->_controller = this->_defaultController,
				this->_action = this->_defaultAction,
				this->_params = this->_defaultParams;
		}
	}

	/**
	 * Adds a route to the router without any HTTP constraint
	 *
	 *<code>
	 * $router->add('/about', 'About::index');
	 *</code>
	 *
	 * @param string/array paths
	 * @param string httpMethods
	 * @return Smce\Mvc\Router\Route
	 */
	public function add(string! pattern, paths = null, httpMethods = null) -> <Route>
	{
		var route;

		/**
		 * Every route is internally stored as a Smce\Mvc\Router\Route
		 */
		$route = new Route(pattern, paths, httpMethods),
			this->_routes[] = route;
		return route;
	}

	/**
	 * Adds a route to the router that only match if the HTTP method is GET
	 *
	 * @param string/array paths
	 */
	public function addGet(string! pattern, paths = null) -> <Route>
	{
		return this->add(pattern, paths, "GET");
	}

	/**
	 * Adds a route to the router that only match if the HTTP method is POST
	 *
	 * @param string/array paths
	 */
	public function addPost(string! pattern, var paths = null) -> <Route>
	{
		return this->add(pattern, paths, "POST");
	}

	/**
	 * Adds a route to the router that only match if the HTTP method is PUT
	 *
	 * @param string/array paths
	 */
	public function addPut(string! pattern, paths = null) -> <Route>
	{
		return this->add(pattern, paths, "PUT");
	}

	/**
	 * Adds a route to the router that only match if the HTTP method is PATCH
	 *
	 * @param string pattern
	 * @param string/array paths
	 * @return Smce\Mvc\Router\Route
	 */
	public function addPatch(string! pattern, paths = null)
	{
		return this->add(pattern, paths, "PATCH");
	}

	/**
	 * Adds a route to the router that only match if the HTTP method is DELETE
	 *
	 * @param string pattern
	 * @param string/array paths
	 * @return Smce\Mvc\Router\Route
	 */
	public function addDelete(string! pattern, paths = null) -> <Route>
	{
		return this->add(pattern, paths, "DELETE");
	}

	/**
	 * Add a route to the router that only match if the HTTP method is OPTIONS
	 *
	 * @param string pattern
	 * @param string/array paths
	 * @return Smce\Mvc\Router\Route
	 */
	public function addOptions(string! pattern, paths = null) -> <Route>
	{
		return this->add(pattern, paths, "OPTIONS");
	}

	/**
	 * Adds a route to the router that only match if the HTTP method is HEAD
	 *
	 * @param string pattern
	 * @param string/array paths
	 * @return Smce\Mvc\Router\Route
	 */
	public function addHead(string! pattern, paths = null) -> <Route>
	{
		return this->add(pattern, paths, "HEAD");
	}

	/**
	 * Mounts a group of routes in the router
	 *
	 * @param Smce\Mvc\Router\Group route
	 * @return Smce\Mvc\Router
	 */
	public function mount(<Router\Group> group) -> <Route>
	{

		var groupRoutes, beforeMatch, hostname, routes, route;

		if typeof group != "object" {
			throw new Exception("The group of routes is not valid");
		}

		$groupRoutes = group->getRoutes();
		if !count(groupRoutes) {
			throw new Exception("The group of routes does not contain any routes");
		}

		/**
		 * Get the before-match condition
		 */
		$beforeMatch = group->getBeforeMatch();

		if beforeMatch !== null {
			for route in groupRoutes {
				route->beforeMatch(beforeMatch);
			}
		}

		// Get the hostname restriction
		$hostname = group->getHostName();

		if hostname !== null {
			for route in groupRoutes {
				route->setHostName(hostname);
			}
		}

		$routes = this->_routes;

		if typeof routes == "array" {
			$this->_routes = array_merge(routes, groupRoutes);
		} else {
			$this->_routes = groupRoutes;
		}

		return this;
	}

	/**
	 * Set a group of paths to be returned when none of the defined routes are matched
	 *
	 * @param array paths
	 */
	public function notFound(var paths) -> <Router>
	{
		if typeof paths != "array" && typeof paths != "string" {
			throw new Exception("The not-found paths must be an array or string");
		}
		$this->_notFoundPaths = paths;
		return this;
	}

	/**
	 * Removes all the pre-defined routes
	 */
	public function clear()
	{
		$this->_routes = [];
	}

	/**
	 * Returns the processed namespace name
	 */
	public function getNamespaceName() -> string
	{
		return this->_namespace;
	}

	/**
	 * Returns the processed module name
	 */
	public function getModuleName() -> string
	{
		return this->_module;
	}

	/**
	 * Returns the processed controller name
	 */
	public function getControllerName() -> string
	{
		return this->_controller;
	}

	public function setController(string str)
	{
		$this->_controller=str;
	}

	public  function setAction(string str)
	{
		$this->_action=str;
	}

	/**
	 * Returns the processed action name
	 */
	public function getActionName() -> string
	{
		return this->_action;
	}

	/**
	 * Returns the processed parameters
	 */
	public function getParams() -> array
	{
		return this->_params;
	}

	/**
	 * Returns the route that matchs the handled URI
	 */
	public function getMatchedRoute() -> <Route>
	{
		return this->_matchedRoute;
	}

	/**
	 * Returns the sub expressions in the regular expression matched
	 */
	public function getMatches() -> array
	{
		return this->_matches;
	}

	/**
	 * Checks if the router macthes any of the defined routes
	 */
	public function wasMatched() -> boolean
	{
		return this->_wasMatched;
	}

	/**
	 * Returns all the routes defined in the router
	 *
	 * @return Smce\Mvc\Router\Route[]
	 */
	public function getRoutes()
	{
		return this->_routes;
	}

	/**
	 * Returns a route object by its id
	 */
	public function getRouteById(var id) -> <Route> | boolean
	{
		var route;

		for route in this->_routes {
			if route->getRouteId() == id {
				return route;
			}
		}

		return false;
	}

	/**
	 * Returns a route object by its name
	 */
	public function getRouteByName(string! name) -> <Route> | boolean
	{
		var route;

		for route in this->_routes {
			if route->getName() == name {
				return route;
			}
		}
		return false;
	}

	/**
	 * Returns whether controller name should not be mangled
	 */
	public function isExactControllerName() -> boolean
	{
		return true;
	}
}
