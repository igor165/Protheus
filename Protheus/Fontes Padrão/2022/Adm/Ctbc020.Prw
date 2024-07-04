#INCLUDE "CTBC020.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#include "MSGRAPHI.CH"
#include "fileio.ch"
#Include 'FWMVCDef.ch'

#Define CAMPOCHAVE &(cEntidadeCTB + "->" + cEntidadeCTB + cCampoChave)
// 17/08/2009 -- Filial com mais de 2 caracteres

// TRADUÇÃO RELEASE P10 1.2 - 21/07/08  
Static lFWCodFil := FindFunction("FWCodFil")
Static _oCtbc020
Static _oCtbc0201 
Static _oCtbc0202

//-------------------------------------------------------------------
/*{Protheus.doc} CTBC020
Consulta do plano de contas em formato de TREE e os saldos 

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CTBC020(lBar)

Local aSize		:= {}
Local aObjects	:= {}
Local aPages		:= {}
Local cCadastro 	:= STR0001 
Local nTree
Local oDlg                                   
Local nI
Local aTamCta		:= TAMSX3("CT1_CONTA")
Local aTamCC		:= TAMSX3("CTT_CUSTO")                                                 
Local aTamItem	:= TAMSX3("CTD_ITEM")
Local aTamClVl	:= TAMSX3("CTH_CLVL")                    
Local aTamGrp		:= TAMSX3("CTR_GRUPO")
Local cMascCta	:= GetMV("MV_MASCARA")
Local cMascCC		:= GetMv("MV_MASCCUS")                          
Local lSayGrupo 	:= GetNewPar("MV_CTBNATC","1")=="1"
Local aTitles		:= { STR0002, STR0003, STR0004, STR0005, If(lSayGrupo,STR0062,STR0075), STR0067}, aTitFolder := {} //"Grupos contabeis"
Local cFilIni		:= cFilAnt 
Local lPerbar		:= .F.   

Private cFunName := "CTBC020" //Declarada para não dar erro na função LocxDlgNF (LOCXNF), ao rastrear documentos de entrada
Private aTrees	:= {	{ "CT1", "CQ1", "_CONTA"	, 2,cMascCta,aTamCta[1]  },;
				  		{ "CTT", "CQ3", "_CUSTO"	, 2,cMascCC ,aTamCC[1]   },;
						{ "CTD", "CQ5", "_ITEM"	    , 2,""      ,aTamItem[1] },;
						{ "CTH", "CQ7", "_CLVL"	    , 2,""      ,aTamClVl[1] },;
  						{ "CTR", "CQ1", "_GRUPO"		 , 2,""      ,aTamGrp[1]  };
  				   }
Private cArqTmpCT2 	:= cArqTmpCQ3 := cArqTmpCQ5 := cArqTmpCQ1 := cArqTmpCQ7 := ""
Private cArqTmpICQ1	:= ""
Private aHeader		:= {}
Private aCampos 	:= {}
Private aRotina 	:= {{STR0079, "AxVisual", 0, 2}} // Visualizar
Private nFolder 	:= 1
Private cTpBase 	:= cTpCompara := ""
Private mv_pargf
Private aBackHeader := {{},{}}  
Private cTabCT2		:= ""

Default lBar := .F.

// Caso a função tenha sido chamada por ela mesma a variavel nao pode ser reiniciada
If Type("aSelFil") != "A"
	Private aSelFil := {} 
EndIf
       
If cPaisLoc == "CHI" //Tratamento para correlativos.
	Aadd(aTrees,{"CT2","CT2COR","",1,"",1})	
	Aadd(aRotina,{STR0079, "AxVisual",	0, 2 }) //Ajuste para apresentacao da tela de lancamento manuais.# "Visualizar"
EndIf

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf


// Variaveis utilizadas para parametros								  
// mv_par01				// Data Inicial                  	  		  
// mv_par02				// Data Final                        		  
// mv_par03				// Moeda?          			     		      
// mv_par04				// Tipo de saldo = X1_F3 = SLD           	  
// mv_par05				// Saldo comparacao                      	  
// mv_par06				// Conta Inicial                         	  
// mv_par07				// Conta Final  							  
// mv_par08				// C.Custo Inicial 							  
// mv_par09				// C.Custo Final  							  
// mv_par10				// Item Inicial 							  
// mv_par11				// Item Final 	 							  
// mv_par12				// Cl.Vl. Inicial 							  
// mv_par13				// Cl.Vl Final  							  
// mv_par14				// Seleciona Filiais?						

If !lBar  
	If ! Sx1C020()
		Return
	Endif       
Endif	

dbSelectarea("CTO")
dbSetOrder(1)
If Empty( mv_par03 ) .OR. !MsSeek(xFilial()+mv_par03,.F.)
    Help(" ",1,"NOMOEDA")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize		:= MsAdvSize(,.F.,430)
aObjects	:= {{ 100, 157 , .T., .T. }}
aInfo		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj		:= MsObjSize( aInfo, aObjects )
oTdTree	 	:= {}

DEFINE 	MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5];
			OF oMainWnd PIXEL

For nTree := 1 To Len(aTrees)
	DbSelectArea(aTrees[nTree][1])
	dbSetOrder(1)
	DbSeek(xFilial())
	If ! Eof() .And. Mv_PAR14 == 2
		Aadd(aTitFolder, aTitles[nTree])
	else	
		Aadd(aTitFolder, aTitles[nTree])// carrega sempre os folders quando for consulta por filial
	Endif
Next	

oFolder := TFolder():New(aPosObj[1,1],aPosObj[1,2],aTitFolder,aPages,oDlg,,,,;
						   .T., .F.,aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1],)
	
For ni := 1 to Len(oFolder:aDialogs)
	DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[ni]
Next
	
For nTree := 1 To Len(aTrees)
	MsgRun(STR0080, "",; 
			{ || CursorWait(), CTBCMontaTree(oDlg, @nFolder,;
				 				aTrees[nTree][1], aTrees[nTree][2], aTrees[nTree][3],;
								aTrees[nTree][4], aTrees[nTree][5], aTrees[nTree][6],;
								.F., { 3, 3,(aPosObj[1,3]-32) , 170 }),;
				CursorArrow() }) //Visualizar
Next	

ACTIVATE MSDIALOG oDlg ON INIT Ctbc020Bar(oDlg,@lPerbar,oFolder:nOption) //Incluido numero do Folder

For nTree := 1 To Len(aTrees)
	If Select("TMP" + aTrees[nTree][2]) > 0
		DbSelectArea("TMP" + aTrees[nTree][2])
		DbCloseArea()
		Ferase(&("cArqTmp" + aTrees[nTree][2]) + GetDBExtension())
		If File(&("cArqTmpI" + aTrees[nTree][2]) + IndexExt())
			Ferase(&("cArqTmpI" + aTrees[nTree][2]) + IndexExt())
		Endif
	Endif
Next	

//Apaga as tabelas temporarias no banco de dados
If _oCtbc020 <> Nil
	_oCtbc020:Delete()
	_oCtbc020 := Nil
Endif

If _oCtbc0201 <> Nil
	_oCtbc0201:Delete()
	_oCtbc0201 := Nil
Endif

If _oCtbc0202 <> Nil
	_oCtbc0202:Delete()
	_oCtbc0202 := Nil
Endif

If Select("TMPCT2") > 0
	DbSelectArea("TMPCT2")
	DbCloseArea()
Endif

cFilAnt := cFilIni // retorna para a filial inicial da consulta   

If lPerBar
	CTBC020(.T.)
Endif	

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CTBCMontaTree
Monta Panel e TREE

@author Alvaro Camillo Neto

@param  oDlg  Dialog atual                                       	 
@param  nFolder  Folder Atual                                       	 
@param  cEntidadeCTB  Tabela da entidade contabil para montagem do tree  	 
@param  cEntidadeSld  Tabela do dicionario para busca dos saldos         	 
@param  cCampoChave  Nome do campo chave para relacionamento               
@param  nOrdemSal  Ordem para busca na tabela de saldo                   
@param  cMascara  Mascara para apresentacao no tree                     
@param  nTamanho  Tamanho da mascara                                    
@param  lOutRot  Indica se eh chamada da rotina CTBC030                
@param  aPosTree  Posicao do TREE                                       
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CtbcMontaTree(	oDlg, nFolder, cEntidadeCTB, cEntidadeSld, cCampoChave,	nOrdemSal, cMascara, nTamanho, lOutRot, aPosTree)

Local cNivelCt
Local nNivelCt
Local nNivel 
Local cSemClasse := "CTR"
Local cSemDesMoe := "CTR"    
Local cSuperior	:= ""
Local nTamMasc	 := Iif(cEntidadeCTB $ "CT1/CTT",nTamanho+Len(cMascara)-1,nTamanho)
Local bPromptTree	:= { || AllTrim(If(	cMascara # Nil, MascaraCTB(CAMPOCHAVE,	cMascara,nTamMasc, ""),   CAMPOCHAVE)) + " - " +;
	 &(	cEntidadeCTB + "->" + cEntidadeCTB + "_DESC" + IIf(cEntidadeCTB $ cSemDesMoe, "", "01")) }

Local cCampo
Local oMenu 
Local nIndex
Local cIndice := ""
Local cCpoSup
Local aTreeCorr
Local oGetCorr
Local nX
Local nY
Local nK
Local cModo
Private oTree
Private cFilCor := cFilant
		               	
DbSelectArea(cEntidadeCTB)
dbSetOrder(1)
If !DbSeek(xFilial(cEntidadeCTB))
	Return .T.
Endif

oFolder:aDialogs[nFolder]:oFont := oDlg:oFont
oTree  := DbTree():New(aPosTree[1], aPosTree[2], aPosTree[3], aPosTree[4],oFolder:aDialogs[nFolder],,,.T.)
oTree:lShowHint:= .F. 

oTree:bChange := {|| CTBC020Sal(	oTdTree[oFolder:nOption], oFolder:nOption, lOutRot,;
							 		bPromptTree, cEntidadeCTB, lOutRot) }

Aadd(oTdTree, oTree)

If ! lOutRot 
	oTree:bRClicked := {|o,x,y| (Ctc020CtlMnu(o, oMenu), oMenu:Activate(x,y,oTdTree[oFolder:nOption])) } // Posição x,y em relação a Dialog 
	MENU oMenu POPUP
		MENUITEM STR0006 Action Ctbc020CT2(oTdTree[oFolder:nOption], oFolder:nOption)
		MENUITEM STR0007 Action CTBC020Sal(oTdTree[oFolder:nOption], oFolder:nOption,,bPromptTree, cEntidadeCTB)
		MENUITEM "-"
		MENUITEM cTpBase + " X " + cTpCompara;
		Action Ctbc020Sal(	oTdTree[oFolder:nOption], oFolder:nOption, .T.,bPromptTree, cEntidadeCTB)
	ENDMENU
	oPanel := TPanel():New(3,172,'',oFolder:aDialogs[nFolder], oDlg:oFont, .T.,.T.,,,aPosObj[1][4]-178,aPosObj[1,3]-34,.T.,.T. )
Endif

DbSelectArea(cEntidadeCTB)

oTree:BeginUpdate()

For nK := 1 To len(aSelFil)
	IF MV_PAR14 == 1                                    
		cFilDesc := IIF(FindFunction("FWFilialName"), FWFilialName(cEmpAnt , aSelFil[nK],1),GetAdvFval("SM0","M0_FILIAL",cEmpAnt + aSelFil[nK]) )
		DBADDTREE oTree PROMPT STR0081+" "+aSelFil[nK]+" - "+cFilDesc+space(15) RESOURCE "BMPTABLE" CARGO STR0082+" "+aSelFil[nK]+Space(18)	// Adiciono como nivel // FILIAL // Filial
   ENDIF
	
	cFilAnt := aSelFil[nK]						
	If cEntidadeCTB = "CT1"
		dbSetOrder(1)
		MsSeek(xFilial()+mv_par06, .T.)					/// Busco o nivel da conta inicial
		
		While !Eof() .and. !Empty(CT1->CT1_CTASUP)			/// BUSCA A "CONTA MAE" DO GRUPO.
			MsSeek(xFilial("CT1")+CT1->CT1_CTASUP,.F.)
		EndDo
	
		While !Eof() .and. CT1_FILIAL = xFilial() .And. CT1_CONTA <= mv_par07
			If Empty(CT1->CT1_CTASUP)
				Ctc020VarSup(oTree, CT1->CT1_CONTA, cMascara, nTamanho, nTamMasc, cEntidadeSld)
			Endif
			DbSkip()
		Enddo
		
	ElseIf cEntidadeCTB = "CTR"
	
		dbSetOrder(1)
		DbSeek(xFilial("CTR"))
		
		While &(cEntidadeCTB + "_FILIAL") == xFilial(cEntidadeCTB) .And. !Eof() 
	
			DBADDITEM oTree 	PROMPT Eval(bPromptTree);
					  			RESOURCE "BMPTRG" CARGO cEntidadeSld+;
							  	StrZero((cEntidadeCTB)->(RecNo()),12) +;
							  	Left(cCampoChave + Space(7), 7)+ aSelFil[nK] + " " + Str(nOrdemSal, 1)

			dbSkip()
		End	
		DBENDTREE oTree
	
	// Tratamento de correlativos do Chile.
	ElseIf cEntidadeCTB = "CT2" 
	
		oFolder:nOption := nFolder
	
		oPanel 	:= TPanel():New(3,172,'',oFolder:aDialogs[nFolder], oDlg:oFont, .T.,;
							    .T.,,,aPosObj[1][4]-178,aPosObj[1,3]-34,.T.,.T. )
	   oTree:bRClicked:= {|o,x,y| (oMenu:Activate(x,y,oTdTree[oFolder:nOption])) } // Posição x,y em relação a Dialog 
		oTree:bChange 	:= {|| Ctbc020Cor(Upper(Trim(oTree:GetCargo())),oGetCorr)}
	
		Menu oMenu Popup
			MenuItem STR0067 Action CtcCorrMnu(oGetCorr)
		EndMenu
	
		aTreeCorr :=	{	{STR0069,"ALL_LANCAM",;
									{STR0070,"INTEGRA"},;
								 	{STR0071,"CTBA101"},;
								 	{STR0072,"CTBA102"};
							  	};
							}	
								    
		For nX = 1 to Len(aTreeCorr)
			DbAddTree oTree Prompt aTreeCorr[nX][1]  Resource "BMPTABLE" Cargo aTreeCorr[nX][2]
			For nY = 3 to Len(aTreeCorr[nX])
				DbAddItem oTree PROMPT aTreeCorr[nX][nY][1] ;
				   Resource "BMPTRG" Cargo aTreeCorr[nX][nY][2]
			Next nY
			DbEndTree oTree
		Next nX
		aCampos 	:= CtbCHeader(cEntidadeCTB, "")
		
		If _oCtbc020 <> Nil
			_oCtbc020:Delete()
			_oCtbc020 := Nil
		Endif
		
		_oCtbc020 := FWTemporaryTable():New( "TMPCT2COR" )  
		_oCtbc020:SetFields(aCampos) 
		_oCtbc020:AddIndex("1", {"CT2_FILIAL","CT2_SEGOFI","CT2_SBLOTE"})
		
		//------------------
		//Criação da tabela temporaria
		//------------------
		_oCtbc020:Create()  
			
		oGetCorr := MSGetDB():New(3, 172,(aPosObj[1,3]-32) , aPosObj[1][4] - 5, 1,;
				 		 ".T.", ".T.",,,,,.T.,,"TMPCT2COR",,,,  oFolder:aDialogs[nFolder])
		oGetCorr:oBrowse:blDblClick := {||TMPCT2COR->(dbGoTo(oGetCorr:oBrowse:nAt)),ctcMosDoc()}
	
		oGetCorr:oBrowse:bLostFocus := {||aBackHeader[1]:= aHeader,aBackHeader[2]:= aCampos}
		oGetCorr:oBrowse:bGotFocus  := {||aHeader:= aBackHeader[1],aCampos:= aBackHeader[2]}
	
		Ctbc020Cor(Upper(Trim(oTree:GetCargo())),oGetCorr)	
	
		Eval(oGetCorr:oBrowse:bLostFocus)
	Else
		Do Case
			Case cEntidadeCTB == 'CTT'
				cSuperior	:= 'CTT_FILIAL + CTT_CCSUP'
				cCpoSup		:= 'CTT_CCSUP'
			Case cEntidadeCTB	== 'CTD'                        
				cSuperior	:= 'CTD_FILIAL + CTD_ITSUP'
				cCpoSup		:= 'CTD_ITSUP'
			Case cEntidadeCTB == 'CTH'
				cSuperior	:= 'CTH_FILIAL + CTH_CLSUP'
				cCpoSup		:= 'CTH_CLSUP'
		EndCase	
	
		If !Empty(cSuperior) .And. Empty(IndexKey(5))
			IndRegua(cEntidadeCTB, cIndice := (CriaTrab(, .F. )), cSuperior, cCpoSup + " = ' '",, STR0063)
			nIndex:=RetIndex(cEntidadeCTB)+1
			dbSelectArea(cEntidadeCTB)
		Else
			nIndex := 5
		Endif
	
		DbSetOrder(1)
		DbSeek(xFilial())
		
		While &(cEntidadeCTB + "_FILIAL") = xFilial() .And. ! Eof() 
			If Empty(&cCpoSup)
				Ctc020VarSup(	oTree, &(cEntidadeCTB + cCampoChave), cMascara, nTamanho,;
								nTamMasc, cEntidadeSld, nIndex)
			Endif
			DbSkip()
		Enddo
	
	    If ! Empty(cIndice)
			dbSelectArea(cEntidadeCTB)
			dbClearFilter()
			RetIndex(cEntidadeCTB)
			dbSetOrder(1)
		   	Ferase(cIndice + OrdBagExt()) 
		Endif
	Endif
	if Mv_Par14 == 1  
		DBENDTREE oTree		
	endif	
Next
oTree:EndUpdate()
oTree:Refresh()

nFolder ++ 

cFilant  := cFilCor

Return


//-------------------------------------------------------------------
/*{Protheus.doc} CTBCHeader
Cria aHeader para MsGetDb das consultas 
@author Alvaro Camillo Neto

                                    	 
@param  cArqSx3  Tabela para busca de dicionaro para montagem aHeader  
@param  cCpoChave  Campo chave da tabela (para nao ser apresentado)                                   
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CtbCHeader(cArqSx3, cCpoChave)

Local aSaveArea := GetArea()
Local aFora		:= { cCpoChave, "_MOEDA"	, "_TPSALD"	, "_STATUS",;
								 "_ANTDEB"	, "_ANTCRD", "_LPDEB", "_LPCRD" ,;
								 "_LP"		, "_DTLP", "_IDENT","_ATUCRD","_ATUDEB","_SLDATU","_SLBASE" }  
Local aCampos	:= {}

PRIVATE nUsado := 0

If cCpoChave $ "CQ1_GRUPO/CT7_GRUPO"
	aFora[1] := "CQ1_CONTA"
Endif

aHeader := {}
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek(cArqSx3)
While ! Eof() .And. (X3_ARQUIVO == cArqSx3)
	If x3Uso(x3_usado) .and. cNivel >= x3_nivel
		If Ascan(aFora, { |x| x $ Trim(X3_CAMPO)} ) <= 0
			nUsado++
			AADD(aHeader,{ Trim(X3Titulo()), x3_campo, x3_picture, x3_tamanho  , x3_decimal, x3_valid, x3_usado    , x3_tipo, "TMP" + cArqSx3, x3_context } )
			cCpoX3 := x3_usado         
		EndIF
	EndIF 
	If ! SX3->X3_CONTEXT = "V"
		aAdd( aCampos, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO,SX3->X3_DECIMAL } )
	Endif
			  
	dbSkip()
EndDo

If UPPER( Alltrim(cArqSx3) ) $ "CQ0/CQ1/CQ2/CQ3/CQ4/CQ5/CQ6/CQ7/CQ8/CQ9"
	AADD(aHeader,{	STR0110, cArqSx3+"_ATUDEB", "@E 99,999,999,999,999.00",17   , 2, "",cCpoX3, "N", "TMP" + cArqSx3, x3_context } ) //"Sld Atu Deb"
	AADD(aHeader,{	STR0109, cArqSx3+"_ATUCRD", "@E 99,999,999,999,999.00",17   , 2, "",cCpoX3, "N", "TMP" + cArqSx3, x3_context } ) //"Sld Atu Crd"	
	AADD(aHeader,{	STR0083, cArqSx3+"_SLDATU", "",22   , 0, "",cCpoX3, "C", "TMP" + cArqSx3, x3_context } ) //Saldo Atual
	aAdd( aCampos, {	cArqSx3+"_ATUDEB", "N", 17,2 } )
	aAdd( aCampos, {	cArqSx3+"_ATUCRD", "N", 17,2 } )
	aAdd( aCampos, {	cArqSx3+"_SLDATU", "C", 22,0 } )

EndIf


RestArea(aSaveArea)

Return aCampos

//-------------------------------------------------------------------
/*{Protheus.doc} CTBc020Sal
Retorna o saldo da conta atual no TREE selecionado  

@author Alvaro Camillo Neto
                                    	 
@param  oTree  		Tree atual para obter valores do item selecionado   
@param  nFolder		Folder atual                                       	
@param  lCompara		Indica se eh comparacao entre saldos               	
@param  cDescEnt		Descricao da entidade escolhida no Tree           	
@param  cEntidadeCTB	Entidade base do tree                             	
@param  lOutRot		Indica se eh chamada da rotina CTBC030               

@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CTBc020Sal(	oTree, nFolder, lCompara, cDescEnt, cEntidadeCTB, lOutRot,cEntidadeSld, cCampoChave, nOrdemSal, cCpoChave, aSaldos)
Local nCampos, cCargo
Local nSaldos
Local aContas 	:= {}, nConta, lGrupo := .F.
Local bIndGrp 	:= { || 	IndRegua(	"TMP" + cEntidadeSld,;
	&("cArqTmpI" + cEntidadeSld) := (CriaTrab(, .F. ) ),;
	"DTOS(CQ1_DATA)",,, STR0063) } //"Criando indice de trabalho. Aguarde ..."
Local cFunName 	:= FunName()
Local cAliasSld

Local lAtSldBase	:= Iif(GetMV("MV_ATUSAL")== "S",.T.,.F.)

Local nInicio		:= nFinal := Val(mv_par03), dMinData, cOrigem
Local nTamFilial 	:= IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3( "CT2_FILIAL" )[1] )
Local nCredito
Local nDebito
Local cSaldo
Local cNomeCampo
Local cTipo
Local cConta, cMod
Local cFilSal 	:= cFilAnt
Local cContaSld	:= Nil
Local cCCusto 	:= Nil
Local cItem 		:= Nil
Local cClasse 	:= Nil
Local cIdent 		:= Nil
Local lFirst	:= .T.
Local nAntDeb	:= 0
Local nAntCrd	:= 0
Local nAtuDeb	:= 0
Local nAtuCrd	:= 0
Local nDeb		:= 0
Local nCred	:= 0
Local nSaldoAtu:= 0
Local aSaldoAtu := {}

DEFAULT lCompara := .F.
DEFAULT lOutRot  := .F.
DEFAULT aSaldos  := {}

If oTree # Nil .And. Val( Subs( (cCargo := oTree:GetCargo()), 4, 12 ) ) = 0
	Return .F.
Endif

cCargo := AllTrim( cCargo )

If oTree # Nil
	If lCompara .And. cDescEnt # Nil
		(cEntidadeCTB)->(MSGoto(Val(Subs(cCargo, 4, 12))))
		cDescEnt := Eval(cDescEnt)
	Endif
	
	If lCompara .And. mv_par04 = mv_par05
		ApMsgAlert(STR0025) //"Indique tipos de saldos diferentes para comparacao !"
		Return .F.
	Endif
Endif


If cEntidadeSld = Nil
	cEntidadeSld  	:= Left(cCargo, 3)						// Nome da tabela para busca do SALDO
	cCampoChave 	:= Right(cCargo, 9 + nTamFilial)		// Campo para chave para busca e ultimo BYTE
	
	nOrdemSal  		:= Val(Right(cCampoChave, 1))// eh o Indice
	cCpoFil			:= Left(Right(cCampoChave,2 + nTamFilial ),nTamFilial)
	cCpoChave 		:= oTree:GetPrompt()				  			// Obtenho o item do tree atual
	cCpoChave 		:= Left(cCpoChave, At(" -", cCpoChave) - 1)	// Acho o codigo
	
	cFilAnt 		:= cCpoFil
Endif

If !lAtSldBase	//Se os saldos nao foram atualizados na dig. lancamentos
	//Chama rotina de atualizacao de saldos
	dIniRep := ctod("")
	If Need2Reproc(mv_par02,mv_par03,mv_par04,@dIniRep)
		//Chama Rotina de Atualizacao de Saldos Basicos.
		oProcess := MsNewProcess():New({|lEnd|	CTBA190(.T.,dIniRep,mv_par02,cFilAnt,cFilAnt,mv_par04,.T.,mv_par03) },"","",.F.)
		oProcess:Activate()
	EndIf
EndIf

cAliasSld := cEntidadeSld
If cEntidadeCTB $ "CTT,CTD,CTH"		// Utilizo saldo composto para apresentacao
	cAliasSld := "CQ9"
	cCampoChave := cEntidadeCtb + AllTrim(Left(cCampoChave, 7))
	cOrigem := cEntidadeCTB
Else
	cCampoChave := cEntidadeSld + AllTrim(Left(cCampoChave, 7))
Endif

lGrupo := cCampoChave == "CQ1_GRUPO"

If ! lCompara
	aCampos	:= CtbCHeader(cAliasSld, cCampoChave)
	If Select("TMP" + cEntidadeSld) == 0		// Caso nao esteja aberto, abro e crio arquivo
		// e aHeader Cria o arquivo temporario
			
		If _oCtbc0201 <> Nil
			_oCtbc0201:Delete()
			_oCtbc0201 := Nil
		Endif
		
		_oCtbc0201 := FWTemporaryTable():New( "TMP" + cEntidadeSld )  
		_oCtbc0201:SetFields(aCampos) 

		If lGrupo
			_oCtbc0201:AddIndex("1", {"CQ1_DATA"})
		Else
			_oCtbc0201:AddIndex("1", {aCampos[1][1]})		
		Endif
		
		//------------------
		//Criação da tabela temporaria
		//------------------
		_oCtbc0201:Create()  
		
	Else									// Senao limpo arquivo para geracao de novos
		DbSelectArea("TMP" + cEntidadeSld)	// Dados
		__DbZap()
	Endif
Endif

DbSelectArea(cAliasSld)
If cAliasSld = "CQ9" 		// Saldos compostos
	DbSetOrder(2)
Else
	DbSetOrder(nOrdemSal)
Endif

If lGrupo							// Agrupado por grupo contabil
	CT1->(DbSetOrder(4))			// CT1_GRUPO
	CT1->(MsSeek(xFilial("CT1") + cCpoChave))
	
	While 	Alltrim(CT1->CT1_GRUPO) = Alltrim(cCpoChave) .And. CT1->CT1_FILIAL = xFilial("CT1") .And. ! CT1->(Eof())
		If CT1->CT1_CLASSE = "2"
			Aadd(aContas, CT1->CT1_CONTA)
		Endif
		CT1->(DbSkip())
	EndDo
	
	CT1->(DbSetOrder(1))
	
	nConta		:= 2
	cCpoChave 	:= If(Len(aContas) > 0, aContas[1], cCpoChave)
	cCampoChave := "CQ1_CONTA"		// Busco os saldos no arquivo de saldos
Else
	If cAliasSld == "CQ9"
		cCpoChave := StrTran(cCpoChave, ".", "")         	// Tiro os pontos da mascara
		cCpoChave := Left(cCpoChave + Space(Len(&(cEntidadeCTB + "->" + cCampoChave))),;
			Len(&(cEntidadeCTB + "->" + cCampoChave)))
		cCampoChave := "CQ9_CODIGO"
	Else
		cCpoChave := StrTran(cCpoChave, ".", "")         	// Tiro os pontos da mascara
		cCpoChave := Left(cCpoChave + Space(Len(&(cCampoChave))), Len(&(cCampoChave)))
	Endif
Endif

If cAliasSld = "CQ9"		// Chave de busca diferenciada
	(cAliasSld)->(MsSeek(xFilial(cAliasSld) + cEntidadeCTB + mv_par03 + mv_par04 + cCpoChave + Dtos(mv_par01), .T.))
Else
	(cAliasSld)->(MsSeek(xFilial(cAliasSld) + cCpoChave + mv_par03 + mv_par04 + Dtos(mv_par01), .T.))
Endif

While 	.T.
	If cAliasSld = "CQ9" .And. CQ9_IDENT <> cEntidadeCTB
		Exit
	Endif
	If	! 	(&(cCampoChave) = cCpoChave 			.And.;
			&(cAliasSld + "_FILIAL") = xFilial()	.And.;
			&(cAliasSld + "_DATA") <= mv_par02 	.And.;
			&(cAliasSld + "_MOEDA") = mv_par03 	.And.;
			&(cAliasSld + "_TPSALD") = mv_par04 	.And. ! Eof())
		
		If lGrupo .And. nConta <= Len(aContas)
			cCpoChave := aContas[nConta]
			nConta ++
			MsSeek(xFilial() + cCpoChave + mv_par03 + mv_par04 + Dtos(mv_par01), .T.)
			lFirst := .T.	
			Loop
		Else
			Exit
		Endif
	Endif
	
	cContaSld 	:= Nil
	cCCusto 	:= Nil
	cItem 		:= Nil
	cClasse 	:= Nil
	cIdent 	:= Nil
	nDeb		:= 0
	nCred		:= 0
	
	If lFirst
		If cEntidadeCTB $ "CT1/CTR"
			cContaSld 	:= cCpoChave
		ElseIf  cEntidadeCTB == "CTT"
			cCCusto 	:= cCpoChave
		ElseIf  cEntidadeCTB == "CTD"
			cItem 		:= cCpoChave
		ElseIf  cEntidadeCTB == "CTH"
			cClasse 	:= cCpoChave
		EndIf
		cIdent		:= cEntidadeCTB
		dData		:= &(cAliasSld + "->" + cAliasSld + "_DATA")
		aSaldoAtu	:= SaldoCQ(cAliasSld,cContaSld,cCCusto,cItem,cClasse,cIdent,dData,mv_par03,mv_par04)
		nAntDeb	:= aSaldoAtu[7]
		nAntCrd	:= aSaldoAtu[8]
		lFirst		:= .F.
	EndIf

	
	If ! lCompara		
		DbSelectArea("TMP" + cEntidadeSld)
		
		If lGrupo
			dbSetOrder(1)
			If ! MsSeek(Dtos(&(cAliasSld + "->" + cAliasSld + "_DATA")))
				DbAppend()
			Endif
		Else
			DbAppend()
		Endif
		
		For nCampos := 1 To FCount()
			cSubCpo := SubStr( FieldName(nCampos),5 )
			If cSubCpo <> "SLDATU"	//	Se nao for o campo extra que nao existe no SX3, gravar o temporario a partir do arquivo de saldos
				
				If cSubCpo $ '_ANTDEB'
					&(FieldName(nCampos)) :=  nAntDeb
				ElseIf cSubCpo $ '_ANTCRD'
					&(FieldName(nCampos)) :=  nAntCrd
				ElseIf cSubCpo $ '_ATUCRD'
					nAtuCrd := nAntCrd + nCred
					&(FieldName(nCampos)) :=  nAtuCrd
					nAntCrd := nAtuCrd
				ElseIf cSubCpo $ '_ATUDEB'
					nAtuDeb := nAntDeb + nDeb
					&(FieldName(nCampos)) :=  nAtuDeb
					nAntDeb := nAtuDeb
				ElseIf cSubCpo $ '_DEBITO'
					nDeb := &(cAliasSld + "->" + FieldName(nCampos))
					&(FieldName(nCampos)) :=  nDeb
				ElseIf cSubCpo $ '_CREDIT'
					nCred := &(cAliasSld + "->" + FieldName(nCampos))
					&(FieldName(nCampos)) := nCred
				Else
					&(FieldName(nCampos)) :=  &(cAliasSld + "->" + FieldName(nCampos))
				EndIf
				
			Else
				// Buscando no cadastro da entidade contabil, sua Condicao Normal
				
				(cEntidadeCTB)->( DbSetOrder(1) )
				
				If cEntidadeCTB	== "CT1"
					CT1->( DbSeek( xFilial("CT1") + CQ1->CQ1_CONTA ) )
					cTipo	:= CT1->CT1_NORMAL
					cConta	:= CT1->CT1_CONTA
				ElseIf cAliasSLD 	== "CQ9"
					(cEntidadeCTB)->( DbSeek( xFilial(cEntidadeCTB) + CQ9->CQ9_CODIGO ) )
					cTipo 	:= (cEntidadeCTB)->&(cEntidadeCTB+"_NORMAL")
					cConta	:= ""
				EndIf
				
				cNomeCampo	:= FieldName(nCampos)
				cSaldo		:= AllTrim( ValorCTB( nAtuCrd-nAtuDeb,0,0,17, ,.T.,"",cTipo,cConta, .F., , , , ,.F.) )
				
				// Gravando o Saldo alinhando-o a direita
				If cPaisLoc == "RUS" 
					DbSelectArea("TMP" + cEntidadeSld)
				EndIf
				Replace &(cNomeCampo) With Space( Len(&(cNomeCampo)) - Len(AllTrim(cSaldo)) ) + AllTrim(cSaldo)
			EndIf
		Next
	Else
		nDeb	:= &(cAliasSld + "->"+cAliasSld+"_DEBITO")
		nCred	:= &(cAliasSld + "->"+cAliasSld+"_CREDIT")
		
		nAtuCrd := nAntCrd + nCred
		nAtuDeb := nAntDeb + nDeb
		
		nAntCrd := nAtuCrd
		nAntDeb := nAtuDeb
			
		If cFunName = "CTBC040" .And. (nSaldos := Ascan(aSaldos, { |X| 	X[1] = &(cAliasSld + "_DATA") .And. X[3] = ("CTR")->CTR_GRUPO })) == 0
			Aadd(aSaldos, { &(cAliasSld + "_DATA"), 	nAtuDeb - nAtuCrd ,("CTR")->CTR_GRUPO })
			
		ElseIf cFunName # "CTBC040" .And. (nSaldos := Ascan(aSaldos, { |X| 	X[1] = &(cAliasSld + "_DATA") })) = 0
			Aadd(aSaldos, { &(cAliasSld + "_DATA"), 	nAtuDeb - nAtuCrd , 0.00 })
		Else
			aSaldos[nSaldos][2] += 	nAtuDeb - nAtuCrd
		Endif
			
	Endif
	DbSelectArea(cAliasSld)
	DbSkip()
EndDo


If lCompara .And. cFunName # "CTBC040"
	lFirst 	:= .T.
	
	nConta		:= 2
	cCpoChave 	:= If(Len(aContas) > 0, aContas[1], cCpoChave)
	
	If cAliasSld = "CQ9"		// Chave de busca diferenciada
		MsSeek(xFilial() + cEntidadeCTB + mv_par03 + mv_par05 + cCpoChave + Dtos(mv_par01), .T.)
	Else
		MsSeek(xFilial(cEntidadeSld) + cCpoChave + mv_par03 + mv_par05 + Dtos(mv_par01), .T.)
	Endif
	
	While .T.
		If cAliasSld = "CQ9" .And. CQ9_IDENT <> cEntidadeCTB
			Exit
		Endif
		
		If	! 	(&(cCampoChave) = cCpoChave 			.And.;
				&(cAliasSld + "_FILIAL") = xFilial()	.And.;
				&(cAliasSld + "_DATA") <= mv_par02 	.And.;
				&(cAliasSld + "_MOEDA") = mv_par03 	.And.;
				&(cAliasSld + "_TPSALD") = mv_par05	.And. ! Eof())
			If lGrupo .And. nConta <= Len(aContas)
				cCpoChave := aContas[nConta]
				nConta ++
				MsSeek(xFilial(cAliasSld) + cCpoChave + mv_par03 + mv_par05 + Dtos(mv_par01), .T.)
				//MsSeek(cCpoFil + cCpoChave + mv_par03 + mv_par05 + Dtos(mv_par01), .T.)
				Loop
			Else
				Exit
			Endif
		Endif
		
		cContaSld 	:= Nil
		cCCusto 	:= Nil
		cItem 		:= Nil
		cClasse 	:= Nil
		cIdent 	:= Nil
		nDeb		:= 0
		nCred		:= 0
		
		If lFirst
			If cEntidadeCTB $ "CT1/CTR"
				cContaSld 	:= cCpoChave
			ElseIf  cEntidadeCTB == "CTT"
				cCCusto 	:= cCpoChave
			ElseIf  cEntidadeCTB == "CTD"
				cItem 		:= cCpoChave
			ElseIf  cEntidadeCTB == "CTH"
				cClasse 	:= cCpoChave
			EndIf
			cIdent		:= cEntidadeCTB
			dData		:= &(cAliasSld + "->" + cAliasSld + "_DATA")
			aSaldoAtu	:= SaldoCQ(cAliasSld,cContaSld,cCCusto,cItem,cClasse,cIdent,dData,mv_par03,mv_par05)
			nAntDeb	:= aSaldoAtu[7]
			nAntCrd	:= aSaldoAtu[8]
			lFirst		:= .F.
		EndIf
		
		nDeb	:= &(cAliasSld + "->"+cAliasSld+"_DEBITO")
		nCred	:= &(cAliasSld + "->"+cAliasSld+"_CREDIT")
		
		nAtuCrd := nAntCrd + nCred
		nAtuDeb := nAntDeb + nDeb
		
		nAntCrd := nAtuCrd
		nAntDeb := nAtuDeb
		
		
		If (nSaldos := Ascan(aSaldos, { |X| X[1] = &(cAliasSld + "_DATA") })) = 0
			Aadd(aSaldos, { &(cAliasSld + "_DATA"), 0.00,	nAtuDeb - nAtuCrd })
		Else
			aSaldos[nSaldos][3] += nAtuDeb - nAtuCrd
		Endif
		DbSelectArea(cAliasSld)
		DbSkip()
	EndDo
	
	If lOutRot .And. oGraphic # Nil
		oGraphic:Hide()
		oTpBase:Hide()
		oTpCompara:Hide()
		
		oBtnGrap:Disable()
		oBtnSav:Disable()
		oBtnPrn:Disable()
		oBtnMail:Disable()
	Endif
	
	If Len(aSaldos) = 0
		ApMsgAlert(STR0026) //"Nao ha valores a serem comparados !"
		Return .F.
	Endif
	
	ASort(aSaldos, , , { |x,y| y[1] > x[1] } )
	
	CTBC020Grap(cEntidadeSld, nFolder, aSaldos, cDescEnt, lOutRot, mv_pargf)
ElseIf cFunName # "CTBC040"
	CTBC020Browse(cEntidadeSld, nFolder)
Endif

cFilAnt  := cFilSal

Return aSaldos

//-------------------------------------------------------------------
/*{Protheus.doc} CTBc020CT2
Demonstra os lancamentos da data escolhida  

@author Alvaro Camillo Neto

@param oTree		Tree atual para obter valores do item selecionado     
@param nFolder	Folder atual                                       	 

   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ctbc020CT2(oTree, nFolder)

Local nCampos, cCpoChave, cCampo, dData, cCpoFil, cMod, cFilSal
Local cCargo 	:= (oTree:GetCargo())  
Local nTamFilial 	:= IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3( "CT2_FILIAL" )[1] )             
Local lLcto 	:= .F.
Local aCpoVer 	:= 	{ 	{ "CT2_DEBITO"	, "CT2_CREDIT" },;
				    		{ "CT2_CCD"   	, "CT2_CCC"     },;
				    		{ "CT2_ITEMD" 	, "CT2_ITEMC"   },;
							{ "CT2_CLVLDB"	, "CT2_CLVLCR"  };
						}
Local cFilCT2 := cFilAnt

If Left(cCargo, 3) $ "CQ3,CQ5,CQ7"		// Utilizo saldo composto para apresentacao
	cCampo := "CQ9_DATA"
Else
	cCampo := Left(cCargo, 3) + "_DATA"
Endif


cCampo  	:= "TMP" + Left(cCargo, 3) + "->" + cCampo // Nome do campo o temporario atual
cCampoChave := Right(cCargo, 9 + nTamFilial)		// Campo para chave para busca
cCpoFil		:= Left(Right(cCampoChave, 2 + nTamFilial),nTamFilial)
cCampoChave := Left(cCargo, 3) + AllTrim(Left(cCampoChave, 7))

cFilAnt 	:= cCpoFil
aCampos	  	:= CtbCHeader("CT2", "")
dData	    := &(cCampo)

If Select("TMPCT2") = 0			// Caso nao esteja aberto, abro e crio arquivo
								// aHeader Cria o arquivo temporario
	
	If _oCtbc0202 <> Nil
		_oCtbc0202:Delete()
		_oCtbc0202 := Nil
	Endif

	_oCtbc0202 := FWTemporaryTable():New( "TMPCT2" )  
	_oCtbc0202:SetFields(aCampos) 
	_oCtbc0202:AddIndex("1", {aCampos[1][1]})	
	
	//------------------
	//Criação da tabela temporaria
	//------------------
	_oCtbc0202:Create()  
						
Else								// Senao limpo arquivo para geracao de novos
	DbSelectArea("TMPCT2")			// Dados
	__DbZap()
Endif

cCpoChave := oTree:GetPrompt()							// Obtenho o item do tree atual
cCpoChave := Left(cCpoChave, At(" -", cCpoChave) - 1)	// Acho o codigo
cCpoChave := StrTran(cCpoChave, ".", "")         		// Tiro os pontos da mascara

DbSelectArea("CT2")
DbSetOrder(1)
MsSeek(xFilial() + Dtos(dData))

While CT2->CT2_DATA = &(cCampo) .And. 	CT2->CT2_FILIAL = xFilial() .And. ! Eof() 
	lLcto := .F.											
	If cCampoChave = "CQ1_GRUPO"
		If 	! Empty(CT2->CT2_DEBITO) 								.And.;
			CT1->(MsSeek(xFilial("CT1") + CT2->CT2_DEBITO)) 		.And.;
			CT1->CT1_GRUPO = cCpoChave
			lLcto := .T.
		Endif

		If 	! lLcto .And. ! Empty(CT2->CT2_CREDIT) 			.And.;
			CT1->(MsSeek(xFilial("CT1") + CT2->CT2_CREDIT))	.And.;
			CT1->CT1_GRUPO = cCpoChave
			lLcto := .T.
		Endif
	Else
		If (&(aCpoVer[nFolder][1]) = cCpoChave .Or.;
			&(aCpoVer[nFolder][2]) = cCpoChave)
			lLcto := .T.
		Endif
	Endif
											
	If 	CT2_MOEDLC = mv_par03 .And. CT2_TPSALD = mv_par04 .And. lLcto
		DbSelectArea("TMPCT2")
		DbAppend()
		For nCampos := 1 To FCount()
			Replace &(FieldName(nCampos)) With &("CT2->" + FieldName(nCampos))
		Next		
	Endif
	DbSelectArea("CT2")
	DbSkip()
EndDo

CTBC020Browse("CT2", nFolder,, oTree)

cFilAnt := cFilCT2
Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} CTBc020Browse
Monta BROWSE padrao da consulta com TREE  

@author Alvaro Camillo Neto
                                  	 
@param cAlias		Alias atual usado no BROWSE                          
@param nFolder	Folder atual                                       	
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ctbc020Browse(cAlias, nFolder, dData, oTree)
Local cAliasTMP:="TMP"+cAlias 
DbSelectArea(cAliasTMP)
DbGoTop()
If RecCount() <= 0
	MsgAlert(STR0008 + If(dData # Nil, " - " + Dtoc(dData), ""), STR0009)
   //	Return .F.
Endif

oGetDB := MSGetDB():New(3, 172,(aPosObj[1,3]-32) , aPosObj[1][4] - 5, 1,;
				 		 ".T.", ".T.",,,,,.T.,,;
				 		 cAliasTMP,,,, oFolder:aDialogs[nFolder])
 
oGetDB:oBrowse:blDblClick := {|| TransCQ1(nFolder)}  // Incluido Duplo Clique para acionar o Rastreamento
oGetDb:ForceRefresh()

Return //.T.

//-------------------------------------------------------------------
/*{Protheus.doc} Ctbc020Bar
ToolBar especifica da rotina de CONSULTA com PARAMETROS 

@author Alvaro Camillo Neto
                                  	 
@param oDlg		Objeto dialog atual                                                                  	
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ctbc020Bar(oDlg,lPerBar,nFolder,oTree)

Local aButtons := {}
Local oBtn1
Local oBtn2

AADD(aButtons, {"S4WB016N"		, {|| HelProg()}, STR0016}) //"Ajuda"
AADD(aButtons, {"SDUPROP"		, {|| If(Sx1C020(),(lPerBar := .T.,oDlg:End()),lPerBar := .F.)}, STR0017}) //"Parametros
AADD(aButtons, {"DOCORI"		, {|| TransCQ1(nFolder),},STR0086}) //"Detalhes"	
EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,aButtons,,,,,.F.)

Return 

//-------------------------------------------------------------------
/*{Protheus.doc} Ctbc020Grap
Monta grafico de comparacao previsto X Realizado 

@author Alvaro Camillo Neto
                                  	 
@param cEntidadeSld	Alias atual usado no BROWSE                            
@param nFolder   		Folder atual                                       	  
@param aSaldos   		Matriz com o saldo base/comparativo                	  
@param cDescEnt   	Nome da entidade sendo visualizada                	  
@param lOutRot   		Indica se eh chamada da rotina CTBC030                 
@param nCbx   		Numero do tipo de grafico a ser utilizado              
@param cTitDlg		Titulo do grafico sendo visualizado               	  
@param lLegGrp		Indica se usara legenda diretamente do grafico         
@param oDlg   		Objeto onde o grafico sera criado                      
@param nTop   		Posicao inicial do grafico                             
@param nLeft   		Posicao inicial a esquerda onde o grafico sera criado  

@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function Ctbc020Grap(cEntidadeSld, nFolder, aSaldos, cDescEnt, lOutRot, nCbx, cTitDlg,lLegGrp, oDlg, nTop, nLeft, nBottom, nRight)

Local oBmp
Local oBold
Local cMoeda	:= CtbMoeda(mv_par03)[3]
Local aCbx 		:= { STR0031, STR0032, STR0033, STR0034, STR0035, STR0036,; //"Linha"###"Area"###"Pontos"###"Barras"###"Piramide"###"Cilindro"
STR0037, STR0038, STR0039,; //"Barras Horizontal"###"Piramide Horizontal"###"Cilindro Horizontal"
STR0040, STR0041, STR0042, STR0043, STR0044, STR0045 } //"Pizza"###"Forma"###"Linha rapida"###"Flexas"###"GANTT"###"Bolha"
Local oSer, nSer, nQtdSer

Local cCbx 			:= aCbx[nCbx]
Local nAntBase, nAntComp, aSaldosM
Local aSerie 		:= {}, oMenu, aArray := Aclone(aSaldos)
Local nSerie2		:= 0
Local lSerMul		:= Len(aSaldos) > 0 .And. ValType(aSaldos[1][3]) = "C"
Local aCorSer		:= { 	CLR_HBLUE, CLR_HRED, CLR_HGREEN, CLR_YELLOW, CLR_BLACK,;
	CLR_WHITE, CLR_GRAY, CLR_HCYAN, CLR_HMAGENTA }, nCorSer := 1

LOCAL lNovaDlg := .T.
Local cPictVal  := PesqPict("CT2","CT2_VALOR")
Local lSayGrupo := GetNewPar("MV_CTBNATC","1")=="1"

DEFAULT oDlg		:= If(lOutRot, oFolder:aDialogs[nFolder],)
DEFAULT nTop		:= 6
DEFAULT nLeft		:= 155
DEFAULT nBottom		:= aPosObj[1][4]-155
DEFAULT nRight 		:= aPosObj[1,3]-35
DEFAULT lLegGrp   	:= .F.
DEFAULT cTitDlg 	:= STR0027 + STR0046 + AllTrim(cDescEnt) + ' - ' +;
	cTpBase + " X " + cTpCompara //" - Entidade "

nSerie 	:= 0
cTitulo	:= cTitDlg

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

While lNovaDlg
	lNovaDlg 		:= .F.
	
	cMoeda			:= CtbMoeda(mv_par03)[3]
	aCbx 			:= { STR0031, STR0032, STR0033, STR0034, STR0035, STR0036,; //"Linha"###"Area"###"Pontos"###"Barras"###"Piramide"###"Cilindro"
	STR0037, STR0038, STR0039,; //"Barras Horizontal"###"Piramide Horizontal"###"Cilindro Horizontal"
	STR0040, STR0041, STR0042, STR0043, STR0044, STR0045 } //"Pizza"###"Forma"###"Linha rapida"###"Flexas"###"GANTT"###"Bolha"
	nSer			:= 0
	nQtdSer		:= 0
	
	cCbx 			:= aCbx[nCbx]
	nAntBase		:= 0
	nAntComp		:= 0
	aSaldosM		:= {}
	aSerie 		:= {}
	aArray 		:= Aclone(aSaldos)
	nSerie2		:= 0
	lSerMul		:= Len(aSaldos) > 0 .And. ValType(aSaldos[1][3]) = "C"
	aCorSer		:= { 	CLR_HBLUE, CLR_HRED, CLR_HGREEN, CLR_YELLOW, CLR_BLACK,	CLR_WHITE, CLR_GRAY, CLR_HCYAN, CLR_HMAGENTA }
	nCorSer 		:= 1
	
	
	If ! lOutRot
		DEFINE MSDIALOG oDlg FROM 0,0 TO 450,700 PIXEL TITLE STR0027 //"Comparacao entre saldos"
		
		// Layout da janela
		@ 000, 000 BITMAP oBmp RESNAME "ProjetoAP" oF oDlg SIZE 50, 250 NOBORDER WHEN .F. PIXEL
		@ 003, 060 SAY " - "+STR0064 + AllTrim(cDescEnt) + ' - ' + cTpBase + " X " +; //"Entidade "
		cTpCompara FONT oBold PIXEL
		
		@ 014, 050 TO 16 ,400 LABEL '' OF oDlg  PIXEL
		
		@ 020, 055 MSGRAPHIC oGraphic SIZE 285, 158 OF oDlg PIXEL
		If ! lSerMul
			@ 185, 57 SAY cTpBase 		OF oDlg COLOR CLR_HBLUE FONT oBold PIXEL
			@ 195, 57 SAY cTpCompara 	OF oDlg COLOR CLR_HRED  FONT oBold PIXEL
		Endif
	Else
		@ nTop, nLeft MSGRAPHIC oGraphic SIZE nBottom,nRight OF oDlg PIXEL
		
		If ! lLegGrp
			@ aPosObj[1,3]-25, 155 	SAY oTpBase Var cTpBase OF oDlg;
				COLOR CLR_HBLUE FONT oBold PIXEL
			@ aPosObj[1,3]-25, aPosObj[1][4]-(Len(cTpCompara)	* 5) SAY oTpCompara;
				Var cTpCompara OF oDlg COLOR CLR_HRED;
				FONT oBold PIXEL
		Endif
		
		If lOutRot
			oBtnGrap:Enable()
			oBtnSav:Enable()
			oBtnPrn:Enable()
			oBtnMail:Enable()
		Endif
	Endif
	
	oGraphic:SetMargins( 2, 8, 8, 8 )
	
	oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGraphic:SetTitle( cMoeda, "", CLR_HRED , A_LEFTJUST , GRP_TITLE )
	oGraphic:SetTitle( STR0029 + cTpBase + " X " + cTpCompara, "", CLR_GREEN, A_RIGHTJUS , GRP_FOOT  ) //"Comparacao "
	
	oGraphic:SetLegenProp( GRP_SCRTOP, CLR_YELLOW, If(lLegGrp, GRP_AUTO, GRPLASTVAL),;
		lSerMul)
	
	If lSerMul
		aSaldosM := { {STR0047,STR0065, If(lSayGrupo,STR0066,STR0076)} } //"Data de Referencia" //"Saldo"###"Grupo"
	Else
		nSerie   := oGraphic:CreateSerie(nCbx)
		nSerie2  := oGraphic:CreateSerie(nCbx)
		aSaldosM := { {STR0047,cTpBase,cTpCompara} } //"Data de Referencia"
	Endif
	For nSer := 1 To Len(aArray)
		Aadd(aSaldosM, aArray[nSer])
	Next
	
	If nSerie != GRP_CREATE_ERR .And. nSerie2 != GRP_CREATE_ERR
		nAntBase    := nAntComp := 0
		For nSer := 2 To Len(aSaldosM)
			If aSaldosM[nSer][2] = 0
				aSaldosM[nSer][2] := nAntBase
			Endif
			nAntBase := If(aSaldosM[nSer][2] = 0, nAntBase, aSaldosM[nSer][2])
			
			If ! lSerMul
				If aSaldosM[nSer][3] = 0
					aSaldosM[nSer][3] := nAntComp
				Endif
				nAntComp := If(aSaldosM[nSer][3] = 0, nAntComp, aSaldosM[nSer][3])
				Aadd(aSerie, { aSaldosM[nSer][2], aSaldosM[nSer][3] })
			Else
				If (nSerie := Ascan(aSerie, { |x| x[1][1] = aSaldosM[nSer][3] })) = 0
					Aadd(aSerie, { { aSaldosM[nSer][3] } })
					nSerie := Len(aSerie)
				Endif
				Aadd(aSerie[nSerie], { aSaldosM[nSer][1], aSaldosM[nSer][2] })
			Endif
			
			aSaldosM[nSer][1] := Dtoc(aSaldosM[nSer][1])
			aSaldosM[nSer][2] := Trans(aSaldosM[nSer][2], cPictVal)
			
			If ! lSerMul
				aSaldosM[nSer][3] := Trans(aSaldosM[nSer][3], cPictVal)
			Else
				DbSelectArea("CTR")
				MsSeek(xFilial("CTR") + aSaldosM[nSer][3])
				aSaldosM[nSer][3] := CTR_DESC
			Endif
		Next
		
		For nSer := 1 To Len(aSerie)
			If ! lSerMul
				oGraphic:Add(nSerie, aSerie[nSer][1], aSaldosM[nSer + 1][1],CLR_BLUE)
				oGraphic:Add(nSerie2, aSerie[nSer][2], aSaldosM[nSer + 1][1],CLR_HRED)
			Else
				oGraphic:CreateSerie(nCbx)
				For nQtdSer := 2 To Len(aSerie[nSer])
					oGraphic:Add(	nSer, aSerie[nSer][nQtdSer][2],;
						Dtoc(aSerie[nSer][nQtdSer][1]), aCorSer[nCorSer])
				Next
				nCorSer ++
				If nCorSer > Len(aCorSer)
					nCorSer := 1
				Endif
			Endif
		Next
	Else
		ApMsgAlert(STR0028) //"Não foi possível criar a série."
	Endif
	oGraphic:bRClicked := {|o,x,y| oMenu:Activate(x,y,oGraphic) } // Posição x,y em relação a Dialog
	MENU oMenu POPUP
	MENUITEM STR0048 Action ConsDadGraf(aSaldosM)	//"Consulta dados do grafico"
	ENDMENU

	If ! lOutRot
		@ 180, 095 	SAY STR0049	OF oDlg FONT oBold PIXEL //"Tipo de grafico"
		@ 192, 095 	MSCOMBOBOX oSer VAR cCbx ITEMS aCbx SIZE 077, 120 OF oDlg;
			PIXEL ON CHANGE	(nCbx := oSer:nAt, oDlg:End(), lNovaDlg := .T.)
		@ 190, 174 	BUTTON STR0050 SIZE 40,14 OF oDlg PIXEL ACTION Ctb020Graph(oGraphic, "ROTACAO-", nSerie) //"Rotacao &-"
		@ 190, 216 	BUTTON STR0051 SIZE 40,14 OF oDlg PIXEL ACTION Ctb020Graph(oGraphic, "ROTACAO+", nSerie) //"Rotacao &+"
		@ 190, 258 	BUTTON o3D PROMPT "2D" SIZE 40,14 OF oDlg PIXEL ACTION Ctb020Graph(oGraphic, "EFEITO", o3D)
		@ 190, 301 	BUTTON STR0052 SIZE 40,14 OF oDlg PIXEL ACTION GrafSavBmp( oGraphic ) //"&Salva BMP"
		
		@ 207, 050 	TO 209 ,400 LABEL '' OF oDlg  PIXEL
		@ 213, 216 	BUTTON STR0053 SIZE 40,12 OF oDlg PIXEL ACTION CtbGrafPrint(oGraphic,STR0054,{cTitulo},aSaldosM, .F.) //"&Imprimir"###"Comparacao de saldos"
		@ 213, 258 	BUTTON STR0055 SIZE 40,12 OF oDlg PIXEL ACTION PmsGrafMail(oGraphic,cTitulo,{cTitulo },aSaldosM) //"&E-mail"
		@ 213, 301 	BUTTON STR0056 SIZE 40,12 OF oDlg PIXEL ACTION oDlg:End() //"&Sair"
		ACTIVATE MSDIALOG oDlg CENTER
	Else	// Variaveis privates para CTBC030
		aSaldosMP := Aclone(aSaldosM)
	Endif

EndDo


Return

//-------------------------------------------------------------------
/*{Protheus.doc} Ctb020Graph
Executa operacoes no grafico dependendo do parametro  

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ctb020Graph(oGraphic, cAcao, uParam1, uParam2, uParam3)

If oGraphic # Nil
	If cAcao = STR0087 //"EFEITO"
		oGraphic:l3D := !oGraphic:l3D
		If uParam2 = Nil
			uParam1:cCaption := If(oGraphic:l3D, "2D", "3D")
		Else
			If oGraphic:l3D
				uParam1:Show()
				uParam2:Hide()
			Else
				uParam2:Show()
				uParam1:Hide()
			Endif
		Endif
	ElseIf cAcao = STR0088+"+" .And. oGraphic:l3D //"ROTACAO"
		oGraphic:ChgRotat( uParam1, 1, .F. ) // nRotation tem que estar entre 1 e 30 passos
		If .F. // uParam2 # Nil
			If oGraphic:nRotation = 30
				uParam2:Disabled()
			Else
				uParam2:Enabled()
			Endif
		Endif
	ElseIf cAcao = "ROTACAO-" .And. oGraphic:l3D //"ROTACAO"
		oGraphic:ChgRotat( uParam1, 1, .T. ) // nRotation tem que estar entre 1 e 30 passos
		If .F. // uParam3 # Nil
			If oGraphic:nRotation = 1
				uParam3:Disabled()
			Else
				uParam3:Enabled()
			Endif
		Endif
	Endif
Endif


Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} Sx1C020
Executa confirmacao das perguntas das rotinas e ajusta SX1 

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Sx1C020(lPergunta)

Local cPerg 	:= "CTC020"
Local lRet 		:= .T.
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea()) 

DEFAULT lPergunta := .T.

If ! Pergunte(cPerg, lPergunta) .And. lPergunta
	lRet := .F.
Endif

If lRet
	cTpBase	 	:= AllTrim(Tabela("SL", mv_par04,.F.))
	cTpCompara 	:= AllTrim(Tabela("SL", mv_par05,.F.))				
EndIf	

If lRet .And. lPergunta
	If MV_PAR14 == 1 
		aSelFil := AdmGetFil()
		If Empty(aSelFil)
			lRet := .F.
		EndIf
	Else
		aSelFil := {cFilAnt}
	Endif
EndIf   	

mv_par04 	:= mv_par04
mv_par05 	:= mv_par05
mv_pargf 	:= 1

IF lRet .And. EMPTY( MV_PAR03 )
	ApMsgAlert( STR0075 ) // "Informe a moeda!"
	lRet := .F.
ENDIF

IF lRet .And. EMPTY( MV_PAR04 )
	ApMsgAlert( STR0076 ) // "Informe o tipo de saldo!"
	lRet := .F.
ENDIF 
    
RestArea(aAreaSM0)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} Ctc020CtlMnu
Retorna String com a data atual para consulta dos lancamentos

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ctc020CtlMnu(oTree, oMenu)

Local cPopMenu := STR0006, lAtivo, cCargo := oTree:GetCargo()

If Left(cCargo, 3) $ "CQ3,CQ5,CQ7"		// Utilizo saldo composto para apresentacao
	cCampo := "CQ9_DATA"
Else
	cCampo := Left(cCargo, 3) + "_DATA"
Endif
	
If lAtivo := ((Len(AllTrim(cCargo))) > 3)
	cPopMenu += " - " + Dtoc(&("TMP" + 	Left(cCargo, 3) + "->" + cCampo))
Endif

oMenu:aItems[1]:cCaption 	:= cPopMenu
If lAtivo
	oMenu:aItems[1]:Enable()
	oMenu:aItems[2]:Enable()
	oMenu:aItems[4]:Enable()
Else
	oMenu:aItems[1]:Disable()
	oMenu:aItems[2]:Disable()
	oMenu:aItems[4]:Disable()
Endif

Return

//-------------------------------------------------------------------
/*{Protheus.doc} Ctc020VarSup
Varre os niveis superiores a partir da entidade passada 

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ctc020VarSup(oTree, cConta, cMascara, nTamanho, nTamMasc, cEntidadeSld, nIndex)

Local bPrompt 	:= 	{ || AllTrim(MascaraCTB(CT1->CT1_CONTA, cMascara,nTamMasc, "")) +;
	" - " + If(Empty(	&("CT1->CT1_DESC" + mv_par03)), CT1->CT1_DESC01,;
	&("CT1->CT1_DESC" + mv_par03)) }

Local bAvalia	:= { || 	CT1_FILIAL = xFilial() .And. CT1_CTASUP = cConta .And. CT1_CONTA <= mv_par07 .And. ! Eof() }
Local bCampo	:= { || CT1->CT1_CONTA }
Local aAreaEnt	:= GetArea()
Local lTipoTree	:= .F., cAlias := Alias(), cCampo := "_CONTA"
Local nTamFilial 	:= IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3( "CT2_FILIAL" )[1] )

DEFAULT nIndex 	:= 5

If cAlias <> "CT1"
	Do Case
	Case cAlias == 'CTT'
		bPrompt := 	{ || AllTrim(MascaraCTB(CTT->CTT_CUSTO, cMascara,nTamMasc, "")) +;
			" - " + If(Empty(	&("CTT->CTT_DESC" + mv_par03)), CTT->CTT_DESC01,;
			&("CTT->CTT_DESC" + mv_par03)) }
		bAvalia	:= { || CTT_FILIAL = xFilial() .And. CTT_CCSUP = cConta .And. ! Eof() }
		bCampo	:= { || CTT->CTT_CUSTO }
		cCampo 	:= "_CUSTO"
	Case cAlias	== 'CTD'
		bPrompt := 	{ || AllTrim(MascaraCTB(CTD->CTD_ITEM, cMascara,nTamMasc, "")) +;
			" - " + If(Empty(	&("CTD->CTD_DESC" + mv_par03)), CTD->CTD_DESC01,;
			&("CTD->CTD_DESC" + mv_par03)) }
		bAvalia	:= { || CTD_FILIAL = xFilial() .And. CTD_ITSUP = cConta .And. ! Eof() }
		bCampo	:= { || CTD->CTD_ITEM }
		cCampo 	:= "_ITEM "
	Case cAlias = 'CTH'
		bPrompt := 	{ || AllTrim(MascaraCTB(CTH->CTH_CLVL, cMascara,nTamMasc, "")) +;
			" - " + If(Empty(	&("CTH->CTH_DESC" + mv_par03)), CTH->CTH_DESC01,;
			&("CTH->CTH_DESC" + mv_par03)) }
		bAvalia	:= { || CTH_FILIAL = xFilial() .And. CTH_CLSUP = cConta .And. ! Eof() }
		bCampo	:= { || CTH->CTH_CLVL }
		cCampo 	:= "_CLVL "
	EndCase
Endif

DbSetOrder(nIndex)
MsSeek(xFilial() + cConta)

While Eval(bAvalia)
	
	aAuxArea := GetArea()
	RestArea(aAreaENT)
	
	If ! lTipoTree
		DBADDTREE oTree PROMPT Eval(bPrompt);	// Adiciono como nivel
		RESOURCE "BMPTABLE" CARGO cEntidadeSld + Space(21 + nTamFilial)
		
		lTipoTree := .T.
	Endif
	RestArea(aAuxArea)
	Ctc020VarSup(oTree, Eval(bCampo), cMascara, nTamanho, nTamMasc, cEntidadeSld, nIndex)
	DbSkip()
	
EndDo

If (lTipoTree .And. If(cAlias = "CT1", Eval(bCampo) <= mv_par07, .T.)) .Or. ! lTipoTree
	RestArea(aAreaENT)
Endif

If lTipoTree
	DBENDTREE oTree
Else
	DO CASE
	CASE cAlias == "CT1"															//// SE FOR PLANO DE CONTAS
		If CT1->CT1_CONTA >= mv_par06 .and. CT1->CT1_CONTA <= mv_par07			//// SO ADICIONA ANALITICA SE ESTIVER NO INTERVALO
			DBADDITEM oTree PROMPT Eval(bPrompt) RESOURCE "BMPTRG" CARGO cEntidadeSld+StrZero(RecNo(),12) + cCampo + " " + cFilAnt + " 2"
		Endif
	CASE cAlias == "CTT"
		If CTT->CTT_CUSTO >= mv_par08 .and. CTT->CTT_CUSTO <= mv_par09
			DBADDITEM oTree PROMPT Eval(bPrompt) RESOURCE "BMPTRG" CARGO cEntidadeSld+StrZero(RecNo(),12) + cCampo + " " + cFilAnt + " 2"
		Endif
	CASE cAlias == "CTD"
		If CTD->CTD_ITEM >= mv_par10 .and. CTD->CTD_ITEM <= mv_par11
			DBADDITEM oTree PROMPT Eval(bPrompt) RESOURCE "BMPTRG" CARGO cEntidadeSld+StrZero(RecNo(),12) + cCampo + " " + cFilAnt + " 2"
		Endif
	CASE cAlias == "CTH"
		If CTH->CTH_CLVL >= mv_par12 .and. CTH->CTH_CLVL <= mv_par13
			DBADDITEM oTree PROMPT Eval(bPrompt) RESOURCE "BMPTRG" CARGO cEntidadeSld+StrZero(RecNo(),12) + cCampo + " " + cFilAnt + " 2"
		Endif
	ENDCASE
Endif
                                          

Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} Ctbc020Cor
Demonstra os lancamentos correlativos no periodo selecionado

@author Alvaro Camillo Neto

@param cRotina  	Cargo do objeto tree                           
@param oGetCorr  	Objeto do tipo MSGETDB para atualizacao        

@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ctbc020Cor(cRotina,oGetCorr)

Local cCT2Rotina 	:= ""
Local nCampos

DbSelectArea("TMPCT2COR")
__DbZap()

DbSelectArea("CT2")
DbSetOrder(1)

DbSeek(xFilial() + dToS(mv_par01),.T.)

While xFilial("CT2") = CT2_FILIAL .And. CT2_DATA <= mv_par02 .And. ! Eof()
	cCT2Rotina := Upper(Trim(CT2_ROTINA))
	If (cRotina == STR0089 .And. cCT2Rotina <> "CTBA102"	.And. cCT2Rotina <> "CTBA101") .Or.;
			(cCT2Rotina == cRotina .Or. cRotina == "ALL_LANCAM") //"INTEGRA"
			DbSelectArea("TMPCT2COR")
			DbAppend()
			For nCampos := 1 To FCount()
				Replace &(FieldName(nCampos)) With &("CT2->" + FieldName(nCampos))
			Next		
			DbSelectArea("CT2")
  	EndIf
	DbSkip()
EndDo

DbSelectArea("TMPCT2COR" )

If Eof()
	DbAppend()
EndIf

Eval(oGetCorr:oBrowse:bGotop)
oGetCorr:ForceRefresh()

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} CtcCorrMnu
Pesquisa um lancamento correlativo no arquivo de movimentos contabil (CT2)

@author Alvaro Camillo Neto

@param oGetCorr  	Objeto do tipo MSGETDB para atualizacao                          
       

@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CtcCorrMnu(oGetCorr)

Local nOpca 	:= 0
Local cDesCorr :=  Rtrim(RetTitle("CT2_SEGOFI"))
Local cDesLote :=  Rtrim(RetTitle("CT2_SBLOTE"))
Local oGetCor  ,cCorr := Spac(TamSx3("CT2_SEGOFI")[1])
Local oGetSub	,cSub  := Spac(TamSx3("CT2_SBLOTE")[1])
Local oDlg		
Local oLinha

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0067) FROM 9,0 TO 16,30 

	@ 005,015 Say OemToAnsi( cDesCorr ) OF oDlg PIXEL
	@ 015,015 MSGET oGetCor VAR cCorr SIZE 040,08 OF oDlg PIXEL

	@ 005,075 Say OemToAnsi( cDesLote )OF oDlg PIXEL
	@ 015,075 MSGET oGetSub  VAR cSub  SIZE 030,08 OF oDlg PIXEL
	oLinha := TGroup():New(33,1,34,119,'',oDlg,,,.T.)

	DEFINE SBUTTON FROM 039, 060 TYPE 1 ACTION (nOpca:=1,oDlg:End()) ENABLE Of oDlg
	DEFINE SBUTTON FROM 039, 090 TYPE 2 ACTION oDlg:End() 				ENABLE Of oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1  .And. Select("TMPCT2COR") != 0
	DbSelectArea("TMPCT2COR")
	DbSetOrder(1)       
	If ! DbSeek(xFilial("CT2")+Trim(cCorr+cSub))
		MsgAlert(STR0068)	
		Eval(oGetCorr:oBrowse:bGotop)
	EndIf
	oGetCorr:ForceRefresh()
EndIf

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} ctcMosDoc
Mostra o documento que     que originou o lancamento contabil tento como base o numero correlativo + sub-lote.   

@author Alvaro Camillo Neto

@param oGetCorr  	Objeto do tipo MSGETDB para atualizacao                          
       

@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function ctcMosDoc()

Local aArea			:= GetArea()

Local cChave 			:=  ""
Local oBackoFolder
Private __lCusto		:= .F.
Private __lItem		:= .F.
Private __lCLVL		:= .F.
Private cCadastro 	:= ""
Private cSeqCorr  	:= ""
Private aTotRdpe  	:= {{0,0,0,0},{0,0,0,0}}

DbSelectArea("TMPCT2COR")
cChave 	:= CT2_FILIAL+ DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC

CT2->(dbSetOrder(1))

If CT2->(dbSeek(cChave))
	cSeqCorr := CT2_SEGOFI
	If Trim(CT2_ROTINA)  == "CTBA101"
		oBackoFolder := oFolder
		Ctba101Lan("CT2",CT2->(Recno()),2,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,0,CT2_LP,"",,,CT2_VALOR)		
	   oFolder 	:= oBackoFolder
	Else
		aAreaOri := GetArea()
		dbSelectArea("CTF")
		dbSetOrder(1)
		If MsSeek(xFilial("CTF")+DTOS(CT2->(CT2_DATA))+CT2->(CT2_LOTE)+CT2->(CT2_SBLOTE)+CT2->(CT2_DOC),.F.)
			CTF_LOCK := Recno()
			RecLock("CTF",.F.)
		EndIf
		RestArea(aAreaOri)
		Ctba102Lan(2,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,"CT2",CT2->(Recno()),CTF_LOCK,CT2_VALOR)
	EndIf
EndIf

RestArea(aArea)

Return .T. 


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author wilson.possani

@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel      := Nil
Local cAliasTMP   := ""

Local oStr1 := Nil
Local oStr3 := Nil
Local oStr4 := Nil

// inicia o modelo
oModel := MPFormModel():New('CTBC020')
oModel:SetDescription(STR0090)  //"Detalhes das Contas"

// se nao tiver o aTrees retorna modelo (rotina CFGA530)
If Type("aTrees") == "U"
	Return oModel
EndIf

cAliasTMP := "TMP"+aTrees[oFolder:NOPTION][2]

oStr1:= MontaSCab(cAliasTMP)
oStr3:= FWFormStruct(1,'CT2',{ |cCpo| CT2->(FieldPos(ALLTRIM(cCpo))) > 0 })
oStr4:= FWFormStruct(1,'CV3',{ |cCpo| CV3->(FieldPos(ALLTRIM(cCpo))) > 0 })

oStr3:AddField('R_E_C_N_O_',"Recno CT2" , 'R_E_C_N_O_', 'C',17 )

oModel:addFields('SDOCQ1',,oStr1,,,{|oModel|CargaCQ1(oModel,oFolder)},,)
oModel:addGrid('LCTCT2','SDOCQ1',oStr3,,,,,{|oModel| CargaCT2(oModel) }) 
oModel:addGrid('RASTCV3','LCTCT2',oStr4)

oModel:SetPrimaryKey(  { "'"+cAliasTMP+"'"+'->CQ1_FILIAL', "'"+cAliasTMP+"'"+'->CQ1_DATA'  }) 
oModel:SetRelation('RASTCV3', { { "CV3_FILIAL" , "CT2_FILIAL" }, {"CV3_RECDES","R_E_C_N_O_"} }, CV3->(IndexKey(2)) )

oModel:getModel('SDOCQ1'):SetDescription(STR0091) //"Saldos"
oModel:getModel('LCTCT2'):SetDescription(STR0092) //"Lançamentos"
oModel:getModel('RASTCV3'):SetDescription(STR0093) //"Documentos de Origem"

oModel:Activate()

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author wilson.possani

@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
 
Local oStr1:= MontaVCab() 
Local oStr3:= FWFormStruct(2, 'CT2',{ |cCpo| CT2->(FieldPos(ALLTRIM(cCpo))) > 0 })
Local oStr4:= FWFormStruct(2, 'CV3',{ |cCpo| CV3->(FieldPos(ALLTRIM(cCpo))) > 0 }) 
Local nRecDes:= 0     
Local nRecOri:= 0
Local cTabOri:= ""
Local coView := ""
Local oStr2:= Nil
Local oStr5:= Nil
Local oStr6:= Nil
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'CTBC020' )
Local oView

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('SDOCQ1V' , oStr1,'SDOCQ1' )
oView:AddGrid('LCTCT2V'  , oStr3,'LCTCT2')
oView:AddGrid('RASTCV3V' , oStr4,'RASTCV3')  
  
coView := oView:AVIEWS[3][1]
oView:AddUserButton( STR0106, 'FORM', {|oView| ConsORI(coView,oModel) } ) //Rastrear

oView:CreateHorizontalBox( 'BOXFORM1', 25)
oView:CreateHorizontalBox( 'BOXFORM3', 40)
oView:CreateHorizontalBox( 'BOXFORM5', 35)
                   
oView:SetOwnerView('SDOCQ1V','BOXFORM1')
oView:SetOwnerView('LCTCT2V','BOXFORM3')
oView:SetOwnerView('RASTCV3V','BOXFORM5')

oView:EnableTitleView('SDOCQ1V' , STR0103 )				//'Saldos'
oView:EnableTitleView('LCTCT2V' , STR0104 )			//'Lançamentos'
oView:EnableTitleView('RASTCV3V' , STR0105 )	//'Documentos de Orige'

oView:SetViewProperty('LCTCT2V' , 'GRIDVSCROLL', {.F.}  )
oView:SetViewProperty('RASTCV3V' , 'GRIDVSCROLL',  {.F.}  )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} TransCQ1()
Rotina que chama a nova tela

@author wilson.possani

@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TransCQ1(nFolder)
	Local oSavObj	:= oFolder          
	Local aEntidade	:= aClone(aTrees)
	Local aArea		:= GetArea()
	Local aPosOb	:= aClone(aPosObj)
	Local cArqTmp	:= ""
	
	cArqTmp = "TMP" + aTrees[oFolder:nOption,2]
	If Select(cArqTmp) > 0 .And. (cArqTmp)->(RecCount()) > 0
		FWExecView(STR0094,"CTBC020",3,, { || .T. } )
		RestArea(aArea)
		aPosObj := aClone(aPosOb)
		oFolder:= oSavObj
		oFolder:nOption := nFolder
		oFolder:Refresh()
	Endif
Return .T.                             

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaSCab()
Retorna estrutura do tipo FWformModelStruct.

@author wilson.possani

@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static function MontaSCab(cAliasTMP)
   	Local oStruct := FWFormStruct( 1,cAliasTMP, /*bAvalCampo*/, /*lViewUsado*/ )

	oStruct:AddTable('SDOCTB',{'FILIAL', 'CODIGO', 'DATA', 'CREDITO', 'DEBITO', 'RECTMP' },STR0097)//'Saldo da Conta' 
	oStruct:AddField(STR0082,STR0082 , 'FILIAL', 'C',TamSx3("CT2_FILIAL")[1],,,,,,,.T. )     // COLOCAR STR WILSON  # "Filial"
	oStruct:AddField(STR0064,STR0064 , 'ENTIDADE', 'C',10,,,,,,,.T. ) // "Entidade"
	oStruct:AddField(STR0095,STR0095 +" "+ STR0096 , 'CODIGO', 'C',TamSx3("CT2_DEBITO")[1],,,,,,,.T.,.F.) //"Conta"#"Conta Contabil"
	oStruct:AddField(STR0098,STR0098 , 'DESCCONT', 'C',20,,,,,,,.T. )	//"Descrição"
	oStruct:AddField(STR0099,STR0099 , 'DATALANC', 'D',8 ) //"Data"
	oStruct:AddField(STR0100,STR0100 , 'CREDITO', 'N',16,2 ) //"Saldo Credito"
	oStruct:AddField(STR0101,STR0101 , 'DEBITO', 'N',16,2 ) // "Saldo Debito"


