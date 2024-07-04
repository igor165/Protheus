#INCLUDE "TMKA190.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA190   บAutor  ณArmando M. Tessaroliบ Data ณ  27/08/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastramento no modelo padrao da REGRA DE NEGOCIACAO.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณFernando  ณ12/12/06ณ9.12  ณBops 115403 Alterado a array aRotina        ณฑฑ
ฑฑณ          ณ        |      ณpara cria็ใo do menu funcional              ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TMKA190( aRotAuto, nOpc )

Private aRotina := MenuDef() 
Private cCadastro := STR0006 //"Atualiza็ใo da Regra de Negocia็ใo"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao de variaveis para rotina de inclusao automatica    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private lTk190Auto := ( aRotAuto <> NIL )

If lTk190Auto
	MsRotAuto(nOpc,aRotAuto,"SK2")
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Endereca a funcao de BROWSE                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	mBrowse(,,,,"SK2")
Endif

Return(.T.)


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |MenuDef   ณ Autor ณ Fernando Amorim       ณ Data ณ08/12/06  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao de defini็ใo do aRotina                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ aRotina   retorna a array com lista de aRotina             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGATMK                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef() 

Local aRotAdic	:= {}		// Retorno do P.E. TK190ROT
Local lTk190Rot := ExistBlock("TK190ROT")

Local aRotina		:= {{STR0001, "AxPesqui", 0, 1, , .F.},;			//"Pesquisar"
             		    {STR0002, "Tk190Cad", 0, 2, , .T.},;			//"Visualizar"
             		    {STR0003, "Tk190Cad", 0, 3, , .T.},;	  		//"Incluir"
             		    {STR0004, "Tk190Cad", 0, 4, , .T.},;	  		//"Alterar"
             		    {STR0005, "Tk190Cad", 0, 5, , .T.}}	  		//"Excluir"  
					
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de entrada - Adiciona rotinas ao aRotina               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lTk190Rot
	aRotAdic := ExecBlock("TK190ROT" , .F. , .F. )
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK190Inc  บAutor  ณArmando M. Tessaroliบ Data ณ  06/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao especifica de Inclusao da regra de negociacao SK2.   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK190Inc(cAlias, nReg, nOpc)

If ( Type("lTk190Auto") == "U" )
	lTk190Auto := .F.
Endif

If !lTk190Auto
	AxInclui(cAlias, nReg, nOpc)
Else
	AxIncluiAuto(cAlias)
Endif

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK190Alt  บAutor  ณArmando M. Tessaroliบ Data ณ  06/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao especifica de Alteracao da regra de negociacao SK2.  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK190Alt(cAlias, nReg, nOpc)

If ( Type("lTk190Auto") == "U" )
	lTk190Auto := .F.
Endif

If !lTk190Auto
	AxAltera(cAlias, nReg, nOpc)
Else
	AxIncluiAuto(cAlias,NIL,NIL,nOpc,SK0->(RecNo()))
Endif

Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK190Del  บAutor  ณArmando M. Tessaroliบ Data ณ  17/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao especifica de exclusao da regra de negociacao SK2, paบฑฑ
ฑฑบ          ณra validacao da integridade referencial.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk190Del(cAlias, nReg, nOpc)

Local aArea	:= GetArea()
Local lRet	:= .T.
Local cFilSU0	:= xFilial("SU0")

If ( Type("lTk190Auto") == "U" )
	lTk190Auto := .F.
Endif

DbSelectArea("SU0")
DbSetOrder(1)
#IFDEF TOP
	cQuery	:=	" SELECT U0_FILIAL, U0_REGNEG " +;
				" FROM " +	RetSqlName("SU0") + " SU0 " +;
				" WHERE	SU0.U0_FILIAL = '" + cFilSU0 + "' AND" +;
				"		SU0.U0_REGNEG = '" + SK2->K2_REGNEG + "' AND" +;
				"		SU0.D_E_L_E_T_ = ' ' " +;
				" ORDER BY " + SqlOrder(IndexKey())
		
	cQuery	:= ChangeQuery(cQuery)

	DbSelectArea("SU0")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SU0', .F., .T.)
	
#ELSE
	MsSeek(cFilSU0)
#ENDIF

