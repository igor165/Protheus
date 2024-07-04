// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 27     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "PROTHEUS.CH"
#include "OFIOA560.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007464_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA560 ³ Autor ³ Andre Luis Almeida                ³ Data ³ 04/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Tabelas Genericas do Gestao de Concessionarias ( VX5 )     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina / Auto-Pecas / Veiculos                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA560(cParTab)
Local cFilVX5     := xFilial("VX5")
Local ni          := 0
Local aAux        := {}
Local lErro       := .f.
Local aTab        := {}
Local aRet        := {}
Local aParamBox   := {}
Local cCodMar     := GetNewPar("MV_MIL0006","")
Private aVX5      := {}
Private cVX5      := ""
Private cCadastro := STR0001 // Tabelas Genericas do Gestao de Concessionarias
Private aRotina   := MenuDef()
Private cTabBloq  := "028/_FL/"
Default cParTab   := ""

/////////////
// TABELAS //
/////////////
// aVX5[n,1] = 000 - Agrupador de Tabelas
// aVX5[n,2] = Codigo da Tabela
// aVX5[n,3] = Descrição da Tabela
// aVX5[n,4] = Proprietario "S"
// aVX5[n,5] = Campo Padrao a ser utilizado para buscar o tamanho do Codigo dos registros na Tabela
// aVX5[n,6] = Tamanho Default do Codigo dos registros na Tabela quando nao existe o campo no SX3 ( Default 10 )
//
aAdd(aVX5,{"000","001",STR0014													,"S","VMN_MODEND"	,0}) // Modalidade de Endividamento
aAdd(aVX5,{"000","002",STR0015													,"S","VMV_TIPINS"	,0}) // Tipos de Infra
aAdd(aVX5,{"000","003",STR0016													,"S","VMK_CODCUL"	,0}) // Culturas
If cCodMar == "JD" // Tabelas especificas para a marca John Deere
	aAdd(aVX5,{'000','004','Tipo de Cliente - John Deere'						,'S',"VMY_CTYPE"	,0})
	aAdd(aVX5,{'000','005','Unidade de Medida - John Deere'						,'S',"VMB_UNIMED"	,0})
	aAdd(aVX5,{'000','006','Tipo de Garantia - John Deere'						,'S',"VMB_TIPGAR"	,0})
	aAdd(aVX5,{'000','007','Finalidade - John Deere'							,'S',"VMY_MKTCOD"	,0})
	aAdd(aVX5,{'000','008','Aplicacao para Garantia de Bateria - John Deere'	,'S',"VMB_APLICA"	,0})
	aAdd(aVX5,{'000','009','Aplicacao para Garantia de Track - John Deere'		,'S',"VMB_APLICA"	,0})
	aAdd(aVX5,{'000','010','Subtipo de Garantia - John Deere'					,'S',"VMB_SUBGAR"	,0})
	aAdd(aVX5,{'000','011','Falha - John Deere'									,'S',"VMB_FALHA"	,0})
	aAdd(aVX5,{'000','012','Tempo de Maquina Parada - John Deere'				,'S',"VMB_MAQPAR"	,0})
	aAdd(aVX5,{'000','013','Tipo de Autorizacao Especial - John Deere'			,'S',"VMB_TIPESP"	,0})
	aAdd(aVX5,{'000','014','Intervalo de Servico - John Deere'					,'S',"VMB_INTSRV"	,0})
	aAdd(aVX5,{'000','015','Tipo de Maquina - John Deere'						,'S',"VMB_TIPMAQ"	,0})
	aAdd(aVX5,{'000','016','Status de Garantia - John Deere'					,'S',""				,0})
	aAdd(aVX5,{'000','017','Tipo de Servico - John Deere'						,'S',"VMC_TIPTRA"	,0})
	aAdd(aVX5,{'000','018','Localidade de Servico - John Deere'					,'S',""				,0})
	aAdd(aVX5,{'000','019','Tipo de Pmp - John Deere'							,'S',""				,0})
	aAdd(aVX5,{'000','020','Tipo de Garantia - John Deere'						,'S',""				,0})
	aAdd(aVX5,{'000','021','Status de Contrato - John Deere'					,'S',""				,0})
	aAdd(aVX5,{'000','022','Cód. Outros Creditos - John Deere'					,'S',"VMC_CODMAT"	,0})
	aAdd(aVX5,{'000','023','Status de Maquina - John Deere'						,'S',""				,0})
	aAdd(aVX5,{'000','024','Falha (Bateria) - John Deere'						,'S',"VMB_FALHA"	,0})
EndIf
aAdd(aVX5,{'000',"025",STR0017													,"S","VDL_PERFIL"	,0}) // Perfil do Cliente
aAdd(aVX5,{'000',"026",STR0018													,"S","VDM_CAMPOP"	,0}) // Campanha da Oportunidade  de Negócio
aAdd(aVX5,{'000',"027",STR0019													,"S","VDM_TIPMID"	,0}) // Tipos de Mídia
aAdd(aVX5,{'000','028',STR0020													,'S',"VE1_MARFAB"	,0}) // Marcas
If cCodMar == "JD" // Tabelas especificas para a marca John Deere
	aAdd(aVX5,{'000','029','Codigo de troca - John Deere'						,'S',""				,0})
EndIf
aAdd(aVX5,{'000','030',STR0021													,'S',""				,0}) // Bancos
aAdd(aVX5,{'000','031',STR0022													,'S',"VDM_FASFIN"	,0}) // Fase Financiamento
aAdd(aVX5,{'000','032',STR0023													,'S',"VDM_LINCRE"	,0}) // Linha de Credito
aAdd(aVX5,{'000','033',STR0024													,'S',"VCF_CODSEG"	,0}) // Segmentos de Mercados
aAdd(aVX5,{'000','034',STR0025													,'S',"VST_CODFAL"	,0}) // Codigos de Falha
aAdd(aVX5,{'000','035',STR0026													,'S',"VER_AGRUPA"	,0}) // Agrupadores Metas de Vendas
If cCodMar == "JD" // Tabelas especificas para a marca John Deere
	aAdd(aVX5,{'000','036',"Tipos de Pedido - John Deere"						,'S',""				,0}) // Tipos de Pedido
EndIf
aAdd(aVX5, {'000', '037', STR0028												,'S',""				,0})
aAdd(aVX5, {'000', '038', STR0029												,'S',"VG6_TPCUST"	,0})
If cCodMar == "NHC" // Tabelas especificas para a marca New Holland Construction
	aAdd(aVX5, {'000', '039', 'TIPO DE GARANTIA - NEW HOLLAND CONSTRUCTION'		,'S',""				,0})
	aAdd(aVX5, {'000', '040', 'CODIGO DE FALHA - NEW HOLLAND CONSTRUCTION'		,'S',"VGH_FALHA"	,0})
	aAdd(aVX5, {'000', '041', 'TIPO DE RECLAMACAO - NEW HOLLAND CONSTRUCTION'	,'S',"VGH_TIPREC"	,0})
	aAdd(aVX5, {'000', '042', 'CONDICAO DE GARANTIA - NEW HOLLAND CONSTRUCTION'	,'S',"VGH_CGAR"		,0})
EndIf
aAdd(aVX5,{'000', '043', STR0051												,'S',"VQM_TIPSER"	,0}) // Tipo de Serviço para Prestação de Serviços Diversos
aAdd(aVX5,{'000', '044', STR0052												,'S',"VDM_DECVDA"	,0}) // Decisão de Venda
aAdd(aVX5,{'000', '045', STR0054												,'S',"VQQ_CMPMOT"	,0}) // Complemento do Motor
aAdd(aVX5,{'000', '046', STR0060												,'S',""				,0}) // Grupo de Checklist
aAdd(aVX5,{'000', '047', STR0061												,'S',""				,0}) // Tipo de Ordem de Serviço
aAdd(aVX5,{'000', '048', STR0063												,'S',""				,0}) // Tipo de Manutenção
aAdd(aVX5,{'000', '049', STR0064												,'S',""				,0}) // Origem Evento do Diário
aAdd(aVX5,{'000', '050', STR0056												,'S',"VO1_TPATEN"	,0}) // Tipo de Atendimento
If cCodMar == "JD" // Tabelas especificas para a marca John Deere
	aAdd(aVX5,{'000', '051', "Eventos para Bonus de Pedido - John Deere"		,'S',"VQ0_EVENTO"	,0})
EndIf
aAdd(aVX5,{'000', '052', STR0059												,'S',"VAI_CLAHAB"	,1}) // Classificação da Habilidade do Técnico
aAdd(aVX5,{'000', '053', STR0062												,'S',"VQW_TIPSIN"	,4}) // Tipo de Sinistro (Cad.Seguros)

aAdd(aVX5,{'000', '075', "Origem para alerta de alteração de campos"			,'S',"VJT_ORIGEM"	,1})
aAdd(aVX5,{'000', '076', STR0065												,'S',"VV1_COMVEI"	,1}) // Combustiveis
If cCodMar $ "CHL-MSF-VAL-FDT" // Especificos para as marcas Challenger, Massey Ferguson e Valtra (AGCO)
	aAdd(aVX5,{'000', '078', "Gerencial Referencial DFS AGCO"					,'S',"VFF_CODGRF"	,4}) // Gerencial Referencial DFS AGCO
	aAdd(aVX5,{'000', '079', "Departamentos Referencial DFS AGCO"				,'S',"VFF_CODDRF"	,4}) // Gerencial Referencial DFS AGCO
	aAdd(aVX5,{'000', '080', "Plano Contábil DFS AGCO"							,'S',""				,4}) // Plano Contábil DFS AGCO
EndIf

aAdd(aVX5,{'000', '077', STR0085												,'S',"VS1_PRISEP"	,2}) // Prioridade Separação/Conferência

//
If cCodMar == "JD" // Tabelas especificas para a marca John Deere
	aAdd(aVX5,{'000','071','JDQUOTE - QUOTE TYPE'								,'S',""				,0})
	aAdd(aVX5,{'000','072','JDQUOTE - QUOTE STATUS'								,'S',""				,0})
	aAdd(aVX5,{'000','073','JDQUOTE - MOTIVO VENDA PERDIDA'						,'S',""				,0})
	aAdd(aVX5,{'000','074','JDQUOTE - ULTIMA MARCA'								,'S',""				,0})
EndIf
If ( VV2->(ColumnPos("VV2_CORINT")) > 0 )
	aAdd(aVX5,{'000', '066', "Cor Interna - Modelo de Veículo"			,'S',"VV2_CORINT"	,TamSX3("VV2_CORINT")[1]}) // Cor Interna - Modelo de Veículo
	aAdd(aVX5,{'000', '067', "Cor Externa - Modelo de Veículo"			,'S',"VV2_COREXT"	,TamSX3("VV2_COREXT")[1]}) // Cor Externa - Modelo de Veículo
	aAdd(aVX5,{'000', '068', "Opcional - Modelo de Veículo"				,'S',"VV2_OPCION"	,TamSX3("VV2_OPCION")[1]}) // Opcional - Modelo de Veículo
EndIf
//
aAdd(aVX5,{'000', '070', "Tipo de Evento - Log Genérico"				,'S',"VX0_TIPO"	,4}) // Tipo de Evento - Log Genérico

aAdd(aVX5,{'000', '081', "Merchandising Cliente"						,'S',"VCF_MERLBM",3}) // Merchandising Cliente

If cCodMar == "JD" // Tabelas especificas para a marca John Deere
	aAdd(aVX5,{'000', '082', "Base Codes - John Deere"						,'S',"",6}) // Base Codes - John Deere
EndIf

aAdd(aVX5,{'000', '083', "Mensagem WS" ,'S',"",2})
aAdd(aVX5,{'000', '084', "Tipo de Dado - LOG WS" ,'S',"",2})
aAdd(aVX5,{'000', '085', "Origem - LOG WS" ,'S',"",2})

//
OA560FILHO(cCodMar) // Adiciona os registros filhos PADRAO das Tabelas VX5
//
//
//
// TABELAS CUSTOMIZADAS //
//
If ExistBlock("OF560VX5")
	aAux := ExecBlock("OF560VX5",.f.,.f.,{ "1" , "" }) // 1 = Tabelas Customizadas de 'Z00' a 'ZZZ'
	If ValType(aAux) == "A"
		lErro := .f.
		For ni := 1 to len(aAux)
			If len(aAux[ni,1]) == 3 .and. aAux[ni,1] >= "Z00" .and. aAux[ni,1] <= "ZZZ"
				If Len(aAux[ni]) > 2
					aAdd(aVX5,{ '000' , aAux[ni,1] , aAux[ni,2] , 'U' , aAux[ni,3] , aAux[ni,4] }) // Tabela Z?? customizada no VX5
				Else
					aAdd(aVX5,{ '000' , aAux[ni,1] , aAux[ni,2] , 'U' }) // Tabela Z?? customizada no VX5
				EndIf
			Else
				lErro := .t.
				Exit
			EndIf
		Next
		If lErro
			MsgStop(STR0053,STR0005) // Os códigos das tabelas customizadas devem ser de 'Z00' a 'ZZZ'. / Atenção
		EndIf
	EndIf
EndIf
//
//aSort(aVX5,1,,{|x,y| x[3] < y[3] }) // Ordem: Descricao da Tabela
//
DbSelectArea("VX5")
DbSetOrder(1)
//
For ni := 1 to len(aVX5)
	VX5->(DbSeek(cFilVX5+aVX5[ni,1]+left(aVX5[ni,2]+space(10),10)))
	If !Found() .or. VX5->VX5_PROPRI == "U"
		RecLock("VX5",!Found())
		VX5->VX5_FILIAL := cFilVX5
		VX5->VX5_CHAVE  := aVX5[ni,1]
		VX5->VX5_CODIGO := left(aVX5[ni,2]+space(10),10)
		VX5->VX5_DESCRI := aVX5[ni,3]
		VX5->VX5_PROPRI := aVX5[ni,4]
		if VX5->(FieldPos('VX5_UUID')) > 0 .and. empty(VX5->VX5_UUID)
			VX5->VX5_UUID := FWUUIDV4(.t.)
		endif
		if VX5->(FieldPos('VX5_DATALT')) > 0
			if Found()
				VX5->VX5_DATALT := FGX_Timestamp()
			else
				VX5->VX5_DATINC := FGX_Timestamp()
			endif
		endif
		MsUnLock()
	EndIf
	If aVX5[ni,1] == "000" // Chaves das Tabelas
		aAdd(aTab,aVX5[ni,2]+'='+aVX5[ni,3])
	EndIf
Next
//
If Empty(cParTab)
	AADD(aParamBox,{2,STR0002,"",aTab,120,"!Empty(MV_PAR01)",.t.}) // Tabela
	If ParamBox(aParamBox,"",@aRet,,,,,,,,.f.)
		cVX5 := aRet[01] // Chave da Tabela escolhida
	Else
		Return()
	EndIf
