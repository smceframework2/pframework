
/**
 *
 * @author Samed Ceylan
 * @link http://www.samedceylan.com/
 * @copyright 2015 SmceFramework2
 * @github https://github.com/smceframework2
 */
namespace Smce\Components;

class Output
{

    public header;

    public fileName;
    
    public function setContentType(mimeType = "")
    {
        $this->header =  "Content-Type: " . mimeType;
        
        return this;
    }
    
   
    public function setFileName(fileName)
    {
        $this->fileName = fileName;
        
        return this;
    }
    

    public function put(data) -> void
    {
        
        if !empty(this->fileName) {
            header("Content-disposition: attachment; filename=" . this->fileName);
        }
        header(this->header);
        echo data;
    }
    
   
    public function putFile(file) -> void
    {
        
        if !empty(this->fileName) {
            header("Content-disposition: attachment; filename=" . this->fileName);
        }
        header(this->header);
        readfile(file);
    }
    
 
    public function getHeader()
    {
        
        return this->header;
    }

}