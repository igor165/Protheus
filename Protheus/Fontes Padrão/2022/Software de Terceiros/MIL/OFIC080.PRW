#include "TBICONN.CH"
#include "FWMVCDEF.CH"
#include "PROTHEUS.CH"
#include "OFIC080.CH"

Static oUtil
Static oArrHelper
Static oSqlHlp
Static oDpm
Static oDemDpm
Static oModel01
Static oModel02
Static oModel03
Static oModel04

/*/{Protheus.doc} OFIC080
	Tela de consulta analítica de vendas PMM

	@author Vinicius Gati
	@since  23/04/2019
/*/
function OFIC080()
	FWExecView(STR0001, "OFIC080", MODEL_OPERATION_UPDATE) // Tela de consulta analítica de vendas PMM
return .t.

/*/{Protheus.doc} ViewDef
	Definicao da view
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
static function ViewDef()
	Local oModel  := Modeldef()
	Local oStr1   := oModel01:GetView()
	Local oStr2   := oModel02:GetView()
	Local oStr3   := oModel03:GetView()
	Local oStr4   := oModel04:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox('BOX1', 15)
	oView:CreateHorizontalBox('BOX2', 70)
	oView:CreateHorizontalBox('BOX3', 15)

	oView:CreateVerticalBox('BOX_VERT_1', 60, 'BOX2')
	oView:CreateVerticalBox('BOX_VERT_2', 40, 'BOX2')

	oView:AddField('FILTRO', oStr1, 'FILTRO')

	oView:AddGrid('GRID'   , oStr2, 'GRID')
	oView:SetNoInsertLine('GRID')

	oView:AddGrid('GRID_DET', oStr3, 'GRID_DET')
	oView:SetNoInsertLine('GRID_DET')

	oView:AddField('TOTAIS', oStr4, 'TOTAIS')

	oView:SetOwnerView('FILTRO'  ,'BOX1')
	oView:SetOwnerView('GRID'    ,'BOX_VERT_1')
	oView:SetOwnerView('GRID_DET','BOX_VERT_2')
	oView:SetOwnerView('TOTAIS'  ,'BOX3')

	oView:EnableTitleView('FILTRO'  , STR0002) // Filtro
	oView:EnableTitleView('GRID'    , STR0003) // Dados
	oView:EnableTitleView('GRID_DET', STR0004) // Por Grupos
	oView:EnableTitleView('TOTAIS'  , STR0005) // Totais

	// Retira o botão de "Salvar e Criar um Novo"
	oView:SetCloseOnOk({||.T.})

	// Executa a ação antes de cancelar a Janela de edição
	// Se ação retornar .F. não apresenta o questionamento ao usuário de formulário modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.})

	// Retira as mensagens de confirmação ao fechar a Janela
    oView:showUpdateMsg(.F.)
    oView:showInsertMsg(.F.)
return oView

/*/{Protheus.doc} ModelDef
	Definicao do modelo
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
static function ModelDef()
	Local oModel
	Local oStr1
	Local oStr2
	Local oStr3
	Local oStr4

	If oModel01 == NIL
		oUtil      := DMS_Util():New()
		oArrHelper := DMS_ArrayHelper():New()
		oSqlHlp    := DMS_SqlHelper():New()
		oDpm       := DMS_DPM():New()
		oDemDpm    := DMS_DemandaDPM():New()
		oModel01   := GetModel01()
		oModel02   := GetModel02()
		oModel03   := GetModel03()
		oModel04   := GetModel04()
	EndIf

	oStr1 := oModel01:GetModel()
	oStr2 := oModel02:GetModel()
	oStr3 := oModel03:GetModel()
	oStr4 := oModel04:GetModel()

	oModel := MPFormModel():New('OFIC080')
	oModel:SetDescription(STR0006) // Analítico de Vendas John Deere
	
	oModel:AddFields("FILTRO",,oStr1,,,{|| Load01Dados() })
	oModel:GetModel("FILTRO"):SetDescription(STR0002) // Filtro

	oModel:AddGrid("GRID","FILTRO", oStr2,,,,,{|| Load02Dados() })
	oModel:GetModel("GRID"):SetDescription(STR0003) // Dados
	oModel:GetModel("GRID"):SetOptional(.T.)
	oModel:GetModel("GRID"):SetNoUpdateLine(.T.)
	
	oModel:AddGrid("GRID_DET","FILTRO", oStr3,,,,,{|| Load03Dados() })
	oModel:GetModel("GRID_DET"):SetDescription(STR0004) // Por Grupos
	oModel:GetModel("GRID_DET"):SetOptional(.T.)
	oModel:GetModel("GRID_DET"):SetNoUpdateLine(.T.)

	oModel:AddFields("TOTAIS","FILTRO",oStr4,,,{|| Load04Dados() })
	oModel:GetModel("TOTAIS"):SetDescription(STR0005) // Totais

	oModel:SetPrimaryKey({})
