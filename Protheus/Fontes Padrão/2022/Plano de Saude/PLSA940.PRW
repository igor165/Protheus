#Include "plsa940.ch" 
#Include "PLSMGER.CH"
#Include "PROTHEUS.CH"  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA940 ³ Autor ³ Tulio Cesar          ³ Data ³ 29.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Padrao Saude                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA940() 
Private cCodPsa   := "" 
Private cChvPad   := "" 
Private cChvPsa   := "" 
Private cChvReg   := "" 
Private cChvTipo  := ""
Private cChvFac	  := ""
Private aCols     := {}
Private aHeader   := {}
Private aMsgErro  := {}
Private aRotina   := MenuDef()
Private cAlias    := "BR8"
Private cCadastro := PLSRetTit(cAlias)  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama funcao de Browse...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BR8->(DbSetOrder(2))
BR8->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,cAlias))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA940PI2 ³ Autor ³ Daher			   ³ Data ³ 13.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Procedimentos Incompativeis			                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 								                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA940                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA940PI2()

Local   cFilB08   := ""
Private cCadastro := PLSRetTit("B09")
Private aRotina   := {{ STR0001		, 'AxPesqui'    , 0 , K_Pesquisar  },; //"Pesquisar" //"Pesquisar"
                        { STR0002	, 'AxVisual'    , 0 , K_Visualizar },; //"Visualizar" //"Visualizar"
                        { STR0009	, 'PLSA940IN2'	, 0 , K_Incluir    },; //"Incluir" //"Incluir"
				        { STR0010	, 'PLSA940IN2' 	, 0 , K_Alterar    },; //"Alterar" //"Alterar"
 					    { STR0011	, 'AxDeleta'	, 0 , K_Excluir    }}  //"Excluir" //"Excluir"

cChvFac := BYL->BYL_FACE

cFilB09 := "@B09_FILIAL = '"+xFilial("B09")+"' AND B09_CHVPAD = '"+cChvPad+"' AND B09_CHVPSA = '"+alltrim(cChvPsa)+"'"
cFilB09 += " AND B09_CHVREG = '"+cChvReg+"' AND B09_CHVFAC = '"+cChvFac+"' AND D_E_L_E_T_ = ' '"
     
DbSelectArea("B09")
B09->(DbSetFilter({||&cFilB09},cFilB09))				         
B09->(DbSetOrder(1))
B09->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"B09"))
B09->(DbClearFilter())

Return                   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA940IN2 ³ Autor ³ Daher			   ³ Data ³ 13.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 										                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 								                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA940                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA940IN2(cAlias,nReg,nOpc) 

Local cFilB09 := ""

cFilB09 := "@B09_FILIAL = '"+xFilial("B08")+"' AND B09_CHVPAD = '"+cChvPad+"' AND B09_CHVPSA = '"+alltrim(cChvPsa)+"'"
cFilB09 += " AND B09_CHVREG = '"+cChvReg+"' AND B09_CHVFAC = '"+cChvFac+"' AND D_E_L_E_T_ = ' '"

If nOpc == K_Alterar   
	AxAltera(cAlias,nReg,nOpc,,,,,"PLS940T2k('2')")    
EndIf

If nOpc == K_Incluir
	AxInclui(cAlias,nReg,nOpc,,,,"PLS940T2k('1')")
EndIf                                  

B09->(DbSetFilter({||&cFilB09},cFilB09))	

Return   
  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA940INC ³ Autor ³ Daher			   ³ Data ³ 13.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 										                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 								                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA940                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA940INC(cAlias,nReg,nOpc)
LOCAL cFiltro 	   := ""

If cAlias == "B08"
	cFiltro 	   := "@B08_FILIAL = '"+xFilial("B08")+"' AND B08_CHVPAD = '"+cChvPad+"' AND B08_CHVPSA = '"+alltrim(cChvPsa)+"'"
	cFiltro 	   += " AND B08_CHVREG = '"+cChvReg+"' AND D_E_L_E_T_ = ' '"
Endif

If nOpc == K_Alterar   
	AxAltera(cAlias,nReg,nOpc,,,,,"PLS940TOk('2',cAlias)")    
Endif
If nOpc == K_Incluir
	AxInclui(cAlias,nReg,nOpc,,,,"PLS940TOk('1',cAlias)")
Endif

If cAlias == "B08"
	B08->(DbSetFilter({||&cFiltro},cFiltro))
Endif

Return   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA940IN3 ³ Autor ³ Microsiga		   ³ Data ³ 13.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 										                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 								                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA940                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA940IN3(cAlias,nReg,nOpc) 

Local cFilB0N := ""

cFilB0N := "@B0N_FILIAL = '"+xFilial("B0N")+"' AND B0N_CHVPAD = '"+cChvPad+"' AND B0N_CHVPSA = '"+alltrim(cChvPsa)+"' "
cFilB0N += "AND B0N_CHVREG = '"+cChvReg+"' AND D_E_L_E_T_ = ' '"

If nOpc == K_Alterar   
	AxAltera(cAlias,nReg,nOpc,,,,,"PLS940PROk('2')")    
EndIf 

If nOpc == K_Incluir
	AxInclui(cAlias,nReg,nOpc,,,,"PLS940PROk('1')")
EndIf  

B0N->(DbSetFilter({||&cFilB0N},cFilB0N))	

Return   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS940TOk  ³ Autor ³ Daher			   ³ Data ³ 13.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 										                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 								                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA940                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS940TOk(cTipo,cAlias)
LOCAL lRet := .F.
LOCAL cSql := "" 
LOCAL nOrdB08 := NIL 
LOCAL nRecB08 := NIL 
LOCAL nRecB87 := 0
DEFAULT cAlias	 := "B08"

//Recno B08
B08->(DbSetORder(1)) 
nRecB08 := B08->(Recno()) 

//Recno B87
B87->(DbSetOrder(1))
nRecB87 := B87->(Recno())

If cAlias == "B08"
	If cTipo == '1'
		lRet  := ExistChav("B08",cChvPad+cChvPsa+cChvReg+M->B08_CODPAD+M->B08_CODPSA+M->B08_NIVEL+M->B08_DENREG)
		
	ElseIf cTipo == '2'
		cSql := "SELECT * FROM "+RetSqlName("B08")+" WHERE "
		cSql += " B08_FILIAL = '"+xFilial("B08")+"' "
		cSql += "AND B08_CHVPAD = '"+cChvPad+"' "
		cSql += "AND B08_CHVPSA = '"+cChvPsa+"' "
		cSql += "AND B08_CHVREG = '"+cChvReg+"' "
		cSql += "AND B08_CODPAD = '"+M->B08_CODPAD+"' "
		cSql += "AND B08_CODPSA = '"+M->B08_CODPSA+"' "
		cSql += "AND B08_NIVEL  = '"+M->B08_NIVEL+"' "
		cSql += "AND B08_DENREG = '"+M->B08_DENREG+"' "
		cSql += "AND R_E_C_N_O_ <> "+alltrim(str(B08->(Recno())))+" "
		cSql += "AND D_E_L_E_T_ = ' ' "
		PlsQuery(cSql, "TRB")
		If !TRB->(Eof())
			Help("",1,"JAGRAVADO")
			lRet  := .F.
		Else
			lRet  := .T.
		Endif
		TRB->(DbCloseArea())
	Endif
	
	B08->(DbSetORder(1))
	B08->(DbGoTo(nRecB08))
	