return oStruct                       
 

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaVCab()
Retorna estrutura do tipo FWFormViewStruct.

@author wilson.possani

@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------

static function MontaVCab()
	Local oStruct := FWFormViewStruct():New()
                                           

	oStruct:AddField( 'ENTIDADE', '1', STR0064,STR0064,, 'Get' ,,,,.F.)   // "Entidade"
	oStruct:AddField( 'CODIGO'  , '2', STR0095,STR0095+" "+STR0096,, 'Get' ,,,,.F.)//"Conta"#"Conta Contabil"
	oStruct:AddField( 'DESCCONT', '3', STR0098,STR0098,, 'Get' ,,,,.F.) //"Descrição"
	oStruct:AddField( 'DATALANC', '4', STR0099,STR0099,, 'Get' ,,,,.F.) //"Data"
	oStruct:AddField( 'CREDITO' , '5', STR0100,STR0100,,'Get' ,'@E 99,999,999,999,999.99',,,.F.) //"Saldo Credito"
	oStruct:AddField( 'DEBITO'  , '6', STR0101,STR0101,,'Get' ,'@E 99,999,999,999,999.99',,,.F.) // "Saldo Debito"

return oStruct
       

//-------------------------------------------------------------------
/*/{Protheus.doc} CargaCQ1()
 Carga da Tabela de Saldos

@author wilson.possani

@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CargaCQ1(oModel, oFolder)
Local cFolder:= Iif(oFolder:NOPTION == 1,STR0002,Iif(oFolder:NOPTION == 2,STR0003,;
	Iif(oFolder:NOPTION == 3,STR0004,STR0005)))
Local aAux	 := {}
If oFolder:NOPTION == 1 .Or. oFolder:NOPTION == 5
	aAdd(aAux,'')
	aAdd(aAux,cFolder)
	aAdd(aAux,TMPCQ1->CQ1_CONTA)
	CT1->( DbSeek( xFilial("CT1") + TMPCQ1->CQ1_CONTA ) )
	aAdd(aAux,CT1->CT1_DESC01)
	aAdd(aAux,TMPCQ1->CQ1_DATA)
	aAdd(aAux,TMPCQ1->CQ1_DEBITO)
	aAdd(aAux,TMPCQ1->CQ1_CREDIT)
ElseIf oFolder:NOPTION == 2
	aAdd(aAux,'')
	aAdd(aAux,cFolder)
	aAdd(aAux,TMPCQ3->CQ9_CODIGO)
	CTT->( DbSeek( xFilial("CTT") + TMPCQ3->CQ9_CODIGO ) )
	aAdd(aAux,CTT->CTT_DESC01)
	aAdd(aAux,TMPCQ3->CQ9_DATA)
	aAdd(aAux,TMPCQ3->CQ9_DEBITO)
	aAdd(aAux,TMPCQ3->CQ9_CREDIT)
ElseIf oFolder:NOPTION == 3
	aAdd(aAux,'')
	aAdd(aAux,cFolder)
	aAdd(aAux,TMPCQ5->CQ9_CODIGO)
	CTD->( DbSeek( xFilial("CTD") + TMPCQ5->CQ9_CODIGO ) )
	aAdd(aAux,CTD->CTD_DESC01)
	aAdd(aAux,TMPCQ5->CQ9_DATA)
	aAdd(aAux,TMPCQ5->CQ9_DEBITO)
	aAdd(aAux,TMPCQ5->CQ9_CREDIT)
ElseIf oFolder:NOPTION == 4
	aAdd(aAux,'')
	aAdd(aAux,cFolder)
	aAdd(aAux,TMPCQ7->CQ9_CODIGO)
	CTH->( DbSeek( xFilial("CTH") + TMPCQ7->CQ9_CODIGO ) )
	aAdd(aAux,CTH->CTH_DESC01)
	aAdd(aAux,TMPCQ7->CQ9_DATA)
	aAdd(aAux,TMPCQ7->CQ9_DEBITO)
	aAdd(aAux,TMPCQ7->CQ9_CREDIT)
EndIf



Return aAux


//-------------------------------------------------------------------
/*/{Protheus.doc} CargaCT2()
Busca os 

