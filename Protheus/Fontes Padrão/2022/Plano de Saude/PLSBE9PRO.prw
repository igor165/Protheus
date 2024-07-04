#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'topconn.ch'
#include 'PLSBE9PRO.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@since 09/2019
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  STR0003 	Action "staticCall(PLSBE9PRO, PlsTelNew, 1)"  	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0004  	Action "staticCall(PLSBE9PRO, PlsTelNew, 3)"  	Operation 3 Access 0  //Incluir
Add Option aRotina Title  STR0005   Action "staticCall(PLSBE9PRO, PlsTelNew, 4)" 	Operation 4 Access 0  //Alterar
Add Option aRotina Title  STR0006   Action "VIEWDEF.PLSBE9PRO"	Operation 5 Access 0  //Excluir

Return aRotina



//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados.
@since 09/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrBE9 :=  FWFormStruct(1,'BE9')
local lAutoma :=  IIf(type('lAutBE9PR')=='U',.F.,lAutBE9PR) // Variavel declarada para fins de automação
local fieldBE9  := BE9->(FieldPos("BE9_SEQUEN")) > 0
local fieldBBI  := BBI->(FieldPos("BBI_SEQUEN")) > 0

oModel := MPFormModel():New( 'PLSBE9PRO') 

aGatilho := FwStruTrigger('BE9_CODTAB', 'BE9_CODPRO', '', .f., '', 1, '','!empty(FwFldGet("BE9_CODTAB"))')                                           
oStrBE9:AddTrigger( aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4] )

aGatilho := FwStruTrigger('BE9_CODTAB', 'BE9_DESPRO', '', .f., '', 1, '','!empty(FwFldGet("BE9_CODTAB"))')                                           
oStrBE9:AddTrigger( aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4] )


oModel:AddFields( 'BE9MASTER', /*cOwner*/, oStrBE9 )
oModel:GetModel( 'BE9MASTER' ):SetDescription( STR0001 ) //'Procedimentos - Planos de Saúde Vinculados'

oStrBE9:SetProperty("BE9_CODGRU" , MODEL_FIELD_WHEN , { || .f. } )

//INICIALIZADOR PADRAO
IF lAutoma // Para fim de automação, foi feito dessa forma pois ao chamar da automação as variaveis estao vazias
    oStrBE9:SetProperty( 'BE9_CODLOC' , MODEL_FIELD_INIT, { || '001'} )
    oStrBE9:SetProperty( 'BE9_CODESP' , MODEL_FIELD_INIT, { || '002'} )
    oStrBE9:SetProperty( 'BE9_CODSUB' , MODEL_FIELD_INIT, { || ''} )
    oStrBE9:SetProperty( 'BE9_CODINT' , MODEL_FIELD_INIT, { || Plsintpad()} )
    oStrBE9:SetProperty( 'BE9_CODIGO' , MODEL_FIELD_INIT, { || '000004'} )
    oStrBE9:SetProperty( 'BE9_CODPLA' , MODEL_FIELD_INIT, { || '0001'} )
    oStrBE9:SetProperty( 'BE9_CODGRU' , MODEL_FIELD_INIT, { || ''} )
else
    oStrBE9:SetProperty( 'BE9_CODLOC' , MODEL_FIELD_INIT, { || cPVLocBBI} )
    oStrBE9:SetProperty( 'BE9_CODESP' , MODEL_FIELD_INIT, { || cPVEspBBI} )
    oStrBE9:SetProperty( 'BE9_CODSUB' , MODEL_FIELD_INIT, { || cPVEspSBBI} )
    oStrBE9:SetProperty( 'BE9_CODINT' , MODEL_FIELD_INIT, { || Plsintpad()} )
    oStrBE9:SetProperty( 'BE9_CODIGO' , MODEL_FIELD_INIT, { || cRdaBAUB} )
    oStrBE9:SetProperty( 'BE9_CODPLA' , MODEL_FIELD_INIT, { || BBI->BBI_CODPRO} )
    oStrBE9:SetProperty( 'BE9_CODGRU' , MODEL_FIELD_INIT, { || BBI->BBI_CODGRU} )
    IF fieldBE9 .and. fieldBBI
        oStrBE9:SetProperty( 'BE9_SEQUEN' , MODEL_FIELD_INIT, { || BBI->BBI_SEQUEN} )
    endif
