#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICOE400.CH"
#INCLUDE "AVERAGE.CH"

/*
Programa   : EICOE400
Objetivo   : Criar o cadastro de operadaor estrangeiro 
Autor      : Maurício Frison 
Data/Hora  : 29/05/2020 11:28:07 
*/ 
Function EICOE400(aCapAuto,nOpcAuto)
Local oBrowse
Local aCores 	:= {}
Local nX		:= 1

Private INCLUI     := .F. //Variável INCLUI utilizada no dicionário de dados da EKJ para nao permitir alteração de alguns campos  
Private lOE400Auto := ValType(aCapAuto) <> "U" .And. ValType(nOpcAuto) <> "U"

aCores :={{"EKJ_STATUS == '1' "	,"ENABLE"      ,STR0027 },;  //"Registrado"
         { "EKJ_STATUS == '2' .OR. EMPTY(EKJ_STATUS) "	,"BR_AMARELO"  ,STR0028 },; //"Pendente Registro"
         { "EKJ_STATUS == '3' "	,"BR_VERMELHO" ,STR0029 },; //"Pendente Retificação"
         { "EKJ_STATUS == '4' "	,"BR_PRETO"    ,STR0030 }}	 //"Falha de Integração"

   if  !lOE400Auto
      oBrowse := FWMBrowse():New() //Instanciando a Classe
      For nX := 1 To Len( aCores )                                 //Adiciona a legenda 	    
			oBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
		Next nX
      oBrowse:SetAlias("EKJ") //Informando o Alias
      oBrowse:SetMenuDef("EICOE400") //Nome do fonte do MenuDef
      oBrowse:SetDescription(STR0006)//Operador Estrangeiro
      oBrowse:Activate()
   Else
      FWMVCRotAuto(ModelDef(), "EKJ", nOpcAuto,{{"EICOE400_EKJ",aCapAuto}})
   EndIf

Return 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Maurício Frison 
Data/Hora  : 29/05/2020 11:28:07 
*/ 
Static Function MenuDef()
Local aRotina := {}

   aAdd( aRotina, { STR0001	, "AxPesqui"			, 0, 1, 0, NIL } )	//'Pesquisar'
   aAdd( aRotina, { STR0002	, 'VIEWDEF.EICOE400'	, 0, 2, 0, NIL } )	//'Visualizar'
   aAdd( aRotina, { STR0003   , 'VIEWDEF.EICOE400'	, 0, 3, 0, NIL } )	//'Incluir'
   aAdd( aRotina, { STR0004   , 'VIEWDEF.EICOE400'	, 0, 4, 0, NIL } )	//'Alterar'
   aAdd( aRotina, { STR0005   , 'VIEWDEF.EICOE400'	, 0, 5, 0, NIL } )	//'Excluir'
   aAdd( aRotina, { STR0026   , 'OE400Integrar()'  , 0, 6, 0, NIL } )	//'Integrar'
   aAdd( aRotina, { STR0038   , 'OE400RecVers()'   , 0, 7, 0, NIL } )	//'Recuperar Versão'
   aAdd( aRotina, { STR0031   , 'COE400Legen'		, 0, 1, 0, NIL } )	//'Legenda'

Return aRotina