return oModel

/*/{Protheus.doc} GetModel01
	Definicao da struct usada no filtro
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
Static Function GetModel01()
	Local oMd1 := OFDMSStruct():New()
	oMd1:AddField({;
		{'cTitulo'  , STR0007             },; // Competência
		{'cIdField' , "FILTRO_COMPETENCIA"},;
		{'nTamanho' , 25                  },;
		{'aComboValues', last12M()        },;
		{'lObrigat' , .T.                 },;
		{'cTooltip' , STR0008             } ; // Competência da consulta
	})
	oMd1:AddField({;
		{'cTitulo'  ,  STR0009       },; // Filial
		{'cIdField' , "FILTRO_FILIAL"},;
		{'nTamanho' , 25             },;
		{'lObrigat' , .F.            },;
		{'aComboValues', dpmFiliais()},;
		{'cTooltip' ,  STR0010       } ; // Selecione a Filial
	})
	oMd1:AddField({;
		{'cTitulo'  , STR0011            },; // Nota
		{'cIdField' , "FILTRO_NOTA"      },;
		{'nTamanho' , tamsx3('D2_DOC')[1]},;
		{'lObrigat' , .F.                },;
		{'cTooltip' , STR0012            } ; // Digite uma nota para filtrar
	})
	oMd1:AddField({;
		{'cTitulo'  , STR0013               },; // Grupo Produto
		{'cIdField' , "FILTRO_GRUPO_PRODUTO"},;
		{'nTamanho' , tamsx3('BM_GRUPO')[1] },;
		{'f3'       , 'SBM'                 },;
		{'lObrigat' , .F.                   },;
		{'cTooltip' , STR0014               } ; // Selecione o grupo que deseja ver
	})
	oMd1:AddButton(STR0015, "BUTTON_FILTRAR", {|oModel| OC0800014_Filtrar(oModel) }) // Filtrar
return oMd1

/*/{Protheus.doc} Load01Dados
	default values for the filter
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
static function Load01Dados()
return {;
	{;
		space(50),;
		space(tamsx3('VS3_FILIAL')[1]),;
		space(tamsx3('D2_DOC')[1]),; 
		space(tamsx3('BM_GRUPO')[1]),; 
		" ";
	}, 0;
}

