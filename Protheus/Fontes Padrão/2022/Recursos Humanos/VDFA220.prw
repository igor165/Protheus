#Include "VDFA220.Ch"
#Include "Totvs.Ch"
#Include "FWMVCDEF.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFA220  ³ Autor ³ Wagner Mobile Costa   ³ Data ³  15.05.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Manutenção do histórico de designações                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFA220()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³      ³                                          ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function VDFA220()

Private cCadastro := STR0001	// 'Histórico de Designações'
Private aRotina   := MenuDef()

M->RA_FILIAL	:= cFilAnt	//-- Variavel utilizada 

mBrowse(6,1,22,75,"RIL")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef  ³ Autor ³ Wagner Mobile Costa   ³ Data ³  16.05.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Menu Funcional                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw" 			OPERATION 1 						ACCESS 0	// 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.VDFA220" 	OPERATION MODEL_OPERATION_VIEW 		ACCESS 0	// 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.VDFA220" 	OPERATION MODEL_OPERATION_INSERT 	ACCESS 0	// 'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.VDFA220" 	OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0	// 'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.VDFA220" 	OPERATION MODEL_OPERATION_DELETE 	ACCESS 0	// 'Excluir'

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ModelDef ³ Autor ³ Wagner Mobile Costa   ³ Data ³  16.05.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Definição do Modelo de Dados                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ModelDef()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function ModelDef()

Local oStruRIL := FwFormStruct(1, "RIL")
Local oModel   := MPFormModel():New("VDFA220_MVC",, { |oModel| VldPrimary(oModel) } )

oModel:AddFields("RIL", /* cOwner */, oStruRIL)
oModel:SetPrimaryKey( { "RIL_FILIAL", "RIL_MAT", "RIL_DESIGN", "RIL_INICIO" } )
oModel:SetDescription(STR0007)	// 'Histórico de Designações'
oModel:GetModel("RIL"):SetDescription(STR0007)	// 'Histórico de Designações'
M->RA_FILIAL := cFilAnt
If oModel:nOperation == MODEL_OPERATION_UPDATE
	M->RA_FILIAL := RIL->RIL_FILIAL 
EndIf 

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ViewDef  ³ Autor ³ Wagner Mobile Costa   ³ Data ³  16.05.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Definição da visualização dos dados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ViewDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function ViewDef()

Local oModel   := FWLoadModel("VDFA220")
Local oView    := FWFormView():New()
Local oStruRIL := FwFormStruct(2, "RIL")

oView:SetModel( oModel )
oView:AddField( "VIEW_RIL", oStruRIL, "RIL" ) 
oView:CreateHorizontalBox( "TELA" , 100 ) 
oView:SetOwnerView( "VIEW_RIL", "TELA" ) 

M->RA_FILIAL := cFilAnt
If oModel:nOperation == MODEL_OPERATION_UPDATE
	M->RA_FILIAL := RIL->RIL_FILIAL 
EndIf 

Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VldPrimary  ³ Autor ³ Wagner Mobile Costa ³ Data ³  16.05.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Função para validação da chave primária                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VldPrimary()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function VldPrimary(oModel)

Local lRet := .T.

If oModel:nOperation == MODEL_OPERATION_INSERT 
	lRet := ! ExistCpo("RIL", oModel:GetValue("RIL", "RIL_MAT") + oModel:GetValue("RIL", "RIL_DESIGN") + Dtos(oModel:GetValue("RIL", "RIL_INICIO")))
EndIf	 

If ! lRet
	Help(,, 'KEYRIL',, STR0008, 1, 0)	// 'Matricula, Designação e Data de Inicio já existe para este servidor !'
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VLRILRI6 ³ Autor ³ Wagner Mobile Costa   ³ Data ³  15.05.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Validação dos campos RIL_TIPDOC, RIL_ANO e RIL_NUMDOC       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VLRILRI6()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function VlRILRI6()

Local cWhere := "%AND RI6_FILMAT = '" + cFilAnt + "' AND RI6_MAT = '" + M->RIL_MAT + "'", lRet := .T., cMsg := ""

If ReadVar() = "M->RIL_ANO"
	cWhere += " AND RI6_TIPDOC = '" + M->RIL_TIPDOC + "'"
	cWhere += " AND RI6_ANO = '" + &(ReadVar()) + "'"
	cMsg := STR0009 + M->RIL_MAT + ']'	// 'Não existe este tipo de documento/ano relacionado para esta matricula ['
ElseIf ReadVar() = "M->RIL_NUMDOC"
	cWhere += " AND RI6_TIPDOC = '" + M->RIL_TIPDOC + "'"
	cWhere += " AND RI6_ANO = '" + M->RIL_ANO + "'"
	cWhere += " AND RI6_NUMDOC = '" + &(ReadVar()) + "'"
	cMsg := STR0010 + M->RIL_MAT + ']'	// 'Não existe este tipo de documento/ano/número relacionado para esta para matricula ['