endif

//TAMANHO
oStrBE9:SetProperty( 'BE9_DESPRO' , MODEL_FIELD_TAMANHO, 300 )
oStrBE9:SetProperty( 'BE9_DESTAB' , MODEL_FIELD_TAMANHO, 300 )

//VALIDACOES
oStrBE9:SetProperty( 'BE9_VIGDE' , MODEL_FIELD_VALID,{ ||PlsVldVIG(oModel,1) }  )
oStrBE9:SetProperty( 'BE9_VIGATE' ,MODEL_FIELD_VALID,{ ||PlsVldVIG(oModel,2)}  )
oStrBE9:SetProperty( 'BE9_CODPRO' ,MODEL_FIELD_VALID,{ ||PLSA360BE9(oModel)}  )

//OBRIGATORIOS
oStrBE9:SetProperty( 'BE9_VIGATE' , MODEL_FIELD_OBRIGAT, .F. )




oModel:SetPrimaryKey( { "BE9_FILIAL", "BE9_CODIGO", "BE9_CODINT", "BE9_CODLOC", "BE9_CODESP", "BE9_CODSUB", "BE9_CODPLA", "BE9_CODPAD", "BBI_CODPRO" } )
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface.
@since 09/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView 
Local oModel	:= FWLoadModel( 'PLSBE9PRO' ) // Cria as estruturas a serem usadas na View
Local oStrBE9	:= FWFormStruct(2,'BE9',{ |cCampo| PLSCMPBE9(cCampo) } )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_BE9', oStrBE9, 'BE9MASTER' )
oView:CreateHorizontalBox( 'SUPERIOR', 100 )
oView:SetOwnerView( 'VIEW_BE9', 'SUPERIOR' )

Return oView



//----------------------------------------------------------------
/*/{Protheus.doc} PLSVLDVIGMvc
--Substitui a função PLSVLDVIG.
Validacao da vigencia
@author  DEV TOTVS
@version P12
@since   09/09/19
/*/
//----------------------------------------------------------------
Static Function PlsVldVIG(oModel,nTipo)
Local lRet    := .T.
local cSql :=""
local nOperation := oModel:getOperation()
local cData := iif(nTipo==1,dtos(oModel:GetValue("BE9MASTER","BE9_VIGDE")),dtos(oModel:GetValue("BE9MASTER","BE9_VIGATE")))           
    //Verifico se a vigência final é maior que a inicial.
    If !Empty(oModel:GetValue("BE9MASTER","BE9_VIGATE")) .and. oModel:GetValue("BE9MASTER","BE9_VIGDE") > oModel:GetValue("BE9MASTER","BE9_VIGATE")
        Help(nil, nil ,STR0007, nil, STR0008, 1, 0, nil, nil, nil, nil, nil, {STR0010} )//Atenção: Vigência Inicial não pode ser maior que a Final. Informe outra data.
        lRet := .F.
    EndIf

 if lRet
    //Verifico se já existe uma vigência em aberto
   cSql := " SELECT BE9_VIGDE,BE9_VIGATE FROM " + RetSqlName("BE9") 
   cSql += " WHERE BE9_FILIAL = '"    + xFilial("BE9") + "' "
   cSql += " AND BE9_CODIGO =  '"     + alltrim(oModel:GetValue("BE9MASTER","BE9_CODIGO")) + "' " 
   cSql += " AND BE9_CODINT = '"      + alltrim(oModel:GetValue("BE9MASTER","BE9_CODINT")) + "' "
   cSql += " AND BE9_CODLOC = '"      + alltrim(oModel:GetValue("BE9MASTER","BE9_CODLOC")) + "' "
   cSql += " AND BE9_CODESP = '"      + alltrim(oModel:GetValue("BE9MASTER","BE9_CODESP")) + "' "
   cSql += " AND BE9_CODPLA = '"      + alltrim(oModel:GetValue("BE9MASTER","BE9_CODPLA")) + "' "
   cSql += " AND BE9_CODPAD = '"      + alltrim(oModel:GetValue("BE9MASTER","BE9_CODPAD")) + "' "
   cSql += " AND BE9_CODPRO = '"      + alltrim(oModel:GetValue("BE9MASTER","BE9_CODPRO")) + "' "
   cSQL += " AND ( '" + cData + "' >= BE9_VIGDE  OR BE9_VIGDE  = '' ) AND "
   cSQL += "( '" + cData + "' <= BE9_VIGATE OR BE9_VIGATE = '' ) AND "
   cSql += " D_E_L_E_T_ = ' ' "  
   if nOperation == 4  // Proteção contra alterar o proprio registro
    cSql += " AND R_E_C_N_O_  <> '"   + cValToChar(BE9->(RECNO())) + "'"
   endif
   dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"VerRep",.f.,.t.)

            if ( !VerRep->(eof()) )
               Help(nil, nil ,STR0007, nil, STR0009, 1, 0, nil, nil, nil, nil, nil, {STR0010} )//Atenção: Já existe um intervalo de data que compreende a data selecionada. Informe outra data.
                lret := .F.                         
            endif
    VerRep->(DBCloseArea())