/*/{Protheus.doc} GetModel02
	Definicao da struct usada no filtro
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
Static Function GetModel02()
	Local oMd2 := OFDMSStruct():New()
	oMd2:AddField({;
		{'cTitulo'  , STR0009      },; // Filial
		{'cIdField' , "GRID_FILIAL"},;
		{'nTamanho' , 12           },;
		{'cTooltip' , STR0009      } ; // Filial
	})
	oMd2:AddField({;
		{'cTitulo'  , STR0011    },; // Nota
		{'cIdField' , "GRID_NOTA"},;
		{'nTamanho' , 25         },;
		{'cTooltip' , STR0011    } ; // Nota
	})
	oMd2:AddField({;
		{'cTitulo'  ,  STR0016          },; // Valor
		{'cIdField' , "GRID_VALOR"      },;
		{'cTipo'    , 'N'               },;
		{'nTamanho' , 10                },;
		{'nDecimal' ,  2                },;
		{'cPicture' , '@E 99,999,999.99'},;
		{'cTooltip' ,  STR0017          } ; // Valor Total
	})
	oMd2:AddField({;
		{'cTitulo'  , STR0018           },; // Custo
		{'cIdField' , "GRID_CUSTO"      },;
		{'cTipo'    , 'N'               },;
		{'nTamanho' , 10                },;
		{'nDecimal' ,  2                },;
		{'cPicture' , '@E 99,999,999.99'},;
		{'cTooltip' , STR0019           } ; // Valor Total Custo
	})
	oMd2:AddField({;
		{'cTitulo'  , STR0020             },; // Valor Oficina
		{'cIdField' , "GRID_VALOR_OFICINA"},;
		{'cTipo'    , 'N'                 },;
		{'nTamanho' , 10                  },;
		{'nDecimal' ,  2                  },;
		{'cPicture' , '@E 99,999,999.99'  },;
		{'cTooltip' , STR0021             } ; // Valor Total Oficina
	})
	oMd2:AddField({;
		{'cTitulo'  , STR0022            },; // Valor Balcão
		{'cIdField' , "GRID_VALOR_BALCAO"},;
		{'cTipo'    , 'N'                },;
		{'nTamanho' , 10                 },;
		{'nDecimal' ,  2                 },;
		{'cPicture' , '@E 99,999,999.99' },;
		{'cTooltip' , STR0023            } ; // Valor Total Balcão
	})
	oMd2:AddField({;
		{'cTitulo'  , ""       },;
		{'cIdField' , "GRID_AJ"},;
		{'cTipo'    , 'C'      },;
		{'nTamanho' , 10       },;
		{'cTooltip' , ''       } ;
	})
return oMd2

/*/{Protheus.doc} Load02Dados
	default values for the grid
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
static function Load02Dados()
return {  }

/*/{Protheus.doc} GetModel03
	Definicao da struct usada no filtro
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
Static Function GetModel03()
	Local oMd3 := OFDMSStruct():New()
	oMd3:AddField({;
		{'cTitulo'  , STR0009          },; // Filial
		{'cIdField' , "GRID_DET_FILIAL"},;
		{'nTamanho' , 12               },;
		{'cTooltip' , STR0009          }; // Filial
	})
	oMd3:AddField({;
		{'cTitulo'  , STR0024         },; // Grupo
		{'cIdField' , "GRID_DET_GRUPO"},;
		{'nTamanho' , 20              },;
		{'cTooltip' , STR0024         } ; // Grupo
	})
	oMd3:AddField({;
		{'cTitulo'  , STR0016           },; // Valor
		{'cIdField' , "GRID_DET_VALOR"  },;
		{'cTipo'    , 'N'               },;
		{'nTamanho' , 10                },;
		{'nDecimal' ,  2                },;
		{'cPicture' , '@E 99,999,999.99'},;
		{'cTooltip' , STR0017           } ; // Valor Total
	})
	oMd3:AddField({;
		{'cTitulo'  , STR0018           },; // Custo
		{'cIdField' , "GRID_DET_CUSTO"  },;
		{'cTipo'    , 'N'               },;
		{'nTamanho' , 10                },;
		{'nDecimal' ,  2                },;
		{'cPicture' , '@E 99,999,999.99'},;
		{'cTooltip' , STR0019           } ; // Valor Total Custo
	})
	oMd3:AddField({;
		{'cTitulo'  , ""       },;
		{'cIdField' , "GRID_AJ"},;
		{'cTipo'    , 'C'      },;
		{'nTamanho' , 10       },;
		{'cTooltip' , ""       } ;
	})
return oMd3

/*/{Protheus.doc} Load03Dados
	default values for the grid
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
static function Load03Dados()
return { }

/*/{Protheus.doc} GetModel04
	Definicao da struct usada no filtro
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
Static Function GetModel04()
	Local oMd := OFDMSStruct():New()
	oMd:AddField({;
		{'cTitulo'  , STR0025       },; // Venda Total
		{'cIdField' , "TOTAIS_VALOR"},;
		{'nTamanho' , 20            } ;
	})
	oMd:AddField({;
		{'cTitulo'  , STR0026       },; // Custo Total
		{'cIdField' , "TOTAIS_CUSTO"},;
		{'nTamanho' , 20            } ;
	})
return oMd

/*/{Protheus.doc} Load04Dados
	default values for the total values
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
static function Load04Dados()
return {{"0,00", "0,00"}, 0}