Elseif cAlias == "B87"

	If cTipo == '1'
		lRet  := ExistChav("B87",cChvPad+cChvPsa+cChvReg+cCodFace+M->B87_CODPAD+M->B87_CODPSA+M->B87_DENREG+M->B87_FACINC)
		
	Elseif cTipo == '2'
		cSql := "SELECT * FROM "+RetSqlName("B87")+" WHERE "
		cSql += " B87_FILIAL = '"+xFilial("B87")+"' "
		cSql += "AND B87_CHVPAD = '"+cChvPad+"' "
		cSql += "AND B87_CHVPSA = '"+cChvPsa+"' "
		cSql += "AND B87_CHVREG = '"+cChvReg+"' "
		cSql += "AND B87_FACE   = '"+cCodFace+"' "
		cSql += "AND B87_CODPAD = '"+M->B87_CODPAD+"' "
		cSql += "AND B87_CODPSA = '"+M->B87_CODPSA+"' "
		cSql += "AND B87_DENREG = '"+M->B87_DENREG+"' "
		cSql += "AND B87_FACINC = '"+M->B87_FACINC+"' "
		cSql += "AND B87_NIVEL  = '"+M->B87_NIVEL+"' "
		cSql += "AND R_E_C_N_O_ <> "+alltrim(str(B87->(Recno())))+" "
		cSql += "AND D_E_L_E_T_ = ' ' "
		PlsQuery(cSql, "TRB")
		If !TRB->(Eof())
			Help("",1,"JAGRAVADO")
			lRet  := .F.
		Else
			lRet  := .T.
		Endif
		TRB->(DbCloseArea())
	Endif
	
	B87->(DbSetOrder(1))
	B87->(DbGoTo(nRecB87))
Endif

Return lRet  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS940TOk  ³ Autor ³ Daher			   ³ Data ³ 13.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 										                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 								                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA940                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS940PROk(cTipo)
LOCAL lRet := .F.
LOCAL cSql := "" 
LOCAL nRecB0N := 0 

B0N->(DbSetORder(1))
nRecB0N := B0N->(Recno())

If cTipo == '1'
	lRet  := ExistChav("B0N",cChvPad+cChvPsa+cChvReg+M->B0N_CODPAD+M->B0N_CODPSA+M->B0N_NIVEL+M->B0N_DENREG)
EndIf

If cTipo == '2'	
	cSql := "SELECT * FROM "+RetSqlName("B0N")+" WHERE "
	cSql += " B0N_FILIAL = '"+xFilial("B0N")+"' "
	cSql += "AND B0N_CHVPAD = '"+cChvPad+"' "
	cSql += "AND B0N_CHVPSA = '"+cChvPsa+"' "
	cSql += "AND B0N_CHVREG = '"+cChvReg+"' "
	cSql += "AND B0N_CODPAD = '"+M->B0N_CODPAD+"' "
	cSql += "AND B0N_CODPSA = '"+M->B0N_CODPSA+"' "
	cSql += "AND B0N_NIVEL  = '"+M->B0N_NIVEL+"' "
	cSql += "AND B0N_DENREG = '"+M->B0N_DENREG+"' "
	cSql += "AND R_E_C_N_O_ <> "+alltrim(str(B0N->(Recno())))+" "
	cSql += "AND D_E_L_E_T_ = ' ' "
	PlsQuery(cSql, "TRB")
	If !TRB->(Eof())
		Help("",1,"JAGRAVADO")
		lRet  := .F.
	Else
		lRet  := .T.
	EndIf
	TRB->(DbCloseArea())
EndIf

B0N->(DbSetORder(1))
B0N->(DbGoTo(nRecB0N))

Return lRet  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS940T2k  ³ Autor ³ Daher			   ³ Data ³ 13.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 										                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 								                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA940                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS940T2k(cTipo)
LOCAL lRet := .F.
LOCAL cSql := "" 
LOCAL nRecB09 := 0

B09->(DbSetORder(1))
nRecB09 := B09->(Recno())

If cTipo == '1'
	lRet  := ExistChav("B09",cChvPad+cChvPsa+cChvReg+cChvFac+M->B09_CODPAD+M->B09_CODPSA+M->B09_NIVEL+M->B09_DENREG+M->B09_FADENT)
EndIf

If cTipo == '2'	
	cSql := "SELECT * FROM "+RetSqlName("B09")+" WHERE "
	cSql += " B09_FILIAL = '"+xFilial("B09")+"' "
	cSql += "AND B09_CHVPAD = '"+cChvPad+"' "
	cSql += "AND B09_CHVPSA = '"+cChvPsa+"' "
	cSql += "AND B09_CHVREG = '"+cChvReg+"' "
	cSql += "AND B09_CHVFAC = '"+cChvFac+"' "
	cSql += "AND B09_CODPAD = '"+M->B09_CODPAD+"' "
	cSql += "AND B09_CODPSA = '"+M->B09_CODPSA+"' "
	cSql += "AND B09_NIVEL  = '"+M->B09_NIVEL+"' "
	cSql += "AND B09_DENREG = '"+M->B09_DENREG+"' "
	cSql += "AND B09_FADENT = '"+M->B09_FADENT+"' "
	cSql += "AND R_E_C_N_O_ <> "+alltrim(str(B09->(Recno())))+" "
	cSql += "AND D_E_L_E_T_ = ' ' "
	PlsQuery(cSql, "TRB")
	If !TRB->(Eof())
		Help("",1,"JAGRAVADO")
		lRet  := .F.
	Else
		lRet  := .T.
	EndIf
	TRB->(DbCloseArea())
EndIf

B09->(DbSetORder(1))
B09->(DbGoTo(nRecB09))

Return lRet  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA940Mov ³ Autor ³ Michele Tatagiba   ³ Data ³ 13.06.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modulo de Manutencao da Tabela Padrao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSA940Mov(cAlias,nReg,nOpc)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA940                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA940Mov(cAlias,nReg,nOpc)  

Local   I__f        := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da EnchoiceBar...                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local   aButtons    := {}
Local   bOK         := {|| nOpca := 1,If(Obrigatorio(aGets,aTela) .And. PLS940Alt(nOpc) .And. PLSVLDLEM(), Eval({|| oDlg:End()}) ,(nOpca:=3,.F.)) , ;
                           If(nOpca==1,oDlg:End(),.F.) }
Local   bCancel     := {||oDlg:End()}
Local   nOrdBR8     := BR8->(IndexOrd())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle de lock de registro...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local   lLock       := .F.
Local   aPosObj     := {}
Local   aObjects    := {}
Local   aSize       := {}
Local   aInfo       := {}
Local   aNiveis     := PLSESPNIV(BR8->BR8_CODPAD)
Local   nNiveis     := (aNiveis[1]+1)          
Local   nI	        := 0                      
Local   cChave      := ""
Local   cCodAux     := ""                                                   
Local   nRecBR8     := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis genericas...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCampos     := {}
Private nOpcx       := nOpc
Private nOpca       := 0
Private cCodPad
Private cCodPsa
Private bFilter                                
Private cCadastro   := "   >>   "+AllTrim(BR8->BR8_CODPSA)+" - "+AllTrim(BR8->BR8_DESCRI)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da enchoice...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0]
Private aGETS[0]
Private cAliasEnc   := "BR8"
Private nRegEnc
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis para controle de forma de pagamento...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aSTela      := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis para controle de Qtd/Percentual do procedimento... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTrbQtd     := {}
Private oBrwQtd
Private aCabQtd     := {}
Private aDadQtd     := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis para controle de co-participacao...                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTrbCo      := {}
Private oBrwCo
Private aCabCo      := {}
Private aDadCo      := {} 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis para controle das Refeições do Acompanhante        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTrbIdaAcomp  := {}
Private oBrwIdaAcomp
Private aCabIdaAcomp  := {}
Private aDadIdaAcomp  := {} 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis para controle de De/Para EDI                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTrbDePara  := {}
Private oBrwDePara
Private aCabDePara  := {}
Private aDadDePara  := {}    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis para controle de Qtd/Percentual do procedimento... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTrbDnt     := {}
Private oBrwDnt
Private aCabDnt     := {}
Private aDadDnt     := {}
Private cDente      := ""
Private cTpDente    := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis para controle de Grupo Periodicidade/Procedimento...						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aDadPerio   := {}
Private aCabPerio   := {}
Private aTrbPerio   := {}
Private oBrwPerio
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis para controle de Qtd/Percentual do procedimento... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aDadPer	    := {}
Private aCabPer	    := {}
Private aTrbPer     := {}
Private oBrwPer

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no contrato do procedimento selecionado no browse...      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nRegEnc := BR8->(Recno())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta ,M->??? para enchoice...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Copy cAliasEnc TO MEMORY                                                             

