#Include "TmsA480.ch"
#Include "Protheus.ch"
#Include "FWMVCDEF.CH"

Static lTm480Tok := ExistBlock("TM480TOK")
Static lTm480But := ExistBlock("TM480BUT")
Static lTm480Del := ExistBlock("TM480DEL")
Static aMemos    := {{"DUO_CDOCTR", "DUO_OBSCTR"}}
Static aSetKey   := {}


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TmsA480  � Autor � Larson Zordan         � Data �12.07.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Perfil do cliente                                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador    � Data   � BOPS �  Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Mauro Paladini �04/09/13�      �Conversao da rotina para o padrao MVC  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TmsA480()

Local oBrowse   := Nil
Private aRotina := MenuDef()
Private aSetKey := {}

dbSelectArea("DUO")
dbSetOrder(1) //DUO_FILIAL+DUO_CODCLI+DUO_LOJCLI

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DUO")
oBrowse:SetDescription(STR0006) // "Perfil do Cliente"
oBrowse:Activate()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ModelDef � Autor � Mauro Paladini        � Data �23.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de dados                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oModel Objeto do Modelo                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ModelDef()

Local oModel   := Nil
Local lMile    := IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT") 

// Estrutura de campos do cabecalho
Local oStruDUO  := Nil

Local bPreValid := Nil
Local bPosValid := { |oMdl| PosVldMdl(oMdl) }
Local bComValid := Nil
Local bCancel   := Nil

// Validacoes da Grid
Local bLinePost	:= Nil // { |oMdl| PosVldLine(oMdl) }

If Empty(aSetKey)
	Aadd(aSetKey, { VK_F4, {|| TmsA480Whe()}})
	Aadd(aSetKey, { VK_F5, {|| TmsA480SepDoc('DUO_SEPDOC')}})
	Aadd(aSetKey, { VK_F6, {|| TmsA480SepDoc('DUO_DOCFAT')}})
EndIf


oStruDUO := FwFormStruct( 1, "DUO" )

oModel:= MpFormMOdel():New("TMSA480", /*bPreValid*/ , bPosValid , /*bComValid*/ ,/*bCancel*/ )
oModel:SetDescription(STR0006) // "Perfil do Cliente"

If !IsIncallStack("CFGA600") .And. !lMile
	FWMemoVirtual( oStruDUO, aMemos )
Endif

oModel:AddFields("MdFieldDUO",Nil,oStruDUO,/*prevalid*/,,/*bCarga*/)
oModel:GetModel("MdFieldDUO"):SetDescription(STR0006) // "Perfil do Cliente"
oModel:SetPrimaryKey({ "DUO_FILIAL","DUO_CODCLI","DUO_LOJCLI" })

If !lMile
	oModel:bActivate := { |oModel| TmsKeyOn(aSetKey) }
	oModel:SetDeActivate( { |oModel| TmsKeyOff(aSetKey) } )
Endif

Return ( oModel )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ViewDef  � Autor � Mauro Paladini        � Data �09.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe browse de acordo com a estrutura                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oView do objeto oView                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ViewDef()

Local oView     := Nil
Local oModel    := FwLoadModel("TMSA480")
Local oStruDUO  := FwFormStruct( 2, "DUO" )
Local aOpc      := {MODEL_OPERATION_VIEW,MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE,MODEL_OPERATION_DELETE}
Local nI        := 0
Local aButtons  := {	{ STR0007 , "WEB" 		, {|| TmsA480Whe()}},;					//"Separar Estados - <F4>"
						{ STR0009 , "BMPPOST" 	, {|| TmsA480SepDoc('DUO_SEPDOC')}},;	//"Tipos de Documentos - <F5>"
						{ STR0019 , "NOTE" 		, {|| TmsA480SepDoc('DUO_DOCFAT')}} }	//"Doc. Fatur. Difer. - <F6>"

Private aUsrButtons	:= {}


oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField('VwFieldDUO', oStruDUO  , 'MdFieldDUO')
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VwFieldDUO","TELA")

