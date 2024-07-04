#INCLUDE "FINA918D.ch"
#INCLUDE "PROTHEUS.CH"

Static __lSmtHTML	:= (GetRemoteType() == 5)
Static __lLJGERTX	:= SuperGetMv( "MV_LJGERTX" , .T. , .F. )
Static __cPicSALD   := PesqPict("SE1","E1_SALDO")
Static __cPicVL     := PesqPict("FIF",Iif(__lLJGERTX,"FIF_VLBRUT","FIF_VLLIQ"))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  Fina918D ºAutor  ³Alessandro Santos   º Data ³  18/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera planilha de Excel com as informacoes recebidas no     º±±
±±º          ³ Array aNaoConc e aTitulos.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Tellerina                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Fina918D(aNaoConc, aTitulos, aHeader, aHeadSE1, nTpRel)

Local cArqPesq := "" // Nome do arquivo que foi gerado
Local nHandle  := 0 // Indicador de arquivo de exportacao aberto
Local nI	   := 0
Local cPathTmp //Caminho do arquivo
Local cTabela  := ""
Local nRet      := 0

If (Len(aNaoConc) > 0 .And. Len(aTitulos) > 0)

	If __lSmtHTML
		cPathTmp:= "\Temp\" 
	Else
		cPathTmp := cGetFile('',STR0001,0,,.F.,GETF_LOCALHARD+ GETF_RETDIRECTORY+GETF_NETWORKDRIVE) //"Selecione o Diretório"	
    EndIf
    				
	If !Empty(cPathTmp)
		cArqPesq := cPathTmp + 'FINA918_' + Dtos( dDataBase ) + '_' + StrTran( Time(), ':', '' ) +'.xml' 
			
		// Verifica se o arquivo existe e exclui.
		If FILE(cArqPesq)  
			FERASE(cArqPesq)
		EndIf    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria um arquivo do tipo *.xls	                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nHandle := FCREATE(cArqPesq, 0)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o arquivo pode ser criado, caso contrario um alerta sera exibido      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FERROR() != 0
			Alert(STR0002 + cArqPesq )	//"Não foi possível abrir ou criar o arquivo: "		
		Else
			//XML para criacao da planilha Excel		
			cTabela:='<html xmlns:v="urn:schemas-microsoft-com:vml"' + Chr(13) + Chr(10)
			cTabela+='		xmlns:o="urn:schemas-microsoft-com:office:office"' + Chr(13) + Chr(10)
			cTabela+='		xmlns:x="urn:schemas-microsoft-com:office:excel"' + Chr(13) + Chr(10)
			cTabela+='		xmlns="http://www.w3.org/TR/REC-html40">' + Chr(13) + Chr(10)			
			cTabela+='		<head>' + Chr(13) + Chr(10)
			cTabela+='			<meta http-equiv=Content-Type content="text/html; charset=us-ascii">' + Chr(13) + Chr(10)
			cTabela+='			<meta name=ProgId content=Excel.Sheet>' + Chr(13) + Chr(10)
			cTabela+='			<meta name=Generator content="Microsoft Excel 11">' + Chr(13) + Chr(10)
			cTabela+='			<link rel=File-List href="sher305_arquivos/filelist.xml">' + Chr(13) + Chr(10)
			cTabela+='			<link rel=Edit-Time-Data href="sher305_arquivos/editdata.mso">' + Chr(13) + Chr(10)
			cTabela+='			<link rel=OLE-Object-Data href="sher305_arquivos/oledata.mso">' + Chr(13) + Chr(10)
			cTabela+='			<!--[if gte mso 9]><xml>' + Chr(13) + Chr(10)
			cTabela+=' 			<o:DocumentProperties>' + Chr(13) + Chr(10)
			cTabela+='  				<o:LastAuthor>Tellerina</o:LastAuthor>' + Chr(13) + Chr(10)
			cTabela+='  				<o:Created>2009-09-03T15:13:45Z</o:Created>' + Chr(13) + Chr(10)
			cTabela+='  				<o:LastSaved>2011-06-27T17:53:19Z</o:LastSaved>' + Chr(13) + Chr(10)
			cTabela+='  				<o:Company>Totvs</o:Company>' + Chr(13) + Chr(10)
			cTabela+='  				<o:Version>11.8122</o:Version>' + Chr(13) + Chr(10)
			cTabela+=' 			</o:DocumentProperties>' + Chr(13) + Chr(10)
			cTabela+=' 			<o:OfficeDocumentSettings>' + Chr(13) + Chr(10)
			cTabela+='  				<o:DownloadComponents/>' + Chr(13) + Chr(10)
			cTabela+='  				<o:LocationOfComponents HRef="/"/>' + Chr(13) + Chr(10)
			cTabela+=' 			</o:OfficeDocumentSettings>' + Chr(13) + Chr(10)
			cTabela+='			</xml><![endif]-->' + Chr(13) + Chr(10)
			cTabela+='			<style>' + Chr(13) + Chr(10)
			cTabela+='				<!--table' + Chr(13) + Chr(10)
			cTabela+='				{mso-displayed-decimal-separator:"\,";' + Chr(13) + Chr(10)
			cTabela+='		   		mso-displayed-thousand-separator:"\.";}' + Chr(13) + Chr(10)
			cTabela+='		  		@page' + Chr(13) + Chr(10)
			cTabela+='		   		{margin:1.0in .75in 1.0in .75in;' + Chr(13) + Chr(10)
			cTabela+='		   		mso-header-margin:.49in;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-footer-margin:.49in;}' + Chr(13) + Chr(10)
			cTabela+='		  		tr' + Chr(13) + Chr(10)
			cTabela+='		   		{mso-height-source:auto;}' + Chr(13) + Chr(10)
			cTabela+='		   		col' + Chr(13) + Chr(10)
			cTabela+='		   		{mso-width-source:auto;}' + Chr(13) + Chr(10)
			cTabela+='		  		br' + Chr(13) + Chr(10)
			cTabela+='		 		{mso-data-placement:same-cell;}' + Chr(13) + Chr(10)
			cTabela+='		  		.style0' + Chr(13) + Chr(10)
			cTabela+='		  		{mso-number-format:General;' + Chr(13) + Chr(10)
			cTabela+='		  		text-align:general;' + Chr(13) + Chr(10)
			cTabela+='		 		vertical-align:bottom;' + Chr(13) + Chr(10)
			cTabela+='		 		white-space:nowrap;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-rotate:0;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-background-source:auto;' + Chr(13) + Chr(10)
			cTabela+='		   		mso-pattern:auto;' + Chr(13) + Chr(10)
			cTabela+='		  		color:windowtext;' + Chr(13) + Chr(10)
			cTabela+='		  		font-size:8.0pt;' + Chr(13) + Chr(10)
			cTabela+='		 		font-weight:400;' + Chr(13) + Chr(10)              
			cTabela+='		 		font-style:normal;' + Chr(13) + Chr(10)
			cTabela+='		 		text-decoration:none;' + Chr(13) + Chr(10)
			cTabela+='		 		font-family:Tahoma;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-generic-font-family:auto;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-font-charset:0;' + Chr(13) + Chr(10)
			cTabela+='		  		border:none;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-protection:locked visible;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-style-name:Normal;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-style-id:0;}' + Chr(13) + Chr(10)
			cTabela+='	   	   		.style21' + Chr(13) + Chr(10)
			cTabela+='		   		{mso-number-format:General;' + Chr(13) + Chr(10)
			cTabela+='		  		text-align:general;' + Chr(13) + Chr(10)
			cTabela+='		  		vertical-align:bottom;' + Chr(13) + Chr(10)
			cTabela+='		  		white-space:nowrap;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-rotate:0;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-background-source:auto;' + Chr(13) + Chr(10) 
			cTabela+='		  		mso-pattern:auto;' + Chr(13) + Chr(10)
			cTabela+='		   		color:black;' + Chr(13) + Chr(10)
			cTabela+='		   		font-size:10.0pt;' + Chr(13) + Chr(10)
			cTabela+='		  		font-weight:400;' + Chr(13) + Chr(10)
			cTabela+='		   		font-style:normal;' + Chr(13) + Chr(10)
			cTabela+='		   		text-decoration:none;' + Chr(13) + Chr(10)
			cTabela+='		  		font-family:Arial;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-generic-font-family:auto;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-font-charset:0;' + Chr(13) + Chr(10)
			cTabela+='		  		border:none;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-protection:locked visible;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-style-name:Normal_Vendas;}' + Chr(13) + Chr(10)
			cTabela+='		 		td' + Chr(13) + Chr(10)
			cTabela+='		 		{mso-style-parent:style0;' + Chr(13) + Chr(10)
			cTabela+='		 		padding-top:1px;' + Chr(13) + Chr(10)
			cTabela+='		  		padding-right:1px;' + Chr(13) + Chr(10)
			cTabela+='		  		padding-left:1px;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-ignore:padding;' + Chr(13) + Chr(10)
			cTabela+='		  		color:windowtext;' + Chr(13) + Chr(10)
			cTabela+='		   		font-size:8.0pt;' + Chr(13) + Chr(10)
			cTabela+='		  		font-weight:400;' + Chr(13) + Chr(10)
			cTabela+='		  		font-style:normal;' + Chr(13) + Chr(10)
			cTabela+='		 		text-decoration:none;' + Chr(13) + Chr(10)
			cTabela+='		  		font-family:Tahoma;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-generic-font-family:auto;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-font-charset:0;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-number-format:General;' + Chr(13) + Chr(10)
			cTabela+='		   		text-align:general;' + Chr(13) + Chr(10)
			cTabela+='		  		vertical-align:bottom;' + Chr(13) + Chr(10)
			cTabela+='		  		border:none;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-background-source:auto;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-pattern:auto;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-protection:locked visible;' + Chr(13) + Chr(10)
			cTabela+='		 		white-space:nowrap;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-rotate:0;}' + Chr(13) + Chr(10)  
			cTabela+='		  		-->' + Chr(13) + Chr(10)
			cTabela+='			</style>' + Chr(13) + Chr(10)
			cTabela+='			<!--[if gte mso 9]><xml>' + Chr(13) + Chr(10)
			cTabela+=' 			<x:ExcelWorkbook>' + Chr(13) + Chr(10)
			cTabela+='  				<x:ExcelWorksheets>' + Chr(13) + Chr(10)						
			cTabela+='   					<x:ExcelWorksheet>' + Chr(13) + Chr(10)			
			cTabela+='    						<x:Name>Plan1</x:Name>' + Chr(13) + Chr(10)
			cTabela+='    						<x:WorksheetOptions>' + Chr(13) + Chr(10)
			cTabela+='     						<x:DefaultRowHeight>210</x:DefaultRowHeight>' + Chr(13) + Chr(10)
			cTabela+='     						<x:Print>' + Chr(13) + Chr(10)
			cTabela+='      							<x:ValidPrinterInfo/>' + Chr(13) + Chr(10)
			cTabela+='      							<x:HorizontalResolution>600</x:HorizontalResolution>' + Chr(13) + Chr(10)
			cTabela+='      							<x:VerticalResolution>600</x:VerticalResolution>' + Chr(13) + Chr(10)
			cTabela+='     				   		</x:Print>' + Chr(13) + Chr(10)
			cTabela+='     						<x:Zoom>120</x:Zoom>' + Chr(13) + Chr(10)
			cTabela+='     				   		<x:Selected/>' + Chr(13) + Chr(10)
			cTabela+='     						<x:LeftColumnVisible>0</x:LeftColumnVisible>' + Chr(13) + Chr(10)
			cTabela+='     						<x:FreezePanes/>' + Chr(13) + Chr(10)
			cTabela+='     						<x:FrozenNoSplit/>' + Chr(13) + Chr(10)
			cTabela+='     						<x:SplitHorizontal>1</x:SplitHorizontal>' + Chr(13) + Chr(10)
			cTabela+='     				   		<x:TopRowBottomPane>1</x:TopRowBottomPane>' + Chr(13) + Chr(10)
			cTabela+='     						<x:ActivePane>2</x:ActivePane>' + Chr(13) + Chr(10)
			cTabela+='     						<x:Panes>' + Chr(13) + Chr(10)
			cTabela+='      							<x:Pane>' + Chr(13) + Chr(10)
			cTabela+='       								<x:Number>1</x:Number>' + Chr(13) + Chr(10)
			cTabela+='      							</x:Pane>' + Chr(13) + Chr(10)
			cTabela+='      					   		<x:Pane>' + Chr(13) + Chr(10)
			cTabela+='       						   		<x:Number>1</x:Number>' + Chr(13) + Chr(10)
			cTabela+='       						   		<x:ActiveRow>1</x:ActiveRow>' + Chr(13) + Chr(10)
			cTabela+='       								<x:ActiveCol>1</x:ActiveCol>' + Chr(13) + Chr(10)
			cTabela+='      					   		</x:Pane>' + Chr(13) + Chr(10)
			cTabela+='     						</x:Panes>' + Chr(13) + Chr(10)
			cTabela+='     						<x:ProtectContents>False</x:ProtectContents>' + Chr(13) + Chr(10)
			cTabela+='     						<x:ProtectObjects>False</x:ProtectObjects>' + Chr(13) + Chr(10)
			cTabela+='     						<x:ProtectScenarios>False</x:ProtectScenarios>' + Chr(13) + Chr(10)
			cTabela+='    						</x:WorksheetOptions>' + Chr(13) + Chr(10)
			cTabela+='   					</x:ExcelWorksheet>' + Chr(13) + Chr(10)			
			cTabela+='  				</x:ExcelWorksheets>' + Chr(13) + Chr(10)
			cTabela+='  				<x:WindowHeight>8580</x:WindowHeight>' + Chr(13) + Chr(10)
			cTabela+='  				<x:WindowWidth>15060</x:WindowWidth>' + Chr(13) + Chr(10)
			cTabela+='  				<x:WindowTopX>120</x:WindowTopX>' + Chr(13) + Chr(10)
			cTabela+='  				<x:WindowTopY>60</x:WindowTopY>' + Chr(13) + Chr(10)
			cTabela+='  				<x:ProtectStructure>False</x:ProtectStructure>' + Chr(13) + Chr(10)
			cTabela+='  				<x:ProtectWindows>False</x:ProtectWindows>' + Chr(13) + Chr(10)
			cTabela+=' 			</x:ExcelWorkbook>' + Chr(13) + Chr(10)
			cTabela+='			</xml><![endif]--><!--[if gte mso 9]><xml>' + Chr(13) + Chr(10)
			cTabela+=' 		<o:shapedefaults v:ext="edit" spidmax="1025" fillcolor="none [9]">' + Chr(13) + Chr(10)
			cTabela+='  			<v:fill color="none [9]"/>' + Chr(13) + Chr(10)
			cTabela+=' 		</o:shapedefaults></xml><![endif]-->' + Chr(13) + Chr(10)
			cTabela+='		</head>' + Chr(13) + Chr(10)	   			   		
	   		cTabela+='		<body link=blue vlink=purple>' + Chr(13) + Chr(10)			
			cTabela+='			<table x:str border=0 cellpadding=0 cellspacing=0 width=5310 style="border-collapse:' + Chr(13) + Chr(10)
			cTabela+=' 			collapse;table-layout:fixed;width:3986pt">' + Chr(13) + Chr(10)
			
			For nI := 2 To Len(aHeadSE1)
				cTabela+=' 			<col width=66 style="mso-width-source:userset;mso-width-alt:3000;width:50pt">' + Chr(13) + Chr(10)
			Next nI  
			
			cTabela+=' 			<tr class=xl27 height=15 style="Mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)
            
            If nTpRel == 1
                //aAdd(aHeader,  )
            	For nI := 2 To Len(aHeader) //Cabecalho Nao Conciliados            	
					cTabela+='  				<td class=xl00 width=84 style="width:63pt;font-weight:700">' + aHeader[nI] + '</td>' + Chr(13) + Chr(10)
		    	Next nI		    		
				//cTabela+='  				<td class=xl00 width=84 style="width:63pt;font-weight:700">' + RetTitle("FIF_CAPTUR") + '</td>' + Chr(13) + Chr(10)
				cTabela+=' 			</tr>' + Chr(13) + Chr(10) 

			               
				If(FWRITE(nHandle, cTabela) == 0)
					Alert(STR0003)     //"Não foi possível gravar o arquivo!"
				EndIf	
												   								
				//Linha de Dados
				For nI := 1 To Len(aNaoConc)
					cTabela:='			<tr height=15 style="Mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)																							
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,2]        	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,3]        	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,4]        	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,5]        	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,6]        	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,7]        	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,8]        	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,9]        	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">' + DtoC(aNaoConc[nI,10]) 	+ '</td>' + Chr(13) + Chr(10)				
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">' + DtoC(aNaoConc[nI,11]) 	+ '</td>' + Chr(13) + Chr(10)				
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Transform(aNaoConc[nI,12], __cPicSALD) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Transform(aNaoConc[nI,13], __cPicVL) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,34]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,15]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,16]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,17]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Dtoc(aNaoConc[nI,18])    + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,19]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,20]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,21]       	+ '</td>' + Chr(13) + Chr(10)					
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Str(aNaoConc[nI,22])          + '</td>' + Chr(13) + Chr(10)				
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Str(aNaoConc[nI,23])          + '</td>' + Chr(13) + Chr(10)
					cTabela+='  			<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,28]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,29]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,30]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,31]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,32]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='		   		</tr>' + Chr(13) + Chr(10) 
																						
					If(FWRITE(nHandle, cTabela) == 0)
						Alert(STR0003)  //"Nao foi possivel gravar o arquivo!"
					EndIf				   										    
			 	Next nI
		 	
		 	ElseIf nTpRel == 2
		    	For nI := 2 To Len(aHeadSE1) //Cabecalho Titulos Financeiro            	
					cTabela+='  				<td class=xl00 width=84 style="width:63pt;font-weight:700">' + aHeadSE1[nI] + '</td>' + Chr(13) + Chr(10)
		    	Next nI
		    	cTabela+=' 			</tr>' + Chr(13) + Chr(10) 
			               
				If(FWRITE(nHandle, cTabela) == 0)
					Alert(STR0003)    //"Não foi possível gravar o arquivo!"
				EndIf
				
				//Linha de Dados
				For nI := 1 To Len(aTitulos)
					cTabela:='			<tr height=15 style="Mso-height-source:userset;height:15pt">' + Chr(13)  + Chr(10)																							
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">' + DtoC(aTitulos[nI,2])  	+ '</td>' + Chr(13) + Chr(10)				
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">' + DtoC(aTitulos[nI,3])  	+ '</td>' + Chr(13) + Chr(10)				
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Transform(aTitulos[nI,4], __cPicSALD) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aTitulos[nI,5]        	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aTitulos[nI,6]        	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aTitulos[nI,7]        	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aTitulos[nI,8]        	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aTitulos[nI,9]        	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aTitulos[nI,10]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aTitulos[nI,11]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aTitulos[nI,12]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aTitulos[nI,13]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aTitulos[nI,14]  		+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Str(aTitulos[nI,15])     + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' 				+ Chr(13) + Chr(10)
					cTabela+='  		 	<td colspan=2 class=xl00 style="Mso-ignore:colspan"></td>' 				+ Chr(13) + Chr(10)
					cTabela+='  			<td colspan=2 style="Mso-ignore:colspan"></td>' 							+ Chr(13) + Chr(10)
					cTabela+='		   		</tr>' 		
																						
					If(FWRITE(nHandle, cTabela) == 0)
						Alert(STR0003)  //"Nao foi possivel gravar o arquivo!"
					EndIf				   										    
			 	Next nI			    	
			ElseIf nTpRel == 4
                //aAdd(aHeader,  )
                For nI := 2 To Len (aHeader) //Cabecalho Nao Conciliados            	
					cTabela+='  				<td class=xl00 width=84 style="width:63pt;font-weight:700">' + aHeader[nI] + '</td>' + Chr(13) + Chr(10)
		    	Next nI		    		
				//cTabela+='  				<td class=xl00 width=84 style="width:63pt;font-weight:700">' + RetTitle("FIF_CAPTUR") + '</td>' + Chr(13) + Chr(10)
				cTabela+=' 			</tr>' + Chr(13) + Chr(10) 

			               
				If(FWRITE(nHandle, cTabela) == 0)
					Alert(STR0003)     //"Não foi possível gravar o arquivo!"
				EndIf	
												   								
				//Linha de Dados
				For nI := 1 To Len(aNaoConc)
					cTabela:='			<tr height=15 style="Mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)																							
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + dtoc(aNaoConc[nI,10])        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,47]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Transform(aNaoConc[nI,45], __cPicSALD) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Transform(aNaoConc[nI,46], __cPicVL) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,34]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,35]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,02]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,36]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,28]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,37]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,09]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,38]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,27]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,25]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,26]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Transform(aNaoConc[nI,39], __cPicSALD) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Transform(aNaoConc[nI,40], __cPicSALD) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,06]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,08]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,41]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,27]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,42]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,43]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,04]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,44]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,33]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,29]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,31]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aNaoConc[nI,30]        + '</td>' + Chr(13) + Chr(10)
						
					cTabela+='		   	</tr>' + Chr(13) + Chr(10) 
																						
					If(FWRITE(nHandle, cTabela) == 0)
						Alert(STR0003)  //"Nao foi possivel gravar o arquivo!"
					EndIf				   										    
			 	Next nI
		    Else 
		    	For nI := 1 To Len(aHeadSE1) //Cabecalho dos Totais           	
					cTabela+='  				<td class=xl00 width=84 style="width:63pt;font-weight:700">' + aHeadSE1[nI] + '</td>' + Chr(13) + Chr(10)
		    	Next nI
		    	cTabela+=' 			</tr>' + Chr(13) + Chr(10) 
			               
				If(FWRITE(nHandle, cTabela) == 0)
					Alert(STR0003)    //"Não foi possível gravar o arquivo!"
				EndIf
				
				//Linha de Dados
				For nI := 1 To Len(aTitulos)
					cTabela:='			<tr height=15 style="Mso-height-source:userset;height:15pt">' + Chr(13)  + Chr(10)																							
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">' + DtoC(aTitulos[nI,1])  	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">' + Transform(aTitulos[nI,2], __cPicSALD) + '</td>' + Chr(13) + Chr(10)					
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">' + Str(aTitulos[nI,3]) + '</td>' + Chr(13) + Chr(10)				
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Transform(aTitulos[nI,4], __cPicSALD) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Str(aTitulos[nI,5]) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Transform(aTitulos[nI,6], __cPicSALD) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Str(aTitulos[nI,7]) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Transform(aTitulos[nI,8], __cPicSALD) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Str(aTitulos[nI,9]) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Transform(aTitulos[nI,10], __cPicSALD) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Str(aTitulos[nI,11]) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Transform(aTitulos[nI,12], __cPicSALD) + '</td>' + Chr(13) + Chr(10)				
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' 				+ Chr(13) + Chr(10)
					cTabela+='  		 	<td colspan=2 class=xl00 style="Mso-ignore:colspan"></td>' 				+ Chr(13) + Chr(10)
					cTabela+='  			<td colspan=2 style="Mso-ignore:colspan"></td>' 						+ Chr(13) + Chr(10)
					cTabela+='		   		</tr>' 		
																						
					If(FWRITE(nHandle, cTabela) == 0)
						Alert(STR0003)  //"Nao foi possivel gravar o arquivo!"
					EndIf				   										    
			 	Next nI			    	
		    EndIf
			 	 										 																						
			cTabela:='		   		<tr height=15 style="Mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)
			cTabela+='  		  		<td height=15 class=xl00 width=66 style="height:15pt;width:20pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='			 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+=' 		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  				<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)		  
			cTabela+='  		 		<td colspan=2 class=xl00 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=4 class=xl00 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=6 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+=' 	  		</tr>' + Chr(13) + Chr(10)
			cTabela+=' 	   		<tr height=15 style="Mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)
			cTabela+='  		 		<td height=15 class=x100 width=66 style="height:15pt;width:20pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  				<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  	  			<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)			
			cTabela+=' 	 		</tr>' + Chr(13) + Chr(10)
			cTabela+=' 	  		<tr height=15 style="Mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)
			cTabela+='  				<td height=15 colspan=2 style="height:15pt;mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=3 class=xl00 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=3 class=xl00 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td class=xl31></td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td colspan=3 class=xl00 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td colspan=6 class=xl00 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=4 class=xl00 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td colspan=6 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+=' 	  		</tr>' + Chr(13) + Chr(10)
			cTabela+='		   		<tr height=15 style="mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)
			cTabela+='  	   			<td height=15 colspan=2 style="height:15pt;mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td colspan=5 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td class=xl31></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td colspan=6 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td colspan=4 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  	  			<td colspan=6 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+=' 			</tr>' + Chr(13) + Chr(10)
			cTabela+=' 	 		<tr height=15 style="mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)
			cTabela+='  		 		<td height=15 colspan=2 style="height:15pt;mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=5 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td class=xl31></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=6 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=4 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=6 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+=' 			</tr>' + Chr(13) + Chr(10)
			cTabela+=' 	   		<tr height=15 style="mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)
			cTabela+='  		 		<td height=15 colspan=2 style="height:15pt;mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td colspan=5 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00></td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td colspan=6 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td colspan=4 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td colspan=6 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+=' 			</tr>' + Chr(13) + Chr(10)
			cTabela+=' 	   		<tr height=14 style="height:15pt">' + Chr(13) + Chr(10)
			cTabela+='  		  		<td height=14 colspan=5 style="height:15pt;mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td colspan=5 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td class=xl36></td>' + Chr(13) + Chr(10)
			cTabela+='  		   		<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		   		<td colspan=5 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		   		<td colspan=2 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		   		<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		   		<td colspan=6 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+=' 	   		</tr>' + Chr(13) + Chr(10)
			cTabela+=' 			<tr height=14 style="height:15pt">' + Chr(13) + Chr(10)
			cTabela+=' 				<td height=14 colspan=2 style="height:10.5pt;mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=8 class=xl25 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=20 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+=' 			</tr>' + Chr(13) + Chr(10)
			cTabela+=' 			<![if supportMisalignedColumns]>' + Chr(13) + Chr(10)
			cTabela+=' 				<tr height=0 style="display:none">' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			  		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			  		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			  		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  					<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			  		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+=' 				</tr>' + Chr(13) + Chr(10)
			cTabela+=' 			<![endif]>' + Chr(13) + Chr(10)
			cTabela+='			</table>' + Chr(13) + Chr(10)
			cTabela+='	</html>' + Chr(13) + Chr(10)											

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se foi possivel gravar o arquivo, caso nao seja possivel uma mensagem    ³
			//³de alerta sera exibida na tela   			                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If(FWRITE(nHandle, cTabela) == 0)
				Alert(STR0003)  //"Não foi possível gravar o arquivo!"
			Else
				If !__lSmtHTML
					MsgInfo(STR0004 + cArqPesq)  //"Arquivo gerado com sucesso: "
				EndIf			
			EndIf										
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Fecha o arquivo gravado                                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FCLOSE(nHandle)		
			
			If __lSmtHTML
				nRet := CpyS2TW(cArqPesq, .T.)
			    If (nRet == 0)
			        FERASE(cArqPesq)
			    Else
			        Alert(STR0003)
			    EndIf						
			EndIf																
									
		EndIf	
	EndIf
