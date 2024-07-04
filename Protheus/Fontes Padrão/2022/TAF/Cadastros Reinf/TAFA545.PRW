#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA545.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA545
MVC do evento R-4010 - Retenções na Fonte - Pessoa Jurídica

@author Henrique Pereira			
@since 09/08/2019
@version 1.0
  
/*/
//-------------------------------------------------------------------

Function TAFA545()  

	MsgInfo("Prezado cliente, esta rotina estará disponível após a liberação da REINF 2.0","Aviso - REINF")

/* if TAFAlsInDic("V4Q")
    browsedef()  
else
    Aviso( STR0001, TafAmbInvMsg(), { STR0003 }, 3 )  // #Aviso , "Ambiente desatualizado para execução desta Rotina. Tabelas: V4Q ... não existem no metadados.", {Encerrar}                                                                                                                                                                                                                                                                                                                                                                                                                 
endif
 */
return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} browsedef
MVC do evento R-4020 - Retenções na Fonte - Pessoa Jurídica

@author Henrique Pereira			
@since 09/08/2019
@version 1.0

/*/
//-------------------------------------------------------------------

/* static function browsedef()

local oBrowse   as object

//--------------------------------------------
// Inicialização variáveis do tipo objeto
//--------------------------------------------
oBrowse := FWmBrowse():New()

DBSelectArea("V4Q")
DbSetOrder(1)

oBrowse:SetDescription(STR0004)	//"R-4010 - Retenções na Fonte - Pessoa Física"
oBrowse:SetAlias( 'V4Q')
oBrowse:SetMenuDef( 'TAFA545' )	
oBrowse:Activate()

return oBrowse
 */
//--------------------------------------------------
/*/{Protheus.doc} modeldef
Model MVC do evento R-4020 - Retenções na Fonte - Pessoa Jurídica

@author Henrique Pereira			
@since 09/08/2019
@version 1.0

/*/
//--------------------------------------------------