While !Eof() .AND. SU0->U0_FILIAL == cFilSU0
	
	If SU0->U0_REGNEG == SK2->K2_REGNEG
		lRet := .F.
		Exit
	Endif
	
	DbSelectArea("SU0")
	DbSkip()
End

#IFDEF TOP
	DbSelectArea("SU0")
	DbCloseArea()
	ChkFile("SU0")
#ENDIF

RestArea(aArea)

If lRet
	If !lTk190Auto
		AxDeleta(cAlias, nReg, nOpc)
	Else
		DbSelectarea(cAlias)
		RecLock(cAlias,.F.,.T.)
		DbDelete()
		MsUnlock()
	Endif
Else
	If !lTk190Auto
		Help("  ",1,"TMKNDELREL")
		AxVisual(cAlias, nReg, nOpc)
	Endif
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ Tk190Cad บ Autor ณ Danilo Dias        บ Data ณ  13/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Desc.    ณ Funcao para inclusao, alteracao, exclusao ou visualizacao  บฑฑ
ฑฑบ          ณ da regra de negociacao com condicao de pagamento para      บฑฑ
ฑฑบ          ณ integracao com financeiro.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Param    ณ cAlias - Alias da tabela utilizada.                        บฑฑ
ฑฑบ          ณ nReg   - NUmero do registro.                               บฑฑ
ฑฑบ          ณ nOpc   - Opcao do menu.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso      ณ TMKA190                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk190Cad( cAlias, nReg, nOpc )

Local aArea 		:= GetArea()
Local cSeek 		:= nil				//Chave de busca para a FillGetDados
Local bWhile		:= nil				//Condicao para a busca na FillGetDados
Local lRet		:= .F.				//Retorno da rotina
Local nOpca 		:= 0				//Op็ใo selecionada pelo usuแrio no dialog
Local aColsAux	:= {}				//Auxiliar com os dados do aCols para a alteracao dos dados
Local aSize		:= MsAdvSize()		//Dimensoes da tela
Local nI, nJ							//Variaveis numericas de uso geral
Local oDlgRegra						//Dialog
Local oEncRegra						//Enchoice
Local oGetCondPg						//Grid

Private aTela[0][0]				//Usado na fun็ใo Obrigatorio()
Private aGets[0]					//Usado na fun็ใo Obrigatorio()
Private VISUAL	:= (nOpc == 2)	//Indica se e uma visualizacao
Private INCLUI	:= (nOpc == 3)	//Indica se e uma inclusao
Private ALTERA	:= (nOpc == 4)	//Indica se e uma alteracao
Private EXCLUI	:= (nOpc == 5)	//Indica se e uma exclusao


// chamada automatica.
//Nesse caso, aciona as rotinas antigas.
If 	( lTk190Auto )
	
	If INCLUI
		TK190Inc( cAlias, nReg, nOpc )
	ElseIf ALTERA
		Tk190Alt( cAlias, nReg, nOpc )
	ElseIf VISUAL
		AxVisual( cAlias, nReg, nOpc )
	ElseIf EXCLUI
		Tk190Del( cAlias, nReg, nOpc )
	EndIf
	
	lRet := .T.
	
