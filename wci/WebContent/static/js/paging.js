	function getPaging(pagingNM ,intCurrentPage, intTotalRowNum, intRowCntPerPage, intPageBlockSize, strSchOption) {
		
		if (window.outerWidth < 841) { // for mobile 
			intPageBlockSize = 5;
		}
	
		var strReturn           = "";
		var strReplace          = "";
		var intVirtualStartPage = 0;
		var intVirtualEndPage   = 0;
		var intVirtualPrevPage  = 0;
		var intVirtualNextPage  = 0;
		var intFinalPage        = parseInt(intTotalRowNum/intRowCntPerPage);
		var intRest             = intTotalRowNum%intRowCntPerPage;

		if (intRest==0) { }
		else { intFinalPage = intFinalPage+1; }

		if (intCurrentPage>intPageBlockSize) {
			intVirtualStartPage = parseInt(((intCurrentPage-1)/intPageBlockSize))*intPageBlockSize+1;
			intVirtualPrevPage  = intVirtualStartPage-1;
		}
		else { intVirtualStartPage = 1; }

		intVirtualEndPage = intVirtualStartPage + intPageBlockSize - 1;
		if (intVirtualEndPage>=intFinalPage) { intVirtualEndPage = intFinalPage; }
		else { intVirtualNextPage = intVirtualEndPage+1; }

		strReturn = "<div class=\"paging\">\n";

		if (intCurrentPage > 1) {
			strReturn += "<a href=\"javascript:"+pagingNM+"(1);\">처음</a>";
		}

		if (intVirtualPrevPage>0) {
			strReturn += "<a href=\"javascript:"+pagingNM+"(\'"+ intVirtualPrevPage +"\');\">이전</a>";
		}

		strReturn += "<span class=\"pagenum\">";

		for (var i=intVirtualStartPage; i<intVirtualEndPage+1; i++) {
			strReturn += (i==intCurrentPage) ? "<a href=\"javascript:"+pagingNM+"(\'"+ i +"\');\" class=\"on\">"+i+"</a>" : "<a href=\"javascript:"+pagingNM+"(\'"+ i +"\');\">"+i+"</a>";
		}

		strReturn += "</span>";

		if (intVirtualNextPage>0) {
			strReturn += "<a href=\"javascript:"+pagingNM+"(\'"+ intVirtualNextPage +"\');\">다음</a>\n";
		}

		if (intTotalRowNum > 0 && intFinalPage != intCurrentPage) {
			strReturn += "<a href=\"javascript:"+pagingNM+"(\'"+ intFinalPage +"\');\">마지막</a>\n";
		}

		strReturn += "</div>";
		document.write(strReturn);
	}


	function setPaging(tgt, pagingNM ,intCurrentPage, intTotalRowNum, intRowCntPerPage, intPageBlockSize, strSchOption) {
		
		if (window.outerWidth < 841) { // for mobile 
			intPageBlockSize = 5;
		}
	
		var strReturn           = "";
		var strReplace          = "";
		var intVirtualStartPage = 0;
		var intVirtualEndPage   = 0;
		var intVirtualPrevPage  = 0;
		var intVirtualNextPage  = 0;
		var intFinalPage        = parseInt(intTotalRowNum/intRowCntPerPage);
		var intRest             = intTotalRowNum%intRowCntPerPage;

		if (intRest==0) { }
		else { intFinalPage = intFinalPage+1; }

		if (intCurrentPage>intPageBlockSize) {
			intVirtualStartPage = parseInt(((intCurrentPage-1)/intPageBlockSize))*intPageBlockSize+1;
			intVirtualPrevPage  = intVirtualStartPage-1;
		}
		else { intVirtualStartPage = 1; }

		intVirtualEndPage = intVirtualStartPage + intPageBlockSize - 1;
		if (intVirtualEndPage>=intFinalPage) { intVirtualEndPage = intFinalPage; }
		else { intVirtualNextPage = intVirtualEndPage+1; }

		strReturn = "<div class=\"paging\">\n";

		if (intCurrentPage > 1) {
			strReturn += "<a href=\"javascript:"+pagingNM+"(1, '"+strSchOption+"');\">처음</a>";
		}

		if (intVirtualPrevPage>0) {
			strReturn += "<a href=\"javascript:"+pagingNM+"("+ intVirtualPrevPage +", '"+strSchOption+"');\">이전</a>";
		}

		strReturn += "<span class=\"pagenum\">";

		for (var i=intVirtualStartPage; i<intVirtualEndPage+1; i++) {
			strReturn += (i==intCurrentPage) ? "<a href=\"javascript:"+pagingNM+"("+ i +", '"+strSchOption+"');\" class=\"on\">"+i+"</a>" : "<a href=\"javascript:"+pagingNM+"("+ i +", '"+strSchOption+"');\">"+i+"</a>";
		}

		strReturn += "</span>";

		if (intVirtualNextPage>0) {
			strReturn += "<a href=\"javascript:"+pagingNM+"("+ intVirtualNextPage +", '"+strSchOption+"');\">다음</a>\n";
		}

		if (intTotalRowNum > 0 && intFinalPage != intCurrentPage) {
			strReturn += "<a href=\"javascript:"+pagingNM+"("+ intFinalPage +", '"+strSchOption+"');\">마지막</a>\n";
		}

		strReturn += "</div>";
		$(tgt).html(strReturn);
	}