@author wilson.possani

@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function CargaCT2(oModel)
Local lRet      := .F.
Local cQuery    := ""
Local aArea     := GetArea()
Local aFields	:= oModel:GetStruct():GetFields()
Local aCpoCT2	:= {}
Local nX		:= 0         
Local nY		:= 0        
Local aAux		:= {}
Local cCampo 	:= ""
Local __aRet1	:= {}

DbSelectArea("CT2")
DbSetOrder(1)
cTabCT2	  := GetNextAlias() //'TMPCT2' + Alltrim(Str(oFolder:NOPTION)) 

cQuery    := ""
cQuery    += "SELECT"
cQuery    += " *"
cQuery    += " FROM "+RetSQLName("CT2")+" TMP"
cQuery    += " WHERE"               
If oFolder:NOPTION == 1 .Or. oFolder:NOPTION == 5
	cQuery 	  += " CT2_FILIAL = '"+TMPCQ1->CQ1_FILIAL+"' AND " 
	cQuery    += " CT2_DATA = '"+DTOS(TMPCQ1->CQ1_DATA)+"' AND "
	cQuery    += " (CT2_DEBITO = '"+TMPCQ1->CQ1_CONTA+"' OR  "
	cQuery    += " CT2_CREDIT = '"+TMPCQ1->CQ1_CONTA+"') AND "
	cQuery    += " CT2_MOEDLC = '"+ MV_PAR03 +"' AND "
	cQuery    += " TMP.D_E_L_E_T_ = ' ' "
