package com.quilombo
{
	public interface IConfigLoader
	{
		function load(value:Object):Object;
		function setDefaults():void;
	}
}
