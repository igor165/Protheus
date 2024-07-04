#INCLUDE "UBAA050.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "TopConn.ch"

Static __oMBFardao 	:= Nil
Static __oMBFardo  	:= Nil
Static __oMBMala   	:= Nil
Static __oMBBloco  	:= Nil
Static __oPnMain   	:= Nil
Static __oPnFardao 	:= Nil
Static __oPnFardo  	:= Nil
Static __oPnMala   	:= Nil
Static __oPnBloco  	:= Nil
Static __oPnButton 	:= Nil
 

/*/{Protheus.doc} UBAA050
//Rotina para lançamento de contaminantes
@author jeferson.chaves
@since 21/03/2017
@version undefined

@type function
/*/
Function UBAA050()
	Local aCords 	 := FWGetDialogSize( oMainWnd )
	Local cSayPres   := STR0008 /*"Apresentar"*/ 

	If .Not. TableInDic('N76')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif	

	Private	_oGetSafra 
	Private _oGetContam 
	Private _oCbxEntida 
	Private _oCbxPres
	Private _oCbxDe
	Private _oCbxAte
	Private _oResult 
	Private _oDlg
	Private	_cGetContam 		:= Space(TAMSX3("N76_CODIGO")[1]) 
	Private	_cGetSafra			:= Space(TAMSX3("NJU_CODSAF")[1])
	Private _cResult			:= Space(TAMSX3("NPX_RESTXT")[1])
	Private _cGetDe				:= ""//Space(TAMSX3("DXI_CODIGO")[1])
	Private _cGetAte			:= ""//Space(TAMSX3("DXI_CODIGO")[1])	
	Private _cListResul			:= ""
	Private _dResult			:= dDataBase
	Private _nResult			:= 0
	Private _aEntidade 			:= {AGRSX2NOME("DXL"),AGRSX2NOME("DXI"),AGRSX2NOME("DXJ"), AGRSX2NOME("DXD")}
	Private _cEntidade 			:= AGRSX2NOME("DXL")
	Private _aListResul			:= {}
	Private _oSayPres
	Private _oSayDe
	Private _oSayAte
	Private _nRegCount          := 0
	Private _oRegCount
	Private _lAltera			:= .F.
	Private _cSayMala  
	Private _nCntMala           := 0	
	Private _oCntMala                      
	
	// Montagem da Tela 
	_oDlg := TDialog():New( aCords[ 1 ], aCords[ 2 ], aCords[ 3 ], aCords[ 4 ], STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Lançamento de Contaminantes"
	_oDlg:lEscClose := .F. //Não sai da rotina ao acionar a tecla Esc 
	
	oSZ := FwDefSize():New()             
	oSZ:AddObject( "CABECALHO",  100, 10, .T., .T. ) // Totalmente dimensionavel
	oSZ:AddObject( "GRID"     ,  100, 80, .T., .T. ) // Totalmente dimensionavel
	oSZ:AddObject( "RODAPE"   ,  100, 10, .T., .T. ) // Totalmente dimensionavel
	               
    oSZ:lProp 	 := .T. // Proporcional             
	oSZ:aMargins := { 1, 1, 1, 1 } // Espaco ao lado dos objetos 0, entre eles 3 
	oSZ:Process() 	   // Dispara os calculos   
		
	__oPnMain := TPanel():New( oSZ:GetDimension("CABECALHO","LININI"), oSZ:GetDimension("CABECALHO","COLINI"), ,_oDlg, , , , , ,oSZ:GetDimension("CABECALHO","COLEND"), oSZ:GetDimension("CABECALHO","LINEND"))
				
	__oPnFardao := TPanel():New( oSZ:GetDimension("GRID","LININI"), oSZ:GetDimension("GRID","COLINI"), ,_oDlg, , , , , ,oSZ:GetDimension("GRID","COLEND"), oSZ:GetDimension("GRID","LINEND")/1.3)
	__oPnFardo  := TPanel():New( oSZ:GetDimension("GRID","LININI"), oSZ:GetDimension("GRID","COLINI"), ,_oDlg, , , , , ,oSZ:GetDimension("GRID","COLEND"), oSZ:GetDimension("GRID","LINEND")/1.3)
	__oPnMala   := TPanel():New( oSZ:GetDimension("GRID","LININI"), oSZ:GetDimension("GRID","COLINI"), ,_oDlg, , , , , ,oSZ:GetDimension("GRID","COLEND"), oSZ:GetDimension("GRID","LINEND")/1.3)
	__oPnBloco  := TPanel():New( oSZ:GetDimension("GRID","LININI"), oSZ:GetDimension("GRID","COLINI"), ,_oDlg, , , , , ,oSZ:GetDimension("GRID","COLEND"), oSZ:GetDimension("GRID","LINEND")/1.3)
	
	__oPnButton := TPanel():New( oSZ:GetDimension("RODAPE","LININI"), oSZ:GetDimension("RODAPE","COLINI"), ,_oDlg, , , , , ,oSZ:GetDimension("RODAPE","COLEND"), oSZ:GetDimension("RODAPE","LINEND"))
	
	@001, 05 Say STR0003	 /*"Safra"*/ 				 SIZE 53, 07 												  		 Of __oPnMain Pixel
	@008, 05 MSGET _oGetSafra  VAR _cGetSafra   SIZE 60, 10  F3 "NJU" VALID NAOVAZIO() .AND. EXISTCPO("NJU") 					 Of __oPnMain Pixel
	
	_oGetSafra:bHelp := {|| ShowHelpCpo(    "NJU_CODSAF",;
                                {GetHlpSoluc("NJU_CODSAF")[1]},2,;
                                {GetHlpSoluc("NJU_CODSAF")[2]},2)}
	
	@001, 70 Say STR0002	/*"Contaminante"*/			 SIZE 53, 07 												  		  Of __oPnMain Pixel
	@008, 70 MSGET _oGetContam VAR _cGetContam  SIZE 40, 10  F3 "N76" VALID NAOVAZIO() .And. EXISTCPO("N76") .And. UBA050SIT() .And. UBA050CONT() Of __oPnMain Pixel HASBUTTON
	_oGetContam:bHelp := {|| ShowHelpCpo(    "N76_CODIGO",;
                                {GetHlpSoluc("N76_CODIGO")[1]},2,;
                                {GetHlpSoluc("N76_CODIGO")[2]},2)}
                                
	@001, 113 Say STR0004 /*"Nome Cont"*/          	SIZE 53, 07     								  						 	Of __oPnMain Pixel
	@008, 113 MSGET Posicione("N76",1,xFilial("N76")+_cGetContam,"N76_NMCON")	SIZE 100, 10 WHEN .F.						 	Of __oPnMain Pixel
	
	_cEntidade := _aEntidade[2]
	@001, 215 Say STR0005 /*"Entidade"*/				 SIZE 20,10 												  	     	Of __oPnMain Pixel
	@008, 215 MSCOMBOBOX _oCbxEntida VAR _cEntidade ITEMS _aEntidade  SIZE 90,13 Valid sfClearMarK() .AND. _oResult:SetFocus()	Of __oPnMain Pixel
	_oCbxEntida:bHelp := {|| ShowHelpCpo(    "NPX_TIPOVA",;
                                {GetHlpSoluc("NPX_TIPOVA")[1]},2,;
                                {GetHlpSoluc("NPX_TIPOVA")[2]},2)}
	
	@001, 310 Say STR0006 /*Resultado*/				 SIZE 53, 07									  						 	Of __oPnMain Pixel
	@008, 310 MSGET _oResult VAR _cResult  	 SIZE 152, 10  												  					 	Of __oPnMain Pixel
	_oResult:bHelp := {|| ShowHelpCpo(    "NPX_RESTXT",;
                                {GetHlpSoluc("NPX_RESTXT")[1]},2,;
                                {GetHlpSoluc("NPX_RESTXT")[2]},2)}
    	
	cPres := STR0011 /*"Ambos"*/
	@001, 470 Say _oSayPres Var cSayPres			 SIZE 40,10 											  							Of __oPnMain Pixel
	@008, 470 MSCOMBOBOX _oCbxPres VAR cPres ITEMS {STR0009 /*"Lançado"*/, STR0010 /*"Não Lançado"*/, STR0011 /*"Ambos"*/}  SIZE 50,13	Of __oPnMain Pixel

	//-- Cabeçalho Segunda linha
	@001, 525 Say _oSayDe  		Var STR0031	/*"De"*/	SIZE 53,07 																						Of __oPnMain Pixel
	@008, 525 MSGET _oCbxDe 	VAR _cGetDe  			SIZE 50,10	Valid VAZIO() .Or. sfVldMarK("1") .AND. sfVerTam() WHEN _lAltera					Of __oPnMain Pixel

	@001, 580 Say _oSayAte     	Var STR0032	/*"Até"*/	SIZE 53,07																						Of __oPnMain Pixel
	@008, 580 MSGET _oCbxAte 	VAR _cGetAte			SIZE 50,10	Valid VAZIO() .Or. sfVldMarK("2") .AND. sfMarca() .AND. sfVerTam() WHEN _lAltera	Of __oPnMain Pixel
	
	//-- Rodapé
	@001, 05 Say STR0022 /*"Selecionados"*/   SIZE 53, 07 								 Of __oPnButton Pixel
	@008, 05 MSGET _oRegCount  VAR _nRegCount   SIZE 60, 10  WHEN .F. 					 Of __oPnButton Pixel                            
	
	@001, 75 Say _cSayMala /*"Qtd. Fardos Selecionados"*/   SIZE 100, 07 				 Of __oPnButton Pixel
	@008, 75 MSGET _oCntMala   VAR _nCntMala    SIZE 60, 10  WHEN .F. 					 Of __oPnButton Pixel
    							
	MBBlocoCreate()
	MBMalaCreate()
	MBFardoCreate()
	MBFardaoCreate()
	
	__oPnFardao:lVisible 	:= .T.
	__oPnFardo:lVisible  	:= .F.
	__oPnMala:lVisible   	:= .F.
	__oPnBloco:lVisible  	:= .F.
	_oCntMala:lVisible  	:= .F.
	
	_oDlg:Activate( , , , .t., { || .t. }, , { || _oCbxPres:SetFocus() } )
	
Return Nil


/*/{Protheus.doc} UBA050SIT
//Função para validar se o Contaminante esta initivo
@author jeferson.chaves
@since 04/04/2017
@version undefined
@type function
/*/
Static Function UBA050SIT()
	Local lRet := .T.
	Local cSitCON := Posicione("N76",1,xFilial("N76")+_cGetContam,"N76_SITCON")
	
	if .Not. cSitCON = "1"
		Help(,,STR0018,,STR0021, 1, 0) //"ATENCAO"###"Contaminante Inativo"
		lRet := .F.
	endIf
Return lRet

/*/{Protheus.doc} MenuDef
@author jeferson.chaves
@since 21/03/2017
@version undefined
@type function
/*/
Static Function MenuDef()
	Local aRotina 	:= {}
	
	aAdd( aRotina,{"","",0,0,0,Nil})
Return( aRotina )


/*/{Protheus.doc} UBA050CONT
//Função que de acordo com o contaminante, é criado o campo de resultado para tal Tipo de Resultado 
@author jeferson.chaves
@since 28/03/2017
@version undefined
@type function
/*/
Function UBA050CONT()
	Local nQtdCaract := Posicione("N76",1,xFilial("N76")+_cGetContam,"N76_TMCON")
	Local nPrecisao  := Posicione("N76",1,xFilial("N76")+_cGetContam,"N76_VLPRC")
	Local nTipRes	 := Posicione("N76",1,xFilial("N76")+_cGetContam,"N76_TPCON")
	Local lTxt		 := .T.
	Local aReturMask := Iif(nTipRes = "1" .Or. nTipRes = "2" .Or. nTipRes = "5",AGRGerPic(nQtdCaract, nPrecisao, lTxt),{}) 
	Local cMask 	 := Iif(nTipRes = "1" .Or. nTipRes = "2" .Or. nTipRes = "5",Iif(aReturMask[1],aReturMask[2],""),"")
	Local cSayPres   := STR0008 /*"Apresentar"*/
		
	FreeObj(_oResult)
	FreeObj(_oCbxPres)
	FreeObj(_oSayPres)
	
	_nResult := 0
	_cResult := ""
	
	If nTipRes = "1" //Numerico
		@008, 310 MSGET _oResult VAR _nResult  	 SIZE 152, 10  						PICTURE cMask		Valid _oCbxPres:SetFocus()			  Of __oPnMain Pixel
		_oResult:bHelp := {|| ShowHelpCpo(    "NPX_RESNUM",;
                                {GetHlpSoluc("NPX_RESNUM")[1]},2,;
                                {GetHlpSoluc("NPX_RESNUM")[2]},2)}
        @001, 470 Say _oSayPres Var cSayPres		 SIZE 40,10 											 									  Of __oPnMain Pixel
        @008, 470 MSCOMBOBOX _oCbxPres VAR cPres ITEMS {STR0009 /*"Lançado"*/, STR0010 /*"Não Lançado"*/, STR0011 /*"Ambos"*/}  SIZE 50,13 	  Of __oPnMain Pixel                        
	ElseIf nTipRes = "2" //Texto
		_cResult := Space(nQtdCaract)
		@008, 310 MSGET _oResult VAR _cResult  	 SIZE 152, 10  											Valid _oCbxPres:SetFocus()  			  Of __oPnMain Pixel
		_oResult:bHelp := {|| ShowHelpCpo(    "NPX_RESTXT",;
                                {GetHlpSoluc("NPX_RESTXT")[1]},2,;
                                {GetHlpSoluc("NPX_RESTXT")[2]},2)}
        @001, 470 Say _oSayPres Var cSayPres		 SIZE 40,10										 											  Of __oPnMain Pixel
        @008, 470 MSCOMBOBOX _oCbxPres VAR cPres ITEMS {STR0009 /*"Lançado"*/, STR0010 /*"Não Lançado"*/, STR0011 /*"Ambos"*/}  SIZE 50,13 	  Of __oPnMain Pixel                        
	ElseIf nTipRes = "3" //Data
		@008, 310 MSGET _oResult VAR _dResult  	 SIZE 152, 10  											Valid _oCbxPres:SetFocus()			  Of __oPnMain Pixel HASBUTTON
		_oResult:bHelp := {|| ShowHelpCpo(    "NPX_RESDTA",;
                                {GetHlpSoluc("NPX_RESDTA")[1]},2,;
                                {GetHlpSoluc("NPX_RESDTA")[2]},2)}
        @001, 470 Say _oSayPres Var cSayPres		 SIZE 40,10 																				  Of __oPnMain Pixel
        @008, 470 MSCOMBOBOX _oCbxPres VAR cPres ITEMS {STR0009 /*"Lançado"*/, STR0010 /*"Não Lançado"*/, STR0011 /*"Ambos"*/}  SIZE 50,13 	  Of __oPnMain Pixel                        	
	ElseIf nTipRes = "4" //Lista
		UBA050LIST()
		_cListResul := iif(!Empty(_aListResul) ,_aListResul[1],"") 
		@008, 310 MSCOMBOBOX _oResult VAR _cListResul ITEMS _aListResul SIZE 152, 13 						Valid _oCbxPres:SetFocus()			  Of __oPnMain Pixel
		_oResult:bHelp := {|| ShowHelpCpo(    "NPX_RESTXT",;
                                {GetHlpSoluc("NPX_RESTXT")[1]},2,;
                                {GetHlpSoluc("NPX_RESTXT")[2]},2)}
        @001, 470 Say _oSayPres Var cSayPres		 SIZE 40,10 											  									  Of __oPnMain Pixel
        @008, 470 MSCOMBOBOX _oCbxPres VAR cPres ITEMS {STR0009 /*"Lançado"*/, STR0010 /*"Não Lançado"*/, STR0011 /*"Ambos"*/}  SIZE 50,13 	  Of __oPnMain Pixel                        
	Else // = 5 Faixa
		@008, 310 MSGET _oResult VAR _nResult  	 SIZE 152, 10  						PICTURE cMask		Valid _oCbxPres:SetFocus()			  Of __oPnMain Pixel
		_oResult:bHelp := {|| ShowHelpCpo(    "NPX_RESNUM",;
                                {GetHlpSoluc("NPX_RESNUM")[1]},2,;
                                {GetHlpSoluc("NPX_RESNUM")[2]},2)}
        @001, 470 Say _oSayPres Var cSayPres				 SIZE 40,10 											                              Of __oPnMain Pixel
        @008, 470 MSCOMBOBOX _oCbxPres VAR cPres ITEMS {STR0009 /*"Lançado"*/, STR0010 /*"Não Lançado"*/, STR0011 /*"Ambos"*/}  SIZE 50,13 	  Of __oPnMain Pixel                        
	EndIf
	
Return nil


/*/{Protheus.doc} UBA050LIST
//Carrega o tipo Lista de Contaminantes N77
@author jeferson.chaves
@since 28/03/2017
@version undefined
@type function
/*/
Function UBA050LIST()
	_cListResul := ""
	_aListResul := {}

	DbSelectArea("N77")
	DbSetorder(1)
	
	cQuery := " SELECT "								  
	cQuery += "   N77_SEQ AS SEQNCIA, "					  
	cQuery += "   N77_RESULT AS RESULT "				  
	cQuery += " FROM "									  
	cQuery += "   "+RetSQLName("N77")+" N77 "			  
	cQuery += " WHERE "									  
	cQuery += "   N77.D_E_L_E_T_ = '' "					  
	cQuery += "   AND N77_CODCTM = '" + _cGetContam + "' " 
	cQuery := ChangeQuery(cQuery)
	
	TCQUERY cQuery NEW ALIAS "CONTAMIN" 
	
	CONTAMIN->(DBGotop()) 
	Do While .Not. CONTAMIN->(EoF()) 
	 
		aAdd(_aListResul,CONTAMIN->SEQNCIA + " - " + CONTAMIN->RESULT)
		CONTAMIN->(DBSkip()) 
	EndDo 
	     
	CONTAMIN->(DBCloseArea()) 	
Return Nil

/*/{Protheus.doc} ResultLanca
//Função de preparação das informações para lançamento de contaminantes
@author bruna.rocio
@since 28/03/2017
@version undefined
@type function
/*/
Static Function ResultLanca()
	Local lRet       := .T.
	Local _cEntidade  := ""
	Local oGrid      := Nil
	Local cTipoResul := Posicione("N76",1,xFilial("N76")+_cGetContam,"N76_TPCON")
	Local nRat       := 0
	Local nTam       := 0

	Do Case
		Case _oCbxEntida:nAt = 1 //DXL
			_cEntidade := "DXL"
			oGrid := __oMBFardao
		Case _oCbxEntida:nAt = 2 //DXI
			_cEntidade := "DXI"
			oGrid := __oMBFardo
		Case _oCbxEntida:nAt = 3 //DXJ
			_cEntidade := "DXJ"
			oGrid := __oMBMala
		Case _oCbxEntida:nAt = 4 //DXD 
			_cEntidade := "DXD"
			oGrid := __oMBBloco 			
	EndCase
	
	If !AGRIsSelec(_cEntidade, oGrid)
		Help(,,STR0018,,STR0019, 1, 0) //"ATENCAO"###"Nenhum registro selecionado para lançamento"
	ElseIf Empty(_cGetContam)
		Help(,,STR0018,,STR0023, 1, 0) //"ATENCAO"###"Nenhum contaminante selecionado para lançamento."
		lRet := .F.
	Else 
		If MsgYesNo( OemToAnsi(STR0020), OemToAnsi(STR0018)) //"Será efetuado o registro de resultado de contaminante para a entidade. Deseja prosseguir?"##"ATENÇÃO"
	
			Do Case
				Case cTipoResul = "1" //Numerico
					lRet := UBAX050LANC(_cGetContam, _cEntidade, cTipoResul, _nResult, oGrid)
				Case cTipoResul = "2" //Texto
					lRet := UBAX050LANC(_cGetContam, _cEntidade, cTipoResul, _cResult, oGrid)
				Case cTipoResul = "3" //Data
					lRet := UBAX050LANC(_cGetContam, _cEntidade, cTipoResul, _dResult, oGrid)
				Case cTipoResul = "4" //Lista
					nRat := RAT('-',_cListResul)
					nTam := Len(Alltrim(_cListResul)) - nRat - 1
					nRat += 2
					lRet := UBAX050LANC(_cGetContam, _cEntidade, cTipoResul, SUBSTR(_cListResul,nRat,nTam), oGrid)
				Case cTipoResul = "5" //Faixa
					lRet := UBAX050LANC(_cGetContam, _cEntidade, cTipoResul, _nResult, oGrid)
			EndCase
				
			If lRet	
				__oMBFardao:Refresh(.T.)
				RegCount("DXL",__oMBFardao)
				__oMBFardo:Refresh(.T.)
				RegCount("DXI",__oMBFardo)
				__oMBMala:Refresh(.T.)
				RegCount("DXJ",__oMBMala)
				__oMBBloco:Refresh(.T.)
				RegCount("DXD",__oMBBloco)			
			Endif
		Endif	
	Endif	
Return lRet

/*/{Protheus.doc} ResultExclui
//Função de preparação das informações para exclusão do lançamento de contaminantes
@author silvana.torres
@since 11/04/2017
@version undefined
@type function
/*/
Static Function ResultExclui()
	Local lRet       := .T.
	Local _cEntidade  := ""
	Local oGrid      := Nil

	Do Case
		Case _oCbxEntida:nAt = 1 //DXL
			_cEntidade := "DXL"
			oGrid := __oMBFardao
		Case _oCbxEntida:nAt = 2 //DXI
			_cEntidade := "DXI"
			oGrid := __oMBFardo
		Case _oCbxEntida:nAt = 3 //DXJ
			_cEntidade := "DXJ"
			oGrid := __oMBMala
		Case _oCbxEntida:nAt = 4 //DXD 
			_cEntidade := "DXD"
			oGrid := __oMBBloco 			
	EndCase
	
	If !AGRIsSelec(_cEntidade, oGrid)
		Help(,,STR0018,,STR0025, 1, 0) //"ATENCAO"###"Nenhum registro selecionado para exclusão de lançamento"
	ElseIf Empty(_cGetContam)
		Help(,,STR0018,,STR0026, 1, 0) //"ATENCAO"###"Nenhum contaminante selecionado para exclusão de lançamento."
		lRet := .F.
	Else 
		If MsgYesNo( OemToAnsi(STR0027), OemToAnsi(STR0018)) //"Será efetuada a exclusão do registro de resultado de contaminante para a entidade. Deseja prosseguir?"##"ATENÇÃO"
				
			lRet := UBAX050EXC(_cGetContam, _cEntidade, oGrid)
							
			If lRet	
				__oMBFardao:Refresh(.T.)
				RegCount("DXL",__oMBFardao)
				__oMBFardo:Refresh(.T.)
				RegCount("DXI",__oMBFardo)
				__oMBMala:Refresh(.T.)
				RegCount("DXJ",__oMBMala)
				__oMBBloco:Refresh(.T.)
				RegCount("DXD",__oMBBloco)			
			Endif
		Endif	
	Endif	
Return lRet

/*/{Protheus.doc} ResultCont
//Função de abertura da tela de resultado de contaminação
@author silvana.torres
@since 17/04/2017
@version undefined
@type function
/*/
Static Function ResultCont()
	Local lRet       := .T.
	Local _cEntidade  := ""
	Local oGrid      := Nil
	
	Private _cWhereEnt  := ""
	Private _cTitulo    := ""
	
	Private _aSeek 		:= {}

	Do Case
		Case _oCbxEntida:nAt = 1 //DXL
			_cEntidade := "DXL"
			oGrid     := __oMBFardao
			_cWhereEnt := "NPX_FARDAO = '" + DXL->DXL_CODIGO + "' .And. NPX_CODSAF = '" + DXL->DXL_SAFRA + "'"
			_cWhereEnt += " .And. NPX_PRDTOR = '" + DXL->DXL_PRDTOR + "' .And. NPX_LJPRO = '" + DXL->DXL_LJPRO + "' .And. NPX_FAZ =  '" + DXL->DXL_FAZ + "' .And. NPX_ATIVO = '1' "
			_cTitulo   := DXL->DXL_CODIGO  			
		Case _oCbxEntida:nAt = 2 //DXI
			_cEntidade := "DXI"
			oGrid     := __oMBFardo
			_cWhereEnt := "NPX_CODSAF = '" + DXI->DXI_SAFRA + "' .And. NPX_ETIQ =  '" + DXI->DXI_ETIQ + "' .And. NPX_ATIVO = '1'"
			_cTitulo   := DXI->DXI_CODIGO
		Case _oCbxEntida:nAt = 3 //DXJ
			_cEntidade := "DXJ"
			oGrid     := __oMBMala
			_cWhereEnt := "NPX_CODSAF = '" + DXJ->DXJ_SAFRA + "' .And. NPX_ROMCLA =  '" + DXJ->DXJ_CODIGO + "' .And. NPX_ATIVO = '1'"
			_cTitulo   := DXJ->DXJ_CODIGO + " - " + AGRRETSX3BOX("DXJ_TIPO", DXJ->DXJ_TIPO)  			
		Case _oCbxEntida:nAt = 4 //DXD 
			_cEntidade := "DXD"
			oGrid     := __oMBBloco 			
			_cWhereEnt := "NPX_CODSAF = '" + DXD->DXD_SAFRA + "' .And. NPX_BLOCO =  '" + DXD->DXD_CODIGO + "' .And. NPX_ATIVO = '1'"
			_cTitulo   := DXD->DXD_CODIGO
	EndCase
	
	oSize := FWDefSize():New(.T.)
	
	UBAC050LST()
	
Return lRet

/*/{Protheus.doc} AllMarkDXL
//Marca todos os fardões
@author bruna.rocio
@since 04/04/2017
@version undefined

@type function
/*/
Static Function AllMarkDXL()
	Local aArea  := GetArea()
	Local lAtu   := .F.
	
	dbSelectArea("DXL")
	dbGoTop() 
	
	While !Eof()
		lAtu := .T.
		If (DXL->DXL_OK <> __oMBFardao:Mark())
			RecLock("DXL", .F.)
				DXL->DXL_OK := __oMBFardao:Mark()
			MSUnlock()
		ElseIf (DXL->DXL_OK  == __oMBFardao:Mark())
			RecLock("DXL", .F.)
				DXL->DXL_OK  := "  "
			MSUnlock()
		EndIf
		dbSkip() 
	EndDo
	RestArea(aArea)
	
	If lAtu
		RegCount("DXL", __oMBFardao)
	
		__oMBFardao:Refresh()
		__oMBFardao:GoTop()
	Endif	
Return Nil

/*/{Protheus.doc} AllMarkDXI
//Marca todos os fardos
@author bruna.rocio
@since 04/04/2017
@version undefined

@type function
/*/
Static Function AllMarkDXI()
	Local aArea  := GetArea()
	Local lAtu   := .F.
	
	dbSelectArea("DXI")
	dbGoTop() 
	
	While !Eof()
		lAtu := .T.
		If (DXI->DXI_OK <> __oMBFardo:Mark())
			RecLock("DXI", .F.)
				DXI->DXI_OK := __oMBFardo:Mark()
			MSUnlock()
		ElseIf (DXI->DXI_OK  == __oMBFardo:Mark())
			RecLock("DXI", .F.)
				DXI->DXI_OK  := "  "
			MSUnlock()
		EndIf
		dbSkip() 
	EndDo
	RestArea(aArea)
	
	If lAtu
		RegCount("DXI", __oMBFardo)
	
		__oMBFardo:Refresh()
		__oMBFardo:GoTop()
	Endif	
Return Nil


/*/{Protheus.doc} AllMarkDXJ
//Marca todas as malas
@author bruna.rocio
@since 04/04/2017
@version undefined

@type function
/*/
Static Function AllMarkDXJ()
	Local aArea  := GetArea()
	Local lAtu   := .F.
	
	dbSelectArea("DXJ")
	dbGoTop() 
	
	While !Eof()
		lAtu := .T.
		If (DXJ->DXJ_OK <> __oMBMala:Mark())
			RecLock("DXJ", .F.)
				DXJ->DXJ_OK := __oMBMala:Mark()
			MSUnlock()
		ElseIf (DXJ->DXJ_OK  == __oMBMala:Mark())
			RecLock("DXJ", .F.)
				DXJ->DXJ_OK  := "  "
			MSUnlock()
		EndIf
		dbSkip() 
	EndDo
	RestArea(aArea)
	
	If lAtu
		RegCount("DXJ", __oMBMala)
	
		__oMBMala:Refresh()
		__oMBMala:GoTop()
	Endif	
Return Nil


/*/{Protheus.doc} AllMarkDXD
//Marca todos os blocos
@author bruna.rocio
@since 04/04/2017
@version undefined

@type function
/*/
Static Function AllMarkDXD()
	Local aArea  := GetArea()
	Local lAtu   := .F.
	
	dbSelectArea("DXD")
	dbGoTop() 
	
	While !Eof()
		lAtu := .t.
		If (DXD->DXD_OK <> __oMBBloco:Mark())
			RecLock("DXD", .F.)
				DXD->DXD_OK := __oMBBloco:Mark()
			MSUnlock()
		ElseIf (DXD->DXD_OK  == __oMBBloco:Mark())
			RecLock("DXD", .F.)
				DXD->DXD_OK  := "  "
			MSUnlock()
		EndIf
		dbSkip() 
	EndDo
	RestArea(aArea)
	
	If lAtu
		RegCount("DXD", __oMBBloco)
	
		__oMBBloco:Refresh()
		__oMBBloco:GoTop()
	Endif	
Return Nil


/*/{Protheus.doc} CarrEntidade
//Função responsável pelo carregamento das entidades de acordo com seleção
@author bruna.rocio
@since 27/03/2017
@version undefined
@type function
/*/
Static Function CarrEntidade( )
	Local lRet    := .T.
	Local aArea   := GetArea()
		
	Do Case
		Case _oCbxEntida:nAt = 1 //DXL
			__oPnFardao:lVisible 	:= .T.
			__oPnFardo:lVisible  	:= .F.
			__oPnMala:lVisible   	:= .F.
			__oPnBloco:lVisible  	:= .F.
			__oMBFardao:SetFilterDefault("@"+MontaFiltro("DXL","DXL_CODIGO" ,"DXL_PRDTOR","DXL_LJPRO","DXL_FAZ"))
			__oMBFardao:Refresh(.T.)	
			_cSayMala 				:= ""
			_oCntMala:lVisible  	:= .F.
			_lAltera				:= .T.	//-- Indica se altera os campos de Intevalo De/Ate
			_cGetDe					:= Space(TAMSX3("DXL_CODIGO")[1])
			_cGetAte				:= Space(TAMSX3("DXL_CODIGO")[1])				
			RegCount("DXL",__oMBFardao)		
			
		Case _oCbxEntida:nAt = 2 //DXI
			__oPnFardao:lVisible 	:= .F.
			__oPnFardo:lVisible  	:= .T.
			__oPnMala:lVisible   	:= .F.
			__oPnBloco:lVisible  	:= .F.
			__oMBFardo:SetFilterDefault("@"+MontaFiltro("DXI","DXI_ETIQ"))
			__oMBFardo:Refresh(.T.)
			_cSayMala 				:= ""
			_oCntMala:lVisible  	:= .F.
			_lAltera				:= .T.	//-- Indica se altera os campos de Intevalo De/Ate
			_cGetDe					:= Space(TAMSX3("DXI_CODIGO")[1])
			_cGetAte				:= Space(TAMSX3("DXI_CODIGO")[1])				
			RegCount("DXI",__oMBFardo)
			
		Case _oCbxEntida:nAt = 3 //DXJ
			__oPnFardao:lVisible 	:= .F.
			__oPnFardo:lVisible  	:= .F.
			__oPnMala:lVisible   	:= .T.
			__oPnBloco:lVisible  	:= .F.
			__oMBMala:SetFilterDefault("@DXJ_TIPO = 1 AND "+MontaFiltro("DXJ","DXJ_CODIGO"))
			__oMBMala:Refresh(.t.)
			_oCntMala:lVisible  	:= .T.
			_cSayMala 				:=  OemtoAnsi(STR0030)
			_lAltera				:= .F.	//-- Indica se altera os campos de Intevalo De/Ate
			RegCount("DXJ",__oMBMala)
		Case _oCbxEntida:nAt = 4 //DXJ 
			__oPnFardao:lVisible 	:= .F.
			__oPnFardo:lVisible  	:= .F.
			__oPnMala:lVisible   	:= .F.
			__oPnBloco:lVisible  	:= .T.
			__oMBBloco:SetFilterDefault("@"+MontaFiltro("DXD","DXD_CODIGO"))
			__oMBBloco:Refresh(.T.)
			_oCntMala:lVisible  	:= .F.
			_cSayMala 				:= ""
			_lAltera				:= .F.	//-- Indica se altera os campos de Intevalo De/Ate
			RegCount("DXD",__oMBBloco)
	EndCase

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} MontaFiltro
//Monta filtro para apresentação de dados lançados e não lançados dinamicamente de acordo com a entidade
@author bruna.rocio
@since 29/03/2017
@version undefined
@param cEnt, characters, entidade do grid
@param cChvEnt, characters, chave da entidade
@type function
/*/
Static Function MontaFiltro(cEnt, cCodigo, cProdutor, cLoja, cFazenda)
	Local cFiltro := ""
	
	//Do Case
	If _oCbxPres:nAt = 1 //Lançado
		cFiltro := cEnt + "_SAFRA = '" + _cGetSafra + "' AND " +;
		           " EXISTS (SELECT * FROM " + RetSqlName('NPX') + " NPX " +;
				   " Where NPX.D_E_L_E_T_ = ' ' " +;
				   "   and NPX.NPX_FILIAL = '"  + FwXFilial('NPX') + "' " +;
		           "   and NPX.NPX_CODSAF =  '" + _cGetSafra + "' " +;
		           "   and NPX.NPX_CODVA  = '"  + _cGetContam + "' " +;
		           "   and NPX.NPX_CODTA  = '"  + _cGetContam + "' "  +;
		           "   and NPX.NPX_ATIVO  = '1' "
		           		           
		If cEnt = "DXL"
			cFiltro += " And NPX.NPX_FARDAO = DXL_CODIGO And NPX.NPX_PRDTOR = DXL_PRDTOR  "
			cFiltro += " And NPX.NPX_LJPRO  = DXL_LJPRO And NPX.NPX_FAZ = DXL_FAZ) "
		ElseIf cEnt = "DXI"
			cFiltro +=" And NPX.NPX_ETIQ = DXI_ETIQ ) "
		ElseIf cEnt = "DXJ"
			cFiltro += " And NPX.NPX_ROMCLA = DXJ_CODIGO And NPX_TPMALA = DXJ_TIPO )"
		Else //DXD          
		    cFiltro += " And NPX.NPX_BLOCO = DXD_CODIGO )"
		Endif           
			          			 
	ElseIf _oCbxPres:nAt = 2 //Não Lançado
		cFiltro := cEnt + "_SAFRA = '" + _cGetSafra + "' AND " +;
		           " NOT EXISTS (SELECT * FROM " + RetSqlName('NPX') + " NPX " +;
				   " Where NPX.D_E_L_E_T_ = ' ' " +;
				   "   and NPX.NPX_FILIAL = '"  + FwXFilial('NPX') + "' " +;
		           "   and NPX.NPX_CODSAF =  '" + _cGetSafra + "' " +;
		           "   and NPX.NPX_CODVA  = '"  + _cGetContam      + "' " +;
		           "   and NPX.NPX_CODTA  = '"  + _cGetContam + "' "
		           
		If cEnt = "DXL"
			cFiltro += " And NPX.NPX_FARDAO = DXL_CODIGO And NPX.NPX_PRDTOR = DXL_PRDTOR  "
			cFiltro += " And NPX.NPX_LJPRO  = DXL_LJPRO And NPX.NPX_FAZ = DXL_FAZ )"
		ElseIf cEnt = "DXI"
			cFiltro +=" And NPX.NPX_ETIQ = DXI_ETIQ )"
		ElseIf cEnt = "DXJ"
			cFiltro += " And NPX.NPX_ROMCLA = DXJ_CODIGO And NPX_TPMALA = DXJ_TIPO )"
		Else //DXD          
		    cFiltro += " And NPX.NPX_BLOCO = DXD_CODIGO )"
		Endif
	Else //Ambos
		cFiltro := cEnt + "_SAFRA = '" + _cGetSafra + "'"		
	Endif

Return cFiltro


/*/{Protheus.doc} RegCount
//Conta os registros selecionados
@author bruna.rocio
@since 04/04/2017
@version undefined
@param cAliasGrid, characters, descricao
@param oGrid, object, descricao
@type function
/*/
Static Function RegCount(cAliasGrid, oGrid)
	Local aArea := GetArea()
	Local lRet  := .T.
			
	_nRegCount := 0	
	_nCntMala  := 0
		
	dbSelectArea(cAliasGrid)
	dbGoTop()
	
	While .Not. Eof()	
		
		If oGrid:IsMark()
			_nRegCount ++
			
			if cAliasGrid == "DXJ"
				_nCntMala += (cAliasGrid)->DXJ_QTVINC
			endIf 
		Endif
		
		DbSkip()
	EndDo	
	
	_oRegCount:Refresh(.T.)
	_oCntMala:Refresh(.T.)

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} GridLegend
//Calcula o valor da legenda para a entidade
@author bruna.rocio
@since 29/03/2017
@version undefined
@param _cEntidade, characters, entidade do grid
@param cCodigo, characters, codigo da entidade
@type function
/*/
Static Function GridLegend(_cEntidade, cCodigo, cProdutor, cLoja, cFazenda)
	Local aArea := GetArea()
	Local lRet  := .T.
	
	dbSelectArea('NPX')
	
	Do Case
		Case _cEntidade = "DXI"
			dbSetOrder(4)
			lRet := MsSeek(FwXFilial('NPX')+_cGetSafra+cCodigo+PADR(_cGetContam,TamSx3('NPX_CODTA')[1],'')+"1")
		Case _cEntidade = "DXD"
			dbSetOrder(5)
			lRet := MsSeek(FwXFilial('NPX')+_cGetSafra+cCodigo+PADR(_cGetContam,TamSx3('NPX_CODTA')[1],'')+"1")
		Case _cEntidade = "DXJ"
			dbSetOrder(6)
			lRet := MsSeek(FwXFilial('NPX')+_cGetSafra+cCodigo+"1"+PADR(_cGetContam,TamSx3('NPX_CODTA')[1],'')+"1") //mala visual
		Case _cEntidade = "DXL"
			dbSetOrder(7)
			lRet := MsSeek(FwXFilial('NPX')+cCodigo+_cGetSafra+cProdutor+cLoja+cFazenda+PADR(_cGetContam,TamSx3('NPX_CODTA')[1],'')+"1")
	EndCase

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} MBFardaoCreate
//Função para criação de grid para exibição de Fardão
@author bruna.rocio
@since 22/03/2017
@version undefined
@type function
/*/
Static Function MBFardaoCreate()
	Local lRet    := .T.
	Local cFiltro := ""  
	Local aCampos := {'DXL_CODIGO', 'DXL_SAFRA' , 'DXL_CODPRO', 'DXL_PRDTOR', 'DXL_LJPRO' , 'DXL_NMPDTR' , 'DXL_FAZ',;
	                  'DXL_TALHAO', 'DXL_CODVAR', 'DXL_LOCAL' , 'DXL_PSESTI', 'DXL_PSLIQU', 'DXL_DIFCOMP', 'DXL_CODROM', 'DXL_STATUS', 'DXL_CODUNB'}			 
			
	cFiltro := "@DXL_SAFRA = '" + _cGetSafra + "'"
		
	__oMBFardao:=FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
	__oMBFardao:SetDescription(STR0012 /*"Fardão"*/) // Define o titulo do MarkBrowse
	__oMBFardao:SetOwner(__oPnFardao)
	__oMBFardao:SetAlias("DXL") 	
	__oMBFardao:SetFieldMark("DXL_OK")	// Define o campo utilizado para a marcacao
	__oMBFardao:SetFilterDefault(cFiltro)
	__oMBFardao:SetOnlyFields(aCampos)	
	__oMBFardao:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
	__oMBFardao:DisableDetails()	// Desabilita a exibicao dos detalhes do MarkBrowse
	__oMBFardao:DisableReport()	// Desabilita a opcao de imprimir
	__oMBFardao:SetUseFilter(.T.)
	__oMBFardao:AddLegend({||  GridLegend( "DXL", DXL->DXL_CODIGO,DXL->DXL_PRDTOR,DXL->DXL_LJPRO,DXL->DXL_FAZ)}, "Green", STR0009 /*'Lançado'*/)
	__oMBFardao:AddLegend({|| !GridLegend( "DXL", DXL->DXL_CODIGO,DXL->DXL_PRDTOR,DXL->DXL_LJPRO,DXL->DXL_FAZ)}, "Red"  , STR0010 /*'Não Lançado'*/)
	__oMBFardao:SetProfileID('1')
	__oMBFardao:SetMenuDef("")
	__oMBFardao:SetAfterMark({|| RegCount("DXL",__oMBFardao) })
	__oMBFardao:SetAllMark({||AllMarkDXL()})
	__oMBFardao:AddButton(STR0013 /*"Carregar"*/, {||CarrEntidade( )})
	__oMBFardao:AddButton(STR0014 /*"Lançar"*/  , {||ResultLanca( )})
	__oMBFardao:AddButton(STR0024 /*"Excluir"*/  , {||ResultExclui( )})
	__oMBFardao:AddButton(STR0028 /*"Result.Cont."*/  , {||ResultCont()})
	__oMBFardao:Activate(__oPnFardao)	// Ativa o MarkBrowse
			