ElseIf oFolder:NOPTION == 2
	cQuery 	  += " CT2_FILIAL = '"+TMPCQ3->CQ9_FILIAL+"' AND " 
	cQuery    += " CT2_DATA = '"+DTOS(TMPCQ3->CQ9_DATA)+"' AND "
	cQuery    += " (CT2_CCD = '"+TMPCQ3->CQ9_CODIGO+"' OR  "
	cQuery    += " CT2_CCC = '"+TMPCQ3->CQ9_CODIGO+"') AND "
	cQuery    += " CT2_MOEDLC = '"+ MV_PAR03 +"' AND "
	cQuery    += " TMP.D_E_L_E_T_ = ' ' "
ElseIf oFolder:NOPTION == 3
	cQuery 	  += " CT2_FILIAL = '"+TMPCQ5->CQ9_FILIAL+"' AND " 
	cQuery    += " CT2_DATA = '"+DTOS(TMPCQ5->CQ9_DATA)+"' AND "
	cQuery    += " (CT2_ITEMD = '"+TMPCQ5->CQ9_CODIGO+"' OR  "
	cQuery    += " CT2_ITEMC = '"+TMPCQ5->CQ9_CODIGO+"') AND "
	cQuery    += " CT2_MOEDLC = '"+ MV_PAR03 +"' AND "
	cQuery    += " TMP.D_E_L_E_T_ = ' ' " 
