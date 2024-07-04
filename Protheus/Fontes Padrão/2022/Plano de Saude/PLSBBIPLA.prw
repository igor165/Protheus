#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'topconn.ch'
#include 'PLSBBIPLA.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@since 09/2019
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  STR0003 	Action 'staticCall(PLSBBIPLA, PlsTelNew, 1)' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0004  	Action "staticCall(PLSBBIPLA, PlsTelNew, 3)" 	Operation 3 Access 0  //Incluir
Add Option aRotina Title  STR0005 	Action "staticCall(PLSBBIPLA, PlsTelNew, 4)"  	Operation 4 Access 0  //Alterar
Add Option aRotina Title  STR0006	Action "VIEWDEF.PLSBBIPLA"                  	Operation 5 Access 0  //Excluir

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
Local oStrBBI	:= FWFormStruct(1,'BBI')
local lAutoma :=  IIf(type('lAutBBIPL')=='U',.F.,lAutBBIPL) // Variavel declarada para fins de automação


oModel := MPFormModel():New( 'PLSBBIPLA',,{|| Vldexcl(oModel) }) 


oModel:AddFields( 'BBIMASTER', /*cOwner*/, oStrBBI )
oModel:GetModel( 'BBIMASTER' ):SetDescription(STR0001) //Plano de Saúde - Informações

//inicializador padrão
IF lAutoma //Foi necessário declarar dessa forma, pois na automaçao essas variveis vem vazias 
    oStrBBI:SetProperty( 'BBI_CODLOC' , MODEL_FIELD_INIT, { || '001'} )
    oStrBBI:SetProperty( 'BBI_CODESP' , MODEL_FIELD_INIT, { || '002'} )
    oStrBBI:SetProperty( 'BBI_CODSUB' , MODEL_FIELD_INIT, { || ''} )
    oStrBBI:SetProperty( 'BBI_CODINT' , MODEL_FIELD_INIT, { || plsintpad()} )
    oStrBBI:SetProperty( 'BBI_CODIGO' , MODEL_FIELD_INIT, { || '000004'} )

else
    oStrBBI:SetProperty( 'BBI_CODLOC' , MODEL_FIELD_INIT, { || cPVLocBBI} )
    oStrBBI:SetProperty( 'BBI_CODESP' , MODEL_FIELD_INIT, { || cPVEspBBI} )
    oStrBBI:SetProperty( 'BBI_CODSUB' , MODEL_FIELD_INIT, { || cPVEspSBBI} )
    oStrBBI:SetProperty( 'BBI_CODINT' , MODEL_FIELD_INIT, { || plsintpad()} )
    oStrBBI:SetProperty( 'BBI_CODIGO' , MODEL_FIELD_INIT, { || cRdaBAUB} )
endif

oStrBBI:SetProperty( 'BBI_DESPRO' , MODEL_FIELD_TAMANHO, 300 )

//Validação 
oStrBBI:SetProperty( 'BBI_CODPRO' , MODEL_FIELD_VALID, { ||VldCodPro(oModel)})
oStrBBI:SetProperty( 'BBI_VERSAO' , MODEL_FIELD_VALID, { ||ExistCpo("BI3",PlsIntPad()+oModel:Getmodel("BBIMASTER"):getvalue("BBI_CODPRO")+oModel:Getmodel("BBIMASTER"):getvalue("BBI_VERSAO"))})
oStrBBI:SetProperty( 'BBI_VIGDE' ,  MODEL_FIELD_VALID, { ||PLVldVi(oModel,1) })
oStrBBI:SetProperty( 'BBI_VIGATE' , MODEL_FIELD_VALID, { ||PLVldVi(oModel,2) })
oStrBBI:SetProperty( 'BBI_TABPRE' , MODEL_FIELD_VALID, { ||VldTabPre(oModel) })

//Obrigatorios
oStrBBI:SetProperty( 'BBI_VIGDE' , MODEL_FIELD_OBRIGAT, .T. )


oModel:SetPrimaryKey( { "BBI_FILIAL", "BBI_CODIGO", "BBI_CODINT", "BBI_CODLOC", "BBI_CODESP", "BBI_CODSUB", "BBI_CODPRO", "BBI_VERSAO" } )
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
Local oModel	:= FWLoadModel( 'PLSBBIPLA' ) // Cria as estruturas a serem usadas na View
Local oStrBBI	:= FWFormStruct(2,'BBI',{|cCampo| PLSCMPBBI(cCampo)})

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_BBI', oStrBBI, 'BBIMASTER' )
oView:CreateHorizontalBox( 'SUPERIOR', 100 )
oView:SetOwnerView( 'VIEW_BBI', 'SUPERIOR' )