Else
	cVX5 := cParTab // Tabela enviada por parametro
EndIf
//
If !Empty(cVX5)
	cCadastro := FM_SQL("SELECT VX5_DESCRI FROM "+RetSQLName("VX5")+" WHERE VX5_FILIAL='"+cFilVX5+"' AND VX5_CHAVE='000' AND VX5_CODIGO='"+left(cVX5+space(10),10)+"' AND D_E_L_E_T_=' '")
	DbSelectArea("VX5")
	DbGoTop()
	mBrowse( 6, 1,22,75,"VX5",,,,,,,,,,,,,,(" VX5_CHAVE='"+cVX5+"' "))
	DbSelectArea("VX5")
EndIf
//
If Empty(cParTab)
	OFIOA560() // Chamar tela novamente
EndIf
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OA560FILHO³ Autor ³ Andre Luis Almeida               ³ Data ³ 18/09/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Adiciona registros filhos PADRAO das tabelas VX5                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OA560FILHO(cCodMar)
//
// aVX5[n,1] = Codigo da Tabela
// aVX5[n,2] = Codigo do Registro
// aVX5[n,3] = Descrição do Regsitro
// aVX5[n,4] = Proprietario "S"
// aVX5[n,5] = Elemento utilizado somente no Pai - Agrupamento das Tabelas ( quando Codigo da Tabela for 000 )
// aVX5[n,6] = Elemento utilizado somente no Pai - Agrupamento das Tabelas ( quando Codigo da Tabela for 000 )
//
aAdd(aVX5,{'028','CHY','CHERY'													,'S',"",0})
aAdd(aVX5,{'028','GM' ,'DAFRA'													,'S',"",0})
aAdd(aVX5,{'028','FI' ,'FIAT'													,'S',"",0})
aAdd(aVX5,{'028','FD' ,'FORD'													,'S',"",0})
aAdd(aVX5,{'028','GM' ,'GENERAL MOTORS'											,'S',"",0})
aAdd(aVX5,{'028','HON','HONDA'													,'S',"",0})
aAdd(aVX5,{'028','HY' ,'HYUNDAI'												,'S',"",0})
aAdd(aVX5,{'028','KIA','KIA MOTORS'												,'S',"",0})
aAdd(aVX5,{'028','LIF','LIFAN'													,'S',"",0})
aAdd(aVX5,{'028','MAN','MAN'													,'S',"",0})
aAdd(aVX5,{'028','MIT','MITSUBISHI'												,'S',"",0})
aAdd(aVX5,{'028','NIS','NISSAN'													,'S',"",0})
aAdd(aVX5,{'028','REN','RENAULT'												,'S',"",0})
aAdd(aVX5,{'028','SCA','SCANIA'													,'S',"",0})
aAdd(aVX5,{'028','TOY','TOYOTA'													,'S',"",0})
aAdd(aVX5,{'028','VW' ,'VOLKSWAGEN'												,'S',"",0})
aAdd(aVX5,{'028','PEG','PEUGEOT'												,'S',"",0})
aAdd(aVX5,{'028','YAM','YAMAHA'													,'S',"",0})
aAdd(aVX5,{'028','JD' ,'JOHN DEERE'												,'S',"",0})
aAdd(aVX5,{'028','TMK','THERMO KING'											,'S',"",0})
aAdd(aVX5,{'028','NHA','NEW HOLLAND AGRICULTURE'								,'S',"",0})
aAdd(aVX5,{'028','NHC','NEW HOLLAND CONSTRUCTION'								,'S',"",0})
aAdd(aVX5,{'028','ATL','ATLAS COPCO'											,'S',"",0})
aAdd(aVX5,{'028','GHL','GHEL'													,'S',"",0})
aAdd(aVX5,{'028','KOM','KOMATSU'												,'S',"",0})
aAdd(aVX5,{'028','CHL','CHALLENGER'												,'S',"",0})
aAdd(aVX5,{'028','CSA','CASE AGRICULTURE'										,'S',"",0})
aAdd(aVX5,{'028','CSC','CASE CONSTRUCTION'										,'S',"",0})
aAdd(aVX5,{'028','VAL','VALTRA'													,'S',"",0})
aAdd(aVX5,{'028','MSF','MASSEY FERGUSON'										,'S',"",0})
aAdd(aVX5,{'028','GRS','GREEN SYSTEM - JOHN DEERE'								,'S',"",0})
aAdd(aVX5,{'028','PLA','PLA - JOHN DEERE'										,'S',"",0})
aAdd(aVX5,{'028','MHY','MONTADORA - HYUNDAI'									,'S',"",0})
aAdd(aVX5,{'028','FDT','FENDT'													,'S',"",0})
aAdd(aVX5,{'028','JDC','JOHN DEERE CONSTRUCTION'								,'S',"",0})
aAdd(aVX5,{'028','HCM','HITACHI - JOHN DEERE'									,'S',"",0})
//
aAdd(aVX5,{'038','MAT',STR0049													,'S',"",0})
aAdd(aVX5,{'038','OLL',STR0050													,'S',"",0})
aAdd(aVX5,{'038','MOT',STR0030													,'S',"",0})
aAdd(aVX5,{'038','RR ',STR0031													,'S',"",0})
aAdd(aVX5,{'038','TO ',STR0032													,'S',"",0})
aAdd(aVX5,{'038','MO ',STR0033													,'S',"",0})
aAdd(aVX5,{'038','O01',STR0034													,'S',"",0})
aAdd(aVX5,{'038','O02',STR0035													,'S',"",0})
aAdd(aVX5,{'038','O03',STR0036													,'S',"",0})
aAdd(aVX5,{'038','O05',STR0037													,'S',"",0})
aAdd(aVX5,{'038','O07',STR0038													,'S',"",0})
aAdd(aVX5,{'038','O08',STR0039													,'S',"",0})
aAdd(aVX5,{'038','O09',STR0040													,'S',"",0})
aAdd(aVX5,{'038','O11',STR0041													,'S',"",0})
aAdd(aVX5,{'038','O12',STR0042													,'S',"",0})
aAdd(aVX5,{'038','O13',STR0043													,'S',"",0})
aAdd(aVX5,{'038','O15',STR0044													,'S',"",0})
aAdd(aVX5,{'038','M04',STR0045													,'S',"",0})
aAdd(aVX5,{'038','M10',STR0046													,'S',"",0})
aAdd(aVX5,{'038','M14',STR0047													,'S',"",0})
aAdd(aVX5,{'038','M06',STR0048													,'S',"",0})
//
Do Case
	Case cCodMar == "JD" // Especificos para a marca John Deere
		//
		aAdd(aVX5,{'007','13','ANIMAIS / LACTACAO / ALIMENTACAO'				,'S',"",0})
		aAdd(aVX5,{'007','15','PLANTAS / GRAOS PEQUENOS'						,'S',"",0})
		aAdd(aVX5,{'007','16','CULTIVO ESPECIAL'								,'S',"",0})
		aAdd(aVX5,{'007','17','UTILIDADES GERAIS'								,'S',"",0})
		aAdd(aVX5,{'007','41','CONTRUCAO CASAS & EDIFICIOS'						,'S',"",0})
		aAdd(aVX5,{'007','43','SISTEMAS DE AGUA E ESGOTO'						,'S',"",0})
		aAdd(aVX5,{'007','49','RODOVIAS & RUAS'									,'S',"",0})
		aAdd(aVX5,{'007','71','AEROPORTOS'										,'S',"",0})
		aAdd(aVX5,{'007','74','FERROVIARIA'										,'S',"",0})
		aAdd(aVX5,{'007','81','COMPANHIA DE TELEFONE'							,'S',"",0})
		aAdd(aVX5,{'007','82','GAS, AGUA E ELETRICIDADE'						,'S',"",0})
		aAdd(aVX5,{'007','84','ATERROS (LIXO)'									,'S',"",0})
		aAdd(aVX5,{'007','87','PARQUES'											,'S',"",0})
		aAdd(aVX5,{'007','89','RESIDENCIAL'										,'S',"",0})
		aAdd(aVX5,{'007','90','CONCESSIONARIO JOHN DEERE'						,'S',"",0})
		aAdd(aVX5,{'007','92','MOVIMENTO DE RODOVIAS'							,'S',"",0})
		aAdd(aVX5,{'007','93','VIVEIROS E JARDINS'								,'S',"",0})
		aAdd(aVX5,{'007','94','CAMPOS DE GOLF'									,'S',"",0})
		aAdd(aVX5,{'007','95','INSTITUICÕES'									,'S',"",0})
		aAdd(aVX5,{'007','96','EMPRESA DE ALUGUEL INDEPENDENTE'					,'S',"",0})
		aAdd(aVX5,{'007','98','INDEFINIDO'										,'S',"",0})
		//
		aAdd(aVX5,{'004','01','COMERCIAL'										,'S',"",0})
		aAdd(aVX5,{'004','02','GOVERNO FEDERAL'									,'S',"",0})
		aAdd(aVX5,{'004','03','ESTADO / REGIAO'									,'S',"",0})
		aAdd(aVX5,{'004','04','PAIS'											,'S',"",0})
		aAdd(aVX5,{'004','05','CIDADE'											,'S',"",0})
		aAdd(aVX5,{'004','06','FORCAS ARMADAS'									,'S',"",0})
		aAdd(aVX5,{'004','07','CONTA NACIONAL'									,'S',"",0})
		aAdd(aVX5,{'004','08','RESIDENCIAL'										,'S',"",0})
		aAdd(aVX5,{'004','09','FAZENDA'											,'S',"",0})
		aAdd(aVX5,{'004','L ','FROTA GRANDE (25-74)'							,'S',"",0})
		aAdd(aVX5,{'004','M ','FROTA MÉDIA (10-24)'								,'S',"",0})
		aAdd(aVX5,{'004','S ','FROTA PEQUENA (<10)'								,'S',"",0})
		aAdd(aVX5,{'004','V ','FROTA MUITO GRANDE (>74)'						,'S',"",0})
		//
		aAdd(aVX5,{'005','Acre','ACRES'											,'S',"",0})
		aAdd(aVX5,{'005','D','DIAS'												,'S',"",0})
		aAdd(aVX5,{'005','H','HORAS'											,'S',"",0})
		aAdd(aVX5,{'005','Hectar','HECTARES'									,'S',"",0})
		aAdd(aVX5,{'005','Hrs','SEPARATOR HOURS'								,'S',"",0})
		aAdd(aVX5,{'005','Km','KILOMETROS'										,'S',"",0})
		aAdd(aVX5,{'005','Mile','MILHAS'										,'S',"",0})
		aAdd(aVX5,{'005','Pc','FARDO'											,'S',"",0})
		//
		aAdd(aVX5,{'006','ZNRM','NORMAL'										,'S',"",0})
		aAdd(aVX5,{'006','ZPIP','PMP (PIP)'										,'S',"",0})
		aAdd(aVX5,{'006','ZPAR','PECAS'											,'S',"",0})
		aAdd(aVX5,{'006','ZSPA','AUTORIZACAO ESPECIAL'							,'S',"",0})
		aAdd(aVX5,{'006','ZZTK','ESTEIRAS'										,'S',"",0})
		aAdd(aVX5,{'006','ZZBT','BATERIA'										,'S',"",0})
		aAdd(aVX5,{'006','ZZMK','MARKETING'										,'S',"",0})
		//
		aAdd(aVX5,{'008','AUTO','CARRO/CAMINHONETE MENOS DE 1T'					,'S',"",0})
		aAdd(aVX5,{'008','COPR','PRODUTO DO CONSUMIDOR'							,'S',"",0})
		aAdd(aVX5,{'008','CVEH','VEICULO COMERCIAL'								,'S',"",0})
		aAdd(aVX5,{'008','FIND','AGRICOLA OU INDUSTRIAL'						,'S',"",0})
		aAdd(aVX5,{'008','OTHR','OUTRO'											,'S',"",0})
		//
		aAdd(aVX5,{'009','AGRI','AGRICULTURA'									,'S',"",0})
		aAdd(aVX5,{'009','CONS','CONSTRUCAO'									,'S',"",0})
		//
		aAdd(aVX5,{'010','MTC','PLANO DE MANUTECAO'								,'S',"",0})
		//
		aAdd(aVX5,{'011','01','CURVADO/TORCIDO/DESALINHADO'						,'S',"",0})
		aAdd(aVX5,{'011','02','SOPRANDO'										,'S',"",0})
		aAdd(aVX5,{'011','03','QUEBRADO/RACHADO'								,'S',"",0})
		aAdd(aVX5,{'011','04','QUEIMADO'										,'S',"",0})
		aAdd(aVX5,{'011','05','CALIBRACAO'										,'S',"",0})
		aAdd(aVX5,{'011','06','FROUXO'											,'S',"",0})
		aAdd(aVX5,{'011','07','BATIDO'											,'S',"",0})
		aAdd(aVX5,{'011','08','CORROIDO'										,'S',"",0})
		aAdd(aVX5,{'011','09','CORTE'											,'S',"",0})
		aAdd(aVX5,{'011','10','CONEXAO ELETRICA'								,'S',"",0})
		aAdd(aVX5,{'011','11','FALHA ELETRICA'									,'S',"",0})
		aAdd(aVX5,{'011','12','AJUSTE IMPROPRIO'								,'S',"",0})
		aAdd(aVX5,{'011','13','FALTA DE POTENCIA'								,'S',"",0})
		aAdd(aVX5,{'011','14','VAZAMENTO'										,'S',"",0})
		aAdd(aVX5,{'011','15','CONSUMO DE OLEO'									,'S',"",0})
		aAdd(aVX5,{'011','16','OMITIDO/FALTANDO'								,'S',"",0})
		aAdd(aVX5,{'011','17','OUTRO (REQUER EXPLICACAO)'						,'S',"",0})
		aAdd(aVX5,{'011','18','FORA DO AJUSTE'									,'S',"",0})
		aAdd(aVX5,{'011','19','SUPERAQUECIDO'									,'S',"",0})
		aAdd(aVX5,{'011','20','ORIFICIO ALARGADO/POROSO'						,'S',"",0})
		aAdd(aVX5,{'011','21','PRESSAO BAIXA/ELEVADA'							,'S',"",0})
		aAdd(aVX5,{'011','22','ROTEAMENTO'										,'S',"",0})
		aAdd(aVX5,{'011','23','MARCADO/RANHURAS'								,'S',"",0})
		aAdd(aVX5,{'011','24','CURTO CIRCUITO/ENCIRCUITADO'						,'S',"",0})
		aAdd(aVX5,{'011','25','ENGATE DE MARCHA'								,'S',"",0})
		aAdd(aVX5,{'011','26','SOFTWARE REPROGRAMADO'							,'S',"",0})
		aAdd(aVX5,{'011','27','DESMANCHADO'										,'S',"",0})
		aAdd(aVX5,{'011','28','FUNDIDO'											,'S',"",0})
		aAdd(aVX5,{'011','29','VIBRACAO'										,'S',"",0})
		aAdd(aVX5,{'011','30','DESGASTADO'										,'S',"",0})
		aAdd(aVX5,{'011','31','INSTALADO PECA ERRADA'							,'S',"",0})
		//
		aAdd(aVX5,{'012','10','NENHUM TEMPO DE MAQUINA PARADA'					,'S',"",0})
		aAdd(aVX5,{'012','20','MENOS DE 4 HORAS'								,'S',"",0})
		aAdd(aVX5,{'012','30','MENOS DE 1 DIA'									,'S',"",0})
		aAdd(aVX5,{'012','40','MAIS DO QUE 1 DIA'								,'S',"",0})
		aAdd(aVX5,{'012','50','MAIS DO QUE 1 SEMANA'							,'S',"",0})
		aAdd(aVX5,{'012','60','DESCONHECIDO'									,'S',"",0})
		//
		aAdd(aVX5,{'013','01','ADMINIS. POR CONCESSIONARIA (C&F)'				,'S',"",0})
		aAdd(aVX5,{'013','02','GESTO DE BOA VONTADE'							,'S',"",0})
		aAdd(aVX5,{'013','03','PRODUTO'											,'S',"",0})
		aAdd(aVX5,{'013','04','EXPERIMENTAL/ENGENHARIA'							,'S',"",0})
		aAdd(aVX5,{'013','05','VENDAS'											,'S',"",0})
		aAdd(aVX5,{'013','06','POLITICA DE PROCESSAMENTO'						,'S',"",0})
		aAdd(aVX5,{'013','07','SERVICO PECA COM DEFEITO'						,'S',"",0})
		aAdd(aVX5,{'013','08','FIU'												,'S',"",0})
		aAdd(aVX5,{'013','09','SEGURO DE DESGASTE (C&F)'						,'S',"",0})
		aAdd(aVX5,{'013','10','SEGURO DE GIRO LUBRIFICAD (C&F)'					,'S',"",0})
		aAdd(aVX5,{'013','11','STRUCTURAL (C&F)'								,'S',"",0})
		//
		aAdd(aVX5,{'014','PDI','INSPECAO DE PRÉ ENTREGA'						,'S',"",0})
		aAdd(aVX5,{'014','ADI','INSPECAO APÓS A ENTREGA'						,'S',"",0})
		aAdd(aVX5,{'014','BRKN','BREAK-IN'										,'S',"",0})
		aAdd(aVX5,{'014','PRMO','PROMOCIONAL'									,'S',"",0})
		aAdd(aVX5,{'014','INST','INSTALACAO'									,'S',"",0})
		aAdd(aVX5,{'014','MNT1','PRIMEIRA MANUTENCAO'							,'S',"",0})
		aAdd(aVX5,{'014','MNT2','SEGUNDA MANUTENCAO'							,'S',"",0})
		aAdd(aVX5,{'014','MNT3','TERCEIRA MANUTENCAO'							,'S',"",0})
		aAdd(aVX5,{'014','MNT4','QUARTA MANUTENCAO'								,'S',"",0})
		aAdd(aVX5,{'014','MNT5','QUINTA MANUTENCAO'								,'S',"",0})
		aAdd(aVX5,{'014','MNT6','SEXTA MANUTENCAO'								,'S',"",0})
		aAdd(aVX5,{'014','MNT7','SETIMA MANUTENCAO'								,'S',"",0})
		aAdd(aVX5,{'014','MNT8','OITAVA MANUTENCAO'								,'S',"",0})
		//
		aAdd(aVX5,{'015','NORM','NORMAL'										,'S',"",0})
		aAdd(aVX5,{'015','AMS','COM AMS '										,'S',"",0})
		aAdd(aVX5,{'015','TRACK','WITH TRACK NOT WHEELS'						,'S',"",0})
		aAdd(aVX5,{'015','TRAMS','TRACK WITH AMS'								,'S',"",0})
		//
		aAdd(aVX5,{'016','01','NOVO'											,'S',"",0})
		aAdd(aVX5,{'016','02','ENVIADO'											,'S',"",0})
		aAdd(aVX5,{'016','03','APROVADO (PAGO)'									,'S',"",0})
		aAdd(aVX5,{'016','04','REJEITADO'										,'S',"",0})
		aAdd(aVX5,{'016','05','DELETADO'										,'S',"",0})
		aAdd(aVX5,{'016','06','FORWARDED'										,'S',"",0})
		aAdd(aVX5,{'016','07','RETORNADO'										,'S',"",0})
		aAdd(aVX5,{'016','08','REVISADO'										,'S',"",0})
		aAdd(aVX5,{'016','09','AGUARDANDO NF'									,'S',"",0})
		aAdd(aVX5,{'016','12','NF ATUALIZADA'									,'S',"",0})
		aAdd(aVX5,{'016','15','DEBITADO'										,'S',"",0})
		//
		aAdd(aVX5,{'017','WTYLABORA','CONSERTAR'								,'S',"",0})
		aAdd(aVX5,{'017','WTYLABORB','LIMPAR'									,'S',"",0})
		aAdd(aVX5,{'017','WTYLABORC','SOLDAR'									,'S',"",0})
		aAdd(aVX5,{'017','WTYLABORD','SERVICO ESPECIAL'							,'S',"",0})
		aAdd(aVX5,{'017','WTYLABORI','REMOVER'									,'S',"",0})
		aAdd(aVX5,{'017','WTYLABORJ','TEMPO DESLOCAMENTO'						,'S',"",0})
		aAdd(aVX5,{'017','WTYLABORK','PULVERIZAR'								,'S',"",0})
		aAdd(aVX5,{'017','WTYLABORL','DIAGNOSTICO'								,'S',"",0})
		aAdd(aVX5,{'017','WTYLABORM','TEMPO ACESSO'								,'S',"",0})
		//
		aAdd(aVX5,{'018','01','OFICINA'											,'S',"",0})
		aAdd(aVX5,{'018','02','CAMPO'											,'S',"",0})
		//
		aAdd(aVX5,{'019','FASF','TROCA QUANDO FALHA'							,'S',"",0})
		aAdd(aVX5,{'019','MALF','OBRIGATORIO'									,'S',"",0})
		aAdd(aVX5,{'019','OPT','OPCIONAL'										,'S',"",0})
		aAdd(aVX5,{'019','PEP','PROGRAMA DE MELHORAMENTO DE PRODUTO'			,'S',"",0})
		aAdd(aVX5,{'019','SAFT','SEGURANCA'										,'S',"",0})
		//
		aAdd(aVX5,{'020','B','GARANTIA BASICA'									,'S',"",0})
		aAdd(aVX5,{'020','C','WEAR ASSURANCE'									,'S',"",0})
		aAdd(aVX5,{'020','D','GARANTIA PREDETERMINADA'							,'S',"",0})
		aAdd(aVX5,{'020','E','GARANTIA DE MOTOR'								,'S',"",0})
		aAdd(aVX5,{'020','F','MAIN FRAME'										,'S',"",0})
		aAdd(aVX5,{'020','G','EXTENDED WARRANTY (ENGINE)'						,'S',"",0})
		aAdd(aVX5,{'020','H','EXTENDED WARRANTY (POWERTRAIN & HYDRAULIC)'		,'S',"",0})
		aAdd(aVX5,{'020','J','JD PROMISE'										,'S',"",0})
		aAdd(aVX5,{'020','M','EMISSIONS WARRANTY'								,'S',"",0})
		aAdd(aVX5,{'020','P','EXTENDED WARRANTY (POWERTRAIN)'					,'S',"",0})
		aAdd(aVX5,{'020','Q','LIMITED BASIC'									,'S',"",0})
		aAdd(aVX5,{'020','S','STRUCTUREALL'										,'S',"",0})
		aAdd(aVX5,{'020','U','FACTORY UNDERCARRIAGE'							,'S',"",0})
		aAdd(aVX5,{'020','V','MAX LIFE'											,'S',"",0})
		aAdd(aVX5,{'020','W','WET TURN'											,'S',"",0})
		aAdd(aVX5,{'020','X','EXTENDED WARRANTY (COMPREHENSIVE)'				,'S',"",0})
		//
		aAdd(aVX5,{'021','AVAL','DISPONIVEL'									,'S',"",0})
		//
		aAdd(aVX5,{'022','WTYSUBL1','TAXAS MEIO AMBIENTE'						,'S',"",0})
		aAdd(aVX5,{'022','WTYSUBL2','SUBLOCACAO'								,'S',"",0})
		aAdd(aVX5,{'022','WTYSUBL3','REEMBOLSO REFRIG./ADITIVO'					,'S',"",0})
		aAdd(aVX5,{'022','WTYSUBL4','HAULING (U.S. SOUTH DAKOTA DEALERS ONLY)'	,'S',"",0})
		aAdd(aVX5,{'022','WTYSUBL5','DESLOCAMENTO - KM'							,'S',"",0})
		aAdd(aVX5,{'022','WTYSUBL6','DESLOCAMENTO - MILHAS'						,'S',"",0})
		aAdd(aVX5,{'022','WTYSUBL7','OUTROS'									,'S',"",0})
		aAdd(aVX5,{'022','WTYSUBL8','DESLOCAMENTO - FIXO'						,'S',"",0})
		//
		aAdd(aVX5,{'023','NEW','MAQUINA NOVA'									,'S',"",0})
		aAdd(aVX5,{'023','USED','MAQUINA USADA'									,'S',"",0})
		aAdd(aVX5,{'023','PRNT','PREVIOUSLY RENTED'								,'S',"",0})
		aAdd(aVX5,{'023','RNTL','RENTAL MACHINE'								,'S',"",0})
		aAdd(aVX5,{'023','CHCK','CONSULT MACHINE NOTES'							,'S',"",0})
		aAdd(aVX5,{'023','CVFM','CONVERSION FORM REQUIRED'						,'S',"",0})
		aAdd(aVX5,{'023','DEMO','DEMONSTRACAO'									,'S',"",0})
		aAdd(aVX5,{'023','DMGD','DAMAGED'										,'S',"",0})
		aAdd(aVX5,{'023','LCUK','LOCATION UNKNOWN'								,'S',"",0})
		aAdd(aVX5,{'023','MGRT','MIGRATED'										,'S',"",0})
		aAdd(aVX5,{'023','ONRT','RENTAL MACHINE'								,'S',"",0})
		aAdd(aVX5,{'023','PRMS','JD PROMISE'									,'S',"",0})
		aAdd(aVX5,{'023','STL1','SECURITY ISSUE'								,'S',"",0})
		aAdd(aVX5,{'023','STL2','SECURITY ISSUE'								,'S',"",0})
		aAdd(aVX5,{'023','STLP','PROB. PLACA DE NUMERO SERIE'					,'S',"",0})
		aAdd(aVX5,{'023','SUSP','GARANTIA SUSPENSA'								,'S',"",0})
		aAdd(aVX5,{'023','VOID','GARANTIA ANULADA'								,'S',"",0})
		aAdd(aVX5,{'023','WTOF','INSURANCE WRITE-OFF'							,'S',"",0})
		aAdd(aVX5,{'023','WXT1','APPROVED FOR WTY EXT WHEN SOLD'				,'S',"",0})
		aAdd(aVX5,{'023','WXT2','WARRANTY ALLOWED WHEN SOLD'					,'S',"",0})
		aAdd(aVX5,{'023','WXT3','WARRANTY END DATE EXTENDED'					,'S',"",0})
		aAdd(aVX5,{'023','FOWN','PRIMEIRO DONO'									,'S',"",0})
		aAdd(aVX5,{'023','SCRP','SCRAPPED'										,'S',"",0})
		//
		aAdd(aVX5,{'024','71','BATERIA CELULA MORTA'							,'S',"",0})
		aAdd(aVX5,{'024','72','CASO DEFEITUOSO'									,'S',"",0})
		aAdd(aVX5,{'024','73','POLARIDADE INVERTIDA'							,'S',"",0})
		aAdd(aVX5,{'024','74','NAO SEGURA CARGA'								,'S',"",0})
		aAdd(aVX5,{'024','75','OUTRO (REQUER EXPLICACAO)'						,'S',"",0})
	    //
		aAdd(aVX5,{'029','0','NENHUMA PECA DEVE SER RETORNADA'					,'S',"",0})
		aAdd(aVX5,{'029','1','PECA DEVE SER RETORNADA'							,'S',"",0})
		aAdd(aVX5,{'029','2','ALGUMAS PECAS DEVEM SER RETORNADA'				,'S',"",0})
		aAdd(aVX5,{'029','3','TODAS AS PECAS RECEBIDAS'							,'S',"",0})
		aAdd(aVX5,{'029','4','NENHUMA PECA RECEBIDA'							,'S',"",0})
		aAdd(aVX5,{'029','5','ALGUMAS PECAS RETORNADAS'							,'S',"",0})
		aAdd(aVX5,{'029','6','TODAS AS PECAS RETORNADAS'						,'S',"",0})
		aAdd(aVX5,{'029','7','NENHUMA PECA RETORNADA'							,'S',"",0})
		aAdd(aVX5,{'029','8','PECA ERRADA RETORNADA'							,'S',"",0})
		//
		aAdd(aVX5,{'036','ORD_EMER','MD'										,'S',"",0})
		aAdd(aVX5,{'036','ORD_ISO','IS'											,'S',"",0})
		aAdd(aVX5,{'036','ORD_SO','SO'											,'S',"",0})
		aAdd(aVX5,{'036','ORD_TS','TS'											,'S',"",0})
		aAdd(aVX5,{'036','ORD_WO','WO'											,'S',"",0})
		//
		aAdd(aVX5,{'050', '0'  , STR0057										,'S',"",0}) // 'Interno'
		aAdd(aVX5,{'050', '1'  , STR0058										,'S',"",0}) // 'Externo'
    	//
		aAdd(aVX5,{'071', '2'  , 'Compra'										,'S',"",0})
		//
		aAdd(aVX5,{'072', '1'  , 'Ativo'										,'S',"",0})
		aAdd(aVX5,{'072', '2'  , 'Expirado'									,'S',"",0})
		aAdd(aVX5,{'072', '4'  , 'Venda Fechada'							,'S',"",0})
		aAdd(aVX5,{'072', '14' , 'Inquiry'									,'S',"",0})
		aAdd(aVX5,{'072', '16' , 'Venda Perdida'							,'S',"",0})
		aAdd(aVX5,{'072', '17' , 'Sem Compra'								,'S',"",0})
		aAdd(aVX5,{'072', '18' , 'Comprou equipamento usado'			,'S',"",0})

		aAdd(aVX5,{'073', '7'  , 'Suporte de Pós Vendas'									,'S',"",0})
		aAdd(aVX5,{'073', '8'  , 'Confiabilidade do Produto'								,'S',"",0})
		aAdd(aVX5,{'073', '9'  , 'Desempenho do Produto'									,'S',"",0})
		aAdd(aVX5,{'073', '10' , 'Disponibilidade do Produto'								,'S',"",0})
		aAdd(aVX5,{'073', '11' , 'Especificações do Produto'								,'S',"",0})
		aAdd(aVX5,{'073', '12' , 'Product knowledge (demonstration)'					,'S',"",0})
		aAdd(aVX5,{'073', '13' , 'Residual value'												,'S',"",0})
		aAdd(aVX5,{'073', '14' , 'Oferta de Usado'											,'S',"",0})
		aAdd(aVX5,{'073', '15' , 'Fidelidade à marca ou distribuidor concorrente'	,'S',"",0})
		aAdd(aVX5,{'073', '16' , 'Preço'															,'S',"",0})
		aAdd(aVX5,{'073', '17' , 'Opçoes de Financiamento'									,'S',"",0})
		aAdd(aVX5,{'073', '18' , 'Custo de manutenção'										,'S',"",0})
		aAdd(aVX5,{'073', '19' , 'Outros'														,'S',"",0})

		aAdd(aVX5,{'074', '1'  ,'AGRIFAC'									,'S',"",0})
		aAdd(aVX5,{'074', '2'  ,'AGRITECHNOLOGICAL CENTRE'					,'S',"",0})
		aAdd(aVX5,{'074', '3'  ,'AGROTEKHMASH'								,'S',"",0})
		aAdd(aVX5,{'074', '4'  ,'ALKO'										,'S',"",0})
		aAdd(aVX5,{'074', '5'  ,'ALÖ QUICKE'								,'S',"",0})
		aAdd(aVX5,{'074', '6'  ,'AMAZONE'									,'S',"",0})
		aAdd(aVX5,{'074', '7'  ,'AMITY'										,'S',"",0})
		aAdd(aVX5,{'074', '8'  ,'ATV'										,'S',"",0})
		aAdd(aVX5,{'074', '9'  ,'AUTOFARM'									,'S',"",0})
		aAdd(aVX5,{'074', '10' ,'BALTIETS'									,'S',"",0})
		aAdd(aVX5,{'074', '11' ,'BARGAM'									,'S',"",0})
		aAdd(aVX5,{'074', '12' ,'BATEMAN'									,'S',"",0})
		aAdd(aVX5,{'074', '13' ,'BERTHOUD'									,'S',"",0})
		aAdd(aVX5,{'074', '14' ,'BISO'										,'S',"",0})
		aAdd(aVX5,{'074', '15' ,'BOURGAULT'									,'S',"",0})
		aAdd(aVX5,{'074', '16' ,'BRYANSKSELMASH'							,'S',"",0})
		aAdd(aVX5,{'074', '17' ,'CAPELLO'									,'S',"",0})
		aAdd(aVX5,{'074', '18' ,'CASE IH'									,'S',"",0})
		aAdd(aVX5,{'074', '19' ,'CASTEL GARDEN'								,'S',"",0})
		aAdd(aVX5,{'074', '20' ,'CHAFER'									,'S',"",0})
		aAdd(aVX5,{'074', '21' ,'CHALLENGER / AGCO'							,'S',"",0})
		aAdd(aVX5,{'074', '22' ,'CLAAS'										,'S',"",0})
		aAdd(aVX5,{'074', '23' ,'CNH'										,'S',"",0})
		aAdd(aVX5,{'074', '24' ,'CRESSONI'									,'S',"",0})
		aAdd(aVX5,{'074', '25' ,'DAMMAN'									,'S',"",0})
		aAdd(aVX5,{'074', '26' ,'DEGELMANN'									,'S',"",0})
		aAdd(aVX5,{'074', '27' ,'DEUTZ-FAHR'								,'S',"",0})
		aAdd(aVX5,{'074', '28' ,'DOMINONI'									,'S',"",0})
		aAdd(aVX5,{'074', '29' ,'EINBOCK'									,'S',"",0})
		aAdd(aVX5,{'074', '30' ,'EVRARD'									,'S',"",0})
		aAdd(aVX5,{'074', '31' ,'FAHR'										,'S',"",0})
		aAdd(aVX5,{'074', '32' ,'FANTINI'									,'S',"",0})
		aAdd(aVX5,{'074', '33' ,'FELLA'										,'S',"",0})
		aAdd(aVX5,{'074', '34' ,'FENDT'										,'S',"",0})
		aAdd(aVX5,{'074', '35' ,'FERABOLLI'									,'S',"",0})
		aAdd(aVX5,{'074', '36' ,'FLEXICOIL'									,'S',"",0})
		aAdd(aVX5,{'074', '37' ,'GASPARDO'									,'S',"",0})
		aAdd(aVX5,{'074', '38' ,'GERINGHOFF'								,'S',"",0})
		aAdd(aVX5,{'074', '39' ,'GHERARDI'									,'S',"",0})
		aAdd(aVX5,{'074', '40' ,'GREAT PLAINS'								,'S',"",0})
		aAdd(aVX5,{'074', '41' ,'GREGOIRE BESSON'							,'S',"",0})
		aAdd(aVX5,{'074', '42' ,'HARDI'										,'S',"",0})
		aAdd(aVX5,{'074', '43' ,'HATZENBICHLER'								,'S',"",0})
		aAdd(aVX5,{'074', '44' ,'HAUER'										,'S',"",0})
		aAdd(aVX5,{'074', '45' ,'HAYTER'									,'S',"",0})
		aAdd(aVX5,{'074', '46' ,'HONDA'										,'S',"",0})
		aAdd(aVX5,{'074', '47' ,'HONEY BEE'									,'S',"",0})
		aAdd(aVX5,{'074', '48' ,'HORSCH'									,'S',"",0})
		aAdd(aVX5,{'074', '49' ,'HOUSEHAM'									,'S',"",0})
		aAdd(aVX5,{'074', '50' ,'HTZ'										,'S',"",0})
		aAdd(aVX5,{'074', '51' ,'HURLIMANN'									,'S',"",0})
		aAdd(aVX5,{'074', '52' ,'HUSQVARNA'									,'S',"",0})
		aAdd(aVX5,{'074', '53' ,'HYDRAC'									,'S',"",0})
		aAdd(aVX5,{'074', '54' ,'IDAAS'										,'S',"",0})
		aAdd(aVX5,{'074', '55' ,'ISAGRI'									,'S',"",0})
		aAdd(aVX5,{'074', '56' ,'ISEKI'										,'S',"",0})
		aAdd(aVX5,{'074', '57' ,'JACOBSON'									,'S',"",0})
		aAdd(aVX5,{'074', '58' ,'JACTO'										,'S',"",0})
		aAdd(aVX5,{'074', '59' ,'JCB'										,'S',"",0})
		aAdd(aVX5,{'074', '60' ,'JOHN DEERE'								,'S',"",0})
		aAdd(aVX5,{'074', '61' ,'KINZE'										,'S',"",0})
		aAdd(aVX5,{'074', '62' ,'KIOTI'										,'S',"",0})
		aAdd(aVX5,{'074', '63' ,'KNIGHT'									,'S',"",0})
		aAdd(aVX5,{'074', '64' ,'KRASNOYARSKIY COMBINE PLANT'				,'S',"",0})
		aAdd(aVX5,{'074', '65' ,'KRAUSE'									,'S',"",0})
		aAdd(aVX5,{'074', '66' ,'KRONE'										,'S',"",0})
		aAdd(aVX5,{'074', '67' ,'KUBOTA'									,'S',"",0})
		aAdd(aVX5,{'074', '68' ,'KUHN'										,'S',"",0})
		aAdd(aVX5,{'074', '69' ,'KV - RAU'									,'S',"",0})
		aAdd(aVX5,{'074', '70' ,'KVERNELAND'								,'S',"",0})
		aAdd(aVX5,{'074', '71' ,'LA FORGE'									,'S',"",0})
		aAdd(aVX5,{'074', '72' ,'LAMBORGHINI'								,'S',"",0})
		aAdd(aVX5,{'074', '73' ,'LANDINI'									,'S',"",0})
		aAdd(aVX5,{'074', '74' ,'LAVERDA'									,'S',"",0})
		aAdd(aVX5,{'074', '75' ,'LEMKEN'									,'S',"",0})
		aAdd(aVX5,{'074', '76' ,'MAC HALE'									,'S',"",0})
		aAdd(aVX5,{'074', '77' ,'MACDON'									,'S',"",0})
		aAdd(aVX5,{'074', '78' ,'MAILLEUX'									,'S',"",0})
		aAdd(aVX5,{'074', '79' ,'MANIP'										,'S',"",0})
		aAdd(aVX5,{'074', '80' ,'MASCHIO GASPARDO'							,'S',"",0})
		aAdd(aVX5,{'074', '81' ,'MASSEY FERGUSSON'							,'S',"",0})
		aAdd(aVX5,{'074', '82' ,'MATERMACC'									,'S',"",0})
		aAdd(aVX5,{'074', '83' ,'MATROT'									,'S',"",0})
		aAdd(aVX5,{'074', '84' ,'MCCORMICK'									,'S',"",0})
		aAdd(aVX5,{'074', '85' ,'MILLER'									,'S',"",0})
		aAdd(aVX5,{'074', '86' ,'MISC.'										,'S',"",0})
		aAdd(aVX5,{'074', '87' ,'MONOSEM'									,'S',"",0})
		aAdd(aVX5,{'074', '88' ,'MONTANA'									,'S',"",0})
		aAdd(aVX5,{'074', '89' ,'MORESIL'									,'S',"",0})
		aAdd(aVX5,{'074', '90' ,'MORRIS'									,'S',"",0})
		aAdd(aVX5,{'074', '91' ,'MTD'										,'S',"",0})
		aAdd(aVX5,{'074', '92' ,'MTZ'										,'S',"",0})
		aAdd(aVX5,{'074', '93' ,'MUELLER ELECTRONIC'						,'S',"",0})
		aAdd(aVX5,{'074', '94' ,'NEW HOLLAND'								,'S',"",0})
		aAdd(aVX5,{'074', '95' ,'OLIMAC'									,'S',"",0})
		aAdd(aVX5,{'074', '96' ,'PEGORARO'									,'S',"",0})
		aAdd(aVX5,{'074', '97' ,'PETERSBURG TRACTOR PLANT (KIROVETS)'		,'S',"",0})
		aAdd(aVX5,{'074', '98' ,'PLA'										,'S',"",0})
		aAdd(aVX5,{'074', '99' ,'POTTINGER'									,'S',"",0})
		aAdd(aVX5,{'074', '100','RANSOMES'									,'S',"",0})
		aAdd(aVX5,{'074', '101','ROSTSELMASH'								,'S',"",0})
		aAdd(aVX5,{'074', '102','S.E.P.'									,'S',"",0})
		aAdd(aVX5,{'074', '103','SALFORD'									,'S',"",0})
		aAdd(aVX5,{'074', '104','SAME'										,'S',"",0})
		aAdd(aVX5,{'074', '105','SANDS'										,'S',"",0})
		aAdd(aVX5,{'074', '106','SATPLAN'									,'S',"",0})
		aAdd(aVX5,{'074', '107','SHIBAURA'									,'S',"",0})
		aAdd(aVX5,{'074', '108','STOLL'										,'S',"",0})
		aAdd(aVX5,{'074', '109','STRAWMASTER'								,'S',"",0})
		aAdd(aVX5,{'074', '110','STROM'										,'S',"",0})
		aAdd(aVX5,{'074', '111','SUNFLOWER'									,'S',"",0})
		aAdd(aVX5,{'074', '112','TARUP'										,'S',"",0})
		aAdd(aVX5,{'074', '113','TECNOMA'									,'S',"",0})
		aAdd(aVX5,{'074', '114','TOPCON'									,'S',"",0})
		aAdd(aVX5,{'074', '115','TORO'										,'S',"",0})
		aAdd(aVX5,{'074', '116','TRIMA-BAAS'								,'S',"",0})
		aAdd(aVX5,{'074', '117','TRIMBLE'									,'S',"",0})
		aAdd(aVX5,{'074', '118','UNIA'										,'S',"",0})
		aAdd(aVX5,{'074', '119','VADERSTAD'									,'S',"",0})
		aAdd(aVX5,{'074', '120','VALPADANA'									,'S',"",0})
		aAdd(aVX5,{'074', '121','VALTRA'									,'S',"",0})
		aAdd(aVX5,{'074', '122','VERSATILE'									,'S',"",0})
		aAdd(aVX5,{'074', '123','VICON'										,'S',"",0})
		aAdd(aVX5,{'074', '124','VIKING'									,'S',"",0})
		aAdd(aVX5,{'074', '125','VLADIMIR TRACTOR PLANT'					,'S',"",0})
		aAdd(aVX5,{'074', '126','VOGEL & NOOT'								,'S',"",0})
		aAdd(aVX5,{'074', '127','VOLGOGRAD TRACTOR PLANT'					,'S',"",0})
		aAdd(aVX5,{'074', '128','WELGER'									,'S',"",0})
		aAdd(aVX5,{'074', '129','WOLF'										,'S',"",0})
		aAdd(aVX5,{'074', '130','YAMAHA'									,'S',"",0})
		aAdd(aVX5,{'074', '131','YANMAR'									,'S',"",0})
		aAdd(aVX5,{'074', '132','ZUCCHETTI'									,'S',"",0})
		aAdd(aVX5,{'074', '133','ZUERN'										,'S',"",0})
		aAdd(aVX5,{'074', '134','OTHER'										,'S',"",0})
		aAdd(aVX5,{'074', '135','NONE'										,'S',"",0})
		aAdd(aVX5,{'074', '136','POLARIS'									,'S',"",0})
		aAdd(aVX5,{'074', '142','ZETOR'										,'S',"",0})
		aAdd(aVX5,{'074', '143','URSUS'										,'S',"",0})
		aAdd(aVX5,{'074', '144','PRONAR'									,'S',"",0})

    	//
	Case cCodMar == "NHC" // Especificos para a marca New Holland Construction
		//
		aAdd(aVX5, {'039', '1', 'ESTOQUE'										,'S',"",0})
		aAdd(aVX5, {'039', '3', 'CLIENTES'										,'S',"",0})
		//
		aAdd(aVX5, {'040','01','REVISOES - INSPECOES'							,'S',"",0})
		aAdd(aVX5, {'040','02','REGULAGEM, CALIBRACAO OU AJUSTE INTERNO'		,'S',"",0})
		aAdd(aVX5, {'040','03','REPARO DE SERVICO AUTORIZADO'					,'S',"",0})
		aAdd(aVX5, {'040','06','NAO FUNCIONAMENTO'								,'S',"",0})
		aAdd(aVX5, {'040','07','DESEMPENHO INSUFICIENTE'						,'S',"",0})
		aAdd(aVX5, {'040','08','PARTIDA DIFICIL'								,'S',"",0})
		aAdd(aVX5, {'040','09','EXCESSO DE RUIDOS'								,'S',"",0})
		aAdd(aVX5, {'040','10','EXCESSO DE VIBRACAO'							,'S',"",0})
		aAdd(aVX5, {'040','11','EXCESSO DE FUMACA'								,'S',"",0})
		aAdd(aVX5, {'040','12','LUBRIFICACAO INSUFICIENTE'						,'S',"",0})
		aAdd(aVX5, {'040','15','PERDAS DE PRESSAO'								,'S',"",0})
		aAdd(aVX5, {'040','16','PRESSAO IRREGULAR OU INSUFICIENTE'				,'S',"",0})
		aAdd(aVX5, {'040','17','CONSUMO EXCESSIVO DE COMBUSTIVEL'				,'S',"",0})
		aAdd(aVX5, {'040','18','CONSUMO EXCESSO DE OLEO LUBRIFICANTE'			,'S',"",0})
		aAdd(aVX5, {'040','24','ABERTURA EM APURACAO'							,'S',"",0})
		aAdd(aVX5, {'040','25','DIFICULDADE DE OPERACAO ESFORCO EXCESSIVO'		,'S',"",0})
		aAdd(aVX5, {'040','26','DIFICULDADE NA ABERTURA OU FECHAMENTO'			,'S',"",0})
		aAdd(aVX5, {'040','27','DESENGATE ESPONTANEO'							,'S',"",0})
		aAdd(aVX5, {'040','28','VIBRACAO'										,'S',"",0})
		aAdd(aVX5, {'040','29','PATINAMENTO'									,'S',"",0})
		aAdd(aVX5, {'040','30','FALHA NA SEGURANCA'								,'S',"",0})
		aAdd(aVX5, {'040','31','ENDURECIMENTO'									,'S',"",0})
		aAdd(aVX5, {'040','32','TRAVAMENTO'										,'S',"",0})
		aAdd(aVX5, {'040','33','INTERFERENCIA'									,'S',"",0})
		aAdd(aVX5, {'040','34','CURSO IRREGULAR'								,'S',"",0})
		aAdd(aVX5, {'040','35','FALHA NO RETORNO'								,'S',"",0})
		aAdd(aVX5, {'040','38','FIXACAO INSUFICIENTE'							,'S',"",0})
		aAdd(aVX5, {'040','39','FOLGA EXCESSIVA'								,'S',"",0})
		aAdd(aVX5, {'040','40','DESALINHAMENTO OU FORA DO ESQUADRO'				,'S',"",0})
		aAdd(aVX5, {'040','44','ONDULACAO - ENRUGAMENTO'						,'S',"",0})
		aAdd(aVX5, {'040','45','DEFORMACAO - EMPENAMENTO'						,'S',"",0})
		aAdd(aVX5, {'040','46','CORROSAO - DESCAMACAO'							,'S',"",0})
		aAdd(aVX5, {'040','47','DESGASTE - FORMACAO DE SULCOS'					,'S',"",0})
		aAdd(aVX5, {'040','48','RUPTURA - TRINCA'								,'S',"",0})
		aAdd(aVX5, {'040','49','RUPTURA DA ROSCA'								,'S',"",0})
		aAdd(aVX5, {'040','50','RACHADURA'										,'S',"",0})
		aAdd(aVX5, {'040','51','DESGASTE'										,'S',"",0})
		aAdd(aVX5, {'040','52','SUPER AQUECIMENTO'								,'S',"",0})
		aAdd(aVX5, {'040','53','QUEIMA'											,'S',"",0})
		aAdd(aVX5, {'040','54','CURTO - CIRCUITO'								,'S',"",0})
		aAdd(aVX5, {'040','55','MAU CONTATO'									,'S',"",0})
		aAdd(aVX5, {'040','58','VAZAMENTO DE OLEO'								,'S',"",0})
		aAdd(aVX5, {'040','59','VAZAMENTO DE COMBUSTIVEL'						,'S',"",0})
		aAdd(aVX5, {'040','60','VAZAMENTO DE AGUA E ADITIVO'					,'S',"",0})
		aAdd(aVX5, {'040','61','VAZAMENTO DE FREON'								,'S',"",0})
		aAdd(aVX5, {'040','63','NIVEL DE FLUIDO BAIXO'							,'S',"",0})
		aAdd(aVX5, {'040','64','FALTA DE PECAS NA MONTAGEM'						,'S',"",0})
		aAdd(aVX5, {'040','66','MONTAGEM DEFEITUOSA'							,'S',"",0})
		aAdd(aVX5, {'040','67','DEFEITO DO PROCESSO'							,'S',"",0})
		aAdd(aVX5, {'040','68','DEFEITO NA SOLDA'								,'S',"",0})
		aAdd(aVX5, {'040','69','DEFEITOS DE FUNDICAO'							,'S',"",0})
		aAdd(aVX5, {'040','75','ENTUPIMENTO, OBSTRUCAO'							,'S',"",0})
		aAdd(aVX5, {'040','76','PRESENCA DE MATERIAL ESTRANHO OU IMPUREZAS'		,'S',"",0})
		aAdd(aVX5, {'040','78','INFILTRACAO OU ACUMULO DE AGUA'					,'S',"",0})
		aAdd(aVX5, {'040','79','INFILTRACAO DE AR'								,'S',"",0})
		aAdd(aVX5, {'040','80','ENTRADA DE POEIRA'								,'S',"",0})
		aAdd(aVX5, {'040','81','ENTRADA DE GAS DE ESCAPE'						,'S',"",0})
		aAdd(aVX5, {'040','86','AMASSADO'										,'S',"",0})
		aAdd(aVX5, {'040','87','OXIDACAO - CORROSAO'							,'S',"",0})
		aAdd(aVX5, {'040','88','FALHA DE VEDACAO'								,'S',"",0})
		aAdd(aVX5, {'040','90','DEFORMADO DA PINTURA'							,'S',"",0})
		aAdd(aVX5, {'040','91','MANCHAS OU ALTERACAO DA COR'					,'S',"",0})
		aAdd(aVX5, {'040','93','ARRANHAO, DESCASCADO'							,'S',"",0})
		aAdd(aVX5, {'040','94','PINTURA INSUFICIENTE'							,'S',"",0})
		aAdd(aVX5, {'040','95','PINTURA RACHADA'								,'S',"",0})
		aAdd(aVX5, {'040','96','BOLHAS NA PINTURA'								,'S',"",0})
		//
		aAdd(aVX5, {'041', '10', 'NORMAL'										,'S',"",0})
		aAdd(aVX5, {'041', '19', 'BALCAO'										,'S',"",0})
		aAdd(aVX5, {'041', '23', 'PMP'											,'S',"",0})
		//
		aAdd(aVX5, {'042', 'STD', 'STD'											,'S',"",0})
		//
	Case cCodMar $ "CHL-MSF-VAL-FDT" // Especificos para as marcas Challenger, Massey Ferguson e Valtra (AGCO)
		aAdd(aVX5,{'078','9111','Diretores'										,'S',"",0})
		aAdd(aVX5,{'078','9112','Gerentes'										,'S',"",0})
		aAdd(aVX5,{'078','9113','Supervisores'									,'S',"",0})
		aAdd(aVX5,{'078','9114','Coordenadores'									,'S',"",0})
		aAdd(aVX5,{'078','9115','Vendedores'									,'S',"",0})
		aAdd(aVX5,{'078','9116','Analistas'										,'S',"",0})
		aAdd(aVX5,{'078','9117','Assistentes'									,'S',"",0})
		aAdd(aVX5,{'078','9118','Auxiliares'									,'S',"",0})
		aAdd(aVX5,{'078','9119','Diretores'										,'S',"",0})
		aAdd(aVX5,{'078','9211','Novos'											,'S',"",0})
		aAdd(aVX5,{'078','9212','Usados'										,'S',"",0})
		aAdd(aVX5,{'078','9213','Outros Negócios'								,'S',"",0})
		aAdd(aVX5,{'078','9311','Trator'										,'S',"",0})
		aAdd(aVX5,{'078','9312','Colheitadeira'									,'S',"",0})
		aAdd(aVX5,{'078','9313','Colhedora'										,'S',"",0})
		aAdd(aVX5,{'078','9314','Plantadeira'									,'S',"",0})
		aAdd(aVX5,{'078','9315','Pulverizador'									,'S',"",0})
		aAdd(aVX5,{'078','9316','Plataforma'									,'S',"",0})
		aAdd(aVX5,{'078','9317','Implementos'									,'S',"",0})
		aAdd(aVX5,{'078','9318','Outros'										,'S',"",0})
		aAdd(aVX5,{'078','9411','Trator'										,'S',"",0})
		aAdd(aVX5,{'078','9412','Colheitadeira'									,'S',"",0})
		aAdd(aVX5,{'078','9413','Colhedora'										,'S',"",0})
		aAdd(aVX5,{'078','9414','Plantadeira'									,'S',"",0})
		aAdd(aVX5,{'078','9415','Pulverizador'									,'S',"",0})
		aAdd(aVX5,{'078','9416','Plataforma'									,'S',"",0})
		aAdd(aVX5,{'078','9417','Implementos'									,'S',"",0})
		aAdd(aVX5,{'078','9418','Outros'										,'S',"",0})
		aAdd(aVX5,{'078','9419','Colheitadeira'									,'S',"",0})
		aAdd(aVX5,{'078','9420','Colhedora'										,'S',"",0})
		aAdd(aVX5,{'078','9421','Plantadeira'									,'S',"",0})
		aAdd(aVX5,{'078','9422','Pulverizador'									,'S',"",0})
		aAdd(aVX5,{'078','9423','Plataforma'									,'S',"",0})
		aAdd(aVX5,{'078','9424','Implementos'									,'S',"",0})
		aAdd(aVX5,{'078','9511','Horas Disponíveis'								,'S',"",0})
		aAdd(aVX5,{'078','9512','Horas Faturadas'								,'S',"",0})
		aAdd(aVX5,{'078','9513','Tempo de O.S.'									,'S',"",0})
		aAdd(aVX5,{'078','9514','Valor O.S. em Aberto'							,'S',"",0})
		aAdd(aVX5,{'078','9611','Tempo de Pedido'								,'S',"",0})
		aAdd(aVX5,{'078','9612','Horas Faturadas'								,'S',"",0})
		aAdd(aVX5,{'078','9613','Valor Pedidos Abertos'							,'S',"",0})
		//
		aAdd(aVX5,{'079','1101','Máquinas Novas'								,'S',"",0})
		aAdd(aVX5,{'079','1102','Máquinas Usadas'								,'S',"",0})
		aAdd(aVX5,{'079','1201','Peças'											,'S',"",0})
		aAdd(aVX5,{'079','1301','Serviços'										,'S',"",0})
		aAdd(aVX5,{'079','1401','Administrativo'								,'S',"",0})
		aAdd(aVX5,{'079','1501','Outros Negócios'								,'S',"",0})
		//
		aAdd(aVX5,{'080','1111','Disponibilidades Imediatas'								  	,'S',"",0})
		aAdd(aVX5,{'080','1121','Contas a Receber Maquinas Novas'                             	,'S',"",0})
		aAdd(aVX5,{'080','1122','Contas a Receber Maquinas Usadas'                            	,'S',"",0})
		aAdd(aVX5,{'080','1123','Contas a Receber Peças'                                      	,'S',"",0})
		aAdd(aVX5,{'080','1124','Contas a Receber Serviços'                                   	,'S',"",0})
		aAdd(aVX5,{'080','1125','Contas a Receber Comissões e Consórcios'                     	,'S',"",0})
		aAdd(aVX5,{'080','1126','Contas a Receber Outros'                                     	,'S',"",0})
		aAdd(aVX5,{'080','1127','Empresas Coligadas'                                          	,'S',"",0})
		aAdd(aVX5,{'080','1128','Consorcio em Andamento'                                      	,'S',"",0})
		aAdd(aVX5,{'080','1131','Adiantamentos Fornecedores'                                  	,'S',"",0})
		aAdd(aVX5,{'080','1132','Adiantamentos Funcionários'                                  	,'S',"",0})
		aAdd(aVX5,{'080','1133','Despesas Antecipadas - Curto Prazo'                          	,'S',"",0})
		aAdd(aVX5,{'080','1139','Outros Adiantamentos'                                        	,'S',"",0})
		aAdd(aVX5,{'080','1141','Impostos a Compensar e Recuperar Curto Prazo'                	,'S',"",0})
		aAdd(aVX5,{'080','1151','Máquinas e Implementos AGCO - Novos'                         	,'S',"",0})
		aAdd(aVX5,{'080','1152','Máquinas e Implementos AGCO - Usados'                        	,'S',"",0})
		aAdd(aVX5,{'080','1153','Máquinas e Implementos Outras Marcas - Novos'                	,'S',"",0})
		aAdd(aVX5,{'080','1154','Máquinas e Implementos Outras Marcas - Usados'               	,'S',"",0})
		aAdd(aVX5,{'080','1155','Peças AGCO'                                                  	,'S',"",0})
		aAdd(aVX5,{'080','1156','Peças Outras Marcas'                                         	,'S',"",0})
		aAdd(aVX5,{'080','1157','Estoque de Outros Negócios - AGCO'                           	,'S',"",0})
		aAdd(aVX5,{'080','1158','Estoque de Outros Negócios'                                  	,'S',"",0})
		aAdd(aVX5,{'080','1159','(-) Estoques - Ajuste a Valor Presente'                      	,'S',"",0})
		aAdd(aVX5,{'080','1160','(-) Provisão de Estoque Obsoleto'                            	,'S',"",0})
		aAdd(aVX5,{'080','1194','(-) Devolução de Vendas'                                      	,'S',"",0})
		aAdd(aVX5,{'080','1195','Valores em Transito'                                         	,'S',"",0})
		aAdd(aVX5,{'080','1196','(-) Contas a Receber - Ajuste a Valor Presente'              	,'S',"",0})
		aAdd(aVX5,{'080','1197','(-) PCLD - Provisão de  Créditos Duvidosos'                  	,'S',"",0})
		aAdd(aVX5,{'080','1198','Outros Créditos'                                             	,'S',"",0})
		aAdd(aVX5,{'080','1199','Fundo AGCO'                                                  	,'S',"",0})
		aAdd(aVX5,{'080','1211','Contas a Receber - Vendas - Longo Prazo - Novos'             	,'S',"",0})
		aAdd(aVX5,{'080','1212','Contas a Receber - Vendas - Longo Prazo - Usados'            	,'S',"",0})
		aAdd(aVX5,{'080','1213','Aplicações Financeiras - Longo Prazo'                        	,'S',"",0})
		aAdd(aVX5,{'080','1214','Consórcio'                                                   	,'S',"",0})
		aAdd(aVX5,{'080','1215','Créditos com Partes Relacionadas - LP'                       	,'S',"",0})
		aAdd(aVX5,{'080','1216','(-) Investimentos Permanentes - Ajuste a Valor Presente'     	,'S',"",0})
		aAdd(aVX5,{'080','1217','(-) Contas a Receber LP - Ajuste a Valor Presente'           	,'S',"",0})
		aAdd(aVX5,{'080','1221','Impostos Diferidos'                                          	,'S',"",0})
		aAdd(aVX5,{'080','1225','Despesas Antecipadas - Longo Prazo'                          	,'S',"",0})
		aAdd(aVX5,{'080','1229','Outros Créditos'                                             	,'S',"",0})
		aAdd(aVX5,{'080','1231','Terrenos'                                                    	,'S',"",0})
		aAdd(aVX5,{'080','1232','Construções e Prédios'                                       	,'S',"",0})
		aAdd(aVX5,{'080','1233','Máquinas/equipamentos e ferramentas'                         	,'S',"",0})
		aAdd(aVX5,{'080','1234','Móveis e Utensílios'                                         	,'S',"",0})
		aAdd(aVX5,{'080','1235','Veículos'                                                    	,'S',"",0})
		aAdd(aVX5,{'080','1236','Frota para Locação'                                          	,'S',"",0})
		aAdd(aVX5,{'080','1237','Imobilizado outros'                                          	,'S',"",0})
		aAdd(aVX5,{'080','1238','Benfeitorias em prédio de Terceiros'                         	,'S',"",0})
		aAdd(aVX5,{'080','1239','Consorcios em Andamentos para Imobilizado'                   	,'S',"",0})
		aAdd(aVX5,{'080','1240','Computadores e Perifericos'                                  	,'S',"",0})
		aAdd(aVX5,{'080','1296','(-) Aplicações Financeiras LP - Ajuste a Valor Presente'     	,'S',"",0})
		aAdd(aVX5,{'080','1297','(-) Ativo Imobilizado - Ajuste a Valor Presente'             	,'S',"",0})
		aAdd(aVX5,{'080','1298','Intangível'                                                  	,'S',"",0})
		aAdd(aVX5,{'080','1299','(-) Depreciação e Amortização'                               	,'S',"",0})
		aAdd(aVX5,{'080','2111','Fornecedores Maquinas Novas'                                 	,'S',"",0})
		aAdd(aVX5,{'080','2112','Fornecedores Maquinas Usadas'                                	,'S',"",0})
		aAdd(aVX5,{'080','2113','Fornecedores Peças'                                          	,'S',"",0})
		aAdd(aVX5,{'080','2114','Fornecedores Serviços'                                       	,'S',"",0})
		aAdd(aVX5,{'080','2115','Fornecedores Outros'                                         	,'S',"",0})
		aAdd(aVX5,{'080','2116','Contas a Pagar Partes Relacionadas'                          	,'S',"",0})
		aAdd(aVX5,{'080','2117','Outras contas a pagar'                                       	,'S',"",0})
		aAdd(aVX5,{'080','2118','Contas a Pagar Empresas Coligadas'                           	,'S',"",0})
		aAdd(aVX5,{'080','2121','Financiamentos AGCO FINANCE CP'                              	,'S',"",0})
		aAdd(aVX5,{'080','2122','Empréstimos Bancários CP'                                    	,'S',"",0})
		aAdd(aVX5,{'080','2123','Outros Empréstimos CP'                                       	,'S',"",0})
		aAdd(aVX5,{'080','2124','Financiamentos Outros Bancos CP'                             	,'S',"",0})
		aAdd(aVX5,{'080','2125','Empréstimos de Sócios CP'                                    	,'S',"",0})
		aAdd(aVX5,{'080','2126','Leasing a Pagar CP'                                          	,'S',"",0})
		aAdd(aVX5,{'080','2127','Duplicatas Descontadas'                                      	,'S',"",0})
		aAdd(aVX5,{'080','2128','Financiamentos FINAME'                                       	,'S',"",0})
		aAdd(aVX5,{'080','2130','(-) Ajuste a Valor Presente - Empréstimos'                   	,'S',"",0})
		aAdd(aVX5,{'080','2131','Salários e Bônus a Pagar'                                    	,'S',"",0})
		aAdd(aVX5,{'080','2132','Obrigações Trabalhistas a Recolher'                          	,'S',"",0})
		aAdd(aVX5,{'080','2133','Provisões Trabalhistas'                                      	,'S',"",0})
		aAdd(aVX5,{'080','2141','Obrigações Tributárias a Recolher'                           	,'S',"",0})
		aAdd(aVX5,{'080','2142','Outras Obrigações Fiscais a Recolher'                        	,'S',"",0})
		aAdd(aVX5,{'080','2151','Adiantamento de Clientes'                                    	,'S',"",0})
		aAdd(aVX5,{'080','2152','Outros Adiantamentos'                                        	,'S',"",0})
		aAdd(aVX5,{'080','2161','Dividendos a Pagar'                                          	,'S',"",0})
		aAdd(aVX5,{'080','2162','Consórcios a Pagar'                                          	,'S',"",0})
		aAdd(aVX5,{'080','2163','Faturamento para Entrega Futura'                             	,'S',"",0})
		aAdd(aVX5,{'080','2164','Receitas e Custos Diferidos'                                 	,'S',"",0})
		aAdd(aVX5,{'080','2165','Impostos Diferidos'                                          	,'S',"",0})
		aAdd(aVX5,{'080','2166','Valores em Transito'                                         	,'S',"",0})
		aAdd(aVX5,{'080','2197','(-) Devoluções de Compras'                                   	,'S',"",0})
		aAdd(aVX5,{'080','2198','(-) Contas a Pagar - Reclassificação para Longo Prazo'       	,'S',"",0})
		aAdd(aVX5,{'080','2199','(-) Ajuste a Valor Presente - Contas a Pagar'                	,'S',"",0})
		aAdd(aVX5,{'080','2211','Financiamentos AGCO FINANCE LP'                              	,'S',"",0})
		aAdd(aVX5,{'080','2212','Financiamentos Outros Bancos LP'                             	,'S',"",0})
		aAdd(aVX5,{'080','2213','Empréstimos Bancários LP'                                    	,'S',"",0})
		aAdd(aVX5,{'080','2214','(-) Ajuste a Valor Presente - Empréstimos'                   	,'S',"",0})
		aAdd(aVX5,{'080','2221','Contas a Pagar - Empresas Coligadas LP'                      	,'S',"",0})
		aAdd(aVX5,{'080','2222','Contas a Pagar e Fornecedores LP'                            	,'S',"",0})
		aAdd(aVX5,{'080','2223','Outros Investimentos a pagar'                                	,'S',"",0})
		aAdd(aVX5,{'080','2224','Contas a Pagar de Partes Relacionadas LP'                    	,'S',"",0})
		aAdd(aVX5,{'080','2225','Outros Empréstimos LP'                                       	,'S',"",0})
		aAdd(aVX5,{'080','2226','Parcelamento de Tributos'                                    	,'S',"",0})
		aAdd(aVX5,{'080','2227','Provisões para Contigências'                                 	,'S',"",0})
		aAdd(aVX5,{'080','2231','Capital Social Integralizado'                                	,'S',"",0})
		aAdd(aVX5,{'080','2232','Adiantamentos para Futuro Aumento de Capital'                	,'S',"",0})
		aAdd(aVX5,{'080','2233','Reservas de Lucro'                                           	,'S',"",0})
		aAdd(aVX5,{'080','2234','Reservas de Capital'                                         	,'S',"",0})
		aAdd(aVX5,{'080','2235','(-) Ações/Quotas em Tesouraria'                              	,'S',"",0})
		aAdd(aVX5,{'080','2236','(-) Dividendos Distribuídos'                                 	,'S',"",0})
		aAdd(aVX5,{'080','2237','(-) Juros Capital Próprio'                                   	,'S',"",0})
		aAdd(aVX5,{'080','2238','(-) Prejuízos Acumulado'                                     	,'S',"",0})
		aAdd(aVX5,{'080','2239','Resultado do Exercício'                                      	,'S',"",0})
		aAdd(aVX5,{'080','2299','(-) Ajuste a Valor Presente - Outras Contas a Pagar LP'      	,'S',"",0})
		aAdd(aVX5,{'080','3111','Comissões sobre Vendas - Consórcio'                          	,'S',"",0})
		aAdd(aVX5,{'080','3112','(-) Dedução de Comissões sobre Vendas - Consórcio'           	,'S',"",0})
		aAdd(aVX5,{'080','3113','Comissões sobre Vendas de Máquinas'                          	,'S',"",0})
		aAdd(aVX5,{'080','3114','(-) Dedução de Comissões sobre Vendas de Máquinas'           	,'S',"",0})
		aAdd(aVX5,{'080','3115','Receita com Outras Comissões'                                	,'S',"",0})
		aAdd(aVX5,{'080','3116','(-) Dedução de Outras Comissões'                             	,'S',"",0})
		aAdd(aVX5,{'080','3117','Máquinas AGCO - Novos'                                       	,'S',"",0})
		aAdd(aVX5,{'080','3118','(-) Dedução de Máquinas AGCO - Novos'                        	,'S',"",0})
		aAdd(aVX5,{'080','3119','Implementos AGCO - Novos'                                    	,'S',"",0})
		aAdd(aVX5,{'080','3120','(-) Dedução de Implementos AGCO - Novos'                     	,'S',"",0})
		aAdd(aVX5,{'080','3121','Implementos Outras Marcas - Novos'                           	,'S',"",0})
		aAdd(aVX5,{'080','3122','(-) Dedução de Máquinas Outras Marcas - Novos'               	,'S',"",0})
		aAdd(aVX5,{'080','3131','Máquinas e Implementos AGCO - Usados'                        	,'S',"",0})
		aAdd(aVX5,{'080','3132','(-) Dedução de Máquinas e Implementos AGCO - Usados'         	,'S',"",0})
		aAdd(aVX5,{'080','3133','Máquinas e implementos Outras Marcas - Usados'               	,'S',"",0})
		aAdd(aVX5,{'080','3134','(-) Dedução de Máquinas e Implementos Outras Marcas - Usados'	,'S',"",0})
		aAdd(aVX5,{'080','3211','Receita com Comissões Sobre Vendas de Peças'                 	,'S',"",0})
		aAdd(aVX5,{'080','3212','(-) Dedução de Comissões Sobre Vendas de Peças'              	,'S',"",0})
		aAdd(aVX5,{'080','3213','Receitas Peças  AGCO'                                        	,'S',"",0})
		aAdd(aVX5,{'080','3214','Receitas Peças Oficina AGCO'                                 	,'S',"",0})
		aAdd(aVX5,{'080','3215','(-) Dedução de Peças AGCO'                                   	,'S',"",0})
		aAdd(aVX5,{'080','3216','(-) Dedução de Peças Oficina  AGCO'                          	,'S',"",0})
		aAdd(aVX5,{'080','3221','Peças Outras Marcas'                                         	,'S',"",0})
		aAdd(aVX5,{'080','3222','Peças Oficina Outras Marcas'                                 	,'S',"",0})
		aAdd(aVX5,{'080','3223','(-) Dedução de Peças Outras Marcas'                          	,'S',"",0})
		aAdd(aVX5,{'080','3224','(-) Dedução de Peças Oficina Outras Marcas'                  	,'S',"",0})
		aAdd(aVX5,{'080','3225','Lubrificantes'                                               	,'S',"",0})
		aAdd(aVX5,{'080','3226','(-) Dedução de Lubrificantes'                                	,'S',"",0})
		aAdd(aVX5,{'080','3311','Receita com Serviços Prestados a Clientes'                   	,'S',"",0})
		aAdd(aVX5,{'080','3312','(-) Dedução de Serviços Prestados a Clientes'                	,'S',"",0})
		aAdd(aVX5,{'080','3313','Receita com Serviços Internos'                               	,'S',"",0})
		aAdd(aVX5,{'080','3314','(-) Dedução de Serviços Internos'                            	,'S',"",0})
		aAdd(aVX5,{'080','3315','Receita com Serviços de Garantia'                            	,'S',"",0})
		aAdd(aVX5,{'080','3316','(-) Dedução de Serviços de Garantia'                         	,'S',"",0})
		aAdd(aVX5,{'080','3317','Receita com Serviços Recall'                                 	,'S',"",0})
		aAdd(aVX5,{'080','3318','(-) Dedução de Serviços Recall'                              	,'S',"",0})
		aAdd(aVX5,{'080','3319','Receita com KM de Serviços de Assistência a Campo'           	,'S',"",0})
		aAdd(aVX5,{'080','3320','(-) Dedução de KM de Serviços de Assistência a Campo'        	,'S',"",0})
		aAdd(aVX5,{'080','3321','Receita com deslocamento de Assistência a Campo'             	,'S',"",0})
		aAdd(aVX5,{'080','3322','(-) Dedução de deslocamento de Assistência a Campo'          	,'S',"",0})
		aAdd(aVX5,{'080','3323','Serviços Realizados por Terceiros'                           	,'S',"",0})
		aAdd(aVX5,{'080','3324','(-) Dedução de Serviços Realizados por Terceiros'            	,'S',"",0})
		aAdd(aVX5,{'080','3411','Receitas de Tecnologia - ACGO'                               	,'S',"",0})
		aAdd(aVX5,{'080','3412','Receita Outros Negócios AGCO'                                	,'S',"",0})
		aAdd(aVX5,{'080','3413','(-) Dedução de Receitas Tecnologia - AGCO'                   	,'S',"",0})
		aAdd(aVX5,{'080','3414','(-) Dedução de Receitas com Outros Negócios - AGCO'          	,'S',"",0})
		aAdd(aVX5,{'080','3511','Receita Outros Negócios'                                     	,'S',"",0})
		aAdd(aVX5,{'080','3512','(-) Dedução de Receitas com Outros Negócios'                 	,'S',"",0})
		aAdd(aVX5,{'080','4117','Custo Máquinas AGCO - Novos'                                 	,'S',"",0})
		aAdd(aVX5,{'080','4119','Custo Impllementos AGCO - Novos'                             	,'S',"",0})
		aAdd(aVX5,{'080','4121','Custo Máquinas Outras Marcas - Novos'                        	,'S',"",0})
		aAdd(aVX5,{'080','4131','Custo Máquinas e Implementos AGCO - Usados'                  	,'S',"",0})
		aAdd(aVX5,{'080','4133','Custo Máquinas e implementos Outras Marcas - Usados'         	,'S',"",0})
		aAdd(aVX5,{'080','4213','Custo Peças  AGCO'                                           	,'S',"",0})
		aAdd(aVX5,{'080','4214','Custo Peças Oficina AGCO'                                    	,'S',"",0})
		aAdd(aVX5,{'080','4221','Peças Outras Marcas'                                         	,'S',"",0})
		aAdd(aVX5,{'080','4222','Peças Oficina Outras Marcas'                                 	,'S',"",0})
		aAdd(aVX5,{'080','4311','Materiais de Consumo - Oficina'                              	,'S',"",0})
		aAdd(aVX5,{'080','4312','Salários e Encargos dos Técnicos'                            	,'S',"",0})
		aAdd(aVX5,{'080','4313','Custos Serviços Realizados por Terceiros'                    	,'S',"",0})
		aAdd(aVX5,{'080','4314','Custo com deslocamento técnicos'                             	,'S',"",0})
		aAdd(aVX5,{'080','4315','Custos com Pós - Venda/Garantias Indeferidas e Retrabalhos'  	,'S',"",0})
		aAdd(aVX5,{'080','4319','Uso e Consumo Oficina'                                       	,'S',"",0})
		aAdd(aVX5,{'080','4320','Ferramental de pequeno valor'                                	,'S',"",0})
		aAdd(aVX5,{'080','4399','Outros Custos Sobre Serviços'                                	,'S',"",0})
		aAdd(aVX5,{'080','4411','Custo de Tecnologia ACGO'                                   	,'S',"",0})
		aAdd(aVX5,{'080','4412','Custo com Outros Negócios - AGCO'                           	,'S',"",0})
		aAdd(aVX5,{'080','4511','Custo com Outros Negócios'                                  	,'S',"",0})
		aAdd(aVX5,{'080','5111','Brindes'                                                     	,'S',"",0})
		aAdd(aVX5,{'080','5112','Comissões e Encargo Folha de Pagamento'                      	,'S',"",0})
		aAdd(aVX5,{'080','5113','Bônus e Participação nos Resultados'                         	,'S',"",0})
		aAdd(aVX5,{'080','5114','Despesas com Ajustes de Acordo Comercial'                    	,'S',"",0})
		aAdd(aVX5,{'080','5116','Perdas com Devedores Duvidosos'                              	,'S',"",0})
		aAdd(aVX5,{'080','5117','Taxa Flat de Financiamento'                                  	,'S',"",0})
		aAdd(aVX5,{'080','5118','Despesas de Consumo Interno Oficina'                         	,'S',"",0})
		aAdd(aVX5,{'080','5119','Fretes'                                                      	,'S',"",0})
		aAdd(aVX5,{'080','5120','Despesa com reforma de máquinas usadas'                      	,'S',"",0})
		aAdd(aVX5,{'080','5121','Remuneração Dirigentes'                                      	,'S',"",0})
		aAdd(aVX5,{'080','5122','Salários - Gerência e Supervisão'                            	,'S',"",0})
		aAdd(aVX5,{'080','5123','Salários - Funcionários'                                     	,'S',"",0})
		aAdd(aVX5,{'080','5124','Provisões - 13o. Sal. e Férias'                              	,'S',"",0})
		aAdd(aVX5,{'080','5125','Encargos Sociais - todos'                                    	,'S',"",0})
		aAdd(aVX5,{'080','5126','Benefícios'                                                  	,'S',"",0})
		aAdd(aVX5,{'080','5127','Água, Luz e Gás'                                             	,'S',"",0})
		aAdd(aVX5,{'080','5128','Aluguel'                                                     	,'S',"",0})
		aAdd(aVX5,{'080','5129','Amortizações e Depreciações'                                 	,'S',"",0})
		aAdd(aVX5,{'080','5130','Despesa com Alimentação'                                     	,'S',"",0})
		aAdd(aVX5,{'080','5131','Despesas com Material de Segurança e Uniformes'              	,'S',"",0})
		aAdd(aVX5,{'080','5132','Despesas com Móveis e Utensílios'                            	,'S',"",0})
		aAdd(aVX5,{'080','5133','Despesas de Comunicação'                                     	,'S',"",0})
		aAdd(aVX5,{'080','5134','Donativos e Contribuições'                                   	,'S',"",0})
		aAdd(aVX5,{'080','5135','Eventos e Confraternização'                                  	,'S',"",0})
		aAdd(aVX5,{'080','5136','Garantias Recusadas - AGCO'                                  	,'S',"",0})
		aAdd(aVX5,{'080','5137','Impostos e Taxas Diversos'                                   	,'S',"",0})
		aAdd(aVX5,{'080','5138','Leasing'                                                     	,'S',"",0})
		aAdd(aVX5,{'080','5139','Legais e Auditoria'                                          	,'S',"",0})
		aAdd(aVX5,{'080','5140','Manutenção de Veículos frota da Adm'                         	,'S',"",0})
		aAdd(aVX5,{'080','5141','Manutenção Predial'                                          	,'S',"",0})
		aAdd(aVX5,{'080','5142','Materiais Diversos / Escritório'                             	,'S',"",0})
		aAdd(aVX5,{'080','5143','Multas'                                                      	,'S',"",0})
		aAdd(aVX5,{'080','5144','Processamento Dados - Terceiros'                             	,'S',"",0})
		aAdd(aVX5,{'080','5145','Propaganda e Promoção de Vendas'                             	,'S',"",0})
		aAdd(aVX5,{'080','5146','Publicações, Assinaturas e Assoc.'                           	,'S',"",0})
		aAdd(aVX5,{'080','5147','Retorno de Garantia ( Pecas e Serviços )'                    	,'S',"",0})
		aAdd(aVX5,{'080','5148','Seguros'                                                     	,'S',"",0})
		aAdd(aVX5,{'080','5149','Serviços Profissionais - Terceiros'                          	,'S',"",0})
		aAdd(aVX5,{'080','5150','Treinamento'                                                 	,'S',"",0})
		aAdd(aVX5,{'080','5151','Combustíveis e Lubrificantes'                                	,'S',"",0})
		aAdd(aVX5,{'080','5152','Viagens, Represent. e Hospitalidade'                         	,'S',"",0})
		aAdd(aVX5,{'080','5153','Taxas Associativas'                                          	,'S',"",0})
		aAdd(aVX5,{'080','5154','Sistemas, Software e Informática'                            	,'S',"",0})
		aAdd(aVX5,{'080','5155','Postagens, Correios e Telegrafos'                            	,'S',"",0})
		aAdd(aVX5,{'080','5156','Aviso Prévio'                                                	,'S',"",0})
		aAdd(aVX5,{'080','5157','Ações Trabalhistas'                                          	,'S',"",0})
		aAdd(aVX5,{'080','5158','Estágio'                                                     	,'S',"",0})
		aAdd(aVX5,{'080','5199','Outros Despesas'                                             	,'S',"",0})
		aAdd(aVX5,{'080','6111','Rendimento Aplicações Financeiras'                           	,'S',"",0})
		aAdd(aVX5,{'080','6112','Juros Recebidos'                                             	,'S',"",0})
		aAdd(aVX5,{'080','6113','Variaçoes Monetarias Ativas'                                 	,'S',"",0})
		aAdd(aVX5,{'080','6114','Descontos Obtidos'                                           	,'S',"",0})
		aAdd(aVX5,{'080','6115','Juros de CAR'                                                	,'S',"",0})
		aAdd(aVX5,{'080','6121','Despesas Financeiras s/ Capital Giro'                        	,'S',"",0})
		aAdd(aVX5,{'080','6122','IOF'                                                         	,'S',"",0})
		aAdd(aVX5,{'080','6123','Despesa com Juros'                                           	,'S',"",0})
		aAdd(aVX5,{'080','6124','Multas Financeiras'                                          	,'S',"",0})
		aAdd(aVX5,{'080','6125','Juros sobre Capital Próprio'                                 	,'S',"",0})
		aAdd(aVX5,{'080','6126','Variaçoes Monetarias Passivas'                               	,'S',"",0})
		aAdd(aVX5,{'080','6127','Despesas Bancárias'                                          	,'S',"",0})
		aAdd(aVX5,{'080','6128','Descontos Passivos'                                          	,'S',"",0})
		aAdd(aVX5,{'080','7111','Ganho com Venda de Ativo Imobilizado'                        	,'S',"",0})
		aAdd(aVX5,{'080','7112','Outras Receitas'                                             	,'S',"",0})
		aAdd(aVX5,{'080','7121','Perda com Venda de Ativo'                                    	,'S',"",0})
		aAdd(aVX5,{'080','7122','Outras Despesas'                                             	,'S',"",0})
		aAdd(aVX5,{'080','8111','IRPJ'                                                        	,'S',"",0})
		aAdd(aVX5,{'080','8112','CSLL'                                                        	,'S',"",0})