//-- Deleta botoes padrao
If	lTm480Del
	If ValType(aRetPE := ExecBlock("TM480DEL", .F., .F.,{aButtons})) == "A"
		aButtons := aClone(aRetPE)
	EndIf
EndIf

//�������������������������������������������������������Ŀ
//� Tratamento especial para o funcionamento dos botoes   �
//���������������������������������������������������������
For nI := 1 To Len(aOpc)
	//-- Adiciona os botoes padroes
	AEval( aButtons, { |x| oView:AddUserButton( x[1], x[2], x[3] ,NIL,NIL, {aOpc[nI]}) } )
	//-- Adiciona os botoes de usuario
	If	lTm480But
		If ValType(aUsrButtons := ExecBlock("TM480BUT", .F., .F., {aOpc[nI]})) == "A"
			AEval( aUsrButtons, { |x| oView:AddUserButton( x[3], x[1], x[2] ,NIL,NIL, {aOpc[nI]}) } )
		EndIf
	EndIf
Next nI

Return(oView)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Mauro Paladini        � Data �14.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � MenuDef com as rotinas do Browse                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina array com as rotina do MenuDef                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Private aRotina := {}

ADD OPTION aRotina TITLE STR0001 ACTION "PesqBrw"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.TMSA480" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSA480" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TMSA480" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSA480" OPERATION 5 ACCESS 0 //"Excluir"

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������

If ExistBlock("TM480MNU")
	ExecBlock("TM480MNU",.F.,.F.)
EndIf

Return ( aRotina )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA480Vld� Autor � Larson Zordan         � Data �09.07.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do Sistma                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TmsA480Vld()
Local aArea    := GetArea()
Local cCampo   := ReadVar()
Local lRet     := .T.
Local lAchou   := .F.
Local lTMSOPdg := SuperGetMV("MV_TMSOPDG",,"0") == "2"
Local cOperac  := "01"

If cCampo == "M->DUO_FOBDIR"
	If M->DUO_FOBDIR == "1" //1=Sim,2=Nao
		If DTI->(dbSeek(xFilial("DTI")+M->DUO_CODCLI+M->DUO_LOJCLI))
			lRet := .F.
			Help("",1,"TMSA48001") //"O FOB Dirigido n�o podera ser alterado para SIM, pois este cliente � um remetente da tabela de Consignatarios
		EndIf
	EndIf
ElseIf cCampo == "M->DUO_OPECOL" .Or. cCampo == "M->DUO_OPEENT"
	If lTMSOPdg
		DEJ->(dbSetOrder(1)) //DEJ_FILIAL+DEJ_CODOPE+DEJ_ITEM
		DEJ->(MsSeek(xFilial("DEJ")+cOperac))
		While DEJ->(!Eof() .And. DEJ_FILIAL+DEJ_CODOPE == xFilial("DEJ")+cOperac)
			If	cCampo == "M->DUO_OPECOL" .And. M->DUO_OPECOL == DEJ->DEJ_OPERAC .And. DEJ->DEJ_SERTMS == '1' .Or. ;
				cCampo == "M->DUO_OPEENT" .And. M->DUO_OPEENT == DEJ->DEJ_OPERAC .And. DEJ->DEJ_SERTMS == '3'
				lAchou := .T.
				Exit
			EndIf
			DEJ->(dbSkip())
		EndDo
	EndIf
	If !lAchou
		lRet := .F.
		Help('', 1, 'REGNOIS')
	EndIf
EndIf

RestArea( aArea )
Return( lRet )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA480CBx� Autor � Larson Zordan         � Data �09.07.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao com uso do PARAMBOX()                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function TmsA480Whe()
Static aEstados := {}
Local aEstados  := {}
Local aRet      := {}
Local aSX512	:= {}
Local nX5		:= 0
Local cUfs      := ""
Local lCkb      := .F.
Local lInv      := .F.
Local nX        := 0
Local nQt       := 0
Local lRet      := .T.

Local oModel    := FWModelActive()
Local oView     := FWViewActive()

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

