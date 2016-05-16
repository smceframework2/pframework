/**
 *
 * @author Samed Ceylan
 * @link http://www.samedceylan.com/
 * @copyright 2015 SmceFramework 2
 * @github https://github.com/smceframework2
 */
namespace Smce\Core;

class Loader

{
    private static dirs;

    private _registered = false;

    public function setDir(array dir) -> void
    {

        if is_array(self::dirs)
        {

            $self::dirs = array_merge(self::dirs , dir);

        }else
        {

             $self::dirs = dir;

        }
        
        
    }
    

    public function register() -> <Loader>
    {
        
        if this->_registered === false {

            spl_autoload_register([this, "autoLoad"]);
            $this->_registered = true;
        }
        
        return this;
    }


    public function autoLoad(string className) -> void
    {


        var parts, fileName="", namespa="", lastNsPos, value;;

        $className = ltrim(className, '\\');
        if strrpos(className, '\\')
        {
            $lastNsPos = strrpos(className, '\\');
            $namespa = substr(className, 0, lastNsPos);
            $className = substr(className, lastNsPos + 1);
            
            $fileName  = str_replace("\\", DIRECTORY_SEPARATOR, namespa) . DIRECTORY_SEPARATOR;
        }


        $fileName .= str_replace('_', DIRECTORY_SEPARATOR, className) . ".php";

        for value in self::dirs     
        {
            int len, i=1;

            $len=strlen(value);

            if substr(value,len-i,len)!="/"
            {

               $value=value.DIRECTORY_SEPARATOR;

            }
            if is_file(value.fileName)
            {
                require(value.fileName);
                break;

            }
        }
    }
    
    
    

}