EndCase

aAdd(aVX5,{'075','001',"CGPoll"													,'S',"",0})

AADD(aVX5, {'070', 'PVAA', "ALTERAÇÃO STATUS - ABERTO"             , "S","",0 } )
AADD(aVX5, {'070', 'PVAP', "ALTERAÇÃO STATUS - PENDENTE APROVACAO" , "S","",0 } )
AADD(aVX5, {'070', 'PVAO', "ALTERAÇÃO STATUS - PRE-APROVADO"       , "S","",0 } )
AADD(aVX5, {'070', 'PVAL', "ALTERAÇÃO STATUS - APROVADO"           , "S","",0 } )
AADD(aVX5, {'070', 'PVAR', "ALTERAÇÃO STATUS - REPROVADO"          , "S","",0 } )
AADD(aVX5, {'070', 'PVAF', "ALTERAÇÃO STATUS - FINALIZADO"         , "S","",0 } )
AADD(aVX5, {'070', 'PVAC', "ALTERAÇÃO STATUS - CANCELADO"          , "S","",0 } )

aAdd(aVX5, {"076", "0", STR0066													,"S","",0}) // Gasolina
aAdd(aVX5, {"076", "1", STR0067													,"S","",0}) // Alcool
aAdd(aVX5, {"076", "2", STR0068													,"S","",0}) // Diesel
aAdd(aVX5, {"076", "3", STR0069													,"S","",0}) // Gas Natural Veicular
aAdd(aVX5, {"076", "4", STR0070													,"S","",0}) // Alcool/Gasolina
aAdd(aVX5, {"076", "5", STR0071													,"S","",0}) // Alcool/Gasolina/GNV
aAdd(aVX5, {"076", "9", STR0072													,"S","",0}) // Sem Combustivel
aAdd(aVX5, {"076", "A", STR0073													,"S","",0}) // Gasogenio
aAdd(aVX5, {"076", "B", STR0074													,"S","",0}) // Gas Metano
aAdd(aVX5, {"076", "C", STR0075													,"S","",0}) // Eletrico/Fonte Interna
aAdd(aVX5, {"076", "D", STR0076													,"S","",0}) // Eletrico/Fonte Externa
aAdd(aVX5, {"076", "E", STR0077													,"S","",0}) // Gasol/Gas Natural Combustivel
aAdd(aVX5, {"076", "F", STR0078													,"S","",0}) // Alcool/Gas Natural Combustivel
aAdd(aVX5, {"076", "G", STR0079													,"S","",0}) // Diesel/Gas Natural Combustivel
aAdd(aVX5, {"076", "H", STR0080													,"S","",0}) // Alcool/Gas Natural Veicular
aAdd(aVX5, {"076", "I", STR0081													,"S","",0}) // Gasolina/Gas Natural Veicular
aAdd(aVX5, {"076", "J", STR0082													,"S","",0}) // Diesel/Gas Natural Veicular
aAdd(aVX5, {"076", "K", STR0083													,"S","",0}) // Gasolina/Eletrico