cCodPad := BR8->BR8_CODPAD
cCodPsa := BR8->BR8_CODPSA      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados da Qtd/Percentual por procedimento...              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BL0" TO aCabQtd For .T.
                    
BL0->(DbSetOrder(1))
If ! BL0->(DbSeek(xFilial("BL0")+cCodPad+cCodPsa))
   Store COLS Blank "BL0" TO aDadQtd FROM aCabQtd
Else
   Store COLS "BL0" TO aDadQtd FROM aCabQtd VETTRAB aTrbQtd While xFilial("BL0")+cCodPad+cCodPsa == BL0->(BL0_FILIAL+BL0_CODPAD+BL0_CODPSA)
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados da Co-Participacao                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BHC" TO aCabCo For .T.
                    
BHC->(DbSetOrder(1))
If ! BHC->(DbSeek(xFilial("BHC")+cCodPad+cCodPsa))
   Store COLS Blank "BHC" TO aDadCo FROM aCabCo
Else
   Store COLS "BHC" TO aDadCo FROM aCabCo VETTRAB aTrbCo While xFilial("BHC")+cCodPad+cCodPsa == BHC->(BHC_FILIAL+BHC_CODPAD+BHC_CODPSA)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados das idades dos acompanhantes (Refeição)            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FWAliasInDic("BKV")
	Store Header "BKV" TO aCabIdaAcomp For .T.
						
	BKV->(DbSetOrder(1))
	If ! BKV->(DbSeek(xFilial("BKV")+cCodPad+cCodPsa))
		Store COLS Blank "BKV" TO aDadIdaAcomp FROM aCabIdaAcomp
	Else
		Store COLS "BKV" TO aDadIdaAcomp FROM aCabIdaAcomp VETTRAB aTrbIdaAcomp While xFilial("BKV")+cCodPad+cCodPsa == BKV->(BKV_FILIAL+BKV_CODPAD+BKV_CODPSA)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados da Co-Participacao                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "B1M" TO aCabDePara For .T.
                    
B1M->(DbSetOrder(1))
If ! B1M->(DbSeek(xFilial("B1M")+cCodPad+cCodPsa))
   Store COLS Blank "B1M" TO aDadDePara FROM aCabDePara
Else
   Store COLS "B1M" TO aDadDePara FROM aCabDePara VETTRAB aTrbDePara While xFilial("B1M")+cCodPad+cCodPsa == B1M->(B1M_FILIAL+B1M_CODPAD+B1M_CODPSA)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados da Grupo Periodicidade/Procedimento...							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "B06" TO aCabPerio For .T.                    
B06->(DbSetOrder(1))
If ! B06->(DbSeek(xFilial("B06")+cCodPad+cCodPsa))
   Store COLS Blank "B06" TO aDadPerio FROM aCabPerio
Else
   Store COLS "B06" TO aDadPerio FROM aCabPerio VETTRAB aTrbPerio While xFilial("B06")+BR8->BR8_CODPAD+BR8->BR8_CODPSA == B06->(B06_FILIAL+B06_CODPAD+B06_CODPSA)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 100, 100, .t., .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

SetEnch("") 
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice dos Dados Gerais ...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Como essa rotina nao tem inclusao e o alterar e nopc == 4 e so tem 3 itens no aRotina
//estamos incluindo um novo item para evitar erro da enchoice
aRotina := {{ STR0001	, 'AxPesqui'   , 0 ,K_Pesquisar },; 
             { STR0002	, 'PLSA940MOV' , 0 ,K_Visualizar },;
             { STR0003	, 'PLSA940MOV' , 0 ,2            },; 
             { STR0003	, 'PLSA940MOV' , 0 ,3            }} 

Zero();MsMGet():New(cAliasEnc,nRegEnc,If(nOpc==2,K_Visualizar,K_Alterar),,,,,{aPosObj[1][1],aPosObj[1][2],aPosObj[1][4]+15,aPosObj[1][3]},,,,,,oDlg,,,.F.)

aadd(aButtons,{"COMPTITL",{|| PLS940ADDC(nOpc) },STR0006,STR0021}) //"Co-participacao"
aadd(aButtons,{"COMPTITL",{|| PLS940DEPA(nOpc) },"De-Para EDI","De-Para EDI"}) //"De-Para EDI"
aadd(aButtons,{"BUDGET",{|| PLS940ADQT(nOpc) },STR0007,STR0022}) //"Qtd X Percentual"
aadd(aButtons,{"RELATORIO",{|| PLSEXITDE(BR8->BR8_CODPAD,BR8->BR8_CODPSA) },STR0020,STR0024}) //"Tabela(s) de Origem"
If BR8->(FieldPos('BR8_REFACO')) > 0
	aadd(aButtons,{"COMPTITL",{|| PL940RefeiAcomp(nOpc) },STR0052,STR0052}) // "Refeic. Acompanhantes"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa botao 												        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aButtons,{"CLOCK03",{|| PL940PERIO(BR8->BR8_CODPAD,BR8->BR8_CODPSA,nOpc) },STR0027,STR0028})  //"Grupo Periodicidade/Procedimento"###"Grp.Perio."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata atualizacao dos dados...                                      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BR8->(DBSetOrder(nOrdBR8))
BR8->(DBGoto(nRegEnc))

If nOpca == K_OK
   If nOpcx == 3
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Inicio da Transacao...                                              ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
      Begin Transaction
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Co-participacao...                                                  ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
      If Type('oBrwCo') == "O"
         aChave := {}
         aadd(aChave,{"BHC_CODPAD",cCodPad})
         aadd(aChave,{"BHC_CODPSA",cCodPsa})
         oBrwCo:nOpc := K_Alterar
         oBrwCo:Grava(aChave)
      EndIf   
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ De-Para EDI                                                         ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
      If Type('oBrwDePara') == "O"
         aChave := {}
         aadd(aChave,{"B1M_CODPAD",cCodPad})
         aadd(aChave,{"B1M_CODPSA",cCodPsa})
         oBrwDePara:nOpc := K_Alterar
         oBrwDePara:Grava(aChave)
      EndIf   
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Qtd X Percentual...                                                 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
      If Type('oBrwQtd') == "O"
         aChave := {}
         aadd(aChave,{"BL0_CODPAD",cCodPad})
         aadd(aChave,{"BL0_CODPSA",cCodPsa})
         oBrwQtd:nOpc := K_Alterar
         oBrwQtd:Grava(aChave)
      EndIf   
	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Idades do Acompanhante (Refeição)                                   ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
	  If Type('oBrwIdaAcomp') == "O"
         aChave := {}
         aadd(aChave,{"BKV_CODPAD",cCodPad})
         aadd(aChave,{"BKV_CODPSA",cCodPsa})
         oBrwIdaAcomp:nOpc := K_Alterar
         oBrwIdaAcomp:Grava(aChave)
      EndIf   
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Se foi digitada uma quantidade x percentual em um gupo ou subgrupo  ³
      //| o sistema deve marcar todos os procedimentos abaixo dele 			  |
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                   
      nRecBR8 := BR8->(Recno())
      nOrdBR8 := BR8->(IndexOrd())
      BL0->(DbSetOrder(1))
	  If BL0->(MsSeek(xFilial("BL0")+cCodPad+cCodPsa))
	      //se for um procedimento
	      If alltrim(M->BR8_NIVEL) == alltrim(str(nNiveis))
		  		M->BR8_QTDPER := '1'
		  Else
		  		cCodAux    := BR8->BR8_CODPAD+Subs(BR8->BR8_CODPSA,aNiveis[2,(nNiveis-(val(M->BR8_NIVEL))),1],aNiveis[2,(nNiveis-(val(M->BR8_NIVEL))),2])
			   	cChave     := xFilial("BR8")+cCodAux
			    M->BR8_QTDPER := '1'			       				
				BR8->(DbSetOrder(1))
				If BR8->(MsSeek(cChave))					
					While !BR8->(Eof()) .and. (BR8->BR8_FILIAL+BR8->BR8_CODPAD+Subs(BR8->BR8_CODPSA,aNiveis[2,(nNiveis-(val(M->BR8_NIVEL))),1],aNiveis[2,(nNiveis-(val(M->BR8_NIVEL))),2])) == cChave
					   If Empty(BR8->BR8_QTDPER) 
						   If BR8->(Recno()) <> nRecBR8                         
								BR8->(Reclock("BR8",.F.))
									BR8->BR8_QTDPER := '1'
								BR8->(MsUnlock())        
						   EndIf
					   EndIf
					   BR8->(DbSkip())
					EndDo
				EndIf
		  EndIf                                                                    
      EndIf
      BR8->(DbGoTo(nRecBR8))
      BR8->(DbSetOrder(nOrdBR8))            
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Grupo Periodicidade/Procedimento...                                 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
      If Type('oBrwPerio') == "O"
      	 aChave := {}
         aadd(aChave,{"B06_CODPAD",cCodPad})
         aadd(aChave,{"B06_CODPSA",cCodPsa})
         oBrwPerio:nOpc := K_Alterar
         oBrwPerio:Grava(aChave)
      EndIf              
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Atualizo a tabela padrao...                                         ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
      PLUPTENC("BR8",K_Alterar)      
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Fim da Transacao...                                                 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      End Transaction   
   EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