Else

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Carrega tabela SK2 na memoria.                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SK2")		//Regras de Negociacao
	SK2->(dbSetOrder(1))	//K2_FILIAL + K2_REGNEG ( Filial + Regra de Negociacao )
	RegToMemory( "SK2", INCLUI, .F. )
	M->K2_FILIAL := xFilial("SK2")
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Carrega tabela SV0 na memoria.                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SV0")		//Condicoes de Pagamento da Regra de Negociacao
	SV0->(dbSetOrder(1))	//V0_FILIAL + V0_REGNEG + V0_CONDPG ( Filial + Regra + Condicao)
	RegToMemory( "SV0", INCLUI, .F. )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inicializa variaveis.                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cSeek 		:= xFilial("SV0") + M->K2_REGNEG			//Chave de busca para a FillGetDados
	bWhile 		:= { || SV0->V0_FILIAL + SV0->V0_REGNEG }	//While para a FillGetDados
	
	//Limpa aHeader e aCols
	aHeader	:= {}
	aCols 		:= {}
	
	//Monta aHeader e aCols com as condicoes de pagamento
	FillGetDados( nOpc, "SV0", 1, cSeek, bWhile,,,,,,, INCLUI )
	
	//Array auxiliar com o conteudo de aCols
	aColsAux := aClone(aCols)
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta dialog Modelo 3 para Regras de Negociacao com grid     ณ
	//ณ de condicoes de pagamento.                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oDlgRegra := MsDialog():New( 0, 0, aSize[6], aSize[5], cCadastro,,,,,,,, oMainWnd, .T. )	
		oEncRegra := MsMGet():New( "SK2",, nOpc,,,,, {10,10,130,aSize[3]},,1,,,, oDlgRegra,,,,,,, )
		oEncRegra:oBox:align := CONTROL_ALIGN_ALLCLIENT
		oGetCondPg := MsGetDados():New(150, 0, aSize[4], aSize[3], nOpc, "Tk190LinOk()","Tk190TudoOk()",,.T.,,,,, "Tk190CpoOk()",,,, oDlgRegra )
	oDlgRegra:Activate( ,,,.T.,,,EnchoiceBar( oDlgRegra, { || IIf( Tk190TudoOk(), (nOpca := 1, oDlgRegra:End()), nOpca := 0 ) }, {|| nOpca := 0, oDlgRegra:End() } ) )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Trata a opcao selecionada no dialog.                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ( nOpca == 1 )	
		//Acao para o botao Confirmar
		If ( INCLUI ) .Or. ( ALTERA )
			lRet := Tk190Grava( aColsAux )	
		ElseIf ( EXCLUI )
			lRet := Tk190Deleta()				
		ElseIf ( VISUAL )
			lRet := .T.
		EndIf
	Else	
		//Acao para o botao Fechar
		If ( INCLUI )
			RollBackSXE()	//Cancela a numeracao obtida pelo GetSXENum
		EndIf
	EndIf
EndIf

nOpca := 0
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ Tk190Grava บ Autor ณ Danilo Dias      บ Data ณ  13/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Desc.    ณ Funcao para gravacao dos dados inseridos ou alterados.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Param    ณ aColsAux - Copia do array aCols.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso      ณ TMKA190                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk190Grava( aColsAux )

Local aArea	:= GetArea()
Local nI, nJ			//Contadores de uso geral
Local lGravou	:= .F.	//Indica se a gravacao teve sucesso
Local lNovo	:= .T.	//Indica se e um novo item da grid ou nao
Local bCampo	:= { |nCPO| Field(nCPO) }	//Bloco de codigo para o FieldPut

//Inicia controle de transacao
Begin Transaction

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grava dados da Enchoice (Cabecalho), tabela SK2.             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RecLock( "SK2", INCLUI )
	For nI := 1 To FCount()
		FieldPut( nI, M->&( Eval( bCampo, nI ) ) )
	Next nI
	MsUnlock()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grava dados da GetDados (Itens), tabela SV0.                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ( Trim( aCols[1,1] ) != '' )
		For nI := 1 To Len(aCols)
		
			lNovo := .T.
			
			//Verifica se o item foi excluido do grid
			If ( aCols[nI, Len(aHeader) + 1] == .T. )
				//Se for alteracao exclui registro, senao nao faz nada
				If ( ALTERA ) .And. ( nI <= Len(aColsAux) )
					If ( SV0->( dbSeek( xFilial("SK2") + M->K2_REGNEG + aColsAux[nI, 1] ) ) )	
						RecLock( "SV0", .F. )
							SV0->(dbDelete())
						MsUnlock()
					EndIf
				EndIf
			Else
				//Grava o item na tabela
				If ( ALTERA )
					If ( nI <= Len(aColsAux) )
						If ( SV0->( dbSeek( xFilial("SK2") + M->K2_REGNEG + aColsAux[nI, 1] ) ) )
							lNovo := .F.
						EndIf
					EndIf
				EndIf
				
				RecLock( "SV0", lNovo)	
					SV0->V0_FILIAL := xFilial("SV0")
					SV0->V0_REGNEG := M->K2_REGNEG
					SV0->V0_CONDPG := aCols[nI,1]
				MsUnlock()
			EndIf
		Next nI
		lGravou := .T.
	Else
		lGravou := .T.
	EndIf
	
	//Verifica se houve erro na gravacao para desfazer a transacao
	If !lGravou
		RollBackSX8()
		DisarmTransaction()
	Else
		ConfirmSX8()	//Confirma numeracao obtida no SXE
	EndIf	
	
End Transaction
		
RestArea(aArea)