/*
Programa   : modelef()
Objetivo   : model da rotina de cadastro de operador estrangeiro
Retorno    : objeto model
Autor      : Maurício Frison
Data/Hora  : Jun/2020
Obs.       :
*/
Static Function ModelDef()
Local oStruEKJ       := FWFormStruct( 1, "EKJ") //Monta a estrutura da tabela EKJ
Local bPosValidacao  := {|oModel| OE400POSVL(oModel)}
Local oModel

   /*Criação do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
   módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
   oModel := MPFormModel():New( 'EICOE400', /*bPreValidacao*/, bPosValidacao, /*bCommit*/, /*bCancel*/ )

   //Modelo para criação da antiga Enchoice com a estrutura da tabela SJO
   oModel:AddFields( 'EICOE400_EKJ',/*nOwner*/,oStruEKJ, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

   //Adiciona a descrição do Modelo de Dados
   oModel:SetDescription(STR0006)//Operador Estrangeiro

   //Utiliza a chave primaria
   oModel:SetPrimaryKey( { "EKJ_FILIAL","EKJ_CNPJ_R", "EKJ_FORN", "EKJ_FOLOJA"} )  

Return oModel

/*
Programa   : Viewdef()
Objetivo   : View da rotina de cadastro de operador estrangeiro
Retorno    : objeto view
Autor      : Maurício Frison
Data/Hora  : Jun/2020
Obs.       :
*/
Static Function ViewDef()
Local oModel   := FWLoadModel("EICOE400")
Local oStruEKJ := FWFormStruct(2,"EKJ")
Local oView
 
   // Cria o objeto de View
   oView := FWFormView():New()
                                                                        
   // Define qual o Modelo de dados a ser utilizado
   oView:SetModel( oModel ) 

   oStruEKJ:SetProperty('EKJ_VERSAO' , MVC_VIEW_ORDEM ,'16')
   oStruEKJ:SetProperty('EKJ_VERMAN' , MVC_VIEW_ORDEM ,'17')
   oStruEKJ:SetProperty('EKJ_DATA' , MVC_VIEW_ORDEM ,'18')
   oStruEKJ:SetProperty('EKJ_HORA' , MVC_VIEW_ORDEM ,'19')
   oStruEKJ:SetProperty('EKJ_USER' , MVC_VIEW_ORDEM ,'20')

   //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
   oView:AddField('EICOE400_EKJ', oStruEKJ)

   //Relaciona a quebra com os objetos
   oView:SetOwnerView( 'EICOE400_EKJ') 

   //Habilita ButtonsBar
   oView:EnableControlBar(.T.)

Return oView 

/*
Programa   : OE400Val(cCampo)
Objetivo   : Funcao de validação dos campos
Retorno    : Lógico
Autor      : Maurício Frison
Data/Hora  : Jun/2020
Obs.       :
*/
FUNCTION OE400Val(cCampo)
Local lRet := .T.
Local oModel      := FWModelActive()
Local oModelEKJ   := oModel:GetModel("EICOE400_EKJ")

   Do Case 
      Case cCampo == "EKJ_IMPORT"
         If Empty(Posicione("SYT",1,xFilial("SYT")+oModelEKJ:GetValue("EKJ_IMPORT"),"YT_COD_IMP"))
            lRet := .F.
            easyHelp(STR0008) //Código do importador não encontrado
         ElseIf SYT->YT_IMP_CON <> "1"
            lRet := .F.
            easyHelp(STR0009) //"Código informado não é de importador"
         EndIf
      Case cCampo == "EKJ_TIN"
         If !Empty(Posicione("EKJ",2,xFilial("EKJ")+oModelEKJ:GetValue("EKJ_TIN"),"EKJ_TIN"))
            lRet := .F.
           // easyHelp(STRTRAN(STR0007,####,":"+M->EKJ_TIN)) // Campo TIN:#### já existente
           easyHelp(STR0007) // Campo TIN já existente
         EndIf
      Case (cCampo == "EKJ_FORN" .OR. cCampo == "EKJ_FOLOJA") .And. !empty(oModelEKJ:GetValue("EKJ_FORN")) .And. !empty(oModelEKJ:GetValue("EKJ_FOLOJA"))
         If empty(Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_COD"))
            lRet := .F.
            easyHelp(STR0010) //Fornecedor e Loja não encontrados
         EndIf
         If !empty(Posicione("EKJ",1,xFilial("EKJ") + oModelEKJ:GetValue("EKJ_CNPJ_R") + oModelEKJ:GetValue("EKJ_FORN") + oModelEKJ:GetValue("EKJ_FOLOJA"),"EKJ_CNPJ_R"))
            lRet := .F.
            easyHelp(STR0035) //Importador, Fornecedor e Loja já existentes
         EndIf
      Case cCampo == "EKJ_VERMAN"
         If !Empty(oModelEKJ:GetValue("EKJ_VERMAN")) .and. !Empty(oModelEKJ:GetValue("EKJ_VERSAO"))
            lRet := (oModelEKJ:GetValue("EKJ_VERMAN") == oModelEKJ:GetValue("EKJ_VERSAO")) .Or. MsgYesNo(STR0043) // Deseja substituir a versão atual pela informação digitada?
            If !lRet
               easyHelp(STR0042) // Limpe o campo para prosseguir.
            EndIf
         EndIf

   EndCase

Return lRet

/*
Programa   : OE400Gatil(cCampo)
Objetivo   : Funcao de gatilho dos campos
Retorno    : cReturn
Autor      : Maurício Frison
Data/Hora  : Jun/2020
Obs.       :
*/
FUNCTION OE400Gatil(cCampo)
Local cReturn := ''
Local oModel      := FWModelActive()
Local oModelEKJ   := oModel:GetModel("EICOE400_EKJ")
Local cTin :=''

   Do Case
      Case cCampo=="EKJ_IMPORT" 
           cReturn := Posicione("SYT",1,xFilial("SYT")+oModelEKJ:GetValue("EKJ_IMPORT"),"YT_NOME_RE")
      Case cCampo=="EKJ_CNPJ_R"
           cReturn := Posicione("SYT",1,xFilial("SYT")+oModelEKJ:GetValue("EKJ_IMPORT"),"YT_CGC")
           cReturn := Substr(cReturn,1,8)
      Case cCampo=="EKJ_NOME" 
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_NOME")
      Case (cCampo=="EKJ_TIN")
            Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_MUN")
            cTin := Posicione("EKJ",2,xFilial("EKJ") + SA2->A2_FILIAL + SA2->A2_COD + SA2->A2_LOJA,"EKJ_TIN")
            cReturn :=  if(Empty(cTin),RTRIM(SA2->A2_FILIAL) + RTRIM(SA2->A2_COD) + RTRIM(SA2->A2_LOJA),cTin) 
      Case (cCampo=="EKJ_CIDA")
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_MUN")
           cReturn := SubStr(cReturn,1,35)
      Case (cCampo=="EKJ_LOGR")
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_END")
      Case (cCampo=="EKJ_POSTAL")
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_POSEX")
           cReturn := SubStr(cReturn,1,9)
      Case (cCampo=="EKJ_PAIS")
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_PAISSUB")
           cReturn := Substr(cReturn,1,2)
      Case (cCampo=="EKJ_SUBP")
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_PAISSUB")
      Case (cCampo=="EKJ_VERSAO")
           cReturn := oModelEKJ:GetValue("EKJ_VERSAO")
           If !Empty(oModelEKJ:GetValue("EKJ_VERMAN"))
               cReturn := oModelEKJ:GetValue("EKJ_VERMAN")
           EndIf
   EndCase

return cReturn

/*
Programa   : OE400POSVL
Objetivo   : Funcao de Pos Validacao
Retorno    : Logico
Autor      : Maurício Frison
Data/Hora  : Jun/2020
Obs.       :
*/
Static Function OE400POSVL(oMdl)
Local oModel      := FWModelActive()
Local oModelEKJ   := oModel:GetModel("EICOE400_EKJ")
Local lRet        := .T.

   //Inclusão
   If oMdl:GetOperation() == 3
      If EKJ->( dbsetorder(1),dbseek(xFilial("EKJ")+oModelEKJ:GetValue("EKJ_CNPJ_R")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA")))
         lRet := .F.
         easyHelp(STR0012) // Inclusão não permitida, chave do registro duplicada
      EndIf
   EndIf

   //Alteração
   If oMdl:GetOperation() == 4
      If oModelEKJ:getvalue("EKJ_STATUS") == "1" .and. VerifAlt(oModelEKJ)
         oModelEKJ:setvalue("EKJ_STATUS", "3")
      EndIf
   EndIf

   //Exclusão
   If oMdl:GetOperation() == 5
      IF !Empty(oModelEKJ:GetValue("EKJ_DATA")) 
         lRet := .F.
         easyHelp(STR0011) // Registro com data de integração não pode ser excluído
      EndIf
   EndIf

Return lRet

/*
Programa   : VerifAlt
Objetivo   : Função para verificar se houve alteração nos campos e consequentemente alterar o status de retificação
Retorno    : Logico (.T. caso houve alteração e caso contrário, .F.)
Autor      : Nícolas Castellani Brisque
Data/Hora  : Ago/2022
Obs.       :
*/
Static Function VerifAlt(oModelEKJ)
   Local lRet    := .F.
   Local aCampos := {"EKJ_TIN", "EKJ_NOME", "EKJ_LOGR", "EKJ_CIDA", "EKJ_SUBP", "EKJ_PAIS", "EKJ_POSTAL"}
   Local i

   Begin Sequence
      For i := 1 to Len(aCampos)
         If oModelEKJ:getvalue(aCampos[i]) != EKJ->&(aCampos[i])
            lRet := .T.
            Break
         EndIf
      Next
   End Sequence

Return lRet

/*
Programa   : OE400RecVers
Objetivo   : Função para recuperar a versão do Operador Estrangeiro diretamente do Portal Único
Parâmetros : lIntegOp - Quando .T. Indica que já integrou o operador estrangeiro, então muda alguns constroles internos
                        Quando .F. Indica que não passou pela rotina de intgrar o operador estrangeiro
Retorno    : 
Autor      : Nícolas Castellani Brisque
Data/Hora  : Ago/2022
Obs.       :
*/
Function OE400RecVers(cUrlInteg, lIntegOp) 
   Local cURLAuth
   Local cUrlGetVers
   Local oEasyJS     := nil
   Local cAuth       := "/portal/api/autenticar"
   Local cErros      := ''
   Local cRet        := ""
   Local aRet        := {.T.,.T.} //[1] erro de conexão, [2] erro da camada de negócio  
   Local aResult     := {}
   Local lRet        := .T.
   Local lIntegrou   := .T.
   Default cUrlInteg := AVgetUrl()
   Default lIntegOp := .F.

   If !AvFlags("DUIMP_12.1.2310-22.4")
      If !lIntegOp
         EasyHelp(STR0045, STR0033, STR0046) // Esta ação está indisponível para o release atual. / "A ação estará disponível a partir do release 12.1.2310. / Aviso
      EndIf
   Else
      cURLAuth    := cUrlInteg + cAuth
      cUrlGetVers := cUrlInteg + '/catp/api/ext/operador-estrangeiro?cpfCnpjRaiz=' + EKJ->EKJ_CNPJ_R + '&codigo=' + rtrim(EKJ->EKJ_TIN)

      oEasyJS := EasyJS():New()
      oEasyJS:cUrl := cUrlAuth
      oEasyJS:setTimeOut(30)

      Begin Sequence   
         lRet := oEasyJS:Activate(.T.) //Ativa a tela que solicita o certificado
         If lRet
            cRet := execEndPoint(oEasyJs, cUrlAuth, cUrlGetVers, '', 'GET', @aRet,,, .F., @cErros)
            If Empty(cRet)
               cErros := If(lIntegOp,STR0047,STR0044) //"O registro do operador estrangeiro no portal único ocorreu com sucesso, mas houve falha na recuperação da versão","Houve uma falha na recuperação da versão do operador estrangeiro do Portal Único."               
            Else
               aResult := getRetorno(cRet)
            EndIf
         EndIf
      End Sequence

      If !Empty(cErros)
            lIntegrou := .F.
            EECView(STR0039 + cErros + CRLF + STR0040, STR0033) // Ocorreu o seguinte problema: / Solução: Conferir sua conexão de internet ou verificar os parâmetros MV_EIC0073 e MV_EIC0072. / Aviso
      Else
         recLock("EKJ",.F.)
         EKJ->EKJ_VERSAO := aResult[1]
         EKJ->(msUnlock())
         If !lIntegOp
            MsgInfo(STR0041, STR0033) // "Recuperado a versão com sucesso!" / "Aviso"
         EndIf
      EndIf
   EndIf

Return lIntegrou

Static Function execEndPoint(oEasyJS, cUrlAuth, cUrlExec, cDados, cMetodo, aRet, oLogView, cAtuReg, lBody, cErros)
   Local cRet    := ''
   Local cScript := AVAuth(cUrlAuth, cUrlExec, cDados, cMetodo, lBody)
   Default lBody := .T.

   oEasyJS:runJSSync(cScript, {|x| cRet := x }, {|x| cErros := x })
   If !Empty(cErros)
      aRet[1] := .F.
      Break
   EndIf

Return cRet
/*
Função:    getRetorno
Objetivo:  tratar o json retornado pelo portal e obter o código do Operador Estrangeiro e a Versão
Retorno:   aResult contendo o código do Operador Estrangeiro na primeira posição e a versão na segunda posição
Autor:     Maurício Frison
Data:      Maio/2022
*/
Static Function getRetorno(cMsg)
   Local cRet
   Local oJson
   Local aJson   := {}
   Local aResult := {}

   If !empty(cMsg)
      cRet     := '{"items":['+cMsg+']}'
      oJson    := JsonObject():New()
      cRetJson := oJson:FromJson(cRet)
      If valtype(cRetJson) == "U" .And. valType(oJson:GetJsonObject("items")) == "A"
         aJson := oJson:GetJsonObject("items")
         If len(aJson) > 0 .And. len(aJson[1]) > 0
            cTin    := aJson[1][1]:GetJsonText("codigo")
            cVersao := aJson[1][1]:GetJsonText("versao")
            aadd(aResult,cTin)
            aadd(aResult,cVersao) 
         EndIf
      EndIf
   EndIf
   FreeObj(oJson)
Return aResult

/*/{Protheus.doc} OE400Integrar
   Função para realizar a integração do operador estrangeiro com o siscomex
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   @param aOperadores - array com o recno do operador a ser integrado, se vazio registra o posicionado no browse
   @return Nil
   /*/
Function OE400Integrar(aOperadores,lIntegAuto)
Local cURLTest    := EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br") // Teste integrador localhost:3001 - val.portalunico.siscomex.gov.br
Local cURLProd    := EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br") // Produção - portalunico.siscomex.gov.br 
Local lIntgProd   := EasyGParam("MV_EIC0074",.F.,"1") == "1"
Local cErros      := ""
Local cPathInt    := ""
Local lRet        := .T.
Local oProcess
Local cLib

Private cURLIAOE    := "/catp/api/ext/operador-estrangeiro"
Private cURLCOE     := "/catp/api/ext/operador-estrangeiro/exportar/" // + {cpfCnpjRaiz}/{exibirDesativados}
Private cURLAuth    := "/portal/api/autenticar"
Private cPathAuth   := ""
Private cPathIAOE   := ""

Default aOperadores  := {}
Default lIntegAuto   := .F.
GetRemoteType(@cLib)
If 'HTML' $ cLib 
   If ! lOE400Auto
      easyhelp(STR0036,STR0033,STR0037) //"Integração com Portal Único não disponível no smartclientHtml","AVISO","Utilizar o smartclient aplicativo"
   Endif 
ElseIf !lIntegAuto .And. EKJ->EKJ_STATUS == "1"
   easyhelp(STR0049,STR0033,STR0050) //"Integração não realizada, operador estrangeiro já estava integrado","AVISO","Posicione em um operador estrangeiro com o status diferente de integrado pra executar a integração"
Else
   begin sequence

         if ! lIntgProd 
            // se não for execauto exibe a pergunta se não segue como sim
            if ! lOE400Auto .and. ;
               ! lIntegAuto .and. ;
               ! msgnoyes( STR0013 + ENTER ; // "O sistema está configurado para integração com a Base de Testes do Portal Único."
                         + STR0014 + ENTER ; // "Qualquer integração para a Base de Testes não terá qualquer efeito legal e não deve ser utilizada em um ambiente de produção."
                         + STR0015 + ENTER ; //"Para integrar com a Base Oficial (Produção) do Portal Único, altere o parâmetro 'MV_EEC0054' para 1."
                         + STR0016 , STR0017 ) // "Deseja Prosseguir?" // "Atenção"
               break
            else
               cPathInt := cURLTest
            endif
         else
            cPathInt := cURLProd
         endif
         cPathAuth := cPathInt+cURLAuth
         cPathIAOE := cPathInt+cURLIAOE
         // Caso não receba parâmetro faz a inclusão do registro posicionado 
         if len(aOperadores) == 0
            aadd(aOperadores, EKJ->(recno()) )
         endif

      if ! lOE400Auto
         oProcess := MsNewProcess():New({|lEnd| lRet := OE400Sicomex(aOperadores,cPathAuth,cPathIAOE,oProcess,lEnd,@cErros) },;
                    STR0024 , STR0025 ,.T.) // "Integrar Operado Estrangeiro" , "Processando integração"
         oProcess:Activate()
      else
         lRet := OE400Sicomex(aOperadores,cPathAuth,cPathIAOE,oProcess,.F.,@cErros)
      endif

      if ! empty(cErros) .and. ! lRet
         EECView(cErros,STR0017) //ATENÇÃO
      Else
         lIntVrs := OE400RecVers(cPathInt, .T.) // Adquire a versão do Operador Estrangeiro após integrar e não mostra mensagem
         MsgInfo(if(lIntVrs,STR0048,STR0032),STR0033) //Registrado e versão atualizada com sucesso//"Registrado com sucesso" //"Aviso" "
      endif

   end sequence
EndIf
Return lRet
/*/{Protheus.doc} OE400Sicomex
   Função que realiza a integração com o siscomex para cada item do array aOperadores
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   /*/
Function OE400Sicomex(aOperadores,cPathAuth,cPathIAOE,oProcess,lEnd,cErros)
Local nQtdInt     := len(aOperadores)
Local cRet        := ""
Local cAux        := ""
Local cSucesso    := ""
Local cCodigo     := ""
Local ctxtJson    := ""
Local aJson       := {}
Local aJsonErros  := {}
Local lRet        := .T.
Local oEasyJS
Local oJson
Local cRetJson
Local nO
Local nj

   if ! lOE400Auto
      oProcess:SetRegua1(nQtdInt)
   endif
   for nO := 1 to nQtdInt
      If lEnd	//houve cancelamento do processo
         lRet := .F.
         Exit
      EndIf
      EKJ->(dbgoto(aOperadores[nO]))
      If EKJ->EKJ_STATUS <> "1" // se for diferente de registrado
         if ! lOE400Auto
            oProcess:IncRegua1( STR0023 + EKJ->EKJ_FORN + "/" + EKJ->EKJ_FOLOJA ) // "Integrando:"
            oProcess:SetRegua2(1)
         endif

         // Monta o texto do json para a integração
         ctxtJson := '[{' + ;
                        ' "seq": '                    + "1" + ' ,' + ;
                        ' "cpfCnpjRaiz": "'           + EKJ->EKJ_CNPJ_R   + '",' + ;
                        ' "codigo": "'                + EKJ->EKJ_TIN      + '",' + ;
                        ' "nome": "'                  + EKJ->EKJ_NOME     + '",' + ;
                        ' "logradouro": "'            + EKJ->EKJ_LOGR     + '",' + ;
                        ' "nomeCidade": "'            + EKJ->EKJ_CIDA     + '",' + ;
                        ' "codigoSubdivisaoPais": "'  + EKJ->EKJ_SUBP     + '",' + ;
                        ' "codigoPais": "'            + EKJ->EKJ_PAIS     + '",' + ;
                        ' "cep": "'                   + EKJ->EKJ_POSTAL   + '"' + ;
                        '}]'

         // consome o serviço através do easyjs
         oEasyJS  := EasyJS():New()
         oEasyJS:cUrl := cPathAuth
         oEasyJS:setTimeOut(30)
         oEasyJS:Activate(.T.)
         oEasyJS:runJSSync( OE400Auth( cPathAuth , cPathIAOE , ctxtJson ) ,{|x| cRet := x } , {|x| cErros := x } )

         // Pega o retorno e converte para json para extrair as informações
         if ! empty(cRet)
            cRet     := '{"items":'+cRet+'}'
            oJson    := JsonObject():New()
            cRetJson := oJson:FromJson(cRet)
            if valtype(cRetJson) == "U" 
               if valtype(oJson:GetJsonObject("items")) == "A"
                  aJson    := oJson:GetJsonObject("items")
                  if len(aJson) > 0
                     cSucesso := aJson[1]:GetJsonText("sucesso")
                     cCodigo  := aJson[1]:GetJsonText("codigo")
                     if valtype(aJson[1]:GetJsonObject("erros")) == "A"
                        aJsonErros := aJson[1]:GetJsonObject("erros")
                        for nj := 1 to len(aJsonErros)
                           cErros += aJsonErros[nj] + ENTER
                        next
                        if empty(cErros)
                           cErros += STR0019 
                        endif
                     endif
                  endif
               else
                  cErros += STR0018 + ENTER // "Arquivo de retorno sem itens!"
               endif
               FreeObj(oJson)
            else
               cErros += STR0019 + ENTER // "Arquivo de retorno inválido!"
            endif
         elseif empty(cErros)
            cErros += STR0020 + ENTER // "Integração sem nenhum retorno!"
         endif

         // caso dê tudo certo grava as informações e finaliza o registro
         if ! empty(cRet) .and. ! empty(cSucesso) .and. upper(cSucesso) == "TRUE"
            reclock("EKJ",.F.)
               EKJ->EKJ_STATUS:= "1"
               EKJ->EKJ_TIN   := cCodigo
               EKJ->EKJ_DATA  := dDatabase
               EKJ->EKJ_HORA  := strtran(time(),":","")
               EKJ->EKJ_USER  := __cUserID
               EKJ->EKJ_LOG   := ""
            EKJ->(msunlock())
            if ! lOE400Auto
               oProcess:IncRegua2( STR0021 ) // "Integrado!"
            endif
         else // caso não grava o log, se não tiver ret tem algum erro.
            lRet := .F.
            cAux += "Fabricante: " + EKJ->EKJ_FORN + "/" + EKJ->EKJ_FOLOJA + ENTER + cErros
            reclock("EKJ",.F.)
               EKJ->EKJ_STATUS:= "4"
               EKJ->EKJ_DATA  := dDatabase
               EKJ->EKJ_HORA  := strtran(time(),":","")
               EKJ->EKJ_USER  := __cUserID
               EKJ->EKJ_LOG   := cErros
            EKJ->(msunlock())
            if ! lOE400Auto
               oProcess:IncRegua2( STR0022 ) // "Falha!"
            endif
         endif
      endif

      cErros   := ""
      cRet     := ""
      cCodigo  := ""
      cSucesso := ""
   next

   if ! empty(cAux)
      cErros := cAux
   endif

Return lRet

/*/{Protheus.doc} OE400Auth
   Gera o script para autenticar e consumir o serviço do portaul unico através do easyjs 
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   /*/
Static Function OE400Auth(cUrl,cURLIAOE,cOperador)
Local cVar

   begincontent var cVar
      fetch( '%Exp:cUrl%', {
         method: 'POST',
         mode: 'cors',
         headers: { 
            'Content-Type': 'application/json',
            'Role-Type': 'IMPEXP',
         },
      })
      .then( response => {
         if (!(response.ok)) {
            throw new Error( response.statusText );
         }
         var XCSRFToken = response.headers.get('X-CSRF-Token');
         var SetToken = response.headers.get('Set-Token');
         return fetch( '%Exp:cURLIAOE%', {
            method: 'POST',
            mode: 'cors',
            headers: { 
               'Content-Type': 'application/json',
               "Authorization": SetToken,
               "X-CSRF-Token":  XCSRFToken,
            },
            body: '%Exp:cOperador%'
         })
      })
      .then( (res) => res.text() )
      .then( (res) => { retAdvpl(res) } )
      .catch((e) => { retAdvplError(e) });
   endcontent

Return cVar

/*
Programa   : COE400Legen
Objetivo   : Demonstra a legenda das cores da mbrowse
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       :
*/
Function COE400Legen()
Local aCores := {}

   aCores := { {"ENABLE"       ,STR0027   },;   //"Registrado"
               {"BR_AMARELO"   ,STR0028   },;   //"Pendente Registro"
               {"BR_VERMELHO"  ,STR0029	},;   //"Pendente de Retificação
               {"BR_PRETO"     ,STR0030   }}    //"Falha de Integração"

   BrwLegenda(STR0006,STR0031,aCores)

Return .T.

