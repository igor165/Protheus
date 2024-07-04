#INCLUDE "FINA051.ch"
#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA051   บAutor  ณBruno Sobieski      บ Data ณ  01/08/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para informar o codigo do comprovante de detracao    บฑฑ
ฑฑบ          ณpara o Peru                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINA051()
Local oWizard
Local lRet 		:= .F.
Local lParam, lBrowse:=.T., lParam2
Local aParam1,aParam2
Local aConfig1,aConfig2
Local oGet01		
Local nValor	:=	0
Private aTitulos
Private oTitulo
Private oBrowse
Private aBrowse
Private lMeslib := SFE->(ColumnPos( "FE_MESLIB" )) > 0

If Pergunte("FINA051",.T.)
	If mv_par01 == 1	
		aParam1 := {				{ 1 ,STR0001,Replicate(" ",LEN(SA2->A2_COD)) ,"@!" 	 ,"ExistCpo('SA2')"  ,"SA2" ,"" ,65 ,.T. }, ; //"Fornecedor"
									{ 1 ,STR0002,CriaVar("ED_CODIGO") ,"" 	 ,"ExistCpo('SED')"  ,"SED" ,"" ,65 ,.T. }, ; //"Natureza da detra็ใo"
									{ 1 ,STR0003,FirstDay(dDataBase) ,"" 	 ,"FisChkDt(mv_par03)"  ,"" ,"" ,65 ,.T. }, ; //"Emision de"
									{ 1 ,STR0004,dDataBase ,"" 	 ,""  ,"" ,"" ,65 ,.T. }} //"Emision hasta"
		
		aConfig1 := {Replicate(" ",LEN(SA2->A2_COD)),CriaVar("ED_CODIGO"),GetMV("MV_DATAFIS")+1, dDataBase}
		SFB->(DbSetOrder(1))
		SED->(DbSetOrder(1))
		If SFB->(DbSeek(xFilial()+"DIG")) .and. SED->(DBSeek(xFilial()+SFB->FB_NATUREZ))
			aConfig1[2]	:=	SFB->FB_NATUREZ
		Endif
		IF lMeslib
			aParam2 := {			{ 1 ,STR0005 		,""	,"@!" 	 ,""  ,"" ,"" ,65 ,.T. }, ; //"Numero do comprovante"
									{ 1 ,STR0006		,"" ,"" 	 ,"FisChkDt(mv_par02)"  ,"" ,"" ,65 ,.T. }, ;//"Data do deposito"
									{ 1 ,STR0040 		,"" ,"@!" 	 ,"VerifMes(mv_par03)"  ,"" ,"" ,65 ,.T. }} 
			
			aConfig2 := {CriaVar("FE_CERTDET"),Ctod(""),CriaVar("FE_MESLIB")}
		Else
			aParam2 := {			{ 1 ,STR0005 		,""	,"@!" 	 ,""  ,"" ,"" ,65 ,.T. }, ; //"Numero do comprovante"
									{ 1 ,STR0006		,"" ,"" 	 ,"FisChkDt(mv_par02)"  ,"" ,"" ,65 ,.T. }}//"Data do deposito"						 
			
			aConfig2 := {CriaVar("FE_CERTDET"),Ctod("")}
		EndIf
		
		oWizard := APWizard():New(STR0007/*<chTitle>*/,; //"Atencao"
									STR0008/*<chMsg>*/, STR0009/*<cTitle>*/, ;  //"Este assistente o auxiliara no preenchimento dos dados relativos เ comprovante de detra็ใo."###"Contancias de detraccion"
											STR0010/*<cText>*/,;  //"Voce devera escolher o fornecedor e um filtro com a data de emissใo das notas fiscais para posteriormente escolher para quais delas ้ a comprovante sendo informada."
											{|| .T.}/*<bNext>*/, ;
											{|| .T.}/*<bFinish>*/,;
											/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)
		
		oWizard:NewPanel( STR0011/*<chTitle>*/,;  //"Dados para filtro"
								 STR0012/*<chMsg>*/, ;  //"Neste passo voce devera informar os dados para filtrar as notas fiscais."
								 {||.T.}/*<bBack>*/, ;
								 {||Fa051Rest_Par(aConfig1), If(ParamOk(aParam1, aConfig1), Fa051Rest_Par(aConfig2),.F.) }/*<bNext>*/, ;
								 {||.T.}/*<bFinish>*/,;
								 .T./*<.lPanel.>*/,;
								 {||Fa051Rest_Par(aConfig1), ParamBox(aParam1 ,STR0013, aConfig1,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel]) }/*<bExecute>*/ ) //"Filtro"
							  
		oWizard:NewPanel( STR0014/*<chTitle>*/,;  //"Conta Or็amentแria" //"Dados da comprovante"
								STR0015 + iif (lMeslib,STR0041,"") /*<chMsg>*/,;   //"Neste passo voc๊ devera informar os dados da comprovante de deposito"
								{|| Fa051Rest_Par(aConfig1),.T.}/*<bBack>*/, ;
								{|| Fa051Rest_Par(aConfig2), ParamOk(aParam2, aConfig2)}/*<bNext>*/, ;
								{||.T.}/*<bFinish>*/,;
								.T./*<.lPanel.>*/, ;
								{|| Fa051Rest_Par(aConfig2),ParamBox(aParam2 ,STR0016, aConfig2,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel])/*<bExecute>*/ }) //"comprovante"
		
		oWizard:NewPanel( STR0017/*<chTitle>*/,; //"Parโmetros" //"Selecione tํtulos de detra็ใo da comprovante"
		 						STR0018/*<chMsg>*/, ;  //"So estใo disponํveis os tํtulos de detra็ใo baixados anteriormente เ data do dep๓sito e que ainda nใo tiveram comprovante informada."
		 						{||.T.}/*<bBack>*/, ;
		 						{|| Iif(nValor>0,lRet := GeraSFE(aTitulos,aConfig2),.F.)}/*<bNext>*/, ;
		 						{|| .T. }/*<bFinish>*/, ;
		 						.F./*<.lPanel.>*/, ;
		 						{|| Fa051SelTit(aConfig1, @oTitulo,@nValor)/*<bExecute>*/  })  
		 
		oWizard:NewPanel( STR0019/*<chTitle>*/,; //"Parโmetros" //"Finalizado"
		 						STR0020/*<chMsg>*/, ;  //"Opera็ใo finalizada com sucesso."
		 						{||.F.}/*<bBack>*/, ;
		 						{||.T.}/*<bNext>*/, ;
		 						{||.T. }/*<bFinish>*/, ;
		 						.F./*<.lPanel.>*/, ;
		 						{|| /*<bExecute>*/  })  
		
		oTitulo := CreateBrw(oWizard:oMPanel[4],@oTitulo,@oGet01,@nValor) 						
		// 						
		oWizard:Activate( .T./*<.lCenter.>*/,;
								 {||.T.}/*<bValid>*/, ;
								 {||.T.}/*<bInit>*/, ;
								 {||.T.}/*<bWhen>*/ )
	
    Else
		aParam1 := {				{ 1 ,STR0001,Replicate(" ",LEN(SA2->A2_COD)) ,"@!" 	 ,"ExistCpo('SA2')"  ,"SA2" ,"" ,65 ,.T. }, ; //"Fornecedor"
									{ 1 ,"Data do deposito"		,"" ,"" 	 ,"FisChkDt(mv_par02)"  ,"" ,"" ,65 ,.T. }}
		
		aConfig1 := {Replicate(" ",LEN(SA2->A2_COD)),Ctod("")}
		
		oWizard := APWizard():New(STR0007/*<chTitle>*/,; //"Atencao"
									STR0021/*<chMsg>*/, STR0022/*<cTitle>*/, ;  //"Este assistente o auxiliara a limpar os dados relativos ao comprovante de detra็ใo."###"Comprovante de detraccion"
											STR0023/*<cText>*/,;  //"Voce devera escolher o fornecedor e a data de deposito da detra็ใo para posteriormente escolher qual a detra็ใo que deve ser cancelada."
											{|| .T.}/*<bNext>*/, ;
											{|| .T.}/*<bFinish>*/,;
											/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)
		
		oWizard:NewPanel( STR0014/*<chTitle>*/,;  //"Conta Or็amentแria" //"Dados da comprovante"
								STR0015/*<chMsg>*/,;   //"Neste passo voc๊ devera informar os dados da comprovante de deposito"
								{|| .T.}/*<bBack>*/, ;
								{|| Fa051Rest_Par(aConfig1),ParamOk(aParam1, aConfig1)}/*<bNext>*/, ;
								{||.T.}/*<bFinish>*/,;
								.T./*<.lPanel.>*/, ;
								{|| ParamBox(aParam1 ,STR0024, aConfig1,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel])/*<bExecute>*/ }) //"Dados do comprovante"
		
		oWizard:NewPanel( STR0025/*<chTitle>*/,; //"Parโmetros" //"Selecione a detra็ใo"
		 						STR0026/*<chMsg>*/, ;  //"Selecione as detra็๕es que deseja cancelar. ."
		 						{|| Fa051Rest_Par(aConfig1),.T.}/*<bBack>*/, ;
		 						{||lRet := CancelaSFE(aTitulos,aConfig1)}/*<bNext>*/, ;
		 						{|| .T. }/*<bFinish>*/, ;
		 						.F./*<.lPanel.>*/, ;
		 						{|| Fa051SelDet(aConfig1, @oTitulo,@nValor)/*<bExecute>*/  })  
		
		oWizard:NewPanel( STR0019/*<chTitle>*/,; //"Parโmetros" //"Finalizado"
		 						STR0020/*<chMsg>*/, ;  //"Opera็ใo finalizada com sucesso."
		 						{||.F.}/*<bBack>*/, ;
		 						{||.T.}/*<bNext>*/, ;
		 						{||.T. }/*<bFinish>*/, ;
		 						.F./*<.lPanel.>*/, ;
		 						{|| /*<bExecute>*/  })  
		
		oTitulo := CreateBrw2(oWizard:oMPanel[3],@oTitulo,@oGet01,@nValor) 						
		// 						
		oWizard:Activate( .T./*<.lCenter.>*/,;
								 {||.T.}/*<bValid>*/, ;
								 {||.T.}/*<bInit>*/, ;
								 {||.T.}/*<bWhen>*/ )
    
    Endif
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCreateBRW บAutor  ณBruno Sobieski      บ Data ณ  01/08/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCriar o Browse que sera utilizado posteriormente no wizard  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CreateBrw(oWizard, oTitulo,oGet01,nValor)
Local oFont
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local oNever	:= LoadBitmap( GetResources(), "DISABLE" )
Local cVarQ := "  "
Local oPanel 
Local oPanelSay
oPanel		:=	TPanel():New(0,0,'',oWizard,, .T., .T.,, ,20,20)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT    		
oPanelSay	:=	TPanel():New(62,2,'',oPanel,, .T., .T.,, ,20,20)
oPanelSay:Align := CONTROL_ALIGN_BOTTOM

DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD 
aTitulos	:= {	{0,Ctod(""),"","","","",0,0}}
@003,005 Say STR0027   PIXEL Of oPanelSay //"Total selecionado :"
@003,060 MSGET oGet01 VAR nValor FONT oFont PICTURE "@E 999,999,999.99" WHEN .F. PIXEL OF oPanelSay SIZE 60,7   

@ 1, 1 LISTBOX oTitulo   VAR cVarQ Fields;
	  HEADER "",;
	  OemToAnsi(STR0028),;   //						  			  		   //"Emissao"
	  OemToAnsi(STR0029),;  // //"Prefixo"
	  OemToAnsi(STR0030),;  // //"Nฃmero"
	  OemToAnsi(STR0031),;  // //"Tipo"
	  OemToAnsi(STR0032),;  // //"Valor"
	  COLSIZES 12, ;
	  GetTextWidth(0,"BBBBB"),;
	  GetTextWidth(0,"BBB"),;
	  GetTextWidth(0,"BBBBBBBBBBBBB"),;
	  GetTextWidth(0,"BBB"),;
	  GetTextWidth(0,"BBBBBBBBBB");
	  SIZE 10,10 ON DBLCLICK (aTitulos:=F051Troca(oTitulo:nAt,aTitulos,@nValor),oTitulo:Refresh(),oGet01:Refresh()) PIXEL of oPanel  NOSCROLL

   oTitulo:SetArray(aTitulos)
   oTitulo:bLine := { || { If(aTitulos[oTitulo:nAt,1	]==1,oOK,If(aTitulos[oTitulo:nAt,1]==-1,oNo,oNever)),;
		Dtoc(aTitulos[oTitulo:nAt,2]),aTitulos[oTitulo:nAt,3],;
		aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,5],;
		Transform(aTitulos[oTitulo:nAt,6],"@E 999,999,999.99")}}