Return lGravou


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ Tk190Deleta บ Autor ณ Danilo Dias     บ Data ณ  13/12/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Desc.    ณ Exclui a regra de negociacao.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso      ณ TMKA190                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk190Deleta()

Local aArea	:= GetArea()
Local lRet 	:= .T.
Local cFilSU0	:= xFilial("SU0")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se a regra foi utilizada em um grupo de atendimento ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SU0")		//Grupo de Atendimento
SU0->(DbSetOrder(1))	//U0_FILIAL + U0_CODIGO ( Filial + Grupo )

#IFDEF TOP
	cQuery	:=	" SELECT U0_FILIAL, U0_REGNEG " +;
				" FROM " +	RetSqlName("SU0") + " SU0 " +;
				" WHERE	SU0.U0_FILIAL = '" + cFilSU0 + "' AND" +;
				"		SU0.U0_REGNEG = '" + SK2->K2_REGNEG + "' AND" +;
				"		SU0.D_E_L_E_T_ = ' ' " +;
				" ORDER BY " + SqlOrder(IndexKey())
		
	cQuery	:= ChangeQuery(cQuery)
	DbSelectArea("SU0")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SU0', .F., .T.)
	
#ELSE
	SU0->(MsSeek(cFilSU0))
#ENDIF

While !Eof() .AND. SU0->U0_FILIAL == cFilSU0
	
	If SU0->U0_REGNEG == SK2->K2_REGNEG
		lRet := .F.
		Exit
	EndIf
	
	DbSelectArea("SU0")
	DbSkip()
End

#IFDEF TOP
	DbSelectArea("SU0")
	DbCloseArea()
	ChkFile("SU0")
#ENDIF

RestArea(aArea)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Exclui a Regra de Negociacao e as Condicoes de Pagamento.    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet
	Begin Transaction
		//Exclui a Regra de Negociacao
		dbSelectArea("SK2")
		SK2->(dbSetOrder(1))
		RecLock( "SK2", .F. )
			SK2->(dbDelete())
		MsUnlock()
		
		//Exclui as Condicoes de Pagamento da Regra
		dbSelectArea("SV0")
		SV0->(dbSetOrder(1))
		SV0->( MsSeek( SK2->K2_FILIAL + SK2->K2_REGNEG) )
		While (!Eof()) .And. ( SK2->K2_FILIAL + SK2->K2_REGNEG == SV0->V0_FILIAL + SV0->V0_REGNEG )
			RecLock( "SV0", .F. )
				SV0->(dbDelete())
			MsUnlock()
			SV0->(dbSkip())
		End Do
	End Transaction	
Else
	Help( "  ", 1, "TMKNDELREL" )
	lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ Tk190TudoOk บ Autor ณ Danilo Dias     บ Data ณ  13/12/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Desc.    ณ Valida a inclusao ou alteracao da Regra de Negociacao.     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso      ณ TMKA190                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk190TudoOk()

Local lRet 	:= .T.
Local lItens 	:= .T.	//Informa se a grid possui algum item
Local nI		:= 0

If lRet .And. ( INCLUI .Or. ALTERA )
	//Verifica se existem itens na grid
	If ( Len(aCols) == 1 .And. Trim(aCols[1,1]) == "" )
		lItens := .F.
	Else
		lItens := .F.
		For nI := 1 To Len(aCols)
			If aCols[nI, Len(aHeader)+1] == .F.
				lItens := .T.
				Exit
			EndIf
		Next nI
	EndIf
	
	//Verifica se algum campo obrigatorio foi deixado sem preenchimento.
	lRet := Obrigatorio(aGets, aTela)
	
	//Se a opcao de liquidacao foi deixada como Sim, obriga a digitacao
	//de pelo menos uma condicao de pagamento.
	If lRet .AND. !lItens .AND. ( M->K2_LIQUIDA == '1' ) 
		Help( " ", 1, "Tk190TudoOk", , STR0007, 1 )	//"Informe uma condi็ใo de pagamento para a regra ou altere o campo 'Liquida็ใo' (K2_LIQUIDA) para 'Nใo'."
		lRet := .F.
	EndIf
	
	If lRet
		lRet := Tk190LinOk()	//Valida a linha atual
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ Tk190LinOk บ Autor ณ Danilo Dias      บ Data ณ  13/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Desc.    ณ Valida a inclusao de uma linha na grid de condicoes de     บฑฑ
ฑฑบ          ณ pagamento da regra (SV0).                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso      ณ TMKA190                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk190LinOk()

