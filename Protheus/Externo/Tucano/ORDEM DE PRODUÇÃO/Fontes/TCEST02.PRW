#INCLUDE "FWBROWSE.CH"
#Include 'FWMVCDef.ch'
#Include "TOTVS.CH"
#include "Fileio.ch"
#include "TryException.ch"

/* 
	Igor Gomes Oliveira 
	Emp: Tucano 
	Data: 14/05/2024 
	v.1
*/

Static cDescription := "Teor de Matéria seca Padrão do Milho em Grãos"

User Function TCEST02()
	Private cTipoReg 	:= ''
	Private oBrowse 	:= FWMBrowse():New()
	Private aSeek 		:= {}
    Private cTitulo     := 'Teor de Matéria seca Padrão do Milho em Grãos'
    Private cLogFile    := ""

    GeraX1("TCEST02")

	oBrowse:SetDescription(cDescription)
	oBrowse:SetAlias("ZTM")
	oBrowse:SetMenuDef("TCEST02")
    oBrowse:AddFilter('Default',"ZTM->ZTM_ITEM == '000001' ",.F.,.T.)
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetDBFFilter(.T.)

	oBrowse:Activate()
Return Nil

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Incluir' 			ACTION 'ViewDEF.TCEST02' 	 OPERATION MODEL_OPERATION_INSERT   ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar' 			ACTION 'ViewDEF.TCEST02' 	 OPERATION MODEL_OPERATION_UPDATE   ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' 		ACTION 'ViewDEF.TCEST02' 	 OPERATION MODEL_OPERATION_VIEW   	ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir' 			ACTION 'ViewDEF.TCEST02' 	 OPERATION MODEL_OPERATION_DELETE   ACCESS 0

Return aRotina