/*/{Protheus.doc} last12M
	returns the last twelve months as combobox type data for the filter

    @author Vinicius Gati
    @since  23/04/2019
/*/
Static Function last12M()
	Local aLast12M   := {}
	Local oArrHelper := DMS_ArrayHelper():New()
	d12MesesAnt := oUtil:RemoveMeses(ddatabase, 1)
	d12MesesAnt := oUtil:UltimoDia(YEAR(d12MesesAnt), MONTH(d12MesesAnt))
	
	aAdd(aLast12M, d12MesesAnt)

	Do While LEN(aLast12M) < 12
		dData := aLast12M[LEN(aLast12M)]
		dData := oUtil:RemoveMeses( dData, 1 )
		dData := oUtil:UltimoDia( YEAR(dData), MONTH(dData) )
		aAdd(aLast12M, dData)
	End Do
return oArrHelper:Map(aLast12M, {|dData| alltrim(dtos(dData))+"="+alltrim(dtoc(dData)) })

/*/{Protheus.doc} dpmFiliais
	returns the branchs that is configured as john deere brand, the parameter is MV_MIL0005

    @author Vinicius Gati
    @since  23/04/2019
/*/
static function dpmFiliais()
	Local aFilis := oDpm:GetFiliais()
	Local aFilFiltro := {}
	oArrHelper:each(aFilis, {|aFilData| aadd(aFilFiltro,  alltrim(aFilData[1]) + "=" + alltrim(aFilData[1]) + " (" + alltrim(aFilData[2]) + ")")})
return aFilFiltro

