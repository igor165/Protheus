#INCLUDE "plsmcon.ch"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COMMON.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE G_CONSULTA  "01"

//Variável utilizada para identificar os itens do grid de itens
STATIC __oGrdRee
STATIC __ArrPro := {}
STATIC objCENFUNLGP := CENFUNLGP():New() 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESUSER ³ Autor ³ Tulio Cesar        ³ Data ³ 16.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de usuarios...                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPESUSER(lBloqueia)
LOCAL aCores 		:= {}
LOCAL aAuxCor		:= {}
LOCAL cChave     := Space(100)
LOCAL oDlgPesUsr
LOCAL oTipoPes
LOCAL oSayUsr
LOCAL nOpca      := 0
LOCAL aBrowUsr   := {}
LOCAL aVetPad    := { {"ENABLE","","",0,"","","","","","","","",""} }
LOCAL oBrowUsr
LOCAL bRefresh   := { || If(!Empty(cChave),PLSAPUSRPq(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowUsr,aVetPad,oBrowUsr,lBloqueia),.T.), If( Empty(aBrowUsr[1,2]) .And. !Empty(cChave),.F.,.T. )  }
LOCAL cValid     := "{|| Eval(bRefresh) }"
LOCAL bOK        := { || IIF(FunName() == "TMKA271", (nLin := oBrowUsr:nAt, nOpca := 1,oDlgPesUsr:End()), IIF(!Empty(cChave),(nLin := oBrowUsr:nAt, nOpca := 1,oDlgPesUsr:End()),Help("",1,"PLSMCON"))) }
LOCAL bCanc      := { || nOpca := 3,oDlgPesUsr:End() }
LOCAL nReg
LOCAL oGetChave
LOCAL aTipoPes   := {}
LOCAL nOrdem     := 1
LOCAL cTipoPes   := ""
LOCAL oChkChk
LOCAL lChkChk    := .F.
LOCAL nLin       := 1
LOCAL aButtons 	 := {}
LOCAL cSQL
LOCAL lIncUsr	 := GetNewPar("MV_PLSUSR",.F.)
Local aCampos := {}
Local aBls    := {}

DEFAULT lBloqueia:= .F.

PRIVATE aOpcoes  := {}

cCadastro := Fundesc()

aBrowUsr := aClone(aVetPad)
IF ExistBlock("PLSBUTDV")
	aButtons := ExecBlock("PLSBUTDV",.F.,.F.)
Endif
// Tratamento para inclusão de usuário, somente pelo Call Center -- 14/12/10 - Bruno Lazarini
If cModulo == 'TMK' .And. lIncUsr // If IsInCallStack("TKSELENT")
	AAdd(aButtons ,{ STR0037	,	{|| PLSMBUSCA(oBrowUsr,aBrowUsr) }, STR0037,STR0037}) // Intercâmbio
	AAdd(aButtons ,{ STR0036    ,	{|| A090INTGER("BE1")}, STR0036,STR0036}) // Usuário
Else
	If GetNewPar("MV_PLORDTM",2) != 2 //No Call Center, se a entidade foi pesquisar, o parametro nao pode ter efeito, sempre vou pesquisar pela matricula PLS
		BA1->(dbSetOrder(2))
	EndIf
Endif

cSQL := "SELECT BX8_OPCAO, BX8_CHAVE "
cSQL += "  FROM "+RetSQLNAME("BX8")
cSQL += " WHERE BX8_FILIAL = '"+xFilial("BX8")+"'"
cSQL += "   AND BX8_RDMAKE = 'PLSPESUSR'"
cSQL += "   AND D_E_L_E_T_ = ' '"
PLSQuery(cSQL,"PLSBX8")

If ! PLSBX8->(Eof())
   While ! PLSBX8->(Eof())
         aadd(aTipoPes,AllTrim(Str(nOrdem,2))+"-"+PLSBX8->BX8_OPCAO)
         aadd(aOpcoes,{AllTrim(PLSBX8->BX8_CHAVE)})
         nOrdem ++
   PLSBX8->(DBSkip())
   Enddo
Else
   aTipoPes   := {STR0001,STR0002,STR0003,STR0004,STR0005,STR0006,STR0007,"8-Nome Social"} //"1-Nome do Usuario"###"2-Matricula"###"3-Matricula Antiga"###"4-Matricula Empresa"###"5-Nome do Pai"###"6-Nome da Mae"###"7-Nome Empresa/Nome Usuario"

   aadd(aOpcoes,{"BA1_NOMUSR"})
   aadd(aOpcoes,{"BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG"})
   aadd(aOpcoes,{"BA1_MATANT"})
   aadd(aOpcoes,{"BA1_MATEMP"})
   aadd(aOpcoes,{"BA1_PAI"})
   aadd(aOpcoes,{"BA1_MAE"})
   aadd(aOpcoes,{""})
   aadd(aOpcoes,{"BA1_NOMSOC"})

Endif

PLSBX8->(DbCloseArea())
DbSelectArea("BX8")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPesUsr TITLE STR0008 FROM 008.2,000 TO 026,ndColFin OF GetWndDefault() //"Pesquisa de Beneficiarios"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Val(GetVersao(.F.)) >= 12//caso a versão seja maior ou igual a 12 altera a linha de início dos folders
	oGetChave := TGet():New(033,103,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesUsr,210,008 ,"@!S30",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
Else
	oGetChave := TGet():New(020,103,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesUsr,210,008 ,"@!S30",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Browse...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Val(GetVersao(.F.)) >= 12//caso a versão seja maior ou igual a 12 altera a linha de início dos folders
	oBrowUsr := TcBrowse():New( 050, 008, 378, 075,,,, oDlgPesUsr,,,,,,,,,,,, .F.,, .T.,, .F., )
Else
	oBrowUsr := TcBrowse():New( 043, 008, 378, 075,,,, oDlgPesUsr,,,,,,,,,,,, .F.,, .T.,, .F., )
Endif

oBrowUsr:AddColumn(TcColumn():New("",nil,nil,nil,nil,nil,015,.T.,.F.,nil,nil,nil,.T.,nil))
         oBrowUsr:ACOLUMNS[1]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,1] }

oBrowUsr:AddColumn(TcColumn():New(STR0009,nil,nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil)) //"Matricula"
         oBrowUsr:ACOLUMNS[2]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,2] }

oBrowUsr:AddColumn(TcColumn():New(STR0010,nil,nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil)) //"Matricula Antiga"
         oBrowUsr:ACOLUMNS[3]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,9] }

oBrowUsr:AddColumn(TcColumn():New(STR0011,nil,nil,nil,nil,nil,120,.F.,.F.,nil,nil,nil,.F.,nil)) //"Nome"
         oBrowUsr:ACOLUMNS[4]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,3] }

oBrowUsr:AddColumn(TcColumn():New("Nome Social",nil,nil,nil,nil,nil,120,.F.,.F.,nil,nil,nil,.F.,nil)) //"Nome Social"
         oBrowUsr:ACOLUMNS[5]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,13] }

oBrowUsr:AddColumn(TcColumn():New(STR0035,nil,nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil)) //"Plano"
         oBrowUsr:ACOLUMNS[6]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,11] }

oBrowUsr:AddColumn(TcColumn():New(STR0044,nil,nil,nil,nil,nil,70,.F.,.F.,nil,nil,nil,.F.,nil)) //"Descricao do Plano"
        	 oBrowUsr:ACOLUMNS[7]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,12] }

oBrowUsr:AddColumn(TcColumn():New(STR0012,nil,nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil)) //"Nome Reduzido
         oBrowUsr:ACOLUMNS[8]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,10] }

oBrowUsr:AddColumn(TcColumn():New(STR0013,nil,nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil)) //"Nascto (Idade)"
         oBrowUsr:ACOLUMNS[9]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,4] }

oBrowUsr:AddColumn(TcColumn():New(STR0014,nil,nil,nil,nil,nil,120,.F.,.F.,nil,nil,nil,.F.,nil)) //"Nome do Pai/Mae"
         oBrowUsr:ACOLUMNS[10]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,5] }

oBrowUsr:AddColumn(TcColumn():New(STR0015,nil,nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil)) //"Data Inclusao"
         oBrowUsr:ACOLUMNS[11]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,6] }

oBrowUsr:AddColumn(TcColumn():New(STR0016,nil,nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil)) //"Bairro"
         oBrowUsr:ACOLUMNS[12]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,7] }

If Val(GetVersao(.F.)) >= 12//caso a versão seja maior ou igual a 12 altera a linha de início dos folders
	@ 033,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 090,010 OF oDlgPesUsr PIXEL COLOR CLR_HBLUE
	@ 033,319 CHECKBOX oChkChk   Var lChkChk PROMPT STR0017 PIXEL SIZE 080, 010 OF oDlgPesUsr //"Pesquisar Palavra Chave"
Else
	@ 020,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 090,010 OF oDlgPesUsr PIXEL COLOR CLR_HBLUE
	@ 020,319 CHECKBOX oChkChk   Var lChkChk PROMPT STR0017 PIXEL SIZE 080, 010 OF oDlgPesUsr //"Pesquisar Palavra Chave"
Endif

oBrowUsr:SetArray(aBrowUsr)
oBrowUsr:BLDBLCLICK := bOK

//-- LGPD -------- 
if objCENFUNLGP:isLGPDAt() 
	aCampos := { .F.,;
				 "BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO",;	//Matricula
				 "BA1_MATANT",;												//Matricula Antiga
				 "BA1_NOMUSR",;												//Nome
				 "BA1_CODPLA+BA3_CODPLA",;									//Plano
				 "BI3_DESCRI",;												//Descricao do Plano
				 "BA1_NREDUZ",;												//Nome Reduzido
				 "BA1_DATNAS",;												//Nascto (Idade)
				 "BA1_PAI+BA1_MAE",;										//Nome do Pai/Mae
				 "BA1_DATINC",;												//Data Inclusao
				 "BA1_BAIRRO",;												//Bairro
				 "BA1_NOMSOC"}                                              //Nome Social

	aBls := objCENFUNLGP:getTcBrw(aCampos) 
	oBrowUsr:aObfuscatedCols := aBls 
endif 
//---------------- 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgPesUsr ON INIT Eval({ || EnChoiceBar(oDlgPesUsr,bOK,bCanc,.F.,aButtons) })

If nOpca == K_OK
   If !Empty(aBrowUsr[nLin,2])
      BA1->(DbGoTo(aBrowUsr[nLin,8]))
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da Funcao...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nOpca==K_OK)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300PQ  ³ Autor ³ Tulio Cesar        ³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa a usuarios na base de dados ...                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSAPUSRPq(cChave,cTipoPes,lChkChk,aBrowUsr,aVetPad,oBrowUsr,lBloqueia,lAuto)

	Local aArea     	:= GetArea()
	LOCAL cSQL      	:= ""
	LOCAL cNomeEmp  	:= ""
	LOCAL cNomeUsr  	:= ""
	LOCAL nFor   		:= 0
	LOCAL lTroca    	:= .F.
	Local cStrFil   	:= ""
	Local lExisteBloc	:=.F.
	LOCAL dBloqueio		:=	FsDateConv(dDataBase,"YYYYMMDD")
	LOCAL cCodPla 		:= ""
	LOCAL cNomePla		:= ""
	LOCAL cCor 			:= ""

	Default lAuto := .F.

	If '"' $ cChave .Or. "'" $ cChave
		Aviso( STR0018,STR0019,{ STR0028}, 2 )//"Caracter Invalido"//"Existem caracteres invalidos em sua pesquisa."
		Return(.F.)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa resultado...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aBrowUsr := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua busca...                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := "SELECT BA1_NREDUZ, BA1_MATANT, BA1_NOMUSR, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, "
	cSQL += "       BA1_DATNAS, BA1_PAI,    BA1_IMAGE,  BA1_MAE,    BA1_DATINC, BA1_BAIRRO, BA1_MOTBLO, BA1_CODPLA, "
	cSQL += "       BA3_CODPLA, BA1_DATBLO, BA1_NOMSOC, BA1.R_E_C_N_O_  BA1REG "
	cSql += " FROM "+RetSqlName("BA1")+" BA1, "+RetSqlName("BA3")+" BA3 "

	IIF(cTipoPes == "7",cSql += ", "+RetSqlName("BG9")+" BG9 ",cSql += "")
	cSQL += " WHERE "

	cSQL += " BA1_FILIAL = '"+xFilial("BA1")+"' AND "
	cSQL += " BA3_FILIAL = '"+xFilial("BA3")+"' AND "
	IIF(cTipoPes == "7",cSql += "BG9_FILIAL = '"+xFilial("BG9")+"' AND ",cSql += "")

	If lBloqueia
		cSql += " (BA1_MOTBLO = '' Or '" + dBloqueio + "' < BA1_DATBLO ) AND "
	Endif

	If cTipoPes <> "7"

		cSQL += "    BA1.D_E_L_E_T_ = ' ' "

		cSQL += PLSWHERE(aOpcoes[val(cTipoPes),1],cChave,lChkChk)

		cSQL += " AND BA3.D_E_L_E_T_ = ' ' "

		cSQL += "AND BA3.BA3_FILIAL = BA1.BA1_FILIAL "
		cSQL += "AND BA3.BA3_CODINT = BA1.BA1_CODINT "
		cSQL += "AND BA3.BA3_CODEMP = BA1.BA1_CODEMP "
		cSQL += "AND BA3.BA3_MATRIC = BA1.BA1_MATRIC "
		cSQL += "AND BA3.BA3_CONEMP = BA1.BA1_CONEMP "
		cSQL += "AND BA3.BA3_VERCON = BA1.BA1_VERCON "
		cSQL += "AND BA3.BA3_SUBCON = BA1.BA1_SUBCON "
		cSQL += "AND BA3.BA3_VERSUB = BA1.BA1_VERSUB "
			
		//Cancelamento de Planos, filtra a empresa dos parametros
		If FunName() == "PLSA99B"  
			cSQL += "AND BA1.BA1_CODEMP >= '"+mv_par04+"' " 
			cSQL += "AND BA1.BA1_CODEMP <= '"+mv_par05+"' " 
		EndIf
			
		If FindFunction("PlsRestOp")
			cStrFil := PlsRestOp("U")   // retorna string com filtro para restricao do operador
			If !Empty(cStrFil)
				cSQL += " and "+cStrFil
			EndIf
		EndIf

		cSQL += " ORDER BY BA1_FILIAL,"+StrTran(aOpcoes[Val(cTipoPes),1], "+", ",")
	Else
		If cTipoPes == "7" //Nome Empresa e Nome do Usuario, separado por ; (ponto e virgula)
			For nFor := 1 To Len(AllTrim(cChave))
				If Subs(cChave,nFor,1) == ";" .Or. Subs(cChave,nFor,1) == "/"
					lTroca := .T.
					nFor ++
				Endif

				If ! lTroca
					cNomeEmp += Subs(cChave,nFor,1)
				Else
					cNomeUsr += Subs(cChave,nFor,1)
				Endif
			Next
		Endif

		cSQL += "    BA1.D_E_L_E_T_ = ' ' "
		cSQL += "AND BA3.D_E_L_E_T_ = ' ' "
		cSQL += "AND BG9.D_E_L_E_T_ = ' ' "

		cSQL += "AND BA3.BA3_FILIAL = BA1.BA1_FILIAL "
		cSQL += "AND BA3.BA3_CODINT = BA1.BA1_CODINT "
		cSQL += "AND BA3.BA3_CODEMP = BA1.BA1_CODEMP "
		cSQL += "AND BA3.BA3_MATRIC = BA1.BA1_MATRIC "
		cSQL += "AND BA3.BA3_CONEMP = BA1.BA1_CONEMP "
		cSQL += "AND BA3.BA3_VERCON = BA1.BA1_VERCON "
		cSQL += "AND BA3.BA3_SUBCON = BA1.BA1_SUBCON "
		cSQL += "AND BA3.BA3_VERSUB = BA1.BA1_VERSUB "
		cSQL += "AND BA1.BA1_CODEMP = BG9.BG9_CODIGO "
		
		//Cancelamento de Planos, filtra a empresa dos parametros
		If FunName() == "PLSA99B"  
			cSQL += "AND BA1.BA1_CODEMP >= '"+mv_par04+"' " 
			cSQL += "AND BA1.BA1_CODEMP <= '"+mv_par05+"' " 
		EndIf
		
		If lChkChk
			cSQL += "AND BG9_DESCRI LIKE '%"+cNomeEmp+"%' "
			cSQL += "AND BA1_NOMUSR LIKE '%"+cNomeUsr+"%' "
		Else
			cSQL += "AND BG9_DESCRI LIKE '"+cNomeEmp+"%' "
			cSQL += "AND BA1_NOMUSR LIKE '"+cNomeUsr+"%' "
		Endif

		If FindFunction("PlsRestOp")
			cStrFil := PlsRestOp("U")   // retorna string com filtro para restricao do operador
			If !Empty(cStrFil)
				cSQL += " and "+cStrFil
			EndIf
		EndIf

		cSQL += " ORDER BY BA1_FILIAL,BA1_NREDUZ,BA1_NOMUSR"
	Endif

	PLSQuery(cSQL,"TrbPes")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para alteração das cores da legenda.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ExistBlock('PLSMCORF3')
		lExisteBloc:=.T.
	Endif

	cCodPla := ""

	BI3->( dbSetorder(01) )
	TrbPes->(DbGoTop())
	While ! TrbPes->(Eof())

		If ! PLSVldInt(TrbPes->BA1_CODINT,.T.)
			TrbPes->(DbSkip())
			Loop
		Endif

		// Codigo do Plano.
		cCodPla := IIF(EMPTY(TrbPes->BA1_CODPLA),TrbPes->BA3_CODPLA,TrbPes->BA1_CODPLA)

		// Nome do plano.
		If BI3->( dbSeek(xFilial("BI3") + TrbPes->BA1_CODINT + cCodPla) )
			cNomePla := BI3->BI3_DESCRI
		Else
			cNomePla := " "
		Endif
		
		cCor := PLLegBloq("TrbPes")

		TrbPes->(aadd(aBrowUsr,{If(lExisteBloc,ExecBlock('PLSMCORF3',.f.,.f.,{BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"-"+BA1_TIPREG+"-"+BA1_DIGITO,BA1_MOTBLO,BA1_DATBLO,BA1_DATINC}),cCor),;
									BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"-"+BA1_TIPREG+"-"+BA1_DIGITO,;
									BA1_NOMUSR,;
									Calc_Idade(dDataBase,BA1_DATNAS),;
									AllTrim(BA1_PAI)+" - "+AllTrim(BA1_MAE),;
									BA1_DATINC,;
									BA1_BAIRRO,;
									BA1REG,;
									BA1_MATANT,;
									BA1_NREDUZ,;
									cCodPla,;
									cNomePla,;
									BA1_NOMSOC }))

		TrbPes->(DbSkip())
	Enddo

	TrbPes->(DbCloseArea())
	RestArea(aArea)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Testa resultado da pesquisa...                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aBrowUsr) == 0
		aBrowUsr := aClone(aVetPad)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza browse...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lAuto
		oBrowUsr:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
						// uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
						// Exemplo:
						// 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
						// (via seta para cima ou clique na primeira linha)
						// 2a. Pesquisa: "AV" - Ocorria o erro
		oBrowUsr:SetArray(aBrowUsr)
		oBrowUsr:Refresh()
		oBrowUsr:SetFocus()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fim da Rotina...                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESPROC ³ Autor ³ Michele Tatagiba   ³ Data ³ 23.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de Procedimentos ...                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tulio Cesar ³27.05.02³ xxxx ³ Acertos/Melhorias...                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPESPROC(cCodPad,lAll,cCondSQLAd)
LOCAL nReg          := 0
LOCAL nLin       	:= 1
LOCAL nOpca      	:= 0
LOCAL nSaldo		:= 0
LOCAL nOrdem     	:= 1
LOCAL cChave     	:= Space(40)
LOCAL cTipoPes   	:= ""
LOCAL cCabec		:= ""
LOCAL cCodInt  		:= ""
LOCAL cCodRDA		:= ""
LOCAL cEspec   		:= ""
LOCAL cCodLoc		:= ""
LOCAL cOpeOri		:= ""
LOCAL cCodProduto	:= ""
LOCAL cTipPre  		:= ""
LOCAL cSQL 			:= ""
LOCAL cTipoGuia		:= ""
LOCAL oDlgPesPro    := NIL
LOCAL oTipoPes		:= NIL
LOCAL oSayPro       := NIL
LOCAL oBrowPro		:= NIL
LOCAL oGetChave		:= NIL
LOCAL oChkChk		:= NIL
LOCAL aBrowPro   	:= {}
LOCAL aVetPad    	:= { {"","",0,"",""} }
LOCAL bRefresh   	:= { || If(!Empty(cChave),PLSAPPROPQ(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowPro,aVetPad,oBrowPro,cCodPad,lAll,cCondSQLAd,cCodRDA,cCodInt,cVarRead,cTipoGuia),.T.), If( Empty(aBrowPro[1,1]) .And. !Empty(cChave),.F.,.T. )  }
LOCAL cValid     	:= "{|| Eval(bRefresh) }"
LOCAL bOK        	:= { || If(!Empty(cChave),(nLin := oBrowPro:nAt,nOpca := 1,lOk:=.T.,oDlgPesPro:End()),Help("",1,"PLSMCON")) }
LOCAL bCanc      	:= { || nOpca := 3,oDlgPesPro:End() }
LOCAL aTipoPes   	:= {}
LOCAL lChkChk    	:= .F.
LOCAL lRet		 	:= .F.
LOCAL aButtons   	:= {}
LOCAL dDatAnalise	:= dDataBase
LOCAL dDatPro		:= dDataBase
LOCAL aDadUsr		:= PLSGETUSR()
LOCAL lReembolso	:= .F.
LOCAL aItensPac     := {}
LOCAL cVarRead		:= ReadVar()
Local aCampos := {}
Local aBls    := {}

DEFAULT lAll     	:= .T.
DEFAULT cCondSQLAd  := ""
DEFAULT cCodPad		:= ""

PRIVATE aOpcoes   	:= {}
PRIVATE cCadastro 	:= ""

Aadd(aButtons, {"POSCLI",{|| PLSCPITEM(cCodPad,aBrowPro[oBrowPro:nAt,1],cCabec) },"Consultar composição"})
Aadd(aButtons, {"RELATORIO",{ || BR8->(DbGoTo(aBrowPro[oBrowPro:nAt,3])), PLSEXITDE(BR8->BR8_CODPAD,BR8->BR8_CODPSA) } ,"Exibe em quais Tabelas o procedimento esta cadastrado"})

dbSelectArea("BR8")
//_@CodPad variavel private para que nao precise criar mais consulta sxb
//basta criar esta variavel no fonte como privada e tratar a tabela no valid
//do campo ou pergunte utilize uma consulta que nao tenha M-> por exemplo BDUPLS
If Type("_CodPad_") <> 'U' .And. !Empty(_CodPad_)
	cCodPad	:= _CodPad_
EndIf

//Verifico qual a variavel de cabecalho
If SubStr(ReadVar(),4,3) == "BE2"

	cCabecAux 	:= "BEA"
	cCabec 		:= "BE1"
	
	if (cCabecAux)-> (fieldPos( cCabecAux + "_TIPATE" ) ) > 0 .and. M->&( cCabec + "_TIPATE") == '04'
		cTipoGuia := G_CONSULTA
	endIf
	
ElseIf SubStr(ReadVar(),4,3) == "BEJ"
	
	cCabecAux 	:= "BE4"
	cCabec 		:= "BE4"
	
ElseIf SubStr(ReadVar(),4,3) == "B45"
	
	cCabecAux 	:= "B44"
	cCabec 		:= "B44"
	
ElseIf SubStr(ReadVar(),4,3) == "BD6"
	
	If BCL->BCL_TIPGUI $ "03,05"
		cCabecAux 	:= "BE4"
		cCabec 		:= "BE4"
	Else
		cCabecAux 	:= "BD5"
		cCabec 		:= "BD5"
	EndIf
	
	cTipoGuia		:= BCL->BCL_TIPGUI
	
ElseIf SubStr(ReadVar(),4,3) == "BLY"
		
		cCabecAux 	:= "BLZ"
		cCabec 		:= "BLZ"
		
ElseIf SubStr(ReadVar(),4,3) == "BQV"

	If FunName() $ "PLSA094A/PLSA094B" //Para Intercambio, existe Evolucao de SADT
		cCabecAux 	:= "BEA"
		cCabec 		:= "BE1"
	Else
		cCabecAux 	:= "BE4"
		cCabec 		:= "BE4"
	EndIf
	
EndIf

//Preencho os parametros
If !Empty(cCabec)

	If &(cCabecAux+"->(FieldPos('"+cCabecAux+"_CODOPE'))") > 0
		cCodInt	:= &("M->"+cCabec+"_CODOPE")
	EndIf

	If Empty(cCodInt) .And. &(cCabecAux+"->(FieldPos('"+cCabecAux+"_OPERDA'))") > 0
		cCodInt	:= &("M->"+cCabec+"_OPERDA")
	EndIf

	If Empty(cCodInt) .And. &(cCabecAux+"->(FieldPos('"+cCabecAux+"_CODINT'))") > 0
		cCodInt	:= &("M->"+cCabec+"_CODINT")
	EndIf

	If &(cCabecAux+"->(FieldPos('"+cCabecAux+"_CODRDA'))") > 0
		cCodRDA	:= &("M->"+cCabec+"_CODRDA")
	EndIf
	If &(cCabecAux+"->(FieldPos('"+cCabecAux+"_DATPRO'))") > 0
		dDatPro	:=  &("M->"+cCabec+"_DATPRO")
	EndIf
	
EndIf

If ExistBlock("PLSPESPR")
   lRet := ExecBlock("PLSPESPR",.F.,.F.,{cCodPad})