ElseIf oFolder:NOPTION == 4
	cQuery 	  += " CT2_FILIAL = '"+TMPCQ7->CQ9_FILIAL+"' AND " 
	cQuery    += " CT2_DATA = '"+DTOS(TMPCQ7->CQ9_DATA)+"' AND "
	cQuery    += " (CT2_CLVLDB = '"+TMPCQ7->CQ9_CODIGO+"' OR  "
	cQuery    += " CT2_CLVLCR = '"+TMPCQ7->CQ9_CODIGO+"') AND "
	cQuery    += " CT2_MOEDLC = '"+ MV_PAR03 +"' AND "
	cQuery    += " TMP.D_E_L_E_T_ = ' ' " 
EndIf

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabCT2,.T.,.T.)
                                                 
For nY := 1 to Len(aFields)
	cCampo :=  Alltrim(aFields[nY][3])
	aAdd(aCpoCT2, cCampo  )
Next nY

While (cTabCT2)->(!EOF())
	TCSetField(cTabCT2,"R_E_C_N_O_", "C")
	aAux := Nil
	aAux := Array(Len(aCpoCT2))

	For nX := 1 to Len(aCpoCT2) 
	   If Alltrim(aCpoCT2[nX]) == 'CT2_DATA'
			cCampo   := aCpoCT2[nX]
			aAux[nX] := STOD((cTabCT2)->&(cCampo))
		ElseIf Alltrim(aCpoCT2[nX]) $ 'R_E_C_N_O_'
			cCampo   := aCpoCT2[nX]
			cChave:= (cTabCT2)->CT2_FILIAL+(cTabCT2)->CT2_DATA+(cTabCT2)->CT2_LOTE+(cTabCT2)->CT2_SBLOTE+(cTabCT2)->CT2_DOC+(cTabCT2)->CT2_LINHA+(cTabCT2)->CT2_TPSALD+(cTabCT2)->CT2_EMPORI+(cTabCT2)->CT2_FILORI+"01"
			CT2->(dbseek(cChave))                         
			aAux[nX] := ALLTRIM(STR(CT2->(Recno())))
		Else		   
			cCampo   := aCpoCT2[nX]
			aAux[nX] := (cTabCT2)->&(cCampo)
		EndIf
	Next nX
	
	aAdd(__aRet1,{0 ,aAux })

	(cTabCT2)->(dbSkip())
EndDo      

If Select(cTabCT2) > 0
	DbSelectArea(cTabCT2)
	(cTabCT2)->(DbCloseArea())
	Ferase(cTabCT2)
Endif

Return __aRet1


//-------------------------------------------------------------------
/*/{Protheus.doc} ConsOri()
Busca os resitros da origem

@author wilson.possani

@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ConsOri(coView,oModel)

Local nOpc	 := 4
Local cRecCt2:= 0
Local aArea	 := GetArea() 
Local nRecDes:= 0
Local nRecOri:= 0
Local cTabOri:= ""

If coView == "RASTCV3V"
	cCadastro:= STR0102 //"Exibe o Documento Original" 
	cRecCT2 := ALLTRIM(STR(INT(CT2->(Recno()))))
	nRecDes:= oModel:GetValue( 'RASTCV3',"CV3_RECDES" )
	nRecOri:= oModel:GetValue( 'RASTCV3',"CV3_RECORI" )
	cTabOri:= oModel:GetValue( 'RASTCV3',"CV3_TABORI" )  
	
	CTBC010ROT(cTabOri,nRecOri,nOpc,nRecDes)

Endif 

RestArea(aArea)
Return .T.