Return          


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA940TAB ³ Autor ³ Tulio Cesar          ³ Data ³ 29.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta mascara virtualmente. Utilizado no campo BR8_CODPSA     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA940Tab(cTipo,cCodTabPro,cOri) 

Local   cMascara   := "@R "
Local   cRet  
Local   nRec       := BF8->(Recno())
Default cCodTabPro := If(cTipo=="B",BR8->BR8_CODPAD,M->BR8_CODPSA)
Default cOri       := "G"

BF8->(DbClearFilter())
BF8->(DbSetOrder(1)) 

If ! BF8->(DbSeek(xFilial("BF8")+cCodTabPro))
   If cOri == "G"
      cRet := "@!"+"%C"
   Else
      cRet := "@!"
   EndIf   
   Return(cRet)
EndIf

While ! BF8->(Eof()) .And. BF8->(BF8_FILIAL+BF8_CODINT+BF8_CODIGO) == xFilial("BF8")+cCodTabPro
    cMascara += Replicate("!",Val(BF8->BF8_DIGITO))+BF8->BF8_SEPARA
	BF8->(DbSkip())
EndDo      

If cOri == "G"
   cRet := cMascara+"%C"
Else
   cRet := cMascara
EndIf                  

BF8->(DbGoTo(nRec))

Return(cRet) 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ A940PAR ³ Autor ³ Michele Tatagiba     ³ Data ³ 13.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a getdados da Co Participacao                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLS940ADDC(nOpc)

Local oDlgCo                   
Local nOpca  := 0

If nOpc == 3
   nOpc := K_Alterar
Else
   nOpc := K_Visualizar
EndIf      

DEFINE MSDIALOG oDlgCo TITLE STR0016+BR8->BR8_DESCRI FROM 009,000 TO 029,060 OF GetWndDefault() //"Co-participacao - "
oDlgCo:lEscClose := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwCo  := TPLSBrw():New(0030,001,237,150,nil  ,oDlgCo,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCo ,aDadCo ,.F. ,"BHC" ,nOpc,STR0016+BR8->BR8_DESCRI ,,nil,nil,aTrbCo,'PlsVldBHC') //"Co-participacao - "

ACTIVATE DIALOG oDlgCo CENTERED ON INIT ( EnchoiceBar(oDlgCo, {|| nOpca:=1,oDlgCo:End()},{|| nOpca:= 0,oDlgCo:End()} ))

If nOpca == 1
   aCabCo := aClone(oBrwCo:aHeader)
   aDadCo := aClone(oBrwCo:aCols)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PL940RefeiAcomp
Monta a getdados das idades dos acompanhantes para refeição

@author sakai
@since 03/06/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function PL940RefeiAcomp(nOpc)

	Local oDlgIdaAcomp                   
	Local nOpca := 0

	If M->BR8_REFACO <> "1"
		MsgInfo(STR0054,STR0055) // "Campo de refeição para acompanhantes não habilitado, Portanto não será permitido cadastrar as idades dos acompanhante.";"Não Permitido"
		Return .F.
	EndIf

	If nOpc == 3
		nOpc := K_Alterar
	Else
		nOpc := K_Visualizar
	EndIf

	DEFINE MSDIALOG oDlgIdaAcomp TITLE STR0052+" - "+Alltrim(BR8->BR8_DESCRI) FROM 009,000 TO 029,060 OF GetWndDefault() // "Refeic. Acompanhantes"
	
	oDlgIdaAcomp:lEscClose := .F.                               
	oBrwIdaAcomp  := TPLSBrw():New(0030, 001, 237, 150, nil, oDlgIdaAcomp, nil, nil, nil, nil, nil, .T., nil, .T., nil, ;
	                 aCabIdaAcomp, aDadIdaAcomp, .F., "BKV", nOpc, STR0052+" - "+BR8->BR8_DESCRI,, nil, nil, aTrbIdaAcomp, 'PlsVldBKV') // "Refeic. Acompanhantes"
	
	ACTIVATE DIALOG oDlgIdaAcomp CENTERED ON INIT ( EnchoiceBar(oDlgIdaAcomp, {|| nOpca:=1, oDlgIdaAcomp:End()}, {|| nOpca:= 0, oDlgIdaAcomp:End()} ))

	If nOpca == 1
		aCabIdaAcomp := aClone(oBrwIdaAcomp:aHeader)
		aDadIdaAcomp := aClone(oBrwIdaAcomp:aCols)
	EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ A940PAR ³ Autor ³ Microsiga            ³ Data ³ 02.06.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a getdados da Co Participacao                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLS940DEPA(nOpc)

Local oDlgDePara                   
Local nOpca  := 0

If nOpc == 3
   nOpc := K_Alterar
Else
   nOpc := K_Visualizar
EndIf      

DEFINE MSDIALOG oDlgDePara TITLE "De/Para Intercâmbio: "+BR8->BR8_DESCRI FROM 009,000 TO 029,060 OF GetWndDefault() //"Co-participacao - "
oDlgDePara:lEscClose := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwDePara  := TPLSBrw():New(0030,001,237,150,nil  ,oDlgDePara,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabDePara ,aDadDePara ,.F. ,"B1M" ,nOpc,"De/Para Intercâmbio: "+BR8->BR8_DESCRI ,,nil,nil,aTrbDePara,'PlsVldB1M') //"Co-participacao - "

ACTIVATE DIALOG oDlgDePara CENTERED ON INIT ( EnchoiceBar(oDlgDePara, {|| nOpca:=1,oDlgDePara:End()},{|| nOpca:= 0,oDlgDePara:End()} ))

If nOpca == 1
   aCabDePara := aClone(oBrwDePara:aHeader)
   aDadDePara := aClone(oBrwDePara:aCols)
EndIf

Return
      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLS940ADDC³ Autor ³ Tulio Cesar        ³ Data ³ 12.02.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a getdados da Qtd/Percentual                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLS940ADQT(nOpc)

Local oDlgQtd
Local nOpca   := 0

If nOpc == 3
   nOpc := K_Alterar
Else
   nOpc := K_Visualizar
EndIf      

DEFINE MSDIALOG oDlgQtd TITLE STR0018+BR8->BR8_DESCRI FROM 009,000 TO 029,060 OF GetWndDefault() //"Qtd x Percentual - "
oDlgQtd:lEscClose := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwQtd  := TPLSBrw():New(0030,001,237,150,nil  ,oDlgQtd,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabQtd ,aDadQtd ,.F. ,"BL0" ,nOpc,STR0018+BR8->BR8_DESCRI ,,nil,nil,aTrbQtd) //"Qtd X Percentual - "