//////////////////////////
// Marca ou desmarca todos
oTitulo:bHeaderClick := {|oObj,nCol| conout(nCol), If( nCol==1, fMarkAll(@aTitulos, @nValor),Nil), oTitulo:Refresh(),oGet01:Refresh()}
oTitulo:Align := CONTROL_ALIGN_ALLCLIENT
oTitulo:Refresh()      
oTitulo:DrawSelect()
//---
 
Return oTitulo
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCreateBRW บAutor  ณBruno Sobieski      บ Data ณ  01/08/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCriar o Browse que sera utilizado posteriormente no wizard  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CreateBrw2(oWizard, oTitulo)
Local oFont
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local oNever	:= LoadBitmap( GetResources(), "DISABLE" )
Local cVarQ := "  "
Local oPanel 
Local oPanelSay
oPanel		:=	TPanel():New(0,0,'',oWizard,, .T., .T.,, ,20,20)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT    		
oPanelSay	:=	TPanel():New(62,2,'',oPanel,, .T., .T.,, ,20,20)
oPanelSay:Align := CONTROL_ALIGN_BOTTOM

DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD 
aTitulos	:= {	{0,Ctod(""),"",0,0}}
//oBtn := TButton():New( 003, 002, 'Titulos',oPanelSay,{||ShowTitles()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