Else

	aadd(aButtons,{"S4WB007N",{ || BR8->(DbGoTo(aBrowPro[oBrowPro:nAt,3])), BR8->(AxVisual("BR8",BR8->(Recno()),K_Visualizar)) } ,"Visualizar parametrizacoes deste procedimento"})
	aBrowPro := aClone(aVetPad)

	BX8->( DBSetOrder(1) )

	If BX8->(DBSeek(xFilial("BX8")+'PLSPESPROC'))
	   
	   While !BX8->(EOF()) .And. xFilial("BX8")+'PLSPESPROC' == AllTrim(BX8->(BX8_FILIAL+BX8_RDMAKE))
	         aadd(aTipoPes,AllTrim(Str(nOrdem,2))+"-"+BX8->BX8_OPCAO)
	         aadd(aOpcoes,{AllTrim(BX8->BX8_CHAVE)})
	         nOrdem ++
	   BX8->(DBSkip())
	   Enddo
	   
	Else
	
	   aTipoPes := {STR0029,STR0030}//"1-Nome do Procedimento"##"2-Codigo do Procedimento"
	   aadd(aOpcoes,{"BR8_DESCRI"})
	   aadd(aOpcoes,{"BR8_CODPSA"})
	   
	Endif

	DEFINE MSDIALOG oDlgPesPro TITLE STR0045 FROM 008.2,000 TO 030,ndColFin OF GetWndDefault() //"Pesquisa de Procedimentos"

    If Val(GetVersao(.F.)) >= 12

		//Monta objeto que recebera o a chave de pesquisa  ...                     ³
		oGetChave := TGet():New(040,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)

		//Monta Browse...                                                          ³
		oBrowPro := TcBrowse():New( 058, 008, 378, If(cPaisLoc=="BRA",075,090),,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

		ADD COLUMN TO oBrowPro BITMAP DATA { || LoadBitmap( GetResources(), aBrowPro[oBrowPro:nAt,4] ) } TITLE "" WIDTH 015 ALIGN CENTERED NOHILITE

		oBrowPro:AddColumn(TcColumn():New(STR0046,nil,;
		         nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))//"Tabela"
		         oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,5] }
		oBrowPro:AddColumn(TcColumn():New(STR0047,nil,;
		         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))//"Procedimento"
		         oBrowPro:ACOLUMNS[3]:BDATA := { || aBrowPro[oBrowPro:nAt,1] }
		oBrowPro:AddColumn(TcColumn():New(STR0048,nil,;
		         nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil))//"Descricao"
		         oBrowPro:ACOLUMNS[4]:BDATA := { || aBrowPro[oBrowPro:nAt,2] }

		@ 040,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE
	 	@ 040,315 CHECKBOX oChkChk   Var lChkChk PROMPT STR0049 PIXEL SIZE 080, 010 OF oDlgPesPro//"Pesquisar Palavra Chave"

		oBrowPro:SetArray(aBrowPro)
		oBrowPro:BLDBLCLICK := bOK
		oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}

		If cPaisLoc == "BRA"
		   @ 142,013 BITMAP oBmp RESNAME "BR_VERMELHO"   OF oDlgPesPro SIZE 40,20 NOBORDER WHEN .F. PIXEL
		   @ 142,025 Say oSay PROMPT STR0050 SIZE 100,010 OF oDlgPesPro PIXEL//"Nao Pertence ao ROL da ANS"

		   @ 142,120 BITMAP oBmp RESNAME "BR_VERDE"   OF oDlgPesPro SIZE 40,20 NOBORDER WHEN .F. PIXEL
		   @ 142,130 Say oSay PROMPT  STR0051 SIZE 100,010 OF oDlgPesPro PIXEL //"Pertence ao ROL da ANS"
		Endif
		
	Else
	
		//Monta objeto que recebera o a chave de pesquisa  ...                     
		oGetChave := TGet():New(020,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)

			//Monta Browse...                                                          
		oBrowPro := TcBrowse():New( 043, 008, 378, If(cPaisLoc=="BRA",075,090),,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

		ADD COLUMN TO oBrowPro BITMAP DATA { || LoadBitmap( GetResources(), aBrowPro[oBrowPro:nAt,4] ) } TITLE "" WIDTH 015 ALIGN CENTERED NOHILITE

		oBrowPro:AddColumn(TcColumn():New(STR0046,nil,;
				nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))//"Tabela"
				oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,5] }
		oBrowPro:AddColumn(TcColumn():New(STR0047,nil,;
				nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))//"Procedimento"
				oBrowPro:ACOLUMNS[3]:BDATA := { || aBrowPro[oBrowPro:nAt,1] }
		oBrowPro:AddColumn(TcColumn():New(STR0048,nil,;
				nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil))//"Descricao"
				oBrowPro:ACOLUMNS[4]:BDATA := { || aBrowPro[oBrowPro:nAt,2] }

		@ 020,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE
		@ 020,315 CHECKBOX oChkChk   Var lChkChk PROMPT STR0049 PIXEL SIZE 080, 010 OF oDlgPesPro//"Pesquisar Palavra Chave"

		oBrowPro:SetArray(aBrowPro)
		oBrowPro:BLDBLCLICK := bOK
		oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}

		If cPaisLoc == "BRA"
			@ 130,013 BITMAP oBmp RESNAME "BR_VERMELHO"   OF oDlgPesPro SIZE 20,20 NOBORDER WHEN .F. PIXEL
			@ 130,025 Say oSay PROMPT STR0050 SIZE 100,010 OF oDlgPesPro PIXEL//"Nao Pertence ao ROL da ANS"

			@ 130,120 BITMAP oBmp RESNAME "BR_VERDE"   OF oDlgPesPro SIZE 20,20 NOBORDER WHEN .F. PIXEL
			@ 130,130 Say oSay PROMPT  STR0051 SIZE 100,010 OF oDlgPesPro PIXEL //"Pertence ao ROL da ANS"
		endIf
		
	endIf
	
//-- LGPD -------- 
if objCENFUNLGP:isLGPDAt() 
	aCampos := {.F.,"BR8_CODPAD","BR8_CODPSA","BR8_DESCRI"} 
	aBls := objCENFUNLGP:getTcBrw(aCampos) 
	oBrowPro:aObfuscatedCols := aBls 
endif 
//---------------- 
	
	ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || oGetChave:SetFocus(), EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.,aButtons) }) CENTERED
	
	If nOpca == K_OK

		lRet := .T.
		If !Empty( aBrowPro[nLin,1] )

			BR8->( DbGoTo(aBrowPro[nLin,3]) )
			
			//Se desabilita a visualizacao de procedimentos na execucao segue como e no padrao
			If GetNewPar("MV_PLSDTPG",.F.)

				If Type(SubStr(ReadVar(),1,7)+"CODPAD") <> "U"
					&(SubStr(ReadVar(),1,7)+"CODPAD") := BR8->BR8_CODPAD
				EndIf

			Else
				
				If Type("M->BE1_NUMLIB") <> "U"

					BE2->( dbSetOrder(6) )
					If BE2->(dbSeek(xFilial("BE2")+M->BE1_NUMLIB+BR8->(BR8_CODPAD+BR8_CODPSA)))

						While !BE2->(Eof()) .And. BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_CODPAD+BE2_CODPRO) == M->BE1_NUMLIB+BR8->(BR8_CODPAD+BR8_CODPSA)
						 	nSaldo += BE2->BE2_SALDO
							BE2->( DbSkip() )
						EndDo
						M->BE2_QTDSOL := nSaldo
					EndIf

				EndIf
				
			EndIf
			
		EndIf
		
	endIf

endIf
	
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSAPPROPQ ³ Autor ³ Michele Tatagiba   ³ Data ³ 23.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa o procedimento na base de dados ...              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tulio Cesar ³27.05.02³ xxxx ³ Acertos/Melhorias...                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSAPPROPQ(cChave,cTipoPes,lChkChk,aBrowPro,aVetPad,oBrowPro,cCodPad,;
						   lAll,cCondSQLAd,cCodRDA,cCodInt,cVarRead,cTipoGuia,lAuto)

	LOCAL aArea   	:= GetArea()
	LOCAL lRet		:= .F.
	LOCAL cSQL      := ""
	LOCAL cCodPsa	:= ""
	LOCAL cRetBR8 	:= ""
	LOCAL cRetBBM	:= ""
	LOCAL cRetBBN	:= ""
	LOCAL cRetBC0	:= ""
	LOCAL cRetBD7	:= ""
	LOCAL cRetBE2	:= ""
	LOCAL lProcLib	:= IIf(GetNewPar("MV_PLSLIBE","0") == "1" .And. Type("M->BE1_NUMLIB") <> "U",IIf(Empty(M->BE1_NUMLIB),.F.,.T.),.F.)
	LOCAL lPLibOdo	:= IIf(GetNewPar("MV_PLSLIBE","0") == "1" .And. Type("M->B01_NUMLIB") <> "U",IIf(Empty(M->B01_NUMLIB),.F.,.T.),.F.)
	LOCAL lPLibRee	:= IIf(GetNewPar("MV_PLSLIBE","0") == "1" .And. Type("M->B44_NUMLIB") <> "U",IIf(Empty(M->B44_NUMLIB),.F.,.T.),.F.)
	LOCAL lProcInt  := .f.
	LOCAL cPacote	:= GetNewPar("MV_PLSPCTE","")

	DEFAULT cVarRead  := ""
	DEFAULT cTipoGuia := ""
	DEFAULT lAuto := .F.

	If lProcLib
		cAlias := "BE1"
	ElseIf lPLibOdo
		cAlias := "B01"
	ElseIf lPLibRee
		cAlias := "B44"
	EndIf

	If '"' $ cChave .Or. "'" $ cChave
		Aviso( STR0018,STR0019,{ STR0028}, 2 )//"Caracter Invalido"//"Existem caracteres invalidos em sua pesquisa."
		Return(.F.)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Nome das tabelas
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cRetBR8 := BR8->(RetSQLName("BR8"))
	cRetBBM := BBM->(RetSQLName("BBM"))
	cRetBBN := BBN->(RetSQLName("BBN"))
	cRetBC0 := BC0->(RetSQLName("BC0"))
	cRetBD7 := BD7->(RetSQLName("BD7"))
	cRetBE2 := BE2->(RetSQLName("BE2"))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa resultado...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aBrowPro := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Veio de uma liberacao ou foi informado participacao
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lProcLib .Or. lPLibOdo .Or. lPLibRee 

		BR8->( DbSetOrder(1) ) //BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN

		cSQL := "SELECT BE2_CODPAD,BE2_CODPRO FROM "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Grau de participacao 45a
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If lProcLib .And. TYPE("M->BE1_GRAUPA") <> "U" .And. !Empty(M->BE1_GRAUPA) .Or. lPLibRee
			cSQL += RetSQLName("BE2")+", "+RetSQLName("BD7")+" "
		Else
			cSQL += RetSQLName("BE2")+" "
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ be2
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cSQL += "WHERE BE2_FILIAL = '"+xFilial("BE2")+"' AND "
		cSQL += "BE2_OPEMOV = '"+Substr(&("M->"+cAlias+IIf(lProcInt,"_NUMINT","_NUMLIB")),01,4)+"' AND "
		cSQL += "BE2_ANOAUT = '"+Substr(&("M->"+cAlias+IIf(lProcInt,"_NUMINT","_NUMLIB")),05,4)+"' AND "
		cSQL += "BE2_MESAUT = '"+Substr(&("M->"+cAlias+IIf(lProcInt,"_NUMINT","_NUMLIB")),09,2)+"' AND "
		cSQL += "BE2_NUMAUT = '"+Substr(&("M->"+cAlias+IIf(lProcInt,"_NUMINT","_NUMLIB")),11,8)+"' AND "
		cSQL += RetSQLName("BE2")+".D_E_L_E_T_ = ' ' "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ bd7
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If lProcLib .And. TYPE("M->BE1_GRAUPA") <> "U" .And. !Empty(M->BE1_GRAUPA)

			cSQL += "AND BE2_FILIAL = BD7_FILIAL "
			cSQL += "AND BE2_OPEMOV = BD7_CODOPE "
			cSQL += "AND BE2_CODLDP = BD7_CODLDP "
			cSQL += "AND BE2_CODPEG = BD7_CODPEG "
			cSQL += "AND BE2_NUMERO = BD7_NUMERO "
			cSQL += "AND BE2_CODPAD = BD7_CODPAD "
			cSQL += "AND BE2_CODPRO = BD7_CODPRO "
			cSQL += "AND BD7_CODTPA = '" + M->BE1_GRAUPA + "' "
			cSQL += "AND BD7_MOTBLO = ' ' "
			cSQL += "AND BD7_SALDO > 0 AND "
			cSQL += RetSQLName("BD7")+".D_E_L_E_T_ = ' ' "

		ElseIf lPLibRee
			cSQL += "AND BE2_FILIAL = BD7_FILIAL "
			cSQL += "AND BE2_OPEMOV = BD7_CODOPE "
			cSQL += "AND BE2_CODLDP = BD7_CODLDP "
			cSQL += "AND BE2_CODPEG = BD7_CODPEG "
			cSQL += "AND BE2_NUMERO = BD7_NUMERO "
			cSQL += "AND BE2_CODPAD = BD7_CODPAD "
			cSQL += "AND BE2_CODPRO = BD7_CODPRO "
			cSQL += "AND BD7_BLOPAG = '1' AND "
			cSQL += RetSQLName("BD7")+".D_E_L_E_T_ = ' ' "
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Order by
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cSQL += "ORDER BY BE2_FILIAL,BE2_DESPRO"

	Elseif !Empty(cPacote) .and. (cCodPad $ cPacote) .and. SubStr(cVarRead,4,3) <> "BLD"

		cSql := "SELECT BLZ_CODPRO, BLZ_CODPAD FROM "+RetSqlName("BLZ")+","+RetSqlName("BR8")
		cSql += " WHERE BLZ_FILIAL = BR8_FILIAL "
		cSql += "AND BLZ_CODPAD = BR8_CODPAD "
		cSql += "AND BLZ_CODPRO = BR8_CODPSA "
		cSql += "AND BLZ_FILIAL = '"+xFilial("BLZ")+"' "
		cSql += "AND BLZ_CODINT = '"+cCodInt+"' "
		cSql += "AND BLZ_CODPAD = '"+cCodPad+"' "
		cSql += "AND BLZ_CODRDA = '"+cCodRDA+"' "
		cSql += "AND "+RetSqlName("BLZ")+".D_E_L_E_T_ = ' ' "

		cSql += PLSWHERE(aOpcoes[val(cTipoPes),1],cChave,lChkChk)

		cSql += " AND "+RetSqlName("BR8")+".D_E_L_E_T_ = ' ' "

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ BR8
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cSQL := "SELECT BR8_CODROL, BR8_CODPAD, BR8_CODPSA, BR8_DESCRI "
		cSQL += ","+cRetBR8+".R_E_C_N_O_ AS BR8REG "
		cSQL += "  FROM "+cRetBR8
		cSQL += " WHERE BR8_FILIAL = '"+xFilial("BR8")+"' "

		If !Empty(cCodPad)
			cSQL += "   AND BR8_CODPAD = '"+cCodPad+"' "
		EndIf

		cSql += PLSWHERE(aOpcoes[val(cTipoPes),1],cChave,lChkChk)

		If ! lAll
			cSQL += " AND BR8_ANASIN = '1'"
		EndIf

		cSQL += "   AND "+cRetBR8+".D_E_L_E_T_ = ' ' "

		If ! Empty(cCondSQLAd)
			cSQL += cCondSQLAd
		EndIf
		
		cSQL += "ORDER BY BR8_FILIAL,"+StrTran(aOpcoes[Val(cTipoPes),1], "+", ",")
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ executa a query
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbPes",.F.,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ While na area de trabalho
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	TrbPes->( DbGoTop() )
	While !TrbPes->( Eof() )

		// CodPsa
		If (lProcLib .Or. lPLibOdo .Or. lPLibRee )
			
			cCodPsa := TrbPes->BE2_CODPRO

		Elseif !Empty(cPacote) .and. (cCodPad $ cPacote) .and. SubStr(cVarRead,4,3) <> "BLD"
			
			cCodPsa := TrbPes->BLZ_CODPRO

		Else
		
			cCodPsa := TrbPes->BR8_CODPSA

			if cTipoGuia == G_CONSULTA .and. !PLSISCON(TrbPes->BR8_CODPAD,TrbPes->BR8_CODPSA)
				TrbPes->( DbSkip() )
				loop
			endIf

		Endif

		//Se veio da liberacao ou e o 45a posiciona a BR8
		If Ascan(aBrowPro,{ |x| AllTrim(x[1]) == AllTrim(cCodPsa) } ) == 0

			If lProcLib .Or. lPLibOdo .Or. lPLibRee 
			
				BR8->( MsSeek( xFilial("BR8") + TrbPes->(BE2_CODPAD+BE2_CODPRO) ) )

				//³ matriz de retorno
				BR8->( AaDd( aBrowPro,{ BR8_CODPSA,BR8_DESCRI,RECNO(),If(cPaisLOC=="BRA",If(Empty(BR8_CODROL),"BR_VERMELHO","BR_VERDE"),"BR_VERDE" ),BR8_CODPAD } ) )

			Elseif !Empty(cPacote) .and. (cCodPad $ cPacote) .and. SubStr(cVarRead,4,3) <> "BLD"
			
				//³ matriz de retorno
				If BR8->( MsSeek( xFilial("BR8") + TrbPes->(BLZ_CODPAD+BLZ_CODPRO) ) )
					BR8->( AaDd( aBrowPro,{ BR8_CODPSA,BR8_DESCRI,RECNO(),If(cPaisLOC=="BRA",If(Empty(BR8_CODROL),"BR_VERMELHO","BR_VERDE"),"BR_VERDE" ),BR8_CODPAD } ) )
				Endif

			Else
				//³ matriz de retorno
				TrbPes->( AaDd( aBrowPro,{ BR8_CODPSA,BR8_DESCRI,BR8REG,If(cPaisLOC=="BRA",If(Empty(BR8_CODROL),"BR_VERMELHO","BR_VERDE"),"BR_VERDE" ),BR8_CODPAD } ) )
			EndIf
			
		EndIf
		TrbPes->( DbSkip() )
		
	EndDo

	TrbPes->( DbCloseArea() )

	// Ordena a matriz de resultados por Descrição.
	If !Empty(cPacote) .and. (cCodPad $ cPacote)

		aBrowPro := aSort(aBrowPro,,,{|x,y| x[2] < y[2]})

	Endif

	RestArea(aArea)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Testa resultado da pesquisa...                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aBrowPro) == 0
		aBrowPro := aClone(aVetPad)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza browse...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lAuto
		oBrowPro:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
						// uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
						// Exemplo:
						// 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
						// (via seta para cima ou clique na primeira linha)
						// 2a. Pesquisa: "AV" - Ocorria o erro
		oBrowPro:SetArray(aBrowPro)
		oBrowPro:Refresh()
		oBrowPro:SetFocus()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESCRE  ³ Autor ³ Michele Tatagiba   ³ Data ³ 23.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de Credenciados ...                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPESCRE(cCodInt,lBloqueia,cSQLAdic,cFunAadd)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cChave     := Space(40)
LOCAL oDlgPesCre
LOCAL oTipoPes
LOCAL oSayCre
LOCAL nOpca      := 0
LOCAL aBrowCre   := {}
LOCAL aVetPad    := { {"","","","","","",""} }
LOCAL oBrowCre
LOCAL bRefresh   := { || If(!Empty(cChave),PLSAPCREPq(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowCre,aVetPad,oBrowCre,cCodInt,lBloqueia,cSQLAdic,cFunAadd),.T.), If( Empty(aBrowCre[1,2]) .And. !Empty(cChave),.F.,.T. )  }
LOCAL cValid     := "{|| Eval(bRefresh) }"
LOCAL bOK        := { || IF(!Empty(cChave),(nLin := oBrowCre:nAt, nOpca := 1,oDlgPesCre:End()),Help("",1,"PLSMCON")) }
LOCAL bCanc      := { || nOpca := 3,oDlgPesCre:End() }
LOCAL nReg
LOCAL oGetChave
LOCAL aTipoPes   := {}
LOCAL nOrdem     := 1
LOCAL cTipoPes   := ""
LOCAL oChkChk
LOCAL lChkChk    := .F.
LOCAL nLin       := 1
Local aCampos := {}
Local aBls    := {}

DEFAULT lBloqueia:= .F.
DEFAULT cCodInt  := PLSINTPAD()
DEFAULT cFunAadd := ""
PRIVATE aOpcoes  := {}

aBrowCre         := aClone(aVetPad)

cCadastro := Fundesc()

BX8->(DBSetOrder(1))
If BX8->(DBSeek(xFilial("BX8")+'PLSPESCRE'))
	While !BX8->(EOF()) .And. xFilial("BX8")+'PLSPESCRE' == AllTrim(BX8->(BX8_FILIAL+BX8_RDMAKE))
		aadd(aTipoPes,AllTrim(Str(nOrdem,2))+"-"+BX8->BX8_OPCAO)
		aadd(aOpcoes,{AllTrim(BX8->BX8_CHAVE)})
		nOrdem ++

		BX8->(DBSkip())
	Enddo