Return lRet

/*/{Protheus.doc} MBFardoCreate
//Função para criação de grid para exibição de Fardo
@author bruna.rocio
@since 22/03/2017
@version undefined
@type function
/*/
Static Function MBFardoCreate()
	Local lRet    := .T.
	Local cFiltro := ""  
	Local aCampos := {'DXI_CODIGO', 'DXI_SAFRA' , 'DXI_ETIQ'  , 'DXI_PRDTOR', 'DXI_LJPRO' , 'DXI_FAZ',;
	                  'DXI_BLOCO' , 'DXI_FARDAO', 'DXI_PSBRUT', 'DXI_PSLIQU', 'DXI_COSTEL', 'DXI_CODUNB'}			 
			
	cFiltro := "@DXI_SAFRA = '" + _cGetSafra + "'"
	
	__oMBFardo:=FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
	__oMBFardo:SetDescription(STR0015 /*"Fardo"*/) // Define o titulo do MarkBrowse
	__oMBFardo:SetOwner(__oPnFardo)
	__oMBFardo:SetAlias("DXI") 	
	__oMBFardo:SetFieldMark("DXI_OK")	// Define o campo utilizado para a marcacao
	__oMBFardo:SetFilterDefault(cFiltro)
	__oMBFardo:AddLegend({||  GridLegend( "DXI", DXI->DXI_ETIQ)}, "Green", STR0009 /*'Lançado'*/)
	__oMBFardo:AddLegend({|| !GridLegend( "DXI", DXI->DXI_ETIQ)}, "Red"  , STR0010 /*'Não Lançado'*/)
	__oMBFardo:SetOnlyFields(aCampos)	
	__oMBFardo:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
	__oMBFardo:DisableDetails()	// Desabilita a exibicao dos detalhes do MarkBrowse
	__oMBFardo:DisableReport()	// Desabilita a opcao de imprimir
	__oMBFardo:SetProfileID('2')
	__oMBFardo:SetMenuDef("")
	__oMBFardo:SetAfterMark({|| RegCount("DXI",__oMBFardo) })
	__oMBFardo:SetAllMark({||AllMarkDXI()})
	__oMBFardo:AddButton(STR0013 /*"Carregar"*/, {||CarrEntidade( )})
	__oMBFardo:AddButton(STR0014 /*"Lançar"*/  , {||ResultLanca( )})
	__oMBFardo:AddButton(STR0024 /*"Excluir"*/  , {||ResultExclui( )})
	__oMBFardo:AddButton(STR0028 /*"Result.Cont."*/  , {||ResultCont( )})
	
	ADD COLUMN oColumn DATA { || Posicione("DXK",2,xFilial("DXI")+DXI->DXI_SAFRA+DXI->DXI_ETIQ+"1","DXK_CODROM")} TITLE STR0029 SIZE TamSX3("DXJ_CODIGO")[1] PICTURE PesqPict("DXJ","DXJ_CODIGO" ) OF __oMBFardo //Mala
	
	__oMBFardo:Activate()	// Ativa o MarkBrowse
				
