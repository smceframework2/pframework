
/**
 *
 * @author Samed Ceylan
 * @link http://www.samedceylan.com/
 * @copyright 2015 SmceFramework 2
 * @github https://github.com/smceframework2
 */

namespace Smce\Components;


class Session
{

	private security;

    private $iv;
	
	public function setSecurity(security)
	{

		$this->security=md5(sha1(security));

	}

    

    public function register() -> void
    {
        
        if session_status() == PHP_SESSION_NONE 
        {
            session_start();

        }
    }


	/**
     * @param $key
     * @param $value
     *
     * @return bool
     */
    public function set(key, value) -> bool
    {
        var security;
    
        $security =  this->security;
        $_SESSION[security . md5(sha1(key))] = this->encrypt(value);

        if _SESSION[security . md5(sha1(key))] 
        {
            
            return true;

        } else {
            
            return false;

        }
    }
    
    /**
     * @param $key
     *
     * @return session or false
     */
    public function get(key)
    {
        var security;
    
        $security =  this->security;
        
        if isset _SESSION[security . md5(sha1(key))] {
            
            return trim(this->decrypt(_SESSION[security . md5(sha1(key))]));
        } else {
            
            return false;
        }
    }
    
  
    public function reset() -> void
    {
        var security, login, key, value;
    
        $security =  this->security;
        $login =  md5(sha1("SMCE_" . this->security));

        for key, value in _SESSION {
            $key =  str_replace(security, "", key);
            unset(_SESSION[security . key]);
        
        }

        unset(_SESSION[security . login]);
    
    }

    public function remove(key) -> bool
    {
       
        var security;

        $security =  this->security;

        if isset(_SESSION[security . md5(sha1(key))])
        {
            unset(_SESSION[security . md5(sha1(key))]);
            return true;

        }

        return false;
    
    }


    
    /**
     * @param $_identity
     * @param $duration
     *
     * session_set_cookie_params
     */
    public function login(_identity, duration) -> void
    {
        var security2;
    
        $security2 =  md5(sha1("SMCE_" . this->security));
        ini_set("session.gc_maxlifetime", duration);
        session_set_cookie_params(duration);
        this->set(security2, true);
    }

    public function getLoginStatus()
    {
    
    	return this->get("SMCE_" . this->security);

    }
 

        

    public function isSessionStart()
    {
        
        if session_status() == PHP_SESSION_NONE {
            
            return false;
        } else {
            
            return true;
        }
    }



    private function encrypt(string str)
    {
        return mcrypt_encrypt(MCRYPT_RIJNDAEL_256, this->security, str, MCRYPT_MODE_CBC, this->security);

    }

    private function decrypt(string str)
    {
        return mcrypt_decrypt(MCRYPT_RIJNDAEL_256, this->security, str, MCRYPT_MODE_CBC, this->security);

    }


}