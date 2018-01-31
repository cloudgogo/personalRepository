package com.fr.function;

import java.util.ArrayList;
import java.util.List;

import com.fr.general.FArray;
import com.fr.script.AbstractFunction;

public class TestFunction extends AbstractFunction{

	@Override
	public Object run(Object[] arg0) {
		// TODO Auto-generated method stub
		List<String> list= new ArrayList<String>();
		list.add("112233");
		list.add("333333");
		list.add("aaaaaa");
		FArray<String> value =new FArray(list);
		return value;
	}

}