aAdd(aVX5, {"083", "01", "LocationCreatedInDbs","S","",0})
aAdd(aVX5, {"083", "02", "LocationUpdateInDbs","S","",0})
aAdd(aVX5, {"083", "03", "LocationRemovedInDbs","S","",0})
aAdd(aVX5, {"083", "04", "FileList","S","",0})
aAdd(aVX5, {"083", "05", "FileDownload","S","",0})
aAdd(aVX5, {"083", "06", "FileUpload","S","",0})

aAdd(aVX5, {"084", "00", "Mobile"            ,"S","",0 })
aAdd(aVX5, {"084", "01", "ServiceOperations" ,"S","",0 })
aAdd(aVX5, {"084", "02", "DTF" ,"S","",0 })

aAdd(aVX5, {"085", "00", "BlackBird" , "S", "", 0 })
aAdd(aVX5, {"085", "01", "DBS"       , "S", "", 0 })
aAdd(aVX5, {"085", "02", "Mobile"    , "S", "", 0 })

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA560I ³ Autor ³ Andre Luis Almeida               ³ Data ³ 04/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Incluir VX5                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA560I()
Local cFilVX5   := xFilial("VX5")
Local cCod      := ""
Local cDesc     := space(200)
Local aRet      := {}
Local aParamBox := {}
Local nPos      := 0
Local nTam      := 10 // Declarar como NIL para funcionar o carregamento no TamSX3
Local cTab      := ""

