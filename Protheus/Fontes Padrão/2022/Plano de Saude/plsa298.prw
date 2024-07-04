#INCLUDE "PLSA298.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"

/*/{Protheus.doc} PL298MOV
Cadastro de Relacionamento entre NF's Entrada x Guias                                             
O objetivo deste relacionamento eh utilizar o valor da NF para valorizar o custo do usuario e cobrar do mesmo (quando for o caso) o valor pago pelo material de alto custo.  
@type function
@author TOTVS
@since 12.12.06
@version 1.0
/*/
Function PLSA298
local lSeqImp :=  B19->(fieldPos("B19_SEQIMP")) > 0 
local cFiltro := iif(lSeqImp,"B19_FILIAL ='" + xFilial("B19") + "'AND" +" B19_SEQIMP = ' ' ","")

Private aRotina := {	{ STRPL01 , 'AxPesqui' , 0 , K_Pesquisar  },; //'Pesquisar'
						{ STRPL02 , 'PL298MOV' , 0 , K_Visualizar },; //'Visualizar'
						{ STRPL03 , 'PL298MOV' , 0 , K_Incluir    },; //'Incluir'
						{ STRPL04 , 'PL298MOV' , 0 , K_Alterar    },; //'Alterar'
						{ STRPL05 , 'PL298MOV' , 0 , K_Excluir    } } //'Excluir'

Private cCadastro := "Cadastro de NF's Entrada x Guias"

B19->(dbSetOrder(1))
B19->(dbGoTop())
iif(lSeqImp,B19->(mBrowse(06,01,22,75,"B19",,,,,,,,,,,,,,cFiltro)),B19->(mBrowse(06,01,22,75,"B19")))

Return

/*/{Protheus.doc} PL298MOV
Movimentacao do Cadastro de Relacionamento NF Entr x Guias 
@type function
@author TOTVS
@since 12.12.06
@version 1.0
/*/
Function PL298MOV(cAlias,nReg,nOpc)
Local I__f     := 0
Local nOpca	   := 0
Local oDlg
Local cChave   := ""
Local nRecNo   := 0
Local aPosObj  := {}
Local aObjects := {}
Local aSize    := {}
Local aInfo    := {}
Local nInd     := 0
Local aColsNew := {}
Local aColsOld := {}

Private oEnchoice
Private oGetDados
Private aTELA[0][0]
Private aGETS[0]
Private aHeader
Private aCols
Private aVetTrab := {}
Private aChave   := {}

If ExistBlock( "PLS298GET" )  
	If ExecBlock( "PLS298GET", .F., .F., { }, .F. )    
		Store Header "B19" To aHeader For AllTrim(SX3->X3_CAMPO) $ "B19_ITEM,B19_COD,B19_DESC,B19_GUIA,B19_NOMUSR"	  
	Else
		Store Header "B19" To aHeader For AllTrim(SX3->X3_CAMPO) $ "B19_ITEM,B19_COD,B19_DESC,B19_GUIA,B19_NOMUSR"			
	EndIf
Else
	Store Header "B19" To aHeader For AllTrim(SX3->X3_CAMPO) $ "B19_ITEM,B19_COD,B19_DESC,B19_GUIA,B19_NOMUSR"
EndIf

If nOpc == K_Incluir
	Copy "B19" To Memory Blank
	Store COLS Blank "B19" To aCols From aHeader
Else
	Copy "B19" To Memory
	cChave := B19->(B19_FILIAL+B19_DOC+B19_SERIE+B19_FORNEC+B19_LOJA)
	nRecNo := B19->(RecNo())

	B19->(dbSetOrder(1))
	If B19->(MsSeek(cChave))
		Store COLS "B19" To aCols From aHeader VETTRAB aVetTrab While B19->(B19_FILIAL+B19_DOC+B19_SERIE+B19_FORNEC+B19_LOJA) == cChave
	Else
		Store COLS Blank "B19" To aCols From aHeader
	EndIf
	
	B19->(dbGoTo(nRecNo))
	If ALTERA
		PL298VLDNF("2")
	EndIf
	aColsOld := aClone(aCols)