If	Empty(aEstados)
	aSX512 	 := FwGetSX5("12",)
	For nX5 := 1 to Len(aSX512)
		lCkb := .F.
		For nX := 1 To Len(M->DUO_SEPEST) Step 3
			If AllTrim(M->DUO_SEPEST) == "*" .Or. SubStr(M->DUO_SEPEST,nX,2) == AllTrim(aSX512[nX5,3])
				lCkb := .T.
				Exit
			EndIf
		Next nX
		aAdd(aEstados, {4,"",lCkb,AllTrim(aSX512[nX5,3]) + " - " + aSX512[nX5,4],80,,.F.} )
	Next nX5		
EndIf

While .T.
	nQt  := 0
	aRet := {}
	cUFs := ""
	If ParamBox( aEstados, STR0007, @aRet, , {{ 5, { |oPanel| TmsA480Marc(aEstados,@aRet,@lInv),oPanel:Refresh() }, STR0008 }} , .T., , , , , .F.)	//"Separar Estados"###"Marca/Desmarca Todos"
		For nX := 1 To Len(aRet)
			If aRet[nX]
				cUFs += If(Empty(cUFs),"",";")+SubStr(aEstados[nX,4],1,2)
				nQt ++
			EndIf
		Next nX
		If nQt == Len(aRet)
			If oModel:LoadValue( "MdFieldDUO" , "DUO_SEPEST" , "*" + Space(Len( oModel:GetValue( "MdFieldDUO" , "DUO_SEPEST" ) ) - 1) )
				oView:SetModified( .T. )
			Endif
			Exit
		ElseIf Len(AllTrim(cUFs)) <= Len(M->DUO_SEPEST)
			If oModel:LoadValue( "MdFieldDUO" , "DUO_SEPEST" , cUFs + Space(Len( oModel:GetValue( "MdFieldDUO" , "DUO_SEPEST" ) ) - Len(cUFs)) )
				oView:SetModified( .T. )
			Endif
			Exit
		Else
			Help("",1,"TMSA48002") //"Quantidade de Estados n�o suportado pelo campo"
		EndIf
	Else
		Exit
	EndIf
EndDo

oView:Refresh()

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA480Mar� Autor � Larson Zordan         � Data �10.07.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Marca/Desmarca todos os CheckBox do PARAMBOX()             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function TmsA480Marc(aEstados,aRet,lInv)

Local nX := 0

For nX := 1 To Len(aEstados)
	&("MV_PAR"+StrZero(nx,2)) := If(lInv,.F.,.T.)
Next nX
lInv := !lInv

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA480SepDoc� Autor � Marcelo Iuspa      � Data �26.03.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao de separacao por Tipo de Documento               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TmsA480SepDoc( cCpoDest )

Local aItem      := TMSValField("DOCTMS",.F.,,.F.,.T.)
Local aDocs      := {}
Local aRet       := {}
Local aMem       := {}
Local lInv       := .F.
Local lAll       := .T.
Local cSepDoc    := ";" + StrTran(M->&(cCpoDest), " ", "")
Local oDlg
Local cTMSMFat   := GetMV("MV_TMSMFAT",,"") //-- Modo de Faturamento:1-Faturamento a partir do SE1;2=Faturamento a partir do DT6
Local cTitSTA    := Iif(cCpoDest == 'DUO_DOCFAT',SubStr(STR0019, 1, Iif(AT("-",STR0019)==0, Len(STR0019), AT("-",STR0019)-1) ),; //-- Titulo do Parambox Sem a Tecla de Atalho.
					SubStr(STR0009, 1, Iif(AT("-",STR0009)==0, Len(STR0009), AT("-",STR0009)-1) ) )
Local oModel     := FWModelActive()
Local oView      := FWViewActive()
Local cTmsERP    := SuperGetMV("MV_TMSERP",,'0') //-- Integracao com ERP

If cTmsERP == '1' .And. cCpoDest == 'DUO_DOCFAT' //-- ERP Datasul
	Help('',1,'TMSA48005') //-- Botao nao disponivel quando houver integracao com o financeiro Datasul (MV_TMSERP igual a 1)