ACTIVATE DIALOG oDlgQtd CENTERED ON INIT ( EnchoiceBar(oDlgQtd, {|| nOpca:=1,oDlgQtd:End()},{|| nOpca:= 0,oDlgQtd:End()} ))

If nOpca == 1
   aCabQtd := aClone(oBrwQtd:aHeader)
   aDadQtd := aClone(oBrwQtd:aCols)
EndIf

Return      


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLS940GENQ³ Autor ³ Michele Tatagiba     ³ Data ³ 29.11.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Se a quantidade for informada para uma Clinica,Especialidade³±±
±±³          ³ Medico ou Patologia, o campo Generico nao pode ser preenchid³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS940GENQ()
               
Local lRet := .T.

If M->BR8_QTDCRE == "0" .Or. M->BR8_QTDESP == "0" .Or. M->BR8_QTDMED == "0";
   .Or. M->BR8_QTDPAT = "0"
   lRet := .F.
EndIf

Return(lRet)        


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLS940GENP³ Autor ³ Michele Tatagiba     ³ Data ³ 29.11.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Se o periodo for informada para uma Clinica,Especialidade,  ³±±
±±³          ³ Medico ou Patologia, o campo Generico nao pode ser preenchid³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS940GENP()
               
Local lRet := .T.

If lRet .And. (M->BR8_PTRCRE == "0" .Or. M->BR8_PTRESP == "0" .Or. M->BR8_PTRMED == "0";
   .Or. M->BR8_PTRPAT = "0")
   lRet := .F.
EndIf

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA940WHE³ Autor ³ Tulio Cesar          ³ Data ³ 14.01.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ When de diversos campo do siga...                           ³±±
±±³          ³ nao cabe no X3_WHEN ai coloca em uma funcao                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA940Whe(cTipo)

Local lPode := .F.

If     cTipo == "01" //BHC_PERCOP
       lPode := ( M->BHC_VLRCOP == 0 )
ElseIf cTipo == "02" //BHC_VLRCOP
       lPode := ( M->BHC_PERCOP == 0 .And. M->BHC_VALUS == 0 )       
ElseIf cTipo == "03" //BHC_VALUS
       lPode := ( M->BHC_VLRCOP == 0 )       
EndIf
                                        
Return(lPode)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA940DPR³ Autor ³ Tulio Cesar          ³ Data ³ 11.02.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do campo BR8_DESPAC                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA940DPR(cTipo)
LOCAL cRet        := ""
Return(cRet)	


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PL940PERIO³ Autor ³Luciano Aparecido   ³ Data ³ 18.01.2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a getdados Periodicidade Grupo Proced./Proced...    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PL940PERIO(cCodPad,cCodPro,nOpc)

Local oDlgPerio
Local nOpca     := 0
Local aButtons  := {}

If nOpc == 3
   nOpc := K_Alterar
Else
   nOpc := K_Visualizar
EndIf      

DEFINE MSDIALOG oDlgPerio TITLE STR0027+" - "+Alltrim(cCodPro)+" - "+Alltrim(BR8->BR8_DESCRI) FROM 009,000 TO 029,060 OF GetWndDefault()  //"Grupo Periodicidade/Procedimento"
oDlgPerio:lEscClose := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse ...					                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aButEsp := {{OemtoAnsi(STR0051),{||PlVigDifId("B06",'xFilial("B06")+M->(B06_CODPAD+B06_CODPSA+B06_CODTAB+B06_CODPRO+B06_NIVEL)',M->B06_DIFIDA)},OemtoAnsi(STR0051),OemtoAnsi(STR0051)}} //"Period. Dif. Idade"

oBrwPerio  := TPLSBrw():New(0030,001,237,150,nil  ,oDlgPerio,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabPerio ,aDadPerio ,.F. ,"B06" ,nOpc,STR0027+" - "+Alltrim(BR8->BR8_DESCRI) ,,nil,nil,aTrbPerio,,,,,aButEsp)  //"Grupo Periodicidade/Procedimento"

ACTIVATE DIALOG oDlgPerio CENTERED ON INIT ( EnchoiceBar(oDlgPerio, {|| nOpca:=1,oDlgPerio:End()},{|| nOpca:= 0,oDlgPerio:End()},.f.,aButtons ))

If nOpca == 1
   aCabPerio := aClone(oBrwPerio:aHeader)
   aDadPerio := aClone(oBrwPerio:aCols)
EndIf

Return    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PLS940LOk ºAutor  ³Luciano Aparecido   º Data ³  28/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a linha da msGetdados                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSA940     		                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS940LOk ()

Local lRet  := .T. //Retorno da funcao
Local nI    := 0
Local nPos  := 0

nPos  := aScan(aCabPerio,{|x| AllTrim(x[2])=="B06_CODPRO"})	
If nPos > 0 
	For nI:=1 to Len(aDadPerio)		
		If M->B06_CODPRO == aDadPerio[nI,nPos] 
			MsgAlert(STR0031+" ! --> "+AllTRIM(M->B06_CODPRO)) //"Já existe este procedimento cadastrado"
			lRet:=.F.
		EndIf			
	Next nI
EndIf  

Return lRet    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |P940FAC 	ºAutor  ³Daher			     º Data ³  28/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³															  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSA940     		                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS940FAC()
LOCAL lRet 	:= .F.

If Type("M->BYL_FACE") <> "U"
	If !Empty(M->BYL_FACE)
		lRet := (ExistChav("BYL",cChvPad+cChvPsa+cChvReg+cChvTipo+M->BYL_FACE) .and. ExistCpo("B09",M->BYL_FACE))
		If lRet
			If !Empty(M->BYL_FACE)
				B09->(DbSetOrder(1))
				If B09->(MsSeek(xFilial("B09")+M->BYL_FACE))
					M->BYL_DESFAC := B09->B09_FACDES
				Endif
			Else
				M->BYL_DESFAC := ""
			Endif
		Endif
	Endif
	
Elseif Type("M->B87_FACE") <> "U"
    // apenas se informada a face
	If !Empty(M->B87_FACE)          
	
		// Verifica se a face existe
		B09->(DbSetOrder(1))           
		If B09->(MsSeek(xFilial("B09")+M->B87_FACINC))                                                                     
			// Verifica chave duplicada no B87.
			lRet := (ExistChav("B87",cChvPad+cChvPsa+cChvReg+cChvTipo+M->B87_FACINC))
		                                       
			// Ok Parcial.
			If lRet       
				// Verifica se a face eh valida para o dente.
				If BYL->( MsSeek(xFilial("BYL")+M->B87_CODPAD+M->B87_CODPSA+M->B87_DENREG+cChvTipo+M->B87_FACINC) )
					M->B87_DESFCI := B09->B09_FACDES
					
				Else
					MsgAlert("A Face digitada nao existe no cadastro de Dente/Regiao do procedimento informado!")
					M->B87_DESFCI := ""
					
					lRet := .F.
				Endif
			Endif
		Else
			MsgAlert("A Face digitada nao existe no cadastro!")
			M->B87_DESFCI := ""	
			lRet := .F.
		 
		Endif
	Else
		M->B87_DESFCI := ""	
		lRet := .T.
	Endif
Endif

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³08/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                   
Static Function MenuDef()
Local lVisual := .F.	// Define Menu apenas visual.
Private aRotina := {{ STR0001			, 'AxPesqui'   , 0 ,K_Pesquisar  , 0,.f.},; 	//"Pesquisar"
					{ STR0002			, 'PLSA940MOV' , 0 ,K_Visualizar , 0,nil}} 		//"Visualizar"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Defini-se as regras para um menu apenas visual                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lVisual := IsInCallStack("PLSA790V") // Rotina Auditoria somente visualiza

If !lVisual .AND. ALIAS() != "BEL"				     
	aadd(aRotina,{ STR0003	, 'PLSA940MOV' , 0 ,K_Alterar , 0,nil})	//"Alterar"
EndIf                                                            
If !lVisual                                                                                 
	aadd(aRotina,{ STR0032	, 'PLSA940SDE' , 0 ,K_Visualizar })		//"Dente/Região"