EndIf
aSize    := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .F. } )
AAdd( aObjects, { 1, 1, .T., .T., .F. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

Define MsDialog oDlg Title cCadastro From aSize[7],0 To aSize[6],aSize[5] Of GetWndDefault() Pixel
Zero()     
If ExistBlock( "PLS298ENC" )   
	aArea = GetArea()
	If ExecBlock( "PLS298ENC", .F., .F., { }, .F. )
		oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,{"B19_FORNEC","B19_LOJA","B19_DOC",SerieNfId('B19',3,"B19_SERIE")},aPosObj[1],,,,,,oDlg,,,.F.)
	Else
		oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,{"B19_FORNEC","B19_LOJA","B19_DOC",SerieNfId('B19',3,"B19_SERIE"),"NOUSER"},aPosObj[1],,,,,,oDlg,,,.F.)
	EndIf	 
	RestArea(aArea)
Else      
	oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,{"B19_FORNEC","B19_LOJA","B19_DOC",SerieNfId('B19',3,"B19_SERIE")},aPosObj[1],,,,,,oDlg,,,.F.)
EndIf   

oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"AllwaysTrue","PL298TDOK",,.F.,,,,Len(aCols),,,,,oDlg)
Activate MsDialog oDlg On Init Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,IIf(Obrigatorio(aGets,aTela).And.oGetDados:TudoOK(),oDlg:End(),nOpca:=2),IIf(nOpca==1,oDlg:End(),.F.) },{||oDlg:End()},.F.,{})  })
If nOpca == K_OK
	aChave := { {"B19_DOC",M->B19_DOC},{SerieNfId('B19',3,"B19_SERIE"),&('M->'+SerieNfId('B19',3,"B19_SERIE"))},{"B19_FORNEC",M->B19_FORNEC},{"B19_LOJA",M->B19_LOJA} }
	If INCLUI .Or. ALTERA
		For nInd := 1 To Len(aCols)
			If ! Empty(aCols[nInd, aScan(aHeader, { |x| AllTrim(x[2]) == "B19_GUIA" })])
				aAdd(aColsNew, aClone(aCols[nInd]))
			Else
				If ALTERA
					B19->(dbSetOrder(2))
					If B19->(MsSeek(xFilial("B19")+aColsOld[nInd, aScan(aHeader, { |x| AllTrim(x[2]) == "B19_GUIA" })]))
						RecLock("B19", .F.)
						B19->(DbDelete())
						B19->(MsUnlock())
					EndIf
					B19->(dbSetOrder(1))
				EndIf
			EndIf
		Next nInd                  
		aCols := aClone(aColsNew)
	EndIf
	PlUptCols("B19",aCols,aHeader,aVetTrab,nOpc,aChave)
EndIf

Return

/*/{Protheus.doc} PL298VLGUI
Valida a Guia de Internacao informada
@type function
@author TOTVS
@since 12.12.06
@version 1.0
/*/
Function PL298VLGUI()

	Local lRet := .T.
	Local nInd := 0
	
	If ! Empty(M->B19_GUIA)
	
		lRet := ExistCpo("BD6",M->B19_GUIA) 
		
		If lRet
	
			aCols[n, aScan(aHeader, {|x|AllTrim(x[2]) == "B19_NOMUSR"})] := Posicione("BD6", 1, xFilial("BD6")+M->B19_GUIA, "BD6_NOMUSR")
			For nInd := 1 To Len(aCols)
				If nInd <> n
					If aCols[nInd, aScan(aHeader, { |x| AllTrim(x[2]) == "B19_GUIA" })] == M->B19_GUIA
						Help("",1,"JAGRAVADO",,STR0002 + ; //"Guia já informada para este fornecedor/nota fiscal no item "
								aCols[nInd, aScan(aHeader, { |x| AllTrim(x[2]) == "B19_ITEM" })],3,0)
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next nInd
			
			If lRet
				B19->(dbSetOrder(2))
				If B19->(MsSeek(xFilial("B19")+M->B19_GUIA))
					If B19->(B19_FORNEC+B19_LOJA+B19_DOC+B19_SERIE) <> M->(B19_FORNEC+B19_LOJA+B19_DOC+B19_SERIE)
						Help("",1,"JAGRAVADO",,STR0003 + CRLF + ; //"Guia já associada a outro Fornecedor/Nota Fiscal:"
									B19->B19_FORNEC + " " + B19->B19_LOJA + " " + B19->B19_DOC + " " + SerieNfId('B19',2,"B19_SERIE") + " " + B19->B19_ITEM,3,0)
						lRet := .F.
					EndIf
				EndIf
			EndIf
		
		EndIf
		
	Else
	
		aCols[n, aScan(aHeader, {|x|AllTrim(x[2]) == "B19_NOMUSR"})] := ""
		
	EndIf
	
