/**
 *
 * @author Samed Ceylan
 * @link http://www.samedceylan.com/
 * @copyright 2015 SmceFramework 2
 * @github https://github.com/smceframework2
 */

namespace Smce\Core\Di;


class DiSingleton
{
	 private  static disSingleton;

	 private cs;

	 private static reflection;

	 private static reflectionClassArr;

   public static istance;

	
	 public function __construct(string key, $class) 
	 {
	 	if get_class($class) != ""{

	 		$this->cs = $class;

	 	}else{

	 		throw new \Exception(key." is not recycled class");

	 	}
        

	 }

	 public function resolveWhen(string key)
	 {

	 	 $self::disSingleton[ key ] = this->cs;

	 	 $self::reflectionClassArr[ get_class(this->cs) ]  = key;

	 	 class_alias(get_class(this->cs), key);

	 }


	public static function getSingleton(string key)
	{

		if isset self::disSingleton[ key ]{

			return self::disSingleton[ key ];

		}

		return false;
		

	}

	public static function  getKeys() -> array
    {
        var arr=[], key, value;
        int i=0;

        for key,value in self::disSingleton
        {

            $arr[i]=key;
            $i++;
        }

        return arr;
    }


    public static function  getAll() -> array
    {

        return self::disSingleton;

    }

   
    public static function getCount() -> int
    {

        if is_array(self::disSingleton){

            return count(self::disSingleton);

        }else{

            return 0;
        }

    }


    private static function controllerConstructorParamerters(controller)
    {	

    	    var params, value, paramerter=[], $class;

          $self::reflection = new \ReflectionClass(controller);

          if self::reflection->getConstructor()!=false
          {

          	  $params = self::reflection->getConstructor()->getParameters();
        	
          
	          for value in params
	          {

	          	if isset value->getClass()->name
	          	{

	          		$$class=self::disSingleton[self::reflectionClassArr[value->getClass()->name]];
	          		$paramerter[]=$class;

	          	}else{

	          		 throw new \Exception(value." class not found");
	          	}

	          }

	          return paramerter;

          }
          
          return false;
          
    }

    private static function controllerMethodParamerters(controller,action)
    {	

          var params, value, paramerter=[], $class;

          $self::reflection = new \ReflectionClass(controller);
         
        	
          
          if  self::reflection->getMethod(action)!=false
          {

             $params = self::reflection->getMethod(action)->getParameters();

             
	          for value in params
	          {

	          	if isset value->getClass()->name
	          	{
	          		$$class=self::disSingleton[self::reflectionClassArr[value->getClass()->name]];
	          		 $paramerter[]=$class;

	          	}else{

	          		 throw new \Exception(value." class not found");
	          	}

	          }

            return paramerter;
          }

          return false;

    }

    

    public static function make(controller,action)
    {

        var refMethod,constructorParamerter, actionParamerter;


        $constructorParamerter=self::controllerConstructorParamerters(controller);

        if constructorParamerter!= false && count(constructorParamerter)>0
        {

            $self::istance=self::reflection->newInstanceArgs(constructorParamerter); 

        }else{

            $self::istance=self::reflection->newInstanceArgs(); 

        }
           


        $actionParamerter=self::controllerMethodParamerters(controller,action);


        $refMethod= new \ReflectionMethod(controller, action);


        if actionParamerter==false
        {
            refMethod->invokeArgs(self::istance,[]);

        }else{

            refMethod->invokeArgs(self::istance,actionParamerter);

        }  

       
    }




}