EndIf          

aadd(aRotina,{ OemtoAnsi(STR0051)	,'PlVigDifId("BR8","BR8->(BR8_FILIAL+BR8_CODPAD+BR8_CODPSA)",BR8->BR8_DIFIDA)',0,K_Alterar})		//"Period. Dif. Idade"

If Existblock("PLS940M3")
	aPtoEntrada := Execblock("PLS940M3",.f.,.f.)
	aadd(aRotina,{aPtoEntrada[1],aPtoEntrada[2],0,K_Incluir})
Endif

aadd(aRotina, {"Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('BR8',BR8->BR8_CODPSA, 1)})", 0 ,K_Visualizar})
aadd(aRotina, {"Excluir Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('BR8',BR8->BR8_CODPSA, 0)})", 0 ,K_Visualizar})
	

Return(aRotina)  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSVLD940 ³ Autor ³ Daher			        ³ Data ³ 26.06.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de campos 						   			      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLD940()

Local lRet := .F.

If Readvar() == "M->B08_CODPAD"  
	If !Empty(M->B08_CODPAD)               
		BR4->(DbSetOrder(1))
		BR4->(MsSeek(xFilial("BR4")+M->B08_CODPAD))       	
		lRet := ExistCpo('BR4',M->B08_CODPAD,1)
		If lRet
			M->B08_DESPAD := BR4->BR4_DESCRI
			M->B08_CODPSA := space(TamSx3("B08_CODPSA")[1])
			M->B08_DESCRI := space(TamSx3("B08_DESCRI")[1])
			M->B08_DENREG := space(TamSx3("B08_DENREG")[1])
			M->B08_DESREG := space(TamSx3("B08_DESREG")[1])						
		EndIf
	Else
		M->B08_DESPAD := space(TamSx3("B08_DESPAD")[1])   
		M->B08_CODPSA := space(TamSx3("B08_CODPSA")[1])
		M->B08_DESCRI := space(TamSx3("B08_DESCRI")[1])
		M->B08_DENREG := space(TamSx3("B08_DENREG")[1])
		M->B08_DESREG := space(TamSx3("B08_DESREG")[1])
		lRet := .T.
	EndIf
EndIf

If Readvar() == "M->B08_CODPSA"  
	If !Empty(M->B08_CODPSA)               
		BR8->(DbSetOrder(1))
		BR8->(MsSeek(xFilial("BR8")+M->B08_CODPAD+M->B08_CODPSA))       	
		lRet := ExistCpo('BR8',M->B08_CODPAD+M->B08_CODPSA,1)
		If lRet
			M->B08_DESCRI := BR8->BR8_DESCRI 
			M->B08_DENREG := space(TamSx3("B08_DENREG")[1])
			M->B08_DESREG := space(TamSx3("B08_DESREG")[1])
			PLSGatNiv(M->B08_CODPAD,M->B08_CODPSA,"B08",.F.,.T.)			
		EndIf
	Else
		M->B08_DESCRI := space(TamSx3("B08_DESCRI")[1])
		M->B08_DENREG := space(TamSx3("B08_DENREG")[1])
		M->B08_DESREG := space(TamSx3("B08_DESREG")[1])
		lRet := .T.
	EndIf
EndIf

If Readvar() == "M->B08_DENREG"  
	If !Empty(M->B08_DENREG)  
		B05->(DbSetOrder(1))
		B05->(MsSeek(xFilial("B05")+M->B08_CODPAD+M->B08_CODPSA+M->B08_DENREG))       	
		lRet := ExistCpo('B05',M->B08_CODPAD+M->B08_CODPSA+M->B08_DENREG,1)
		If lRet
			M->B08_DESREG := B05->B05_DESCRI			
		EndIf
	Else
		M->B08_DESREG := space(TamSx3("B08_DESREG")[1])
		lRet := .T.
	EndIf
EndIf
     
If Readvar() == "M->B0N_CODPAD"  
	If !Empty(M->B0N_CODPAD)               
		BR4->(DbSetOrder(1))
		BR4->(MsSeek(xFilial("BR4")+M->B0N_CODPAD))       	
		lRet := ExistCpo('BR4',M->B0N_CODPAD,1)
		If lRet
			M->B0N_DESPAD := BR4->BR4_DESCRI
			M->B0N_CODPSA := space(TamSx3("B0N_CODPSA")[1])
			M->B0N_DESCRI := space(TamSx3("B0N_DESCRI")[1])
			M->B0N_DENREG := space(TamSx3("B0N_DENREG")[1])
			M->B0N_DESREG := space(TamSx3("B0N_DESREG")[1])						
		EndIf
	Else
		M->B0N_DESPAD := space(TamSx3("B0N_DESPAD")[1])   
		M->B0N_CODPSA := space(TamSx3("B0N_CODPSA")[1])
		M->B0N_DESCRI := space(TamSx3("B0N_DESCRI")[1])
		M->B0N_DENREG := space(TamSx3("B0N_DENREG")[1])
		M->B0N_DESREG := space(TamSx3("B0N_DESREG")[1])
		lRet := .T.
	EndIf
EndIf

If Readvar() == "M->B0N_CODPSA"  
	If !Empty(M->B0N_CODPSA)               
		BR8->(DbSetOrder(1))
		BR8->(MsSeek(xFilial("BR8")+M->B0N_CODPAD+M->B0N_CODPSA))       	
		lRet := ExistCpo('BR8',M->B0N_CODPAD+M->B0N_CODPSA,1)
		If lRet
			M->B0N_DESCRI := BR8->BR8_DESCRI 
			M->B0N_DENREG := space(TamSx3("B0N_DENREG")[1])
			M->B0N_DESREG := space(TamSx3("B0N_DESREG")[1])
			PLSGatNiv(M->B0N_CODPAD,M->B0N_CODPSA,"B0N",.F.,.T.)			
		EndIf
	Else
		M->B0N_DESCRI := space(TamSx3("B0N_DESCRI")[1])
		M->B0N_DENREG := space(TamSx3("B0N_DENREG")[1])
		M->B0N_DESREG := space(TamSx3("B0N_DESREG")[1])
		lRet := .T.
	EndIf
EndIf

If Readvar() == "M->B0N_DENREG"  
	If !Empty(M->B0N_DENREG)  
		B05->(DbSetOrder(1))
		B05->(MsSeek(xFilial("B05")+M->B0N_CODPAD+M->B0N_CODPSA+M->B0N_DENREG))       	
		lRet := ExistCpo('B05',M->B0N_CODPAD+M->B0N_CODPSA+M->B0N_DENREG,1)
		If lRet
			M->B0N_DESREG := B05->B05_DESCRI			
		EndIf
	Else
		M->B0N_DESREG := space(TamSx3("B0N_DESREG")[1])
		lRet := .T.
	EndIf
EndIf

If Readvar() == "M->B09_FADENT"  
	If !Empty(M->B09_FADENT)                       
		lRet := ExistChav("B09",M->B09_FADENT)
	Else
		lRet := .t.
	EndIf
EndIf

If Readvar() == "M->B10_FADENT"  
	If !Empty(M->B10_FADENT)                       
		lRet := ExistChav("B10",cFace+M->B10_FADENT)
		If lRet
			B09->(DbSetOrder(1))
			B09->(MsSeek(xFilial("B09")+M->B10_FADENT))       	
			M->B10_FACDES := B09->B09_FACDES
		EndIf
	Else
		lRet := .t.
	Endif
Endif
     
If Readvar() == "M->B87_CODPAD"  
	If !Empty(M->B87_CODPAD)               
		// Verifica se procedimento existe
		BR4->(DbSetOrder(1))
		BR4->(MsSeek(xFilial("BR4")+M->B87_CODPAD))       	
		lRet := ExistCpo('BR4',M->B87_CODPAD,1)
		
		// verifica se o dente existe.
		If lRet              
			M->B87_DESPAD := BR4->BR4_DESCRI
			M->B87_CODPSA := space(TamSx3("B87_CODPSA")[1])
			M->B87_DESCRI := space(TamSx3("B87_DESCRI")[1])
		Endif
	Else
		M->B87_DESPAD := space(TamSx3("B87_DESPAD")[1])   
		M->B87_CODPSA := space(TamSx3("B87_CODPSA")[1])
		M->B87_DESCRI := space(TamSx3("B87_DESCRI")[1])
		lRet := .T.
	Endif
