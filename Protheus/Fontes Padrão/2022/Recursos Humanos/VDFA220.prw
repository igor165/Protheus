#Include "VDFA220.Ch"
#Include "Totvs.Ch"
#Include "FWMVCDEF.Ch"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � VDFA220  � Autor � Wagner Mobile Costa   � Data �  15.05.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Manuten��o do hist�rico de designa��es                      ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFA220()                                                    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���            �          �      �                                          ���
�������������������������������������������������������������������������������*/
Function VDFA220()

Private cCadastro := STR0001	// 'Hist�rico de Designa��es'
Private aRotina   := MenuDef()

M->RA_FILIAL	:= cFilAnt	//-- Variavel utilizada 

mBrowse(6,1,22,75,"RIL")

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Wagner Mobile Costa   � Data �  16.05.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Menu Funcional                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw" 			OPERATION 1 						ACCESS 0	// 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.VDFA220" 	OPERATION MODEL_OPERATION_VIEW 		ACCESS 0	// 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.VDFA220" 	OPERATION MODEL_OPERATION_INSERT 	ACCESS 0	// 'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.VDFA220" 	OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0	// 'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.VDFA220" 	OPERATION MODEL_OPERATION_DELETE 	ACCESS 0	// 'Excluir'

Return aRotina

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ModelDef � Autor � Wagner Mobile Costa   � Data �  16.05.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Defini��o do Modelo de Dados                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                   ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������*/
Static Function ModelDef()

Local oStruRIL := FwFormStruct(1, "RIL")
Local oModel   := MPFormModel():New("VDFA220_MVC",, { |oModel| VldPrimary(oModel) } )

oModel:AddFields("RIL", /* cOwner */, oStruRIL)
oModel:SetPrimaryKey( { "RIL_FILIAL", "RIL_MAT", "RIL_DESIGN", "RIL_INICIO" } )
oModel:SetDescription(STR0007)	// 'Hist�rico de Designa��es'
oModel:GetModel("RIL"):SetDescription(STR0007)	// 'Hist�rico de Designa��es'
M->RA_FILIAL := cFilAnt
If oModel:nOperation == MODEL_OPERATION_UPDATE
	M->RA_FILIAL := RIL->RIL_FILIAL 
EndIf 

Return oModel

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ViewDef  � Autor � Wagner Mobile Costa   � Data �  16.05.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Defini��o da visualiza��o dos dados                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������*/
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
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � VldPrimary  � Autor � Wagner Mobile Costa � Data �  16.05.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Fun��o para valida��o da chave prim�ria                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VldPrimary()                                                  ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������*/
Static Function VldPrimary(oModel)

Local lRet := .T.

If oModel:nOperation == MODEL_OPERATION_INSERT 
	lRet := ! ExistCpo("RIL", oModel:GetValue("RIL", "RIL_MAT") + oModel:GetValue("RIL", "RIL_DESIGN") + Dtos(oModel:GetValue("RIL", "RIL_INICIO")))
EndIf	 

If ! lRet
	Help(,, 'KEYRIL',, STR0008, 1, 0)	// 'Matricula, Designa��o e Data de Inicio j� existe para este servidor !'
EndIf

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � VLRILRI6 � Autor � Wagner Mobile Costa   � Data �  15.05.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Valida��o dos campos RIL_TIPDOC, RIL_ANO e RIL_NUMDOC       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VLRILRI6()                                                   ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������*/
Function VlRILRI6()

Local cWhere := "%AND RI6_FILMAT = '" + cFilAnt + "' AND RI6_MAT = '" + M->RIL_MAT + "'", lRet := .T., cMsg := ""

If ReadVar() = "M->RIL_ANO"
	cWhere += " AND RI6_TIPDOC = '" + M->RIL_TIPDOC + "'"
	cWhere += " AND RI6_ANO = '" + &(ReadVar()) + "'"
	cMsg := STR0009 + M->RIL_MAT + ']'	// 'N�o existe este tipo de documento/ano relacionado para esta matricula ['
ElseIf ReadVar() = "M->RIL_NUMDOC"
	cWhere += " AND RI6_TIPDOC = '" + M->RIL_TIPDOC + "'"
	cWhere += " AND RI6_ANO = '" + M->RIL_ANO + "'"
	cWhere += " AND RI6_NUMDOC = '" + &(ReadVar()) + "'"
	cMsg := STR0010 + M->RIL_MAT + ']'	// 'N�o existe este tipo de documento/ano/n�mero relacionado para esta para matricula ['
EndIf 

cWhere += "%"
	
BeginSql Alias "QRY"
	SELECT RI6_CODITE
      FROM %table:RI6%
     WHERE %notDel% %Exp:cWhere%
EndSql

If Empty(QRY->RI6_CODITE)
	lRet := MsgYesNo(STR0011 + cMsg + STR0012)	// 'Aten��o. ' ## '. Continua ?' 
EndIf

QRY->(DbCloseArea())	

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � QRY116BR � Autor � Wagner Mobile Costa   � Data �  16.05.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �  Montagem de consulta padrao da chave S116BR da tabela RCC   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � QRY116BR()                                                   ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������*/
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