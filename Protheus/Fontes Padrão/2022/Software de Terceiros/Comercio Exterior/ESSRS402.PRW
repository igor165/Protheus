#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH" 
#INCLUDE "FWBROWSE.CH"

/*
Programa   : ESSRS402
Objetivo   : Manutenção dos Documentos (EL2) relacionados ao Pagamento (EL1) de um Serviço do Registro (EJZ)
Retorno    : Nil
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 05/10/2012 15:14 
Revisao    : 
*/

*------------------------*
Static Function MenuDef()
*------------------------*

Local aRotina := {}

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Documentos" ACTION "VIEWDEF.ESSRS402" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Legendas"   ACTION "RS402Legenda" OPERATION 9 ACCESS 0

Return aRotina

*------------------------*
Static Function ModelDef()
*------------------------*

Local oModel
Local oStruEL1 := FWFormStruct(1,"EL1",{|cCpo| MostrCpo(cCpo)},) 
Local oStruEL2 := FWFormStruct(1,"EL2",{|cCpo| MostrCpo(cCpo)},)
Local bPosVal  := {||RS402GravDoc()}
Local cTpReg   := If( Type("cTpReg")=="C",cTpReg, If( IsInCallStack("ESSRV400") ,"V", "A" ) )

oModel := MPFormModel():New("ESSRS402",/*bGridValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)

//Modelo para criação da antiga Enchoice com a estrutura da tabela
oModel:AddFields("EL1MASTER", /*nOwner*/, oStruEL1,/*bPre*/,/*bPos*/)     
                                                             
//Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid("EL2DETAIL", "EL1MASTER", oStruEL2,  /*bLinePre*/ ,/*bLinePos*/ , /*bPreVal*/,bPosVal,/*bLoad*/ )

// EL1	5	EL1_FILIAL+EL1_TPPROC+EL1_REGIST+EL1_SEQREG+EL1_SEQPAG
// EL2	6	EL2_FILIAL+EL2_TPPROC+EL2_REGIST+EL2_SEQREG+EL2_SEQPAG
//Modelo de relação entre Capa e Detalhe
oModel:SetRelation("EL2DETAIL",{{"EL2_FILIAL", "xFilial('EL2')"},;
                              {"EL2_TPPROC", "RS402Info('EL1_TPPROC')"},;
                              {"EL2_REGIST", "RS402Info('EL1_REGIST')"},;
                              {"EL2_SEQREG", "RS402Info('EL1_SEQREG')"},;
                              {"EL2_SEQPAG", "RS402Info('EL1_SEQPAG')"}},;
                              EL2->(IndexKey(6)))

//Informa grid não pussui preenchimento obrigátorio
oModel:GetModel( "EL2DETAIL" ):SetOptional( .T. ) 

//Definição da Chave Primária
oModel:SetPrimaryKey({})     

oModel:GetModel("EL2DETAIL"):SetUniqueLine({ "EL2_RE", "EL2_DI"})

//Adiciona a descrição do Modelo de Dados
If(cTpReg == "V",oModel:SetDescription("Faturamentos"),oModel:SetDescription("Pagamentos"))  
If(cTpReg == "V",oModel:GetModel("EL1MASTER"):SetDescription("Faturamentos"),oModel:GetModel("EL1MASTER"):SetDescription("Pagamentos")) // Título da Capa
oModel:GetModel("EL2DETAIL"):SetDescription("Documentos") //Título do Detalhe 
Return oModel

*------------------------*
Static Function ViewDef()
*------------------------*

//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("ESSRS402")

//Cria a estrutura a ser usada na View 
Local oStruEL1  := FWFormStruct(2,"EL1",{|cCpo| MostrCpo(cCpo)},) 
Local oStruEL2  := FWFormStruct(2,"EL2",{|cCpo| MostrCpo(cCpo)},)
Local oView
   
//Cria o objeto de View      

oView := FWFormView():New()

//Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_EL1", oStruEL1, "EL1MASTER")
oView:AddGrid( "VIEW_EL2", oStruEL2, "EL2DETAIL" )

//Criar "box" horizontal para receber algum elemento da view 
oView:CreateHorizontalBox( 'EMCIMA'  , 25 )
oView:CreateHorizontalBox( 'EMBAIXO' , 75 ) 

//Relaciona o ID da View com o "box" para exibição 
oView:SetOwnerView("VIEW_EL1", "EMCIMA")
oView:SetOwnerView("VIEW_EL2", "EMBAIXO")


//Ação executada ao deletar uma linha 
oView:SetViewAction("DELETELINE",{||DeleteDoc()})  

//Liga a identificação do componente                     
If(cTpReg == "V",oView:EnableTitleView("VIEW_EL1", "Faturamentos", RGB(240,248,255)),oView:EnableTitleView("VIEW_EL1", "Pagamentos", RGB(240,248,255)))
oView:EnableTitleView("VIEW_EL2", "Documentos", RGB(240,248,255))

//Habilita ButtonsBar
oView:EnableControlBar(.T.)
Return oView


/*
Programa   : MostrCpo
Objetivo   : Verificar quais campos devem compor a estrutura (Documentos relacionados a Pagamentos)
Parametros : Campos a serem verificados
Retorno    : lRet
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 05/10/2012 14:33 
Revisao    : 11/03/2013 09:28
*/