/* static function modeldef()
local cInfoPgtEx as character
local cInfoFisca as character
local cInfoPgto  as character
local cFCI       as character
local cSCP       as character   
local cRRAProcJ  as character
local cDespProcJ as character
local cOrigemRec as character
local oModel     as object
local oStruV4Q   as object
local oStruV4R   as object
local oStruV4Rb  as object
local oStruV4Rc  as object
local oStruV5E   as object
local oStruV5Eb  as object
local oStruV5Ec  as object
local oStruV5Ed  as object
local oStruV5Ee  as object
local oStruV5Ef  as object
local oStruV4T   as object
local oStruV4U   as object
local oStruV4V   as object
local oStruV4X   as object
local oStruV4W   as object
local oStruV4Y   as object
local oStruV4Z   as object
local oStruV5A   as object
local oStruV5B   as object

oModel      := MPFormModel():new("TAFA545")

//--------------------------------------------
// Inicialização variáveis do tipo obejeto 
//--------------------------------------------
oStruV4Q    := FWFormStruct(1,"V4Q") // cabeçalho
oStruV4R    := FWFormStruct(1,"V4R") // idePgto         - Identificação do rendimento
oStruV5E    := FWFormStruct(1,"V5E") // infoPgto        - Informações relativas ao pagamento efetuado
oStruV4T    := FWFormStruct(1,"V4T") // detDed          - O possui na Sociedade em Conta de Participação
oStruV4U    := FWFormStruct(1,"V4U") // benefPen        - Informação dos beneficiários da pensão alimentícia
oStruV4V    := FWFormStruct(1,"V4V") // rendIsento      - Rendimentos isentos ou não tributáveis
oStruV4X    := FWFormStruct(1,"V4X") // infoProcRet     - Informações de processos relacionados a não retenção de tributos ou depósitos judiciais
oStruV4W    := FWFormStruct(1,"V4W") // ideAdv          - Identificação do advogado
oStruV4Y    := FWFormStruct(1,"V4Y") // ideOpSaude      - Identificação da operadora do plano privado coletivo empresarial de assistência à saúde
oStruV4Z    := FWFormStruct(1,"V4Z") // infoReemb       - Informação de reembolso do titular do plano de saúde coletivo empresarial.
oStruV5A    := FWFormStruct(1,"V5A") // infoDependPl    - Informações de dependente do plano de saúde coletivo empresarial.
oStruV5B    := FWFormStruct(1,"V5B") // infoReembDep    - Informação de reembolso do dependente do plano de saúde coletivo empresarial

oModel      := MPFormModel():new("TAFA545")

cInfoPgtEx:= 'V4R_LOGRAD|V4R_NRLOGR|V4R_COMPLE|V4R_BAIRRO|V4R_CIDADE|V4R_ESTADO|V4R_CEP|V4R_TELEF|'                                                                                                          
oStruV4Rb := FwFormStruct( 1, 'V4R', {|x| AllTrim( x ) + "|" $ cInfoPgtEx } )     

cInfoFisca:= 'V4R_INDNIF|V4R_NIF|V4R_CTRIB|V4R_DTRIB|'
oStruV4Rc := FwFormStruct( 1, 'V4R', {|x| AllTrim( x ) + "|" $ cInfoFisca } )  

cFCI      := '|V5E_NRFCI|'
oStruV5Eb := FwFormStruct( 1, 'V5E', {|x| AllTrim( x ) + "|" $ cFCI } )   

cSCP      := 'V5E_NRSCP|V5E_PERSCP|'
oStruV5Ec := FwFormStruct( 1, 'V5E', {|x| AllTrim( x ) + "|" $ cSCP } )  

cRRAProcJ := 'V5E_INDRRA|V5E_TPPROC|V5E_NRPROC|V5E_INDORI|V5E_DESCRI|V5E_QTDMES|'  
oStruV5Ed := FwFormStruct( 1, 'V5E', {|x| AllTrim( x ) + "|" $ cRRAProcJ } )  

cDespProcJ:= 'V5E_VLRDES|V5E_VLRADV|'
oStruV5Ee := FwFormStruct( 1, 'V5E', {|x| AllTrim( x ) + "|" $ cDespProcJ } )  

cOrigemRec:= 'V5E_CNPJOR|'
oStruV5Ef := FwFormStruct( 1, 'V5E', {|x| AllTrim( x ) + "|" $ cOrigemRec } )     


oModel:addfields('MODEL_V4Q',,oStruV4Q) // cabeçalho  fields
oModel:GetModel('MODEL_V4Q'):SetPrimaryKey({'V4Q_ID'}) 

oModel:addgrid('MODEL_V4R','MODEL_V4Q', oStruV4R) //  idePgto - Identificação do rendimento
oModel:GetModel("MODEL_V4R"):SetUniqueLine({"V4R_NATREN","V4R_PAISRE"})
oModel:SetRelation("MODEL_V4R",{ {"V4R_FILIAL","xFilial('V4R')"}, {"V4R_ID","V4Q_ID"},{"V4R_VERSAO","V4Q_VERSAO"} },V4R->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4R' ):SetOptional( .T. )

oModel:AddGrid ('MODEL_V4Rb', 'MODEL_V4R', oStruV4Rb) //InfoPgtEx
oModel:GetModel('MODEL_V4Rb' ):SetOptional( .T. )
oModel:SetRelation("MODEL_V4Rb",{ {"V4R_FILIAL","xFilial('V4R')"}, {"V4R_ID","V4Q_ID"},{"V4R_VERSAO","V4Q_VERSAO"}, {"V4R_NATREN","V4R_NATREN" } },V4R->(IndexKey(1)))
oModel:GetModel('MODEL_V4Rb' ):SetMaxLine(1)

oModel:AddGrid ('MODEL_V4Rc', 'MODEL_V4R', oStruV4Rc) //cInfoFiscal
oModel:GetModel('MODEL_V4Rc' ):SetOptional( .T. )
oModel:SetRelation("MODEL_V4Rc",{ {"V4R_FILIAL","xFilial('V4R')"}, {"V4R_ID","V4Q_ID"},{"V4R_VERSAO","V4Q_VERSAO"}, {"V4R_NATREN","V4R_NATREN" } },V4R->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4Rc' ):SetMaxLine(1)

oModel:Addgrid('MODEL_V5Ea','MODEL_V4R',oStruV5E) // infoPgto - Informações relativas ao pagamento efetuado
oModel:GetModel("MODEL_V5Ea"):SetUniqueLine({"V5E_DATAFG","V5E_INDDEC"})
oModel:SetRelation("MODEL_V5Ea",{{"V5E_FILIAL","xFilial('V5E')"},{"V5E_ID","V4Q_ID"},{"V5E_VERSAO","V4Q_VERSAO"},{"V5E_NATREN","V4R_NATREN"},{"V5E_PAISRE","V4R_PAISRE"}},V5E->(IndexKey(1)))
oModel:GetModel( 'MODEL_V5Ea' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V5Eb','MODEL_V5Ea',oStruV5Eb) //FCI 
oModel:SetRelation("MODEL_V5Eb",{{"V5E_FILIAL","xFilial('V5E')"},{"V5E_ID","V4Q_ID"},{"V5E_VERSAO","V4Q_VERSAO"},{"V5E_NATREN","V4R_NATREN"},{"V5E_PAISRE","V4R_PAISRE"}, {"V5E_DATAFG","V5E_DATAFG"}, {"V5E_INDDEC", "V5E_INDDEC"}},V5E->(IndexKey(1)))
oModel:GetModel( 'MODEL_V5Eb' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V5Eb' ):SetMaxLine(1)

oModel:Addgrid('MODEL_V5Ec','MODEL_V5Ea', oStruV5Ec) //SCP 
oModel:SetRelation("MODEL_V5Ec",{{"V5E_FILIAL","xFilial('V5E')"},{"V5E_ID","V4Q_ID"},{"V5E_VERSAO","V4Q_VERSAO"},{"V5E_NATREN","V4R_NATREN"},{"V5E_PAISRE","V4R_PAISRE"}, {"V5E_DATAFG","V5E_DATAFG"}, {"V5E_INDDEC", "V5E_INDDEC"}},V5E->(IndexKey(1)))
oModel:GetModel( 'MODEL_V5Ec' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V5Ec' ):SetMaxLine(1)

oModel:Addgrid('MODEL_V5Ed','MODEL_V5Ea', oStruV5Ed) //RRA/PROCJUD
oModel:SetRelation("MODEL_V5Ed",{{"V5E_FILIAL","xFilial('V5E')"},{"V5E_ID","V4Q_ID"},{"V5E_VERSAO","V4Q_VERSAO"},{"V5E_NATREN","V4R_NATREN"},{"V5E_PAISRE","V4R_PAISRE"}, {"V5E_DATAFG","V5E_DATAFG"}, {"V5E_INDDEC", "V5E_INDDEC"}},V5E->(IndexKey(1)))
oModel:GetModel( 'MODEL_V5Ed' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V5Ed' ):SetMaxLine(1)

oModel:Addgrid('MODEL_V5Ee','MODEL_V5Ed', oStruV5Ee) //DespProcJud
oModel:SetRelation("MODEL_V5Ee",{{"V5E_FILIAL","xFilial('V5E')"},{"V5E_ID","V4Q_ID"},{"V5E_VERSAO","V4Q_VERSAO"},{"V5E_NATREN","V4R_NATREN"},{"V5E_PAISRE","V4R_PAISRE"}, {"V5E_DATAFG","V5E_DATAFG"}, {"V5E_INDDEC", "V5E_INDDEC"}},V5E->(IndexKey(1)))
oModel:GetModel( 'MODEL_V5Ee' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V5Ee' ):SetMaxLine(1)

oModel:Addgrid('MODEL_V5Ef','MODEL_V5Ed', oStruV5Ef) //cOrigemRec
oModel:SetRelation("MODEL_V5Ef",{{"V5E_FILIAL","xFilial('V5E')"},{"V5E_ID","V4Q_ID"},{"V5E_VERSAO","V4Q_VERSAO"},{"V5E_NATREN","V4R_NATREN"},{"V5E_PAISRE","V4R_PAISRE"}, {"V5E_DATAFG","V5E_DATAFG"}, {"V5E_INDDEC", "V5E_INDDEC"}},V5E->(IndexKey(1)))
oModel:GetModel( 'MODEL_V5Ef' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V5Ef' ):SetMaxLine(1)

oModel:Addgrid('MODEL_V4T','MODEL_V5Ea',oStruV4T) // detDed - O possui na Sociedade em Conta de Participação
oModel:GetModel("MODEL_V4T"):SetUniqueLine({"V4T_TPDEDU"})
oModel:SetRelation("MODEL_V4T",{ {"V4T_FILIAL","xFilial('V4T')"}, {"V4T_ID","V4Q_ID"},{"V4T_VERSAO","V4Q_VERSAO"},{"V4T_NATREN","V4R_NATREN"},{"V4T_PAISRE","V4R_PAISRE"},{"V4T_DATAFG","V5E_DATAFG"},{"V4T_INDDEC","V5E_INDDEC"} },V4T->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4T' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V4U','MODEL_V4T',oStruV4U) // benefPen - Informação dos beneficiários da pensão alimentícia 
oModel:GetModel("MODEL_V4U"):SetUniqueLine({"V4U_CPFDEP"})
oModel:SetRelation("MODEL_V4U",{ {"V4U_FILIAL","xFilial('V4U')"}, {"V4U_ID","V4Q_ID"},{"V4U_VERSAO","V4Q_VERSAO"},{"V4U_NATREN","V4R_NATREN"},{"V4U_PAISRE","V4R_PAISRE"},{"V4U_DATAFG","V5E_DATAFG"},{"V4U_INDDEC","V5E_INDDEC"},{"V4U_TPDEDU","V4T_TPDEDU"}},V4U->(IndexKey(1)))
oModel:GetModel('MODEL_V4U' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V4V','MODEL_V5Ea',oStruV4V) //rendIsento - Rendimentos isentos ou não tributáveis
oModel:GetModel("MODEL_V4V"):SetUniqueLine({"V4V_TPISEN"})
oModel:SetRelation("MODEL_V4V",{ {"V4V_FILIAL","xFilial('V4V')"}, {"V4V_ID","V4Q_ID"},{"V4V_VERSAO","V4Q_VERSAO"},{"V4V_NATREN","V4R_NATREN"},{"V4V_PAISRE","V4R_PAISRE"},{"V4V_DATAFG","V5E_DATAFG"},{"V4V_INDDEC","V5E_INDDEC"} },V4V->(IndexKey(1)))
oModel:GetModel('MODEL_V4V' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V4X','MODEL_V5Ea',oStruV4X) //infoProcRet - Informações de processos relacionados a não retenção de tributos ou depósitos judiciais
oModel:GetModel("MODEL_V4X"):SetUniqueLine({"V4X_TPPROC","V4X_NRPROC"})
oModel:SetRelation("MODEL_V4X",{ {"V4X_FILIAL","xFilial('V4X')"}, {"V4X_ID","V4Q_ID"},{"V4X_VERSAO","V4Q_VERSAO"},{"V4X_NATREN","V4R_NATREN"},{"V4X_PAISRE","V4R_PAISRE"},{"V4X_DATAFG","V5E_DATAFG"},{"V4X_INDDEC","V5E_INDDEC"}},V4X->(IndexKey(1)))
oModel:GetModel('MODEL_V4X' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V4W','MODEL_V5Ea',oStruV4W) // ideAdv - Identificação do advogado
oModel:GetModel("MODEL_V4W"):SetUniqueLine({"V4W_TPINSC","V4W_NRINSC"})
oModel:SetRelation("MODEL_V4W",{ {"V4W_FILIAL","xFilial('V4W')"}, {"V4W_ID","V4Q_ID"},{"V4W_VERSAO","V4Q_VERSAO"},{"V4W_NATREN","V4R_NATREN"},{"V4W_PAISRE","V4R_PAISRE"},{"V4W_DATAFG","V5E_DATAFG"},{"V4W_INDDEC","V5E_INDDEC"}},V4W->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4W' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V4Y','MODEL_V4Q',oStruV4Y) // ideOpSaude -  Identificação da operadora do plano privado coletivo empresarial de assistência à saúde
oModel:GetModel("MODEL_V4Y"):SetUniqueLine({"V4Y_NRINSC"})
oModel:SetRelation("MODEL_V4Y",{ {"V4Y_FILIAL","xFilial('V4Y')"}, {"V4Y_ID","V4Q_ID"},{"V4Y_VERSAO","V4Q_VERSAO"}},V4Y->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4Y' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V4Z','MODEL_V4Y',oStruV4Z) // infoReemb - Informação de reembolso do titular do plano de saúde coletivo empresarial
oModel:GetModel("MODEL_V4Z"):SetUniqueLine({"V4Z_TPINSC","V4Z_NRINSC"})
oModel:SetRelation("MODEL_V4Z",{ {"V4Z_FILIAL","xFilial('V4Z')"}, {"V4Z_ID","V4Q_ID"},{"V4Z_VERSAO","V4Q_VERSAO"},{"V4Z_INSC4Y","V4Y_NRINSC"} },V4Z->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4Z' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V5A','MODEL_V4Y',oStruV5A) // infoDependPl - Informações de dependente do plano de saúde coletivo empresarial.
oModel:GetModel("MODEL_V5A"):SetUniqueLine({"V5A_CPF"})
oModel:SetRelation("MODEL_V5A",{ {"V5A_FILIAL","xFilial('V5A')"}, {"V5A_ID","V4Q_ID"},{"V5A_VERSAO","V4Q_VERSAO"},{"V5A_NRINSC","V4Y_NRINSC"} },V5A->(IndexKey(1)))
oModel:GetModel( 'MODEL_V5A' ):SetOptional( .T. )

oModel:Addgrid('MODEL_V5B','MODEL_V5A',oStruV5B) //infoReembDep - Informação de reembolso do dependente do plano de saúde coletivo empresarial
oModel:GetModel("MODEL_V5B"):SetUniqueLine({"V5B_SEQ"})
oModel:SetRelation("MODEL_V5B",{ {"V5B_FILIAL","xFilial('V5B')"}, {"V5B_ID","V4Q_ID"},{"V5B_VERSAO","V4Q_VERSAO"},{"V5B_INSC4Y","V4Y_NRINSC"},{"V5B_CPF","V5A_CPF"} },V5B->(IndexKey(1)))
oModel:GetModel( 'MODEL_V5B' ):SetOptional( .T. )

return oModel
 */
