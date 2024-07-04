#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'topconn.ch'
#include 'PLSA950.CH'


//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSA950
Tela de Informações do PTU A410
@since 03/2020
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSA950(lAutoma)
local cFiltro   := "@(BR4_FILIAL = '" + xFilial("BR4") + "') AND BR4_SEGMEN = '01'"
local oBrowse	:= nil
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BR4')
oBrowse:SetFilterDefault(cFiltro)
oBrowse:SetDescription(STR0001) // Tipo de Tabela Padrão
iif(!lAutoma, oBrowse:Activate(), '')
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@since 03/2020
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title   STR0002 	Action 'VIEWDEF.PLSA950' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title   STR0003  Action "VIEWDEF.PLSA950" 	Operation 3 Access 0  //Incluir
Add Option aRotina Title   STR0004	Action "VIEWDEF.PLSA950" 	Operation 4 Access 0  //Alterar
Add Option aRotina Title   STR0005  Action "VIEWDEF.PLSA950"	Operation 5 Access 0  //Excluir
Add Option aRotina Title 'Vinculo TISS' 		Action "MsgRun('',,{||PLVINCTIS('BR4',BR4->BR4_CODPAD, 1)})" OPERATION 2 ACCESS 0 //Incluir vinculo tiss
Add Option aRotina Title 'Exluir Vinculo TISS' 	Action "MsgRun('',,{||PLVINCTIS('BR4',BR4->BR4_CODPAD, 0)})" OPERATION 2 ACCESS 0 //Excluir vinculo tiss


Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados.
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrBR	:= FWFormModelStruct():New()
Local oStrBR4G	:= FWFormStruct(1,'BR4')
local lAut :=  IIf(type('lAut950')=='U',.F.,lAut950) // Variavel declarada para fins de automação

oModel := MPFormModel():New( 'PLSA950', , { |oModel| PLSCADOK(oModel) },{|oModel| PlsSavMdl(oModel,lAut)}) 
oStrBR:AddField('CODTABELA' , 'Código da Tabela'   , 'CODTABELA' , 'C', 2  , 0, ,{||PlEditC(oModel)}, {}, .F., , .F., .F., .T., , )
oStrBR:AddField('DESCTABELA', 'Descrição da Tabela', 'DESCTABELA', 'C', 100, 0, ,{||PlEditC(oModel)}, {}, .F., , .F., .F., .T., , )
oStrBR:AddField('MASK', 'Máscara do Procedimento', 'MASK', 'C', 100, 0, ,{||.t.}, {}, .F., , .F., .F., .T., , )
oStrBR:AddField('CODTIS', 'Vinc Cd Tiss', 'CODTIS', 'C', 100, 0, ,{||.t.}, {}, .F., , .F., .F., .T., , )
oStrBR:AddField('DESTIS', 'Desc Vinc Cd', 'DESTIS', 'C', 100, 0, ,{||.t.}, {}, .F., , .F., .F., .T., , )
oModel:AddFields( 'MASTERCAB', /*cOwner*/, oStrBR,,,{|oModel|loadCab(oModel)}) 
oModel:AddGrid('BR4Detail', 'MASTERCAB', oStrBR4G,,{||PlVldDigV(oModel)})

oStrBR4G:setProperty( "BR4_DESCRI" , MODEL_FIELD_INIT, { || oModel:getModel('MASTERCAB'):getValue('DESCTABELA')} )
oStrBR4G:setProperty( "BR4_CODPAD" , MODEL_FIELD_INIT, { || oModel:getModel('MASTERCAB'):getValue('CODTABELA')} )
oStrBR4G:setProperty( "BR4_DESCRI" , MODEL_FIELD_WHEN, { || .f.}  )
oStrBR4G:setProperty( "BR4_CODPAD" , MODEL_FIELD_WHEN, { || .f.}  )
oStrBR4G:setProperty( "BR4_DIGITO" , MODEL_FIELD_VALID, {|| MaskCmp(oModel, "1")}  )
oStrBR4G:setProperty( "BR4_SEPARA" , MODEL_FIELD_VALID, {|| MaskCmp(oModel, "1")}  )
oStrBR4G:setProperty( "BR4_SEPARA" , MODEL_FIELD_OBRIGAT, .F. )
oStrBR4G:setProperty( "BR4_CODPAD" , MODEL_FIELD_OBRIGAT, .T. )