Return lRet

/*/{Protheus.doc} PL298TDOK
Valida o Fornecedor/Loja e o Documento/Serie apos o usuario clicar no botao "OK" 
@type function
@author TOTVS
@since 12.12.06
@version 1.0
/*/
Function PL298TDOK()

Local lRet := .T.
SA2->(dbSetOrder(1))
If ! SA2->(MsSeek(xFilial("SA2")+M->B19_FORNEC+M->B19_LOJA))
	Help("",1,"REGNOIS",,STR0004,4,0) //"Fornecedor/Loja inválido!"
	lRet := .F.
Else
	lRet := PL298VLDNF("2",.F., STR0005) //"Documento/Série Inválido para o Fornecedor/Loja informado!"
EndIf         

If lRet .And. INCLUI
	lRet := ExistChav("B19", M->(B19_DOC+B19_SERIE+B19_FORNEC+B19_LOJA))
EndIf

Return lRet

/*/{Protheus.doc} PL298VLDNF
Valida a Nota Fiscal/Serie informada e atualiza browse.
@type function
@author TOTVS
@since 12.12.06
@version 1.0
/*/
Function PL298VLDNF(cCpo, lAtual, cMensag)
Local I__f := 0
Local nInd
Local lRet
Local aNewCols        
Local nPItem
Local nPCod
Local nPDesc
Local nPNomU
Default cCpo    := "2"
Default lAtual  := .T.         
Default cMensag := ""
SF1->(DbSetOrder(1))
If SF1->(MsSeek(xFilial("SF1")+M->B19_DOC+M->B19_SERIE+M->B19_FORNEC+M->B19_LOJA))
	lRet := .T.
	If lAtual
		nPItem := aScan(aHeader, {|x|AllTrim(x[2]) == "B19_ITEM"})
		nPCod  := aScan(aHeader, {|x|AllTrim(x[2]) == "B19_COD"})
		nPDesc := aScan(aHeader, {|x|AllTrim(x[2]) == "B19_DESC"})
		nPNomU := aScan(aHeader, {|x|AllTrim(x[2]) == "B19_NOMUSR"})
		SD1->(DbSetOrder(1))
		SD1->(MsSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
		nInd  := 0
		If INCLUI
			aCols := {}
		EndIf
		Do While SD1->(!Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
			If aScan(aCols, { |x| x[nPItem]+x[nPCod] == SD1->(D1_ITEM+D1_COD) }) == 0
				Store COLS Blank "B19" TO aNewCols FROM aHeader
				aAdd(aCols, aClone(aNewCols[1]))
				nInd := Len(aCols)
				aCols[nInd, nPItem] := SD1->D1_ITEM
				aCols[nInd, nPCod]  := SD1->D1_COD
				aCols[nInd, nPDesc] := Posicione("SB1", 1, xFilial("SB1")+SD1->D1_COD, "B1_DESC")
				aCols[nInd, nPNomU] := ""
			EndIf
			SD1->(DbSkip())
		EndDo
		aCols := aSort(aCols,,, {|x,y| x[1] < y[1]} )
	EndIf
Else
	If lAtual
		Store COLS Blank "B19" TO aCols FROM aHeader
	EndIf
	If cCpo == "1"
		lRet := .T.
	Else
		Help("",1,"REGNOIS",,cMensag,4, 0)
		lRet := .F.
	EndIf
EndIf         
               
If lAtual .And. ValType(oGetDados) == "O"
	oGetDados:Refresh()
EndIf
	
Return lRet

/*/{Protheus.doc} PLPESQGUIA
Pesquisa generica de pesquisa de guias 
@type function
@author TOTVS
@since 12.12.06
@version 1.0
/*/
Function PLPESQGUIA()

	Static objCENFUNLGP := CENFUNLGP():New()

Local cChave     := Space(100)
Local oDlgPesGui                       
Local oTipoPes
Local oSayGui
Local nOpca      := 0
Local aBrowGui   := {}
Local aVetPad    := { { "ENABLE", "","","","","","",CtoD(""), 0 } }
Local oBrowGui
Local bRefresh   := { || If(!Empty(cChave),PLPQGUIA(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowGui,aVetPad,oBrowGui),.T.), If( Empty(aBrowGui[1,2]) .And. !Empty(cChave),.F.,.T. )  }
Local cValid     := "{|| Eval(bRefresh) }"
Local bOK        := { || If(!Empty(cChave),(nLin := oBrowGui:nAt, nOpca := 1,oDlgPesGui:End()),Help("",1,"PLSMCON")) }
Local bCanc      := { || nOpca := 3,oDlgPesGui:End() }
Local oGetChave
Local aTipoPes   := {}
Local nOrdem     := 1
Local cTipoPes   := ""
Local oChkChk
Local lChkChk    := .F.
Local nLin       := 1
Local aButtons 	 := {} 

aBrowGui := aClone(aVetPad)
If ExistBlock("PLSBUTDV")							
	aButtons := ExecBlock("PLSBUTDV",.F.,.F.)		
EndIf												

aTipoPes := { STR0006, STR0007, STR0008, "4-Nr. da Guia" } //"1-Nome do Usuário"###"2-Matrícula do Usuário"###"3-Matrícula Antiga"###

Define MsDialog oDlgPesGui Title STR0010 From 008.2,000 To 025,ndColFin Of GetWndDefault() //"Pesquisa de Guias"
oGetChave := TGet():New(035,103,{ | U | If( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesGui,210,008 ,"@!S30",&cValid,Nil,Nil,Nil,Nil,Nil,.T.,Nil,.F.,Nil,.F.,Nil,Nil,.F.,Nil,Nil,cChave)
oBrowGui := TcBrowse():New( 050, 008, 378, 075,,,, oDlgPesGui,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrowGui:AddColumn(TcColumn():New("",Nil,;
         Nil,Nil,Nil,Nil,055,.T.,.F.,Nil,Nil,Nil,.T.,Nil))
         oBrowGui:ACOLUMNS[1]:BDATA     := { || aBrowGui[oBrowGui:nAt,1] }

oBrowGui:AddColumn(TcColumn():New(STR0011,Nil,; //"Matrícula"
         Nil,Nil,Nil,Nil,055,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
         oBrowGui:ACOLUMNS[2]:BDATA     := { || aBrowGui[oBrowGui:nAt,2] }

oBrowGui:AddColumn(TcColumn():New(STR0012,Nil,; //"Matricula Antiga"
         Nil,Nil,Nil,Nil,055,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
         oBrowGui:ACOLUMNS[3]:BDATA     := { || aBrowGui[oBrowGui:nAt,3] }

oBrowGui:AddColumn(TcColumn():New(STR0013,Nil,; //"Nome do Usuário"
         Nil,Nil,Nil,Nil,090,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
         oBrowGui:ACOLUMNS[4]:BDATA     := { || aBrowGui[oBrowGui:nAt,4] }

oBrowGui:AddColumn(TcColumn():New("Guia Operadora",Nil,; 
         Nil,Nil,Nil,Nil,070,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     
         oBrowGui:ACOLUMNS[5]:BDATA     := { || aBrowGui[oBrowGui:nAt,5] } 

oBrowGui:AddColumn(TcColumn():New(STR0021,Nil,; //"Tipo de Guia"
         Nil,Nil,Nil,Nil,070,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     
         oBrowGui:ACOLUMNS[6]:BDATA     := { || aBrowGui[oBrowGui:nAt,6] }	         

oBrowGui:AddColumn(TcColumn():New(STR0015,Nil,; //"Procedimento"
         Nil,Nil,Nil,Nil,040,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     
         oBrowGui:ACOLUMNS[7]:BDATA     := { || aBrowGui[oBrowGui:nAt,7] }

oBrowGui:AddColumn(TcColumn():New(STR0016,Nil,; //"Descrição"
         Nil,Nil,Nil,Nil,120,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     
         oBrowGui:ACOLUMNS[8]:BDATA     := { || aBrowGui[oBrowGui:nAt,8] }

oBrowGui:AddColumn(TcColumn():New(STR0017,Nil,; //"Data Proced"
         Nil,Nil,Nil,Nil,040,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     
         oBrowGui:ACOLUMNS[9]:BDATA     := { || aBrowGui[oBrowGui:nAt,9] }

@ 035,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 090,010 OF oDlgPesGui PIXEL COLOR CLR_HBLUE
@ 035,319 CHECKBOX oChkChk   Var lChkChk PROMPT STR0018 PIXEL SIZE 080, 010 OF oDlgPesGui //"Pesquisar Palavra Chave"

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := { .F.,;
					"BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO",;
					"BD6_MATANT",;
					"BD6_NOMUSR",;
					"BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO",;
					.F.,;
					"BD6_CODPRO",;
					"BD6_DESPRO",;
					"BD6_DATPRO",; 
					.F. }
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oBrowGui:aObfuscatedCols := aBls//{.T., .T., .T., .T., .T., .T., .F., .T.}
	endif

oBrowGui:SetArray(aBrowGui)
oBrowGui:bLDblClick := bOK
                                 
Activate MsDialog oDlgPesGui On Init Eval({ || EnChoiceBar(oDlgPesGui,bOK,bCanc,.F.,aButtons) }) 

If nOpca == K_OK
   If !Empty(aBrowGui[nLin,2])
      BD6->(dbGoTo(aBrowGui[nLin,10]))
   EndIf
EndIf

Return(nOpca==K_OK)

/*/{Protheus.doc} PLPQGUIA
Pesquisa as guias na base de dados
@type function
@author TOTVS
@since 12.12.06
@version 1.0
/*/
Static Function PLPQGUIA(cChave,cTipoPes,lChkChk,aBrowGui,aVetPad,oBrowGui)

Local aArea     := GetArea()
Local cSQL      := ""
Local cRetBD6
Local cStrFil
Local cAltCus
Local cOrderBy	:= ""
Local aPL298GUI := {}

If '"' $ cChave .Or. ;
   "'" $ cChave
   Aviso( STR0019, STR0020, { "Ok" }, 2 )
   Return(.F.)
EndIf   

cRetBD6 := RetSQLName("BD6")                                            

aBrowGui := {}
  
If ExistBlock('PL298GUI')
	  aPL298GUI := ExecBlock('PL298GUI',.F.,.F.,{cChave,cTipoPes,lChkChk,aBrowGui})  
	  If ValType(aPL298GUI) =='A'
	  	aBrowGui := aClone(aPL298GUI)
	  EndIf	
Else

	cSQL := "SELECT BD6_OPEUSR, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_DIGITO, "
	cSQL += "       BD6_MATANT, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_NOMUSR, "
	cSQL += "       BD6_CODOPE, BD6_ANOINT, BD6_MESINT, BD6_NUMINT, BD6_TIPGUI, BR8_ALTCUS, "
	cSQL += "       BD6_CODPAD, BD6_CODPRO, BD6_DESPRO, BD6_DATPRO, BD6.R_E_C_N_O_ AS RECBD6 "
	cSQL += "  FROM " + cRetBD6 + " BD6 "
	cSQL += " INNER JOIN " + RetSqlName("BR8") + " BR8 "
	cSQL += " ON BR8.BR8_FILIAL = '" + xFilial("BR8") + "' "
	cSQL += " AND BR8.BR8_CODPAD = BD6.BD6_CODPAD "
	cSQL += " AND BR8.BR8_CODPSA = BD6.BD6_CODPRO "
	cSQL += " AND BR8.BR8_ALTCUS = '1' "
	cSQL += " AND BR8.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSQLName("BA1") + " BA1 "
	cSql += " ON BA1.BA1_FILIAL = '" + xFilial("BA1") + "' "
	cSql += " AND BD6_OPEUSR = BA1_CODINT "
	cSql += " AND BD6_CODEMP = BA1_CODEMP "
	cSql += " AND BD6_MATRIC = BA1_MATRIC "
	cSql += " AND BD6_TIPREG = BA1_TIPREG "
	cSql += " AND BD6_DIGITO = BA1_DIGITO "
	cSql += " AND BA1.D_E_L_E_T_ = ' ' "
	cSQL += " WHERE "
	cSQL += " BD6_FILIAL = '"+xFilial("BD6")+"' AND "
	If cTipoPes == "1" // Nome do Usuario			
		If lChkChk
			cSQL += "BD6_NOMUSR LIKE '%" + AllTrim(cChave) + "%' AND "
		Else
			cSQL += "BD6_NOMUSR LIKE '" + AllTrim(cChave) + "%' AND "
		EndIf	

		cOrderBy := " ORDER BY BD6_FILIAL,BD6_NOMUSR "

	ElseIf cTipoPes == "2" // Matricula do Usuario    		   
		If lChkChk
			cSQL += "BD6_OPEUSR || BD6_CODEMP || BD6_MATRIC || BD6_TIPREG LIKE '%" + AllTrim(cChave) + "%' AND "
		Else
			cSQL += "BD6_OPEUSR || BD6_CODEMP || BD6_MATRIC || BD6_TIPREG LIKE '" + AllTrim(cChave) + "%' AND "
		EndIf

		cOrderBy := " ORDER BY BD6_FILIAL,BD6_OPEUSR,BD6_CODEMP,BD6_MATRIC,BD6_TIPREG "

	ElseIf cTipoPes == "3" // Matricula Antiga		
		If lChkChk
			cSQL += "BD6_MATANT LIKE '%" + AllTrim(cChave) + "%' AND "
		Else
			cSQL += "BD6_MATANT LIKE '" + AllTrim(cChave) + "%' AND "
		EndIf	

		cOrderBy := " ORDER BY BD6_FILIAL,BD6_OPEUSR,BD6_CODEMP,BD6_MATRIC,BD6_TIPREG,BD6_DIGITO "

	ElseIf cTipoPes == "4" // Numero da Guia
		
		If lChkChk
			cSQL += "BD6_CODOPE||BD6_CODLDP||BD6_CODPEG||BD6_NUMERO LIKE '%" + AllTrim(cChave) + "%' AND "
		Else
			cSQL += "BD6_CODOPE||BD6_CODLDP||BD6_CODPEG||BD6_NUMERO LIKE '" + AllTrim(cChave) + "%' AND "
		EndIf
		
		cOrderBy := " ORDER BY BD6_FILIAL,BD6_NOMUSR "
	EndIf   
	
	cSQL += "BD6_TIPGUI  IN ('02','03','05') AND "
	cSQL += "BD6_FASE   IN ('1','2') AND "
	cSQL += "BD6.D_E_L_E_T_ = ' '"
	If FindFunction("PLSRESTOP")
		cStrFil := PLSRESTOP("U")   // retorna string com filtro para restricao do operador
		If !Empty(cStrFil)
			cSQL += " AND " + cStrFil
		EndIf
	EndIf	

	cSQL += cOrderBy

	If ExistBlock("PL298PESBD")
	   cSQL := ExecBlock("PL298PESBD",.F.,.F.,{cSQL})
	Endif
	
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbPes",.F.,.T.)	
	
	Do While !TrbPes->(Eof())		
	    TrbPes->(aAdd(aBrowGui, {  "ENABLE",;
									TrbPes->BD6_OPEUSR+"."+TrbPes->BD6_CODEMP+"."+TrbPes->BD6_MATRIC+"."+TrbPes->BD6_TIPREG+"-"+TrbPes->BD6_DIGITO,;
									TrbPes->BD6_MATANT,;
									TrbPes->BD6_NOMUSR,;
									TrbPes->BD6_CODOPE+"."+TrbPes->BD6_CODLDP+"."+TrbPes->BD6_CODPEG+"."+TrbPes->BD6_NUMERO,;
									If(TrbPes->BD6_TIPGUI=='03',"Solicitação de Internação",(If(TrbPes->BD6_TIPGUI=='02',"SADT","Resumo de internação"))),;
									TrbPes->BD6_CODPRO,;
									TrbPes->BD6_DESPRO,;
									TrbPes->BD6_DATPRO,; 
									TrbPes->RECBD6 }))
	
		TrbPes->(DbSkip())
	EndDo
	      
	TrbPes->(DbCloseArea()) 

EndIf 

RestArea(aArea)

If Len(aBrowGui) == 0
	aBrowGui := aClone(aVetPad)   
EndIf       

oBrowGui:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
                  // uma pesquisa mais abrangante e depois uma nova pesquisa menos abrangente
                  // Exemplo:
                  // 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
                  // (via seta para cima ou clique na primeira linha)
                  // 2a. Pesquisa: "AV" - Ocorria o erro
oBrowGui:SetArray(aBrowGui)
oBrowGui:Refresh() 
oBrowGui:SetFocus()

Return(.T.)