Else
	aTipoPes := {STR0020,STR0021,STR0022,STR0023,"5-CPF / CNPJ"} //"1-Nome"###"2-Codigo"###"3-Est.CR+Num.CR+Sigla CR"###"4-Codigo da Operadora"

	aadd(aOpcoes,{"BAU_NOME"})
	aadd(aOpcoes,{"BAU_CODIGO"})
	aadd(aOpcoes,{"BAU_ESTCR+BAU_CONREG+BAU_SIGLCR"})
	aadd(aOpcoes,{"BAU_CODOPE"})
	aadd(aOpcoes,{"BAU_CPFCGC"})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPesCre TITLE STR0024 FROM 008.2,000 TO 025,ndColFin OF GetWndDefault() //"Pesquisa de Rede de Atendimento"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Val(GetVersao(.F.)) >= 12//caso a versão seja maior ou igual a 12 altera a linha de início dos folders
	oGetChave := TGet():New(033,103,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesCre,210,008 ,"@!S30",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
Else
	oGetChave := TGet():New(020,103,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesCre,210,008 ,"@!S30",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Browse...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Val(GetVersao(.F.)) >= 12//caso a versão seja maior ou igual a 12 altera a linha de início dos folders
	oBrowCre := TcBrowse():New( 050, 008, 378, 075,,,, oDlgPesCre,,,,,,,,,,,, .F.,, .T.,, .F., )
Else
	oBrowCre := TcBrowse():New( 043, 008, 378, 075,,,, oDlgPesCre,,,,,,,,,,,, .F.,, .T.,, .F., )
Endif

oBrowCre:AddColumn(TcColumn():New("",nil,;
         nil,nil,nil,nil,015,.T.,.F.,nil,nil,nil,.T.,nil))
         oBrowCre:ACOLUMNS[1]:BDATA     := { || IF(Empty(aBrowCre[oBrowCre:nAt,1]),LoadBitmap( GetResources(), "ENABLE" ),LoadBitmap( GetResources(), "DISABLE" )) }
oBrowCre:AddColumn(TcColumn():New(STR0025,nil,; //"Codigo"
         nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowCre:ACOLUMNS[2]:BDATA     := { || aBrowCre[oBrowCre:nAt,2] }
oBrowCre:AddColumn(TcColumn():New(STR0011,nil,; //"Nome"
         nil,nil,nil,nil,120,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowCre:ACOLUMNS[3]:BDATA     := { || aBrowCre[oBrowCre:nAt,3] }
oBrowCre:AddColumn(TcColumn():New(STR0026,nil,; //"Est.CR+Num.CR+Sigla CR"
         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowCre:ACOLUMNS[4]:BDATA     := { || aBrowCre[oBrowCre:nAt,4] }
oBrowCre:AddColumn(TcColumn():New(STR0015,nil,; //"Data Inclusao"
         nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowCre:ACOLUMNS[5]:BDATA     := { || aBrowCre[oBrowCre:nAt,5] }
oBrowCre:AddColumn(TcColumn():New(STR0027,nil,; //"Data Exclusao"
         nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowCre:ACOLUMNS[6]:BDATA     := { || aBrowCre[oBrowCre:nAt,6] }

If Val(GetVersao(.F.)) >= 12//caso a versão seja maior ou igual a 12 altera a linha de início dos folders
	@ 033,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 090,010 OF oDlgPesCre PIXEL COLOR CLR_HBLUE
	@ 033,319 CHECKBOX oChkChk   Var lChkChk PROMPT STR0017 PIXEL SIZE 080, 010 OF oDlgPesCre //"Pesquisar Palavra Chave"
Else
	@ 020,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 090,010 OF oDlgPesCre PIXEL COLOR CLR_HBLUE
	@ 020,319 CHECKBOX oChkChk   Var lChkChk PROMPT STR0017 PIXEL SIZE 080, 010 OF oDlgPesCre //"Pesquisar Palavra Chave"
Endif

oBrowCre:SetArray(aBrowCre)
oBrowCre:BLDBLCLICK := bOK
oGetChave:SetFocus()

//-- LGPD -------- 
if objCENFUNLGP:isLGPDAt() 
	aCampos := {.F.,"BAU_CODIGO","BAU_NOME","BAU_ESTCR+BAU_CONREG+BAU_SIGLCR","BAU_DTINCL","BAU_DTEXCL"} 
	aBls := objCENFUNLGP:getTcBrw(aCampos) 
	oBrowCre:aObfuscatedCols := aBls 
endif 
//---------------- 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgPesCre ON INIT Eval({ || oGetChave:SetFocus(), EnChoiceBar(oDlgPesCre,bOK,bCanc,.F.) })

If nOpca == K_OK
   If !Empty(aBrowCre[nLin,2])
      BAU->(DbGoTo(aBrowCre[nLin,7]))
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da Funcao...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nOpca==K_OK)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300PQ  ³ Autor ³ Tulio Cesar        ³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa a credenciados na base de dados...               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSAPCrePq(cChave,cTipoPes,lChkChk,aBrowCre,aVetPad,oBrowCre,cCodInt,lBloqueia,cSQLAdic,cFunAadd,lAuto)

	Local aArea      := GetArea()
	LOCAL cSQL  	 := ""
	LOCAL cSqlOrd  	 := ""
	LOCAL cRetBAU	 := ""
	LOCAL cRetBAW    := ""
	LOCAL cRetBC1    := ""
	LOCAL lAdd       := .T.
	LOCAL cCdPfSo    := ""

	DEFAULT cFunAadd := ""
	DEFAULT lAuto := .F.

	cRetBAU := BAU->(RetSQLName("BAU"))
	cRetBAW := BAW->(RetSQLName("BAW"))
	cRetBC1 := BC1->(RetSQLName("BC1"))

	If '"' $ cChave .Or.  "'" $ cChave
		Aviso( STR0018,STR0019,{ STR0028}, 2 )//"Caracter Invalido"//"Existem caracteres invalidos em sua pesquisa."
		Return(.F.)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa resultado...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aBrowCre := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua busca...                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSqlSel := "SELECT  BAU_FILIAL, BAW_CODIGO, BAW_CODINT, BAU_ESTCR, BAU_CONREG, BAU_SIGLCR, BAU_CODIGO, "
	cSqlSel += " 	   	 BAU_NOME, BAU_CODBLO, BAU_DTINCL, BAU_DTEXCL, "+cRetBAU+".R_E_C_N_O_ AS BAUREG "
	If !Empty(&cFunAadd)
		cSqlFrm := "  FROM "+cRetBAU+", "+cRetBAW+", "+cRetBC1
		cSqlWhr := " WHERE BAU_FILIAL = BAW_FILIAL "
		cSqlWhr += "   AND BC1_FILIAL = BAW_FILIAL "
		cSqlWhr += "   AND BAW_CODIGO = BAU_CODIGO "
		cSqlWhr += "   AND BC1_CODIGO = BAU_CODIGO "
		cSqlWhr += "   AND BAW_CODINT = '"+cCodInt+"'"
		cSqlWhr += "   AND BAU_FILIAL = '"+xFilial("BAU")+"'"
		cSqlWhr += "   AND "+cRetBAU+".D_E_L_E_T_ = ' ' "
		cSqlWhr += "   AND "+cRetBAW+".D_E_L_E_T_ = ' ' "
		cSqlWhr += "   AND "+cRetBC1+".D_E_L_E_T_ = ' ' "
	Else
		cSqlFrm := "  FROM "+cRetBAU+", "+cRetBAW
		cSqlWhr := " WHERE BAU_FILIAL = BAW_FILIAL "
		cSqlWhr += "   AND BAW_CODIGO = BAU_CODIGO "
		cSqlWhr += "   AND BAW_CODINT = '"+cCodInt+"' "
		cSqlWhr += "   AND BAU_FILIAL = '"+xFilial("BAU")+"'"
		cSqlWhr += "   AND "+cRetBAU+".D_E_L_E_T_ = ' ' "
		cSqlWhr += "   AND "+cRetBAW+".D_E_L_E_T_ = ' ' "
	Endif

	cSqlWhr += PLSWHERE(aOpcoes[val(cTipoPes),1],cChave,lChkChk)

	If lBloqueia
		cSqlWhr += " AND BAU_CODBLO = '' "
	Endif

	If ! Empty(cSQLAdic)
		cSqlWhr += " AND ("+cSQLAdic+") "
	Endif

	If !Empty(&cFunAadd)
		cCdPfSo := &cFunAadd
		cSqlWhr    += " AND BC1_CODPRF = '"+ alltrim(cCdPfSo) +"' "
	Endif


	cSqlGrp := "GROUP BY BAU_FILIAL,BAW_CODIGO, BAW_CODINT, BAU_ESTCR,  BAU_CONREG, BAU_SIGLCR, BAU_CODIGO, BAU_NOME, "
	cSqlGrp += "BAU_CODBLO, BAU_DTINCL, BAU_DTEXCL, "+cRetBAU+".R_E_C_N_O_ "

	If ! aOpcoes[Val(cTipoPes),1] $ SubStr(cSQL, At("GROUP BY", cSQL))

		cSqlGrp += ", " + aOpcoes[Val(cTipoPes),1] + " "

	EndIf

	cSqlOrd := "ORDER BY BAU_FILIAL,"+StrTran(aOpcoes[Val(cTipoPes),1], "+", ",")

	If ExistBlock("PLPESRDA")
		cSQL := ExecBlock("PLPESRDA",.F.,.F.,{cSqlSel,cSqlFrm,cSqlWhr,cSqlGrp,cSqlOrd})
	Else
		cSQL := cSqlSel + cSqlFrm + cSqlWhr + cSqlGrp
	EndIf

	PLSQuery(cSQL,"TrbPes")

	TrbPes->(DbGoTop())
	While ! TrbPes->(Eof())
		lAdd := .T.
		TrbPes->(aadd(aBrowCre,{BAU_CODBLO,BAU_CODIGO,BAU_NOME,AllTrim(BAU_ESTCR)+"-"+AllTrim(BAU_CONREG)+"-"+AllTrim(BAU_SIGLCR),BAU_DTINCL,BAU_DTEXCL,BAUREG}))
		TrbPes->(DbSkip())
	Enddo

	TrbPes->(DbCloseArea())
	RestArea(aArea)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Testa resultado da pesquisa...                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aBrowCre) == 0
		aBrowCre := aClone(aVetPad)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza browse...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lAuto
		oBrowCre:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
						// uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
						// Exemplo:
						// 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
						// (via seta para cima ou clique na primeira linha)
						// 2a. Pesquisa: "AV" - Ocorria o erro
		oBrowCre:SetArray(aBrowCre)
		oBrowCre:Refresh()
		oBrowCre:SetFocus()
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESPFS  ³ Autor ³ Michele Tatagiba   ³ Data ³ 24.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de Profissionais Saude ...              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPESPFS(cSigla, cUF, cVar)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cChave     := Space(40)
LOCAL oDlgPesPfs
LOCAL oTipoPes
LOCAL oSayPfs
LOCAL nOpca      := 0
LOCAL aBrowPfs   := {}
LOCAL aVetPad    := { {"","","","",""} }
LOCAL oBrowPfs
LOCAL bRefresh   := { || If(!Empty(cChave),PLSAPPFSPq(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowPfs,aVetPad,oBrowPfs,cSigla,cUF),.T.), If( Empty(aBrowPfs[1,2]) .And. !Empty(cChave),.F.,.T. ) }
LOCAL cValid     := "{|| Eval(bRefresh) }"
LOCAL bOK        := { || IF(!Empty(cChave),(nLin := oBrowPfs:nAt, nOpca := 1,oDlgPesPfs:End()),Help("",1,"PLSMCON")) }
LOCAL bCanc      := { || nOpca := 3,oDlgPesPfs:End() }
LOCAL nReg
LOCAL oGetChave
LOCAL aTipoPes   := {}
LOCAL nOrdem     := 1
LOCAL cTipoPes   := ""
LOCAL oChkChk
LOCAL lChkChk   := .F.
LOCAL nLin      := 1
LOCAL aButtons  := { {"POSCLI",{|| FWExecView("Profissional", 'PLSA960', 3)},STR0052} } //"Incluir novo Profissional de Saude"
LOCAL aBtAux	:= {}
Local aCampos 	:= {}
Local aBls    	:= {}
Local cCadAux	:= ""
Local cSiglaMem := ""
Local aSigla := {} 

Default cCadastro := ""
Default cVar := ''

PRIVATE aOpcoes := {}

aBrowPfs := aClone(aVetPad)
cCadAux	:= cCadastro

If ExistBlock("PLSBTPFS")
	aBtAux := Execblock("PLSBTPFS",.F.,.F.,{aButtons})
	If Valtype(aBtAux) == "A"
		aButtons := aClone(aBtAux)
	Endif
Endif

BX8->(DBSetOrder(1))
If BX8->(DBSeek(xFilial("BX8")+'PLSPESPFS'))
   While !BX8->(EOF()) .And. xFilial("BX8")+'PLSPESPFS' == AllTrim(BX8->(BX8_FILIAL+BX8_RDMAKE))
         aadd(aTipoPes,AllTrim(Str(nOrdem,2))+"-"+BX8->BX8_OPCAO)
         aadd(aOpcoes,{AllTrim(BX8->BX8_CHAVE)})
         nOrdem ++
   BX8->(DBSkip())
   Enddo
Else
   aTipoPes := {"1-Nome","2-Codigo","3-Est.CR+Num.CR+Sigla CR"}

   aadd(aOpcoes,{"BB0_NOME"})
   aadd(aOpcoes,{"BB0_CODIGO"})
   aadd(aOpcoes,{"BB0_ESTADO+BB0_NUMCR+BB0_CODSIG"})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPesPfs TITLE STR0053 FROM 008.2,000 TO 025,ndColFin OF GetWndDefault()//"Pesquisa de Profissionais de Saude"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Val(GetVersao(.F.)) >= 12//caso a versão seja maior ou igual a 12 altera a linha de início dos folders
	oGetChave := TGet():New(033,100,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPfs,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
Else
	oGetChave := TGet():New(020,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPfs,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Browse...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Val(GetVersao(.F.)) >= 12//caso a versão seja maior ou igual a 12 altera a linha de início dos folders
	oBrowPfs := TcBrowse():New( 050, 008, 378, 075,,,, oDlgPesPfs,,,,,,,,,,,, .F.,, .T.,, .F., )
Else
	oBrowPfs := TcBrowse():New( 043, 008, 378, 075,,,, oDlgPesPfs,,,,,,,,,,,, .F.,, .T.,, .F., )
Endif

oBrowPfs:AddColumn(TcColumn():New("",nil,;
         nil,nil,nil,nil,015,.T.,.F.,nil,nil,nil,.T.,nil))
         oBrowPfs:ACOLUMNS[1]:BDATA     :={ || IF(Empty(aBrowPfs[oBrowPfs:nAt,1]),LoadBitmap( GetResources(), "ENABLE" ),LoadBitmap( GetResources(), "DISABLE" )) }
oBrowPfs:AddColumn(TcColumn():New(STR0054,nil,;
         nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil)) //"Codigo"
         oBrowPfs:ACOLUMNS[2]:BDATA     := { || aBrowPfs[oBrowPfs:nAt,2] }
oBrowPfs:AddColumn(TcColumn():New(STR0055,nil,;
         nil,nil,nil,nil,120,.F.,.F.,nil,nil,nil,.F.,nil))//"Nome"
         oBrowPfs:ACOLUMNS[3]:BDATA     := { || aBrowPfs[oBrowPfs:nAt,3] }
oBrowPfs:AddColumn(TcColumn():New(STR0056,nil,;
         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil)) //"Est.CR+Num.CR+Sigla CR"
         oBrowPfs:ACOLUMNS[4]:BDATA     := { || aBrowPfs[oBrowPfs:nAt,4] }

oBrowPfs:AddColumn(TcColumn():New(STR0078,nil,;
         nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil)) //"Estado"
         oBrowPfs:ACOLUMNS[5]:BDATA     := { || aBrowPfs[oBrowPfs:nAt,5] }
If Val(GetVersao(.F.)) >= 12//caso a versão seja maior ou igual a 12 altera a linha de início dos folders
	@ 033,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 090,010 OF oDlgPesPfs PIXEL COLOR CLR_HBLUE
	@ 033,315 CHECKBOX oChkChk   Var lChkChk PROMPT STR0049 PIXEL SIZE 080, 010 OF oDlgPesPfs //"Pesquisar Palavra Chave"
Else
	@ 020,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPfs PIXEL COLOR CLR_HBLUE
	@ 020,315 CHECKBOX oChkChk   Var lChkChk PROMPT STR0049 PIXEL SIZE 080, 010 OF oDlgPesPfs //"Pesquisar Palavra Chave"
Endif
oBrowPfs:SetArray(aBrowPfs)
oBrowPfs:BLDBLCLICK := bOK
oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}
oGetChave:SetFocus()

//-- LGPD -------- 
if objCENFUNLGP:isLGPDAt() 
	aCampos := {.F.,"BB0_CODIGO","BB0_NOME","BB0_ESTADO+BB0_NUMCR+BB0_CODSIG","BB0_ESTADO" } 
	aBls := objCENFUNLGP:getTcBrw(aCampos) 
	oBrowPfs:aObfuscatedCols := aBls 
endif 
//----------------

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgPesPfs ON INIT Eval({ || oGetChave:SetFocus(), EnChoiceBar(oDlgPesPfs,bOK,bCanc,.F.,aButtons) })

cCadastro := cCadAux

If nOpca == K_OK
   If nLin <= Len(aBrowPfs) .And. nLin > 0
      BB0->(DbGoTo(aBrowPfs[nLin,6]))

		//cVar recebe o nome da variavel na memoria
		//Ex: M->BOW_REGSOL, M->BE1_REGEXE, etc...
		If !empty(cVar) .AND. "M->" $ cVar
			//Vamos verificar a Sigla da variavel cVar
			//Ex: BOW, BE1, etc...
			//aSigla é uma variavel temporaria, que vai receber os dados da string no formato de array
			If EMPTY(cSiglaMem)
				//Vamos quebrar a string com o caracter "_" o Array aSigla[1] ficara M->BOW
				aSigla := StrTokArr(cVar, '_')
				//vamos quebrar a string com o caracter "->" o Array aSigla[2] ficara BOW
				aSigla := StrTokArr(aSigla[1], '->')
				cSiglaMem := aSigla[2]
			EndIf
			
			//Vamos procurar pela pelavra REGEXE e REGSOL na variavel de memoria 
			//Se achar, vamos atribuir a variavel de memoria M->BE1_ESTEXE e M->BE1_ESTSOL a UF do usuario
			If "REGEXE" $ cVar .AND. ValType(&("M->"+cSiglaMem+"_ESTEXE")) == "C"
				&("M->"+cSiglaMem+"_ESTEXE") := aBrowPfs[nLin,5]
			elseIf "REGSOL" $ cVar .AND. ValType(&("M->"+cSiglaMem+"_ESTSOL")) == "C"
				&("M->"+cSiglaMem+"_ESTSOL") := aBrowPfs[nLin,5]
			EndIf

			If "B45_CRM" $ cVar .AND. (ValType(&("M->"+cSiglaMem+"_EST")) == "C" .OR. ValType(&("M->"+cSiglaMem+"_ESTSOL")) == "C")
				&("M->"+cSiglaMem+"_EST") := aBrowPfs[nLin,5]
				&("M->"+cSiglaMem+"_ESTSOL") := aBrowPfs[nLin,5]
			EndIf

			If "BOW_CONREG" $ cVar .AND. (ValType(&("M->"+cSiglaMem+"_ESTEXE")) == "C" .OR. ValType(&("M->"+cSiglaMem+"_ESTSOL")) == "C")
				&("M->"+cSiglaMem+"_ESTEXE") := aBrowPfs[nLin,5]
				&("M->"+cSiglaMem+"_ESTSOL") := aBrowPfs[nLin,5]
			EndIf
		EndIf
		Iif(ValType("M->BE1_ESTEXE") == "C" .AND. !empty(M->BE1_ESTEXE), M->BE1_ESTEXE := aBrowPfs[nLin,5], '') 
			
   Endif
   	if type("M->B4B_UFCONS") <> "U"
		M->B4B_UFCONS := BB0->BB0_ESTADO
	endif
	if type("M->B4B_SICONS") <> "U"
		M->B4B_SICONS :=  BB0->BB0_CODSIG
	endif
	if type("M->B4B_CGC") <> "U"
		M->B4B_CGC :=  BB0->BB0_CGC
	endif
	if type("M->B01_SIGLA") <> "U"                                            
	    M->B01_SIGLA :=  BB0->BB0_CODSIG                                     
	endif
	
	// Será necessario a macro p que encontre o Profissional de acordo com a SIGLA.
	if type("M->BE1_SIGLA") <> "U"                                           
	    	M->BE1_SIGLA :=  BB0->BB0_CODSIG                                     
	endif
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada que vai me permitir alterar o conteudo dos campos       ³
	//| BE1_SIGLA,BE1_ESTSOL,BE4_SIGLA_BE4_ESTSOL,baseado no codigo do BB0 que	 |
	//| eu escolhi,exemplo do uso do pto de entrada								 |
	//| user function PLPESPFS1                                                  |
	//|	if type("M->BE1_ESTSOL") <> "U"											 |
	//|		M->BE1_ESTSOL := BB0->BB0_ESTADO                                     |
	//|	endif                                                                    |
	//|	if type("M->BE1_SIGLA") <> "U"                                           |
	//|		M->BE1_SIGLA :=  BB0->BB0_CODSIG                                     |
	//|	endif                                                                    |
	//|	if type("M->BE4_ESTSOL") <> "U"                                          |
	//|		M->BE4_ESTSOL := BB0->BB0_ESTADO                                     |
	//|	endif                                                                    |
	//|	if type("M->BE4_SIGLA") <> "U"                                           |
	//|		M->BE4_SIGLA := BB0->BB0_CODSIG                                      |
	//|	endif                                                                    |
	//|	return                                                                   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	If Existblock("PLPESPFS1")
		ExecBlock("PLPESPFS1",.F.,.F.)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da Funcao...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nOpca==K_OK)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSAPPFSPq ³ Autor ³ Michele Tatagiba   ³ Data ³ 24.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa a Profissionais de Saude na base de dados...     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSAPPFSPq(cChave,cTipoPes,lChkChk,aBrowPfs,aVetPad,oBrowPfs,cSigla, cUF,lAuto)

	Local aArea   := GetArea()
	LOCAL cSQL
	LOCAL cRetBB0
	LOCAL cSqlOrd := ""

	Default lAuto := .F.

	If '"' $ cChave .Or. ("'" $ cChave)
		Aviso( STR0018,STR0019,{ STR0028}, 2 )//"Caracter Invalido"//"Existem caracteres invalidos em sua pesquisa."
		Return(.F.)
	Endif

	cRetBB0 := BB0->(RetSQLName("BB0"))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa resultado...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aBrowPfs := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua busca...                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSqlSel := "SELECT BB0_CODIGO, BB0_NOME , BB0_ESTADO ,BB0_NUMCR ,BB0_CODSIG, "
	cSqlSel += cRetBB0+".R_E_C_N_O_ AS BB0REG,BB0_CODBLO "
	cSqlFrm := " FROM "+cRetBB0+" "
	cSqlWhr := " WHERE "

	If !EMPTY(cSigla)
		cSqlWhr += " BB0_CODSIG = '" + cSigla + "' AND "
	EndIf

	If !EMPTY(cUF)
		cSqlWhr += " BB0_ESTADO = '" + cUF + "' AND "
	EndIf

	cSqlWhr += "BB0_FILIAL = '"+xFilial("BB0")+"' AND "
	cSqlWhr += cRetBB0+".D_E_L_E_T_ = ' ' "

	cSqlWhr += PLSWHERE(aOpcoes[val(cTipoPes),1],cChave,lChkChk)

	cSqlOrd := "ORDER BY BB0_FILIAL,"+StrTran(aOpcoes[Val(cTipoPes),1], "+", ",")

	If ExistBlock("PLPESPRF")
		cSQL := ExecBlock("PLPESPRF",.F.,.F.,{cSqlSel,cSqlWhr,cSqlFrm,cSqlOrd})
	Else
		cSQL := cSqlSel + cSqlFrm + cSqlWhr + cSqlOrd
	EndIf

	PLSQuery(cSQL,"TrbPes")

	TrbPes->(DbGoTop())
	While ! TrbPes->(Eof())
		TrbPes->(aadd(aBrowPfs,{BB0_CODBLO,BB0_CODIGO,BB0_NOME,AllTrim(BB0_ESTADO)+"-"+;
		AllTrim(BB0_NUMCR)+"-"+AllTrim(BB0_CODSIG),TrbPes->BB0_ESTADO,BB0REG}))
		TrbPes->(DbSkip())
	Enddo

	TrbPes->(DbCloseArea())
	RestArea(aArea)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Testa resultado da pesquisa...                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aBrowPfs) == 0
		aBrowPfs := aClone(aVetPad)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza browse...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lAuto
		oBrowPfs:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
						// uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
						// Exemplo:
						// 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
						// (via seta para cima ou clique na primeira linha)
						// 2a. Pesquisa: "AV" - Ocorria o erro
		oBrowPfs:SetArray(aBrowPfs)
		oBrowPfs:Refresh()
		oBrowPfs:SetFocus()
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESTDE  ³ Autor ³ Michele Tatagiba   ³ Data ³ 17.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de Procedimentos na TDE                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPESTDE(cCodTab,cCodInt)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cChave     := Space(40)
LOCAL oDlgPesPro
LOCAL nLin       := 1
LOCAL oTipoPes
LOCAL oSayPro
LOCAL nOpca      := 0
LOCAL aBrowPro   := {}
LOCAL aVetPad    := { {"","",""} }
LOCAL oBrowPro
LOCAL bRefresh   := { || If(!Empty(cChave),PLSAPPROTD(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowPro,aVetPad,oBrowPro,cCodTab,cCodInt),.T.), If( Empty(aBrowPro[1,1]) .And. !Empty(cChave),.F.,.T. )  }
LOCAL cValid     := "{|| Eval(bRefresh) }"
LOCAL bOK        := { || If(!Empty(cChave),(nLin := oBrowPro:nAt,nOpca := 1,lOk:=.T.,oDlgPesPro:End()),Help("",1,"PLSMCON")) }
LOCAL bCanc      := { || nOpca := 3,oDlgPesPro:End() }
LOCAL nReg
LOCAL oGetChave
LOCAL aTipoPes   := {}
LOCAL nOrdem     := 1
LOCAL cTipoPes   := ""
LOCAL oChkChk
LOCAL lChkChk    := .T.
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
LOCAL nX,nY,nW,nH := 0
Local aCampos := {}
Local aBls    := {}
PRIVATE aOpcoes  := {}

aBrowPro         := aClone(aVetPad)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o Tamanho da Tela ...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 20, .t., .f. } )
AAdd( aObjects, { 100, 100, .t., .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

nX := aPosObj[1][1] + 17		//Valor Original = 33
nY := aPosObj[1][2]			//Valor Original = 03
nW := aPosObj[2][4] + 71		//Valor Original = 309
nH := aPosObj[1][3] + 22 	//Valor Original = 53

//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

BX8->(DBSetOrder(1))
If BX8->(DBSeek(xFilial("BX8")+'PLSPESTES'))
   While !BX8->(EOF()) .And. xFilial("BX8")+'PLSPESTES' == AllTrim(BX8->(BX8_FILIAL+BX8_RDMAKE))
         aadd(aTipoPes,AllTrim(Str(nOrdem,2))+"-"+BX8->BX8_OPCAO)
         aadd(aOpcoes,{AllTrim(BX8->BX8_CHAVE)})
         nOrdem ++
   BX8->(DBSkip())
   Enddo
Else
   aTipoPes := {STR0029,STR0030} //"1-Nome do Procedimento"###"2-Codigo do Procedimento"

   aadd(aOpcoes,{"BA8_DESCRI"})
   aadd(aOpcoes,{"BA8_CODPRO"})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPesPro TITLE STR0031 FROM 008.2,000 TO 025,ndColFin OF GetWndDefault() //"Pesquisa de Procedimentos na TDE"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetChave := TGet():New(nx - 15, nH + 20,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Browse...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowPro := TcBrowse():New( nX, nY, nW+80, nH,,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrowPro:AddColumn(TcColumn():New(STR0032,nil,; //"Procedimento"
         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowPro:ACOLUMNS[1]:BDATA     := { || aBrowPro[oBrowPro:nAt,1] }
oBrowPro:AddColumn(TcColumn():New(STR0033,nil,; //"Nivel"
         nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowPro:ACOLUMNS[2]:BDATA     := { || aBrowPro[oBrowPro:nAt,2] }
oBrowPro:AddColumn(TcColumn():New(STR0034,nil,; //"Descricao"
         nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowPro:ACOLUMNS[3]:BDATA     := { || aBrowPro[oBrowPro:nAt,3] }

@ nX - 15,nY COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 090,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE
@ nX - 15,nW - 2 CHECKBOX oChkChk   Var lChkChk PROMPT STR0017 PIXEL SIZE 080, 010 OF oDlgPesPro //"Pesquisar Palavra Chave"

oBrowPro:SetArray(aBrowPro)
oBrowPro:BLDBLCLICK := bOK
oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}
oGetChave:SetFocus()

//-- LGPD -------- 
if objCENFUNLGP:isLGPDAt() 
	aCampos := {"BA8_CODPRO","BA8_NIVEL","BA8_DESCRI"} 
	aBls := objCENFUNLGP:getTcBrw(aCampos) 
	oBrowPro:aObfuscatedCols := aBls 
endif 
//----------------

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || oGetChave:SetFocus(), EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.) })

If nOpca == K_OK
   If !Empty(aBrowPro[nLin,1])
      BA8->(DbGoTo(aBrowPro[nLin,4]))
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da Funcao...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nOpca == K_OK)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSAPPROTD ³ Autor ³ Michele Tatagiba   ³ Data ³ 17.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa o procedimento na base de dados ...              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSAPPROTD(cChave,cTipoPes,lChkChk,aBrowPro,aVetPad,oBrowPro,cCodTab,cCodInt,lAuto)

	Local aArea := GetArea()
	LOCAL cSQL := ""
	LOCAL cRetBA8 := ""

	Default lAuto := .F.

	If '"' $ cChave .Or.  "'" $ cChave
		Aviso( STR0018,STR0019,{ STR0028}, 2 )//"Caracter Invalido"//"Existem caracteres invalidos em sua pesquisa."
		Return(.F.)
	Endif

	cRetBA8 := BA8->(RetSQLName("BA8"))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa resultado...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aBrowPro := {}

	cSQL := "SELECT BA8_CODTAB, BA8_CODPRO, BA8_DESCRI ,BA8_NIVEL "
	cSQL += ","+cRetBA8+".R_E_C_N_O_ AS BA8REG "
	cSQL += "  FROM "+cRetBA8
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Prepara a consulta                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL += " WHERE BA8_FILIAL = '"+xFilial("BA8")+"' AND BA8_CODTAB = '"+cCodInt+cCodTab+"'  "
	cSQL += "   AND "+cRetBA8+".D_E_L_E_T_ = ' ' "

	cSQL += PLSWHERE(aOpcoes[val(cTipoPes),1],cChave,lChkChk)

	cSQL += "ORDER BY BA8_FILIAL,"+StrTran(aOpcoes[Val(cTipoPes),1], "+", ",")

	PLSQuery(cSQL,"TrbPes")

	TrbPes->(DbGoTop())
	While ! TrbPes->(Eof())
		TrbPes->(aadd(aBrowPro,{BA8_CODPRO,BA8_NIVEL,BA8_DESCRI,BA8REG}))
		TrbPes->(DbSkip())
	Enddo

	TrbPes->(DbCloseArea())
	RestArea(aArea)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Testa resultado da pesquisa...                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aBrowPro) == 0
		aBrowPro := aClone(aVetPad)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza browse...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lAuto
		oBrowPro:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
						// uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
						// Exemplo:
						// 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
						// (via seta para cima ou clique na primeira linha)
						// 2a. Pesquisa: "AV" - Ocorria o erro
		oBrowPro:SetArray(aBrowPro)
		oBrowPro:Refresh()
		oBrowPro:SetFocus()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fim da Rotina...                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESUSER ³ Autor ³ Michele Tatagiba   ³ Data ³ 06.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de Usuarios do protheus                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPESUSRC(cCampo,cNomCampo)
LOCAL nLin       := 1
LOCAL nOpca      := 0
LOCAL nReg       := 0
LOCAL aBrowUsr   := {}
LOCAL aVetPad    := { {"","",""} }
LOCAL oBrowUsr	 := NIL
LOCAL oDlgPesUsr := NIL
LOCAL oSayUsr    := NIL
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
LOCAL nX,nY,nW,nH := 0
LOCAL bRefresh   := { || PLSAPUSER(aBrowUsr,aVetPad,oBrowUsr)}
LOCAL bOK        := { || nLin := oBrowUsr:nAt,nOpca := 1,lOk:=.T.,oDlgPesUsr:End() }
LOCAL bCanc      := { || nOpca := 3,oDlgPesUsr:End() }
DEFAULT cCampo	 := ""
DEFAULT cNomCampo:= ""

aBrowUsr         := aClone(aVetPad)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPesUsr TITLE STR0042 FROM 008.2,005 TO 025,090 OF GetWndDefault() //"Pesquisa dos Usuarios do PROTHEUS"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o Tamanho da Tela ...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 20, .t., .f. } )
AAdd( aObjects, { 100, 100, .t., .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

nX := aPosObj[1][1]			//Valor Original = 33
nY := aPosObj[1][2]			//Valor Original = 03
nW := aPosObj[2][4] + 25		//Valor Original = 309
nH := aPosObj[1][3] + 40		//Valor Original = 53

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Browse...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


oBrowUsr := TcBrowse():New(nX,nY,nW,nH,,,, oDlgPesUsr,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrowUsr:AddColumn(TcColumn():New(STR0054,nil,;
         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))  //"Codigo"
         oBrowUsr:ACOLUMNS[1]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,1] }
oBrowUsr:AddColumn(TcColumn():New(STR0055,nil,;
         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))//"Nome"
         oBrowUsr:ACOLUMNS[2]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,2] }
oBrowUsr:AddColumn(TcColumn():New(STR0043,nil,;
         nil,nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil)) //"Nome Completo"
         oBrowUsr:ACOLUMNS[3]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,3] }

oBrowUsr:SetArray(aBrowUsr)
oBrowUsr:BLDBLCLICK := bOK
Eval(bRefresh)

//-- LGPD -------- 
//TcBrowse não tratado pois as informações do aBrowUsr são carregados pela função do frame FWSFALLUSERS(), em PLSAPUSER().
//----------------

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgPesUsr ON INIT Eval({ || EnChoiceBar(oDlgPesUsr,bOK,bCanc,.F.) })

if nOpca == K_OK
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Verifica se e parametro sx1
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	if at("MV_", upper(cCampo) ) > 0 .or. at("MV_", upper(cNomCampo) ) > 0

		if !empty(cCampo)
      		&(cCampo) := aBrowUsr[nLin,1]
      	endif

		if !empty(cNomCampo)
      		&(cNomCampo) := aBrowUsr[nLin,3]
		endif

	else
		if !empty(cCampo)
      		&("M->"+cCampo) := aBrowUsr[nLin,1]
      	endif

		if !empty(cNomCampo)
      		&("M->"+cNomCampo) := aBrowUsr[nLin,3]
		endif
	endIf
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da Funcao...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nOpca == K_OK)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSUSRBIO  ³ Autor ³ TOTVS			   ³ Data ³ 05.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Dialog pesquisa usuarios    	    				         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSUSRBIO(cUsuario,cNomeUsr)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlgPesUsr
Local cChave     := Space(100)
LOCAL nLin       := 1
LOCAL oSayUsr
LOCAL nOpca      := 0
LOCAL aBrowUsr   := {}
LOCAL aVetPad    := { {"","",""} }
LOCAL oBrowUsr
LOCAL oGetChave
LOCAL oTipoPes
LOCAL bRefresh   := { || PLSAPUSER(aBrowUsr,aVetPad,oBrowUsr,cChave,cTipoPes)}
LOCAL bOK        := { || nLin := oBrowUsr:nAt,nOpca := 1,lOk:=.T.,oDlgPesUsr:End() }
LOCAL bCanc      := { || nOpca := 3,oDlgPesUsr:End() }
LOCAL nReg
LOCAL cValid     := "{|| Eval(bRefresh) }"
LOCAL cTipoPes   := ""
LOCAL aTipoPes   := {STR0040,STR0041} //"1-Nome Usuario"###"2-Codigo"

aBrowUsr         := aClone(aVetPad)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPesUsr TITLE STR0042 FROM 008.2,005 TO 025,090 OF GetWndDefault()  //"Pesquisa dos Usuarios do PROTHEUS"

oGetChave := TGet():New(015,108,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesUsr,215,008 ,"",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Browse...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowUsr := TcBrowse():New( 030, 008, 316, 093,,,, oDlgPesUsr,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrowUsr:AddColumn(TcColumn():New(STR0054,nil,;
         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil)) //"Codigo"
         oBrowUsr:ACOLUMNS[1]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,1] }
oBrowUsr:AddColumn(TcColumn():New(STR0055,nil,;
         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil)) //"Nome"
         oBrowUsr:ACOLUMNS[2]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,2] }
oBrowUsr:AddColumn(TcColumn():New(STR0043,nil,;
         nil,nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil))  //"Nome Completo"
         oBrowUsr:ACOLUMNS[3]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,3] }

@ 015,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 100,010 OF oDlgPesUsr PIXEL COLOR CLR_HBLUE

oBrowUsr:SetArray(aBrowUsr)
oBrowUsr:BLDBLCLICK := bOK
Eval(bRefresh)

