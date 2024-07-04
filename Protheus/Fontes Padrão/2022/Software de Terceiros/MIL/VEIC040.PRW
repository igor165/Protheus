#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static oModel01
Static oModel02
Static oModel03
Static oModel04


/*/{Protheus.doc} VEIC040
	Tela para consulta de arquivos no protheus data
	
	@type function
	@author Vinicius Gati
	@since 11/03/2019
/*/
Function VEIC040()
	oExecView := FWViewExec():New()
	oExecView:SetTitle("Arquivos de log e configuração")
	oExecView:SetSource("VEIC040")
	oExecView:SetOperation(MODEL_OPERATION_UPDATE)
	oExecView:OpenView(.T.)
Return NIL

/*/{Protheus.doc} modeldef
	Retorna model padrao mvc
	
	@type function
	@author Vinicius Gati
	@since 11/03/2019
/*/
static function modeldef()
	Local oModel
	Local oStruFiltro
	Local oStruFiles
	Local oStruAcoes
	Local oStruArq

	If oModel01 == NIL
		oModel01 := GetModel01()
		oModel02 := GetModel02()
		oModel03 := GetModel03()
		oModel04 := GetModel04()
	EndIf

	oStruFiltro := oModel02:GetModel()
	oStruFiles  := oModel01:GetModel()
	oStruAcoes  := oModel03:GetModel()
	oStruArq    := oModel04:GetModel()

	oModel := MPFormModel():New("VEIC040", /* <bPre> */, /* <bPost> */, {|| .T.} /* <bCommit> */, {|| .T.} /* <bCancel> */)
	oModel:AddFields("MASTER", /* <cOwner> */, oStruFiltro, /* <bPre> */, /* <bPost> */, {|| VC040032_LoadPadrao() }/* <bLoad> */)
	oModel:AddGrid("FILES", "MASTER", oStruFiles,,,,, {|| VC040022_LoadPadrao() })
	oModel:AddFields("ACOES", "MASTER", oStruAcoes,,, {|| {{' ', ' '},0} })
	oModel:AddFields("ARQUIVO", "MASTER", oStruArq,,, {|| {{' '},0} })
	                

	oModel:SetDescription("Consulta arquivos de log")
	oModel:GetModel("MASTER"):SetDescription("Filtro")
	oModel:GetModel("FILES"):SetDescription("Arquivos")
	oModel:GetModel("ACOES"):SetDescription("Ações")
	oModel:GetModel("ARQUIVO"):SetDescription("Arquivo")

	oModel:SetPrimaryKey({})
	oModel:SetActivate()
return oModel

/*/{Protheus.doc} viewdef
	Retorna view padrao mvc
	
	@type function
	@author Vinicius Gati
	@since 11/03/2019
/*/
static function viewdef()
	Local oModel      := modeldef()
	Local oStruFiltro := oModel02:GetView()
	Local oStruFiles  := oModel01:GetView()
	Local oStruAcoes  := oModel03:GetView()
	Local oStruArq    := oModel04:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("FILTRO", oStruFiltro, "MASTER")
	oView:AddGrid("FILES", oStruFiles)
	oView:AddField("ACOES", oStruAcoes)
	oView:AddField("ARQUIVO", oStruArq)

	oView:EnableTitleView("FILTRO", "Filtro")
	oView:EnableTitleView("FILES", "Consulta")
	oView:EnableTitleView("ACOES", "Ações")
	oView:EnableTitleView("ARQUIVO", "Arquivo")

	oView:CreateHorizontalBox("TELA_FILTRO", 10)
	oView:CreateHorizontalBox("TELA_PAINEL", 40)
	oView:CreateHorizontalBox("TELA_ARQUIVO", 40)
	oView:CreateHorizontalBox("TELA_ACOES" , 10)

	oView:SetOwnerView("FILTRO", "TELA_FILTRO")
	oView:SetOwnerView("FILES" , "TELA_PAINEL")
	oView:SetOwnerView("ACOES" , "TELA_ACOES")
	oView:SetOwnerView("ARQUIVO", "TELA_ARQUIVO")

	// Retira o boto de "Salvar e Criar um Novo"
	oView:SetCloseOnOk({||.T.})

	// Retira as mensagens de confirmao ao fechar a Janela
	oView:showUpdateMsg(.F.)
	oView:showInsertMsg(.F.)
return oView