ElseIf cCpoDest == 'DUO_DOCFAT' .And. cTMSMFat <> '2'
	Help('',1,'TMSA48003') //-- Botao somente disponivel quando o faturamento estiver configurado para ser realizado a partir dos documentos de transporte (MV_TMSMFAT igual a 2)
Else
	//-- Finaliza Teclas de Atalhos
	If !(cCpoDest $ "DYE_DOCCOB")
		TmsKeyOff(aSetKey)
	EndIf

	aEval(aItem, {|z,w| Aadd(aDocs, {4, "", "*" $ cSepDoc .Or. ";" + aItem[w,1] $ cSepDoc, aItem[w,1] + "-" + aItem[w,2], 80,,.F.}), Aadd(aMem, MemVarBlock("MV_PAR" + StrZero(w, 2)))})

	If ParamBox( aDocs, cTitSTA, @aRet, , {{ 5, { |oPanel| TmsA480DocMarc(aMem, @lInv),oPanel:Refresh() }, STR0008 }} , .T., , , , , .F.) //"Tipos de Documentos"###"Marca/Desmarca Todos" 
		M->&(cCpoDest) := ""
		aEval(aRet, {|z,w| If(z, M->&(cCpoDest) += If(Len(M->&(cCpoDest)) > 0, ";","") + aItem[w,1],lAll := .F.)})
		M->&(cCpoDest) := Pad(If(lAll, "*", M->&(cCpoDest)),Iif(cCpoDest $ "DYE_DOCCOB"	, Len(DYE->&(cCpoDest)), Len(DUO->&(cCpoDest))))
		If oModel <> Nil .And. RTrim(oModel:cID) == "TMSA480"
			If oModel:LoadValue( "MdFieldDUO" , cCpoDest , M->&(cCpoDest) )
				oView:SetModified( .T. )
			Endif
		Endif
	Endif

	//-- Inicializa Teclas de Atalhos
	If !(cCpoDest $ "DYE_DOCCOB")
		TmsKeyOn(aSetKey)
	EndIf
EndIf

If	oView <> Nil
	oView:Refresh()
Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA480DocMarc� Autor � Marcelo Iuspa     � Data �10.07.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Marca/Desmarca todos os CheckBox do PARAMBOX() Sep Doc     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function TmsA480DocMarc(aMem, lInv)

lInv := !lInv
aEval(aMem, {|z| Eval(z, lInv)})

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PosVldMdl � Autor � Mauro Paladini        � Data �03/09/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de validacao da model (compatibilizacao)             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPL1 - .T./.F. Logico                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�<oModel>                                                    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function PosVldMdl(oMdl)

Local lRet := .T.

If oMdl <> Nil

	If oMdl:GetOperation() == MODEL_OPERATION_INSERT .Or. oMdl:GetOperation() == MODEL_OPERATION_UPDATE     	
		lRet := TMSA480TOk(oMdl:GetOperation())
	Endif

Endif

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA480TOk� Autor � Robson Alves          � Data �22.01.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se os campos obrigatorios estao preenchidos.      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSA480TOk(nOpcx)

Local lRet := .T.
Local oMdl := FWModelActive() 

If M->DUO_AGRNFC <> '2' .And. M->DUO_NFCTR == 0
	lRet := .F.
	oMdl:SetErrorMessage (,,,,,STR0021)
EndIf

If lTm480Tok
	lRet := ExecBlock("TM480TOK",.F.,.F.,{nOpcx} )
	If ValType(lRet) <> 'L'
		lRet := .T.
	EndIf
EndIf

Return( lRet )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA480Whn� Autor � Alex Egydio           � Data �02.06.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes antes de editar o campo                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TmsA480Whn()

Local aAreaAnt := GetArea()
Local cCampo   := ReadVar()
Local lRet     := .T.

//-- Desabilitar a digitacao do campo tipo de fatura, quando a base para fatura for manual
If cCampo $ 'M->DUO_TIPFAT'
	lRet := M->DUO_BASFAT != StrZero(1,Len(DUO->DUO_BASFAT))
EndIf

RestArea(aAreaAnt)

Return lRet
