<?php

namespace Smce\Components;


class Collection
{
   

    protected $items = [];
 
    public function __construct($items = [])
    {

        $this->items =  $items;

    }
    

    public function each($callback)
    {
        array_map($callback, $this->items);
        
        return this;
    }

  

    public function map($callback)
    {
        
        return new static(array_map($callback, $this->items, array_keys($this->items)));

    }


    public function filter($callback)
    {
        
        return new static(array_filter($this->items, $callback));

    }

   

    public function pop()
    {
        
        return array_pop($this->items);
    }

    public function diff($items)
    {
        
        return new static(array_diff($this->items, $items));

    }
    
    
    public function getAll()
    {
        
        return $this->items;
    }


    public function get($key, $dt = null)
    {
        
        if($this->offsetExists($key)) {
            
            return $this->items[$key];
        }
        
    }

    public function flip()
    {
        
        return new static(array_flip($this->items));
    }

    public function has($key)
    {
        
        return $this->offsetExists($key);
    }

    public function isEmpty()
    {
        
        return empty($this->items);
    }

    public function keys()
    {
        
        return new static(array_keys($this->items));
    }

   

    public function merge($items)
    {
        
        return new static(array_merge($this->items, $items));
    }
    

    public function last()
    {
        
        return count($this->items) > 0 ? end($this->items) : null;
    }
    
    public function offsetExists($key)
    {
        
        return array_key_exists($key, $this->items);
    }

    public function prepend($value)
    {

        array_unshift($this->items, $value);

    }

    public function reduce($callback, $initial = null)
    {
        
        return array_reduce($this->items, $callback, $initial);

    }
    

    public function reverse()
    {
        
        return new static(array_reverse($this->items));
    }

    public function search($value, $strict = false)
    {
        
        return array_search($value, $this->items, $strict);
    }

    public function shift()
    {
        
        return array_shift($this->items);
    }

    public function sort($callback)
    {
        uasort($this->items, $callback);
        
        return $this;
    }

    public function splice($offset, $length = 0, $replacement = [])
    {
        
        return new static(array_splice($this->items, $offset, $length, $replacement));
    }

 

    public function transform($callback)
    {
        $this->items =  array_map($callback, $this->items);
        
        return $this;
    }

    public function values()
    {
        
        return new static(array_values($this->items));
    }


    public function unique()
    {

        return new static(array_unique($this->items));

    }

    public function shuffle()
    {
        shuffle($this->items);
        
        return $this;
    }

    public function count()
    {
        
        return count($this->items);
    }
    

    public function push($value)
    {

        $this->offsetSet($null, $value);

    }



    public function offsetSet($key, $value)
    {
        
        if(is_null($key)){
            $this->items[] = $value;
        } else {
            $this->items[$key] = $value;
        }

    }

    
}