Return lRet


/*/{Protheus.doc} MBMalaCreate
//Função de criação da grid para exibição de malas de classificação
@author bruna.rocio
@since 22/03/2017
@version undefined
@type function
/*/
Static Function MBMalaCreate()
	Local lRet    := .T.
	Local cFiltro := ""
	Local aCampos := {'DXJ_CODIGO','DXJ_TIPO', 'DXJ_SAFRA', 'DXJ_PRDTOR', 'DXJ_LJPRO', 'DXJ_FAZ',;
	                  'DXJ_CODVAR', 'DXJ_STATUS', 'DXJ_CODBAR','DXJ_QTVINC', 'DXJ_CODUNB'}		
		
	cFiltro := "@DXJ_SAFRA = '" + _cGetSafra + "'"
	            	
	__oMBMala:=FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
	__oMBMala:SetDescription(STR0016 /*"Mala de Classificação"*/) // Define o titulo do MarkBrowse
	__oMBMala:SetOwner(__oPnMala)
	__oMBMala:SetAlias("DXJ") 	
	__oMBMala:SetFieldMark("DXJ_OK")	// Define o campo utilizado para a marcacao
	__oMBMala:AddLegend({||  GridLegend( "DXJ", DXJ->DXJ_CODIGO)}, "Green", STR0009 /*'Lançado'*/)
	__oMBMala:AddLegend({|| !GridLegend( "DXJ", DXJ->DXJ_CODIGO)}, "Red"  , STR0010 /*'Não Lançado'*/)
	__oMBMala:SetFilterDefault(cFiltro)
	__oMBMala:SetOnlyFields(aCampos)	
	__oMBMala:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
	__oMBMala:DisableDetails()	// Desabilita a exibicao dos detalhes do MarkBrowse
	__oMBMala:DisableReport()	// Desabilita a opcao de imprimir
	__oMBMala:SetProfileID('3')
	__oMBMala:SetMenuDef("")
	__oMBMala:SetAfterMark({|| RegCount("DXJ",__oMBMala) })
	__oMBMala:SetAllMark({||AllMarkDXJ()})
	__oMBMala:AddButton(STR0013 /*"Carregar"*/, {||CarrEntidade( )})
	__oMBMala:AddButton(STR0014 /*"Lançar"*/  , {||ResultLanca( )})
	__oMBMala:AddButton(STR0024 /*"Excluir"*/  , {||ResultExclui( )})
	__oMBMala:AddButton(STR0028 /*"Result.Cont."*/  , {||ResultCont( )})
	__oMBMala:Activate()	// Ativa o MarkBrowse