/*/{Protheus.doc} GetModel01
	Definio dos dados que sero digitados
	
	@type function
	@author Vinicius Gati
	@since 11/03/2019
/*/
Static Function GetModel01()
	Local oMd1 := OFDMSStruct():New()
	oMd1:AddField({;
		{'cTitulo'     , 'Nome'     },;
		{'nTamanho'    , 400        },;
		{'cIdField'    , 'FILENAME' },;
		{'cTooltip'    , 'Nome do arquivo'} ;
	})
	oMd1:AddField({;
		{'cTitulo'     , 'Tamanho'  },;
		{'cTipo'       , 'N'        },;
		{'nTamanho'    , 8          },;
		{'cIdField'    , 'SIZE'     },;
		{'cTooltip'    , 'Nome do arquivo'} ;
	})
	oMd1:AddField({;
		{'cTitulo'     , 'Data'},;
		{'cTipo'       , 'D'   },;
		{'nTamanho'    , 8     },;
		{'cIdField'    , 'DATA'},;
		{'cTooltip'    , 'Data alteração'} ;
	})
	oMd1:AddField({;
		{'cTitulo'     , 'Hora'},;
		{'nTamanho'    , 8     },;
		{'cIdField'    , 'HORA'},;
		{'cTooltip'    , 'Hora alteração'} ;
	})
	oMd1:AddField({;
		{'cTitulo'     , 'Caminho' },;
		{'nTamanho'    , 200      },;
		{'cIdField'    , 'PATH'    },;
		{'lObrigat'    , .T.       },;
		{'cTooltip'    , 'Caminho do arquivo'} ;
	})
return oMd1

/*/{Protheus.doc} GetModel02
	Definio dos dados que sero digitados
	
	@type function
	@author Vinicius Gati
	@since 11/03/2019
/*/
Static Function GetModel02()
	Local oMd1 := OFDMSStruct():New()
	oMd1:AddField({;
		{'cTitulo'     , 'Caminho' },;
		{'nTamanho'    , 1500      },;
		{'cIdField'    , 'PATH'    },;
		{'cTooltip'    , 'Caminho do arquivo'} ;
	})
	oMd1:AddField({;
		{'cTitulo'     , 'Nome'     },;
		{'nTamanho'    , 400        },;
		{'cIdField'    , 'FILENAME' },;
		{'cTooltip'    , 'Nome do arquivo'} ;
	})
	oMd1:AddButton('Filtrar', "BTN_FILTRAR", {|oModel| VC040012_Filtrar(oModel) })
return oMd1

/*/{Protheus.doc} GetModel03
	Botoes de ação
	
	@type function
	@author Vinicius Gati
	@since 11/03/2019
/*/
static function GetModel03()
	Local oMd1 := OFDMSStruct():New()
	oMd1:AddButton('Visualizar', "BTN_VISUALIZAR", {|oModel| VC040052_AbreArquivo(oModel) })
	oMd1:AddButton('Excluir'   , "BTN_EXCLUIR", {|oModel| VC040072_DeletaArquivo(oModel) })
return oMd1

/*/{Protheus.doc} GetModel04
	Botoes de ação
	
	@type function
	@author Vinicius Gati
	@since 11/03/2019
/*/
static function GetModel04()
	Local oMd1 := OFDMSStruct():New()
	oMd1:AddField({;
		{'cTitulo'     , 'Conteúdo' },;
		{'cTipo'       , "M"        },; 
		{'nTamanho'    , 40000      },;
		{'cIdField'    , 'CONTEUDO' },;
		{'bValid'      , {|| .t.  } },;
		{'cTooltip'    , 'Conteúdo do arquivo'} ;
	})
return oMd1

/*/{Protheus.doc} VC040012_Filtrar
	Filtra os arquivos e mostra na tela
	
	@type function
	@author Vinicius Gati
	@since 11/03/2019
/*/
static function VC040012_Filtrar(oModel)
	local aArquivos := VC040042_BuscaArquivosLog(alltrim(oModel:GetValue("PATH")), alltrim(oModel:GetValue("FILENAME")))
	local oForm := oModel:oFormModel
	local oFilesForm := oForm:GetModel('FILES')
	local aMetodos := ClassMethArr(oFilesForm)
	local nX := 1

	oFilesForm:DelAllLine()
	oFilesForm:ClearData()
	For nX:= 1 to Len(aArquivos)
		oFilesForm:AddLine()
		oFilesForm:SetValue('FILENAME', aArquivos[nx, 1])
		oFilesForm:SetValue('SIZE', aArquivos[nx, 2])
		oFilesForm:SetValue('DATA', aArquivos[nx, 3])
		oFilesForm:SetValue('HORA', aArquivos[nx, 4])
		oFilesForm:SetValue('PATH', aArquivos[nx, 5])
	Next