Endif

If Readvar() == "M->B87_CODPSA"  
	If !Empty(M->B87_CODPSA)               
		BR8->(DbSetOrder(1))
		BR8->(MsSeek(xFilial("BR8")+M->B87_CODPAD+M->B87_CODPSA))       	
		lRet := ExistCpo('BR8',M->B87_CODPAD+M->B87_CODPSA,1)
		If lRet
			B05->( dbSetorder(01) )
			lRet := B05->( MsSeek(xFilial("B05")+M->B87_CODPAD+M->B87_CODPSA+M->B87_CHVREG) )
		
		    If lRet
				M->B87_DESCRI := BR8->BR8_DESCRI 
				M->B87_DESREG := B05->B05_DESCRI			
				
				PLSGatNiv(M->B87_CODPAD,M->B87_CODPSA,"B87",.F.,.T.)			
			Else
				MsgAlert('O Dente/Regiao "'+M->B87_CHVREG+'" nao existe cadastrado para o procedimento informado. Verifique o cadastro de Dente/Regiao do procedimento informado!')
				M->B87_DESCRI := space(TamSx3("B87_DESCRI")[1])
				M->B87_DESREG := space(TamSx3("B87_DESREG")[1])				
				
			Endif

		Endif
	Else
		M->B87_DESCRI := space(TamSx3("B87_DESCRI")[1])
		M->B87_DESREG := space(TamSx3("B87_DESREG")[1])
		lRet := .T.
	Endif
Endif

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLS940PESQ³ Autor ³ Daher			        ³ Data ³ 26.06.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 											   			      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS940PESQ()   

Local lRet    := .F.                                    	
Local cCodPad := ""
Local nRecBr8 := BR8->(Recno())
Local nOrdBR8 := BR8->(Indexord())

If Type("M->B08_CODPAD") <> "U"
	cCodPad := M->B08_CODPAD
EndIf                
              
If Type("M->B09_CODPAD") <> "U"
	cCodPad := M->B09_CODPAD
EndIf
     
If Type("M->B0N_CODPAD") <> "U"
	cCodPad := M->B0N_CODPAD
Endif
     
If Type("M->B87_CODPAD") <> "U"
	cCodPad := M->B87_CODPAD
Endif

lRet := PLSPESPROC(cCodPad,.F.)
cCodPSA := BR8->BR8_CODPSA           
BR8->(DbGoTo(nRecBr8))
BR8->(DbSetOrder(nOrdBR8))  

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLS940Alt  ³ Autor ³ Renan Sakai	        ³ Data ³ 14/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Para criar validacoes ao confirmar a alteracao/visualizacao ³±±    
±±³          ³do item com o Ponto de Entrada PLS940VLD.                   ³±±    
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLS940Alt(nOpc)  
Local lRet := .T.        

If Existblock("PLS940VLD")
  lRet := Execblock("PLS940VLD",.F.,.F.,{nOpc})
EndIf

Return (lRet) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSVLDLEM ºAutor  ³Microsiga           º Data ³  06/25/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao do formulario						   			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSA940                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PLSVLDLEM()  
Local lRet := .T.  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Periodo Lemb e Unidade Lemb.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BR8->( FieldPos("BR8_QTDLEM") ) > 0 .And. BR8->( FieldPos("BR8_PERLEM") ) > 0 .And. BR8->( FieldPos("BR8_UNILEM") ) > 0 
	If M->BR8_QTDLEM > 0 .And. M->BR8_PERLEM == 0  
		lRet := .F.
		MsgInfo(STR0046)//"Informe o campo Periodo Lemb"
	ElseIf M->BR8_QTDLEM > 0 .And. M->BR8_PERLEM > 0 .And. Empty(M->BR8_UNILEM)
		lRet := .F.
		MsgInfo(STR0047)//"Informe o campo Unidade Lemb"
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quantidade Max. e Min de Exec.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->BR8_QTMIAU > M->BR8_QTMAAU
	lRet := .F.
	Help("",1,"PLSA940QTD")
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSVLDCPO ºAutor  ³Microsiga           º Data ³  29/10/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao de campos do formulario					      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSA940                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSVLDCPO(cCampo)
Local 	lRet	:= .T.
Default cCampo	:= ReadVar()

If AllTrim(cCampo) == "M->BR8_QTMIAU" //Qtd. Min.
	If !(M->BR8_QTMIAU <= M->BR8_QTMAAU .Or. Vazio()) .And. M->BR8_QTMAAU <> 0
		lRet := .F.
		Help("",1,"PLSA940QTD")
	Endif
Elseif AllTrim(cCampo) == "M->BR8_QTMAAU" //Qtd. Max.
	If !(M->BR8_QTMAAU >= M->BR8_QTMIAU .Or. Vazio()) .And. M->BR8_QTMIAU <> 0
		lRet := .F.
		Help("",1,"PLSA940QTD")
	Endif
Endif

Return lRet

        
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA940ExcºAutor  ³Microsiga           º Data ³  29/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exclusão da tabela B05, B08 E BYL                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSA940Exc() 

Local   aArea  := GetArea()
Private aParam := {}

aAdd( aParam,  {||} )  //antes da abertura
aAdd( aParam,  {|| U_PLSA940cEx() } )  //ao clicar no botao ok
aAdd( aParam,  {||} )  //durante a transacao
aAdd( aParam,  {||} )       //termino da transacao

nOpca := AxDeleta("B05",B05->(Recno()),5,,,,aParam,,,,,,,) 

RestArea(aArea) 

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldBHC ºAutor  ³Microsiga           º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funca de validacao das datas de vigencia, chamada no       º±±
±±º          ³ botao de OK da Rotina Cobertura / Co-Participacao.         º±±
±±º          ³ Tabela - BHC - Tabela Padrao Co-Participacao.			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PlsVldBHC() 
Local lRet     := .T.
Local cDatDe   := ""
Local cDatAte  := "" 
Local aChave   := {}
Local aArea	   := GetArea()      

If BHC->( FieldPos("BHC_FINATE") ) > 0 
	aChave := {'01',M->BHC_TIPO+cValToChar(M->BHC_QTD)+M->BHC_CODTAB+M->BHC_FINATE,'BHC_TIPO+BHC_QTD+BHC_CODTAB+BHC_FINATE'}
Else
	aChave := {'01',M->BHC_TIPO+cValToChar(M->BHC_QTD)+M->BHC_CODTAB,'BHC_TIPO+BHC_QTD+BHC_CODTAB'}
Endif

If  BHC->( FieldPos("BHC_VIGINI") ) > 0 .And. BHC->( FieldPos("BHC_VIGFIN") ) > 0
	cDatDe   := "BHC_VIGINI"
	cDatAte  := "BHC_VIGFIN"

	If !Empty(M->BHC_VIGINI)
		lRet := PLSVLDVIG("BHC",0,oBrwCo,cDatDe,cDatAte,aChave)
	EndIf
EndIf	

RestArea(aArea)

Return(lRet)      


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA940ExcºAutor  ³Microsiga           º Data ³  29/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exclusao das tabelas B08, BYL, BON e B05                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PLSA940cEx()  

Local aArea := GetArea()

DbSelectArea("B08")
DbSetOrder(1)
DbGoTop()	

If DbSeek(xFilial("B08")+B05->B05_CODPAD+B05->B05_CODPSA+B05->B05_CODIGO)
   While !Eof() .and. xFilial("B08")+B08->B08_CHVPAD+B08->B08_CHVPSA+B08->B08_CHVREG==xFilial("B05")+B05->B05_CODPAD+B05->B05_CODPSA+B05->B05_CODIGO
		RecLock("B08",.F.)	
			dbDelete()
		MsUnlock()  
   		DbSkip()
   EndDo