Return lRet

/*/{Protheus.doc} MBBlocoCreate
//Função de criação da grid para exibição de Blocos
@author bruna.rocio
@since 22/03/2017
@version undefined

@type function
/*/
Static Function MBBlocoCreate()
	Local lRet    := .T.
	Local cFiltro := ""
	Local aCampos := {'DXD_SAFRA' ,'DXD_CODIGO', 'DXD_CLACOM', 'DXD_PRDTOR', 'DXD_LJPRO', 'DXD_FAZ',;
	                  'DXD_CODVAR', 'DXD_LOCAL', 'DXD_QTDMAX', 'DXD_CODUNB'}
	                         			 	
	cFiltro := "@DXD_SAFRA = '" + _cGetSafra + "'"
		
	__oMBBloco:=FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
	__oMBBloco:SetDescription(STR0017 /*"Bloco"*/) // Define o titulo do MarkBrowse
	__oMBBloco:SetOwner(__oPnBloco)
	__oMBBloco:SetAlias("DXD") 	
	__oMBBloco:SetFieldMark("DXD_OK")	// Define o campo utilizado para a marcacao
	__oMBBloco:SetFilterDefault(cFiltro)	
	__oMBBloco:AddLegend({|| GridLegend( "DXD", DXD->DXD_CODIGO)}, "Green", STR0009 /*'Lançado'*/)
	__oMBBloco:AddLegend({|| !GridLegend("DXD", DXD->DXD_CODIGO)}, "Red"  , STR0010 /*'Não Lançado'*/)
	__oMBBloco:SetOnlyFields(aCampos)	
	__oMBBloco:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
	__oMBBloco:DisableDetails()	// Desabilita a exibicao dos detalhes do MarkBrowse
	__oMBBloco:DisableReport()	// Desabilita a opcao de imprimir
	__oMBBloco:SetProfileID('4')
	__oMBBloco:SetMenuDef("")
	__oMBBloco:SetAfterMark({|| RegCount("DXD",__oMBBloco) })
	__oMBBloco:SetAllMark({||AllMarkDXD()})
	__oMBBloco:AddButton(STR0013 /*"Carregar"*/,{||CarrEntidade( )})
	__oMBBloco:AddButton(STR0014 /*"Lançar"*/  ,{||ResultLanca( )})
	__oMBBloco:AddButton(STR0024 /*"Excluir"*/  , {||ResultExclui( )})
	__oMBBloco:AddButton(STR0028 /*"Result.Cont."*/  , {||ResultCont( )})
	__oMBBloco:Activate()	// Ativa o MarkBrowse
	
