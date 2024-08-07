#INCLUDE "PLSMACRC.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MSOLE.CH"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Define
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
#DEFINE PLS_G_SADT "1"
#DEFINE PLS_G_INTE "2"
#DEFINE PLS_G_OUTR "3"
#DEFINE PLS_G_ODON "4"
#DEFINE PLS_G_REEM "5"
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSMACRC
Controle de macro word

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
Class PLSMACRC From PLSCONTR

METHOD New() Constructor
METHOD CloseDoc(oObj)
METHOD Destroy()
METHOD GetDocPro()

EndClass     
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Class

Heranca
1 = PLSCONTR

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD New() Class PLSMACRC
Return Self
//-------------------------------------------------------------------
/*/{Protheus.doc} GetDocPro
Valida e exibe documento padrao dot

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD GetDocPro() Class PLSMACRC
LOCAL aArea     := GetArea()
LOCAL nHoraBase := Seconds()
LOCAL nValCus	:= 0
LOCAL nValRec   := 0
LOCAL cChkPLA 	:= ""
LOCAL aDad 		:= {}
LOCAL oModelWord:= NIL
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Registro do BD6
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
BD6->( DbSetOrder(1) ) //BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
If BD6->( MSSeek( xFilial("BD6")+B53->( B53_CODOPE + B53_CODLDP + B53_CODPEG + B53_NUMERO + B53_ORIMOV ) ) )
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Se for internacao pega
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If B53->B53_ORIMOV == PLS_G_INTE
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Registro do BE4
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		BE4->( DbSetOrder(1) ) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
		BE4->( MSSeek( xFilial("BE4")+B53->( B53_CODOPE + B53_CODLDP + B53_CODPEG + B53_NUMERO + B53_ORIMOV ) ) )
	EndIf                    
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Registro do BA1
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�                                                        
	BA1->( DbSetOrder(2) )//BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
	BA1->( MSSeek( xFilial("BA1")+B53->B53_MATUSU ) )
	cChkPLA := Iif( Empty(BA1->BA1_CODPLA),BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO),BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO) )
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Registro do BA3
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	BA3->( DbSetOrder(1) ) //BA3_FILIAL + BA3_CODINT + BA3_CODEMP + BA3_MATRIC + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB
	BA3->( MSSeek( xFilial("BA3")+BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC) ) )
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Registro do BA1
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�                                                        
	BTS->( DbSetOrder(1) )//BTS_FILIAL + BTS_MATVID
	BTS->( MSSeek( xFilial("BTS")+BA1->BA1_MATVID ) )
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Verifica se todos foram achados
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�                                                        
	If (B53->B53_ORIMOV == PLS_G_INTE .And. !BE4->( Found() ) ) .Or. !BD6->( Found() ) .Or. !BA3->( Found() ) .Or. !BA1->( Found() ) .Or. !BTS->( Found() )
		_Super:ExbMHelp( STR0001 ) //"N�o foi poss�vel construi todos os relacionamentos da guia"
		Return
	EndIf
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Matriz com dados do processo					
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	AaDD(aDad,{"Adv_MatricNome"		,B53->B53_MATUSU + " - " + AllTrim(BA1->BA1_NOMUSR) })
	AaDD(aDad,{"Adv_TpProc"			,M->B68_DESTPP })
	AaDD(aDad,{"Adv_ParTit"			,BA1->BA1_MAE })
	AaDD(aDad,{"Adv_Plano"			,Posicione("BI3",1,xFilial("BI3")+cChkPLA,"BI3_DESCRI") })
	AaDD(aDad,{"Adv_Telefone"		,BA1->BA1_TELEFO })
	AaDD(aDad,{"Adv_Uf"				,BA1->BA1_ESTADO })
	AaDD(aDad,{"Adv_DtAdesao"		,BA1->BA1_DATINC })
	AaDD(aDad,{"Adv_DtNascimento"	,BTS->BTS_DATNAS })
	AaDD(aDad,{"Adv_Idade"			,If( Empty( BTS->BTS_DATNAS ),0,Calc_Idade( dDataBase,BTS->BTS_DATNAS ) ) } )  
	AaDD(aDad,{"Adv_Acomod"			,Iif(B53->B53_ORIMOV==PLS_G_INTE,BE4->BE4_DESPAD," - ")})
	AaDD(aDad,{"Adv_VlrApr"			,BD6->BD6_VLRAPR })
	AaDD(aDad,{"Adv_VlrAut"			,BD6->BD6_VLRACB })
	AaDD(aDad,{"Adv_QtdApr"			,BD6->BD6_QTDSOL })
	AaDD(aDad,{"Adv_QtdAut"			,Iif(BD6->BD6_STATUS == '1',BD6->BD6_QTDPRO ,'0')})  
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Retorna receita
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�        
    nValRec := _Super:GetReceitaUsu('5',BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_CONEMP,BA1->BA1_VERCON,BA1->BA1_SUBCON,BA1->BA1_VERSUB,BA1->BA1_MATRIC,BA1->BA1_TIPREG,'1900','01',AllTrim(Str(Year(dDataBase))),cMonth(dDataBase),1)            
	AaDD(aDad,{"Adv_VlrCtr",Transform( nValRec, "@E 9,999,999.99" ) })
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Retorna Custo
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    nValCus := _Super:GetCustoUsu('5',BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_CONEMP,BA1->BA1_VERCON,BA1->BA1_SUBCON,BA1->BA1_VERSUB,BA1->BA1_MATRIC,BA1->BA1_TIPREG,'1900','01',AllTrim(Str(Year(dDataBase))),cMonth(dDataBase),.F.)
	AaDD(aDad,{"Adv_VlrUtl",Transform( nValCus, "@E 9,999,999.99" ) })
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Mostra o modelo para que o usario de inicio a criacao do doc no banco de cohecimento
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	Processa( { |lEnd| oModelWord := PLSMACRM():New(1,2,3,1,0.45,0,1,aDad) } )
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Verifica se tem erro
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If !Empty(oModelWord:cErro)
		_Super:ExbMHelp( oModelWord:cErro )
		oModelWord:Destroy()
	EndIf
Else
	_Super:ExbMHelp( STR0002 ) //"Registro n�o encontrado (Guia)"
EndIf	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Dura豫o
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
_Super:SetLog(nHoraBase)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Restaura area															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
RestArea( aArea )       
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Fim da rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return(oModelWord)       
//-------------------------------------------------------------------
/*/{Protheus.doc} CloseDoc
Fecha o link com o arquivo do modelo do word

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD CloseDoc(oWord) Class PLSMACRC
	OLE_CloseFile( oWord )
	OLE_CloseLink( oWord )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destroy o obj link e fecha o arquivo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD Destroy() Class PLSMACRC
	FreeObj(Self:self)
Return
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    쿛LSMACRC  � Autor � Totvs				    � Data � 30/03/10 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao � Somente para compilar a class							  낢굇
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
Function PLSMACRC
Return