@ 1, 1 LISTBOX oTitulo   VAR cVarQ Fields;
	  HEADER "",;
	  OemToAnsi(STR0028),;   //						  			  		   //"Emissao"
	  OemToAnsi(STR0030),;  // //"Nฃmero"
	  OemToAnsi(STR0033),;  // //"Titulos"
	  OemToAnsi(STR0032),;  // //"Valor"
	  COLSIZES 12, ;
	  GetTextWidth(0,"BBBBB"),;
	  GetTextWidth(0,"BBBBBBBBBBBBB"),;
	  GetTextWidth(0,"BBB"),;
	  GetTextWidth(0,"BBB"),;
	  SIZE 10,10 ON DBLCLICK (aTitulos:=F051Troca2(oTitulo:nAt,aTitulos),oTitulo:Refresh()) PIXEL of oPanel  NOSCROLL

   oTitulo:SetArray(aTitulos)
   oTitulo:bLine := { || { If(aTitulos[oTitulo:nAt,1	]==1,oOK,If(aTitulos[oTitulo:nAt,1]==-1,oNo,oNever)),;
		Dtoc(aTitulos[oTitulo:nAt,2]),aTitulos[oTitulo:nAt,3],;
		Transform(aTitulos[oTitulo:nAt,4],"@E 999"),;
		Transform(aTitulos[oTitulo:nAt,5],"@E 999,999,999.99")}}