Return lRet

/*{Protheus.doc} sfMarca
//Funcao para marcar conforme intervalo informado nos campos De/Até
@author 	ana.olegini
@since 		18/12/2017
@version 	P12
*/
Static Function sfMarca()
	Local aArea  := GetArea()
		
	If _oCbxEntida:nAt = 1 //DXL		
		DbSelectArea('DXL')
		DbGoTop()
		While !Eof() 
			RecLock("DXL", .F.)
				DXL->DXL_OK := "  "
			MSUnlock()
			dbSkip() 
		EndDo
		RegCount("DXL", __oMBFardao)
		__oMBFardao:Refresh()
		
		DbSelectArea('DXL')
		DbGoTop()		
		While !Eof() 
			If DXL->DXL_CODIGO >= _cGetDe .AND. DXL->DXL_CODIGO <= _cGetAte
				If (DXL->DXL_OK <> __oMBFardao:Mark())
					RecLock("DXL", .F.)
						DXL->DXL_OK := __oMBFardao:Mark()
					MSUnlock()
				EndIf
			EndIf
			
			dbSkip() 
		EndDo
		RestArea(aArea)
	
		RegCount("DXL", __oMBFardao)	//- FARDAO
		__oMBFardao:Refresh()
	
	ElseIf _oCbxEntida:nAt = 2 //DXI 		
		DbSelectArea('DXI')
		DbGoTop()
		While !Eof() 
			RecLock("DXI", .F.)
				DXI->DXI_OK := "  "
			MSUnlock()
			dbSkip() 
		EndDo
		RegCount("DXI", __oMBFardo)
		__oMBFardo:Refresh()

		DbSelectArea('DXI')
		DbGoTop()	
		While !Eof() 
			If DXI->DXI_CODIGO >= _cGetDe .AND. DXI->DXI_CODIGO <= _cGetAte	
				If (DXI->DXI_OK <> __oMBFardo:Mark())
					RecLock("DXI", .F.)
						DXI->DXI_OK := __oMBFardo:Mark()
					MSUnlock()
				EndIf
			EndIf
			dbSkip() 
		EndDo
		RestArea(aArea)
	
		RegCount("DXI", __oMBFardo)	//- FARDINHOS
		__oMBFardo:Refresh(.T.)
	EndIF
	
