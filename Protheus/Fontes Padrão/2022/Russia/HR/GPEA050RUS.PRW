#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA1050.CH"
#INCLUDE "PONCALEN.CH"

#DEFINE Confirma 1
#DEFINE Redigita 2
#DEFINE Abandona 3

Static lInitDesc
Static lRefTrab := FindFunction("fRefTrab") .And. fRefTrab("F")

/*
{Protheus.doc} GPEA050RUS()
    Russian localization of GPEA050 - Vacation schedule

    @type Function
    @author dtereshenko
    @since 2020/08/06
    @version 12.1.23
*/
Function GPEA050RUS()
Return GPEA050()

/*
{Protheus.doc} MenuDef()
    Menu definition

    @type Function
    @author dtereshenko
    @since 2020/08/06
    @version 12.1.23
*/
Static Function MenuDef()
Return FWLoadMenuDef("GPEA050")

/*
{Protheus.doc} ModelDef()
    Model definition

    @type Function
    @author dtereshenko
    @since 2020/08/06
    @version 12.1.23
*/
Static Function ModelDef()
    Local oStructSRA
    Local oStructSRF
    Local oStructRHI
    Local oModel
    Local bPreRHI := { |oModelGrid, nLine, cAction, cField| gp050DelRHI(oModelGrid, nLine, cAction, cField) }
    Local bPreSRF := { |oModelGrid, nLine, cAction, cField| gp050ChkDel(oModelGrid, nLine, cAction, cField) }
    Local bPost	:= {|oMdl| Gp050PVal(oMdl)}

    oModel:= MpFormModel():New("GPEA050", /*Pre-Validacao*/, /*Pos-Validacao*/, { |oModel| Gp050Commit( oModel ) }/*Commit*/, /*Cancel*/)

    oStructSRA := FWFormStruct(1,"SRA",{|cCampo| AllTrim(cCampo)+"|" $ "RA_FILIAL|RA_MAT|RA_NOMECMP|RA_ADMISSA|"})
    oModel:AddFields("GPEA050_SRA", /*cOwner*/, oStructSRA , /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
    oModel:GetModel("GPEA050_SRA"):SetOnlyView( .T. )
    oModel:GetModel("GPEA050_SRA"):SetOnlyQuery( .T. )

    oStructSRA:SetProperty( 'RA_MAT' 	, MODEL_FIELD_WHEN , {||.F.})
    oStructSRA:SetProperty( 'RA_NOMECMP' 	, MODEL_FIELD_WHEN , {||.F.})
    oStructSRA:SetProperty( 'RA_ADMISSA', MODEL_FIELD_WHEN , {||.F.})


    oStructSRF := FWFormStruct(1,"SRF")
    oStructSRF :SetProperty('RF_DFERANT', MODEL_FIELD_VALID, {|| fValidSRF('RF_DFERANT')	} )

    oModel:AddGrid("GPEA050_SRF", "GPEA050_SRA"/*cOwner*/, oStructSRF , bPreSRF , { |oGrid| gp050LinOk(oGrid) } /* bLinePost*/, { || !(lInitDesc := .F.) }, bPost,/*bLoad*/)
    oModel:GetModel("GPEA050_SRF"):SetOptional(.T.)
    oModel:GetModel("GPEA050_SRF"):SetUniqueLine( { "RF_DATABAS" , "RF_DATAFIM" , "RF_PD" } )

    oStructSRF:SetProperty( 'RF_DESCPD' , MODEL_FIELD_INIT,{|oGrid|If(lInitDesc,FDESC("SRV",If(oGrid:Length()>0,oGrid:GetValue("RF_PD"),SRF->RF_PD),"RV_DESC"),"")})

    oModel:SetRelation("GPEA050_SRF",{{"RF_FILIAL",'xFilial("SRF",SRA->RA_FILIAL)'},{"RF_MAT","RA_MAT"}},SRF->(IndexKey()))

    If HabilitaAba()
        oStructRHI := FWFormStruct(1,"RHI")
        oModel:AddGrid("GPEA050_RHI", "GPEA050_SRA"/*cOwner*/, oStructRHI , bPreRHI/*bLinePre*/, /* bLinePost*/, /*bPre*/, /*bPost*/,/*bLoad*/)
        oModel:GetModel('GPEA050_RHI'):SetOptional(.T.)
        
        oModel:SetRelation("GPEA050_RHI",{{"RHI_FILIAL",'xFilial("RHI")'},{"RHI_MAT","RA_MAT"}},RHI->(IndexKey()))
    EndIf

    oModel:SetVldActivate( { |oModel| Gp050IniMod( oModel,oModel:GetOperation() ) } )

Return oModel

/*
{Protheus.doc} ViewDef()
    View definition

    @type Function
    @author dtereshenko
    @since 2020/08/06
    @version 12.1.23
*/
Static Function ViewDef()
    Local oModel
    Local oView
    Local oStructSRA
    Local oStructSRF
    Local oStructRHI

    oModel := FwLoadModel("GPEA050")

    oView := FWFormView():New()

    oView:SetModel(oModel)

    oStructSRA := FWFormStruct(2,"SRA",{|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOMECMP|RA_ADMISSA|"})
    oStructSRA:SetNoFolder()

    oView:AddField( "GPEA050_SRA" , oStructSRA )

    oStructSRF := FWFormStruct(2,"SRF")
    oView:AddGrid(  "GPEA050_SRF" , oStructSRF )

    oStructSRF:RemoveField( "RF_FILIAL" )
    oStructSRF:RemoveField( "RF_MAT" )
    oStructSRF:RemoveField( "RF_NOME" )
    oStructSRF:RemoveField( "RF_ADMISSA" )

    oView:SetViewProperty("GPEA050_SRA","OnlyView") //Somente visualizacao. Nao permite edicao dos campos do cabecalho (SRA)

    oView:CreateHorizontalBox("FORMFIELD",10)
    oView:CreateHorizontalBox("GRID"     ,90)

    If HabilitaAba() //Cria abas somente se variavel for TRUE, do contrario monta a tela sem utilizacao de abas
        oStructRHI := FWFormStruct(2,"RHI")
        oView:AddGrid(  "GPEA050_RHI" , oStructRHI )
        oStructRHI:RemoveField( "RHI_FILIAL" )
        oStructRHI:RemoveField( "RHI_MAT" )
        oStructRHI:RemoveField( "RHI_NOME" )
        oStructRHI:RemoveField( "RHI_NUMPAG" )
        oStructRHI:RemoveField( "RHI_PROCES" )
        oStructRHI:RemoveField( "RHI_ROTEIR" )
        oStructRHI:RemoveField( "RHI_PERIOD" )
        oStructRHI:RemoveField( "RHI_DTPAGO" )
        oStructRHI:RemoveField( "RHI_DTRECI" )
        oStructRHI:RemoveField( "RHI_SALMES" )
        oStructRHI:RemoveField( "RHI_MARK" )
        oStructRHI:RemoveField( "RHI_TPCALC" )
        oStructRHI:RemoveField( "RHI_ADMISS" )
        
        oView:CreateFolder( 'PASTAS','GRID')
        oView:AddSheet( 'PASTAS', 'ABA01', STR0024 ) //"Contr. Dias Direito"
        oView:AddSheet( 'PASTAS', 'ABA02', STR0025 ) //"Programação de Férias"
        oView:CreateHorizontalBox( 'BOXABA01', 100,,, "PASTAS", "ABA01" )
        oView:CreateHorizontalBox( 'BOXABA02', 100,,, "PASTAS", "ABA02" )
        oView:SetOwnerView( "GPEA050_SRA","FORMFIELD")
        oView:SetOwnerView( "GPEA050_SRF", "BOXABA01" )
        oView:SetOwnerView( "GPEA050_RHI", "BOXABA02" )
    Else
        oView:SetOwnerView( "GPEA050_SRA","FORMFIELD")
        oView:SetOwnerView( "GPEA050_SRF","GRID")
    EndIf

    oView:SetCloseOnOk( { |oView| Gp050ClsOk( oView ) } )

Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Gp050ClsOkºAutor  ³Leandro Drumond     º Data ³  03/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tratamento para o metodo SetCloseOnOk (fechar tela Ok)      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Gp050ClsOk( oView )
    Local nOperation := oView:oModel:GetOperation()
    Local oGrid   	 := oView:oModel:GetModel("GPEA050_SRF")
    Local nLinGrdPos := oGrid:GetLine() //Linha posicionada atualmente no Grid
    Local lRet     	 :=  .F.
    Local aArea    	 := GetArea()
    Local nX  		 := 0

    If nOperation == MODEL_OPERATION_UPDATE
        lRet := .T.
        For nX:=1 to oGrid:GetQtdLine()
            oGrid:GoLine( nX )
            if !oGrid:IsDeleted()	
                lRet := .F.
                Exit
            EndIf
        Next nX
        oGrid:GoLine( nLinGrdPos )
    EndIf

    RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp050DAnt		  ³ Autor ³ Leandro Drumond       ³ Data ³04.02.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verificar se o campo Antecipos poderá ser Editado na Argentina.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gp050DAnt(oModel)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp050VerEdit                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function gp050DAnt(oModel)

    Local lEdit := .F.

    If	oModel:GetValue("GPEA050_SRF","RF_STATUS") == "1" .and. oModel:GetValue("GPEA050_SRF","RF_DFERVAT") == 0 
        lEdit := .T.
    EndIf

Return (lEdit)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³gp050ChkDel   ³Autor³Tatiane Matias       ³ Data ³27/04/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Verifica se o registro pode ser excluido.                   ³
³          ³O registro so podera ser excluido se o Dias Pagos for zero. ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³No bDelOk da oGet     .				                        ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function gp050ChkDel(oModelGrid, nLine, cAction, cField)
    Local lRet := .T.

    If cAction == 'DELETE'
        lRet := !oModelGrid:GetValue("RF_DFERANT") > 0
        If !lRet
            Help( ,,,OemToAnsi(STR0016), OemToAnsi(STR0033), 1, 0 ) //"Atenção"##"Períodos com dias de férias pagos não pode ser excluídos." 
        EndIf
    EndIf

Return lRet

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³gp050DelRHI   ³Autor³Mohanad Odeh         ³ Data ³09/09/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Verifica se o registro pode ser excluido.                   ³
³          ³O registro so podera ser excluido se o Status for 1 ou 2    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Na pre-validacao de linha.				                    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function gp050DelRHI(oModelGrid, nLine, cAction, cField)
    Local lRet := .T.

    If cAction == 'DELETE'
        lRet := oModelGrid:GetValue("RHI_STATUS") $ "1"
    EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Gp050PVal ³ Autor ³ Mohanad Odeh            ³ Data ³ 03/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Gp050PVal()                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Gp050PVal(oModel)
    Local lRet := .T.

    lGp050Auto := If (Type("lGp050Auto") == "U",.F.,lGp050Auto)

    If(!lGp050Auto)
        If !MsgYesNo(STR0037 + chr(13) + chr(10) + STR0038,STR0016) // "Toda e qualquer alteracao feita neste cadastro interferira diretamente no calculo de ferias." ### "Deseja confirmar?" ### Atencao
            Help(" ",1,".GPEA050ALT.") // P: As alterações realizadas não foram consideradas para gravação. S: Para finalizar, selecione o botão 'Fechar' 
            lRet := .F.
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} IntegDef
	Rotina responsável pela Mensagem Única da Rotina GPEA050
@author PHILIPE.POMPEU
@since 14/04/2015
@version P12
@param cXML, character, o XML em forma de string
@param nTypeTrans, numérico, Tipo de Transmissão
@param cTypeMessage, character, Tipo da Mensagem
@param cVerMsg, character, Versão da Mensagem
@return aRet, Vetor
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage,cVerMsg)
	Local aRet := {}
	Default cVerMsg := "1.000"
	aRet:= GPEI050( cXML, nTypeTrans, cTypeMessage, cVerMsg)
Return aRet

/*/{Protheus.doc} HabilitaAba
Verifica se Habilita a Aba, função que substitui a variável Private lHabAba,
Variavel para habilitar a aba de Programação de férias
@author philipe.pompeu
@since 17/04/2015
@version P12
@return lResult, Verdadeiro caso deva ser habilitada.
/*/
Static Function HabilitaAba()
	Local lResult := (cPaisLoc == "DOM") 
Return lResult

Static Function fValidSRF(cCampo)
    Local lRet	:= .T.
    Local oModel:= FWModelActive()

    If !lGp050Auto
        If !MsgYesNo(STR0073 + chr(13) + chr(10) + STR0038,STR0016) //"Verifique se o valor está correto antes de finalizar a alteração, pois o mesmo ficará bloqueado imediatamente após o campo ser atualizado e o valor for superior a 0. ### "Deseja confirmar?" ### Atencao
            lRet := .F.
        EndIf
    Endif

Return lRet