Return oView


static function PLSTELNEW(nTipo)
local aButtons 	:= {{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,"Confirmar"},{.t.,'Cancelar'},{.t.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.f.,nil}}	

nTipo := iif( valtype(nTipo) != "N", val(nTipo), nTipo )
FWExecView(cCamLEtxt,'PLSBBIPLA', nTipo,,,,10,aButtons ) 

return


/*/******************Valida vigência***********************
Parametros: nTipo == 1   VIGDE || nTipo == 2   VIGATE
Thiago Rodrigues 28/07/2020*
/*/
Static Function PLVldVi(oModel,nTipo)
Local lRet       := .T.
local cSql       :=""
local cData      := iif(nTipo==1,dtos(oModel:GetValue("BBIMASTER","BBI_VIGDE")),dtos(oModel:GetValue("BBIMASTER","BBI_VIGATE")))           
local nOperation := oModel:getOperation()

//Verifico se a vigência final é maior que a inicial.
If !Empty(oModel:GetValue("BBIMASTER","BBI_VIGATE")) .and. oModel:GetValue("BBIMASTER","BBI_VIGDE") > oModel:GetValue("BBIMASTER","BBI_VIGATE")
    Help(nil, nil ,STR0007, nil, STR0008, 1, 0, nil, nil, nil, nil, nil, {STR0010} )//Atenção: Vigência Inicial não pode ser maior que a Final. Informe outra data.
        lRet := .F.
EndIf

if lRet
    //Verifico se já existe uma vigência em aberto
   cSql := " SELECT BBI_VIGDE,BBI_VIGATE FROM " + RetSqlName("BBI") 
   cSql += " WHERE BBI_FILIAL = '"    + xFilial("BBI") + "' "
   cSql += " AND BBI_CODIGO =  '"     + alltrim(oModel:GetValue("BBIMASTER","BBI_CODIGO")) + "' " 
   cSql += " AND BBI_CODINT = '"      + alltrim(oModel:GetValue("BBIMASTER","BBI_CODINT")) + "' "
   cSql += " AND BBI_CODLOC = '"      + alltrim(oModel:GetValue("BBIMASTER","BBI_CODLOC")) + "' "
   cSql += " AND BBI_CODESP = '"      + alltrim(oModel:GetValue("BBIMASTER","BBI_CODESP")) + "' "
   cSql += " AND BBI_CODPRO = '"      + alltrim(oModel:GetValue("BBIMASTER","BBI_CODPRO")) + "' "
   cSQL += " AND ( '" + cData + "' >= BBI_VIGDE OR BBI_VIGDE  = '' ) AND "
   cSQL += "( '" + cData + "' <= BBI_VIGATE OR BBI_VIGATE = '' ) AND "
   cSql += " D_E_L_E_T_ = ' ' "  
   if nOperation == 4  // Proteção contra alterar o proprio registro
    cSql += " AND R_E_C_N_O_  <> '"   + cValToChar(BBI->(RECNO())) + "'"
   endif
   dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"VerRep",.f.,.t.)

            if ( !VerRep->(eof()) )
                 Help(nil, nil ,STR0007, nil, STR0009, 1, 0, nil, nil, nil, nil, nil, {STR0010} )//Atenção: Já existe um intervalo de data que compreende a data selecionada. Informe outra data.
                lret := .F.                         
            endif
    VerRep->(DBCloseArea())
endif


if lret .and. nOperation == MODEL_OPERATION_UPDATE .and. nTipo ==2
    
    if !Empty(oModel:Getmodel("BBIMASTER"):getvalue("BBI_VIGATE"))
        Help(nil, nil ,STR0007, nil, STR0011, 1, 0, nil, nil, nil, nil, nil, {} )//"Atenção: Ao finalizar a vigência do plano, todos os procedimentos também serão finalizados.
    else 
        Help(nil, nil ,STR0007, nil, STR0012, 1, 0, nil, nil, nil, nil, nil, {} )//"Atenção: Ao reabrir a vigência, todos os procedimentos serão reabertos"
    endif
endif

Return(lRet)