//////////////////////////
// Marca ou desmarca todos
oTitulo:bHeaderClick := {|oObj,nCol| If( nCol==1, fMarkAll2(@aTitulos),Nil), oTitulo:Refresh()}
oTitulo:Align := CONTROL_ALIGN_ALLCLIENT
oTitulo:Refresh()      
oTitulo:DrawSelect()
//---
 
Return oTitulo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFa051SelTit บAutor  ณBruno Sobieski     บ Data ณ 01/08/2010 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณAtualzia o browse com os titulos                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa051SelTit(aConfig1,oTitulo,nValor)
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local oNever	:= LoadBitmap( GetResources(), "DISABLE" )
Local nX
aTitulos	:=	fa051GetTit(aConfig1)
If Len(aTitulos) == 0
	aTitulos	:=	{{0,Ctod(""),"","","","",0,0}}
Endif
nValor	:=	0
For nX:=1 To Len(aTitulos)
	If aTitulos[nX,1] == 1
		nValor	+=	aTitulos[nX,6]
	Endif
Next		
oTitulo:SetArray(aTitulos)      
oTitulo:bLine := { || { If(aTitulos[oTitulo:nAt,1	]==1,oOK,If(aTitulos[oTitulo:nAt,1]==-1,oNo,oNever)),;
		Dtoc(aTitulos[oTitulo:nAt,2]),aTitulos[oTitulo:nAt,3],;
		aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,5],;
		Transform(aTitulos[oTitulo:nAt,6],"@E 999,999,999.99")}}
oTitulo:DrawSelect()
oTitulo:Refresh()    

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFa051SelTit บAutor  ณBruno Sobieski     บ Data ณ 01/08/2010 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณAtualzia o browse com os titulos                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa051SelDet(aConfig1,oTitulo)
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local oNever	:= LoadBitmap( GetResources(), "DISABLE" )
Local nX
aTitulos	:=	fa051GetDet(aConfig1)
If Len(aTitulos) == 0
	aTitulos	:=	{{0,Ctod(""),"",0,0}}
Endif
oTitulo:SetArray(aTitulos)      
   oTitulo:bLine := { || { If(aTitulos[oTitulo:nAt,1	]==1,oOK,If(aTitulos[oTitulo:nAt,1]==-1,oNo,oNever)),;
		Dtoc(aTitulos[oTitulo:nAt,2]),aTitulos[oTitulo:nAt,3],;
		Transform(aTitulos[oTitulo:nAt,4],"@E 999"),;
		Transform(aTitulos[oTitulo:nAt,5],"@E 999,999,999.99")}}
oTitulo:DrawSelect()
oTitulo:Refresh()    

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFa051Troca  บAutor  ณBruno Sobieski     บ Data ณ 01/08/2010 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para marcar/desmarcar os titulos no browse           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function F051Troca(nIt,aArray,nValor)
Local nX
nValor := 0

aArray[nIt,1] := aArray[nIt,1] * -1

For nX:=1 To Len(aArray)
	If aArray[nX,1] == 1
		nValor	+=	aArray[nX,6]
	Endif
Next		

Return aArray
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFa051Troca  บAutor  ณBruno Sobieski     บ Data ณ 01/08/2010 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para marcar/desmarcar os titulos no browse           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function F051Troca2(nIt,aArray)

aArray[nIt,1] := aArray[nIt,1] * -1

Return aArray
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณfMarkAll    บAutor  ณBruno Sobieski      บ Data ณ 01/08/2010บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para inverter a marca dos titulos no browse          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fMarkAll( aTit,nValor )
Local nI 		:= 0
nValor	:=	0
If Len(aTit) > 0
	For nI := 1 to Len(aTit)
		aTit[nI][1]	:= aTit[nI][1] * -1
	Next nI