If cVX5 $ cTabBloq
	MsgStop(STR0027) // Nao e possivel incluir registros na tabela selecionada
	Return
EndIf

DbSelectArea("VX5")

nPos := aScan(aVX5, {|x| x[1]+x[2] == "000"+cVX5 }) // Pesquisa a Tabela
If nPos > 0 .And. Len(aVX5[nPos]) > 4
	If !Empty(aVX5[nPos,5])
		cTab := left(aVX5[nPos,5],At("_",aVX5[nPos,5])-1)
		If len(cTab) == 2
			cTab := "S"+cTab // Tabelas Padrao TOTVS
		EndIf
		If &( cTab+"->(FieldPos('"+aVX5[nPos,5]+"')) > 0" ) // Campo Padrao
			nTam := TamSX3(aVX5[nPos,5])[1] // Utiliza Tamanho do Campo Padrao
		ElseIf aVX5[nPos,6] > 0 // Tamanho Default
			nTam := aVX5[nPos,6] // Utiliza Tamanho Default passado no Vetor das Tabelas
		EndIf
	ElseIf aVX5[nPos,6] > 0 // Tamanho Default
		nTam := aVX5[nPos,6] // Utiliza Tamanho Default passado no Vetor das Tabelas
	EndIf
EndIf
cCod := space(nTam) // Tamanho do Codigo do VX5