/*/{Protheus.doc} last12M
    hits the database, and gets the data with the selected filter

    @author Vinicius Gati
    @since  23/04/2019
/*/
static function OC0800014_Filtrar(oModel)
	Local oGrid         := oModel:GetModel():GetModel("GRID")
	Local oGridGrp      := oModel:GetModel():GetModel("GRID_DET")
	Local oTot          := oModel:GetModel():GetModel("TOTAIS")
	Local nX            := 1
	Local cAl           := GetNextAlias()
	Local cQuery        := ""
	Local cFilial       := oModel:GetValue("FILTRO_FILIAL")
	Local cCompetencia  := oModel:GetValue("FILTRO_COMPETENCIA")
	Local cGrupoProduto := oModel:GetValue("FILTRO_GRUPO_PRODUTO")
	Local cFiltroNota   := oModel:GetValue("FILTRO_NOTA")
	Local cPrefBAL      := alltrim(GetNewPar("MV_PREFBAL","BAL"))
	Local cPrefOFI      := alltrim(GetNewPar("MV_PREFOFI","OFI"))
	Local cOri          := cPrefOFI + "','" + cPrefBAL
	Local nTot          := 0
	Local nTotCus       := 0
	Local cBckFil       := cFilAnt
	Local cNota         := ""
	Local aValPorGrupo  := {}

	if empty(oModel:GetValue("FILTRO_FILIAL"))
		aFiliais := { oDpm:GetFiliais()[1] }
	else
		aFiliais := { {oModel:GetValue("FILTRO_FILIAL")} }
	endif

	cInRecom := "'" + oArrHelper:Join(oDemDpm:aSitRec, "','") + "'"

	oGrid:SetNoInsertLine(.F.)
	oGrid:SetNoUpdateLine(.F.)
	oGrid:ClearData(.f., .f.)

	for nX := 1 to len(aFiliais)
		if empty(aFiliais[nX, 1])
			loop
		endif

		cFilAnt := aFiliais[nX, 1]

		cQuery := ""
		cQuery += " SELECT D2_FILIAL, D2_DOC, D2_SERIE, F2_PREFORI, BM_GRUPO, COALESCE(SUM(D2_CUSTO1), 0) SOMA_CUSTO, COALESCE(SUM(D2_TOTAL), 0) SOMA_TOTAL "
		cQuery += " FROM ( "
		cQuery += "  SELECT D2_FILIAL, D2_DOC, D2_SERIE, F2_PREFORI, BM_GRUPO, cast(D2_CUSTO1 as int) D2_CUSTO1, cast(D2_TOTAL as int) D2_TOTAL, SITUACAO.VS3_CODSIT "
		cQuery += "    FROM "+oSqlHlp:NoLock('SD2')+" "
		cQuery += "    JOIN "+oSqlHlp:NoLock('SF2')+" ON SF2.F2_FILIAL = SD2.D2_FILIAL              AND SF2.F2_DOC    = SD2.D2_DOC   AND SF2.F2_SERIE   = SD2.D2_SERIE  AND SF2.F2_PREFORI IN ('"+cOri+"') AND SF2.D_E_L_E_T_ = ' ' "
		cQuery += "    JOIN "+oSqlHlp:NoLock('SF4')+" ON SF4.F4_FILIAL = '" + xFilial('SF4') + "'   AND SF4.F4_CODIGO = SD2.D2_TES   AND SF4.F4_OPEMOV  = '05'          AND SF4.D_E_L_E_T_ = ' ' "
		cQuery += "    JOIN "+oSqlHlp:NoLock('SB1')+" ON SB1.B1_FILIAL = '" + xFilial('SB1') + "'   AND SD2.D2_COD    = SB1.B1_COD   AND SB1.D_E_L_E_T_ = ' ' "
		if SBM->(FieldPos('BM_VAIDPM')) > 0
			cQuery += "       JOIN "+oSqlHlp:NoLock('SBM')+" ON SBM.BM_FILIAL  = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO   AND SBM.BM_VAIDPM    = '1'       AND SBM.D_E_L_E_T_ = ' ' "
		else
			cQuery += "       JOIN "+oSqlHlp:NoLock('SBM')+" ON SBM.BM_FILIAL  = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO   AND BM_GRUPO IN "+oDpm:GetInGroups()+" AND SBM.D_E_L_E_T_ = ' ' "
		endif
		cQuery += "    LEFT JOIN ( "
		cQuery += "         SELECT VS1_FILIAL, VS3_CODITE, VS3_GRUITE, VS3_CODSIT, VS1_NUMNFI, VS1_SERNFI "
		cQuery += "           FROM "+oSqlHlp:NoLock('VS1')
		cQuery += "           JOIN "+oSqlHlp:NoLock('VS3')+" ON VS3.VS3_FILIAL = VS1_FILIAL AND VS3_NUMORC    = VS1_NUMORC AND VS3.D_E_L_E_T_ = ' '  "
		cQuery += "          WHERE VS1_FILIAL = '" + xFilial('VS1') + "' "
		cQuery += "            AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "    ) SITUACAO ON VS1_FILIAL = '" + xFilial('VS1') + "' AND VS3_CODITE = B1_CODITE AND VS3_GRUITE = B1_GRUPO AND VS1_NUMNFI = D2_DOC AND VS1_SERNFI = D2_SERIE "
		cQuery += "    WHERE SD2.D2_FILIAL  = '" + xFilial('SD2') + "' "
		cQuery += "      AND SD2.D2_EMISSAO >= '" + left(cCompetencia, 6) + '01' + "' 
		cQuery += "      AND SD2.D2_EMISSAO <= '" + cCompetencia + "'
		cQuery += "      AND SD2.D_E_L_E_T_ = ' ' "
		cQuery += " ) TEMP_TBL "
		cQuery += " WHERE (VS3_CODSIT IS NULL OR VS3_CODSIT = ' ' OR VS3_CODSIT NOT IN (" + cInRecom + ") ) "
		if ! Empty(cFiltroNota)
			cQuery += " AND D2_DOC = '"+cFiltroNota+"' "
		endif
		if ! Empty(cGrupoProduto)
			cQuery += " AND BM_GRUPO = '"+cGrupoProduto+"' "
		endif
		cQuery += " GROUP BY D2_FILIAL, D2_DOC, D2_SERIE, F2_PREFORI, BM_GRUPO "
		cQuery += " ORDER BY D2_FILIAL, D2_DOC, D2_SERIE, F2_PREFORI, BM_GRUPO "
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAl, .F., .T.)

		do while ! (cAl)->(eof())
			cNota := alltrim((cAl)->D2_DOC + "/" + (cAl)->D2_SERIE)
			aadd(aValPorGrupo, {(cAl)->D2_FILIAL, (cAl)->BM_GRUPO, (cAl)->SOMA_TOTAL, (cAl)->SOMA_CUSTO})

			if oGrid:Length() > 0 .and. ! oGrid:IsDeleted() .and. ! empty(oGrid:GetValue("GRID_NOTA")) .and. alltrim(oGrid:GetValue("GRID_NOTA")) == cNota
				oGrid:SetValue("GRID_VALOR", oGrid:GetValue("GRID_VALOR") + (cAl)->SOMA_TOTAL)
				oGrid:SetValue("GRID_CUSTO", oGrid:GetValue("GRID_CUSTO") + (cAl)->SOMA_CUSTO)
			else
				oGrid:AddLine()
				oGrid:SetValue("GRID_FILIAL", (cAl)->D2_FILIAL)
				oGrid:SetValue("GRID_NOTA"  , cNota)
				oGrid:SetValue("GRID_VALOR" , (cAl)->SOMA_TOTAL)
				oGrid:SetValue("GRID_CUSTO" , (cAl)->SOMA_CUSTO)
			endif

			if alltrim((cAl)->(F2_PREFORI)) == alltrim(cPrefBAL)
				oGrid:SetValue("GRID_VALOR_BALCAO", oGrid:GetValue("GRID_VALOR_BALCAO") + (cAl)->SOMA_TOTAL)
			else
				oGrid:SetValue("GRID_VALOR_OFICINA", oGrid:GetValue("GRID_VALOR_OFICINA") + (cAl)->SOMA_TOTAL)
			endif

			nTot    += (cAl)->(SOMA_TOTAL)
			nTotCus += (cAl)->(SOMA_CUSTO)
			(cAl)->(dbSkip())
		end do

		(cAl)->(dbCloseArea())
	next
	if oGrid:Length() == 0
		oGrid:AddLine()
	endif
	oGrid:SetNoInsertLine(.T.)
	oGrid:SetNoUpdateLine(.T.)
	oGrid:SetLine(1)

	// GRID_DET_FILIAL
	// GRID_DET_GRUPO
	// GRID_DET_VALOR
	// GRID_DET_CUSTO
	oGridGrp:SetNoInsertLine(.F.)
	oGridGrp:SetNoUpdateLine(.F.)
	oGridGrp:ClearData(.f., .f.)
	oGridGrp:AddLine()
	aValPorGrupo := ASORT(aValPorGrupo,,,{ |x, y| x[1]+x[2] < y[1]+y[2] })
	for nX := 1 to Len(aValPorGrupo)
		cIdxLn := alltrim(oGridGrp:GetValue("GRID_DET_FILIAL")) + alltrim(oGridGrp:GetValue("GRID_DET_GRUPO"))
		cIdx   := alltrim(aValPorGrupo[nX,1]) + alltrim(aValPorGrupo[nX,2])

		if oGridGrp:Length() > 0 .and. ! oGridGrp:IsDeleted() .and. cIdxLn == cIdx
			oGridGrp:SetValue("GRID_DET_VALOR", oGridGrp:GetValue("GRID_DET_VALOR") + aValPorGrupo[nX,3]) // valor
			oGridGrp:SetValue("GRID_DET_CUSTO", oGridGrp:GetValue("GRID_DET_CUSTO") + aValPorGrupo[nX,4]) // custo
		else
			if ! Empty(alltrim(oGridGrp:GetValue("GRID_DET_FILIAL")))
				oGridGrp:AddLine()
			endif
			oGridGrp:SetValue("GRID_DET_FILIAL", aValPorGrupo[nX,1])
			oGridGrp:SetValue("GRID_DET_GRUPO" , aValPorGrupo[nX,2])
			oGridGrp:SetValue("GRID_DET_VALOR" , aValPorGrupo[nX,3])
			oGridGrp:SetValue("GRID_DET_CUSTO" , aValPorGrupo[nX,4])
		endif
	next
	if oGridGrp:Length() == 0
		oGridGrp:AddLine()
	endif
	oGridGrp:SetNoInsertLine(.T.)
	oGridGrp:SetNoUpdateLine(.T.)
	oGridGrp:SetLine(1)

	oTot:SetValue("TOTAIS_VALOR", TRANSFORM(nTot   , "@E 999,999,999,999.99"))
	oTot:SetValue("TOTAIS_CUSTO", TRANSFORM(nTotCus, "@E 999,999,999,999.99"))

	cFilAnt := cBckFil
return .t.