Return .T.

/*{Protheus.doc} sfVldMarK
//Validação dos campos De / Ate
@author 	ana.olegini
@since 		18/12/2017
@version 	P12
@param 		cTp, characters, Informa se 1=De e se 2=Ate
@return 	lRetorno, Indica se retorno é .T. ou .F.
*/
Static Function sfVldMarK(cTp)
	Local lRetorno := .T.
	
	If _oCbxEntida:nAt = 1 		//DXL
		cChave := If( cTp == '1', _cGetDe , _cGetAte )
		dbSelectArea("DXL")
		dbSetOrder(1)
		If .NOT. dbSeek(FWxFilial("DXL")+cChave)
			lRetorno := .F.
		EndIf 
	
	ElseIf _oCbxEntida:nAt = 2 //DXI 
		cChave := If( cTp == '1', _cGetDe , _cGetAte )
		dbSelectArea("DXI")
		dbSetOrder(7)
		If .NOT. dbSeek(FWxFilial("DXI")+_cGetSafra+cChave)
			lRetorno := .F.
		EndIf 
	EndIf 
	
	If .NOT. lRetorno 	
		Help(" ",1,".UBAA050SELEC.")	//O código informado para a seleção não é válido.#Favor informar um código para a seleção válido.
	EndIf
Return lRetorno

/*{Protheus.doc} sfClearMarK
//Limpa os campos De / Ate
@author 	ana.olegini
@since 		18/12/2017
@version 	P12
@return 	Indica retorno .T. 
*/
Static Function sfClearMarK()
	_cGetDe 	:= " " 
	_cGetAte 	:= " "
Return .T.

/*{Protheus.doc} sfVerTam
//Verifica se o campo De é maior que o campo Ate
@author 	ana.olegini
@since 		18/12/2017
@version 	P12
@return 	Indica retorno .T. 
*/
Static Function sfVerTam()
	Local lRetorno := .T.
	
	If .NOT. Empty(_cGetAte)
		If _cGetDe > _cGetAte
			Help(" ",1,".UBAA050MAIOR.") //"O código De informado para a seleção não pode ser maior que o código Até."#Favor informar um código maior para a seleção.     
			lRetorno := .F.
		Else
			lRetorno := .T.
		EndIf
	EndIF
	
Return lRetorno