AADD(aParamBox,{1,STR0003,cCod,"@!","!Empty(MV_PAR01)","",".t.",50,.t.}) // Codigo
AADD(aParamBox,{1,STR0004,cDesc,"@!","!Empty(MV_PAR02)","",".t.",110,.t.}) // Descricao
If ParamBox(aParamBox,"",@aRet,,,,,,,,.f.)
	cCod  := aRet[01] // Codigo
	cDesc := aRet[02] // Descricao
	If FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSQLName("VX5")+" WHERE VX5_FILIAL='"+cFilVX5+"' AND VX5_CHAVE='"+cVX5+"' AND VX5_CODIGO='"+cCod+"' AND D_E_L_E_T_=' '") <= 0
		DbSelectArea("VX5")
		RecLock("VX5",.t.)
    	VX5->VX5_FILIAL := cFilVX5
		VX5->VX5_CHAVE  := cVX5
		VX5->VX5_CODIGO := cCod
		VX5->VX5_DESCRI := cDesc
		VX5->VX5_PROPRI := "U"
		if VX5->(fieldpos('VX5_DATINC')) > 0
			VX5->VX5_DATINC := FGX_Timestamp()
		endif
		if VX5->(fieldpos('VX5_UUID')) > 0
			VX5->VX5_UUID := FWUUIDV4(.t.)
		endif
		MsUnLock()
	Else
		MsgAlert(STR0006,STR0005) // Código informado ja existente! Impossivel Incluir!  / Atenção
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA560A ³ Autor ³ Andre Luis Almeida               ³ Data ³ 04/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alterar VX5                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA560A()
Local cCod      := ""
Local cDesc     := ""
Local aRet      := {}
Local aParamBox := {}
If VX5->VX5_PROPRI == "U"
	cCod  := VX5->VX5_CODIGO
	cDesc := VX5->VX5_DESCRI
	AADD(aParamBox,{1,STR0003,cCod,"@!","!Empty(MV_PAR01)","",".f.",50,.t.}) // Codigo
	AADD(aParamBox,{1,STR0004,cDesc,"@!","!Empty(MV_PAR02)","",".t.",110,.t.}) // Descricao
	If ParamBox(aParamBox,"",@aRet,,,,,,,,.f.)
		cDesc := aRet[02] // Descricao
		If !Empty(cDesc)
			DbSelectArea("VX5")
			RecLock("VX5",.f.)
			VX5->VX5_DESCRI := cDesc
			if VX5->(fieldpos('VX5_DATALT')) > 0
				VX5->VX5_DATALT := FGX_Timestamp()
			endif
			MsUnLock()
		EndIf
	EndIf