/*//-------------------------------------------------------------------
{Protheus.doc} PLSCMPBBI
Campos que não devem ser exibidos  no form BNN
@since    07/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
static function PLSCMPBBI(cCampo)
Local lRet := .T.

if alltrim(cCampo) $ "BBI_CODIGO"
	lRet := .F.
endif

return lRet

/*//-------------------------------------------------------------------
{Protheus.doc} VldTabPre
Verifica se  existe BBI_TABPRE e faz load na descrição
@since    08/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
Static Function VldTabPre(oModel)
local Objbbi := oModel:Getmodel("BBIMASTER")
local cDescr := " "
local lret := .F.

If empty(Objbbi:getvalue("BBI_TABPRE")) .Or. ExistCpo("B22",PlsIntPad()+oModel:Getmodel("BBIMASTER"):getvalue("BBI_TABPRE"))
     cDescr:= posicione('B22', 1, xFilial("B22")+Objbbi:getvalue("BBI_CODINT")+Objbbi:getvalue("BBI_TABPRE"),"B22_DESCRI")
     Objbbi:setvalue("BBI_DESTAB",cDescr)
     lret := .T.
endif 

Return lret

/*//-------------------------------------------------------------------
{Protheus.doc} Vldexcl
faz a exclusão do procedimento relacionado ao plano.
Gera B7O se o plano foi alterado para Ativo == Não ou a data final preenchida for menor que a data atual
@since    08/2020
Thiago Rodrigues
//-------------------------------------------------------------------*/
static function Vldexcl(oModel)
local cSql   :=" "
local lret   :=.T.
local cQuery :=""
local fieldBE9  := BE9->(FieldPos("BE9_SEQUEN")) > 0
local fieldBBI  := BBI->(FieldPos("BBI_SEQUEN")) > 0

if oModel:getOperation() == MODEL_OPERATION_DELETE

    //Atualizar para deletado os registros BE9 que pertencem ao BB8 deletado
    BEGIN TRANSACTION
        cSql := " Select  R_E_C_N_O_ Rec FROM " + RetSqlName("BE9") 
        cSql += " WHERE "
        cSql += "   BE9_FILIAL = '" + xFilial("BE9") + "' "
        cSql += "   AND BE9_CODIGO = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_CODIGO") + "' "
        cSql += "   AND BE9_CODINT = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_CODINT") + "' "
        cSql += "   AND BE9_CODLOC = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_CODLOC") + "' "
        cSql += "   AND BE9_CODESP = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_CODESP") + "' "
        cSql += "   AND BE9_CODSUB = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_CODSUB") + "' "
        cSql += "   AND BE9_CODGRU = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_CODGRU") + "' "
        cSql += "   AND BE9_CODPLA = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_CODPRO") + "' "
        if fieldBE9 .and. fieldBBI
        cSql += "   AND BE9_SEQUEN = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_SEQUEN") + "' " 
        endif
        cSql += "   AND D_E_L_E_T_ = ' ' " 

        dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"aArea",.f.,.t.)

        while ( !aArea->(eof()) )
            BE9->(DBGoTo(aArea->Rec))
            BE9->(Reclock("BE9",.F.))
            BE9->(DBDelete())
            BE9->(msunlock())
            aArea->(DBSkip())
        enddo
   
         aArea->(DBCloseArea())

        PlsGerB7O(oModel:getmodel("BBIMASTER"):getvalue("BBI_CODPRO"),oModel:getmodel("BBIMASTER"):getvalue("BBI_CODLOC"),oModel:getmodel("BBIMASTER"):getvalue("BBI_CODESP"),DATE())
      
    END TRANSACTION