Else
	Alert(STR0005)       //"Não ha dados para gerar o arquivo!"
EndIf

Return()

////////////////////////////////////////////////////////////////////////
// Função	| Fina918DX                                               //
// Autor		| Pedro Pereira Lima                                      //
// Data		| 07/11/2013                                              //
////////////////////////////////////////////////////////////////////////
Function Fina918DX(aConcPar, aIndic, aHeader, aHeadIndic, nTpRel)
Local cArqPesq	:= ""		// Nome do arquivo que foi gerado
Local nHandle	:= 0		// Indicador de arquivo de exportacao aberto
Local nI		:= 0
Local cPathTmp				//Caminho do arquivo
Local cTabela	:= ""
Local nRet      := 0

If (Len(aConcPar) > 0 .And. Len(aIndic) > 0)
	
	If __lSmtHTML
		cPathTmp:= "\Temp\"
	Else
		cPathTmp := cGetFile('',STR0001,0,,.F.,GETF_LOCALHARD+ GETF_RETDIRECTORY+GETF_NETWORKDRIVE) //"Selecione o Diretório"	
    EndIf
        		
	If !Empty(cPathTmp)
		cArqPesq := cPathTmp + 'FINA918_' + Dtos( dDataBase ) + '_' + StrTran( Time(), ':', '' ) +'.xml' 
			
		// Verifica se o arquivo existe e exclui.
		If FILE(cArqPesq)  
			FERASE(cArqPesq)
		EndIf    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria um arquivo do tipo *.xls	                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nHandle := FCREATE(cArqPesq, 0)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o arquivo pode ser criado, caso contrario um alerta sera exibido      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FERROR() != 0
			Alert(STR0002 + cArqPesq )	//"Não foi possível abrir ou criar o arquivo: "		
		Else
			//XML para criacao da planilha Excel		
			cTabela:='<html xmlns:v="urn:schemas-microsoft-com:vml"' + Chr(13) + Chr(10)
			cTabela+='		xmlns:o="urn:schemas-microsoft-com:office:office"' + Chr(13) + Chr(10)
			cTabela+='		xmlns:x="urn:schemas-microsoft-com:office:excel"' + Chr(13) + Chr(10)
			cTabela+='		xmlns="http://www.w3.org/TR/REC-html40">' + Chr(13) + Chr(10)			
			cTabela+='		<head>' + Chr(13) + Chr(10)
			cTabela+='			<meta http-equiv=Content-Type content="text/html; charset=us-ascii">' + Chr(13) + Chr(10)
			cTabela+='			<meta name=ProgId content=Excel.Sheet>' + Chr(13) + Chr(10)
			cTabela+='			<meta name=Generator content="Microsoft Excel 11">' + Chr(13) + Chr(10)
			cTabela+='			<link rel=File-List href="sher305_arquivos/filelist.xml">' + Chr(13) + Chr(10)
			cTabela+='			<link rel=Edit-Time-Data href="sher305_arquivos/editdata.mso">' + Chr(13) + Chr(10)
			cTabela+='			<link rel=OLE-Object-Data href="sher305_arquivos/oledata.mso">' + Chr(13) + Chr(10)
			cTabela+='			<!--[if gte mso 9]><xml>' + Chr(13) + Chr(10)
			cTabela+=' 			<o:DocumentProperties>' + Chr(13) + Chr(10)
			cTabela+='  				<o:LastAuthor>Tellerina</o:LastAuthor>' + Chr(13) + Chr(10)
			cTabela+='  				<o:Created>2009-09-03T15:13:45Z</o:Created>' + Chr(13) + Chr(10)
			cTabela+='  				<o:LastSaved>2011-06-27T17:53:19Z</o:LastSaved>' + Chr(13) + Chr(10)
			cTabela+='  				<o:Company>Totvs</o:Company>' + Chr(13) + Chr(10)
			cTabela+='  				<o:Version>11.8122</o:Version>' + Chr(13) + Chr(10)
			cTabela+=' 			</o:DocumentProperties>' + Chr(13) + Chr(10)
			cTabela+=' 			<o:OfficeDocumentSettings>' + Chr(13) + Chr(10)
			cTabela+='  				<o:DownloadComponents/>' + Chr(13) + Chr(10)
			cTabela+='  				<o:LocationOfComponents HRef="/"/>' + Chr(13) + Chr(10)
			cTabela+=' 			</o:OfficeDocumentSettings>' + Chr(13) + Chr(10)
			cTabela+='			</xml><![endif]-->' + Chr(13) + Chr(10)
			cTabela+='			<style>' + Chr(13) + Chr(10)
			cTabela+='				<!--table' + Chr(13) + Chr(10)
			cTabela+='				{mso-displayed-decimal-separator:"\,";' + Chr(13) + Chr(10)
			cTabela+='		   		mso-displayed-thousand-separator:"\.";}' + Chr(13) + Chr(10)
			cTabela+='		  		@page' + Chr(13) + Chr(10)
			cTabela+='		   		{margin:1.0in .75in 1.0in .75in;' + Chr(13) + Chr(10)
			cTabela+='		   		mso-header-margin:.49in;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-footer-margin:.49in;}' + Chr(13) + Chr(10)
			cTabela+='		  		tr' + Chr(13) + Chr(10)
			cTabela+='		   		{mso-height-source:auto;}' + Chr(13) + Chr(10)
			cTabela+='		   		col' + Chr(13) + Chr(10)
			cTabela+='		   		{mso-width-source:auto;}' + Chr(13) + Chr(10)
			cTabela+='		  		br' + Chr(13) + Chr(10)
			cTabela+='		 		{mso-data-placement:same-cell;}' + Chr(13) + Chr(10)
			cTabela+='		  		.style0' + Chr(13) + Chr(10)
			cTabela+='		  		{mso-number-format:General;' + Chr(13) + Chr(10)
			cTabela+='		  		text-align:general;' + Chr(13) + Chr(10)
			cTabela+='		 		vertical-align:bottom;' + Chr(13) + Chr(10)
			cTabela+='		 		white-space:nowrap;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-rotate:0;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-background-source:auto;' + Chr(13) + Chr(10)
			cTabela+='		   		mso-pattern:auto;' + Chr(13) + Chr(10)
			cTabela+='		  		color:windowtext;' + Chr(13) + Chr(10)
			cTabela+='		  		font-size:8.0pt;' + Chr(13) + Chr(10)
			cTabela+='		 		font-weight:400;' + Chr(13) + Chr(10)              
			cTabela+='		 		font-style:normal;' + Chr(13) + Chr(10)
			cTabela+='		 		text-decoration:none;' + Chr(13) + Chr(10)
			cTabela+='		 		font-family:Tahoma;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-generic-font-family:auto;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-font-charset:0;' + Chr(13) + Chr(10)
			cTabela+='		  		border:none;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-protection:locked visible;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-style-name:Normal;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-style-id:0;}' + Chr(13) + Chr(10)
			cTabela+='	   	   		.style21' + Chr(13) + Chr(10)
			cTabela+='		   		{mso-number-format:General;' + Chr(13) + Chr(10)
			cTabela+='		  		text-align:general;' + Chr(13) + Chr(10)
			cTabela+='		  		vertical-align:bottom;' + Chr(13) + Chr(10)
			cTabela+='		  		white-space:nowrap;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-rotate:0;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-background-source:auto;' + Chr(13) + Chr(10) 
			cTabela+='		  		mso-pattern:auto;' + Chr(13) + Chr(10)
			cTabela+='		   		color:black;' + Chr(13) + Chr(10)
			cTabela+='		   		font-size:10.0pt;' + Chr(13) + Chr(10)
			cTabela+='		  		font-weight:400;' + Chr(13) + Chr(10)
			cTabela+='		   		font-style:normal;' + Chr(13) + Chr(10)
			cTabela+='		   		text-decoration:none;' + Chr(13) + Chr(10)
			cTabela+='		  		font-family:Arial;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-generic-font-family:auto;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-font-charset:0;' + Chr(13) + Chr(10)
			cTabela+='		  		border:none;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-protection:locked visible;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-style-name:Normal_Vendas;}' + Chr(13) + Chr(10)
			cTabela+='		 		td' + Chr(13) + Chr(10)
			cTabela+='		 		{mso-style-parent:style0;' + Chr(13) + Chr(10)
			cTabela+='		 		padding-top:1px;' + Chr(13) + Chr(10)
			cTabela+='		  		padding-right:1px;' + Chr(13) + Chr(10)
			cTabela+='		  		padding-left:1px;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-ignore:padding;' + Chr(13) + Chr(10)
			cTabela+='		  		color:windowtext;' + Chr(13) + Chr(10)
			cTabela+='		   		font-size:8.0pt;' + Chr(13) + Chr(10)
			cTabela+='		  		font-weight:400;' + Chr(13) + Chr(10)
			cTabela+='		  		font-style:normal;' + Chr(13) + Chr(10)
			cTabela+='		 		text-decoration:none;' + Chr(13) + Chr(10)
			cTabela+='		  		font-family:Tahoma;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-generic-font-family:auto;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-font-charset:0;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-number-format:General;' + Chr(13) + Chr(10)
			cTabela+='		   		text-align:general;' + Chr(13) + Chr(10)
			cTabela+='		  		vertical-align:bottom;' + Chr(13) + Chr(10)
			cTabela+='		  		border:none;' + Chr(13) + Chr(10)
			cTabela+='		  		mso-background-source:auto;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-pattern:auto;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-protection:locked visible;' + Chr(13) + Chr(10)
			cTabela+='		 		white-space:nowrap;' + Chr(13) + Chr(10)
			cTabela+='		 		mso-rotate:0;}' + Chr(13) + Chr(10)  
			cTabela+='		  		-->' + Chr(13) + Chr(10)
			cTabela+='			</style>' + Chr(13) + Chr(10)
			cTabela+='			<!--[if gte mso 9]><xml>' + Chr(13) + Chr(10)
			cTabela+=' 			<x:ExcelWorkbook>' + Chr(13) + Chr(10)
			cTabela+='  				<x:ExcelWorksheets>' + Chr(13) + Chr(10)						
			cTabela+='   					<x:ExcelWorksheet>' + Chr(13) + Chr(10)			
			cTabela+='    						<x:Name>Plan1</x:Name>' + Chr(13) + Chr(10)
			cTabela+='    						<x:WorksheetOptions>' + Chr(13) + Chr(10)
			cTabela+='     						<x:DefaultRowHeight>210</x:DefaultRowHeight>' + Chr(13) + Chr(10)
			cTabela+='     						<x:Print>' + Chr(13) + Chr(10)
			cTabela+='      							<x:ValidPrinterInfo/>' + Chr(13) + Chr(10)
			cTabela+='      							<x:HorizontalResolution>600</x:HorizontalResolution>' + Chr(13) + Chr(10)
			cTabela+='      							<x:VerticalResolution>600</x:VerticalResolution>' + Chr(13) + Chr(10)
			cTabela+='     				   		</x:Print>' + Chr(13) + Chr(10)
			cTabela+='     						<x:Zoom>120</x:Zoom>' + Chr(13) + Chr(10)
			cTabela+='     				   		<x:Selected/>' + Chr(13) + Chr(10)
			cTabela+='     						<x:LeftColumnVisible>0</x:LeftColumnVisible>' + Chr(13) + Chr(10)
			cTabela+='     						<x:FreezePanes/>' + Chr(13) + Chr(10)
			cTabela+='     						<x:FrozenNoSplit/>' + Chr(13) + Chr(10)
			cTabela+='     						<x:SplitHorizontal>1</x:SplitHorizontal>' + Chr(13) + Chr(10)
			cTabela+='     				   		<x:TopRowBottomPane>1</x:TopRowBottomPane>' + Chr(13) + Chr(10)
			cTabela+='     						<x:ActivePane>2</x:ActivePane>' + Chr(13) + Chr(10)
			cTabela+='     						<x:Panes>' + Chr(13) + Chr(10)
			cTabela+='      							<x:Pane>' + Chr(13) + Chr(10)
			cTabela+='       								<x:Number>1</x:Number>' + Chr(13) + Chr(10)
			cTabela+='      							</x:Pane>' + Chr(13) + Chr(10)
			cTabela+='      					   		<x:Pane>' + Chr(13) + Chr(10)
			cTabela+='       						   		<x:Number>1</x:Number>' + Chr(13) + Chr(10)
			cTabela+='       						   		<x:ActiveRow>1</x:ActiveRow>' + Chr(13) + Chr(10)
			cTabela+='       								<x:ActiveCol>1</x:ActiveCol>' + Chr(13) + Chr(10)
			cTabela+='      					   		</x:Pane>' + Chr(13) + Chr(10)
			cTabela+='     						</x:Panes>' + Chr(13) + Chr(10)
			cTabela+='     						<x:ProtectContents>False</x:ProtectContents>' + Chr(13) + Chr(10)
			cTabela+='     						<x:ProtectObjects>False</x:ProtectObjects>' + Chr(13) + Chr(10)
			cTabela+='     						<x:ProtectScenarios>False</x:ProtectScenarios>' + Chr(13) + Chr(10)
			cTabela+='    						</x:WorksheetOptions>' + Chr(13) + Chr(10)
			cTabela+='   					</x:ExcelWorksheet>' + Chr(13) + Chr(10)			
			cTabela+='  				</x:ExcelWorksheets>' + Chr(13) + Chr(10)
			cTabela+='  				<x:WindowHeight>8580</x:WindowHeight>' + Chr(13) + Chr(10)
			cTabela+='  				<x:WindowWidth>15060</x:WindowWidth>' + Chr(13) + Chr(10)
			cTabela+='  				<x:WindowTopX>120</x:WindowTopX>' + Chr(13) + Chr(10)
			cTabela+='  				<x:WindowTopY>60</x:WindowTopY>' + Chr(13) + Chr(10)
			cTabela+='  				<x:ProtectStructure>False</x:ProtectStructure>' + Chr(13) + Chr(10)
			cTabela+='  				<x:ProtectWindows>False</x:ProtectWindows>' + Chr(13) + Chr(10)
			cTabela+=' 			</x:ExcelWorkbook>' + Chr(13) + Chr(10)
			cTabela+='			</xml><![endif]--><!--[if gte mso 9]><xml>' + Chr(13) + Chr(10)
			cTabela+=' 		<o:shapedefaults v:ext="edit" spidmax="1025" fillcolor="none [9]">' + Chr(13) + Chr(10)
			cTabela+='  			<v:fill color="none [9]"/>' + Chr(13) + Chr(10)
			cTabela+=' 		</o:shapedefaults></xml><![endif]-->' + Chr(13) + Chr(10)
			cTabela+='		</head>' + Chr(13) + Chr(10)	   			   		
	   		cTabela+='		<body link=blue vlink=purple>' + Chr(13) + Chr(10)			
			cTabela+='			<table x:str border=0 cellpadding=0 cellspacing=0 width=5310 style="border-collapse:' + Chr(13) + Chr(10)
			cTabela+=' 			collapse;table-layout:fixed;width:3986pt">' + Chr(13) + Chr(10)
			
			For nI := 1 To Len(aHeadIndic)
				cTabela+=' 			<col width=66 style="mso-width-source:userset;mso-width-alt:3000;width:50pt">' + Chr(13) + Chr(10)
			Next nI  
			
			cTabela+=' 			<tr class=xl27 height=15 style="Mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)
            
         If nTpRel == 1
                //aAdd(aHeader,  )
            For nI := 2 To Len (aHeader) //Cabecalho Nao Conciliados            	
					cTabela+='  				<td class=xl00 width=84 style="width:63pt;font-weight:700">' + aHeader[nI] + '</td>' + Chr(13) + Chr(10)
		    	Next nI		    		
				//cTabela+='  				<td class=xl00 width=84 style="width:63pt;font-weight:700">' + RetTitle("FIF_CAPTUR") + '</td>' + Chr(13) + Chr(10)
				cTabela+=' 			</tr>' + Chr(13) + Chr(10) 

			               
				If(FWRITE(nHandle, cTabela) == 0)
					Alert(STR0003)     //"Não foi possível gravar o arquivo!"
				EndIf	
												   								
				//Linha de Dados
				For nI := 1 To Len(aConcPar)
					cTabela:='			<tr height=15 style="Mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)																							
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,02]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,03]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,04]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,05]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,06]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,07]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,08]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,09]        + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">' + DtoC(aConcPar[nI,10]) 	+ '</td>' + Chr(13) + Chr(10)				
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">' + DtoC(aConcPar[nI,11]) 	+ '</td>' + Chr(13) + Chr(10)				
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Transform(aConcPar[nI,12], __cPicSALD) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Transform(aConcPar[nI,13], __cPicVL) + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,34]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,15]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,16]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,17]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + DtoC(aConcPar[nI,18])   	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,19]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,20]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,21]       	+ '</td>' + Chr(13) + Chr(10)				
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Str(aConcPar[nI,22])     + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Str(aConcPar[nI,23])     + '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,28]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,29]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,30]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,31]       	+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aConcPar[nI,33]       	+ '</td>' + Chr(13) + Chr(10)
						
					cTabela+='		   	</tr>' + Chr(13) + Chr(10) 
																						
					If(FWRITE(nHandle, cTabela) == 0)
						Alert(STR0003)  //"Nao foi possivel gravar o arquivo!"
					EndIf				   										    
			 	Next nI
		 	
		 	ElseIf nTpRel == 2
		    	For nI := 1 To Len(aHeadIndic) //Cabecalho Titulos Financeiro            	
					cTabela+='  				<td class=xl00 width=84 style="width:63pt;font-weight:700">' + aHeadIndic[nI] + '</td>' + Chr(13) + Chr(10)
		    	Next nI
		    	cTabela+=' 			</tr>' + Chr(13) + Chr(10) 
			               
				If(FWRITE(nHandle, cTabela) == 0)
					Alert(STR0003)    //"Não foi possível gravar o arquivo!"
				EndIf
				
				//Linha de Dados
				For nI := 1 To Len(aIndic)
					cTabela:='			<tr height=15 style="Mso-height-source:userset;height:15pt">' + Chr(13)	+ Chr(10)																							
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">' + Transform(aIndic[nI,01], __cPicSALD) + '</td>' + Chr(13) + Chr(10)				
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">' + Transform(aIndic[nI,02], __cPicSALD) + '</td>' + Chr(13) + Chr(10)				
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,03]   		+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,15]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + DtoC(aIndic[nI,05])		+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + DtoC(aIndic[nI,06])		+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,07]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,08]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,09]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,10]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,11]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,12]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,13]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Str(aIndic[nI,14]) + '</td>' + Chr(13) + Chr(10)
					
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' 				+ Chr(13) + Chr(10)
					cTabela+='  		 	<td colspan=2 class=xl00 style="Mso-ignore:colspan"></td>' 				+ Chr(13) + Chr(10)
					cTabela+='  			<td colspan=2 style="Mso-ignore:colspan"></td>' 							+ Chr(13) + Chr(10)
					cTabela+='		   		</tr>' + Chr(13) + Chr(10) 
																						
					If(FWRITE(nHandle, cTabela) == 0)
						Alert(STR0003)  //"Nao foi possivel gravar o arquivo!"
					EndIf				   										    
			 	Next nI
			 Else
		    	For nI := 1 To Len(aHeadIndic) //Cabecalho Titulos Financeiro            	
					cTabela+='  				<td class=xl00 width=84 style="width:63pt;font-weight:700">' + aHeadIndic[nI] + '</td>' + Chr(13) + Chr(10)
		    	Next nI
		    	cTabela+=' 			</tr>' + Chr(13) + Chr(10) 
			               
				If(FWRITE(nHandle, cTabela) == 0)
					Alert(STR0003)    //"Não foi possível gravar o arquivo!"
				EndIf
				
				//Linha de Dados
				For nI := 1 To Len(aIndic)
					cTabela:='			<tr height=15 style="Mso-height-source:userset;height:15pt">' + Chr(13)	+ Chr(10)																							
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">' + Transform(aIndic[nI,01], __cPicSALD)		+ '</td>' + Chr(13) + Chr(10)				
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">' + Transform(aIndic[nI,02], __cPicSALD)		+ '</td>' + Chr(13) + Chr(10)				
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,03]   		+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,15]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + DtoC(aIndic[nI,05])		+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + DtoC(aIndic[nI,06])		+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,07]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,08]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,09]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,10]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,11]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,12]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + aIndic[nI,13]			+ '</td>' + Chr(13) + Chr(10)
					cTabela+='  		   	<td class=xl00 width=84 style="width:63pt">' + Str(aIndic[nI,14]) + '</td>' + Chr(13) + Chr(10)					
					cTabela+='  		 	<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' 				+ Chr(13) + Chr(10)
					cTabela+='  		 	<td colspan=2 class=xl00 style="Mso-ignore:colspan"></td>' 				+ Chr(13) + Chr(10)
					cTabela+='  			<td colspan=2 style="Mso-ignore:colspan"></td>' 							+ Chr(13) + Chr(10)
					cTabela+='		   		</tr>' + Chr(13) + Chr(10) 
																						
					If(FWRITE(nHandle, cTabela) == 0)
						Alert(STR0003)  //"Nao foi possivel gravar o arquivo!"
					EndIf				   										    
			 	Next nI			    				    	
		   EndIf
			 	 										 																						
			cTabela:='		   		<tr height=15 style="Mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)
			cTabela+='  		  		<td height=15 class=xl00 width=66 style="height:15pt;width:20pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='			 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+=' 		 		    <td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  				<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)		  
			cTabela+='  		 		<td colspan=2 class=xl00 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=4 class=xl00 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=6 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+=' 	  		</tr>' + Chr(13) + Chr(10)
			cTabela+=' 	   		<tr height=15 style="Mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)
			cTabela+='  		 		<td height=15 class=x100 width=66 style="height:15pt;width:20pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  				<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)
			cTabela+='  	  			<td class=xl00 width=84 style="width:63pt">&nbsp;</td>' + Chr(13) + Chr(10)			
			cTabela+=' 	 		</tr>' + Chr(13) + Chr(10)
			cTabela+=' 	  		<tr height=15 style="Mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)
			cTabela+='  				<td height=15 colspan=2 style="height:15pt;mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=3 class=xl00 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=3 class=xl00 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td class=xl31></td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td colspan=3 class=xl00 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td colspan=6 class=xl00 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=4 class=xl00 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td colspan=6 style="Mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+=' 	  		</tr>' + Chr(13) + Chr(10)
			cTabela+='		   		<tr height=15 style="mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)
			cTabela+='  	   			<td height=15 colspan=2 style="height:15pt;mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td colspan=5 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td class=xl31></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td colspan=6 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  	   			<td colspan=4 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  	  			<td colspan=6 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+=' 			</tr>' + Chr(13) + Chr(10)
			cTabela+=' 	 		<tr height=15 style="mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)
			cTabela+='  		 		<td height=15 colspan=2 style="height:15pt;mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=5 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td class=xl31></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=6 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=4 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=6 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+=' 			</tr>' + Chr(13) + Chr(10)
			cTabela+=' 	   		<tr height=15 style="mso-height-source:userset;height:15pt">' + Chr(13) + Chr(10)
			cTabela+='  		 		<td height=15 colspan=2 style="height:15pt;mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td colspan=5 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td class=xl00></td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td colspan=6 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td colspan=4 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		 		<td colspan=6 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+=' 			</tr>' + Chr(13) + Chr(10)
			cTabela+=' 	   		<tr height=14 style="height:15pt">' + Chr(13) + Chr(10)
			cTabela+='  		  		<td height=14 colspan=5 style="height:15pt;mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		  		<td colspan=5 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td class=xl36></td>' + Chr(13) + Chr(10)
			cTabela+='  		   		<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		   		<td colspan=5 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		   		<td colspan=2 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		   		<td colspan=3 class=xl00 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  		   		<td colspan=6 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+=' 	   		</tr>' + Chr(13) + Chr(10)
			cTabela+=' 			<tr height=14 style="height:15pt">' + Chr(13) + Chr(10)
			cTabela+=' 				<td height=14 colspan=2 style="height:10.5pt;mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=8 class=xl25 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+='  				<td colspan=20 style="mso-ignore:colspan"></td>' + Chr(13) + Chr(10)
			cTabela+=' 			</tr>' + Chr(13) + Chr(10)
			cTabela+=' 			<![if supportMisalignedColumns]>' + Chr(13) + Chr(10)
			cTabela+=' 				<tr height=0 style="display:none">' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			  		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			  		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			  		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  					<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			  		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+='  			   		<td width=84 style="width:63pt"></td>' + Chr(13) + Chr(10)
			cTabela+=' 				</tr>' + Chr(13) + Chr(10)
			cTabela+=' 			<![endif]>' + Chr(13) + Chr(10)
			cTabela+='			</table>' + Chr(13) + Chr(10)
			cTabela+='	</html>' + Chr(13) + Chr(10)											

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se foi possivel gravar o arquivo, caso nao seja possivel uma mensagem    ³
			//³de alerta sera exibida na tela   			                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If(FWRITE(nHandle, cTabela) == 0)
				Alert(STR0003)  //"Não foi possível gravar o arquivo!"
			Else
				If !__lSmtHTML
					MsgInfo(STR0004 + cArqPesq)  //"Arquivo gerado com sucesso: "
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Fecha o arquivo gravado                                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FCLOSE(nHandle)				

						
			If __lSmtHTML
				nRet := CpyS2TW(cArqPesq, .T.)
			    If (nRet == 0)
			        FERASE(cArqPesq)
			    Else
			        Alert(STR0003)
			    EndIf						
			EndIf									
		EndIf	
	EndIf
Else
	Alert(STR0005)       //"Não ha dados para gerar o arquivo!"
EndIf

Return()