//--------------------------------------------------
/*/{Protheus.doc} viewdef
View MVC do evento R-4020 - Retenções na Fonte - Pessoa Jurídica

@author Henrique Pereira/Katielly Feitosa 		
@since 09/08/2019
@version 1.0

/*/
//--------------------------------------------------
/* static function viewdef()
local cCmpFil    as character
local cIdePgto   as character
local cInfoPgtEx as character
local cInfoFisca as character
local cInfoPgto  as character
local cFCI       as character
local cSCP       as character   
local cRRAProcJ  as character
local cDespProcJ as character
local cOrigemRec as character
local oView      as object
local oModel     as object
local oStruV4Q   as object
local oStruV4Qb  as object
local oStruV4R   as object
local oStruV4Rb  as object
local oStruV4Rc  as object
local oStruV5E   as object
local oStruV5Eb  as object
local oStruV5Ec  as object
local oStruV5Ed  as object
local oStruV5Ee  as object
local oStruV5Ef  as object
local oStruV4T   as object
local oStruV4U   as object
local oStruV4V   as object
local oStruV4X   as object
local oStruV4W   as object
local oStruV4Y   as object
local oStruV4Z   as object
local oStruV5A   as object
local oStruV5B   as object

// Inicialização variáveis do tipo obejeto
oView     := FWFormView():new()
oModel    := FWLoadModel('TAFA545')
oStruV4Q  := FwFormStruct(2,"V4Q")   // cabeçalho
oStruV4T  := FwFormStruct(2,"V4T")   // detDed          - O possui na Sociedade em Conta de Participação
oStruV4U  := FwFormStruct(2,"V4U")   // benefPen        - Informação dos beneficiários da pensão alimentícia
oStruV4V  := FwFormStruct(2,"V4V")   // rendIsento      - Rendimentos isentos ou não tributáveis
oStruV4X  := FwFormStruct(2,"V4X")   // infoProcRet     - Informações de processos relacionados a não retenção de tributos ou depósitos judiciais
oStruV4W  := FwFormStruct(2,"V4W")   // ideAdv          - Identificação do advogado
oStruV4Y  := FwFormStruct(2,"V4Y")   // ideOpSaude      - Identificação da operadora do plano privado coletivo empresarial de assistência à saúde
oStruV4Z  := FwFormStruct(2,"V4Z")   // infoReemb       - Informação de reembolso do titular do plano de saúde coletivo empresarial.
oStruV5A  := FwFormStruct(2,"V5A")   // infoDependPl    - Informações de dependente do plano de saúde coletivo empresarial.
oStruV5B  := FwFormStruct(2,"V5B")   // infoReembDep    - Informação de reembolso do dependente do plano de saúde coletivo empresarial

cCmpFil   := 'V4Q_PROTUL|'
oStruV4Qb := FwFormStruct( 2, 'V4Q', {|x| AllTrim( x ) + "|" $ cCmpFil } )

cIdePgto  := 'V4R_FILIAL|V4R_ID|V4R_VERSAO|V4R_IDNTRE|V4R_DNATRE|V4R_PAISRE|V4R_OBSERV|V4R_NATREN|'                                                                                                                                                                                       
oStruV4R  := FwFormStruct( 2, 'V4R', {|x| AllTrim( x ) + "|" $ cIdePgto } )     

cInfoPgtEx:= 'V4R_LOGRAD|V4R_NRLOGR|V4R_COMPLE|V4R_BAIRRO|V4R_CIDADE|V4R_ESTADO|V4R_CEP|V4R_TELEF|'                                                                                                          
oStruV4Rb := FwFormStruct( 2, 'V4R', {|x| AllTrim( x ) + "|" $ cInfoPgtEx } )     

cInfoFisca:= 'V4R_INDNIF|V4R_NIF|V4R_CTRIB|V4R_DTRIB|'
oStruV4Rc := FwFormStruct( 2, 'V4R', {|x| AllTrim( x ) + "|" $ cInfoFisca } )    

cInfoPgto := 'V5E_FILIAL|V5E_ID|V5E_VERSAO|V5E_DATAFG|V5E_INDDEC|V5E_VLRBRU|V5E_VLRTRI|V5E_VLRIR|V5E_VLRSUS|V5E_VLRNIR|V5E_VLDEPO|V5E_VLRANO|V5E_VLRANT|'
oStruV5E  := FwFormStruct( 2, 'V5E', {|x| AllTrim( x ) + "|" $ cInfoPgto } )    

cFCI      := 'V5E_NRFCI|'
oStruV5Eb := FwFormStruct( 2, 'V5E', {|x| AllTrim( x ) + "|" $ cFCI } )    

cSCP      := 'V5E_NRSCP|V5E_PERSCP|'
oStruV5Ec := FwFormStruct( 2, 'V5E', {|x| AllTrim( x ) + "|" $ cSCP } )  

cRRAProcJ := 'V5E_INDRRA|V5E_TPPROC|V5E_NRPROC|V5E_INDORI|V5E_DESCRI|V5E_QTDMES|'  
oStruV5Ed := FwFormStruct( 2, 'V5E', {|x| AllTrim( x ) + "|" $ cRRAProcJ } )  

cDespProcJ:= 'V5E_VLRDES|V5E_VLRADV|'
oStruV5Ee := FwFormStruct( 2, 'V5E', {|x| AllTrim( x ) + "|" $ cDespProcJ } )  

cOrigemRec:= 'V5E_CNPJOR|'
oStruV5Ef := FwFormStruct( 2, 'V5E', {|x| AllTrim( x ) + "|" $ cOrigemRec } )  

oView:SetModel( oModel )
oView:SetContinuousForm(.T.)

oView:CreateHorizontalBox( 'BOXH_MASTER', 100)
oView:CreateFolder("FOLDER_MASTER","BOXH_MASTER")
oView:AddSheet( 'FOLDER_MASTER', 'SHEET_MASTER', STR0006 ) // "R-4010"
oView:AddSheet( 'FOLDER_MASTER', 'SHEET_PROTUL', STR0007 ) 

oView:AddField("VIEW_V4Q", oStruV4Q, "MODEL_V4Q" )
oView:EnableTitleView("VIEW_V4Q", STR0004 ) //"R-4010 - Retenções na Fonte - Pessoa Física"
oView:CreateHorizontalBox("PAINEL_SUPERIOR", 30,,,"FOLDER_MASTER","SHEET_MASTER" )
oView:SetOwnerView( "VIEW_V4Q", "PAINEL_SUPERIOR" )   

oView:AddField("VIEW_V4QB", oStruV4Qb, "MODEL_V4Q" )
oView:EnableTitleView("VIEW_V4QB", STR0005) //"Recibo R-4010 - Retenções na Fonte - Pessoa Física"
oView:CreateHorizontalBox("PAINEL_SUPERIORB", 30,,,"FOLDER_MASTER","SHEET_PROTUL" )
oView:SetOwnerView( "VIEW_V4QB", "PAINEL_SUPERIORB" )   

//INFORMAÇÕES SOBRE A NATUREZA DO RENDIMENTO - NÍVEL 1
oView:CreateHorizontalBox( '1BOXH_IDEBENEF', 70,,,"FOLDER_MASTER","SHEET_MASTER")
oView:CreateFolder("FOLDER_IDEBENEF","1BOXH_IDEBENEF")
oView:AddSheet( 'FOLDER_IDEBENEF', 'SHEET_IDEPGTO', STR0008 ) //"idePgto"

oView:CreateHorizontalBox("BOXH_IDEPGTO",20,,,"FOLDER_IDEBENEF","SHEET_IDEPGTO")
oView:AddGrid("VIEW_V4R", oStruV4R,"MODEL_V4R" )
oView:EnableTitleView("VIEW_V4R", STR0009 )  //"Identificação do rendimento"
oView:SetOwnerView( "VIEW_V4R", "BOXH_IDEPGTO" ) 

//INFORMAÇÕES REFERENTES AO PAGAMENTO- NÍVEL 2
oView:CreateHorizontalBox( '1BOXH_IDEPGTO', 20,,,"FOLDER_IDEBENEF","SHEET_IDEPGTO")
oView:CreateFolder("FOLDER_IDEPGTO","1BOXH_IDEPGTO")
oView:AddSheet( 'FOLDER_IDEPGTO', 'SHEET_INFOPGTO', STR0028) //"infoPgto"

oView:CreateHorizontalBox( 'BOXH_INFOPGTO', 20,,,"FOLDER_IDEPGTO","SHEET_INFOPGTO")
oView:AddGrid("VIEW_V5E", oStruV5E,"MODEL_V5Ea" )
oView:EnableTitleView("VIEW_V5E", STR0010 ) //"Informações relativas ao pagamento efetuado"
oView:SetOwnerView( "VIEW_V5E", "BOXH_INFOPGTO" )

oView:CreateHorizontalBox( '1BOXH_INFOPGTO', 60,,,"FOLDER_IDEPGTO","SHEET_INFOPGTO")
oView:CreateFolder("FOLDER_INFOPGTO","1BOXH_INFOPGTO")

oView:AddSheet( 'FOLDER_INFOPGTO', 'SHEET_FCI', STR0029 ) //"FCI"
oView:CreateHorizontalBox( 'BOXH_FCI', 40,,,"FOLDER_INFOPGTO","SHEET_FCI" )
oView:AddGrid("VIEW_V5Eb", oStruV5Eb, "MODEL_V5Eb" ) 
oView:EnableTitleView("VIEW_V5Eb", STR0030 ) //"Fundo ou clube de investimento"
oView:SetOwnerView( "VIEW_V5Eb", "BOXH_FCI" )

oView:AddSheet( 'FOLDER_INFOPGTO', 'SHEET_SCP', STR0031 ) //"SCP"
oView:CreateHorizontalBox( 'BOXH_SCP', 40,,,"FOLDER_INFOPGTO","SHEET_SCP" )
oView:AddGrid("VIEW_V5Ec", oStruV5Ec, "MODEL_V5Ec" ) 
oView:EnableTitleView("VIEW_V5Ec", STR0032) //"Sociedade em conta de participação"
oView:SetOwnerView( "VIEW_V5Ec", "BOXH_SCP" )

oView:AddSheet( 'FOLDER_INFOPGTO', 'SHEET_DETDED', STR0011 ) //"detDed"
oView:CreateHorizontalBox( 'BOXH_DETDED', 40,,,"FOLDER_INFOPGTO","SHEET_DETDED" ) 
oView:AddGrid("VIEW_V4T", oStruV4T,"MODEL_V4T" ) 
oView:EnableTitleView("VIEW_V4T", STR0012 ) //"Dedução do Tributo por Natureza de Rendimento"
oView:SetOwnerView( "VIEW_V4T", "BOXH_DETDED" )

oView:CreateHorizontalBox( 'BOX_BENEFPEN', 40,,,"FOLDER_INFOPGTO","SHEET_DETDED" ) 
oView:AddGrid("VIEW_V4U", oStruV4U,"MODEL_V4U" )
oView:EnableTitleView("VIEW_V4U", STR0013 ) //"Informação dos beneficiários da pensão alimentícia"
oView:SetOwnerView( "VIEW_V4U", "BOX_BENEFPEN" )

oView:AddSheet( 'FOLDER_INFOPGTO', 'SHEET_RENDISENTO', STR0014 ) //"rendIsento"
oView:CreateHorizontalBox("BOXH_RENDISENTO",40,,,"FOLDER_INFOPGTO","SHEET_RENDISENTO")
oView:AddGrid("VIEW_V4V", oStruV4V,"MODEL_V4V")
oView:EnableTitleView("VIEW_V4V", STR0015) //"Rendimentos isentos ou não tributáveis"
oView:SetOwnerView( "VIEW_V4V", "BOXH_RENDISENTO" )

oView:AddSheet("FOLDER_INFOPGTO","SHEET_INFOPROCRET",STR0016) //""infoProcRet"
oView:CreateHorizontalBox("BOX_INFOPROCRET",40,,,"FOLDER_INFOPGTO","SHEET_INFOPROCRET")
oView:AddGrid("VIEW_V4X", oStruV4X,"MODEL_V4X")
oView:EnableTitleView("VIEW_V4X",STR0017) //"Informações de processos relacionados a não retenção de tributos ou depósitos judiciais"  
oView:SetOwnerView( "VIEW_V4X", "BOX_INFOPROCRET" )

oView:AddSheet("FOLDER_INFOPGTO","SHEET_RRAPROCJUD", STR0033 ) //"infoRRA/infoProcJud"
oView:CreateHorizontalBox("BOX_RRAPROCJUD",40,,,"FOLDER_INFOPGTO","SHEET_RRAPROCJUD")
oView:AddGrid("VIEW_V5Ed", oStruV5Ed,"MODEL_V5Ed")
oView:EnableTitleView("VIEW_V5Ed", STR0034) //"Informações complemetares relativos a RRA ou Rendimentos decorrentes de Decisão Judicial"
oView:SetOwnerView( "VIEW_V5Ed", "BOX_RRAPROCJUD" )

oView:CreateHorizontalBox( '1BOXH_RRAPROCJUD', 60,,,"FOLDER_INFOPGTO","SHEET_RRAPROCJUD")
oView:CreateFolder("FOLDER_RRAPROCJUD","1BOXH_RRAPROCJUD")

oView:AddSheet( 'FOLDER_RRAPROCJUD', 'SHEET_DESPPROCJU', STR0035  ) //"despProcJud"
oView:CreateHorizontalBox( 'BOXH_DESPPROCJU', 40,,,"FOLDER_RRAPROCJUD","SHEET_DESPPROCJU" )
oView:AddGrid("VIEW_V5Ee", oStruV5Ee, "MODEL_V5Ee" ) 
oView:EnableTitleView("VIEW_V5Ee", STR0036 ) //"Detalhamento das despesas com processo judicial"
oView:SetOwnerView( "VIEW_V5Ee", "BOXH_DESPPROCJU" )

oView:CreateHorizontalBox("BOX_IDEADV",40,,,"FOLDER_RRAPROCJUD","SHEET_DESPPROCJU")
oView:AddGrid("VIEW_V4W", oStruV4W,"MODEL_V4W")
oView:EnableTitleView("VIEW_V4W",STR0019) //"ideAdv - Identificação do advogado"
oView:SetOwnerView( "VIEW_V4W", "BOX_IDEADV" )

oView:AddSheet("FOLDER_RRAPROCJUD","SHEET_ORIGEMREC",STR0037 ) //"origemRec"
oView:CreateHorizontalBox("BOX_ORIGEMREC",40,,,"FOLDER_RRAPROCJUD","SHEET_ORIGEMREC")
oView:AddGrid("VIEW_V5Ef", oStruV5Ef, "MODEL_V5Ef")
oView:EnableTitleView("VIEW_V5Ef", STR0038) //"Informações sobre a origem dos recursos"
oView:SetOwnerView( "VIEW_V5Ef", "BOX_ORIGEMREC" )

//INFORMAÇÕES DE BENEFICIARIOS DO EXTERIOR - NÍVEL 2
oView:AddSheet('FOLDER_IDEPGTO','SHEET_INFOPGTOEX', STR0039 ) //"infoPgtoExt"
oView:CreateHorizontalBox('BOXH_INFOPGTOEX',20,,,'FOLDER_IDEPGTO','SHEET_INFOPGTOEX')
oView:CreateFolder('FOLDER_INFOPGTOEX','BOXH_INFOPGTOEX')

oView:AddSheet('FOLDER_INFOPGTOEX','SHEET_ENDEXT', STR0042)	//"endExt"
oView:AddSheet('FOLDER_INFOPGTOEX','SHEET_INFOFISCAL', STR0043)	//"infoFiscal"
oView:CreateHorizontalBox('BOX_ENDEXT',100,,,'FOLDER_INFOPGTOEX','SHEET_ENDEXT')
oView:CreateHorizontalBox('BOX_INFOFISCAL',100, ,,'FOLDER_INFOPGTOEX','SHEET_INFOFISCAL')
        
oView:AddGrid("VIEW_V4RB", oStruV4Rb,"MODEL_V4Rb" )
oView:EnableTitleView("VIEW_V4RB", STR0040 )  //"Endereço do beneficiário residente ou domiciliado no exterior"
oView:SetOwnerView( "VIEW_V4RB", "BOX_ENDEXT" )

oView:AddGrid("VIEW_V4RC", oStruV4Rc,"MODEL_V4Rc" )
oView:EnableTitleView("VIEW_V4RC", STR0041 )  //"Informações fiscais do beneficiário residente ou domiciliado no exterior"
oView:SetOwnerView( "VIEW_V4RC", "BOX_INFOFISCAL" )

//PLANO DE SAÚDE E FILHOS - NÍVEL 1
oView:AddSheet( 'FOLDER_IDEBENEF', 'SHEET_IDEOPSAUDE',STR0020)//"ideOpSaude"
oView:CreateHorizontalBox("BOXH_IDEOPSAUDE",20,,,"FOLDER_IDEBENEF","SHEET_IDEOPSAUDE")
oView:AddGrid("VIEW_V4Y", oStruV4Y,"MODEL_V4Y" )
oView:EnableTitleView("VIEW_V4Y",STR0021)  //"Identificação da operadora do plano privado coletivo empresarial de assistência à saúde"
oView:SetOwnerView( "VIEW_V4Y", "BOXH_IDEOPSAUDE" ) 

oView:CreateHorizontalBox( '1BOXH_INFOREEMB', 70,,,"FOLDER_IDEBENEF","SHEET_IDEOPSAUDE")
oView:CreateFolder("FOLDER_INFOREEMB","1BOXH_INFOREEMB")
oView:AddSheet( 'FOLDER_INFOREEMB', 'SHEET_INFOREEMB', STR0022) //"infoReemb"

oView:CreateHorizontalBox("BOXH_INFOREEMB",30,,,"FOLDER_INFOREEMB","SHEET_INFOREEMB")
oView:AddGrid("VIEW_V4Z", oStruV4Z,"MODEL_V4Z" )
oView:EnableTitleView("VIEW_V4Z", STR0023 ) //"Informação de reembolso do titular do plano de saúde coletivo empresarial"
oView:SetOwnerView( "VIEW_V4Z", "BOXH_INFOREEMB" ) 

oView:AddSheet( 'FOLDER_INFOREEMB', 'SHEET_INFODEPENPL', STR0024)  //"infoDependPl"
oView:CreateHorizontalBox("BOXH_INFODEPENPL",30,,,"FOLDER_INFOREEMB","SHEET_INFODEPENPL")
oView:AddGrid("VIEW_V5A", oStruV5A,"MODEL_V5A" )
oView:EnableTitleView("VIEW_V5A", STR0025) //"Informações de dependente do plano de saúde coletivo empresarial." 
oView:SetOwnerView( "VIEW_V5A", "BOXH_INFODEPENPL" ) 

oView:CreateHorizontalBox( '1BOXH_INFOREEMBDEP', 70,,,"FOLDER_INFOREEMB","SHEET_INFODEPENPL")
oView:CreateFolder("FOLDER_INFOREEMBDEP","1BOXH_INFOREEMBDEP")

oView:AddSheet( 'FOLDER_INFOREEMBDEP', 'SHEET_INFOREEMBDEP',STR0026) //"infoReembDep"
oView:CreateHorizontalBox("BOXH_INFOREEMBDEP",30,,,"FOLDER_INFOREEMBDEP","SHEET_INFOREEMBDEP")
oView:AddGrid("VIEW_V5B", oStruV5B,"MODEL_V5B" )
oView:EnableTitleView("VIEW_V5B", STR0027 )  //"Informação de reembolso do dependente do plano de saúde coletivo empresarial"
oView:SetOwnerView( "VIEW_V5B", "BOXH_INFOREEMBDEP" ) 

oStruV4Q:RemoveField("V4Q_PROTUL")

oStruV4R:RemoveField("V4R_ID"    )
oStruV4R:RemoveField("V4R_IDTRIB")
oStruV4R:RemoveField("V4R_IDNTRE")

oStruV4T:RemoveField("V4T_VERSAO")
oStruV4T:RemoveField("V4T_NATREN")
oStruV4T:RemoveField("V4T_PAISRE")    
oStruV4T:RemoveField("V4T_INDDEC")
oStruV4T:RemoveField("V4T_DATAFG")

oStruV4V:RemoveField("V4V_NATREN")
oStruV4V:RemoveField("V4V_PAISRE")
oStruV4V:RemoveField("V4V_INDDEC")
oStruV4V:RemoveField("V4V_DATAFG")

oStruV4W:RemoveField("V4W_NATREN")
oStruV4W:RemoveField("V4W_PAISRE")
oStruV4W:RemoveField("V4W_INDDEC")
oStruV4W:RemoveField("V4W_DATAFG")

oStruV4X:RemoveField("V4X_NATREN")
oStruV4X:RemoveField("V4X_PAISRE")
oStruV4X:RemoveField("V4X_INDDEC")
oStruV4X:RemoveField("V4X_DATAFG")

oStruV4U:RemoveField("V4U_NATREN")
oStruV4U:RemoveField("V4U_PAISRE")
oStruV4U:RemoveField("V4U_PAISRE")
oStruV4U:RemoveField("V4U_DATAFG")
oStruV4U:RemoveField("V4U_TPDEDU")

oStruV5E:RemoveField("V5E_PAISRE")
oStruV5E:RemoveField("V5E_NATREN")
oStruV5E:RemoveField("V5E_IDTRIB")

oStruV4Y:RemoveField("V4Y_NATREN")
oStruV4Y:RemoveField("V4Y_PAISRE")

oStruV4Z:RemoveField("V4Z_INSC4Y")

oStruV5A:RemoveField("V5A_NRINSC")

oStruV5B:RemoveField("V5B_INSC4Y")
oStruV5B:RemoveField("V5B_CPF"   )
oStruV5B:RemoveField("V5B_SEQ"   )

xFunRmFStr(@oStruV4Q,"V4Q") //Remove campos padrões da tabela espelho

return oView
 */
//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu para MVC do evento R-4020 - Retenções na Fonte - Pessoa Jurídica

@author Henrique Pereira			
@since 09/08/2019
@version 1.0

/*/
//--------------------------------------------------
/* Static Function MenuDef()

Local aRotina as array
//--------------------------------------------
// Inicialização variáveis do tipo array
//--------------------------------------------
aRotina := {}
aFuncao := {}

//aAdd( aFuncao, { "", "xFunNewHis( 'V4N', 'TAFA543' )", "3" } )

//Linha comentada para que alguns menus não apareçam durante a WarRoom.
//lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )
    
lMenuDif := .T.

if lMenuDif
    ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA545' OPERATION 2 ACCESS 0
else
    aRotina := TAFMenuReinf( "TAFA545", aFuncao )
endIf

Return(aRotina) 
*/