//-- LGPD -------- 
//TcBrowse não tratado pois as informações do aBrowUsr são carregados pela função do frame FWSFALLUSERS(), em PLSAPUSER().
//----------------

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgPesUsr ON INIT Eval({ || EnChoiceBar(oDlgPesUsr,bOK,bCanc,.F.) })

If nOpca == K_OK
      cUsuario    := aBrowUsr[nLin,1]
      cNomeUsr    := aBrowUsr[nLin,2]
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da Funcao...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nOpca == K_OK)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSAPUSER  ³ Autor ³ Michele Tatagiba   ³ Data ³ 06.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa o usuario na base de dados ....                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSAPUSER(aBrowUsr,aVetPad,oBrowUsr,cChave,cTipoPes)
LOCAL aUsers   := FWSFALLUSERS()
LOCAL nCont    := 1
LOCAL nOldLine := 1
LOCAL cCod     := ""
LOCAL cNome    := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa resultado...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aBrowUsr := {}

aSort(aUsers,,,{|x,y| x[3] < y[3]})

If !Empty(cChave) .And. cTipoPes == STR0040 //'1-Nome Usuario'
	While nCont <= Len(aUsers)
		cNome := aUsers[nCont,3]
		If AllTrim(cNome) $ AllTrim(cChave)
		   aadd(aBrowUsr,{aUsers[nCont,2],aUsers[nCont,3],aUsers[nCont,4]})
		EndIf
	   nCont ++
	Enddo
ElseIf !Empty(cChave) .And. cTipoPes == STR0041 //'2-Código'
	While nCont <= Len(aUsers)
		cCod := aUsers[nCont,2]
		If AllTrim(cCod) $ AllTrim(cChave)
		   aadd(aBrowUsr,{aUsers[nCont,2],aUsers[nCont,3],aUsers[nCont,4]})
		EndIf
	   nCont ++
	Enddo
Else
	While nCont <= Len(aUsers)
	   aadd(aBrowUsr,{aUsers[nCont,2],aUsers[nCont,3],aUsers[nCont,4]})
	   nCont ++
	Enddo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa resultado da pesquisa...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aBrowUsr) == 0
   aBrowUsr := aClone(aVetPad)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ordena em ordem alfabetica....                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aBrowUsr := aSort(aBrowUsr,,,{|x,y| x[2] < y[2]})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza browse...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowUsr:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
                  // uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
                  // Exemplo:
                  // 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
                  // (via seta para cima ou clique na primeira linha)
                  // 2a. Pesquisa: "AV" - Ocorria o erro
oBrowUsr:SetArray(aBrowUsr)
oBrowUsr:Refresh()
oBrowUsr:SetFocus()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSMRETUSR ³ Autor ³ TOTVS			   ³ Data ³ 05.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o Conteudo de um campo    				         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function PLSMRETUSR(cCampo)
LOCAL lSX1 := .f.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Verifica se e SX1
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
lSX1 :=  at("MV_", upper(cCampo) ) > 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return( iIf(lSX1,&(cCampo),&("M->"+cCampo) ) )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSLISTDE  ³ Autor ³ TOTVS			   ³ Data ³ 05.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna Array com Cod.Tabela / Desc.Tab.Honorários        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSLISTDE(cCodPad,cCodPro)
Local aArea    := GetArea()
LOCAL cSQL
LOCAL cBA8Name := RetSQLName("BA8")
LOCAL cBF8Name := RetSQLName("BF8")
LOCAL aRes     := {}

cSQL := "SELECT DISTINCT BA8_CODTAB, BF8_DESCM "
cSQL += "  FROM "+cBA8Name+","+cBF8Name
cSQL += " WHERE BA8_CODPAD = '"+cCodPad+"' "
cSQL += "   AND BA8_CODPRO = '"+cCodPro+"' "
cSQL += "   AND "+cBA8Name+".D_E_L_E_T_ = ' ' "
cSQL += "   AND BF8_CODINT+BF8_CODIGO = BA8_CODTAB "
cSQL += "   AND "+cBF8Name+".D_E_L_E_T_ = ' '"
cSQL += "ORDER BY BF8_DESCM "

PLSQuery(cSQL,"Tdes")

While ! Tdes->(Eof())
      aadd(aRes,{Tdes->BA8_CODTAB,Tdes->BF8_DESCM})
Tdes->(DbSkip())
Enddo
Tdes->(DbCloseArea())
RestArea(aArea)
Return(aRes)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSEXITDE  ³ Autor ³ TOTVS			   ³ Data ³ 05.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Dialog Tabelas										     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSEXITDE(cCodPad,cCodPro)
LOCAL aRes    := PLSLISTDE(cCodPad,cCodPro)
LOCAL oBrowse
LOCAL oDlg
LOCAL bFecha  := { || oDlg:End() }
Local aCampos := {}
Local aBls    := {}

DEFINE MSDIALOG oDlg TITLE STR0057 FROM 009,000 TO 029,060 OF GetWndDefault() //"Tabelas"