return .t. 

/*/{Protheus.doc} VC040022_LoadPadrao
	Retorna modelo de dados de arquivos
	
	@type function
	@author Vinicius Gati
	@since 11/03/2019
/*/
static function VC040022_LoadPadrao()
	Local oArrHlp  := DMS_ArrayHelper():New()
	aArquivos := VC040042_BuscaArquivosLog()
return oArrHlp:Map(aArquivos, {|aData| {0, aData} })


/*/{Protheus.doc} VC040032_LoadPadrao
	Retorna modelo de dados de filtro
	
	@type function
	@author Vinicius Gati
	@since 11/03/2019
/*/
static function VC040032_LoadPadrao()
return {{space(1500),space(400),space(1)}, 0}

/*/{Protheus.doc} NomeMetodo
	Descricao
	
	@type function
	@author Vinicius Gati
	@since 11/03/2019
/*/
static function VC040042_BuscaArquivosLog(cPath, cFileName)
	local aArquivos   := {}
	local nX          := 0
	default cPath     := ''
	default cFileName := ''

	cPath := alltrim(cPath)
	cFileName := alltrim(cFileName)

	if Empty(cPath) .and. Empty(cFileName)
		aArquivos := VC040062_Directory("\system\logsmil\", "*.JSON")
		AEVAL(VC040062_Directory("\system\logsmil\", "*.DATA"), {|aEl| aadd(aArquivos, aEl) })
		AEVAL(VC040062_Directory("\system\logsmil\", "*.LOG") , {|aEl| aadd(aArquivos, aEl) })
	endif

	if !Empty(cPath) .and. Empty(cFileName)
		aArquivos := VC040062_Directory(cPath, "\*.JSON")
		AEVAL(VC040062_Directory(cPath, "\*.DATA"), {|aEl| aadd(aArquivos, aEl) })
		AEVAL(VC040062_Directory(cPath, "\*.LOG") , {|aEl| aadd(aArquivos, aEl) })
	endif
	
	if ! Empty(cPath) .and. ! Empty(cFileName)
		aArquivos := VC040062_Directory(cPath, cFileName)
	endif
return aArquivos

/*/{Protheus.doc} VC040052_AbreArquivo
	Abre arquivo para visualizar conteudo
	
	@type function
	@author Vinicius Gati
	@since 11/03/2019
/*/
static function VC040052_AbreArquivo(oModel)
	local oForm := oModel:oFormModel
	local oFile := oForm:GetModel("FILES")
	local oArq := FWFileReader():New(alltrim(oFile:GetValue("PATH")) + alltrim(oFile:GetValue("FILENAME")))
	local cContent := ""

	if oArq:Open()
	   while (oArq:hasLine())
	      cContent += oArq:GetLine() + chr(13) + chr(10)
	   end
	   oArq:Close()
	endif

	oForm:GetModel("ARQUIVO"):SetValue("CONTEUDO", cContent)
return .t.

/*/{Protheus.doc} VC040062_Directory
	Função Directory praticamente porem retorna com o caminho do 
	arquivo e o caminho+nome para ver conteudo
	
	@type functionadmin
	@author Vinicius Gati
	@since 11/03/2019
/*/
static function VC040062_Directory(cPath, cFilePattern)
	local nX := 1
	local aFiles := {}

	aFiles := Directory(cPath + cFilePattern)

	For nX:= 1 to Len(aFiles)
		aFiles[nX, 5] := cPath // path
		AADD(aFiles[nX], cPath + aFiles[nX, 1]) // full path
	Next
return aFiles

/*/{Protheus.doc} VC040072_DeletaArquivo
	Deleta arquivo da pasta logsmil somente se extensão for .log
	
	@type function
	@author Vinicius Gati
	@since 13/03/2019
/*/
static function VC040072_DeletaArquivo(oModel)
	local oForm := oModel:oFormModel
	local oFile := oForm:GetModel("FILES")
	local cArq  := alltrim(oFile:GetValue("PATH")) + alltrim(oFile:GetValue("FILENAME"))
	if RIGHT(cArq, 3) == "LOG"
		If FERASE(cArq) == -1
			MsgStop('Falha na deleção do Arquivo')
		Else
			MsgStop('Arquivo deletado com sucesso.')
		Endif
	else
		MsgStop('Arquivo não é de log.')
	endif
return .t.