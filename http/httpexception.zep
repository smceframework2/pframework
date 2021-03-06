
/**
 *
 * @author Samed Ceylan
 * @link http://www.samedceylan.com/
 * @copyright 2015 SmceFramework 2
 * @github https://github.com/smceframework2
 */


namespace Smce\Http;

class HttpException extends \Exception
{
    private httpCode;

    private msg;

    public function __construct(int httpCode,string msg) -> void
    {
        $this->msg = msg;
        $this->httpCode = httpCode;

        this->http_response_code(this->httpCode);
    }
    
    public function getMsg()
    {
        
        return this->msg;
    }
    
    public function getHttpCode()
    {
        
        return this->httpCode;
    }
    
    public function htppError()
    {
        var httpError;

       
        $httpError = ["code" : this->httpCode, "msg" : this->msg];

        return httpError;
    }
    
    private function http_response_code(int code = NULL)
    {
        var text,protocol;

        switch (code) {
            case 100: $text = "Continue"; break;
            case 101: $text = "Switching Protocols"; break;
            case 200: $text = "OK"; break;
            case 201: $text = "Created"; break;
            case 202: $text = "Accepted"; break;
            case 203: $text = "Non-Authoritative Information"; break;
            case 204: $text = "No Content"; break;
            case 205: $text = "Reset Content"; break;
            case 206: $text = "Partial Content"; break;
            case 300: $text = "Multiple Choices"; break;
            case 301: $text = "Moved Permanently"; break;
            case 302: $text = "Moved Temporarily"; break;
            case 303: $text = "See Other"; break;
            case 304: $text = "Not Modified"; break;
            case 305: $text = "Use Proxy"; break;
            case 400: $text = "Bad Request"; break;
            case 401: $text = "Unauthorized"; break;
            case 402: $text = "Payment Required"; break;
            case 403: $text = "Forbidden"; break;
            case 404: $text = "Not Found"; break;
            case 405: $text = "Method Not Allowed"; break;
            case 406: $text = "Not Acceptable"; break;
            case 407: $text = "Proxy Authentication Required"; break;
            case 408: $text = "Request Time-out"; break;
            case 409: $text = "Conflict"; break;
            case 410: $text = "Gone"; break;
            case 411: $text = "Length Required"; break;
            case 412: $text = "Precondition Failed"; break;
            case 413: $text = "Request Entity Too Large"; break;
            case 414: $text = "Request-URI Too Large"; break;
            case 415: $text = "Unsupported Media Type"; break;
            case 500: $text = "Internal Server Error"; break;
            case 501: $text = "Not Implemented"; break;
            case 502: $text = "Bad Gateway"; break;
            case 503: $text = "Service Unavailable"; break;
            case 504: $text = "Gateway Time-out"; break;
            case 505: $text = "HTTP Version not supported"; break;
            default:
                trigger_error("Unknown http status code " . $code, E_USER_ERROR);
        }

        $protocol =  isset _SERVER["SERVER_PROTOCOL"] ? _SERVER["SERVER_PROTOCOL"] : "HTTP/1.0";
        header(protocol . " " . code . " " . text);
    }

}