Local lRet 	:= .T.
Local nI		:= 0

//Verifica se a mesma condicao ja foi informada
For nI := 1 To Len(aCols)
	If ( aCols[nI, 1] == aCols[n, 1] ) .And. ( !aCols[nI, Len(aHeader) + 1] ) .And.;
	    ( !aCols[n, Len(aHeader) + 1] ) .And. ( nI != n )
		Help( " ", 1, "Tk190LinOk", , STR0008 + aCols[n,1] + " - " + aCols[n,2] + STR0009, 1)	//"Condi็ใo de Pagamento " | " estแ duplicada."
		lRet := .F.
		Exit
	EndIf
Next

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ Tk190CpoOk บ Autor ณ Danilo Dias      บ Data ณ  13/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Desc.    ณ Valida a digitacao do campo.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso      ณ TMKA190                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk190CpoOk()

Local lRet	:= .T.
Local nI		:= 0

//Verifica se a mesma condicao ja foi informada
For nI := 1 To Len(aCols)
	If ( aCols[nI, 1] == M->V0_CONDPG ) .And. ( !aCols[nI, Len(aHeader) + 1] ) .And.;
	    ( !aCols[n, Len(aHeader) + 1] ) .And. ( nI != n )
		Help( " ", 1, "Tk190LinOk", , STR0010, 1)	//"Condi็ใo de pagamento jแ foi informada."
		lRet := .F.
		Exit
	EndIf
Next	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ Tk190Cons  บ Autor ณ Danilo Dias      บ Data ณ  13/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Desc.    ณ Consulta as condicoes de pagamento da Regra de Negociacao  บฑฑ
ฑฑบ          ณ de acordo com o usuario.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Param    ณ cUsuario  - Codigo do usuario no sistema.                  บฑฑ
ฑฑบ          ณ lFilial   - Indica se deve retornar a chave com filial.    บฑฑ
ฑฑบ          ณ lPesq     - Indica se retorna resultado da busca (.T.) ou  บฑฑ
ฑฑบ          ณ             se retorna apenas a chave (.F.).               บฑฑ
ฑฑบ          ณ cCondicao - Procura uma Condicao de Pagamento especifica.  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Retorno  ณ xRet - Retorna a chave para busca da regra ou se existe    บฑฑ
ฑฑบ          ณ        a regra para o operador. (Dependendo de lPesq)      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso      ณ TMKA190                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk190Cons( cUsuario, lFilial, lPesq, cCondicao )

Local aArea		:= GetArea()
Local aAreaSU7	:= SU7->(GetArea())
Local aAreaSU0	:= SU0->(GetArea())
Local cChave 		:= ""	//Chave de busca
Local xRet		:= ""	//Retorno

Default lFilial 		:= .T.
Default lPesq			:= .F.
Default cCondicao 	:= ""

dbSelectArea("SK2")

dbSelectArea("SU7")		//Operadores
SU7->(dbSetOrder(4))	//U7_FILIAL+U7_CODUSU

dbSelectArea("SU0")		//Grupos de Atendimento
SU0->(dbSetOrder(1))	//U0_FILIAL+U0_GRPSUP

//Busca o cadastro do operador
If SU7->(dbSeek(xFilial("SU7") + cUsuario))
	cChave := SU7->U7_FILIAL + SU7->U7_POSTO
	
	//Busca o Grupo de Atendimento
	If SU0->(dbSeek(cChave))
		cChave := ""
		
		If lFilial
			cChave := xFilial("SK2")
		EndIf
		cChave := cChave + SU0->U0_REGNEG + cCondicao 
	Else
		cChave := ""
	EndIf
	
	//Retorna a chave de busca sem executar a consulta
	xRet := cChave
EndIf

//Retorna se a pesquisa foi bem sucedida
If lPesq
	xRet := SV0->(dbSeek(cChave))
	If !xRet 
		Help( " ", 1, "Tk190Cons", , STR0011, 1)	//"Condi็ใo de Pagamento informada nใo existe no Cadastro das Regras de Negocia็ใo definidas para o usuแrio."
	EndIf
EndIf

RestArea(aAreaSU0)
RestArea(aAreaSU7)
RestArea(aArea)
Return xRet