Else
	MsgStop(STR0007,STR0005) // Registro padrão do sistema. Impossivel Alterar! / Atenção
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA560E ³ Autor ³ Andre Luis Almeida               ³ Data ³ 04/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Excluir VX5                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA560E()
Local cCod      := ""
Local cDesc     := ""
Local aRet      := {}
Local aParamBox := {}
If VX5->VX5_PROPRI == "U"
	cCod  := VX5->VX5_CODIGO
	cDesc := VX5->VX5_DESCRI
	AADD(aParamBox,{1,STR0003,cCod,"@!","","",".f.",50,.t.}) // Codigo
	AADD(aParamBox,{1,STR0004,cDesc,"@!","","",".F.",110,.t.}) // Descricao
	If ParamBox(aParamBox,"",@aRet,,,,,,,,.f.)
		DbSelectArea("VX5")
		RecLock("VX5",.f.,.t.)
			if VX5->(fieldpos('VX5_DATALT')) > 0
				VX5->VX5_DATALT := FGX_Timestamp()
			endif
			VX5->(dbDelete())
		MsUnLock()
	EndIf
Else
	MsgStop(STR0008,STR0005) // Registro padrão do sistema. Impossivel Excluir! / Atencao
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA560CB ³ Autor ³ Rubens Takahashi                ³ Data ³ 04/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao auxiliar para criar opção em um Combo                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA560CB(cChave, nTamChave)

