<?php
/**
 *
 * @author Samed Ceylan
 * @link http://www.samedceylan.com/
 * @copyright 2015 SmceFramework 2
 * @github https://github.com/smceframework2
 */

namespace Smce\Components;

use Smce\Http\HttpException;

class I18n
{

	private static $dir;

	private static $dir_search;

	private static $lang_list;

	private static $lang;

	private static $langArr;

	public function setDir($dir)
	{

		self::$dir=$dir;

	}

	public function setDirSearch($dir)
	{

		self::$dir_search=$dir;

	}

	public function setLangList($list=[])
	{

		self::$lang_list=$list;

	}

	public function setLang($lang)
	{

		self::$lang=$lang;

		self::$langArr=require(self::$dir."/".self::$lang.".php");
	}


	public static function t($str,$arr=[])
	{
		$at=[];
		$at2=[];


		self::is();

		if(isset(self::$langArr[$str]) && !empty(self::$langArr[$str]))
		{

			if(count($arr)>0)
			{
				
				$str2=self::$langArr[$str];
				

					foreach($arr as $key=>$value)
					{
						$at[]=$key;
						$at2[]=$value;
					}


					$str2=str_replace($at,$at2,self::$langArr[$str]);
				
				return $str2;
			}else
			{
				return self::$langArr[$str];
			}
			
			

		}else{

			if(count($arr)>0)
			{

				$str2=$str;
				
				foreach($arr as $key=>$value)
				{
					$at[]=$key;
					$at2[]=$value;
				}

				
				$str2=str_replace($at,$at2,$str);

				

				return $str2;

			}else
			{
				return $str;
			}
			
		}



	}


	public function search()
	{
		$filelist=[];
		$strings=[];

		if(is_dir(self::$dir_search))
		{

			$extensionsfile["php"];

			$rii = new \RecursiveIteratorIterator(new \RecursiveDirectoryIterator(self::$dir_search));
			
			$rii=iterator_to_array($rii);

			foreach($rii as $path)
			{

			    if(is_dir($path)==false)
			    { 

			    	$ab=(string)$path;

			        $xexplode = explode("/", $ab);
			        $ab=end($xexplode);
			        $xexplode = explode(".", $ab);
				    $ex= end($xexplode);

				    if(in_array($ex, $extensionsfile))
					{
				       $filelist[$path->getPathname()] = count(file($path->getPathname())); 
				        
				    }
			    }
			   
			    
			}


			if(count($filelist)>0)
			{
			    $out=[];

				foreach($filelist as $key=>$value)
				{
					$file=file_get_contents($key);
					preg_match_all("#Sm::t\(\"(.*?)\"[ ,|, |,|\)]#",$file,$out);

					if(count($out[1])>0)
					{
						foreach($out as $value)
						{
							$strings[]=$value;
						}
						
					}
				}
			}
			
		}

		$strings=array_unique($strings);
		sort($strings);

		return $strings;
	}


	public function search_replace()
	{
		$strings=[];
		$arr=[];
		$returnArr=[];

		$strings=$this->search();

		foreach(self::$lang_list as $value)
		{
			$file_x=self::$dir."/".$value.".php";

			if(is_file($file_x))
			{
				$file=require($file_x);

				if(is_array($file))
				{
					$arr=$file;
					$arr=$this->uniqueArr($arr);
					$arr=$this->addArr($arr,$strings);
					ksort($arr);
				}else{
					$arr=$this->addArr($arr,$strings);
					$arr=$this->uniqueArr($arr);
					ksort($arr);
				}

				 unlink($file_x);

			}else{
				
				$arr=$this->addArr($arr,$strings);
				$arr=$this->uniqueArr($arr);
				ksort($arr);
				
			}
			
			$returnArr[$value]=$arr;
			$this->writeFile($arr,$file_x);


		}

		$this->out($returnArr);

		return $returnArr;
		
	}

