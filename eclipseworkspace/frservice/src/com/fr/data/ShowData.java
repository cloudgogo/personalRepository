package com.fr.data;

import com.fr.general.data.TableDataException;
import com.fr.third.com.lowagie.text.Element;

public class ShowData extends AbstractTableData{
	TransformOMElement element=new TransformOMElement();
	String[][] data=element.transformElement() ;
	@Override
	public int getColumnCount() throws TableDataException {
		// TODO Auto-generated method stub
		return data[0].length;
	}

	@Override
	public String getColumnName(int arg0) throws TableDataException {
		// TODO Auto-generated method stub
		return data[0][arg0];
	}

	@Override
	public int getRowCount() throws TableDataException {
		// TODO Auto-generated method stub
		return data.length-1;
	}

	@Override
	public Object getValueAt(int arg0, int arg1) {
		// TODO Auto-generated method stub
		return data[arg0][arg1];
	}
        
}