Static Function MostrCpo(cCpo)
Local lRet := .T.           

   If Alltrim(cCpo) $ "EL1_SEQREG/EL2_SEQREG/EL2_SEQPAG/EL2_STTSIS"
      lRet := .F.
   EndIf
   
Return lRet

/*
Programa   : RS402GravDoc()
Objetivo   : Efetuar a gravação dos Documentos relacionados aos Pagamentos apenas caso a DI ou RE tenha sido
             preenchido
Parametros : 
Retorno    : .T.
Autor      : Rafael Ramos Capuano
Data/Hora  : 05/10/2012 14:42 
Revisao    : 
*/

Static Function RS402GravDoc()
Local oModel    := FWModelActive()
Local oModelEL2 := oModel:GetModel("EL2DETAIL")
Local nLinha    := 1
//RRC - 06/03/2013 - Verifica se o pagamento não possui lote gerado, mas que ainda não tenha sido registrado, neste caso, não pode alterar
If lRet := RS401VerLote(EL1->EL1_TPPROC, EL1->EL1_REGIST, EL1->EL1_SEQPAG)//FSY - 23/01/2014 - removido o 4 paremetro
   For nLinha := 1 To oModelEL2:Length()
      oModelEL2:GoLine(nLinha)
      If !oModelEL2:IsDeleted() .And. Empty(oModelEL2:GetValue("EL2_RE")) .And. Empty(oModelEL2:GetValue("EL2_DI")) 
         oModelEL2:DeleteLine()
      EndIf
   Next
Else
   EasyHelp("Não podem ser feitas alterações, pois este pagamento possui lote não cancelado.","Aviso")      
EndIf

Return lRet


/*
Programa   : RS402INFO(cInfo)
Objetivo   : Retornar o conteúdo atual requerido
Parametros : Informação a ser pesquisada 
Retorno    : cRet
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 08/10/2012 09:15 
Revisao    : 
*/ 

Function RS402Info(cInfo)
Local cRet      := ""
Default cInfo   := ""

Do Case
   Case cInfo == "EL1_TPPROC" //Campo não usado
      cRet := EL1->EL1_TPPROC 
      
   Case cInfo == "EL1_REGIST" //Campo não usado
      cRet := EL1->EL1_REGIST
      
   Case cInfo == "EL1_SEQREG" //Campo não usado
      cRet := EL1->EL1_SEQREG        
              
EndCase      

Return cRet

/*
Programa   : RS402Relacao(cCampo)
Objetivo   : Iniciar o conteúdo dos campos especificados, X3_RELACAO
Parametros : cCampo
Retorno    : cRet
Autor      : Rafael Ramos Capuano
Data/Hora  : 10/10/2012 14:01 
Revisao    : 
*/

Function RS402Relacao(cCampo)
Local cRet      := ""
Local oModel    := FWModelActive()
Local oModelEL1 := oModel:GetModel("EL1MASTER")
Local oModelEL2 := oModel:GetModel("EL2DETAIL")    
Default cCampo  := ""

Do Case
   Case cCampo == "EL1_DIAS"      
      If !Empty(M->EL1_PRAZO)
         cRet := M->EL1_PRAZO-If(Empty(M->EL1_DTREG),dDatabase,M->EL1_DTREG)
      Else
         cRet := 0
      EndIf  
EndCase
Return cRet

/*
Programa   : DeleteDoc()
Objetivo   : Validar a exclusão de um Documento relacionado a um Pagamento
Parametros : 
Retorno    : Nil
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 09/10/2012 14:00 
Revisao    : 
*/ 

Static Function DeleteDoc()
Local oModel    := FWModelActive()
Local oModelEL1 := oModel:GetModel("EL1MASTER")
Local oModelEL2 := oModel:GetModel("EL2DETAIL")
Local oView     := FWViewActive()
   
If oModelEL1:GetValue("EL1_STTSIS") <> "1"
   lRet := .F.
   EasyHelp("Este documento não pode ser excluído pois o pagamento referente a ele apresenta Status '" + BSCXBOX('EL1_STTSIS',oModelEL1:GetValue("EL1_STTSIS")) + "'.","Aviso")  
   If oModelEL2:IsDeleted()
      oView:GETVIEWOBJ("EL2DETAIL")[3]:Refresh() //Atualiza o objeto
      oModelEL2:UnDeleteLine()
   EndIf      
EndIf    
Return

/*
Programa   : RS402Legenda()
Objetivo   : Tela de legendas das cores de marcação.
Retorno    : 
Autor      : Fabio Satoru Yamamoto
Data       : 18/03/2013
*/
Function RS402Legenda()
Local aLegenda:= {}

   AAdd(aLegenda, {"BR_VERMELHO", 'Aguardando registro no SISCOSERV'})
   AAdd(aLegenda, {"BR_VERDE"   , 'Registrado no SISCOSERV'}) 
   AAdd(aLegenda, {"BR_AMARELO" , 'Aguardando cancelamento no SISCOSERV'}) 
   AAdd(aLegenda, {"BR_AZUL"    , 'Cancelado no SISCOSERV'})
   BrwLegenda("Pagamentos de Serviços", 'Legendas', aLegenda) //Legenda

Return        