	private function out($arr)
	{
		if(!is_dir(self::$dir."/out"))
		{
			mkdir(self::$dir."/out", 0777);

			chmod(self::$dir."/out", 0777);
		}

		
		foreach($arr as $key=>$value)
		{

			$file_x=self::$dir."/out/".$key.".txt";
			$file = fopen($file_x , "w");

			if($file)
			{
				foreach($value as $key2=>$value2)
				{
					if(empty($value2))
					{
						fwrite ($file ,$key2."=|!|=\n");
					}
					

				}
			}

			fclose ($file); 	
			chmod($file_x, 0777);
		}


	}

	public function in_replace()
	{
		if(is_dir(self::$dir."/in"))
		{
			$readArr=[];
			$arr=[];
			$ex=[];
			
			foreach(self::$lang_list as $key=>$value)
			{
				$file_x=self::$dir."/in/".$value.".txt";
				
				if(file_exists($file_x))
				{	
					$readArr=[];

					$file = fopen($file_x,"r");
					while(!feof($file))
					{ 
					     $line = fgets($file);
					     $line=(string)$line;
					     if(!empty($line))
					     {
					     	 $ex=explode("=|!|=",$line);

						     if(isset($ex[0]) && isset($ex[1]))
						     {
						     	if(!empty(trim($ex[1])))
						     	{
						     		$readArr[$ex[0]]=trim($ex[1]);
						     	}
						     	

						     }else
						     {
						     	return "error";
						     }
					     }
					    

					}

					fclose($file);


					$file_x2=self::$dir."/".$value.".php";

					if(is_file($file_x2))
					{
						
						
						$file=require($file_x2);

						if(is_array($file))
						{
							print_r($readArr);
							$arr=$this->addArr2($file,$readArr);
							$arr=$this->uniqueArr($arr);
							ksort($arr);

							$this->writeFile($arr,$file_x2);

						}


						

					}


				}


			}
		}
	}

	private function uniqueArr($arr)
	{

		$arr2=[];

		foreach($arr as $key=>$value)
		{

			if(!isset($arr2[$key]))
			{
				$arr2[$key]=$value;
			}

		}

		return  $arr2;

	}

	private function addArr($arr,$arr2)
	{
		
		foreach($arr2 as $key=>$value)
		{
			if(!isset($arr[$value]))
			{
				$arr[$value]="";
			}
		}

		return $arr;
	}


	private function addArr2($arr,$arr2)
	{
		
		foreach($arr2 as $key=>$value)
		{
			if(isset($arr[$key]))
			{
				$arr[$key]=$value;
			}
		}

		return $arr;
	}



	private function writeFile($arr,$file_x)
	{
		
		if is_file($file_x)
		{

			unlink($file_x);
		}

		$file = fopen($file_x , "w");

		if($file)
		{

			fwrite ($file ,"<?php") ;
			fwrite ($file ,"\n" ) ;
			fwrite ($file ,"\n" ) ;

			fwrite ($file ,"		return array(" ) ;
			fwrite ($file ,"\n" ) ;
			fwrite ($file ,"\n" ) ;


		
			foreach($arr as $key=>$value)
			{
				if !empty($key)
				{
					fwrite ($file , "			\"".$key."\"=>\"".$value."\",");
					fwrite ($file ,"\n" ) ;
				}
				
			}
			

			fwrite ($file ,"		);" ) ;
			fwrite ($file ,"\n" ) ;
			fwrite ($file ,"\n" ) ;
			fwrite ($file ,"?>" ) ;
			fclose ($file); 	
			chmod($file_x, 0777);
		}else{
			echo "Dosya açılamadı!";
		}
		
		

	}

	private static function is()
	{

		if empty(self::l$ang)
		{

			throw new HttpException(403, "Set I18n 'setLang()'");

		}

		if empty(self::$dir)
		{

			throw new HttpException(403, "Set I18n 'setDir()'");

		}

	}
	

}