Static Function ModelDef()
	Local oModel    := NIL
	Local oStPai    := FWFormStruct(1, 'ZTM')
	Local oStFilho  := FWFormStruct(1, 'ZTM')
	Local aZTMRel  	:= {}
    Local bVldCom  	:= {|| u_SaveZTM()}

    oModel    := MPFormModel():New("MDTCEST02",,,bVldCom)

	oStPai:SetProperty('ZTM_CODIGO', MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_TC02INI()'))//Iniciador de Campo

	oModel:AddFields("FORMCAB" , /*cOwner*/,oStPai, /* {|oModel| ValidModel()} */)
	oModel:AddGrid("FORMGRID", 'FORMCAB',oStFilho , /* {|oModel| ValidModel()} */)

    aAdd(aZTMRel, {'ZTM_FILIAL', 'Iif(!INCLUI, ZTM->ZTM_FILIAL, FWxFilial("ZTM"))'} )
	aAdd(aZTMRel, {'ZTM_CODIGO', 'Iif(!INCLUI, ZTM->ZTM_CODIGO   , "")'} )

	oModel:SetDescription(cDescription)

    oModel:SetRelation('FORMGRID', aZTMRel, ZTM->(IndexKey(2)))
	
	oModel:SetPrimaryKey({"ZTM_FILIAL","ZTM_CODIGO","ZTM_ITEM"})

    oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("FORMCAB"):SetDescription("Formulário do Cadastro "+cTitulo)
	oModel:GetModel("FORMGRID"):SetDescription("Grid do Cadastro "+cTitulo)

Return oModel

Static Function ViewDef()
	Local oModel 	:= ModelDef()
	Local oView  	:= FWFormView():New()
	Local oStPai 	:= FWFormStruct(2, 'ZTM')
	Local oStFilho 	:= FWFormStruct(2, 'ZTM')

	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB" , oStPai    ,"FORMCAB")
	oView:AddGrid("VIEW_ITENS", oStFilho  ,"FORMGRID")

    oView:CreateHorizontalBox('CABEC', 25)
	oView:CreateHorizontalBox('GRID' , 75)

    oView:SetOwnerView('VIEW_CAB'  ,'CABEC')
	oView:SetOwnerView('VIEW_ITENS','GRID' )

	oView:EnableTitleView('VIEW_CAB',"Cabeçalho - "+cTitulo+"")
	oView:EnableTitleView('VIEW_ITENS',"Itens - "+cTitulo+"")

    oView:AddIncrementField( 'VIEW_ITENS', 'ZTM_ITEM' )

	oView:SetCloseOnOk( { |oView| .T. } )

	//oView:AddUserButton( 'Importar arquivo' 		,'', {|oView| Importacao()} )
	oView:AddUserButton( 'Definir Intervalo (F10)'			,'', {|oView| ProcIntervalo()} )
	oView:AddUserButton( 'Alterar valor de cálculo (F11)'	,'', {|oView| AltParam()} )

	SetKey( VK_F10, {|| ProcIntervalo()} )
	SetKey( VK_F11, {|| AltParam()} )

	oStPai:RemoveField('ZTM_ITEM')
	oStPai:RemoveField('ZTM_PERUMI')
	oStPai:RemoveField('ZTM_PRMILH')
	oStPai:RemoveField('ZTM_TEORMS')

	oStFilho:RemoveField('ZTM_FILIAL')
	oStFilho:RemoveField('ZTM_CODIGO')
	oStFilho:RemoveField('ZTM_DATA')
	oStFilho:RemoveField('ZTM_DESCRI')
	oStFilho:RemoveField('ZTM_MSBLQL')

Return oView

User Function SaveZTM()
    Local aArea      	:= GetArea()
	Local lRet       	:= .T.
	Local oModel	  	:= FWModelActive()
    Local oCab          := oModel:GetModel("FORMCAB")
    Local oGrid         := oModel:GetModel("FORMGRID")
	Local nOpc       	:= oModel:GetOperation()
	Local nI         	:= 0
	Local lRecLock   	:= .T.
	Local nLinhas	 	:= oGrid:GetQtdLine()

	
	DbSelectArea('ZTM')
	ZTM->(DbSetOrder(1))
	
	for nI := 1 to nLinhas
		oGrid:GoLIne(nI)
		if !oGrid:isDeleted()
			if oGrid:GetValue("ZTM_PERUMI") == 0 .OR. oGrid:GetValue("ZTM_PRMILH") == 0 
				oModel:SetErrorMessage("","","","","HELP", 'Linha ' + cValToChar(nI) + ' com quantidade zerada', "Verifique a Quantidade ou Apague a linha")
				Return .F. 
			endif
		endif
	next

	//Se for InclusÃ£o
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE

		IF Empty(oCab:GetValue("ZTM_DATA"))
			oModel:SetErrorMessage("","","","","HELP", 'Campo data está vazio', "Verifique o campo Data no cabeçalho")
			Return .F. 
		elseif Empty(oCab:GetValue("ZTM_DESCRI"))
			oModel:SetErrorMessage("","","","","HELP", 'Campo Descrição está vazio', "Verifique o campo Descrição no cabeçalho")
			Return .F. 
		endif 

		if Empty(oModel:GetValue("FORMCAB", "ZTM_CODIGO"))
			oModel:LoadValue("FORMCAB", "ZTM_CODIGO", u_TC02INI())
		ENDIF

		//Cria o registro na tabela 00 (CabeÃ§alho de tabelas)
        For nI := 1 To nLinhas
            oGrid:GoLine(nI)
            If !oGrid:isDeleted()
                RecLock('ZTM', lRecLock := !DbSeek( fwxFilial("ZTM") +;
                                            oCab:GetValue('ZTM_CODIGO') +;
                                            oGrid:GetValue('ZTM_ITEM')))

                    ZTM->ZTM_FILIAL    	:= fwxFilial("ZTM")
                    ZTM->ZTM_CODIGO 	:= oCab:GetValue('ZTM_CODIGO') 
                    ZTM->ZTM_DATA   	:= oCab:GetValue("ZTM_DATA")
                    ZTM->ZTM_DESCRI     := UPPER(oCab:GetValue('ZTM_DESCRI'))
                    ZTM->ZTM_MSBLQL    	:= oCab:GetValue('ZTM_MSBLQL')
                    ZTM->ZTM_ITEM   	:= oGrid:GetValue('ZTM_ITEM')
                    ZTM->ZTM_PERUMI     := oGrid:GetValue('ZTM_PERUMI')
                    ZTM->ZTM_PRMILH   	:= oGrid:GetValue('ZTM_PRMILH') 
                    ZTM->ZTM_TEORMS   	:= oGrid:GetValue('ZTM_TEORMS') 

                ZTM->(MsUnlock())
            Else		
                If ZTM->(DbSeek( fwxFilial("ZTM") +;
                        oCab:GetValue('ZTM_CODIGO') +;
                        oGrid:GetValue('ZTM_ITEM')))

                    RecLock('ZTM', .F.)
                        ZTM->(DbDelete())
                    ZTM->(MsUnlock())
                EndIf 
            EndIf
        Next nI
	//Se for ExclusÃ£o
	ElseIf nOpc == MODEL_OPERATION_DELETE	
        For nI := 1 To oGrid:GetQtdLine()
            oGrid:GoLine(nI)
            //Se conseguir posicionar, exclui o regist
            If ZTM->(DbSeek( fwxFilial("ZTM") +;
                        oCab:GetValue('ZTM_CODIGO') +;
                        oGrid:GetValue('ZTM_ITEM')))

                RecLock('ZTM', .F.)
                    ZTM->(DbDelete())
                ZTM->(MsUnlock())
            EndIf
        Next nI
	EndIf

	//Se nÃ£o for inclusÃ£o, volta o INCLUI para .T. (bug ao utilizar a ExclusÃ£o, antes da InclusÃ£o)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf

	RestArea(aArea)
Return lRet

User Function TC02INI()
    Local cQry      := ""
    Local cAlias    := GetNextAlias()
    Local cRet      := ''

    cQry := "SELECT MAX(ZTM_CODIGO) AS CODIGO" + CRLF
	cQry += "FROM "+RetSqlName("ZTM")+""

    MpSysOpenQry(cQry,cAlias)

    if !(cAlias)->(EOF(  ))
        cRet := StrZero((Val((cAlias)->CODIGO) + 1),6)
    else 
        cRet := '000001'
    endif 
    (cAlias)->(DBCloseArea())
Return cRet

Static Function AltParam()
    Local nVlrParam := SuperGetMV("MV_MSMILH",.f.,.f.) 	

	If MsgYesNo("O valor de calculo é de [" +RTrim(Str(nVlrParam))+ "] Deseja alterar?")
		If Pergunte("ALTTC02", .T.)
			if MV_PAR01 > 0
				PutMV("MV_MSMILH", MV_PAR01)

				Alert("Valor alterado para ["+ALLTRIM( STR(MV_PAR01) )+"]")
			endif
		endif 
	endif 
Return 

Static Function ProcIntervalo()
    Local oModel    := FWModelActive()
    Local oCab      := oModel:GetModel("FORMCAB")
    Local oGrid     := oModel:GetModel("FORMGRID")
	Local oView		:= FWViewActive()
    Local nVlrParam := SuperGetMV("MV_MSMILH",.f.,.f.) 
    Local nVlr1, nVlr2

    if !EMPTY(oCab:GetValue("ZTM_DATA")) .OR. !EMPTY(oCab:GetValue("ZTM_DESCRI"))
        if !Empty(nVlrParam)
            If Pergunte("TCEST02", .T.)
                IF MV_PAR01 < MV_PAR02
                    nVlr1 := MV_PAR01
                    nVlr2 := MV_PAR02

                   if oGrid:GetQtdLine() > 1
                       oGrid:ClearData()
                   endif

					oGrid:SetNoInsertLine(.F.)
                    WHILE nVlr1 <= nVlr2
                        oGrid:AddLine()

                        oGrid:SetValue("ZTM_PERUMI"	,nVlr1)
                        oGrid:SetValue("ZTM_TEORMS"	,100-nVlr1)
                        oGrid:SetValue("ZTM_PRMILH"	,Round((nVlrParam/100)/((100-nVlr1)/100),6))

                        nVlr1 += 0.1
                    ENDDO
					oGrid:SetNoInsertLine(.T.)
                    
					oGrid:GoLine(1)
                else 
                    MsgStop( "1º Valor não pode ser menor que o 2º", "Atenção!" )
                endif
            endif
        else
            MsgStop("O Parâmetro [MV_MSMILH] está vazio, grid não será preenchida!")
        endif
    else
        MsgStop( "Preencha os campos do cabeçalho antes de iniciar a importação", "Atenção" )
    endif
	oView:Refresh()
Return 

Static Function GeraX1(cPerg)
	Local _aArea	:= GetArea()
	Local aRegs     := {}
	Local nX		:= 0
	Local nPergs	:= 0
	Local j,i

	//Conta quantas perguntas existem ualmente.
	DbSelectArea('SX1')
	DbSetOrder(1)
	SX1->(DbGoTop())
	If SX1->(DbSeek(cPerg))
		While !SX1->(Eof()) .And. X1_GRUPO = cPerg
			nPergs++
			SX1->(DbSkip())
		EndDo
	EndIf

	aAdd(aRegs,{cPerg, "01", "1º Valor:  		" , "", "", "MV_CH1", "N", TamSX3("ZTM_PERUMI")[1]  , TamSX3("ZTM_PERUMI")[2]  	, 0, "G", "NaoVazio", "MV_PAR01", "","","","","",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "02", "2º Valor: 		" , "", "", "MV_CHs2", "N", TamSX3("ZTM_PERUMI")[1]  , TamSX3("ZTM_PERUMI")[2]  	, 0, "G", "NaoVazio", "MV_PAR02", "","","","","",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""})

	aAdd(aRegs,{"ALTTC02", "01", "Valor:  		" , "", "", "MV_CH1", "N", 2 ,0	, 0, "G", "NaoVazio", "MV_PAR01", "","","","","",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""})

	SX1->(DbGoTop())  
	If nPergs <> Len(aRegs)
		For nX:=1 To nPergs
			If SX1->(DbSeek(cPerg))		
				If RecLock('SX1',.F.)
					SX1->(DbDelete())
					SX1->(MsUnlock())
				EndIf
			EndIf
		Next nX
	EndIf

	// gravação das perguntas na tabela SX1
	If nPergs <> Len(aRegs)
		dbSelectArea("SX1")
		dbSetOrder(1)
		For i := 1 to Len(aRegs)
			If !dbSeek(cPerg+aRegs[i,2])
				RecLock("SX1",.T.)
					For j := 1 to FCount()
						If j <= Len(aRegs[i])
							FieldPut(j,aRegs[i,j])
						Endif
					Next j
				MsUnlock()
			EndIf
		Next i
	EndIf
	RestArea(_aArea)
Return nil