EndIf      

DbSelectArea("BYL")
DbSetOrder(1)	
DbGoTop()

If DbSeek(xFilial("BYL")+B05->B05_CODPAD+B05->B05_CODPSA+B05->B05_CODIGO)
   While !Eof() .and. xFilial("BYL")+BYL->BYL_CODPAD+BYL->BYL_CODPSA+BYL->BYL_CODIGO==xFilial("B05")+B05->B05_CODPAD+B05->B05_CODPSA+B05->B05_CODIGO
		RecLock("BYL",.F.)	
			dbDelete()
		MsUnlock()  
   		DbSkip()
   EndDo
EndIf    
    
DbSelectArea("B0N")
DbSetOrder(2)
DbGoTop()
	
If DbSeek(xFilial("B0N")+B05->B05_CODPAD+B05->B05_CODPSA+B05->B05_CODIGO)
   While !Eof() .and. xFilial("B0N")+B0N->B0N_CHVPAD+B0N->B0N_CHVPSA+B0N->B0N_CHVREG==xFilial("B05")+B05->B05_CODPAD+B05->B05_CODPSA+B05->B05_CODIGO
		RecLock("B0N",.F.)	
			dbDelete()
		MsUnlock()                   
   		DbSkip()
   EndDo
EndIf

B05->(RecLock("B05",.F.))	
B05->(dbDelete())
B05->(MsUnlock())  
                   
RestArea(aArea) 

Return 
   
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSQTDBHC ºAutor  ³Microsiga           º Data ³  08/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a quantidade quando nao existe data de vigencia     º±±
±±º          ³ Informada e nao permite quantidade duplicada.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSQTDBHC()
Local lRet := .F. 
Local nX   := 0     
Local nPosIni := ""
Local nPosFin := ""
Local nQTD    := ""   
Local aArea	  := GetArea()  
Local nUsado  := Len(oBrwCo:aHeader)

nQTD    := Ascan(oBrwCo:aHeader,{|x| Alltrim(x[2])=="BHC_QTD"})  

If BHC->( FieldPos("BHC_VIGINI") ) > 0 .And. BHC->( FieldPos("BHC_VIGFIN") ) > 0
	nPosIni := Ascan(oBrwCo:aHeader,{|x| Alltrim(x[2])=="BHC_VIGINI"})
	nPosFin := Ascan(oBrwCo:aHeader,{|x| Alltrim(x[2])=="BHC_VIGFIN"})	
	For nX := 1 To Len(oBrwCo:aCols)
		If !oBrwCo:aCols[nX][nUsado+1]
			If nX < n
				If M->BHC_VIGINI == CTOD(" / / ") .And. M->BHC_VIGFIN == CTOD(" / / ")
					If M->BHC_QTD == oBrwCo:aCols[nX][nQTD] .And. Empty(oBrwCo:aCols[nX][nPosIni]) .And. Empty(oBrwCo:aCols[nX][nPosFin])
						PLSVLDCOL({"BHC_TIPO","BHC_QTD"})                                                                                                     
						Return lRet := .T.
					EndIf
				EndIf
			EndIf
		EndIf
	Next nX 
Else
	PLSVLDCOL({"BHC_TIPO","BHC_QTD"})		
EndIf

RestArea(aArea)

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pls940Brw ºAutor  ³Microsiga           º Data ³  		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                											  º±±
±±º          ³    													      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Pls940Brw(cCampo) 

cRet := ""

If cCampo == "B0N_DESPAD"
	cRet := Posicione("BR4",1,xFilial("BR4")+B0N->B0N_CODPAD,"BR4_DESCRI")	
ElseIf cCampo == "B0N_DESCRI"
	cRet := Posicione("BR8",1,xFilial("BR8")+B0N->B0N_CODPAD+B0N->B0N_CODPSA,"BR8_DESCRI")	
ElseIf cCampo == "B0N_DESREG"
	cRet := Posicione("B05",1,xFilial("B05")+B0N->B0N_CODPAD+B0N->B0N_CODPSA+B0N->B0N_DENREG,"B05_DESCRI")

ElseIf cCampo == "B87_DESREG"
	cRet := Posicione("B05",1,xFilial("B05")+B87->(B87_CODPAD+B87_CODPSA+B87_DENREG),"B05_DESCRI")

Endif

Return( cRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA940   ºAutor  ³Microsiga           º Data ³  08/18/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLB0NINI(cCampo)
cRet := ""

If cCampo == "B0N_DESPAD"
	cRet := Iif(inclui,"",Posicione("BR4",1,xFilial("BR4")+B0N->B0N_CODPAD,"BR4_DESCRI"))
	
Elseif cCampo == "B0N_DESCRI"
	cRet := Iif(inclui,"",Posicione("BR8",1,xFilial("BR8")+B0N->B0N_CODPAD+B0N->B0N_CODPSA,"BR8_DESCRI"))
	
Elseif cCampo == "B0N_DESREG"
	cRet := Iif(inclui,"",Posicione("B05",1,xFilial("B05")+B0N->B0N_CODPAD+B0N->B0N_CODPSA+B0N->B0N_DENREG,"B05_DESCRI"))
	
Endif

Return(cRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldB1M ºAutor  ³Microsiga           º Data ³  03/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funca de validacao das datas de vigencia, chamada no       º±±
±±º          ³ botao de OK da Rotina De/Para Intercambio                  º±±
±±º          ³ Tabela - B1M - De/Para Intercambio                  	      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PlsVldB1M() 
Local lRet     := .T.
Local cDatDe   := ""
Local cDatAte  := "" 
Local aChave   := {}
Local aArea	   := GetArea()      

cDatDe   := "B1M_DATINI"
cDatAte  := "B1M_DATFIN"

If !Empty(M->B1M_DATINI)
	lRet := PLSVLDVIG("B1M",0,oBrwDePara,cDatDe,cDatAte,aChave)
EndIf

RestArea(aArea)

Return(lRet)    


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSABKVSEQ
Cria Sequencia

@author  PLS TEAM
@since   03/06/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLSBKVSEQ()
	
	Local cRet := ""

	if ValType(oBrwIdaAcomp) == "O"

		if oBrwIdaAcomp:aCols[Len(oBrwIdaAcomp:aCols),Len(oBrwIdaAcomp:aHeader)+1]
			cRet := Soma1(oBrwIdaAcomp:FieldGet("BKV_SEQUEN"))
		else
			cRet := PLSINCRE("BKV_SEQUEN",oBrwIdaAcomp)
		endIf
	else
		cRet := PLSINCRE("BKV_SEQUEN")
	endIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVldBKV
Valida inclusao de Idades do Acompanhante

@author  PLS TEAM
@since   03/06/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PlsVldBKV()

	Local lRet    := .T.
	Local nX      := 0
	Local cTipo   := ""
	Local nIdaMin := 0
	Local nIdaMax := 0

	for nX := 1 to len(oBrwIdaAcomp:aCols)
		if !oBrwIdaAcomp:aCols[nX,Len(oBrwIdaAcomp:aHeader)+1] .And. M->BKV_SEQUEN <> oBrwIdaAcomp:FieldGet("BKV_SEQUEN",nX)
			nIdaMin := oBrwIdaAcomp:FieldGet("BKV_IDAMIN",nX)
			nIdaMax := oBrwIdaAcomp:FieldGet("BKV_IDAMAX",nX)
			cTipo   := oBrwIdaAcomp:FieldGet("BKV_TIPO",nX)
			if (cTipo == "3" .Or. M->BKV_TIPO == "3" .Or. cTipo == M->BKV_TIPO) .And. (;
				(M->BKV_IDAMIN >= nIdaMin .And. M->BKV_IDAMIN <= nIdaMax) .Or. ;
				(M->BKV_IDAMAX >= nIdaMin .And. M->BKV_IDAMAX <= nIdaMax) )

				lRet := .F.
				MsgInfo(STR0053) //"O período informado está em conflito com um período já existente."
			endIf
		endIf
	next

Return lRet