oBrowse := TcBrowse():New( 030,001,237,150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrowse:AddColumn(TcColumn():New(STR0046,{ || aRes[oBrowse:nAt,1] },;
         "@R !.!!!-!!!",nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil)) //"Tabela"

oBrowse:AddColumn(TcColumn():New(STR0048,{ || aRes[oBrowse:nAt,2] },;
         nil,nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil)) //"Descricao"

oBrowse:SetArray(aRes)

//-- LGPD --------  
if objCENFUNLGP:isLGPDAt()  
	aCampos := {"BA8_CODTAB","BF8_DESCM"}  
	aBls := objCENFUNLGP:getTcBrw(aCampos)  
	oBrowse:aObfuscatedCols := aBls  
endif  
//---------------- 

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bFecha,bFecha,.F.)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PlsEspPre  ³ Autor ³Brunoro/Tulio Cesar³ Data ³ 22.05.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe as especialidades medicas para uso em um F3          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ F3 BYT                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao do mBrowse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSEspPre(cDado)
//file://ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//file://³ Define variaveis...                                                      ³
//file://ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea     := GetArea()
//LOCAL K_OK      := 0 K_OK é uma constante do include PLSMGER
LOCAL oDlg
LOCAL nOpca     := 0
LOCAL bOK       := { || nOpca := K_OK, oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
LOCAL oCritica
LOCAL cSQL
LOCAL aCritica := {}
LOCAL nInd
LOCAL lOk      := .F.
Local aCampos := {}
Local aBls    := {}


cDado    := AllTrim(cDado)

cSQL := "SELECT BAQ_CODESP,BAQ_DESCRI "
cSQL += "  FROM "+RetSQLName("BAQ")
cSQL += " WHERE BAQ_FILIAL = '"+xFilial("BAQ")+"' AND D_E_L_E_T_ = ' ' ORDER BY BAQ_FILIAL,BAQ_DESCRI"

PLSQuery(cSQL,"TrbBAQ")

While ! TrbBAQ->(Eof())
      aadd(aCritica,{TrbBAQ->BAQ_CODESP,TrbBAQ->BAQ_DESCRI,If(TrbBAQ->BAQ_CODESP$cDado,.T.,.F.)})
TRBBAQ->(DbSkip())
Enddo
TrbBAQ->(DbCloseArea())
RestArea(aArea)

DEFINE MSDIALOG oDlg TITLE STR0058 FROM 10,10 TO 36,99 OF GetWndDefault() //"Especialidades"

oCritica := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

oCritica:AddColumn(TcColumn():New(" ",{ || IF(aCritica[oCritica:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
         "@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))

oCritica:AddColumn(TcColumn():New(STR0054,{ || OemToAnsi(aCritica[oCritica:nAt,1]) },;
         "@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))  //"Codigo"

oCritica:AddColumn(TcColumn():New(STR0048,{ || OemToAnsi(aCritica[oCritica:nAt,2]) },;
         "@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))  //"Descricao"

oCritica:SetArray(aCritica)
oCritica:bLDblClick := { || aCritica[oCritica:nAt,3] := IF(aCritica[oCritica:nAt,3],.F.,.T.) }


//-- LGPD --------  
if objCENFUNLGP:isLGPDAt()  
	aCampos := {.F.,"BAQ_CODESP","BAQ_DESCRI" }  
	aBls := objCENFUNLGP:getTcBrw(aCampos)  
	oCritica:aObfuscatedCols := aBls  
endif  
//---------------- 

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

If nOpca == K_OK

   cDado := "'"
   For nInd := 1 To Len(aCritica)
       If aCritica[nInd,3]
             If ( len(cDado) + len(aCritica[nInd,1]) ) > 35 //Pequeno tratamento para não ocorrer error.log de tamanho. Analisar melhor. O campo de especialidade aceita apenas 40 caracteres (pergunte PLS210)
                Exit
             Else
                cDado += aCritica[nInd,1]+"','"
             EndIf  
       Endif
   Next
   cDado := Substr(cDado,1,Len(cDado)-2)
Endif

cEspec := cDado

MV_PAR05 := IIf(!empty(cDado), cDado, "" )
lOk	:= IIf(!empty(cDado), .T., .F. )

Return(lOk)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PlsNomPre  ³ Autor ³Brunoro/Tulio Cesar³ Data ³ 22.05.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a Rede de Atendimento para uso em um F3              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ F3 BYT                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao do mBrowse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSNomPre(cDado)
//file://ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//file://³ Define variaveis...                                                      ³
//file://ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea     := GetArea()
//LOCAL K_OK      := 0 K_OK é uma constante do include PLSMGER
LOCAL oDlg
LOCAL nOpca     := 0
LOCAL bOK       := { || nOpca := K_OK, oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
LOCAL oCritica
LOCAL cSQL
LOCAL aCritica := {}
LOCAL nInd
LOCAL lOk      := .F.
Local aCampos := {}
Local aBls    := {}

cDado    := AllTrim(cDado)

cSQL := "SELECT BAU_CODIGO,BAU_NOME "
cSQL += "  FROM "+RetSQLName("BAU")
cSQL += " WHERE BAU_FILIAL = '"+xFilial("BAU")+"' AND D_E_L_E_T_ = ' ' ORDER BY BAU_FILIAL,BAU_NOME"

PLSQuery(cSQL,"TrbBAU")

While ! TrbBAU->(Eof())
      aadd(aCritica,{TrbBAU->BAU_CODIGO,TrbBAU->BAU_NOME,If(TrbBAU->BAU_CODIGO$cDado,.T.,.F.)})
	  TRBBAU->(DbSkip())
Enddo
TrbBAU->(DbCloseArea())
RestArea(aArea)

DEFINE MSDIALOG oDlg TITLE STR0059 FROM 10,10 TO 36,99 OF GetWndDefault() //"Rede de Atendimento"

oCritica := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

oCritica:AddColumn(TcColumn():New(" ",{ || IF(aCritica[oCritica:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
         "@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))

oCritica:AddColumn(TcColumn():New(STR0054,{ || OemToAnsi(aCritica[oCritica:nAt,1]) },;
         "@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))  //"Codigo"

oCritica:AddColumn(TcColumn():New(STR0048,{ || OemToAnsi(aCritica[oCritica:nAt,2]) },;
         "@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))  //"Descricao"

oCritica:SetArray(aCritica)
oCritica:bLDblClick := { || aCritica[oCritica:nAt,3] := IF(aCritica[oCritica:nAt,3],.F.,.T.) }

//-- LGPD --------  
if objCENFUNLGP:isLGPDAt()  
	aCampos := {.F.,"BAU_CODIGO","BAU_NOME" }  
	aBls := objCENFUNLGP:getTcBrw(aCampos)  
	oCritica:aObfuscatedCols := aBls  
endif  
//---------------- 

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

If nOpca == K_OK

   cDado := "'"
   For nInd := 1 To Len(aCritica)
       If aCritica[nInd,3]
             If ( len(cDado) + len(aCritica[nInd,1]) ) > 34 //Pequeno tratamento para não ocorrer error.log de tamanho. Analisar melhor. O campo de especialidade aceita apenas 35 caracteres (pergunte PLS210)
                Exit
             Else
                cDado += aCritica[nInd,1]+"','"
             EndIf  
       Endif
   Next
   cDado := Substr(cDado,1,Len(cDado)-2)

Endif

cCreden := cDado

MV_PAR07 := IIf(!empty(cDado), cDado, "" )
lOk	:= IIf(!empty(cDado), .T., .F. )

Return(lOk)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESLCRP ³ Autor ³ Geraldo Felix Jr.  ³ Data ³ 26.03.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de locais de atendimento...             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPESLCRP(oObj)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cChave     	:= Space(40)
LOCAL oDlgPesPro
LOCAL oTipoPes
LOCAL oSayPro
LOCAL nOpca      	:= 0
LOCAL aBrowPro   	:= {}
LOCAL aVetPad    	:= { {"",""} }
LOCAL oBrowPro
LOCAL bOK        	:= { || nLin := oBrowPro:nAt, If(Empty(aBrowPro[1,1]),nOpca := 3,nOpca := 1),oDlgPesPro:End() }
LOCAL bCanc      	:= { || nOpca := 3,oDlgPesPro:End() }
LOCAL nReg
LOCAL oGetChave
LOCAL nLin       	:= 1
LOCAL nBB8_LOCAL    := oObj:FieldPos("BB8_LOCAL")
LOCAL nBB8_DESLOC	:= oObj:FieldPos("BB8_DESLOC")
Local nCnt
Local aCampos := {}
Local aBls    := {}
aBrowPro         	:= aClone(aVetPad)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define matriz da consulta...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCnt := 1 To Len(oObj:aCols)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ignora a linha atual...                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nCnt == oObj:Linha()
		Loop
	Endif

	If Empty(aBrowPro[1][1])
		aBrowPro[1][1] := oObj:aCols[nCnt][nBB8_LOCAL]
		aBrowPro[1][2] := oObj:aCols[nCnt][nBB8_DESLOC]
	Else
		Aadd(aBrowPro, {"",""})
		aBrowPro[Len(aBrowPro)][1] := oObj:aCols[nCnt][nBB8_LOCAL]
		aBrowPro[Len(aBrowPro)][2] := oObj:aCols[nCnt][nBB8_DESLOC]
	Endif

Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPesPro TITLE STR0060 FROM 008.2,000 TO 025,ndColFin OF GetWndDefault() //"Pesquisa de locais de atendimento"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Browse...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowPro := TcBrowse():New( 020, 008, 378, 093,,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrowPro:AddColumn(TcColumn():New(STR0054,nil,;
nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil)) //"Codigo"
oBrowPro:ACOLUMNS[1]:BDATA     := { || aBrowPro[oBrowPro:nAt,1] }

oBrowPro:AddColumn(TcColumn():New(STR0048,nil,;
nil,nil,nil,nil,120,.F.,.F.,nil,nil,nil,.F.,nil))//"Descricao"

oBrowPro:ACOLUMNS[2]:BDATA     := { || aBrowPro[oBrowPro:nAt,2] }

oBrowPro:SetArray(aBrowPro)
oBrowPro:BLDBLCLICK := bOK

//-- LGPD --------  
if objCENFUNLGP:isLGPDAt()  
	aCampos := {"BB8_LOCAL","BB8_DESLOC" }  
	aBls := objCENFUNLGP:getTcBrw(aCampos)  
	oBrowPro:aObfuscatedCols := aBls  
endif  
//---------------- 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.) })

If nOpca == K_OK
	If !Empty(aBrowPro[1,1])
		BD1->(DBSetOrder(1))
		BD1->(DBSeek(xFilial("BD1")+PLSINTPAD()+aBrowPro[nLin,1]))
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da Funcao...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nOpca==K_OK)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSMPESQMAT³ Autor ³ Bruno Lazarini     ³ Data ³ 14.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa de matricula, executado pelo Call Center.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteração                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Bruno       ³14.12.10³ xxxx ³ Melhorias:                              ³±±
±±³       	   ³ 		³ 	   ³ Função executada pela função "PLSMBUSCA"³±±
±±³            ³ 		³	   ³ dentro da função: PLSPESUSER(), só é    ³±±
±±³            ³ 		³      ³ executado caso: Estar no módulo de Call ³±±
±±³            ³ 		³      ³ Center e o parametro MV_PLSUSR, estiver ³±±
±±³            ³ 		³      ³ habilitado.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION PLSMPESQMA()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlg
LOCAL nOpcD
LOCAL cMatri	 := SPACE(17)
LOCAL dDatPro    := dDATABASE
LOCAL cHorPro	 := StrTran(Time(),":","")
Local lRet 		 := .T.
LOCAL aRet		 := {}

Define Font oFontHighB Name 'Arial' Size 0, -12 Bold

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela para digitar número de matricula                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                  //L C
DEFINE MSDIALOG oDlg FROM 0,0 TO 140,500 TITLE STR0038 PIXEL // Intercâmbio Eventual

oDlg:OFONT := oFontHighB
// L   C
@ 015,20  Say STR0039 // Informe o numero de Matricula :
@ 015,120 Get cMatri Size 100,10 //VALID PLSA090USR(cMatri, dDatPro, cHorPro, "BE1") //(M->BE1_USUARI,M->BE1_DATPRO,M->BE1_HORPRO,"BE1")
@ 043,20  BmpButton Type 1 ACTION (Iif(PLSA090USR(cMatri, dDatPro, cHorPro, "BE1"), (nOpcd := 1, oDlg:End()), nOpcd := 0))
@ 043,60  BMPBUTTON TYPE 2 ACTION (nOpcD := 2, oDlg:End()) // Botao cancelar, fecha objeto

ACTIVATE DIALOG oDlg  CENTER

If nOpcD = 2
	lRet := .F.
Endif

aRet	:= {lRet,BA1->(Recno())}

RETURN(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSMBUSCA  ³ Autor ³ Bruno Lazarini     ³ Data ³ 14.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Trata objetos e aArray para busca de matricula.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteração                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Bruno       ³14.12.10³ xxxx ³ Melhorias:                              ³±±
±±³       	   ³ 		³ 	   ³ Função executada pelo botão"Intercâmbio"³±±
±±³            ³ 		³	   ³ dentro da função: PLSPESUSER(), só é    ³±±
±±³            ³ 		³      ³ executado caso: Estar no módulo de Call ³±±
±±³            ³ 		³      ³ Center e o parametro MV_PLSUSR, estiver ³±±
±±³            ³ 		³      ³ habilitado.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION PLSMBUSCA(oBrowUsr,aBrowUsr, cTipoPes, cChave)

LOCAL aRet
LOCAL lExisteBloc := .F.

If ExistBlock('PLSMCORF3')
    lExisteBloc:=.T.
Endif

aRet := PLSMPESQMA()

If aRet[1] == .F.
	Return
Endif

BA1->(DbGoTo(aRet[2]))

aBrowUsr := {}
      BA1->(aadd(aBrowUsr,{If(lExisteBloc,ExecBlock('PLSMCORF3',.f.,.f.,{BA1->BA1_CODINT+"."+BA1->BA1_CODEMP+"."+BA1->BA1_MATRIC+"-"+BA1->BA1_TIPREG+"-"+BA1->BA1_DIGITO}),PLLegBloq()),BA1->BA1_CODINT+"."+BA1->BA1_CODEMP+"."+BA1->BA1_MATRIC+"-"+BA1->BA1_TIPREG+"-"+BA1->BA1_DIGITO,;
      BA1->BA1_NOMUSR,;
      Calc_Idade(dDataBase,BA1->BA1_DATNAS),;
      AllTrim(BA1->BA1_PAI)+" - "+AllTrim(BA1->BA1_MAE),;
      BA1->BA1_DATINC,;
      BA1->BA1_BAIRRO,;
      BA1->(Recno()),;
      BA1->BA1_MATANT,;
      BA1->BA1_NREDUZ,;
      IIF(EMPTY(BA1->BA1_CODPLA),BA3->BA3_CODPLA,BA1->BA1_CODPLA)}))
oBrowUsr:SetArray(aBrowUsr)
oBrowUsr:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSESPLOC ºAutor  ³ TOTVS S/A          º Data ³  21/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao criada para ser utilizada na consulta especialidade º±±
±±º          ³ as consulta estavam apresentando problema de performance emº±±
±±º          ³ base de dados dos clientes                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSESPLOC(cCodigo,cCodInt,cLocal)
Local cGetEsp   := Space(40)
Local oBrwEsp   := Nil
Local oDlgEsp   := Nil
Local nLin	    := 1
Local nOpca	    := 0
Local bOk       := { || nLin := oBrwEsp:nAt,nOpca := 1,oDlgEsp:End() }
Local bCanc     := { || nOpca := 3,oDlgEsp:End() }
Local bRefresh  := { || Iif(ValType(oBrwEsp) == 'A' .And. Empty(oBrwEsp[1,1]),.F.,.T. )}
Local bGetEsp   := { || PlGetEsp(AllTrim(@cGetEsp),@aEspLoc,cCodigo,cCodInt,cLocal,oCmbEsp),oBrwEsp:SetArray(aEspLoc), oBrwEsp:Refresh() }
Local aEspLoc   := {}
Local cCmbEsp   := ""
Local oCmbEsp   := Nil
Local lRet      := .F.
Local aCampos := {}
Local aBls    := {}
Default cCodigo := ""
Default cCodInt := PlsIntPad()
Default cLocal  := ""

PlGetEsp(,aEspLoc,cCodigo,cCodInt,cLocal,oCmbEsp)

DEFINE MSDIALOG oDlgEsp TITLE STR0058 FROM 008.8,005 TO 033,060 OF GetWndDefault() //"Especialidades"
@ 15,02 Say oSay PROMPT STR0061 SIZE 25,20 OF oDlgEsp PIXEL //"Pesquisar: "
oCmbEsp :=  TComboBox():Create(oDlgEsp,{|u|if(PCount()>0,cCmbEsp:=u,cCmbEsp)},15,30,{"Código","Descrição"},50,20,,,,,,.T.,,,,,,,,,'cCmbEsp')
@ 15,85 MSGET cGetEsp SIZE 95, 010 OF oDlgEsp PIXEL PICTURE "@!"
DEFINE SBUTTON FROM 15,185 TYPE 1 ACTION Eval(bGetEsp) ENABLE OF oDlgEsp

oBrwEsp := TcBrowse():New( 032, 002, 216, 147,,,, oDlgEsp,,,,,,,,,,,, .F.,, .T.,, .F., )
oBrwEsp:AddColumn(TcColumn():New(STR0054,{ || aEspLoc[oBrwEsp:nAt,1] },"@!",nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))//"Código"
oBrwEsp:AddColumn(TcColumn():New(STR0048,{ || aEspLoc[oBrwEsp:nAt,2] },"@!",nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil))//"Descrição"
oBrwEsp:SetArray(aEspLoc)
oBrwEsp:bLDblClick := bOk
Eval(bRefresh)

//-- LGPD --------  
if objCENFUNLGP:isLGPDAt()  
	aCampos := {"BAX_CODESP","BAQ_DESCRI" }  
	aBls := objCENFUNLGP:getTcBrw(aCampos)  
	oBrwEsp:aObfuscatedCols := aBls  
endif  
//---------------- 

ACTIVATE MSDIALOG oDlgEsp ON INIT Eval({ || EnChoiceBar(oDlgEsp,bOK,bCanc,.F.) })

If nOpca == K_OK
	If ValType(aEspLoc) == 'A' .And. Len(aEspLoc) > 0 .And. !Empty(aEspLoc[nLin,1])
		BAX->(dbSetOrder(1))
		lRet := BAX->(MsSeek(xFilial("BAX")+cCodigo+cCodInt+cLocal+aEspLoc[nLin,1]))
	Else
		lRet := .F.
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PlGetEsp ºAutor  ³Microsiga           º Data ³  11/27/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega as especialidades do prestador de acordo com o localº±±
±±º          ³e chave de pesquisa                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PlGetEsp(cGetEsp,aEspLoc,cCodigo,cCodInt,cLocal,oCmbEsp)
Local cOrdem := "BAQ_CODESP"

aEspLoc := {}
cSQL := "SELECT BAX_CODESP, BAX_CODLOC, BAQ_DESCRI FROM " + RetSqlName("BAX") + " BAX, " + RetSqlName("BAQ") + " BAQ "
cSQL += "WHERE BAX_FILIAL = '" + xFilial("BAX") + "' AND BAQ_FILIAL = '" + xFilial("BAQ") + "' "
cSQL += " AND BAX_CODINT = BAQ_CODINT AND BAX_CODESP = BAQ_CODESP "
If !Empty(cCodigo)
	cSQL += " AND BAX_CODIGO = '" + cCodigo + "'"
EndIf
If !Empty(cCodInt)
	cSQL += " AND BAX_CODINT = '" + cCodInt + "'"
EndIf
If !Empty(cLocal)
	cSQL += " AND BAX_CODLOC = '" + cLocal + "'"
EndIf
If ValType(oCmbEsp) == "O" .And. !Empty(cGetEsp)
	If oCmbEsp:Nat == 1
		cSQL += " AND BAQ_CODESP LIKE '%" + cGetEsp + "%'"
		cOrdem := "BAQ_CODESP"
	Else
		cSQL += " AND BAQ_DESCRI LIKE '%" + cGetEsp + "%'"
		cOrdem := "BAQ_DESCRI"
	EndIf
EndIf
cSQL += " AND (BAX_DATBLO = ' ' OR BAX_DATBLO >= '" + DTOS(dDataBase) + "')"
cSQL += "  AND BAX.D_E_L_E_T_ <> '*' AND BAQ.D_E_L_E_T_ <> '*'"
cSQL += " ORDER BY " + cOrdem

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"ESPLC",.F.,.T.)

While !ESPLC->(Eof())
	aAdd(aEspLoc,{ESPLC->BAX_CODESP,ESPLC->BAQ_DESCRI,ESPLC->BAX_CODLOC})
	ESPLC->(dbSkip())
EndDo

ESPLC->(dbCloseArea())

Return Iif(Len(aEspLoc) > 0,.T.,.F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSMCON   ºAutor  ³Microsiga           º Data ³  04/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSCPITEM(cCodPad,cCodPro,cAliCab)
LOCAL cCodInt    := PLSINTPAD()
LOCAL aDadUsr    := PLSGETUSR()
LOCAL aDadRDA	 := PLSGETRDA()
LOCAL cCodRDA    := &("M->"+cAliCab+"_CODRDA")
LOCAL cCodEsp    := &("M->"+cAliCab+"_CODESP")
LOCAL dDatPro    := &("M->"+cAliCab+"_DATPRO")
LOCAL cHorPro    := &("M->"+cAliCab+"_HORPRO")
LOCAL cCid		 := &("M->"+cAliCab+"_CID")
LOCAL cOpeRda    := &("M->"+cAliCab+"_OPERDA")
LOCAL cMatrUsr	 := &("M->"+cAliCab+"_USUARI")
LOCAL cTipPreFor := &("M->"+cAliCab+"_TIPPRE")
LOCAL cUFAte     := If(Type("M->"+cAliCab+"_UFATE")  <> "U",&("M->"+cAliCab+"_UFATE"),"")
LOCAL cMunAte    := If(Type("M->"+cAliCab+"_MUNATE") <> "U",&("M->"+cAliCab+"_MUNATE"),"")
LOCAL cCodLoc    := If(Type("M->"+cAliCab+"_LOCATE") <> "U",&("M->"+cAliCab+"_LOCATE"),"")
LOCAL cRegAte    := If(Type("M->"+cAliCab+"_GRPINT") <> "U",If(!Empty(&("M->"+cAliCab+"_GRPINT")),"1","2"),"2")
LOCAL cCodTab	 := ""
LOCAL aDadBD4	 := {}
LOCAL nValPPM	 := 0
LOCAL oDlg
Local aCampos := {}
Local aBls    := {}

If Valtype(aDadUsr) <> "A" .or. Len(aDadUsr) == 0
	aDadUsr := PLSDADUSR(cMatrUsr,"1",.F.,dDatPro)
Endif

If Valtype(aDadRDA) <> "A" .or. Len(aDadRDA) == 0
	aDadRDA := PLSDADRDA(cOpeRDA,cCodRDA,"1",dDatPro)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca a tabela de pagamento para este prestador...                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aVetTab := PLSRETTAB(cCodPad,cCodPro,dDatPro,cCodInt,cCodRDA,cCodEsp,"",;
					 cCodLoc,dDatPro,"1",aDadUsr[45],aDadUsr[11],;
   					 nil,"2",aDadUsr,cTipPreFor,nil,nil,.F.,cUFAte,cMunAte)

If Len(aVetTab) > 0 .and. aVetTab[1]
	cCodTab   := aVetTab[3]
	BD4->(dbSetOrder(01))
	If BD4->(dbSeek(xFilial("BD4")+PlsIntPad()+cCodTab+cCodPad+cCodPro))
		While !BD4->(Eof()) .AND. 	BD4->BD4_CODTAB == PlsIntPad()+cCodTab .AND.;
									BD4->BD4_CDPADP == cCodPad .AND.;
									BD4->BD4_CODPRO == cCodPro

			If Empty(BD4->BD4_VIGINI) .or. (Empty(BD4->BD4_VIGFIM) .or. BD4->BD4_VIGFIM <= dDatPro)
				nPos := Ascan(aDadBD4, {|x| x[1] == BD4->BD4_CODIGO})

				If nPos == 0
					nValPPM := 0

					BW4->(DbSetOrder(1))
					If !Empty(BD4->BD4_PORMED)
						If BW4->(MsSeek(xFilial("BW4")+cCodInt+cCodTab+BD4->BD4_PORMED))
							nValPPM := BW4->BW4_VLRREA
						Endif
					Endif

					Aadd(aDadBD4, {BD4->BD4_CODIGO,BD4->BD4_VALREF,BD4->BD4_PORMED,nValPPM})
				Endif
			Endif

			BD4->(dbSkip())
		Enddo
	Endif

	If Len(aDadBD4) > 0
		DEFINE MSDIALOG oDlg TITLE STR0062 FROM 10,10 TO 36,95 OF GetWndDefault() //"Composição do procedimento"

			oComp := TcBrowse():New( 035, 005, 325, 160,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

			oComp:AddColumn(TcColumn():New(STR0063,{ || OemToAnsi(aDadBD4[oComp:nAt,1]) },;
	         "@!",nil,nil,nil,30,.F.,.F.,nil,nil,nil,.F.,nil))    //"Unidade"

			oComp:AddColumn(TcColumn():New(STR0064,{ || aDadBD4[oComp:nAt,2] },;
	         "@E 99,999.99",nil,nil,nil,60,.F.,.F.,nil,nil,nil,.F.,nil)) //"Valor Referencia"

			oComp:AddColumn(TcColumn():New(STR0065,{ || aDadBD4[oComp:nAt,3] },;
	         "@!",nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil)) //"Porte"

			oComp:AddColumn(TcColumn():New(STR0066,{ || aDadBD4[oComp:nAt,4] },;
	         "@E 99,999.99",nil,nil,nil,60,.F.,.F.,nil,nil,nil,.F.,nil)) //"Valor Porte"

			oComp:SetArray(aDadBD4)

			//-- LGPD --------  
			if objCENFUNLGP:isLGPDAt()  
				aCampos := {"BD4_CODIGO","BD4_VALREF","BD4_PORMED","BW4_VLRREA" }  
				aBls := objCENFUNLGP:getTcBrw(aCampos)  
				oComp:aObfuscatedCols := aBls  
			endif  
			//---------------- 

		ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()},.F.,{}) centered
	Endif
Else
	MsgAlert(STR0067)//"Não foi possível localizar a TDE para este evento."
Endif

Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESBRW  ³ Autor ³ Alexander Santos   ³ Data ³ 01.07.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Browse de consulta/pesquisa	                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function PLSPESBRW()
LOCAL nOpca      	:= 0
LOCAL nLin       	:= 1
LOCAL cTipoPes	:= ''
LOCAL cChave     	:= space(100)
LOCAL aBrwDad   	:= { {"","","","",""} }
LOCAL aMatEpt		:= aClone(aBrwDad)
LOCAL aOpcoes		:= {}
LOCAL aPesOrd   	:= {STR0068,STR0069,STR0070}//"1-Liberação","2-Matricula","3-Nome do Usuario"

LOCAL bOK         := { || iif(!empty(cChave),(nLin := oBrwPes:nAt, nOpca := 1,oDlgPes:end()),help("",1,"PLSMCON") ) }
LOCAL bCanc      	:= { || nOpca := 3,oDlgPes:end() }

LOCAL bRefresh   	:= { || iif(!empty(cChave),PLSPBRW(oBrwPes,aBrwDad,aMatEpt,aOpcoes[val(cTipoPes),1],allTrim(cChave),lChk),.t.) }
LOCAL cValid     	:= "{|| eval(bRefresh) }"

LOCAL oPes		:= nil
LOCAL oDlgPes	:= nil
LOCAL oBrwPes	:= nil
LOCAL oTipoPes	:= nil
LOCAL lChk		:= .f.
Local aCampos := {}
Local aBls    := {}

//No reembolso deve exibir apenas as liberações do beneficiário selecionado no item
if upper( allTrim(funName())) $ "PLSA001A,PLSA001" 
	aPesOrd  := {STR0068}//"1-Liberação"
endIf 

//³ pesquisa
aadd(aOpcoes,{"BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT"})
aadd(aOpcoes,{"BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG"})
aadd(aOpcoes,{"BEA_NOMUSR"})
aadd(aOpcoes,{""})

If Val(GetVersao(.F.)) < 12

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Define dialogo...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	DEFINE MSDIALOG oDlgPes TITLE STR0071 FROM 008.2,000 TO 026,ndColFin OF GetWndDefault() //"Pesquisa"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Monta objeto que recebera o a chave de pesquisa  ...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	@ 15,005 COMBOBOX oTipoPes var cTipoPes ITEMS aPesOrd SIZE 070,010 OF oDlgPes PIXEL COLOR CLR_HBLUE
	oPes := TGet():New(15,075,{ | U | if( pcount() == 0, cChave, cChave := U ) },oDlgPes,210,008 ,"@!S30",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
	@ 15,319 CHECKBOX oChkChk   var lChk PROMPT STR0049 PIXEL SIZE 080, 010 OF oDlgPes //"Pesquisar Palavra Chave"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Monta Browse...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oBrwPes := TcBrowse():New( 030, 005, 390, 100,,,, oDlgPes,,,,,,,,,,,, .F.,, .T.,, .F., )

	oBrwPes:AddColumn(TcColumn():New("",nil,nil,nil,nil,'center',015,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrwPes:ACOLUMNS[1]:BDATA := { || aBrwDad[oBrwPes:nAt,1] }

	oBrwPes:AddColumn(TcColumn():New(STR0072,nil,nil,nil,nil,'left',055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrwPes:ACOLUMNS[2]:BDATA := { || aBrwDad[oBrwPes:nAt,2] }//'Autorização'

	oBrwPes:AddColumn(TcColumn():New(STR0073,nil,nil,nil,nil,'left',055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrwPes:ACOLUMNS[3]:BDATA := { || aBrwDad[oBrwPes:nAt,3] } //"Matricula"

	oBrwPes:AddColumn(TcColumn():New(STR0055,nil,nil,nil,nil,'left',120,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrwPes:ACOLUMNS[4]:BDATA := { || aBrwDad[oBrwPes:nAt,4] } //"Nome"

	oBrwPes:AddColumn(TcColumn():New(STR0074,nil,nil,nil,nil,'left',055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrwPes:ACOLUMNS[5]:BDATA := { || aBrwDad[oBrwPes:nAt,5] }//"Data Procedimento"

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Define dialogo...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	DEFINE MSDIALOG oDlgPes TITLE STR0071 FROM 008.2,000 TO 030,ndColFin OF GetWndDefault() //"Pesquisa"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Monta objeto que recebera o a chave de pesquisa  ...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	@ 40,005 COMBOBOX oTipoPes var cTipoPes ITEMS aPesOrd SIZE 070,010 OF oDlgPes PIXEL COLOR CLR_HBLUE
	oPes := TGet():New(40,075,{ | U | if( pcount() == 0, cChave, cChave := U ) },oDlgPes,210,008 ,"@!S30",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
	@ 40,319 CHECKBOX oChkChk   var lChk PROMPT STR0049 PIXEL SIZE 080, 010 OF oDlgPes //"Pesquisar Palavra Chave"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Monta Browse...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oBrwPes := TcBrowse():New( 060, 005, 390, 100,,,, oDlgPes,,,,,,,,,,,, .F.,, .T.,, .F., )

	oBrwPes:AddColumn(TcColumn():New("",nil,nil,nil,nil,'center',015,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrwPes:ACOLUMNS[1]:BDATA := { || aBrwDad[oBrwPes:nAt,1] }

	oBrwPes:AddColumn(TcColumn():New(STR0072,nil,nil,nil,nil,'left',055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrwPes:ACOLUMNS[2]:BDATA := { || aBrwDad[oBrwPes:nAt,2] }//'Autorização'

	oBrwPes:AddColumn(TcColumn():New(STR0073,nil,nil,nil,nil,'left',055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrwPes:ACOLUMNS[3]:BDATA := { || aBrwDad[oBrwPes:nAt,3] } //"Matricula"

	oBrwPes:AddColumn(TcColumn():New(STR0055,nil,nil,nil,nil,'left',120,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrwPes:ACOLUMNS[4]:BDATA := { || aBrwDad[oBrwPes:nAt,4] } //"Nome"

	oBrwPes:AddColumn(TcColumn():New(STR0074,nil,nil,nil,nil,'left',055,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrwPes:ACOLUMNS[5]:BDATA := { || aBrwDad[oBrwPes:nAt,5] }//"Data Procedimento"
EndIf

oBrwPes:setArray(aBrwDad)
oBrwPes:BLDBLCLICK := bOK

//-- LGPD --------  
if objCENFUNLGP:isLGPDAt()  
	aCampos := {.F.,;
				"BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT",;
				"BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG" ,;
				"BEA_NOMUSR",;
				"BEA_DATPRO" }  
	aBls := objCENFUNLGP:getTcBrw(aCampos)  
	oBrwPes:aObfuscatedCols := aBls  
endif  
//---------------- 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Ativa o Dialogo...
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ACTIVATE MSDIALOG oDlgPes ON INIT Eval({ || enchoiceBar(oDlgPes,bOK,bCanc,.F.) })

if nOpca == K_OK
	If cTipoPes == "3-Nome do Usuario"
		If aBrwDad[1][1] == ""
			MsgAlert(STR0082)
			Return(.F.)
		Else
			BEA->(dbGoTo(aBrwDad[nLin,6]))
		Endif
	Endif

	If cTipoPes == "1-Liberação"
		If aBrwDad[1][1] == ""
			MsgAlert(STR0083)
			Return(.F.)
		Else
			BEA->(dbGoTo(aBrwDad[nLin,6]))
		Endif
	Endif

	If cTipoPes == "2-Matricula"
		If aBrwDad[1][1] == ""
			MsgAlert(STR0084)
			Return(.F.)
		Else
			BEA->(dbGoTo(aBrwDad[nLin,6]))
		Endif
	Endif
endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorno da Funcao...
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return(nOpca==K_OK)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPBRW    ³ Autor ³ Alexander Santos   ³ Data ³ 01.07.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de browse									³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function PLSPBRW(oBrwDad,aBrwDad,aMatEpt,cCmpPes,cContBusca,lChk,nTp,lAuto)

	LOCAL aArea     := getArea()
	LOCAL nOrdem    := 1
	LOCAL cSql      := ""
	LOCAL cTipo	 	:= " IN('1','2') "
	LOCAL cMatric   := ""

	DEFAULT nTp		:= 0
	DEFAULT lAuto 	:= .F.

	//No reembolso deve exibir apenas as liberações do beneficiário selecionado no item
	if UPPER(alltrim(funName())) == "PLSA001A"
		cMatric	:= M->B1N_MATRIC
	elseIf UPPER(allTrim(funName())) == "PLSA001"
		cMatric	:= M->B45_MATRIC
	endIf

	//³ Valida chave
	if '"' $ cContBusca .or. "'" $ cContBusca
		Aviso( STR0018,STR0019,{ STR0028}, 2 )//"Caracter Invalido"//"Existem caracteres invalidos em sua pesquisa."
		return(.F.)
	endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ garante retorno correto
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	aBrwDad := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ por tipo de rotina
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	do case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ pesquisa liberacao - um execucao procurando uma liberacao
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		case nTp == 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ tipo por rotina
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			if upper(alltrim(funName())) $ "PLSA094C,PLSA094D"
				cTipo := " = '4'"
			endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Select de liberacao.
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			cSql := "SELECT BEA_OPEMOV,BEA_ANOAUT,BEA_MESAUT,BEA_NUMAUT,BEA_NOMUSR,BEA_DATPRO,BEA_OPEUSR,BEA_CODEMP,BEA_MATRIC,BEA_TIPREG,R_E_C_N_O_ "
			cSql += "  FROM " + RetSQLNAME("BEA")
			cSql += " WHERE BEA_FILIAL = '" + xFilial("BEA") + "' "
			cSql += "   AND BEA_STALIB = '1' "
			cSql += "   AND BEA_ORIGEM = '2' "
			cSql += "   AND BEA_STATUS IN('1','2') "
			cSql += "   AND D_E_L_E_T_ = ' ' "

			if ! empty(cTipo)
				cSql += "   AND BEA_TIPO " + cTipo
			endIf
			
			//No reembolso deve exibir apenas as liberações do beneficiário selecionado no item
			If ! empty(cMatric)
				cSql += "   AND BEA_OPEUSR = '" + subStr(cMatric,1,4 ) + "' "
				cSql += "   AND BEA_CODEMP = '" + subStr(cMatric,5,4 ) + "' "
				cSql += "   AND BEA_MATRIC = '" + subStr(cMatric,9,6 ) + "' "
				cSql += "   AND BEA_TIPREG = '" + subStr(cMatric,15,2) + "' "
				cSql += "   AND BEA_DIGITO = '" + subStr(cMatric,17,1) + "' "
			EndIf
			
	endCase

	cSql += PLSWHERE(cCmpPes,cContBusca,lChk)
	cSql += " ORDER BY BEA_FILIAL," + StrTran(cCmpPes, "+", ",")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ executa query
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cSql := changeQuery(PLSConSQL(cSql))
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"PLSPBRW",.F.,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ monta dados
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	if !PLSPBRW->(eof())

	while ! PLSPBRW->(eof())
		do case
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ pesquisa liberacao - um execucao procurando uma liberacao
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			case nTp == 0
				aadd(aBrwDad,{ allTrim(cValToChar(nOrdem)),PLSPBRW->(BEA_OPEMOV+"-"+BEA_ANOAUT+"."+BEA_MESAUT+"."+BEA_NUMAUT),PLSPBRW->(BEA_OPEUSR+"."+BEA_CODEMP+"."+BEA_MATRIC+"-"+BEA_TIPREG),PLSPBRW->BEA_NOMUSR,sTod(PLSPBRW->BEA_DATPRO),PLSPBRW->R_E_C_N_O_ } )
		endCase

		nOrdem++
		PLSPBRW->(dbSkip())
	endDo

	endIf

	PLSPBRW->(dbCloseArea())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ estado original
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	if len(aBrwDad)==0
		aBrwDad := aClone(aMatEpt)
	endIf

	restArea(aArea)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Atualiza browse...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !lAuto
		oBrwDad:nAt := 1
		oBrwDad:setArray(aBrwDad)
		oBrwDad:refresh()
		oBrwDad:setFocus()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Fim da Rotina...
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return(.t.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSWHERE   ³ Autor ³ Alexander Santos   ³ Data ³ 01.07.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Monta where para pesquisa generica						   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function PLSWHERE(cCmpPes,cContBusca,lChk)
LOCAL nI			:= 0
LOCAL nTam		:= 0
LOCAL cWhere		:= ""
LOCAL aWhere		:= {}
LOCAL cCampo		:= ''
LOCAL cConteudo	:= ''
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ matriz
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
aWhere := strTokArr(cCmpPes,'+')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ monta where campo e conteudo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
for nI:=1 to len(aWhere)

	if !empty(cContBusca)
		cCampo		:= allTrim(aWhere[nI])
		nTam		:= tamSx3(cCampo)[1]
		cConteudo	:= substr(cContBusca,1,nTam)
		cContBusca	:= substr(cContBusca,nTam+1,len(cContBusca))

		if empty(cContBusca) .and. len(cConteudo) != nTam
			cWhere += " AND " + cCampo + " like " + iIf(lChk,"'%","'") + cConteudo + "%' "
		else
			cWhere += " AND " + cCampo + " = '" + cConteudo + "' "
		endIf
	else
		exit
	endIf
next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return(cWhere)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSESPLOC ºAutor  ³ TOTVS S/A          º Data ³  21/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao criada para ser utilizada na consulta especialidade º±±
±±º          ³ as consulta estavam apresentando problema de performance emº±±
±±º          ³ base de dados dos clientes                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSBLOCOI(cTipo)
Local cGetClas   := Space(40)
Local oBrwClas   := Nil
Local oDlgClas   := Nil
Local nLin	    := 1
Local nOpca	    := 0
Local bOk       := { || nLin := oBrwClas:nAt,nOpca := 1,oDlgClas:End() }
Local bCanc     := { || nOpca := 3,oDlgClas:End() }
Local bRefresh  := { || Iif(ValType(oBrwClas) == 'A' .And. Empty(oBrwClas[1,1]),.F.,.T. )}
Local bGetClas   := { || PlGetClas(AllTrim(@cGetClas),@cTipo,@aClass,oCmbClas),oBrwClas:SetArray(aClass), oBrwClas:Refresh() }
Local aClass   := {}
Local cCmbClas   := ""
Local oCmbClas   := Nil
Local lRet      := .F.
Local aCampos := {}
Local aBls    := {}
Private cRetClas := ""
PlGetClas(,cTipo,aClass,oCmbClas)

DEFINE MSDIALOG oDlgClas TITLE "Classificaçoes" FROM 008.8,005 TO 033,060 OF GetWndDefault() //"Especialidades"
@ 15,02 Say oSay PROMPT STR0061 SIZE 25,20 OF oDlgClas PIXEL //"Pesquisar: "
oCmbClas :=  TComboBox():Create(oDlgClas,{|u|if(PCount()>0,cCmbClas:=u,cCmbClas)},15,30,{"Código","Descrição"},50,20,,,,,,.T.,,,,,,,,,'cCmbClas')
@ 15,85 MSGET cGetClas SIZE 95, 010 OF oDlgClas PIXEL PICTURE "@!"
DEFINE SBUTTON FROM 15,185 TYPE 1 ACTION Eval(bGetClas) ENABLE OF oDlgClas

oBrwClas := TcBrowse():New( 032, 002, 216, 147,,,, oDlgClas,,,,,,,,,,,, .F.,, .T.,, .F., )
oBrwClas:AddColumn(TcColumn():New(STR0054,{ || aClass[oBrwClas:nAt,1] },"@!",nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))//"Código"
oBrwClas:AddColumn(TcColumn():New(STR0048,{ || aClass[oBrwClas:nAt,2] },"@!",nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil))//"Descrição"
oBrwClas:SetArray(aClass)
oBrwClas:bLDblClick := bOk
Eval(bRefresh)

//-- LGPD --------  
if objCENFUNLGP:isLGPDAt()  
	aCampos := {"CGE_COD","CGE_DESCR" }  
	aBls := objCENFUNLGP:getTcBrw(aCampos)  
	oBrwClas:aObfuscatedCols := aBls  
endif  
//---------------- 

ACTIVATE MSDIALOG oDlgClas ON INIT Eval({ || EnChoiceBar(oDlgClas,bOK,bCanc,.F.) })

If nOpca == K_OK
	If ValType(aClass) == 'A' .And. Len(aClass) > 0 .And. !Empty(aClass[nLin,1])
		If cTipo =='1'
			CGE->(dbSetOrder(1))
			lRet := CGE->(MsSeek(xFilial("CGE")+aClass[nLin,1]))

		Else
			CGG->(dbSetOrder(1))
			lRet := CGG->(MsSeek(xFilial("CGG")+aClass[nLin,1]))

		Endif

	Else
		lRet := .F.
	EndIf
EndIf
If lRet
	cRetClas:= aClass[nLin,1]
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PlGetEsp ºAutor  ³Microsiga           º Data ³  11/27/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega as especialidades do prestador de acordo com o localº±±
±±º          ³e chave de pesquisa                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PlGetClas(cGetClas,cTipo,aClass,oCmbClass)


aClass := {}
If cTipo =='1'

	cSQL := "SELECT CGE_COD CODIGO,CGE_DESCR DESCR "
	cSQL += "  FROM "+RetSQLName("CGE")
	cSQL += " WHERE CGE_FILIAL = '"+xFilial("CGE")+"' AND D_E_L_E_T_ = ' ' "
	cSQL += " ORDER BY CGE_COD "
Else
	cSQL := "SELECT CGG_COD CODIGO,CGG_DESCR DESCR "
	cSQL += "  FROM "+RetSQLName("CGG")
	cSQL += " WHERE CGG_FILIAL = '"+xFilial("CGG")+"' AND D_E_L_E_T_ = ' ' "
	cSQL += " ORDER BY CGG_COD "

Endif

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)

While !TRB->(Eof())
	aAdd(aClass,{TRB->CODIGO,TRB->DESCR})
	TRB->(dbSkip())
EndDo

TRB->(dbCloseArea())

Return Iif(Len(aClass) > 0,.T.,.F.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSAGMTFU ºAutor  ³ TOTVS S/A          º Data ³  21/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao criada para ser utilizada na consulta ao campo      º±±
±±º          ³ BA3_AGMTFU                                                 º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSAGMTFU()

Local oBrwEsp   := Nil
Local oDlgEsp   := Nil
Local nLin	    := 1
Local nOpca	    := 0
Local bOk       := { || nLin := oBrwEsp:nAt,nOpca := 1,oDlgEsp:End() }
Local bCanc     := { || nOpca := 3,oDlgEsp:End() }
Local bRefresh  := { || Iif(ValType(oBrwEsp) == 'A' .And. Empty(oBrwEsp[1,1]),.F.,.T. )}
Local bGetEsp   := { || PlGetFU(oCmbEsp),oBrwEsp:SetArray(aEspLoc), oBrwEsp:Refresh() }
Local cCmbEsp   := ""
Local oCmbEsp   := Nil
Local lRet      := .F.
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
LOCAL nX,nY,nW,nH := 0
LOCAL nCmbX,nCmbY := 0
Local aCampos := {}
Local aBls    := {}
Private aEspLoc   := {}
Private cGetEsp   := Space(40)

PlGetFU(oCmbEsp)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o Tamanho da Tela ...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 20, .t., .f. } )
AAdd( aObjects, { 100, 100, .t., .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

nX := aPosObj[1][1] + 22		//Valor Original = 33
nY := aPosObj[1][2]			//Valor Original = 03
nW := aPosObj[2][4] - 54		//Valor Original = 309
nH := aPosObj[1][3] + 112	//Valor Original = 53

nCmbX := aPosObj[1][1] + 2					//Valor Original = 15 - Determina a posição X da Combo na tela
nCmbY := aPosObj[1][1] - 3					//Valor Original = 30 - Determina a posição Y da Combo na tela

//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlgEsp TITLE STR0075 FROM 008.8,005 TO 038,070 OF GetWndDefault() //"Funcionários"
@ nCmbX + 5,nY Say oSay PROMPT STR0061 SIZE 25,20 OF oDlgEsp PIXEL //"Pesquisar: "
oCmbEsp :=  TComboBox():Create(oDlgEsp,{|u|if(PCount()>0,cCmbEsp:=u,cCmbEsp)},nCmbX,nCmbY,{STR0073,STR0076,STR0077},50,20,,,,,,.T.,,,,,,,,,'cCmbEsp')
@ nCmbX + 1,aPosObj[1][3] + 32 MSGET cGetEsp SIZE 95, 010 OF oDlgEsp PIXEL PICTURE "@!"
DEFINE SBUTTON FROM nCmbX + 1,aPosObj[2][1] + 129 TYPE 1 ACTION Eval(bGetEsp) ENABLE OF oDlgEsp


oBrwEsp := TcBrowse():New( 055, 003, 254, 163,,,, oDlgEsp,,,,,,,,,,,, .F.,, .T.,, .F.,,.T. )
oBrwEsp:AddColumn(TcColumn():New("Filial",{ || aEspLoc[oBrwEsp:nAt,1] },"@!",nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))//"Filial"
oBrwEsp:AddColumn(TcColumn():New(STR0073,{ || aEspLoc[oBrwEsp:nAt,2] },"@!",nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil))//"Matricula"
oBrwEsp:AddColumn(TcColumn():New(STR0077,{ || aEspLoc[oBrwEsp:nAt,3] },"@!",nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil))//"Nome"
oBrwEsp:AddColumn(TcColumn():New(STR0076,{ || aEspLoc[oBrwEsp:nAt,4] },"@!",nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil))//"Centro de Custo"
oBrwEsp:SetArray(aEspLoc)
oBrwEsp:bLDblClick := bOk
Eval(bRefresh)

//-- LGPD --------  
if objCENFUNLGP:isLGPDAt()  
	aCampos := {"RA_FILIAL","RA_MAT","RA_NOME","RA_CC" }  
	aBls := objCENFUNLGP:getTcBrw(aCampos)  
	oBrwEsp:aObfuscatedCols := aBls  
endif  
//---------------- 

ACTIVATE MSDIALOG oDlgEsp ON INIT Eval({ || EnChoiceBar(oDlgEsp,bOK,bCanc,.F.) })

If nOpca == K_OK
	If ValType(aEspLoc) == 'A' .And. Len(aEspLoc) > 0 .And. !Empty(aEspLoc[nLin,1])
		SRA->(dbSetOrder(1))
		lRet := SRA->(DbSeek(aEspLoc[nLin,1]+aEspLoc[nLin,2]))
	Else
		lRet := .F.
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PlGetFU  ºAutor  ³Microsiga           º Data ³  11/27/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega as matriculas de funcionários                       º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PlGetFU(oCmbEsp, cCpf)
Local cOrdem := "RA_MAT"
DEFAULT cCpf := ""

aEspLoc := {}
cSQL := "SELECT RA_FILIAL, RA_MAT, RA_CC, RA_NOME FROM " + RetSqlName("SRA") + " SRA "
cSQL += "WHERE RA_SITFOLH <> 'D' "

If ! Empty(cCpf)
	cSQL += " AND RA_CIC = '" + AllTrim(cCpf) + "' "	
EndIf

If ValType(oCmbEsp) == "O" .And. !Empty(cGetEsp)
	
	If oCmbEsp:Nat == 1
		cSQL += " AND RA_MAT LIKE '%" + Alltrim(cGetEsp) + "%'"
		cOrdem := "RA_MAT"
	Elseif oCmbEsp:Nat == 2
		cSQL += " AND RA_CC LIKE '%" + Alltrim(cGetEsp) + "%'"
		cOrdem := "RA_CC"
	Else
		cSQL += " AND RA_NOME LIKE '%" + Alltrim(cGetEsp) + "%'"
		cOrdem := "RA_NOME"
	EndIf
EndIf


cSQL += "  AND SRA.D_E_L_E_T_ <> '*' "
cSQL += " ORDER BY " + cOrdem

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"AGMTFU",.F.,.T.)

While !AGMTFU->(Eof())
	aAdd(aEspLoc,{AGMTFU->RA_FILIAL,AGMTFU->RA_MAT,AGMTFU->RA_NOME,AGMTFU->RA_CC})
	AGMTFU->(dbSkip())
EndDo

AGMTFU->(dbCloseArea())

Return Iif(Len(aEspLoc) > 0,.T.,.F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESPROC ³ Autor ³ Michele Tatagiba   ³ Data ³ 23.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de Procedimentos ...                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tulio Cesar ³27.05.02³ xxxx ³ Acertos/Melhorias...                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function P001PESPRO(cCodPad,lAll,cCondSQLAd, oGridProc)
LOCAL nReg          := 0
LOCAL nLin       	:= 1
LOCAL nOpca      	:= 0
LOCAL nSaldo		:= 0
LOCAL nOrdem     	:= 1
LOCAL cChave     	:= Space(40)
LOCAL cTipoPes   	:= ""
LOCAL cCabec		:= ""
LOCAL cCodInt  		:= ""
LOCAL cCodRDA		:= ""
LOCAL cEspec   		:= ""
LOCAL cCodLoc		:= ""
LOCAL cOpeOri		:= ""
LOCAL cCodProduto	:= ""
LOCAL cTipPre  		:= ""
LOCAL cSQL 			:= ""
LOCAL oDlgPesPro    := NIL
LOCAL oTipoPes		:= NIL
LOCAL oSayPro       := NIL
LOCAL oBrowPro		:= NIL
LOCAL oGetChave		:= NIL
LOCAL oChkChk		:= NIL
LOCAL aBrowPro   	:= {}
LOCAL lOriFol1	:= .F.
LOCAL aVetPad    	:= { {"","",0,"",""} }
LOCAL bRefresh   	:= { || If(!Empty(cChave),PLSAPPROPQ(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowPro,aVetPad,oBrowPro,cCodPad,lAll,cCondSQLAd,cCodRDA,cCodInt,cVarRead),.T.), If( Empty(aBrowPro[1,1]) .And. !Empty(cChave),.F.,.T. )  }
LOCAL cValid     	:= "{|| Eval(bRefresh) }"
LOCAL bOK        	:= { || If(!Empty(cChave) .OR. lOriFol1,(nLin := IIf(lOriFol1,oGDProcB:oBrowse:nAt, oBrowPro:nAt),nOpca := 1,lOk:=.T., IIf(lOriFol1,aColsBkp := aClone(oGDProcB:aCols),Nil), IIf(lOriFol1,nPosAtu := oGDProcB:oBrowse:nAt,Nil),oDlgPesPro:End()),Help("",1,"PLSMCON")) }
LOCAL bCanc      	:= { || nOpca := 3,oDlgPesPro:End() }
LOCAL aTipoPes   	:= {}
LOCAL lChkChk    	:= .F.
LOCAL lRet		 	:= .F.
LOCAL aButtons   	:= {}
LOCAL dDatAnalise	:= dDataBase
LOCAL dDatPro		:= dDataBase
LOCAL aDadUsr		:= PLSGETUSR()
LOCAL lReembolso	:= .F.
LOCAL aItensPac     := {}
LOCAL cVarRead		:= ReadVar()
LOCAL lExB1N		:= PLSALIASEX("B1N")
LOCAL lExbProcBen := .F.
LOCAL aHeadB1N	:= {}
LOCAL aColsB1N	:= {}
LOCAL nU			:= 0
LOCAL nPosCodPro := 0
LOCAL nPosCodPad := 0
LOCAL nPosVlrApr := 0
LOCAL nPosQtdPro := 0
LOCAL nPosSequen := 0
LOCAL aColsBkp	:= {}
LOCAL nPOsAtu		:= 0
LOCAL nPosCodRef := 0
LOCAL nPosNomRef := 0
LOCAL lExiste    := .F.
LOCAL nI		 := 0
LOCAL cSequen	 := ""
Local aCampos := {}
Local aBls    := {}

DEFAULT lAll     	:= .T.
DEFAULT cCondSQLAd  := ""
DEFAULT cCodPad		:= ""
DEFAULT oGridProc  := NIL

PRIVATE aOpcoes   	:= {}
PRIVATE cCadastro 	:= ""

Aadd(aButtons, {"POSCLI",{|| PLSCPITEM(cCodPad,aBrowPro[oBrowPro:nAt,1],cCabec) },"Consultar composição"})
Aadd(aButtons, {"RELATORIO",{ || BR8->(DbGoTo(aBrowPro[oBrowPro:nAt,3])), PLSEXITDE(BR8->BR8_CODPAD,BR8->BR8_CODPSA) } ,"Exibe em quais Tabelas o procedimento esta cadastrado"})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ _@CodPad variavel private para que nao precise criar mais consulta sxb
//³ basta criar esta variavel no fonte como privada e tratar a tabela no valid
//³ do campo ou pergunte utilize uma consulta que nao tenha M-> por exemplo BDUPLS
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If Type("_CodPad_") <> 'U' .And. !Empty(_CodPad_)
	cCodPad	:= _CodPad_
EndIf

DEFINE FONT oFontMsg NAME "Arial" SIZE 000,-012 BOLD

cCabecAux 	:= "B44"
cCabec 	:= "B44"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Verifico se possui procedimentos inseridos pelo portal do beneficiario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If Type("M->B44_PROTOC") <> "U" .AND. !Empty(M->B44_PROTOC)
	If lExB1N
		B1N->(DbSetOrder(1))
		If B1N->(MsSeek(xFilial("B1N") + M->B44_PROTOC ))
			lExbProcBen := .T.
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Preencho os parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cCabec)

	If &(cCabecAux+"->(FieldPos('"+cCabecAux+"_CODOPE'))") > 0
		cCodInt	:= &("M->"+cCabec+"_CODOPE")
	EndIf

	If Empty(cCodInt) .And. &(cCabecAux+"->(FieldPos('"+cCabecAux+"_OPERDA'))") > 0
		cCodInt	:= &("M->"+cCabec+"_OPERDA")
	EndIf

	If Empty(cCodInt) .And. &(cCabecAux+"->(FieldPos('"+cCabecAux+"_CODINT'))") > 0
		cCodInt	:= &("M->"+cCabec+"_CODINT")
	EndIf

	If &(cCabecAux+"->(FieldPos('"+cCabecAux+"_CODRDA'))") > 0
		cCodRDA	:= &("M->"+cCabec+"_CODRDA")
	EndIf
	If &(cCabecAux+"->(FieldPos('"+cCabecAux+"_DATPRO'))") > 0
		dDatPro	:=  &("M->"+cCabec+"_DATPRO")
	EndIf
EndIf

aadd(aButtons,{"S4WB007N",{ || BR8->(DbGoTo(aBrowPro[oBrowPro:nAt,3])), BR8->(AxVisual("BR8",BR8->(Recno()),K_Visualizar)) } ,"Visualizar parametrizacoes deste procedimento"})
aBrowPro := aClone(aVetPad)

BX8->( DBSetOrder(1) )

aTipoPes := {STR0029,STR0030}//"1-Nome do Procedimento"##"2-Codigo do Procedimento"
aadd(aOpcoes,{"BR8_DESCRI"})
aadd(aOpcoes,{"BR8_CODPSA"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPesPro TITLE STR0045 FROM 008.2,000 TO 032,ndColFin OF GetWndDefault() //"Pesquisa de Procedimentos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Folders...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder 		  := TFolder():New(030,005,{STR0079,STR0080},{"",""},oDlgPesPro,,,,.T.,.F.,390,140) //"Eventos Beneficiário"#"Pesquisa padrão"
oFolder:aDialogs[1]:lActive := lExbProcBen
oFolder:ShowPage(2)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oGetChave := TGet():New(012,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oFolder:aDialogs[2],210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)

oGetChave:lReadOnly := lExbProcBen
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Browse...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowPro := TcBrowse():New( 028, 007, 378, If(cPaisLoc=="BRA",075,090),,,, oFolder:aDialogs[2],,,,,,,,,,,, .F.,, .T.,, .F., )

ADD COLUMN TO oBrowPro BITMAP DATA { || LoadBitmap( GetResources(), aBrowPro[oBrowPro:nAt,4] ) } TITLE "" ALIGN CENTERED WIDTH 015 NOHILITE

oBrowPro:AddColumn(TcColumn():New(STR0046,nil,;
	nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))//"Tabela"
oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,5] }
oBrowPro:AddColumn(TcColumn():New(STR0047,nil,;
	nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))//"Procedimento"
oBrowPro:ACOLUMNS[3]:BDATA := { || aBrowPro[oBrowPro:nAt,1] }
oBrowPro:AddColumn(TcColumn():New(STR0048,nil,;
	nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil))//"Descricao"
oBrowPro:ACOLUMNS[4]:BDATA := { || aBrowPro[oBrowPro:nAt,2] }

@ 011,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oFolder:aDialogs[2] PIXEL COLOR CLR_HBLUE
@ 012,310 CHECKBOX oChkChk   Var lChkChk PROMPT STR0049 PIXEL SIZE 080, 010 OF oFolder:aDialogs[2]//"Pesquisar Palavra Chave"

oBrowPro:SetArray(aBrowPro)
oBrowPro:BLDBLCLICK := bOK
oBrowPro:bGotFocus := {|| lOriFol1 := .F. }

//-- LGPD --------  
if objCENFUNLGP:isLGPDAt()  
	aCampos := {.F.,"BR8_CODPAD","BR8_CODPSA","BR8_DESCRI" }  
	aBls := objCENFUNLGP:getTcBrw(aCampos)  
	oBrowPro:aObfuscatedCols := aBls  
endif  
//---------------- 

oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}

If cPaisLoc == "BRA"
	@ 108,013 BITMAP oBmp RESNAME "BR_VERMELHO"   OF oFolder:aDialogs[2] SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 108,025 Say oSay PROMPT STR0050 SIZE 100,010 OF oFolder:aDialogs[2] PIXEL//"Nao Pertence ao ROL da ANS"

	@ 108,120 BITMAP oBmp RESNAME "BR_VERDE"   OF oFolder:aDialogs[2] SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 108,130 Say oSay PROMPT  STR0051 SIZE 100,010 OF oFolder:aDialogs[2] PIXEL //"Pertence ao ROL da ANS"
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grid de procedimentos inseridos no portal do beneficiario					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lExbProcBen

	@ 010,005 Say oSay PROMPT  STR0081 SIZE 200,010 OF oFolder:aDialogs[1] PIXEL FONT oFontMsg COLOR CLR_HBLUE  //"Despesas informadas pelo beneficiário no portal:"
	HS_BDados("B1N", @aHeadB1N, @aColsB1N,@nU, 1,, " B1N.B1N_IMGSTA = 'ENABLE' .AND. B1N.B1N_PROTOC = '" + M->B44_PROTOC + "' ",,,/*"ALL""CAMPO1/CAMPO2"*/,,,,,,/*.F.*/,/*aLeg*/,,,,, /*aCpo*/, /*aJoin*/)

	nPosCodPro := Ascan(aHeadB1N,{|x|AllTrim(x[2])=="B1N_CODPRO"})
	nPosCodPad := Ascan(aHeadB1N,{|x|AllTrim(x[2])=="B1N_CODPAD"})
	nPosVlrApr := Ascan(aHeadB1N,{|x|AllTrim(x[2])=="B1N_VLRAPR"})
	nPosQtdPro := Ascan(aHeadB1N,{|x|AllTrim(x[2])=="B1N_QTDPRO"})
	nPosSequen := Ascan(aHeadB1N,{|x|AllTrim(x[2])=="B1N_SEQUEN"})
	nPosSeqB1N := Ascan(aHeadB1N,{|x|AllTrim(x[2])=="B1N_SEQUEN"})
	nPosCodRef := Ascan(aHeadB1N,{|x|AllTrim(x[2])=="B1N_CODREF"})
	nPosNomRef := Ascan(aHeadB1N,{|x|AllTrim(x[2])=="B1N_NOMREF"})

	oGDProcB := MsNewGetDados():New(020, 005, 100, 378,0,,,,,,,,,, oFolder:aDialogs[1], aHeadB1N, aColsB1N)    // 000 000 300 500
	oGDProcB:oBrowse:BlDblClick := bOK
	oGDProcB:oBrowse:bGotFocus := {|| IIF(!Empty(oGDProcB:aCols[oGDProcB:oBrowse:nAt,nPosCodPro]),  lOriFol1 := .T.,lOriFol1 := .F.)    }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Altera a legenda do procedimento que ja foi selecionado e esta no grid	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !EMPTY(oGridProc:aCols[1][GdFieldPos("B45_CODPRO",oGridProc:aHeader)])
		For nI := 1 To LEN(oGridProc:aCols)

			If LEN(__ArrPro) >= nI .OR. !EMPTY(oGridProc:aCols[nI][GdFieldPos("B45_CODPRO",oGridProc:aHeader)]) .AND. LEN(oGDProcB:aCols) >= nI

				cSequen := If(LEN(__ArrPro) >= nI,__ArrPro[nI], oGridProc:aCols[nI][GdFieldPos("B45_SEQB1N",oGridProc:aHeader)])

				nposVal := Ascan(oGridProc:aCols,{ |x| x[GdFieldPos("B45_SEQB1N",oGridProc:aHeader)] == cSequen .AND. x[LEN(oGridProc:aHeader) + 1] == .F.})

				If nposVal > 0 .AND. !oGridProc:aCols[nposVal][LEN(oGridProc:aHeader) + 1]

					If oGDProcB:aCols[nI][GdFieldPos("B1N_SEQUEN",oGDProcB:aHeader)] == cSequen
						oGDProcB:aCols[nI][GdFieldPos("B1N_IMGSTA",oGDProcB:aHeader)] := "DISABLE"
					EndIf
				EndIf
			Else
				EXIT
			EndIf
		Next
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ ||  EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.,aButtons) }) CENTERED
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ OK
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nOpca == K_OK
	//Este item é necessário devido a váriavel lExbProcBen esta vindo como false 
	//e na rotina de reembolso temos que exibir o procedimento selecionado pela consulta padrão	
	If ReadVar() == "M->B45_CODPRO" .AND. IsInCallStack("PLSA001")
		lExbProcBen := .T.
	EndIf
	If lExbProcBen
		If lOriFol1
			//Informa e não permite incluir procedimentos existentes no grid de procedimentos
			For nI := 1 To LEN(__oGrdRee:aCols)

				If __oGrdRee:aCols[nI][GdFieldPos("B45_CODPRO",__oGrdRee:aHeader)] ==  aColsBkp[nPOsAtu,nPosCodPro] .AND. ;
						__oGrdRee:aCols[nI][GdFieldPos("B45_SEQB1N",__oGrdRee:aHeader)] ==  aColsBkp[nPOsAtu,nPosSeqB1N]	.AND. ;
						!__oGrdRee:aCols[nI][LEN(__oGrdRee:aHeader) + 1]

					aviso( STR0085,STR0086 + ALLTRIM(aColsBkp[nPOsAtu,nPosCodPro]) + STR0087,{ STR0028}, 1 ) //"Atenção"##"O procedimento com o código"###" já foi selecionado"

					lExiste := .T.
					EXIT
				EndIf
			Next

			If Ascan(__ArrPro,{ |x| x == aColsBkp[nPOsAtu,nPosSeqB1N]}) == 0
				AADD(__ArrPro,aColsBkp[nPOsAtu,nPosSeqB1N])
			EndIf
		EndIf

		If !lExiste
			lRet := .T.
			If !Empty( aBrowPro[1,1] ) .OR. (lOriFol1)
				If 	!lOriFol1
					BR8->( DbGoTo(aBrowPro[nLin,3]) )
				Else
					BR8->(DbSetOrder(1))
					BR8->(MsSeek(xFilial("BR8") + aColsBkp[nPOsAtu,nPosCodPad] + aColsBkp[nPOsAtu,nPosCodPro]))
				EndIf
				If lOriFol1
					If Type("M->B45_VLRAPR") <> "U"
						M->B45_VLRAPR := aColsBkp[nPOsAtu,nPosVlrApr]
						M->B45_CODPAD := aColsBkp[nPOsAtu,nPosCodPad]
						M->B45_CODPRO := aColsBkp[nPOsAtu,nPosCodPro]
						M->B45_QTDPRO := aColsBkp[nPOsAtu,nPosQtdPro]
						
						//------------------------------------------------------------------------------------------------------------
						//Mensagem necessária para facilitar o entendimento do usuário.
						//dois gatilhos foram criados para estes campos no chamado descrito na mensagem,
						//isso foi necessário pois o fonte poderá existir no RPO, mas os gatilhos não, ou mesmo
						//o fonte poderá receber ajustes de outros chamados e esta alteração poderá interfirir no processo do outro chamado.
						//------------------------------------------------------------------------------------------------------------
						
						//INICIO
						SX7->(dbSetOrder(1))  
   						If !SX7->(dbSeek("B45_CODPRO"+"015")) 
   							
   							If nPosCodRef == 0
						
								MsgAlert("É necessário criar os gatilhos referente ao chamado TVIOLS! entre em contato com o suporte.", "Atenção") 
								lRet := .F.
							Else 	
							 	M->B45_CODREF := aColsBkp[nPOsAtu,nPosCodRef] 
								M->B45_NOMREF := aColsBkp[nPOsAtu,nPosNomRef]
							EndIf
						EndIf
						//FIM
						
						If Type("M->B45_SEQB1N") <> "U"
							M->B45_SEQB1N := aColsBkp[nPOsAtu,nPosSeqB1N]
						EndIf
					EndIf
				Else
					If Type("M->B45_SEQB1N") <> "U"
						M->B45_SEQB1N := Space(Len(M->B45_SEQB1N))
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Retorno da Funcao...
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CarObjRmb ³ Autor ³ Thiago Guilherme   ³ Data ³ 23.04.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna objeto do grid de procedimentos que será utilizado
na consulta padrão do campo B45_CODPRO para não permitir incluir o mesmi
procedimento duas vezes								                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CarObjRmb(OGridRmb)
__oGrdRee := OGridRmb
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPEGRAU ³ Autor ³ Thiago Ribas   ³ Data ³ 23.04.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de grau de participação                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPEGRAU(cCodPad,lAll,cCondSQLAd)
LOCAL nLin       	:= 1
LOCAL nOpca      	:= 0
LOCAL cChave     	:= Space(40)
LOCAL cTipoPes   	:= ""
LOCAL cCabec		:= ""
LOCAL cCodInt  		:= ""
LOCAL cCodRDA		:= ""
LOCAL oDlgPesPro    := NIL
LOCAL oTipoPes		:= NIL
LOCAL oBrowPro		:= NIL
LOCAL oGetChave		:= NIL
LOCAL oChkChk		:= NIL
LOCAL aBrowPro   	:= {}
LOCAL aVetPad    	:= { {"","",0,"",""} }
LOCAL bRefresh   	:= { || PLSAPPRO(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowPro,aVetPad,oBrowPro,cCodPad,lAll,cCondSQLAd,cCodRDA,cCodInt,cVarRead), If( Empty(aBrowPro[1,1]) .And. !Empty(cChave),.F.,.T. )  }
LOCAL cValid     	:= "{|| Eval(bRefresh) }"
LOCAL bOK        	:= { || nLin := oBrowPro:nAt,nOpca := 1,lOk:=.T.,oDlgPesPro:End() }
LOCAL bCanc      	:= { || nOpca := 3,oDlgPesPro:End() }
LOCAL aTipoPes   	:= {}
LOCAL lChkChk    	:= .F.
LOCAL lRet		 	:= .F.
LOCAL aButtons   	:= {}
LOCAL dDatPro		:= dDataBase
LOCAL cVarRead		:= ReadVar()
Local aCampos := {}
Local aBls    := {}
DEFAULT lAll     	:= .T.
DEFAULT cCondSQLAd  := ""
DEFAULT cCodPad		:= ""
PRIVATE aOpcoes   	:= {}

//Não permite efetuar a consulta se o campo B45_CODPRO estiver vazio.
If EMPTY(M->B45_CODPRO)
	Help("",1,"PL001100")
	Return lRet
EndIf

dbSelectArea("BWT")

cCabecAux 	:= "B44"
cCabec 		:= "B44"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Preencho os parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cCabec)

	If &(cCabecAux+"->(FieldPos('"+cCabecAux+"_CODOPE'))") > 0
		cCodInt	:= &("M->"+cCabec+"_CODOPE")
	EndIf

	If Empty(cCodInt) .And. &(cCabecAux+"->(FieldPos('"+cCabecAux+"_OPERDA'))") > 0
		cCodInt	:= &("M->"+cCabec+"_OPERDA")
	EndIf

	If Empty(cCodInt) .And. &(cCabecAux+"->(FieldPos('"+cCabecAux+"_CODINT'))") > 0
		cCodInt	:= &("M->"+cCabec+"_CODINT")
	EndIf

	If &(cCabecAux+"->(FieldPos('"+cCabecAux+"_CODRDA'))") > 0
		cCodRDA	:= &("M->"+cCabec+"_CODRDA")
	EndIf
	If &(cCabecAux+"->(FieldPos('"+cCabecAux+"_DATPRO'))") > 0
		dDatPro	:=  &("M->"+cCabec+"_DATPRO")
	EndIf
EndIf

If ExistBlock("PLSPES")
   lRet := ExecBlock("PLSPES",.F.,.F.,{cCodPad})
Else
	aBrowPro := aClone(aVetPad)

	aTipoPes := {"1-Unidade"}
	aadd(aOpcoes,{"BWT_CODPAR"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define dialogo...                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgPesPro TITLE STR0088 FROM 008.2,000 TO 030,ndColFin OF GetWndDefault() //"Grau de Participação"

    If Val(GetVersao(.F.)) >= 12
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetChave := TGet():New(040,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Browse...                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oBrowPro := TcBrowse():New( 058, 008, 378, If(cPaisLoc=="BRA",075,090),,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

		ADD COLUMN TO oBrowPro BITMAP DATA { || LoadBitmap( GetResources(), aBrowPro[oBrowPro:nAt,4] ) } TITLE "" WIDTH 015 ALIGN CENTERED NOHILITE

		oBrowPro:AddColumn(TcColumn():New("Unidade" ,nil,;
	         nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))
	         oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,1] }
		oBrowPro:AddColumn(TcColumn():New("Descrição",nil,;
	         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	         oBrowPro:ACOLUMNS[3]:BDATA := { || aBrowPro[oBrowPro:nAt,2] }

		@ 040,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE
	 	@ 040,315 CHECKBOX oChkChk   Var lChkChk PROMPT STR0049 PIXEL SIZE 080, 010 OF oDlgPesPro//"Pesquisar Palavra Chave"

		oBrowPro:SetArray(aBrowPro)
		oBrowPro:BLDBLCLICK := bOK
		oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		oGetChave := TGet():New(020,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Browse...                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oBrowPro := TcBrowse():New( 043, 008, 378, If(cPaisLoc=="BRA",075,090),,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

		ADD COLUMN TO oBrowPro BITMAP DATA { || LoadBitmap( GetResources(), aBrowPro[oBrowPro:nAt,4] ) } TITLE "" WIDTH 015 ALIGN CENTERED NOHILITE

		oBrowPro:AddColumn(TcColumn():New("Unidade" ,nil,;
	         nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))
	         oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,1] }
		oBrowPro:AddColumn(TcColumn():New("Descrição",nil,;
	         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	         oBrowPro:ACOLUMNS[3]:BDATA := { || aBrowPro[oBrowPro:nAt,2] }

		@ 020,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE
	 	@ 020,315 CHECKBOX oChkChk   Var lChkChk PROMPT STR0049 PIXEL SIZE 080, 010 OF oDlgPesPro//"Pesquisar Palavra Chave"

		oBrowPro:SetArray(aBrowPro)
		oBrowPro:BLDBLCLICK := bOK
		oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}

		PLSAPPRO(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowPro,aVetPad,oBrowPro,cCodPad,lAll,cCondSQLAd,cCodRDA,cCodInt,cVarRead)
	EndIf

	//-- LGPD --------  
	if objCENFUNLGP:isLGPDAt()  
		aCampos := {.T.,"BWT_CODPAR","BWT_DESCRI" }  
		aBls := objCENFUNLGP:getTcBrw(aCampos)  
		oBrowPro:aObfuscatedCols := aBls  
	endif  
	//---------------- 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa o Dialogo...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || oBrowPro:Refresh(), EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.,aButtons) }) CENTERED
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ OK
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If nOpca == K_OK

		lRet := .T.
		If !Empty( aBrowPro[nLin,1] )

			BWT->( DbGoTo(aBrowPro[nLin,3]) )
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Retorno da Funcao...
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSAPPRO ³ Autor ³ Thiago Ribas   ³ Data ³ 07.05.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa o Grau de participação ...              ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSAPPRO(cChave,cTipoPes,lChkChk,aBrowPro,aVetPad,oBrowPro,cCodPad,lAll,cCondSQLAd,cCodRDA,cCodInt,cVarRead)
LOCAL aArea   	:= GetArea()
LOCAL lRet		:= .F.
LOCAL cSQL      := ""

DEFAULT cVarRead := ""

cAlias := "B44"

If '"' $ cChave .Or. "'" $ cChave
   Aviso( STR0018,STR0019,{ STR0028}, 2 )//"Caracter Invalido"//"Existem caracteres invalidos em sua pesquisa."
   Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa resultado...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aBrowPro := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Veio de uma liberacao ou foi informado participacao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

cSQL := "SELECT BWT_DESCRI, BWT_CODPAR, BD4_CODPRO," + RetSQLNAME("BWT") + ".R_E_C_N_O_ AS RECNO "
cSQL += "FROM " + RetSQLNAME("BWT")
cSQL += " INNER JOIN " + RetSQLNAME("BD4")
cSQL += " ON  BWT_CODPAR = BD4_CODTPA AND BWT_FILIAL = '" + xFilial("BWT") + "' AND BD4_FILIAL = '" + xFilial("BD4") + "' "
cSQL += " WHERE BD4_CODPRO = '" + M->B45_CODPRO + "' AND "
cSQL += IIF(!EMPTY(cChave) .AND. cChave != "_", "BWT_CODPAR = '" + cChave + "' AND ","")
cSQL += RetSQLNAME("BWT") + ".D_E_L_E_T_ = '' AND " + RetSQLNAME("BD4") + ".D_E_L_E_T_ = '' "
cSQL += "GROUP BY BWT_DESCRI, BWT_CODPAR, BD4_CODPRO, " + RetSQLNAME("BWT") + ".R_E_C_N_O_"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ executa a query
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'''
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbPes",.F.,.T.)

TrbPes->( DbGoTop() )
While !TrbPes->( Eof() )

	AaDd( aBrowPro,{  TrbPes->BWT_CODPAR,ALLTRIM(TrbPes->BWT_DESCRI),TrbPes->RECNO, "BR_VERDE" ,M->B45_CODPAD } )
	TrbPes->( DbSkip() )
EndDo

TrbPes->( DbCloseArea() )

RestArea(aArea)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa resultado da pesquisa...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aBrowPro) == 0
   aBrowPro := aClone(aVetPad)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza browse...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowPro:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
                  // uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
                  // Exemplo:
                  // 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
                  // (via seta para cima ou clique na primeira linha)
                  // 2a. Pesquisa: "AV" - Ocorria o erro
oBrowPro:SetArray(aBrowPro)
oBrowPro:Refresh()
oBrowPro:SetFocus()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESBEN ³ Autor ³ Thiago Ribas   ³ Data ³ 23.04.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de beneficiário		                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPESBEN()
LOCAL nLin       	:= 1
LOCAL nOpca      	:= 0
LOCAL cChave     	:= Space(40)
LOCAL cTipoPes   	:= ""
LOCAL oDlgPesPro    := NIL
LOCAL oTipoPes		:= NIL
LOCAL oBrowPro		:= NIL
LOCAL oGetChave		:= NIL
LOCAL oChkChk		:= NIL
LOCAL aBrowPro   	:= {}
LOCAL aVetPad    	:= { {"","",0,""} }
LOCAL cValid     	:= "{|| Eval(bRefresh) }"
LOCAL bOK        	:= { || nLin := oBrowPro:nAt,nOpca := 1,lOk:=.T.,oDlgPesPro:End() }
LOCAL bCanc      	:= { || nOpca := 3,oDlgPesPro:End() }
LOCAL aTipoPes   	:= {}
LOCAL lChkChk    	:= .F.
LOCAL lRet		 	:= .F.
LOCAL aButtons   	:= {}
LOCAL dDatPro		:= dDataBase
LOCAL cVarRead		:= ReadVar()
LOCAL bRefresh   	:= { || PLSABEN(oBrowPro,aBrowPro,cChave, cTipoPes,cVarRead), If( Empty(aBrowPro[1,1]) .And. !Empty(cChave),.F.,.T. )  }
LOCAL lExiCdRas     := BA3->(fieldPos('BA3_CODRAS')) > 0
Local aCampos 	:= {}
Local aBls    	:= {}

PRIVATE aOpcoes   	:= {}

	aBrowPro := aClone(aVetPad)

	aTipoPes := {"1-Matrícula", "2-Nome"}
	aadd(aOpcoes,{"BA1_MATRIC"})
	aadd(aOpcoes,{"BA1_NOMUSR"})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define dialogo...                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgPesPro TITLE STR0088 FROM 008.2,000 TO 030,ndColFin OF GetWndDefault() //"Grau de Participação"

    If Val(GetVersao(.F.)) >= 12
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetChave := TGet():New(040,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Browse...                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oBrowPro := TcBrowse():New( 058, 008, 378, 100,,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

		oBrowPro:AddColumn(TcColumn():New("Matricula" ,nil,;
	    			       nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	         			   oBrowPro:ACOLUMNS[1]:BDATA := { || aBrowPro[oBrowPro:nAt,1] }
		
		oBrowPro:AddColumn(TcColumn():New("Nome",nil,;
	         			   nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	         			   oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,2] }
		
		If lExiCdRas 
		
			oBrowPro:AddColumn(TcColumn():New("Produto",nil,;
	         				   nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	         				   oBrowPro:ACOLUMNS[3]:BDATA := { || aBrowPro[oBrowPro:nAt,3] }
	        
			oBrowPro:AddColumn(TcColumn():New("Matríc. Família",nil,;
	         				   nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	         				   oBrowPro:ACOLUMNS[4]:BDATA := { || aBrowPro[oBrowPro:nAt,4] }
	 	EndIf 
		
		@ 040,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE

		oBrowPro:SetArray(aBrowPro)
		oBrowPro:BLDBLCLICK := bOK
		oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}

		PLSABEN(oBrowPro,aBrowPro,,,cVarRead)

		//-- LGPD --------  
		if objCENFUNLGP:isLGPDAt()  
			If lExiCdRas
				aCampos := {"BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO","BA1_NOMUSR","BI3_DESCRI","BA1_MATRIC" }  
			Else
				aCampos := {"BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO","BA1_NOMUSR" }  
			EndIf
			aBls := objCENFUNLGP:getTcBrw(aCampos)  
			oBrowPro:aObfuscatedCols := aBls  
		endif  
		//---------------- 
		
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa o Dialogo...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || oBrowPro:Refresh(), EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.,aButtons) }) CENTERED
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ OK
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If nOpca == K_OK

		lRet := .T.
		If !Empty( aBrowPro[nLin,1] )
			
			If lExiCdRas
				BA1->( DbGoTo(aBrowPro[nLin,5]) )
			Else
				BA1->( DbGoTo(aBrowPro[nLin,3]) )
			EndIf
		EndIf
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Retorno da Funcao...
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSABEN ³ Autor ³ Thiago Ribas   ³ Data ³ 07.05.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a consulta do beneficiário no reembolso             ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSABEN(oBrowPro, aBrowPro, cChave, cTipo, cVarMemor, lAutomato) 

LOCAL aArea   	:= GetArea()
LOCAL lRet		:= .F.
LOCAL cSQL      := ""
LOCAL aVetPad   := { {"","",0,""} }
LOCAL cCodFam	:= ""
LOCAL cTypeDB	:= AllTrim( TCGetDB() )
LOCAL lBA3Codra := BA3->(fieldPos('BA3_CODRAS')) > 0  
LOCAL cCodRas   := "" 

DEFAULT lAutomato := .F.
DEFAULT aBrowPro  := {}
DEFAULT cChave    := ""

If cVarMemor == "M->B1N_MATRIC" .OR. FunName() == "PLSA001A"
	cCodFam := ALLTRIM(M->(BOW_OPERDA + BOW_CODEMP + BOW_MATRIC))

ElseIf cVarMemor == "M->B45_MATRIC"
	cCodFam := ALLTRIM(M->(B44_OPEUSR + B44_CODEMP + B44_MATRIC))

ELSEIF ( IsinCallStack("PLSR788") .And. !(Empty(MV_PAR05)) )  //Reembolso Analítico
 	cCodFam := Substr(MV_PAR05,1,14)

ELSEIF ( IsinCallStack("PLSR789") .And. !(Empty(MV_PAR04)) ) //Extrato de Utilização
 	cCodFam := Substr(MV_PAR04,1,14)

ELSEIF ( IsinCallStack("U_PLSR001") .And. !(Empty(MV_PAR04)) ) //Extrato Financeiro
 	cCodFam := Substr(MV_PAR04,1,14)

ELSEIF lAutomato
	cCodFam := GetParAuto('CodRastTestCase')[1]
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa resultado...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aBrowPro := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Veio de uma liberacao ou foi informado participacao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
IF ExistBlock("PLSMATRMB")

	aBrowPro := ExecBlock("PLSMATRMB",.F.,.F.)
Else
	
	If cTypeDB $ "ORACLE|DB2|POSTGRES"
		cSQL := "SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_CODINT || BA1_CODEMP || BA1_MATRIC || BA1_TIPREG || BA1_DIGITO AS MATRIC, BA1_NOMUSR, " + RetSQLNAME("BA1") + ".R_E_C_N_O_ AS RECNO "
	Else
		cSQL := "SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO AS MATRIC, BA1_NOMUSR, " + RetSQLNAME("BA1") + ".R_E_C_N_O_ AS RECNO "
	EndIf
	
	If lBA3Codra 
		cSQL += ", BA3_CODRAS, BA3_CODPLA "
	EndIf
	
	cSQL += "FROM " + RetSQLNAME("BA1")
	
	If lBA3Codra 
		
		cSQL += " INNER JOIN " + RetSQLNAME("BA3")
		cSQL += " ON BA3_CODINT = BA1_CODINT AND BA3_CODEMP = BA1_CODEMP AND BA3_MATRIC = BA1_MATRIC "
	EndIf 
	
	If EMPTY(cChave) .OR. ALLTRIM(cChave) == "_"
	
		If cTypeDB $ "ORACLE|DB2|POSTGRES"
			cSQL += " WHERE BA1_FILIAL || BA1_CODINT || BA1_CODEMP || BA1_MATRIC = '" + xFilial("BA1") + cCodFam + "' AND "
		Else
			cSQL += " WHERE BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC = '" + xFilial("BA1") + cCodFam + "' AND "
		EndIf
	
	ElseIf SUBSTR(cTipo,1,1)== "1"
		
		If cTypeDB $ "ORACLE|DB2|POSTGRES"
			cSQL += " WHERE BA1_FILIAL || BA1_CODINT || BA1_CODEMP || BA1_MATRIC || BA1_TIPREG || BA1_DIGITO LIKE '%" + xFilial("BA1") + ALLTRIM(cChave) + "%' AND "
		Else
			cSQL += " WHERE BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO LIKE '%" + xFilial("BA1") + ALLTRIM(cChave) + "%' AND "
		EndIf
	
	ElseIf SUBSTR(cTipo,1,1)== "2"
		
		If cTypeDB $ "ORACLE|DB2|POSTGRES"
			cSQL += " WHERE BA1_FILIAL || BA1_NOMUSR LIKE '%" + xFilial("BA1") + ALLTRIM(cChave) + "%' AND "
			cSQL += " BA1_FILIAL || BA1_CODINT || BA1_CODEMP || BA1_MATRIC = '" + xFilial("BA1") + cCodFam + "' AND "
		Else
			cSQL += " WHERE BA1_FILIAL + BA1_NOMUSR LIKE '%" + xFilial("BA1") + ALLTRIM(cChave) + "%' AND "
			cSQL += " BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC = '" + xFilial("BA1") + cCodFam + "' AND "
		EndIf
	EndIf
	
	cSQL += RetSQLNAME("BA1") + ".D_E_L_E_T_ = '' "
	
	If lBA3Codra 
		cSQL += " AND " + RetSQLName("BA3") + ".D_E_L_E_T_ = '' "
	EndIf 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ executa a query
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbPes",.F.,.T.)
	
	TrbPes->( DbGoTop() )
	While !TrbPes->( Eof() )
	
		If TrbPes->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC) == cCodFam
			
			If lBA3Codra
				TrbPes->( AaDd( aBrowPro,{ MATRIC, ALLTRIM(BA1_NOMUSR), ;
					                       ALLTRIM( Posicione("BI3", 1, xFilial("BI3") + BA1_CODINT + BA3_CODPLA,"BI3_DESCRI") ), ;
					                       BA1_MATRIC,TrbPes->RECNO} ) )
					                       
				cCodRas := TrbPes->BA3_CODRAS
			Else
				TrbPes->( AaDd( aBrowPro,{  MATRIC,BA1_NOMUSR,TrbPes->RECNO} ) )
			EndIf
		EndIf
		TrbPes->( DbSkip() )
	EndDo
	
	TrbPes->( DbCloseArea() )
	
	//Busca as famílias vinculadas a família atual
	If lBA3Codra .AND. !EMPTY(cCodRas)
		cSQL := " SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO,BA1_NOMUSR, BA3_CODPLA, " + RetSQLNAME("BA1") + ".R_E_C_N_O_ AS RECNO "
		cSQL += " FROM " + RetSqlName("BA1")
		cSQL += " INNER JOIN " + RetSqlName("BA3")
		cSQL += " ON BA3_CODINT = BA1_CODINT AND BA3_CODEMP = BA1_CODEMP AND BA3_MATRIC = BA1_MATRIC"
		cSQL += " WHERE"
		cSQL += " BA3_CODRAS = '" + cCodRas + "' AND BA3_DATBLO <> ' ' AND BA3_DATBLO <= '" + DTOS(dDataBase) + "' AND "
		cSQL += RetSqlName("BA3")+".D_E_L_E_T_ = ' ' AND " + RetSqlName("BA1")+".D_E_L_E_T_ = ' '"
		cSQL += " ORDER BY BA3_CODPLA"
		
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbCodRas",.F.,.T.) 
		
		TrbCodRas->( DbGoTop() )
		
		While !TrbCodRas->( Eof() )
	
			If lBA3Codra
				TrbCodRas->( AaDd( aBrowPro,{ TrbCodRas->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO), ALLTRIM(BA1_NOMUSR), ;
					                          ALLTRIM( Posicione("BI3", 1, xFilial("BI3") + BA1_CODINT + BA3_CODPLA,"BI3_DESCRI") ), ;
					                          BA1_MATRIC,TrbCodRas->RECNO} ) )
			EndIf
			
			TrbCodRas->( DbSkip() )
		EndDo
		
		TrbCodRas->( DbCloseArea() )
	EndIf
EndIf	

RestArea(aArea)

If !lAutomato

	If Len(aBrowPro) == 0
		aBrowPro := aClone(aVetPad)
	EndIf

	// Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
	// uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
	// Exemplo:
	// 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
	// (via seta para cima ou clique na primeira linha)
	// 2a. Pesquisa: "AV" - Ocorria o erro
	oBrowPro:nAt := 1 

	oBrowPro:SetArray(aBrowPro)
	oBrowPro:Refresh()
	oBrowPro:SetFocus()
EndIf

Return If(lAutomato, aBrowPro, .T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSUNDMED ³ Autor ³ Thiago Ribas   ³ Data ³ 23.04.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa de unidade de medida			                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSUNDMED()
LOCAL nLin       	:= 1
LOCAL nOpca      	:= 0
LOCAL cChave     	:= Space(40)
LOCAL cTipoPes   	:= ""
LOCAL oDlgPesPro    := NIL
LOCAL oTipoPes		:= NIL
LOCAL oBrowPro		:= NIL
LOCAL oGetChave		:= NIL
LOCAL oChkChk		:= NIL
LOCAL aBrowPro   	:= {}
LOCAL aVetPad    	:= { {"","",0,""} }
LOCAL bRefresh   	:= { || PLSUNMEDI(oBrowPro,aBrowPro,cChave, cTipoPes), If( Empty(aBrowPro[1,1]) .And. !Empty(cChave),.F.,.T. )  }
LOCAL cValid     	:= "{|| Eval(bRefresh) }"
LOCAL bOK        	:= { || nLin := oBrowPro:nAt,nOpca := 1,lOk:=.T.,oDlgPesPro:End() }
LOCAL bCanc      	:= { || nOpca := 3,oDlgPesPro:End() }
LOCAL aTipoPes   	:= {}
LOCAL lChkChk    	:= .F.
LOCAL lRet		 	:= .F.
LOCAL aButtons   	:= {}
LOCAL dDatPro		:= dDataBase
LOCAL nQtd			:= 0
LOCAL cVarRead		:= ReadVar()
Local aCampos := {}
Local aBls    := {}

PRIVATE aOpcoes   	:= {}

If PLSALIASEXI("BVN")

	//Verifica vigência de acordo com a regra da TISS 3
	cSQL := "SELECT BTQ_VIGATE "
	cSQL += "  FROM " + retSQLNAME("BTQ")
	cSQL += " WHERE BTQ_FILIAL = '" + xFilial("BTQ") + "' "
	cSQL += "   AND BTQ_CODTAB =  '60' "
	cSQL += "   AND BTQ_VIGDE <= '" + dtos(dDataBase) + "' AND ( BTQ_VIGATE >= '" + dtos(dDataBase) + "' OR BTQ_VIGATE = ' ' ) "
	cSQL += "   AND D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBTQ",.F.,.T.)
	
	Count To nQtd

	If nQtd == 0
		MsgAlert(STR0090)
	 	TRBBTQ->(DbCloseArea())
	 	Return .F.
	EndIf
	
	TRBBTQ->(DbCloseArea())

	dbSelectArea("BTQ")

	aBrowPro := aClone(aVetPad)

	aTipoPes := {"1-Und. Medida", "2-Descricao"}
	aadd(aOpcoes,{"BTQ_DESTER"})
	aadd(aOpcoes,{"BTQ_DSCDET"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define dialogo...                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgPesPro TITLE "Unidade de Medida" FROM 008.2,000 TO 030,ndColFin OF GetWndDefault() //"Unidade de Medida"

    If Val(GetVersao(.F.)) >= 12
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetChave := TGet():New(040,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Browse...                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oBrowPro := TcBrowse():New( 058, 008, 378, If(cPaisLoc=="BRA",075,090),,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

		ADD COLUMN TO oBrowPro BITMAP DATA { || LoadBitmap( GetResources(), aBrowPro[oBrowPro:nAt,4] ) } TITLE "" WIDTH 015 ALIGN CENTERED NOHILITE // Coluna 1 é a BR_VERDE

		oBrowPro:AddColumn(TcColumn():New("Und. Medida" ,nil,;
	         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	         oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,1] } // coluna 2 é a Unidade
		oBrowPro:AddColumn(TcColumn():New("Descricao",nil,;
	         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	         oBrowPro:ACOLUMNS[3]:BDATA := { || aBrowPro[oBrowPro:nAt,2] } // coluna 3 é a descrição

		@ 040,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE

		oBrowPro:SetArray(aBrowPro)
		oBrowPro:BLDBLCLICK := bOK
		oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}

		PLSUNMEDI(oBrowPro,aBrowPro,cChave, cTipoPes) // Atualiza os dados do browser

		//-- LGPD --------  
		if objCENFUNLGP:isLGPDAt()  
			aCampos := {.F.,"BTQ_DESTER","BTQ_DSCDET" }  
			aBls := objCENFUNLGP:getTcBrw(aCampos)  
			oBrowPro:aObfuscatedCols := aBls  
		endif  
		//---------------- 

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		oGetChave := TGet():New(020,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Browse...                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oBrowPro := TcBrowse():New( 043, 008, 378, If(cPaisLoc=="BRA",075,090),,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

		oBrowPro:AddColumn(TcColumn():New("Und. Medida" ,nil,;
	         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	         oBrowPro:ACOLUMNS[1]:BDATA := { || aBrowPro[oBrowPro:nAt,1] }
		oBrowPro:AddColumn(TcColumn():New("Descricao",nil,;
	         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	         oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,2] }

		@ 020,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE
	 	@ 020,315 CHECKBOX oChkChk   Var lChkChk PROMPT STR0049 PIXEL SIZE 080, 010 OF oDlgPesPro//"Pesquisar Palavra Chave"

		oBrowPro:SetArray(aBrowPro)
		oBrowPro:BLDBLCLICK := bOK
		oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}

		PLSUNMEDI(oBrowPro,aBrowPro)

		//-- LGPD --------  
		if objCENFUNLGP:isLGPDAt()  
			aCampos := {"BTQ_DESTER","BTQ_DSCDET" }  
			aBls := objCENFUNLGP:getTcBrw(aCampos)  
			oBrowPro:aObfuscatedCols := aBls  
		endif  
		//---------------- 

	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa o Dialogo...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || oBrowPro:Refresh(), EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.,aButtons) }) CENTERED
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ OK
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If nOpca == K_OK

		lRet := .T.
		If !Empty( aBrowPro[nLin,1] )

			BTQ->( DbGoTo(aBrowPro[nLin,3]) )
		EndIf
	EndIf

Else
	MsgAlert(STR0089)
	Return .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Retorno da Funcao...
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSUNMEDI ³ Autor ³ Thiago Ribas   ³ Data ³ 07.05.15      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a consulta da unidade de medida                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSUNMEDI(oBrowPro, aBrowPro, cChave, cTipo)
LOCAL aArea   	:= GetArea()
LOCAL lRet		:= .F.
LOCAL cSQL      := ""
LOCAL aVetPad    	:= { {"","",0,""} }
DEFAULT cChave  := "_"

//Limpa resultado...                                                       
aBrowPro := {}

//Veio de uma liberacao ou foi informado participacao
cSQL := " SELECT BTQ_DESTER, BTQ_DSCDET, R_E_C_N_O_ AS RECNO "
cSQL += "   FROM " + RetSQLNAME("BTQ")
cSQL += "  WHERE BTQ_FILIAL = '" + xFilial("BTQ") + "' "
cSQL += "    AND BTQ_CODTAB = '60' "
cSQL += "    AND BTQ_VIGDE <= '" + dtos(dDataBase) + "' AND ( BTQ_VIGATE >= '" + dtos(dDataBase) + "' OR BTQ_VIGATE = ' ' ) "

if subStr(cTipo,1,1) == "1"
	
	cSQL += "   AND BTQ_DESTER LIKE '%" + allTrim(cChave) + "%' "

elseIf subStr(cTipo,1,1)== "2"

	cSQL += "   AND BTQ_DSCDET LIKE '%" + allTrim(cChave) + "%' "

endIf

cSQL += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cSQL)),"TrbPes",.F.,.T.)

TrbPes->( DbGoTop() )
While !TrbPes->( Eof() )

	TrbPes->( AaDd( aBrowPro,{  Alltrim(BTQ_DESTER),Alltrim(BTQ_DSCDET),TrbPes->RECNO, "BR_VERDE"} ) )
	TrbPes->( DbSkip() )
EndDo

TrbPes->( DbCloseArea() )

RestArea(aArea)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa resultado da pesquisa...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aBrowPro) == 0
   aBrowPro := aClone(aVetPad)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza browse...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowPro:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
                  // uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
                  // Exemplo:
                  // 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
                  // (via seta para cima ou clique na primeira linha)
                  // 2a. Pesquisa: "AV" - Ocorria o erro
oBrowPro:SetArray(aBrowPro)
oBrowPro:Refresh()
oBrowPro:SetFocus()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESMED ³ Autor ³ Thiago Ribas   ³ Data ³ 23.04.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa medicamento da receita	do beneficiário          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPESMED()

LOCAL nLin       	:= 1
LOCAL nOpca      	:= 0
LOCAL cChave     	:= Space(40)
LOCAL cTipoPes   	:= ""
LOCAL oDlgPesPro    := NIL
LOCAL oTipoPes		:= NIL
LOCAL oBrowPro		:= NIL
LOCAL oGetChave		:= NIL
LOCAL oChkChk		:= NIL
LOCAL aBrowPro   	:= {}
LOCAL aVetPad    	:= { {"","",0,""} }
LOCAL bRefresh   	:= { || PLSRETMED(oBrowPro,aBrowPro,cChave, cTipoPes), If( Empty(aBrowPro[1,1]) .And. !Empty(cChave),.F.,.T. )  }
LOCAL cValid     	:= "{|| Eval(bRefresh) }"
LOCAL bOK        	:= { || nLin := oBrowPro:nAt,nOpca := 1,lOk:=.T.,oDlgPesPro:End() }
LOCAL bCanc      	:= { || nOpca := 3,oDlgPesPro:End() }
LOCAL aTipoPes   	:= {}
LOCAL lChkChk    	:= .F.
LOCAL lRet		 	:= .F.
LOCAL aButtons   	:= {}
LOCAL dDatPro		:= dDataBase
LOCAL cVarRead		:= ReadVar()
Local aCampos := {}
Local aBls    := {}

PRIVATE aOpcoes   	:= {}

dbSelectArea("BR8")
aBrowPro := aClone(aVetPad)
aTipoPes := {"1-Código Proc.", "2-Descrição"}
aadd(aOpcoes,{"B7D_CODMED"})
aadd(aOpcoes,{"BR8_DESCRI"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define dialogo...                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPesPro TITLE "Itens da Receita" FROM 008.2,000 TO 030,ndColFin OF GetWndDefault() //"Itens da Receita"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetChave := TGet():New(035,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Browse...                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowPro := TcBrowse():New( 060, 008, 378, If(cPaisLoc=="BRA",075,090),,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrowPro:AddColumn(TcColumn():New("Cod. Receita" ,nil,;
	nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowPro:ACOLUMNS[1]:BDATA := { || aBrowPro[oBrowPro:nAt,1] }

oBrowPro:AddColumn(TcColumn():New("Cod. Proc" ,nil,;
	nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,2] }

oBrowPro:AddColumn(TcColumn():New("Descri. proc.",nil,;
	nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowPro:ACOLUMNS[3]:BDATA := { || aBrowPro[oBrowPro:nAt,3] }

oBrowPro:AddColumn(TcColumn():New("Validade Ini.",nil,;
	nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowPro:ACOLUMNS[4]:BDATA := { || aBrowPro[oBrowPro:nAt,4] }

oBrowPro:AddColumn(TcColumn():New("Validade Final",nil,;
	nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowPro:ACOLUMNS[5]:BDATA := { || aBrowPro[oBrowPro:nAt,5] }

@ 035,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE
@ 035,315 CHECKBOX oChkChk   Var lChkChk PROMPT STR0049 PIXEL SIZE 080, 010 OF oDlgPesPro//"Pesquisar Palavra Chave"
oBrowPro:SetArray(aBrowPro)
oBrowPro:BLDBLCLICK := bOK
oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}
PLSRETMED(oBrowPro, aBrowPro, cChave, cTipoPes)

//-- LGPD --------  
if objCENFUNLGP:isLGPDAt()  
	aCampos := {"B7D_CODREC","B7D_CODMED","BR8_DESCRI","B7D_DTVINI","B7D_DTFVAL" }  
	aBls := objCENFUNLGP:getTcBrw(aCampos)  
	oBrowPro:aObfuscatedCols := aBls  
endif  
//---------------- 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa o Dialogo...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || oBrowPro:Refresh(), EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.,aButtons) }) CENTERED
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ OK
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nOpca == K_OK
	If !Empty( aBrowPro[nLin,1] )
		lRet := .T.
		B7D->( DbGoTo(aBrowPro[nLin,7]) ) 
	EndIf
EndIf
GatCampo()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Retorno da Funcao...
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSRETMED ³ Autor ³ Thiago Ribas   ³ Data ³ 07.05.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os medicamentos da receita selecionada            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSRETMED(oBrowPro, aBrowPro, cChave, cTipo)

LOCAL aArea   	:= GetArea()
LOCAL lRet		:= .T.
LOCAL cSQL      := ""
LOCAL aVetPad    	:= { {"","","",CTOD(""),CTOD(""),0} }

aBrowPro := {}
cSQL := "SELECT B7D_CODREC, B7D_CODMED, BR8_DESCRI,B7D_DTVINI,B7D_DTFVAL,B7D_SEQUEN, " + RetSQLNAME("B7D") + ".R_E_C_N_O_ AS RECNO " 
cSQL +=  " FROM " + RetSQLNAME("B7D")
cSQL += " INNER JOIN " + RetSQLNAME("BR8")
cSQL +=    " ON B7D_CODPAD = BR8_CODPAD AND B7D_CODMED = BR8_CODPSA AND B7D_FILIAL = '" + xFilial("B7D") + "' AND BR8_FILIAL = '" + xFilial("BR8") + "' "
If EMPTY(cChave) .OR. ALLTRIM(cChave) == "_"
	cSQL += " AND B7D_BENEFI = '" + M->B1N_MATRIC + "' "
ElseIf SUBSTR(cTipo,1,1)== "1"
	cSQL += " AND B7D_BENEFI = '" + M->B1N_MATRIC + "' "
	cSQL += " AND B7D_CODMED LIKE '%" + ALLTRIM(cChave) + "%' "
ElseIf SUBSTR(cTipo,1,1)== "2"
	cSQL += " AND B7D_BENEFI = '" + M->B1N_MATRIC + "' "
	cSQL += " AND BR8_DESCRI LIKE '%" + ALLTRIM(cChave) + "%' "
EndIf
cSQL += " AND B7D_DTVINI <= '" + DTOS(dDataBase) + "' AND (B7D_DTFVAL >= '" + DTOS(dDataBase) + "' OR B7D_DTFVAL = ' ') "
cSQL += " AND B7D_QTDAUT > B7D_QTDEXE "
cSQL += " AND " + RetSQLNAME("B7D") + ".D_E_L_E_T_ = '' AND " + RetSQLNAME("BR8") + ".D_E_L_E_T_ = '' "
cSQL += "GROUP BY B7D_CODREC, B7D_CODMED, BR8_DESCRI,B7D_DTVINI,B7D_DTFVAL,B7D_SEQUEN, " + RetSQLNAME("B7D") + ".R_E_C_N_O_" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ executa a query
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'''
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbPesMed",.F.,.T.)
TrbPesMed->( DbGoTop() )
While !TrbPesMed->( Eof() )
	TrbPesMed->( AaDd( aBrowPro,{  B7D_CODREC,B7D_CODMED,ALLTRIM(BR8_DESCRI),STOD(B7D_DTVINI), STOD(B7D_DTFVAL), B7D_SEQUEN, TrbPesMed->RECNO, "BR_VERDE"} ) ) 
	TrbPesMed->( DbSkip() )
EndDo
TrbPesMed->( DbCloseArea() )
RestArea(aArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa resultado da pesquisa...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aBrowPro) == 0
	aBrowPro := aClone(aVetPad)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza browse...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowPro:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
                  // uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
                  // Exemplo:
                  // 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
                  // (via seta para cima ou clique na primeira linha)
                  // 2a. Pesquisa: "AV" - Ocorria o erro
oBrowPro:SetArray(aBrowPro)
oBrowPro:Refresh()
oBrowPro:SetFocus()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESBTT ³ Autor ³ Renan Martins   ³ Data ³ 11/2015      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de beneficiário titular                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPESBTT(cTipoT, cParam)
LOCAL nLin       	:= 1
LOCAL nOpca      	:= 0
LOCAL cChave     	:= Space(40)
LOCAL cTipoPes   	:= ""
LOCAL oDlgPesPro    := NIL
LOCAL oTipoPes		:= NIL
LOCAL oBrowPro		:= NIL
LOCAL oGetChave		:= NIL
LOCAL oChkChk		:= NIL
LOCAL aBrowPro   	:= {}
LOCAL aVetPad    	:= { {"","",0,""} }
LOCAL cValid     	:= "{|| Eval(bRefresh) }"
LOCAL bOK        	:= { || nLin := oBrowPro:nAt,nOpca := 1,lOk:=.T.,oDlgPesPro:End() }
LOCAL bCanc      	:= { || nOpca := 3,oDlgPesPro:End() } 
LOCAL aTipoPes   	:= {}
LOCAL lChkChk    	:= .F.
LOCAL lRet		 	:= .F.
LOCAL aButtons   	:= {}
LOCAL dDatPro		:= dDataBase
LOCAL cVarRead		:= ReadVar()
LOCAL bRefresh   	:= { || PLSABENTP(oBrowPro,aBrowPro,cChave, cTipoPes,cVarRead,cTipoT), If( Empty(aBrowPro[1,1]) .And. !Empty(cChave),.F.,.T. )  }
Local aCampos := {}
Local aBls    := {}
PRIVATE aOpcoes   	:= {}
Default cTipoT := "T"

dbSelectArea("BA1")

	aBrowPro := aClone(aVetPad)

	aTipoPes := {"1-Matrícula", "2-Nome"}
	aadd(aOpcoes,{"BA1_MATRIC"})
	aadd(aOpcoes,{"BA1_NOMUSR"})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define dialogo...                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgPesPro TITLE STR0008 FROM 008.2,000 TO 030,ndColFin OF GetWndDefault() //"Grau de Participação"

    If Val(GetVersao(.F.)) >= 12
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetChave := TGet():New(040,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Browse...                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oBrowPro := TcBrowse():New( 058, 008, 378, 100,,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

		oBrowPro:AddColumn(TcColumn():New("Matricula" ,nil,;
	         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	         oBrowPro:ACOLUMNS[1]:BDATA := { || aBrowPro[oBrowPro:nAt,1] }
		oBrowPro:AddColumn(TcColumn():New("Nome",nil,;
	         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	         oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,2] }

		@ 040,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE

		oBrowPro:SetArray(aBrowPro)
		oBrowPro:BLDBLCLICK := bOK
		oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}
		PLSABENTP(oBrowPro,aBrowPro,,,cVarRead, cTipoT, cParam)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		oGetChave := TGet():New(020,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Browse...                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oBrowPro := TcBrowse():New( 043, 008, 378, If(cPaisLoc=="BRA",075,090),,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

		oBrowPro:AddColumn(TcColumn():New("Matricula" ,nil,;
	         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	         oBrowPro:ACOLUMNS[1]:BDATA := { || aBrowPro[oBrowPro:nAt,1] }
		oBrowPro:AddColumn(TcColumn():New("Nome",nil,;
	         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
	         oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,2] }

		@ 020,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE
	 	@ 020,315 CHECKBOX oChkChk   Var lChkChk PROMPT STR0049 PIXEL SIZE 080, 010 OF oDlgPesPro//"Pesquisar Palavra Chave"

		oBrowPro:SetArray(aBrowPro)
		oBrowPro:BLDBLCLICK := bOK
		oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}

		PLSABENTP(oBrowPro,aBrowPro,,,cVarRead, cTipoT, cParam)
	EndIf

	//-- LGPD --------  
	if objCENFUNLGP:isLGPDAt()  
		aCampos := {"BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO","BA1_NOMUSR" }  
		aBls := objCENFUNLGP:getTcBrw(aCampos)  
		oBrowPro:aObfuscatedCols := aBls  
	endif  
	//---------------- 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa o Dialogo...                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || oBrowPro:Refresh(), EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.,aButtons) }) CENTERED
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ OK
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If nOpca == K_OK

		lRet := .T.
		If !Empty( aBrowPro[nLin,1] )

			BA1->( DbGoTo(aBrowPro[nLin,3]) )
		EndIf
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Retorno da Funcao...
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSABENTP ³ Autor ³ Renan Martins   ³ Data ³ 11/2015      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a consulta do beneficiários titulares             ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSABENTP(oBrowPro, aBrowPro, cChave, cTipo,cVarMemor,cTipoT, cParam)
LOCAL aArea   	:= GetArea()
LOCAL lRet		:= .F.
LOCAL cSQL      := ""
LOCAL aVetPad   := { {"","",0,""} }
LOCAL cCodFam	:= ""

/*If cTipo == "T"
	cCodFam := MV_PAR05
ENDIF*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa resultado...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aBrowPro := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Veio de uma liberacao ou foi informado participacao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If AllTrim( TCGetDB() ) $ "ORACLE|DB2|POSTGRES"
	cSQL := "SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_CODINT || BA1_CODEMP || BA1_MATRIC || BA1_TIPREG || BA1_DIGITO MATRICULA, BA1_NOMUSR,  " + RetSQLNAME("BA1") + ".R_E_C_N_O_ AS RECNO "
Else
	cSQL := "SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO MATRICULA, BA1_NOMUSR, " + RetSQLNAME("BA1") + ".R_E_C_N_O_ AS RECNO "
EndIf

cSQL += "FROM " + RetSQLNAME("BA1")

	If EMPTY(cChave) .OR. ALLTRIM(cChave) == "_"
			cSQL += " WHERE BA1_TIPUSU = 'T' AND "
	ElseIf SUBSTR(cTipo,1,1)== "1"
		If AllTrim( TCGetDB() ) $ "ORACLE|DB2|POSTGRES"
			cSQL += " WHERE BA1_FILIAL || BA1_CODINT || BA1_CODEMP || BA1_MATRIC || BA1_TIPREG || BA1_DIGITO LIKE '%" + xFilial("BA1") + ALLTRIM(cChave) + "%' AND BA1_TIPUSU = 'T' AND "
		Else
			cSQL += " WHERE BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO LIKE '%" + xFilial("BA1") + ALLTRIM(cChave) + "%' AND BA1_TIPUSU = 'T' AND "
		EndIf
	ElseIf SUBSTR(cTipo,1,1)== "2"
		If AllTrim( TCGetDB() ) $ "ORACLE|DB2|POSTGRES"
			cSQL += " WHERE BA1_FILIAL || BA1_NOMUSR LIKE '%" + xFilial("BA1") + ALLTRIM(cChave) + "%' AND BA1_TIPUSU = 'T' AND "
		Else
			cSQL += " WHERE BA1_FILIAL + BA1_NOMUSR LIKE '%" + xFilial("BA1") + ALLTRIM(cChave) + "%' AND BA1_TIPUSU = 'T' AND "
		EndIf
	EndIf

	cSQL += RetSQLNAME("BA1") + ".D_E_L_E_T_ = ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ executa a query
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'''
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbPes",.F.,.T.)

TrbPes->( DbGoTop() )
While !TrbPes->( Eof() )
	TrbPes->( AaDd( aBrowPro,{TrbPes->MATRICULA,BA1_NOMUSR,TrbPes->RECNO, "BR_VERDE"} ) )
	TrbPes->( DbSkip() )
EndDo

TrbPes->( DbCloseArea() )

RestArea(aArea)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa resultado da pesquisa..                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aBrowPro) == 0
   aBrowPro := aClone(aVetPad)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza browse...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowPro:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
                  // uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
                  // Exemplo:
                  // 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
                  // (via seta para cima ou clique na primeira linha)
                  // 2a. Pesquisa: "AV" - Ocorria o erro
oBrowPro:SetArray(aBrowPro)
oBrowPro:Refresh()
oBrowPro:SetFocus()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/{Protheus.doc} PLSCONFUN
Consulta para o campo BAU_MATFUN

@author Lucas Nonato
@since  17/11/2017
@version P12
/*/
Function PLSCONFUN()
Local oBrwEsp   := Nil
Local oDlgEsp   := Nil
Local nLin	    := 1
Local nOpca	    := 0
Local bOk       := { || nLin := oBrwEsp:nAt,nOpca := 1,oDlgEsp:End() }
Local bCanc     := { || nOpca := 3,oDlgEsp:End() }
Local bRefresh  := { || Iif(ValType(oBrwEsp) == 'A' .And. Empty(oBrwEsp[1,1]),.F.,.T. )}
Local bGetEsp   := { || PlGetFU(oCmbEsp, M->BAU_CPFCGC),oBrwEsp:SetArray(aEspLoc), oBrwEsp:Refresh() }
Local cCmbEsp   := ""
Local oCmbEsp   := Nil
Local lRet      := .F.
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
LOCAL nX,nY,nW,nH := 0
LOCAL nCmbX,nCmbY := 0
Local aCampos := {}
Local aBls    := {}
Private aEspLoc   := {}
Private cGetEsp   := Space(40)

PlGetFU(oCmbEsp, M->BAU_CPFCGC)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o Tamanho da Tela ...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 20, .t., .f. } )
AAdd( aObjects, { 100, 100, .t., .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

nX := aPosObj[1][1] + 22		//Valor Original = 33
nY := aPosObj[1][2]			//Valor Original = 03
nW := aPosObj[2][4] - 54		//Valor Original = 309
nH := aPosObj[1][3] + 112	//Valor Original = 53

nCmbX := aPosObj[1][1] + 2					//Valor Original = 15 - Determina a posição X da Combo na tela
nCmbY := aPosObj[1][1] - 3					//Valor Original = 30 - Determina a posição Y da Combo na tela

DEFINE MSDIALOG oDlgEsp TITLE STR0075 FROM 008.8,005 TO 40,95 OF GetWndDefault() //"Funcionários"
@ nCmbX + 5,nY Say oSay PROMPT STR0061 SIZE 25,20 OF oDlgEsp PIXEL //"Pesquisar: "
oCmbEsp :=  TComboBox():Create(oDlgEsp,{|u|if(PCount()>0,cCmbEsp:=u,cCmbEsp)},nCmbX,nCmbY,{STR0073,STR0076,STR0077},50,20,,,,,,.T.,,,,,,,,,'cCmbEsp')
@ nCmbX + 1,aPosObj[1][3] + 32 MSGET cGetEsp SIZE 95, 010 OF oDlgEsp PIXEL PICTURE "@!"
DEFINE SBUTTON FROM nCmbX + 1,aPosObj[2][1] + 129 TYPE 1 ACTION Eval(bGetEsp) ENABLE OF oDlgEsp


oBrwEsp := TcBrowse():New( nX, nY, nW, nH,,,, oDlgEsp,,,,,,,,,,,, .F.,, .T.,, .F.,,.T. )
oBrwEsp:AddColumn(TcColumn():New("Filial",{ || aEspLoc[oBrwEsp:nAt,1] },"@!",nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))//"Filial"
oBrwEsp:AddColumn(TcColumn():New(STR0073,{ || aEspLoc[oBrwEsp:nAt,2] },"@!",nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil))//"Matricula"
oBrwEsp:AddColumn(TcColumn():New(STR0077,{ || aEspLoc[oBrwEsp:nAt,3] },"@!",nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil))//"Nome"
oBrwEsp:AddColumn(TcColumn():New(STR0076,{ || aEspLoc[oBrwEsp:nAt,4] },"@!",nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil))//"Centro de Custo"
oBrwEsp:SetArray(aEspLoc)
oBrwEsp:bLDblClick := bOk
Eval(bRefresh)
	
//-- LGPD --------  
if objCENFUNLGP:isLGPDAt()  
	aCampos := {"RA_FILIAL","RA_MAT","RA_NOME","RA_CC" }  
	aBls := objCENFUNLGP:getTcBrw(aCampos)  
	oBrwEsp:aObfuscatedCols := aBls  
endif  
//---------------- 

ACTIVATE MSDIALOG oDlgEsp ON INIT Eval({ || EnChoiceBar(oDlgEsp,bOK,bCanc,.F.) })

If nOpca == K_OK
	If ValType(aEspLoc) == 'A' .And. Len(aEspLoc) > 0 .And. !Empty(aEspLoc[nLin,1])
		SRA->(dbSetOrder(1))
		lRet := SRA->(DbSeek(aEspLoc[nLin,1]+aEspLoc[nLin,2]))
	Else
		lRet := .F.
	EndIf
EndIf

Return(lRet)



/*/{Protheus.doc} PLBQ1SXB
Funcao criada para ser utilizada na consulta Especialidade X Profissional
@author Totvs
@since 04/2018
/*/
Function PLBQ1SXB()

	Local cSql := ""
	Local lRet := .F.
	Local aHeader := {}
	Local aIndices := {}
	Local oConsulta := Nil
	Local aArea := GetArea()
	Local cCRM  := ""
	Local cCampo := ReadVar() 
	
	Do Case
	    Case cCampo == "M->BE1_ESPSOL"
	         cCRM 	:= M->(ALLTRIM(BE1_REGSOL))
	 
	    Case cCampo == "M->BE1_ESPEXE" 
	         cCRM  	:=  M->(ALLTRIM(BE1_REGEXE))
	      
	    Case cCampo == "M->BE4_ESPSOL"
	         cCRM  	:=  M->(ALLTRIM(BE4_REGSOL))
	      
	    Case cCampo == "M->BE4_ESPEXE"
	         cCRM  	:=  M->(ALLTRIM(BE4_REGEXE))  
			 
		Case cCampo == "M->B4B_CODESP"
			 cCRM   :=  M->(ALLTRIM(B4B_NUCONS))    
	EndCase
	

	//Monta a query da consulta padrao
	cSql := " SELECT BQ1_CODESP, BQ1_DESCRI "
	cSql += " FROM " + RetSQLName("BB0") + " BB0 "
	cSql += " INNER JOIN " + RetSQLName("BQ1") + " BQ1 "
	cSql += " ON BB0_CODIGO = BQ1_CODIGO AND BB0_FILIAL = '" + xFilial("BB0") + "' AND BQ1_FILIAL = '" + xFilial("BQ1") + "' "
	cSql += " WHERE BB0_NUMCR = '" + cCRM  + "' "
	cSql += " AND BB0.D_E_L_E_T_ = ' ' AND BQ1.D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)


	//Monta a aHeader da consulta
	SX3->(dbSetOrder(2))

	If SX3->(dbSeek("BQ1_CODESP", .F.))
		SX3->(Aadd(aHeader, {X3_TITULO, 'BQ1_CODESP', X3_PICTURE, X3_TAMANHO, X3_DECIMAL, "AlwaysTrue()", X3_USADO, "C", "", "V"}))
		SX3->(aAdd(aIndices, {"BQ1_CODESP", X3_TITULO}))
	Endif
	If SX3->(dbSeek("BQ1_DESCRI", .F.))
		SX3->(Aadd(aHeader, {X3_TITULO, 'BQ1_DESCRI', X3_PICTURE, X3_TAMANHO, X3_DECIMAL, "AlwaysTrue()", X3_USADO, "C", "", "V"}))
	Endif

	//Monta a consulta padrao
	oConsulta:=PlsIntSxb():New()
	oConsulta:cTitle := "Especialidades" //Titulo da Consulta
	oConsulta:cQuery := cSql             //Query dos dados a serem apresentados
	oConsulta:aIndex := aIndices         //Indices disponiveis (deve usar os mesmos campos da query)
	oConsulta:aHeader := aHeader         //Header da grid presente consulta (deve usar os mesmos campos da query)
	oConsulta:aReturn := {'BQ1_CODESP'}  //Campos de retorno da consulta (deve usar os mesmos campos da query)
	oConsulta:lDataBaseRM := .T.         //Indica se a query eh executada na base do protheus ou da RM
	oConsulta:Show()

	//Coleta o retorno
	If Len(oConsulta:aRetSXB) > 0
		VAR_IXB := oConsulta:aRetSXB[1]
		lRet :=.t.
	EndIf
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} PLSMOTBLO
Funcao criada para ser utilizada no campo BQQ_TODOS na rotina de transferência
@author Ribas
@since 06/2018
/*/
Function PLSMOTBLO() 
LOCAL nLin       	:= 1
LOCAL nOpca      	:= 0
LOCAL cChave     	:= Space(40)
LOCAL cTipoPes   	:= ""
LOCAL oDlgMotBl     := NIL
LOCAL oTipoPes		:= NIL
LOCAL oBrwMot		:= NIL
LOCAL oGetChave		:= NIL
LOCAL oChkChk		:= NIL
LOCAL aBrwMotiv  	:= {}
LOCAL aVetPad    	:= { {"","",0,""} }
LOCAL cValid     	:= "{|| Eval(bRefresh) }"
LOCAL bOK        	:= { || nLin := oBrwMot:nAt,nOpca := 1,lOk:=.T.,oDlgMotBl:End() }
LOCAL bCanc      	:= { || nOpca := 3,oDlgMotBl:End() }
LOCAL aTipoPes   	:= {}
LOCAL lChkChk    	:= .F.
LOCAL lRet		 	:= .F.
LOCAL aButtons   	:= {}
LOCAL cVarRead		:= ReadVar()
LOCAL bRefresh   	:= { || PLSMOTIVO(oBrwMot, aBrwMotiv, cChave, cTipoPes, cVarRead, @cAlias), If( Empty(aBrwMotiv[1,1]) .And. !Empty(cChave), .F., .T. ) }
LOCAL cAlias		:= ""
Local aCampos := {}
Local aBls    := {}

aBrwMotiv := aClone(aVetPad)

aTipoPes := {"1-Código", "2-Descrição"}

DEFINE MSDIALOG oDlgMotBl TITLE STR0093 FROM 008.2,000 TO 030,ndColFin OF GetWndDefault() //"Motivo de Bloqueio"

//Cria a chave de pesquisa
oGetChave := TGet():New(040,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgMotBl,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)

//Cria o grid de retorno dos motivos
oBrwMot := TcBrowse():New( 058, 008, 378, 100,,,, oDlgMotBl,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrwMot:AddColumn(TcColumn():New(STR0094 ,nil,nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil)) //"Código"
oBrwMot:ACOLUMNS[1]:BDATA := { || aBrwMotiv[oBrwMot:nAt,1] }

oBrwMot:AddColumn(TcColumn():New(STR0095,nil,nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil)) //"Descrição"
oBrwMot:ACOLUMNS[2]:BDATA := { || aBrwMotiv[oBrwMot:nAt,2] }

@ 040,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgMotBl PIXEL COLOR CLR_HBLUE

oBrwMot:SetArray(aBrwMotiv)
oBrwMot:BLDBLCLICK := bOK
oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}

//Retorna os motivos assim que clicar na consulta
PLSMOTIVO(oBrwMot,aBrwMotiv,,,cVarRead, @cAlias)

//-- LGPD --------  
if objCENFUNLGP:isLGPDAt()  
	aCampos := {cAlias+"_CODBLO",cAlias+"_DESBLO" }  
	aBls := objCENFUNLGP:getTcBrw(aCampos)  
	oBrwMot:aObfuscatedCols := aBls  
endif  
//---------------- 

ACTIVATE MSDIALOG oDlgMotBl ON INIT Eval({ || oBrwMot:Refresh(), EnChoiceBar(oDlgMotBl,bOK,bCanc,.F.,aButtons) }) CENTERED

If nOpca == K_OK

	lRet := .T.
	
	//posiciona no registro selecionado e preenche o campo
	If !Empty( aBrwMotiv[nLin,1] )
		&(cAlias+'->( DbGoTo(' + ALLTRIM( STR( aBrwMotiv[nLin,3] ) )+') )')
	EndIf
EndIf

Return(lRet)

/*/{Protheus.doc} PLSMOTIVO
Funcao criada para executar a query e retornar os motivos de bloqueio para a rotina de transferencia
@author Ribas
@since 06/2018
/*/
Static Function PLSMOTIVO(oBrwMot, aBrwMotiv, cChave, cTipo, cVarMemor, cAlias) 

LOCAL lRet		:= .F.
LOCAL cSQL      := ""
LOCAL aVetPad    	:= { {"","",0,""} }

If cVarMemor == "M->BQQ_MOTBLO" 

	If M->BQQ_TODOS == "1"
		cAlias := "BG1"	
	Else
		cAlias := "BG3"
	EndIf
EndIf

aBrwMotiv := {}

cSQL := "SELECT " + cAlias+"_CODBLO, " + cAlias+"_DESBLO, " + RetSQLNAME(cAlias) + ".R_E_C_N_O_ AS RECNO "
cSQL += " FROM " + RetSQLNAME(cAlias)

If EMPTY(cChave) .OR. ALLTRIM(cChave) == "_"
	cSQL += " WHERE " + cAlias+"_FILIAL = '" + xFilial(cAlias) +"' AND " + cAlias+"_TIPBLO = '0' AND "

ElseIf SUBSTR(cTipo,1,1)== "1"
	cSQL += " WHERE " + cAlias+"_FILIAL = '" + xFilial(cAlias) +"' AND "
	cSQL += cAlias+"_CODBLO LIKE '%" + ALLTRIM(cChave) + "%'  AND " 
	cSQL += cAlias+"_TIPBLO = '0' AND "

ElseIf SUBSTR(cTipo,1,1)== "2"
	cSQL += " WHERE " + cAlias+"_FILIAL = '" + xFilial(cAlias) +"' AND "
	cSQL += cAlias+"_DESBLO LIKE '%" + ALLTRIM(cChave) + "%'  AND " 
	cSQL += cAlias+"_TIPBLO = '0' AND "
EndIf

cSQL += RetSQLNAME(cAlias) + ".D_E_L_E_T_ = '' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbMotBlo",.F.,.T.)

TrbMotBlo->( DbGoTop() )

While !TrbMotBlo->( Eof() )

	AaDd( aBrwMotiv,{ TrbMotBlo->&(cAlias+"_CODBLO"), ALLTRIM(TrbMotBlo->&(cAlias+"_DESBLO")), TrbMotBlo->RECNO} ) 
	TrbMotBlo->( DbSkip() )
EndDo

TrbMotBlo->( DbCloseArea() )

//////////////////////////////////////////////////////////////
//³ Testa resultado da pesquisa...                                           
//////////////////////////////////////////////////////////////
If Len(aBrwMotiv) == 0
   aBrwMotiv := aClone(aVetPad)
EndIf

//////////////////////////////////////////////////////////////
//³ Atualiza browse...                                                       
//////////////////////////////////////////////////////////////
oBrwMot:nAt := 1 

oBrwMot:SetArray(aBrwMotiv)
oBrwMot:Refresh()
oBrwMot:SetFocus()

Return .T.


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCODDEP

Função criada para fazer a consulta especifica no campo BA1_CODDEP, devido a consulta padrão
não conseguir trabalhar quando o funcionario é de outra filial (diferente da filial corrente) 

@author    Vinicius.Queiros
@version   P12
@since     28/04/2020
/*/
//------------------------------------------------------------------------------------------
Function PLSCODDEP()

Local oBrwEsp   	:= Nil
Local oDlgEsp   	:= Nil
Local nLin	    	:= 1
Local nOpca	    	:= 0
Local bOk       	:= { || nLin := oBrwEsp:nAt,nOpca := 1,oDlgEsp:End() }
Local bCanc     	:= { || nOpca := 3,oDlgEsp:End() }
Local bRefresh  	:= { || Iif(ValType(oBrwEsp) == 'A' .And. Empty(oBrwEsp[1,1]),.F.,.T. )}
Local bGetEsp   	:= { || PlGetDep(oCmbEsp),oBrwEsp:SetArray(aEspLoc), oBrwEsp:Refresh() }
Local cCmbEsp   	:= ""
Local oCmbEsp   	:= Nil
Local lRet      	:= .F.
Local aObjects  	:= {}
Local aSize     	:= {}
Local aInfo     	:= {}
LOCAL nX,nY,nW,nH 	:= 0
LOCAL nCmbX,nCmbY 	:= 0
Local aCampos 		:= {}
Local aBls    		:= {}
Private aEspLoc   	:= {}
Private cGetEsp   	:= Space(40) // Campo de Pesquisa

// Função para realizar a query nos dependentes do funcionario cadastrado na BA3
PlGetDep(oCmbEsp)

// Define o Tamanho da Tela ...                                                          
aSize 	 := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 20, .t., .f. } )
AAdd( aObjects, { 100, 100, .t., .t., .t. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

nX := aPosObj[1][1] + 22		//Valor Original = 33
nY := aPosObj[1][2]			//Valor Original = 03
nW := aPosObj[2][4] - 54		//Valor Original = 309
nH := aPosObj[1][3] + 112	//Valor Original = 53

nCmbX := aPosObj[1][1] + 2	// Valor Original = 15 - Determina a posição X da Combo na tela
nCmbY := aPosObj[1][1] - 3	// Valor Original = 30 - Determina a posição Y da Combo na tela

// Fim da Definição do tamanho da tela

DEFINE MSDIALOG oDlgEsp TITLE STR0096 FROM 008.8,005 TO 038,070 OF GetWndDefault() //"Dependentes na Folha"

@ nCmbX + 5,nY Say oSay PROMPT STR0061 SIZE 25,20 OF oDlgEsp PIXEL //"Pesquisar: "
oCmbEsp :=  TComboBox():Create(oDlgEsp,{|u|if(PCount()>0,cCmbEsp:=u,cCmbEsp)},nCmbX,nCmbY,{STR0097,STR0077},50,20,,,,,,.T.,,,,,,,,,'cCmbEsp') // Combo com as opções: Seq.Dep e Nome
@ nCmbX + 1,aPosObj[1][3] + 32 MSGET cGetEsp SIZE 95, 010 OF oDlgEsp PIXEL PICTURE "@!" // Caixa de texto para a pesquisa
DEFINE SBUTTON FROM nCmbX + 1,aPosObj[2][1] + 129 TYPE 1 ACTION Eval(bGetEsp) ENABLE OF oDlgEsp // Botão para pesquisar

oBrwEsp := TcBrowse():New( 055, 003, 254, 163,,,, oDlgEsp,,,,,,,,,,,, .F.,, .T.,, .F.,,.T. )
oBrwEsp:AddColumn(TcColumn():New(STR0098, { || aEspLoc[oBrwEsp:nAt,1] },"@!",nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))//"Filial"
oBrwEsp:AddColumn(TcColumn():New(STR0073, { || aEspLoc[oBrwEsp:nAt,2] },"@!",nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))//"Matricula"
oBrwEsp:AddColumn(TcColumn():New(STR0097, { || aEspLoc[oBrwEsp:nAt,3] },"@!",nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))//"Seq.Dep."
oBrwEsp:AddColumn(TcColumn():New(STR0077, { || aEspLoc[oBrwEsp:nAt,4] },"@!",nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil))//"Nome"
oBrwEsp:SetArray(aEspLoc)
oBrwEsp:bLDblClick := bOk
Eval(bRefresh)

//-------- LGPD --------  
if objCENFUNLGP:isLGPDAt()  
	aCampos := {"RB_FILIAL","RB_MAT","RB_COD","RB_NOME" }  
	aBls := objCENFUNLGP:getTcBrw(aCampos)  
	oBrwEsp:aObfuscatedCols := aBls  
endif  
//----------------------

ACTIVATE MSDIALOG oDlgEsp ON INIT Eval({ || EnChoiceBar(oDlgEsp,bOK,bCanc,.F.) })

If nOpca == K_OK
	If ValType(aEspLoc) == 'A' .And. Len(aEspLoc) > 0 .And. !Empty(aEspLoc[nLin,1])
		// Quando for selecionado um dependente, Verifica se o dependente existe na SRB
		SRB->(dbSetOrder(1))
		lRet := SRB->(DbSeek(aEspLoc[nLin,1]+aEspLoc[nLin,2]+aEspLoc[nLin,3]))
	Else
		lRet := .F.
	EndIf
EndIf

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlGetDep

Função responsavel por fazer a query dos dependentes vinculado ao funcionário cadastrado
na familia - BA3_AGFTFU+BA3_AGMTFU (Filial do Funcionário + Matricula)

@author    Vinicius.Queiros
@version   P12
@since     28/04/2020
/*/
//------------------------------------------------------------------------------------------

Static Function PlGetDep(oCmbEsp)

aEspLoc := {} // Limpa o array dos dependentes da tela

cSQL := "SELECT RB_FILIAL, RB_MAT, RB_COD, RB_NOME FROM " + RetSqlName("SRB") + " SRB "

If !Empty(Iif(!IsInCallStack("PLSA124"),M->BA3_AGFTFU,BA3->BA3_AGFTFU))
	cSQL += "WHERE RB_FILIAL = '"+Iif(!IsInCallStack("PLSA124"),M->BA3_AGFTFU,BA3->BA3_AGFTFU)+"' AND RB_MAT = '"+Iif(!IsInCallStack("PLSA124"),M->BA3_AGMTFU,BA3->BA3_AGMTFU)+"'"
Else
	cSQL += "WHERE RB_FILIAL = '" + xFilial ("SRB") + "' "
Endif

If ValType(oCmbEsp) == "O" .And. !Empty(cGetEsp) // Quando for uma pesquisa
	
	If oCmbEsp:Nat == 1 // Pesquisa pela Sequencia de Dependentes
		cSQL += " AND RB_COD LIKE '%" + Alltrim(cGetEsp) + "%'"
		cOrdem := "RB_COD"
	Else // Pesquisa pela Nome
		cSQL += " AND RB_NOME LIKE '%" + Alltrim(cGetEsp) + "%'"
		cOrdem := "RB_NOME"
	EndIf
EndIf

cSQL += " AND SRB.D_E_L_E_T_ <> '*' "
cSQL += " ORDER BY RB_MAT"

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"CODDEP",.F.,.T.)

While !CODDEP->(Eof())
	// Adiciona os dependentes no array que irá exibir no browser 
	aAdd(aEspLoc,{CODDEP->RB_FILIAL,CODDEP->RB_MAT,CODDEP->RB_COD,CODDEP->RB_NOME}) 
	CODDEP->(dbSkip())
EndDo
// Fecha tabela temporária
CODDEP->(dbCloseArea())

Return Iif(Len(aEspLoc) > 0,.T.,.F.)
