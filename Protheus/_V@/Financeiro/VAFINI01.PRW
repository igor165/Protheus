#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

Static cTitulo := "Histórico Integração API"
User Function VAFINI01()
    Local aArea   		:= FwGetArea()
    Local oBrowse  		:= NIL
    
    SetFunName("VAFINI01")
	
    oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "SE2" )
	oBrowse:SetDescription( cTitulo )
	oBrowse:SetFilterDefault( "E2_XRCNZE2 > 0" )
	
	oBrowse:Activate()
	
	FwRestArea(aArea)
Return 

Static Function MenuDef()
	Local aRotina := {}
	//ADD OPTION aRotina TITLE 'Visualizar' 	   ACTION 'VIEWDEF.VAFINI01' OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE 'Visualizar' 	   ACTION 'U_FIN01VI()' OPERATION 2 ACCESS 0 
	//ADD OPTION aRotina TITLE 'Incluir' 	   	   ACTION 'VIEWDEF.VAFINI01' OPERATION 3 ACCESS 0
	//ADD OPTION aRotina TITLE 'Excluir' 	   	   ACTION 'VIEWDEF.VAFINI01' OPERATION 5 ACCESS 0 
	//ADD OPTION aRotina TITLE 'Imprimir' 	   ACTION 'VIEWDEF.VAFINI01' OPERATION 8 ACCESS 0 
	//ADD OPTION aRotina TITLE 'Importar Batida' ACTION 'u_Est05Bat()'     OPERATION 3 ACCESS 0 