Endif
For nI:=1 To Len(aTit)
	If aTit[nI,1] == 1
		nValor	+=	aTit[nI,6]
	Endif
Next		

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณfMarkAll    บAutor  ณBruno Sobieski      บ Data ณ 01/08/2010บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para inverter a marca dos titulos no browse          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fMarkAll2( aTit)
Local nI 		:= 0
nValor	:=	0
If Len(aTit) > 0
	For nI := 1 to Len(aTit)
		aTit[nI][1]	:= aTit[nI][1] * -1
	Next nI
Endif                          
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFa051GetTit บAutor  ณBruno Sobieski     บ Data ณ 01/08/2010 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณPesquisa os titulos que serao mostrados ao usuario para     บฑฑ
ฑฑบ          ณselecao                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA051GetTit(aConfig1)
Local cQuery     := "" 
Local cAliasSE2  := "" 
Local aTits	:=	{}
Local nLenFor	:=	GetSx3Cache("E2_FORNECE","X3_TAMANHO") + GetSx3Cache("E2_LOJA","X3_TAMANHO")
Local nLenPref	:=	GetSx3Cache("E2_PREFIXO","X3_TAMANHO")
Local nLenNum	:=	GetSx3Cache("E2_NUM","X3_TAMANHO")
Local nLenTipo	:=	GetSx3Cache("E2_TIPO","X3_TAMANHO")
Local nLenParc	:=	GetSx3Cache("E2_PARCELA","X3_TAMANHO")
cAliasSE2 := GetNextAlias() 

cQuery := "SELECT E2_TITPAI,E2_EMIS1,E2_PREFIXO,E2_NUM,E2_TIPO,E2_VALOR,R_E_C_N_O_ SE2RECNO FROM " + RetSqlName( "SE2" ) + " SE2 " 
cQuery += "WHERE " 
cQuery += "E2_FILIAL='" + xFilial( "SE2" ) + "' AND " 
cQuery += "E2_FORNECE='" + aConfig1[1] + "' AND " 
cQuery += "E2_NATUREZ='" + aConfig1[2] + "' AND " 
cQuery += "E2_TIPO IN ('TX ','TXA') AND " 
cQuery += "E2_EMIS1 BETWEEN '" + Dtos(aConfig1[3]) + "' AND '" + Dtos(aConfig1[4]) + "' AND "
cQuery += "E2_BAIXA <> ' ' AND "
cQuery += "D_E_L_E_T_=' ' "
cQuery += "ORDER BY E2_EMIS1,E2_PREFIXO,E2_NUM"  

cQuery := ChangeQuery( cQuery ) 

dbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSE2, .F., .T. )   

TcSetField( cAliasSE2, "SE2RECNO", "N", 12, 0 ) 
TcSetField( cAliasSE2, "E2_EMIS1", "D",  8, 0 ) 
TcSetField( cAliasSE2, "E2_VALOR", "N", 14, 2 ) 

DbSelectArea(cAliasSE2)
While !(cAliasSE2)->(Eof())
	cFornLoja	:=	Substr(E2_TITPAI,nLenPref+nLenNum+nLenParc+nLenTipo+1,nLenFor)
	cNum		:=	Substr(E2_TITPAI,nLenPref+1,nLenNum)
	cSerie		:=	Substr(E2_TITPAI,1,nLenPref)

	SFE->(DbSetOrder(4))
	If !SFE->(DbSeek(xFilial("SFE")+cFornLoja+cNum+cSerie+"D"))
		Aadd(aTits,{1,;
			E2_EMIS1,;
			E2_PREFIXO,;
   			E2_NUM,;
   			E2_TIPO,;
   			E2_VALOR*(Iif(E2_TIPO == "TXA",-1,1)),;
   			SE2RECNO})   
	Endif
	DbSkip()