Local cSQL
Local cRetorno := ""
Local cAliasVX5 := "TVX5"
Local cArea := GetArea()

cSQL := "SELECT VX5_CODIGO, VX5_DESCRI"
cSQL +=  " FROM " + RetSQLName("VX5") + " VX5"
cSQL += " WHERE VX5_FILIAL = '" + xFilial("VX5") + "'"
cSQL +=   " AND VX5_CHAVE  = '" + cChave + "'"
cSQL +=   " AND D_E_L_E_T_ = ' '"
cSQL += " ORDER BY VX5_CODIGO"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVX5, .F., .T. )
While !((cAliasVX5)->(Eof()))
	cRetorno += Left((cAliasVX5)->VX5_CODIGO,nTamChave) + "=" + AllTrim((cAliasVX5)->VX5_DESCRI) + ";"
	(cAliasVX5)->(dbSkip())
End
If !Empty(cRetorno)
	cRetorno := Left(cRetorno,Len(cRetorno)-1)
EndIf

(cAliasVX5)->(dbCloseArea())
RestArea( cArea )

Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA560PCB ³ Autor ³ Rubens Takahashi               ³ Data ³ 04/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao auxiliar para crirar array para ser utilizada em um combo de    ³±±
±±³          ³ Parambox                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA560PCB(cChave, nTamChave)

	Local cSQL
	Local cAliasVX5 := "TVX5"
	Local cArea := GetArea()
	Local aRetorno := {}

	cSQL := "SELECT VX5_CODIGO, VX5_DESCRI"
	cSQL +=  " FROM " + RetSQLName("VX5") + " VX5"
	cSQL += " WHERE VX5_FILIAL = '" + xFilial("VX5") + "'"
	cSQL +=   " AND VX5_CHAVE  = '" + cChave + "'"
	cSQL +=   " AND D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY VX5_CODIGO"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVX5, .F., .T. )
	While !((cAliasVX5)->(Eof()))
		AADD( aRetorno , Left((cAliasVX5)->VX5_CODIGO,nTamChave) + "=" + AllTrim((cAliasVX5)->VX5_DESCRI) )
		(cAliasVX5)->(dbSkip())
	End

	(cAliasVX5)->(dbCloseArea())
	RestArea( cArea )

Return aClone(aRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA560DS ³ Autor ³ Rubens Takahashi                ³ Data ³ 04/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao auxiliar para retornar a descricao                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA560DS(cTabela,cCodigo)

Return (FM_SQL("SELECT VX5_DESCRI FROM " + RetSQLName("VX5") + " WHERE VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5_CHAVE = '" + cTabela + "' AND VX5_CODIGO = '" + cCodigo + "' AND D_E_L_E_T_ = ' '"))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA560VL ³ Autor ³ Rubens Takahashi                ³ Data ³ 24/02/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao auxiliar para retornar se existe a chave digitada e grava a     ³±±
±±³          ³ descricao em uma variavel enviada por parametro                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA560VL(cTabela,cCodigo,cCpoDescri,lExibeMsg)

Local cSQL
Local cAliasVX5 := "TVX5"
Local lRetorno := .f.

Default lExibeMsg := .t.

cSQL := "SELECT VX5_DESCRI "
cSQL +=  " FROM " + RetSQLName("VX5")
cSQL += " WHERE VX5_FILIAL = '" + xFilial("VX5") + "'"
cSQL +=   " AND VX5_CHAVE = '" + cTabela + "'"
cSQL +=   " AND VX5_CODIGO = '" + cCodigo + "'"
cSQL +=   " AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVX5 , .F., .T. )
If !(cAliasVX5)->(Eof())
	lRetorno := .t.
	If cCpoDescri <> NIL
		cCpoDescri := (cAliasVX5)->VX5_DESCRI
	EndIf
Else
	If lExibeMsg
		HELP(" ",1,"REGNOIS",,STR0002 + ": " + cTabela + CHR(13) + CHR(10) + STR0003 + ": " + cCodigo,4,1)
	EndIf
	If cCpoDescri <> NIL
		cCpoDescri := Space(TamSX3("VX5_DESCRI")[1])
	EndIf
End
(cAliasVX5)->(dbCloseArea())

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA560FL ³ Autor ³ Rubens Takahashi                ³ Data ³ 04/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao auxiliar para filtrar Consulta Padrao                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA560FL(cFiltro,cFilVX5)

Local lRetorno := .f.

Default cFiltro := ReadVar()
Default cFilVX5 := ""

Private cFiltroVX5 := cFilVX5

If Empty(cFiltroVX5)
	Do Case
		Case cFiltro == "M->VMY_MKTCOD"
			cFiltroVX5 := "007"
		Case cFiltro == "M->VMY_CTYPE"
			cFiltroVX5 := "004"
		Case AllTrim(cFiltro) $ "M->VMY_UN1/M->VMY_UN2/M->VMB_UNIMED/M->VMB_UNUSPC"
			cFiltroVX5 := "005"
		Case cFiltro == "M->VMB_TIPGAR"
			cFiltroVX5 := "006"
		Case cFiltro == "M->VMB_SUBGAR"
			cFiltroVX5 := "010"
		Case cFiltro == "M->VMB_APLICA"
			cFiltroVX5 := IIF(M->VMB_TIPGAR="ZZBT","008","009")
		Case cFiltro == "M->VMB_FALHA"
			cFiltroVX5 := IIF(M->VMB_TIPGAR="ZZBT","024","011")
		Case cFiltro == "M->VMB_MAQPAR"
			cFiltroVX5 := "012"
		Case cFiltro == "M->VMB_TIPESP"
			cFiltroVX5 := "013"
		Case cFiltro == "M->VMB_INTSRV"
			cFiltroVX5 := "014"
		Case cFiltro == "M->VMB_TIPMAQ"
			cFiltroVX5 := "015"
		Case cFiltro == "M->VMC_TIPTRA"
			cFiltroVX5 := "017"
		Case cFiltro == "M->VMC_CODMAT"
			cFiltroVX5 := "022"
		Case cFiltro == "M->VDL_PERFIL"
			cFiltroVX5 := "025"
		Case cFiltro $  "M->VDM_CAMPOP/M->VDY_CAMPOP/M->VDQ_CAMPOP/M->VDI_CAMPOP/M->VDJ_CAMPOP"
			cFiltroVX5 := "026"
		Case cFiltro $  "M->VDM_TIPMID/M->VS1_TIPMID/M->VDQ_TIPMID/M->VDI_TIPMID/M->VDJ_TIPMID"
			cFiltroVX5 := "027"
		Case cFiltro == "M->VDM_FASFIN"
			cFiltroVX5 := "031"
		Case cFiltro == "M->VDM_LINCRE"
			cFiltroVX5 := "032"
		Case cFiltro == "M->VCF_CODSEG"
			cFiltroVX5 := "033"
		Case cFiltro $  "M->A1_SATIV5/M->A1_SATIV6/M->A1_SATIV7/M->A1_SATIV8"
			cFiltroVX5 := "033"
		Case cFiltro == "M->VST_CODFAL"
			cFiltroVX5 := "034"
		Case cFiltro == "M->VER_AGRUPA"
			cFiltroVX5 := "035"
		Case cFiltro == "M->VG6_TPCUST"
			cFiltroVX5 := "038"
		Case cFiltro == "M->VGH_CGAR"
			cFiltroVX5 := "042"
		Case cFiltro == "M->VGH_TIPREC"
			cFiltroVX5 := "041"
		Case cFiltro == "M->VGH_FALHA"
			cFiltroVX5 := "040"
		Case cFiltro == "M->VDM_DECVDA"
			cFiltroVX5 := "044"
		Case cFiltro == "M->VQQ_CMPMOT"
			cFiltroVX5 := "045"
		Case cFiltro $  "M->VO1_TPATEN/M->VS1_TPATEN/M->VSO_TPATEN/M->VCP_TPATEN" .OR. FunName() == "OFIOR450"
			cFiltroVX5 := "050"
		Case cFiltro == "M->VAI_CLAHAB"
			cFiltroVX5 := "052"
		Case cFiltro == "M->VV2_CORINT" .or. cFiltro == "M->VRK_CORINT"
			cFiltroVX5 := "066"
		Case cFiltro == "M->VV2_COREXT" .or. cFiltro == "M->VRK_COREXT"
			cFiltroVX5 := "067"
		Case cFiltro == "M->VV2_OPCION" .or. cFiltro == "M->VRK_OPCION"
			cFiltroVX5 := "068"
		Case cFiltro == "M->VJJ_QTYPE"
			cFiltroVX5 := "071"
		Case cFiltro == "M->VJJ_QSTATU"
			cFiltroVX5 := "072"
		Case cFiltro == "M->VQW_TIPSIN"
			cFiltroVX5 := "053"
		Case cFiltro == "M->VFF_CODGRF"
			cFiltroVX5 := "078"
		Case cFiltro == "M->VFF_CODDRF"
			cFiltroVX5 := "079"
		Case cFiltro == "M->VS1_PRISEP" .or. cFiltro == "M->VM3_PRISEP"
			cFiltroVX5 := "077"
		Case cFiltro == "M->VV2_CORINT" .or. cFiltro == "M->VRK_CORINT"
			cFiltroVX5 := "066"
		Case cFiltro == "M->VV2_COREXT" .or. cFiltro == "M->VRK_COREXT"
			cFiltroVX5 := "067"
		Case cFiltro == "M->VV2_OPCION" .or. cFiltro == "M->VRK_OPCION"
			cFiltroVX5 := "068"
		Case cFiltro == "M->VJR_EVENTO"
			cFiltroVX5 := "051"
		Case cFiltro == "M->VK1_CULTUR"
			cFiltroVX5 := "003"
		Case cFiltro $ "M->VCF_MERLBM/M->VCF_MERLBT/M->VCF_MERLBH/M->VCF_MERBAT/M->VCF_MERGRX/M->VCF_MERADT/M->VCF_MERBAC/M->VCF_MERLQA/M->VCF_MERPRA/M->VCF_MERSBG/M->VCF_MERTSE"
			cFiltroVX5 := "081"
		Case cFiltro $ "M->VN0_BASCOD/M->PARBASCOD/"
			cFiltroVX5 := "082"
		OtherWise // CUSTOMIZADO
			If ExistBlock("OF560VX5")
				cFiltroVX5 := ExecBlock("OF560VX5",.f.,.f.,{ "2" , cFiltro }) // 2 = Qual tabela VX5 deve ser utilizada no F3 de um determinado campo ?
			EndIf
	EndCase
EndIf

dbSelectArea("VX5")
lRetorno := ConPad1( , , , "VX5AUX" , , , .F. )

Return lRetorno

Function OFIOA560ADD(cVX5, cCod, cDesc, cPropri)
	Default cPropri := "S"
	
	RecLock("VX5",.t.)
		VX5->VX5_FILIAL := FWxFilial("VX5")
		VX5->VX5_CHAVE  := cVX5
		VX5->VX5_CODIGO := cCod
		VX5->VX5_DESCRI := cDesc
		VX5->VX5_PROPRI := cPropri
	VX5->(MsUnLock())
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Andre Luis Almeida                ³ Data ³ 04/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA)                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {}
aRotina := {{ STR0009 ,"AxPesqui" ,0,1},;	// Pesquisar
			{ STR0010 ,"AxVisual" ,0,2},;	// Visualizar
			{ STR0011 ,"OFIOA560I" ,0,3},;	// Incluir
			{ STR0012 ,"OFIOA560A" ,0,4},;	// Alterar
			{ STR0013 ,"OFIOA560E" ,0,5}}	// Excluir
Return aRotina