Return aRotina
Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStField 		:= nil
	Local oStSE2 		:= FWFormStruct(1, 'SE2')
	Local oStZE2 		:= FWFormStruct(1, 'ZE2')
	Local oStSE5 		:= FWFormStruct(1, 'SE5')
	Local aZE2Rel		:= {}
	Local aSE5Rel		:= {}
	
    oStField := FWFormModelStruct():New()

    oStField:addTable("", {"C_STRING1"}, "Visualização", {|| ""})
    oStField:addField("String 01", "texto", "C_STRING1", "C", 15)
    
    //Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('FINI01')
	
	oModel:AddFields('FAKEM',/*cOwner*/   ,oStField, /* <bPre > */, /* <bPost > */, {|| LoadFake()}/* <bLoad > */)
	oModel:AddGrid('SE2DETAIL',"FAKEM"    ,oStSE2,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,{|oModel| LoadSE2(oModel)}/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence
	oModel:AddGrid('ZE2DETAIL','SE2DETAIL',oStZE2,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence
	oModel:AddGrid('SE5DETAIL','SE2DETAIL',oStSE5,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence
	
	oModel:GetModel('ZE2DETAIL'):SetOnlyView(.T.)
	oModel:GetModel('SE5DETAIL'):SetOnlyView(.T.)

	aadd(aZE2Rel, {'ZE2_FILIAL' ,'E2_FILIAL' })
	aadd(aZE2Rel, {'ZE2_PREFIX' ,'E2_PREFIXO'})
	aadd(aZE2Rel, {'ZE2_NUM'    ,'E2_NUM'    })
	aadd(aZE2Rel, {'ZE2_PARCEL' ,'E2_PARCELA'})
	aadd(aZE2Rel, {'ZE2_TIPO'   ,'E2_TIPO'   })
	aadd(aZE2Rel, {'ZE2_FORNEC' ,'E2_FORNECE'})
	aadd(aZE2Rel, {'ZE2_LOJA'   ,'E2_LOJA'   })

	aadd(aSE5Rel, {'E5_FILIAL'  ,'E2_FILIAL' })
	aadd(aSE5Rel, {'E5_PREFIXO' ,'E2_PREFIXO'})
	aadd(aSE5Rel, {'E5_NUMERO'  ,'E2_NUM'    })
	aadd(aSE5Rel, {'E5_PARCELA' ,'E2_PARCELA'})
	aadd(aSE5Rel, {'E5_TIPO'    ,'E2_TIPO'   })
	aadd(aSE5Rel, {'E5_CLIFOR'  ,'E2_FORNECE'})
	aadd(aSE5Rel, {'E5_LOJA'    ,'E2_LOJA'   })

    oModel:SetRelation('ZE2DETAIL', aZE2Rel, ZE2->(IndexKey(1)))
    
    oModel:SetRelation('SE5DETAIL', aSE5Rel, SE5->(IndexKey(7)))
	
	oModel:SetPrimaryKey( {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"} )

	oModel:SetDescription(cTitulo)
	oModel:GetModel('FAKEM'):SetDescription('Hide')
	oModel:GetModel('SE2DETAIL'):SetDescription('Titulos a Pagar')
	oModel:GetModel('ZE2DETAIL'):SetDescription('Log Integração')
	oModel:GetModel('SE5DETAIL'):SetDescription('Baixa de Titulos')

    oModel:setActivate({ |oModel| ativo(oModel)})
	
Return oModel
Static Function ViewDef()
	Local oView		    := Nil
	Local oModel	    := FWLoadModel("VAFINI01")
	Local oStField 		:= nil
	Local oStSE2 	    := FWFormStruct(2, 'SE2')
	Local oStZE2 	    := FWFormStruct(2, 'ZE2')
	Local oStSE5 	    := FWFormStruct(2, 'SE5')

    oStField := FWFormViewStruct():New()
    oStField:addField("C_STRING1", "01" , "String 01", "texto", , "C" )

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField( 'CAB'       , oStField , 'FAKEM' )
	oView:AddGrid( 'VIEW_SE2'   , oStSE2 , 'SE2DETAIL' )
	oView:AddGrid( 'VIEW_ZE2'   , oStZE2 , 'ZE2DETAIL' )
	oView:AddGrid( 'VIEW_SE5'   , oStSE5 , 'SE5DETAIL' )
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('BOX_HIDE'  , 0 )
	oView:CreateHorizontalBox('BOX_SE2'  , 50 )
	oView:CreateHorizontalBox('BOX_GRID' , 50 )
	
    oView:CreateVerticalBox( 'BOX_ZE2', 50, 'BOX_GRID' )
    oView:CreateVerticalBox( 'BOX_SE5', 50, 'BOX_GRID' )
	
	//Amarrando a view com as box
	oView:SetOwnerView('CAB'	    ,'BOX_HIDE' )
	oView:SetOwnerView('VIEW_SE2'	,'BOX_SE2' )
	oView:SetOwnerView('VIEW_ZE2'	,'BOX_ZE2' )
	oView:SetOwnerView('VIEW_SE5'	,'BOX_SE5')
	
	oView:EnableTitleView('VIEW_SE2','Titulos a Pagar')
	oView:EnableTitleView('VIEW_ZE2','Log Integração')
	oView:EnableTitleView('VIEW_SE5','Baixa de Titulos')
	
Return oView
Static Function LoadFake()
Return {"Fake"}
Static Function LoadSE2(oModel)
    Local aArea     := FwGetArea()
    Local oStruct   := nil
    Local cAlias    := GetNextAlias()
    Local cQry      := ""
    Local aData     := {}
    Local nI 
    Local aAux

    cQry := " select *" + CRLF 
    cQry += " from "+RetSqlName("SE2")+" " + CRLF 
    cQry += " WHERE E2_FILIAL = '"+fWxFilial("SE2")+"' " + CRLF 
    cQry += " AND E2_XRCNZE2 > 0" + CRLF 
    cQry += " AND E2_EMISSAO BETWEEN "+ValToSQL(mv_par01)+" AND "+ValToSQL(mv_par02)+" " + CRLF 
    cQry += " AND D_E_L_E_T_ = '' " + CRLF 

    MemoWrite("C:\totvs_relatorios\VAFINI01.sql" , cQry)

    mpSysOpenQuery(cQry,cAlias)
    
    oStruct := oModel:GetStruct()
    aAux    := oStruct:GetFields()

    While !(cAlias)->(EOF())
        aAdd(aData,{{(cAlias)->R_E_C_N_O_},{}})

        For nI := 1 to Len(aAux)
            if !(aAux[nI][14]) 
                aAdd(aData[Len(aData)][2],(cAlias)->&(aAux[nI][3]))
            else//CAMPO VIRTUAL
                if aAux[nI][4] == 'C'
                    aAdd(aData[Len(aData)][2],"")
                elseif aAux[nI][4] == 'D'
                    aAdd(aData[Len(aData)][2],cToD("//"))
                elseif aAux[nI][4] == 'N'
                    aAdd(aData[Len(aData)][2],0)
                endif 
            endif 
        Next nI

        (cAlias)->(dbSkip())
    EndDo
    (cAlias)->(dbCloseArea())
    FwRestArea(aArea)
Return aData
User Function FIN01VI()
    Local aArea := FwGetArea()
    Local cPerg := "VAFINI01"

    GeraX1(cPerg)

    Pergunte(cPerg, .T.)

    if !EMPTY(MV_PAR01) .AND. !EMPTY(MV_PAR02) 
        FWExecView('Visualização', 'VAFINI01', MODEL_OPERATION_VIEW,,{||.T.})
    endif

    FwRestArea(aArea)
Return 
static function ativo(oModel)

//Só efetua a alteração do campo para inserção
if oModel:GetOperation() == MODEL_OPERATION_INSERT
    FwFldPut("C_STRING1", "FAKE" , /*nLinha*/, oModel)
endif

return
Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
Local i := 0, j := 0

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

aAdd(aRegs, { cPerg, '01', 'Data de?  ', '', '', 'MV_CH1', 'D', TamSX3('E2_EMISSAO')[1],TamSX3('E2_EMISSAO')[2], 0, 'G', ''            , 'MV_PAR01', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '   ', '' })
aAdd(aRegs, { cPerg, '02', 'Data ate? ', '', '', 'MV_CH2', 'D', TamSX3('E2_EMISSAO')[1],TamSX3('E2_EMISSAO')[2], 0, 'G', ''            , 'MV_PAR02', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '   ', '' })

//Se quantidade de perguntas for diferente, apago todas
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