Enddo
DbCloseArea()	
Return aTits
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFa051GetTit บAutor  ณBruno Sobieski     บ Data ณ 01/08/2010 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณPesquisa os titulos que serao mostrados ao usuario para     บฑฑ
ฑฑบ          ณselecao                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA051GetDet(aConfig1)
Local aTits	:=	{}
Local cQuery     := "" 
Local cAliasSFE  := "" 
cAliasSFE := GetNextAlias() 
cQuery := "SELECT FE_CERTDET, FE_EMISSAO,Count(*) CONTA, SUM(VALIMPTX-VALIMPTXA) AS FE_VALIMP FROM "
cQuery += "  ( SELECT FE_CERTDET, FE_EMISSAO,Count(*) CONTA,"
cQuery +=" 		CASE WHEN FE_ESPECIE  <> 'TXA' THEN SUM(FE_VALIMP) ELSE 0 END AS VALIMPTX, "
cQuery +=" 		CASE WHEN FE_ESPECIE   = 'TXA' THEN SUM(FE_VALIMP) ELSE 0 END AS VALIMPTXA "
cQuery += " 	FROM " + RetSqlName( "SFE" ) + " SFE " 
cQuery += "		WHERE " 
cQuery += "		FE_FILIAL='" + xFilial( "SFE" ) + "' AND " 
cQuery += "		FE_FORNECE='" + aConfig1[1] + "' AND " 
cQuery += "		FE_TIPO = 'D' AND " 
cQuery += "		FE_EMISSAO = '"+dTOS(aConfig1[2])+"' AND " 
cQuery += "		D_E_L_E_T_=' ' "
cQuery += "		GROUP BY FE_CERTDET,FE_EMISSAO,FE_ESPECIE) TMP  "  
cQuery += "		GROUP BY FE_CERTDET,FE_EMISSAO  "  
cQuery += "ORDER BY FE_EMISSAO,FE_CERTDET"  

cQuery := ChangeQuery( cQuery ) 

dbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSFE, .F., .T. )   

TcSetField( cAliasSFE, "FE_EMISSAO"	, "D",  8, 0 ) 
TcSetField( cAliasSFE, "FE_VALIMP"	, "N", 14, 2 ) 

DbSelectArea(cAliasSFE)
While !(cAliasSFE)->(Eof())
	Aadd(aTits,{-1,;
		FE_EMISSAO,;
		FE_CERTDET,;
		CONTA,;
		FE_VALIMP})   
	DbSkip()
Enddo
DbCloseArea()	
Return aTits

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFa051Rest_ParบAutor ณBruno Sobieski     บ Data ณ 01/08/2010 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para restauracao dos conteudos das variaveis MV_PAR  บฑฑ
ฑฑบ          ณna navegacao entre os paineis do assistente de copia        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa051Rest_Par(aParam)
Local nX
Local cVarMem

For nX := 1 TO Len(aParam)
	cVarMem := "MV_PAR"+AllTrim(STRZERO(nX,2,0))
	&(cVarMem) := aParam[nX]	
Next

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraSFE   บAutor  ณBruno Sobieski      บ Data ณ  01/08/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para gravar a tabela SFE com os comprovantes da      บฑฑ
ฑฑบ          ณdetracao                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeraSFE(aTits,aConfig2)
Local nX

BEGIN TRANSACTION
For nX:= 1 To Len(aTits)
	SE2->(MsGoTo(aTits[nx,7]))
	If aTits[nX,1]== 1
		RecLock("SFE",.T.)
		FE_FILIAL	:=	xFilial()
		FE_CERTDET	:= aConfig2[1]
		FE_EMISSAO	:= aConfig2[2]
		FE_FORNECE	:= SE2->E2_FORNECE
		FE_LOJA		:= SE2->E2_LOJA
		FE_TIPO		:= "D" 
		FE_NFISCAL	:=	SE2->E2_NUM
		FE_SERIE	:=	SE2->E2_PREFIXO
		FE_VALIMP	:=	SE2->E2_VALOR
		FE_ESPECIE	:=	SE2->E2_TIPO
		FE_PARCELA	:=	SE2->E2_PARCELA
		IF lMeslib
			FE_MESLIB	:=	aConfig2[3]
		EndIF
		MsUnLock()
	Endif