oStrBR:setProperty( "CODTABELA" , MODEL_FIELD_VALID, {|| AtuGrid(oModel, .t.)}  )
oStrBR:setProperty( "DESCTABELA", MODEL_FIELD_VALID, {|| AtuGrid(oModel, .f.)}  )

oStrBR:setProperty( "CODTIS" , MODEL_FIELD_WHEN, { || .f.}  )
oStrBR:setProperty( "DESTIS", MODEL_FIELD_WHEN, { || .f.}  )



oModel:SetRelation( 'BR4Detail', { ;
	{ 'BR4_FILIAL'	, 'xFilial( "BR4" )' },;
    { 'BR4_CODPAD'	, 'CODTABELA' }},;
    BR4->( IndexKey(1) ) )

oModel:GetModel( 'BR4Detail' ):setOptional(.t.)

oModel:GetModel('MASTERCAB'):SetDescription(STR0001) // Tipo de Tabela Padrão
oModel:SetDescription(STR0001) 

oModel:SetPrimaryKey( { "BR4_FILIAL", "BR4_CODPAD" } )
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface.
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView 
Local oModel	:= FWLoadModel( 'PLSA950' )
Local oStrBR	:= FWFormViewStruct():New()
Local oStrBR4G	:= FWFormStruct(2,'BR4',{ |cCampo| plsGrdExb(cCampo) })

oView := FWFormView():New()
oView:SetModel( oModel )
oStrBR:AddField( 'CODTABELA' ,'01','Código da Tabela'	,'Código da Tabela'	  ,, 'C' ,"@!",,,,,,,,,.t.,, )
oStrBR:AddField( 'DESCTABELA','02','Descrição da Tabela','Descrição da Tabela',, 'C' ,"@!",,,,,,,,,.t.,, )
oStrBR:AddField( 'MASK','03','Máscara','Máscara',, 'C' ,"@!",,,.f.,,,,,,.t.,, )
oStrBR:AddField( 'CODTIS','04','Vinc Cd Tiss','Vinc Cd Tiss',, 'C' ,"@!",,,.f.,,,,,,.t.,, )
oStrBR:AddField( 'DESTIS','05','Desc Vinc Cd','Desc Vinc Cd',, 'C' ,"@!",,,.f.,,,,,,.t.,, )

oView:AddField( 'VIEW_BR', oStrBR, 'MASTERCAB')
oView:CreateHorizontalBox( 'SUPERIOR', 30)
oView:CreateHorizontalBox( 'BAIXO'	 , 70)

//Grids
oView:AddGrid( 'ViewBR4G', oStrBR4G, 'BR4Detail',,{||VldPreCab(oModel)} )
oView:AddIncrementField( 'ViewBR4G', 'BR4_SEGMEN' )
oView:AddIncrementField( 'ViewBR4G', 'BR4_CODNIV' )

//Título
oView:EnableTitleView('ViewBR4G',STR0012) //Informe a Codificação dos Procedimentos da tabela