Endif     
Return (lRet)

static function PLSTELNEW(nTipo)
local aButtons 	:= {{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,"Confirmar"},{.t.,'Cancelar'},{.t.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.f.,nil}}	

if empty(BBI->BBI_CODLOC) .and. empty(BBI->BBI_CODESP)
    Help(nil, nil , STR0007 , nil, STR0011 , 1, 0, nil, nil, nil, nil, nil, {STR0012} ) //Atenção: Para inserir procedimentos, é necessário existir um Plano vinculado. Cadastre os Planos de Saúde
elseif !empty(BBI->BBI_VIGATE) .and. date() >= BBI->BBI_VIGATE .and. (nTipo ==3 .or. nTipo== 4) 
    Help(nil, nil , STR0007 , nil, STR0013 , 1, 0, nil, nil, nil, nil, nil, {STR0014} ) //Atenção: Plano com vigência encerrada, Para inserir ou alterar procedimentos, é necessário um Plano vigente.
else
    nTipo := iif( valtype(nTipo) != "N", val(nTipo), nTipo )
    FWExecView(cCamLEtxt,'PLSBE9PRO', nTipo,,,,15,aButtons ) 
endif

return

/*//-------------------------------------------------------------------
{Protheus.doc} PLSCMPBE9
Campos que não devem ser exibidos  no form BE9
@since    05/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
static function PLSCMPBE9(cCampo)
Local lRet := .T.

if alltrim(cCampo) $ ("BE9_CODIGO|BE9_DESESP")
	lRet := .F.
endif

return lRet

function inibrwbe9()
local cret := " "
cret := Posicione("BA8",1,xFilial("BA8")+BE9->BE9_CODINT+BE9->BE9_CODTAB+BE9->BE9_CODPAD+BE9->BE9_CODPRO,"BA8_DESCRI")
return cret


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao alterada para MVC  30/07/2020 Thiago Rodrigues                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do campo BE9_CODPRO                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA360BE9(oModel)
local Objbe9 := oModel:Getmodel("BE9MASTER")
local cDescr := " "
local lret := .F.

If empty(Objbe9:getvalue("BE9_CODPRO")) .Or. ExistCpo("BA8",PlsIntPad()+Objbe9:getvalue("BE9_CODTAB")+Objbe9:getvalue("BE9_CODPAD")+Objbe9:getvalue("BE9_CODPRO"))
     cDescr:= Posicione("BA8",1,xFilial("BA8")+Plsintpad()+Objbe9:getvalue("BE9_CODTAB")+Objbe9:getvalue("BE9_CODPAD")+Objbe9:getvalue("BE9_CODPRO"),"BA8_DESCRI")
     Objbe9:setvalue("BE9_DESPRO",cDescr)
     lret := .T.
endif 


If lRet
	PLSGATNIV(Objbe9:getvalue("BE9_CODPAD"),Objbe9:getvalue("BE9_CODPRO"),"BE9",.F.,,,"BE9MASTER")
	Objbe9:setvalue("BE9_NIVEL",BA8->BA8_NIVEL)
Endif

Return(lRet)