Next	
END TRANSACTION
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCancelaSFEบAutor  ณBruno Sobieski      บ Data ณ  01/08/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para cancelar os comprovantes da detracao            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CancelaSFE(aTits,aConfig1)
Local nX
Local lRet	:=	.T. 
Local cTx	:=	""
For nX:= 1 To Len(aTits)
	If aTits[nX,1]== 1
		SFE->(DbSetOrder(11))
		SFE->(DbSeek(xFilial("SFE")+aTits[nX,3]+"D"))
		While lRet	.And. !SFE->(EOF()) .And.xFilial("SFE")+aTits[nX,3]+"D" == SFE->FE_FILIAL+SFE->FE_CERTDET+SFE->FE_TIPO
			SE2->(DbSetOrder(6))
			cTx	:= Iif(SFE->FE_ESPECIE$MV_CPNEG,"TXA","TX "	)
			IF SE2->(DbSeek(xFilial("SE2")+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_SERIE+SFE->FE_NFISCAL+SFE->FE_PARCELA+cTx))
				If !FisChkDt(SE2->E2_EMIS1,.F.)
					Aviso(STR0034,STR0035+aTits[nX,3]+STR0036+SFE->&(SerieNfId("SFE",3,"FE_SERIE"))+"/"+SFE->FE_NFISCAL+ STR0037+GetMV("MV_DATAFIS")+")",{"Ok"},3) //"Inconsistencia"###"O comprovante "###" nao pode ser cancelado, pois a detra็ใo da nota fiscal "###" foi emitidA em data anterioR ao ultimo fechamento fiscal ("
					lRet	:=	.F.
				Endif
			Endif	
			SFE->(DbSkip())
        Enddo
	Endif
	If !lRet
		Exit
	Endif	
Next	
If lRet
	BEGIN TRANSACTION
	For nX:= 1 To Len(aTits)
		If aTits[nX,1]== 1
			SFE->(DbSetOrder(11))
			SFE->(DbSeek(xFilial("SFE")+aTits[nX,3]+"D"))
			While !SFE->(EOF()) .And.xFilial("SFE")+aTits[nX,3]+"D" == SFE->FE_FILIAL+SFE->FE_CERTDET+SFE->FE_TIPO
				RecLock("SFE",.F.)
				DbDelete()
				MsUnLock()
				DbSkip()			
			Enddo
		Endif
	Next	
	END TRANSACTION
Endif
Return lRet

Function VerifMes(cMesanio)

Local lRet	:=	.T. 
local Cmes := SUBSTR(cMesanio,1,2)
local Cyear1 := SUBSTR(cMesanio,3,1)
local Cyear2 := SUBSTR(cMesanio,4,1)
local Cyear3 := SUBSTR(cMesanio,5,1)
local Cyear4 := SUBSTR(cMesanio,6,1)
local cnumeros:= "1|2|3|4|5|6|7|8|9|0" 

	If len(cMesanio) == 6
		 If Cmes $ "01|02|03|04|05|06|07|08|09|10|11|12"
		 	If Cyear1  $ cnumeros .and. Cyear2  $ cnumeros .and. Cyear3  $ cnumeros .and. Cyear4  $ cnumeros 
		 		lRet := .T.
		 	Else
		 		Help(NIL, NIL, STR0007, NIL, STR0038, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0039})//a๑o no valido
		 	EndIf
		 Else
		 	Help(NIL, NIL, STR0007, NIL, STR0038, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0039})//Mes no valido
		 EndIF
	Else
		Help(NIL, NIL, STR0007, NIL, STR0038, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0039})//Tama๑o no valido
	EndIf

Return lRet