oView:SetOwnerView('VIEW_BR', 'SUPERIOR' )
oView:SetOwnerView('ViewBR4G' , 'BAIXO' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCADOK
Valida a inclusão do Registro.
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PLSCADOK(oModel)
Local lRet		:= .T.
Local oGrid     := oModel:getmodel("BR4Detail")
local nLaco     := 1
local nTamGrid  := oGrid:length()

for nLaco := 1 To oGrid:length()
    oGrid:GoLine(nLaco)
    if !( oGrid:IsDeleted() )
        if (nLaco < nTamGrid) .and. empty(oGrid:getValue("BR4_SEPARA"))
            lret := .f.
            Help(nil, nil , STR0006 , nil, 'Na linha: ' + cValtochar(nLaco) +', ' +STR0008, 1, 0, nil, nil, nil,nil,nil,{STR0007})//Atenção na linha // é obrigatório informar o separador .Informe o separador da linha indicada acima.
            oGrid:GoLine(nLaco)            
            exit
        endIf	
            if (nLaco == nTamGrid) .and. !empty(oGrid:getValue("BR4_SEPARA"))
                lret := .f.
                Help(nil, nil , STR0006, nil, 'Na última linha: ' + cValtochar(nLaco) + ', '+ STR0014, 1, 0, nil, nil, nil,nil,nil,{STR0013 })//Atenção na linha // ñ é obrigatório informar o separador. Retire o SEPARADOR da última linha. 
                oGrid:GoLine(nLaco)  
                exit
            endif
    endif    
next nLaco	

Return lRet

//load no GRID
static function atugrid(oModel, lVldRep)
local lRet 	    := .t.
Local oGrid     := oModel:getmodel("BR4Detail")
Local oCab      := oModel:getmodel("MASTERCAB")
local nT        := 1
local nTamGrid  := oGrid:length()
default lVldRep := .f.

if lVldRep
    BR4->(DbSetOrder(1))
    if ( BR4->(DbSeek(xfilial("BR4") + oCab:getvalue("CODTABELA"))) )
        lRet := .f.
        Help(nil, nil , STR0006  , nil, STR0009 , 1, 0, nil, nil, nil, nil, nil, { STR0016 } )//Atenção Esse código está cadastrado no sistema. Informe outro código!
    endif
endif

if lRet
    for nT := 1 to oGrid:length()
        oGrid:GoLine( nT )
        if empty(oGrid:getvalue("BR4_CODPAD")) .or. (oGrid:getvalue("BR4_CODPAD") != oCab:getvalue("CODTABELA"))
            oGrid:loadvalue("BR4_CODPAD", oCab:getvalue("CODTABELA")) 
        endif
        if empty(oGrid:getvalue("BR4_DESCRI")) .or. (oGrid:getvalue("BR4_DESCRI") != oCab:getvalue("DESCTABELA"))
            oGrid:loadvalue("BR4_DESCRI", allTrim(oCab:getvalue("DESCTABELA"))) 
        endif 

        if (nT < nTamGrid) .and. oGrid:getvalue("BR4_DIGVER") != '0'
            oGrid:loadvalue("BR4_DIGVER", '0')
        endif     
    next 
endif  
return lRet    

//valida cabeçalho
static function VldPreCab(oModel)
Local oCab  := oModel:getmodel("MASTERCAB")
local lRet  := .t.

if ( empty(oCab:getvalue("CODTABELA")) .or.  empty(oCab:getvalue("DESCTABELA")) )
    lRet := .f.
    Help(nil, nil ,STR0006 , nil, STR0010 , 1, 0, nil, nil, nil, nil, nil, nil ) // Atenção Obrigatório preencher o código da tabela e descrição
ENDIF

return lRet


//1 - Model, 2 - Load
static function MaskCmp(oModel, cTipo, cTab)
local nLaco := 0
local nTamMax := Len(CriaVar("BA8_CODPRO"))
local lRet := .t.
local oGrid := oModel:getmodel("BR4Detail")
local oCab  := oModel:getmodel("MASTERCAB")
local cConta 	:= ""
local nTamConta := 0
local aHelp := {'', '', ''}
local aAreaBR4 := BR4->(getarea())
Local aSaveLines  := FWSaveRows()
default cTab := "01"

if ( cTipo == "1" )
    for nLaco := 1 To oGrid:length()
        oGrid:GoLine(nLaco)
        if !( oGrid:IsDeleted() )
            cConta 		+= Replicate("9",Val(oGrid:getValue("BR4_DIGITO")))
            nTamConta	+= Val(oGrid:getValue("BR4_DIGITO"))
            cConta 		+= oGrid:getValue("BR4_SEPARA")
        endIf	
    next nLaco	

FWRestRows(aSaveLines)

    if nTamConta > nTamMax
        Help(nil, nil , STR0006, nil, STR0011, 1, 0, nil, nil, nil, nil, nil, nil )//Atenção campo maior que a codificação
        lRet := .F.
    endIf 
else
    BR4->(DbSetOrder(1))
	if BR4->(DbSeek(xfilial("BR4") + cTab) )
		While !(BR4->(EoF())) .and. BR4->(BR4_FILIAL+BR4_CODPAD) == xfilial("BR4") + cTab
            cConta 		+= Replicate("9",Val(BR4->BR4_DIGITO))
            nTamConta	+= Val(BR4->BR4_DIGITO)
            cConta 		+= BR4->BR4_SEPARA

            BR4->(DbSkip())
        enddo 
    else
        lRet := .f.
        aHelp := {'Carrega', 'erro', 'solução'}
    endif
endif    

If lRET .and. cTipo == '1'
    oCab:loadvalue("MASK", cConta)
EndIf

BR4->(RestArea(aAreaBR4))

return iif(cTipo == "1", lRet, cConta)


//Carrega o cabeçalho
static function loadCab(oModel)
Local aLoad     := {}
local cCodPad   := BR4->BR4_CODPAD
local cDescri   := BR4->BR4_DESCRI

//Realizar De/Para nos campos vinculados a tiss utilizando PLSGETVINC // Thiago rodrigues 2020
//PLSGETVINC (cColuna, cAlias, lMsg, cCodTab , cVlrTiss, lPortal, aTabDup, cPadBkp )
local cCodtis   := PLSGETVINC("BTU_CDTERM", "BR4",.F., "25")
local cDestis   := PLSGETVINC("BTQ_DESTER", "BR4",.F.,"25") 

aAdd(aLoad, {cCodPad, cDescri, MaskCmp(oModel, '2', cCodPad),cCodtis,cDestis}) 
aAdd(aLoad, 1)
      
Return aLoad


//Valida edição
static function PlEditC(oModel)
local lPodEdit := iif(oModel:getOperation() == MODEL_OPERATION_INSERT, .t., .f.)
return lPodEdit

//Valida digito verificador
Static function PlVldDigV(oModel)
local lRet := .T.
local oGrid := oModel:getmodel("BR4Detail")
local nlaco :=1
local nTamGrid := oGrid:length()

for nlaco:=1 To oGrid:length()
 oGrid:GoLine(nLaco)
    if  nlaco < nTamGrid
        oGrid:SetValue("BR4_DIGVER", "0")
    endif
next  nlaco    
return lret

//Oculta os campos fake do grid
static function plsGrdExb(cCampo)
Local lRet := .T.

if alltrim(cCampo) $ 'BR4_CODTIS,BR4_DESTIS'
	lRet := .F.
endif

return lRet


//PlsSavMdl
//Realiza o Commit  em outra model, na mesma ocorria erro por conta dos campos fake
// Thiago rodrigues 18/03/2020
// Chama o fonte PLSA950
Static Function PlsSavMdl(oModel,lautoma)
Local oModelIte := FWLoadModel('PLSA950B')  //Instancia o modelo de dados
local nOperation := oModel:getOperation()
local nl := 1               //Contador          
local cCODTAB :=""          //BR4_CODPAD
local cDescri :=""          //BR4_DESCRI
local cSegmen :=""          //BR4_SEGMEN
local cDig    :=""          //BR4_DIGITO
local csepar  :=""          //BR4_SEPARA
local ccodniv :=""          //BR4_CODNIV
local cdigver :=""          //BR4_DIGVER
local cbrdescr:=""          //BR4_DESC
local oGrid := oModel:getmodel("BR4Detail")
local nTamGrid := oGrid:length()
local cSql :=""
local cCodP  := oModel:getModel("BR4Detail"):getValue("BR4_CODPAD")
local lret := .T.
local cVlrTab   := "00,18,19,20,22,90,98"
Local oCab      := oModel:getmodel("MASTERCAB")
local nUsado := 0
Default lAutoma  :=.F.
Begin transaction

oModelIte:SetOperation( 3 )
oModelIte:Activate()

    if nOperation == 3     //incluir 
        for nl :=1 To nTamGrid
            omodel:getmodel("BR4Detail"):Goline(nl)
		
           cCODTAB := oModel:getmodel("BR4Detail"):getvalue("BR4_CODPAD")  //Pega o valor do campo no model atual
           oModelIte:getmodel("MasterBR4"):setvalue("BR4_CODPAD",cCODTAB) //Atribui a variavel no model criado para salvar o grid

            cDescri := oModel:getmodel("BR4Detail"):getvalue("BR4_DESCRI")
            oModelIte:getmodel("MasterBR4"):setvalue("BR4_DESCRI",cDescri)

            cSegmen := oModel:getmodel("BR4Detail"):getvalue("BR4_SEGMEN")
            oModelIte:getmodel("MasterBR4"):setvalue("BR4_SEGMEN",cSegmen)

            cDig := oModel:getmodel("BR4Detail"):getvalue("BR4_DIGITO")
            oModelIte:getmodel("MasterBR4"):setvalue("BR4_DIGITO",cDig)

            cbrdescr := oModel:getmodel("BR4Detail"):getvalue("BR4_DESC")
            oModelIte:getmodel("MasterBR4"):setvalue("BR4_DESC",cbrdescr)

            csepar := oModel:getmodel("BR4Detail"):getvalue("BR4_SEPARA")
            oModelIte:getmodel("MasterBR4"):setvalue("BR4_SEPARA",csepar)

            ccodniv := oModel:getmodel("BR4Detail"):getvalue("BR4_CODNIV")
            oModelIte:getmodel("MasterBR4"):setvalue("BR4_CODNIV",ccodniv)

            cdigver := oModel:getmodel("BR4Detail"):getvalue("BR4_DIGVER")
            oModelIte:getmodel("MasterBR4"):setvalue("BR4_DIGVER",cdigver)         

            If (oModelIte:VldData() )
            // Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
                oModelIte:CommitData()

                //Vincular a tiss  tabela BTU
                    
                if lret .and. !(oCab:getvalue("CODTABELA") $ (cVlrTab) ) .and. nUsado ==0 .and. !lAutoma
                         PLVINCTIS('BR4', oCab:getvalue("CODTABELA"), 1)
                         nUsado:=1
                endif
            else
            // Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
            aErro := oModelIte:GetErrorMessage()
            // A estrutura do vetor com erro é:
            // [1] identificador (ID) do formulário de origem
            // [2] identificador (ID) do campo de origem
            // [3] identificador (ID) do formulário de erro
            // [4] identificador (ID) do campo de erro
            // [5] identificador (ID) do erro
            // [6] mensagem do erro
            // [7] mensagem da solução
            // [8] Valor atribuído
            // [9] Valor anterior
            AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1] ) + ']' )
            AutoGrLog( "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' )
            AutoGrLog( "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']' )
            AutoGrLog( "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' )
            AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
            AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
            AutoGrLog( "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' )
            AutoGrLog( "Valor atribuído: " + ' [' + AllToChar( aErro[8] ) + ']' )
            AutoGrLog( "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']')
            MostraErro()
            EndIf   
            oModelIte:DeActivate()
            oModelIte:Destroy()
            oModelIte := nil
            oModelIte := FWLoadModel( 'PLSA950B' )
            oModelIte:SetOperation( 3 )
            oModelIte:Activate() 
        next nl         
    elseif nOperation == 5    
            oModelIte:DeActivate()
            oModelIte:Destroy()
            oModelIte := nil
            oModelIte := FWLoadModel( 'PLSA950B' )
            oModelIte:SetOperation( 5 )
            oModelIte:Activate() 

   cSql := " SELECT BF8_CODPAD FROM " + RetSqlName("BF8") 
   cSql += " WHERE BF8_FILIAL = '"    + xFilial("BF8") + "' "
   cSql += " AND BF8_CODPAD =  '"     + alltrim(cCodP) + "' " 
   cSql += " AND D_E_L_E_T_ = ' ' "   

   dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"VerRep",.f.,.t.)

        if ( !VerRep->(eof()) )
            lRet := .f.
        oModel:SetErrorMessage("Tipo de tabela padrão","Excluir" ,"","",STR0006,STR0015)
        endif 

        if lret
            If (oModelIte:VldData() )
            // Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
               oModelIte:CommitData()
               FWFormCommit( oModel )  

                        //Opção de excluir o vinculo da tiss
                  if lret .and. !(oCab:getvalue("CODTABELA") $ (cVlrTab)) .and. !lAutoma
                         PLVINCTIS('BR4', oCab:getvalue("CODTABELA"), 0)
                  Endif
            endif
         Endif            
        VerRep->(dbclosearea()) 
    else //Operação Alterar
        FWFormCommit( oModel )   
    Endif
End Transaction
Return lret