EndIf 

cWhere += "%"
	
BeginSql Alias "QRY"
	SELECT RI6_CODITE
      FROM %table:RI6%
     WHERE %notDel% %Exp:cWhere%
EndSql

If Empty(QRY->RI6_CODITE)
	lRet := MsgYesNo(STR0011 + cMsg + STR0012)	// 'Atenção. ' ## '. Continua ?' 
EndIf

QRY->(DbCloseArea())	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QRY116BR ³ Autor ³ Wagner Mobile Costa   ³ Data ³  16.05.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Montagem de consulta padrao da chave S116BR da tabela RCC   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QRY116BR()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function QRY116F3()

Local lRet := .F., nRetorno := 0

cQuery := "SELECT SUBSTRING(RCC_CONTEU, 1, 3) AS RCC_CODIGO, SUBSTRING(RCC_CONTEU, 4, 100) AS RCC_CONTEU, RCC.R_E_C_N_O_ AS RCC_RECNO "
cQuery +=   "FROM " + RetSqlName("RCC") + " RCC "
cQuery +=  "WHERE D_E_L_E_T_ = ' ' AND RCC_FILIAL = '" + xFilial("RCC") + "' AND RCC_CODIGO = 'S116' "
cQuery +=    "AND CASE WHEN RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCC_FIL END = '" + cFilAnt + "' AND RCC.R_E_C_N_O_ IN (" + QryUtRCC({3}) + ")"

If JurF3Qry(cQuery, "RCCQRY", "RCC_RECNO", @nRetorno,, { "RCC_CODIGO", "RCC_CONTEU" })
	RCC->(DbGoto(nRetorno))
	lRet := .T.
EndIf 

Return lRet

Static Function QryUtRCC(aTam, cAnoMes)
                                                                                                        
Local cQuery := "SELECT MAX(RCCR.R_E_C_N_O_) FROM " + RetSqlName("RCC") + " RCCR " +;
	               "JOIN (SELECT RCC_CODIGO AS COLUNA1, CASE WHEN RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCC_FIL END AS COLUNA2, ", nTam := 1, nSoma := 0

Default cAnoMes := Str(Year(dDataBase), 4) + StrZero(Month(dDataBase), 2)

For nTam := 1 To Len(aTam)
	cQuery += "SUBSTRING(RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ") AS RCC_CONTE" + AllTrim(Str(nTam)) + ", "
	nSoma += aTam[nTam]
Next	

cQuery +=      "MAX(CASE WHEN RCC_CHAVE = ' ' THEN '" + cAnoMes + "' ELSE RCC_CHAVE END) AS RCC_CHAVE " +;
          "FROM " + RetSqlName("RCC") + " " +;
         "WHERE D_E_L_E_T_ = ' ' AND RCC_FILIAL = '" + xFilial("RCC") + "' " +;
         "GROUP BY RCC_CODIGO, CASE WHEN RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCC_FIL END" 

nSoma := 0
For nTam := 1 To Len(aTam)
	cQuery += ", SUBSTRING(RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ")"
	nSoma += aTam[nTam]
Next	

cQuery +=      ") RCCM ON RCCM.COLUNA1 = RCCR.RCC_CODIGO " +;
           "AND RCCM.COLUNA2 = CASE WHEN RCCR.RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCCR.RCC_FIL END " +;
           "AND RCCM.RCC_CHAVE = CASE WHEN RCCR.RCC_CHAVE = ' ' THEN '" + cAnoMes + "' ELSE RCCR.RCC_CHAVE END "

nSoma := 0
For nTam := 1 To Len(aTam)
	cQuery += " AND RCCM.RCC_CONTE" + AllTrim(Str(nTam)) + " = SUBSTRING(RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ")"
	nSoma += aTam[nTam]
Next
           
cQuery += " WHERE RCCR.D_E_L_E_T_ = ' ' AND RCCR.RCC_FILIAL = '" + xFilial("RCC") + "' " +;
             "AND RCCR.RCC_CODIGO = RCC.RCC_CODIGO AND CASE WHEN RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCC_FIL END = " +;
                                                      "CASE WHEN RCC.RCC_FIL = ' ' THEN '" + cFilAnt + "' ELSE RCC.RCC_FIL END " +;
             "AND CASE WHEN RCCR.RCC_CHAVE = ' ' THEN '" + cAnoMes + "' ELSE RCCR.RCC_CHAVE END >= '" + cAnoMes + "' "
nSoma := 0
For nTam := 1 To Len(aTam)
	cQuery += " AND SUBSTRING(RCCR.RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ") = " +;
	               "SUBSTRING(RCC.RCC_CONTEU, 1 + " + AllTrim(Str(nSoma)) + ", " + AllTrim(Str(aTam[nTam])) + ")  
	nSoma += aTam[nTam]
Next

Return cQuery