elseif oModel:getOperation() == MODEL_OPERATION_UPDATE

    If oModel:Getmodel("BBIMASTER"):getvalue("BBI_ATIVO") == '0' .or. date() < oModel:Getmodel("BBIMASTER"):getvalue("BBI_VIGATE")	
        PlsGerB7O(oModel:getmodel("BBIMASTER"):getvalue("BBI_CODPRO"),oModel:getmodel("BBIMASTER"):getvalue("BBI_CODLOC"),;
        oModel:getmodel("BBIMASTER"):getvalue("BBI_CODESP"),iif(!empty(oModel:Getmodel("BBIMASTER"):getvalue("BBI_VIGATE")),oModel:Getmodel("BBIMASTER"):getvalue("BBI_VIGATE"),DATE()))
    endif

    //Se o BBI_VIGATE foi alterado altera também o BE9_VIGATE
    if oModel:getmodel('BBIMASTER'):IsFieldUpdated("BBI_VIGATE")
        cQuery := " Select  R_E_C_N_O_ Rec FROM " + RetSqlName("BE9") 
        cQuery += " WHERE "
        cQuery += "   BE9_FILIAL = '" + xFilial("BE9") + "' "
        cQuery += "   AND BE9_CODIGO = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_CODIGO") + "' "
        cQuery += "   AND BE9_CODINT = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_CODINT") + "' "
        cQuery += "   AND BE9_CODLOC = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_CODLOC") + "' "
        cQuery += "   AND BE9_CODESP = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_CODESP") + "' "
        cQuery += "   AND BE9_CODSUB = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_CODSUB") + "' "
        cQuery += "   AND BE9_CODGRU = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_CODGRU") + "' "
        cQuery += "   AND BE9_CODPLA = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_CODPRO") + "' "
        if fieldBE9 .and. fieldBBI
        cQuery += "   AND BE9_SEQUEN = '" + oModel:Getmodel("BBIMASTER"):getvalue("BBI_SEQUEN") + "' "
        endif 
        cQuery += "   AND D_E_L_E_T_ = ' ' " 

        dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cQuery)),"AreaBE9",.f.,.t.)

        while ( !AreaBE9->(eof()) )
            BE9->(DBGoTo(AreaBE9->Rec))
            if empty(BE9->BE9_VIGATE) .OR. BE9->BE9_VIGATE > oModel:Getmodel("BBIMASTER"):getvalue("BBI_VIGATE")
                BE9->(Reclock("BE9",.F.))
                BE9->BE9_VIGATE := oModel:Getmodel("BBIMASTER"):getvalue("BBI_VIGATE")
                BE9->(msunlock())
            endif
            AreaBE9->(DBSkip())
        enddo

        AreaBE9->(DBCloseArea())
    endif

Endif
return lret

static function VldCodPro(oModel)
local lret  := .F. 
local cDesc := ""
local Objbbi := oModel:Getmodel("BBIMASTER")

If empty(Objbbi:getvalue("BBI_CODPRO")) .Or. ExistCpo("BI3",PlsIntPad()+Objbbi:getvalue("BBI_CODPRO")) 
    cDesc := Posicione("BI3",1,xFilial("BI3")+PlsIntPad()+Objbbi:getvalue("BBI_CODPRO"),"BI3_DESCRI")
    Objbbi:setvalue("BBI_DESPRO",cDesc)
    lret := .T.
Endif

return lret 


/*/{Protheus.doc} PlsGerB7O
    Gera B7O referente aos planos
    @type  Static Function
    @author Thiago Rodrigues
    @since 08/2020
    @version p12
    @param codigo do plano, colodigo do local, codigo da especialidade, data 
    /*/
 Static Function PlsGerB7O(cCodpla,cCodloc,cCodEsp,cData)
 local cPlaExc := ""

B7O->(DbSetOrder(3)) // B7O_FILIAL+B7O_CODRDA+B7O_NVEXC+B7O_PLAEXC
BI3->(DbSetOrder(1)) // BI3_FILIAL, BI3_CODINT, BI3_CODIGO, BI3_VERSAO

if BI3->(dbSeek(xFilial('BI3') + PlsIntPad() + cCodpla )) 
    if !empty(BI3->BI3_SCPA)
        cPlaExc := BI3->BI3_SCPA
    elseif !empty(BI3->BI3_SUSEP)
        cPlaExc := BI3->BI3_SUSEP
    else
        cPlaExc := cCodpla
    endif
else
        cPlaExc := cCodpla
endif
		
    lUpdB7O := !(B7O->(dbSeek(xFilial('B7O')+BAU->BAU_CODIGO + '06' + AllTrim(cPlaExc))))
				
    B7O->(RecLock('B7O', lUpdB7O))
        B7O->B7O_FILIAL := xFilial('B7O')
        B7O->B7O_CODRDA := BAU->BAU_CODIGO			
        B7O->B7O_NVEXC 	:= '06'
        B7O->B7O_REDEXC	:= ""
        B7O->B7O_ENDEXC	:= substr(cCodloc,2,2)			
        B7O->B7O_PLAEXC	:= cPlaExc							
        B7O->B7O_DTBLOQ := cData				
    B7O->(MsUnlock())
						
Return 

