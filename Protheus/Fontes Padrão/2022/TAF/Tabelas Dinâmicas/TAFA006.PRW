#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA006.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA006
Cadastro MVC dos Tipos de Logradouros - Tabela 20 

@author Mauro A. Goncalves
@since 03/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA006()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Tipos de Logradouros
oBrw:SetAlias( 'C06')
oBrw:SetMenuDef( 'TAFA006' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 03/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA006" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 03/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC06 	:= 	FWFormStruct( 1, 'C06' )
Local oModel 	:= 	MPFormModel():New( 'TAFA006' )

oModel:AddFields('MODEL_C06', /*cOwner*/, oStruC06)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 03/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA006' )
Local 	oStruC06 	:= 	FWFormStruct( 2, 'C06' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C06', oStruC06, 'MODEL_C06' )

oView:EnableTitleView( 'VIEW_C06', STR0001 ) //Cadastro de Tipos de Logradouros
oView:CreateHorizontalBox( 'FIELDSC06', 100 )
oView:SetOwnerView( 'VIEW_C06', 'FIELDSC06' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

	nVerAtu := 1031.26

If nVerEmp < nVerAtu

	aAdd( aHeader, "C06_FILIAL" )
	aAdd( aHeader, "C06_ID" )
	aAdd( aHeader, "C06_CODIGO" )
	aAdd( aHeader, "C06_DESCRI" )
	aAdd( aHeader, "C06_CESOCI" )
	
	aAdd( aBody, { "", "000001", "01", "AEROPORTO", "AER" } )
	aAdd( aBody, { "", "000002", "02", "ALAMEDA", "AL" } )
	aAdd( aBody, { "", "000003", "03", "AREA", "A" } )
	aAdd( aBody, { "", "000004", "04", "AVENIDA", "AV" } )
	aAdd( aBody, { "", "000005", "05", "CAMPO", "CPO" } )
	aAdd( aBody, { "", "000006", "06", "CHACARA", "CH" } )
	aAdd( aBody, { "", "000007", "07", "COLONIA", "COL" } )
	aAdd( aBody, { "", "000008", "08", "CONDOMINIO", "COND" } )
	aAdd( aBody, { "", "000009", "09", "CONJUNTO", "CJ" } )
	aAdd( aBody, { "", "000010", "10", "DISTRITO", "DT" } )
	aAdd( aBody, { "", "000011", "11", "ESPLANADA", "ESP" } )
	aAdd( aBody, { "", "000012", "12", "ESTACAO", "ETC" } )
	aAdd( aBody, { "", "000013", "13", "ESTRADA", "EST" } )
	aAdd( aBody, { "", "000014", "14", "FAVELA", "FAV" } )
	aAdd( aBody, { "", "000015", "15", "FAZENDA", "FAZ" } )
	aAdd( aBody, { "", "000016", "16", "FEIRA", "FRA" } )
	aAdd( aBody, { "", "000017", "17", "JARDIM", "JD" } )
	aAdd( aBody, { "", "000018", "18", "LADEIRA", "LD" } )
	aAdd( aBody, { "", "000019", "19", "LAGO", "LGO" } )
	aAdd( aBody, { "", "000020", "20", "LAGOA", "LGA" } )
	aAdd( aBody, { "", "000021", "21", "LARGO", "LRG" } )
	aAdd( aBody, { "", "000022", "22", "LOTEAMENTO", "LOT" } )
	aAdd( aBody, { "", "000023", "23", "MORRO", "MRO" } )
	aAdd( aBody, { "", "000024", "24", "NUCLEO", "NUC" } )
	aAdd( aBody, { "", "000025", "25", "PARQUE", "PRQ" } )
	aAdd( aBody, { "", "000026", "26", "PASSARELA", "PSA" } )
	aAdd( aBody, { "", "000027", "27", "PATIO", "PAT" } )
	aAdd( aBody, { "", "000028", "28", "PRACA", "PC" } )
	aAdd( aBody, { "", "000029", "29", "QUADRA", "Q" } )
	aAdd( aBody, { "", "000030", "30", "RECANTO", "REC" } )
	aAdd( aBody, { "", "000031", "31", "RESIDENCIAL", "RES" } )
	aAdd( aBody, { "", "000032", "32", "RODOVIA", "ROD" } )
	aAdd( aBody, { "", "000033", "33", "RUA", "R" } )
	aAdd( aBody, { "", "000034", "34", "SETOR", "ST" } )
	aAdd( aBody, { "", "000035", "35", "SITIO", "SIT" } )
	aAdd( aBody, { "", "000036", "36", "TRAVESSA", "TV" } )
	aAdd( aBody, { "", "000037", "37", "TRECHO", "TR" } )
	aAdd( aBody, { "", "000038", "38", "TREVO", "TRV" } )
	aAdd( aBody, { "", "000039", "39", "VALE", "VLE" } )
	aAdd( aBody, { "", "000040", "40", "VEREDA", "VER" } )
	aAdd( aBody, { "", "000041", "41", "VIA", "V" } )
	aAdd( aBody, { "", "000042", "42", "VIADUTO", "VD" } )
	aAdd( aBody, { "", "000043", "43", "VIELA", "VLA" } )
	aAdd( aBody, { "", "000044", "44", "VILA", "VL" } )
	aAdd( aBody, { "", "000045", "99", "OUTROS", "O" } )
	aAdd( aBody, { "", "000046", "00", "LINHA", "" } )
	aAdd( aBody, { "", "000047", "00", "MARGEM", "RPR" } )
	aAdd( aBody, { "", "000048", "00", "PASSAGEM", "PSG" } )
	aAdd( aBody, { "", "000049", "00", "PRAIA", "PR" } )
	aAdd( aBody, { "", "000050", "00", "SUPERQUADRA", "" } )
	aAdd( aBody, { "", "000051", "00","ACESSO", "AC"} )
	aAdd( aBody, { "", "000052", "00","ACAMPAMENTO", "ACA"} )
	aAdd( aBody, { "", "000053", "00","ACESSO LOCAL", "ACL"} )
	aAdd( aBody, { "", "000054", "00","ADRO", "AD"} )
	aAdd( aBody, { "", "000055", "00","ÁREA ESPECIAL", "AE"} )
	aAdd( aBody, { "", "000056", "00","AVENIDA MARGINAL DIREITA", "AMD"} )
	aAdd( aBody, { "", "000057", "00","AVENIDA MARGINAL ESQUERDA", "AME"} )
	aAdd( aBody, { "", "000058", "00","ANEL VIÁRIO", "AN"} )
	aAdd( aBody, { "", "000059", "00","ANTIGA ESTRADA", "ANT"} )
	aAdd( aBody, { "", "000060", "00","ARTÉRIA", "ART"} )
	aAdd( aBody, { "", "000061", "00","ALTO", "AT"} )
	aAdd( aBody, { "", "000062", "00","ATALHO", "ATL"} )
	aAdd( aBody, { "", "000063", "00","ÁREA VERDE", "A V"} )
	aAdd( aBody, { "", "000064", "00","AVENIDA CONTORNO", "AVC"} )
	aAdd( aBody, { "", "000065", "00","AVENIDA MARGINAL", "AVM"} )
	aAdd( aBody, { "", "000066", "00","AVENIDA VELHA", "AVV"} )
	aAdd( aBody, { "", "000067", "00","BALNEÁRIO", "BAL"} )
	aAdd( aBody, { "", "000068", "00","BECO", "BC"} )
	aAdd( aBody, { "", "000069", "00","BURACO", "BCO"} )
	aAdd( aBody, { "", "000070", "00","BELVEDERE", "BEL"} )
	aAdd( aBody, { "", "000071", "00","BALÃO", "BLO"} )
	aAdd( aBody, { "", "000072", "00","BLOCOS", "BLS"} )
	aAdd( aBody, { "", "000073", "00","BULEVAR", "BLV"} )
	aAdd( aBody, { "", "000074", "00","BOSQUE", "BSQ"} )
	aAdd( aBody, { "", "000075", "00","BOULEVARD", "BVD"} )
	aAdd( aBody, { "", "000076", "00","BAIXA", "BX"} )
	aAdd( aBody, { "", "000077", "00","CAIS", "C"} )
	aAdd( aBody, { "", "000078", "00","CALÇADA", "CAL"} )
	aAdd( aBody, { "", "000079", "00","CAMINHO", "CAM"} )
	aAdd( aBody, { "", "000080", "00","CANAL", "CAN"} )
	aAdd( aBody, { "", "000082", "00","CHAPADÃO", "CHA"} )
	aAdd( aBody, { "", "000083", "00","CICLOVIA", "CIC"} )
	aAdd( aBody, { "", "000084", "00","CIRCULAR", "CIR"} )
	aAdd( aBody, { "", "000085", "00","CONJUNTO MUTIRÃO", "CJM"} )
	aAdd( aBody, { "", "000086", "00","COMPLEXO VIÁRIO", "CMP"} )
	aAdd( aBody, { "", "000088", "00","COMUNIDADE", "COM"} )
	aAdd( aBody, { "", "000089", "00","CONDOMÍNIO", "CON"} )
	aAdd( aBody, { "", "000090", "00","CORREDOR", "COR"} )
	aAdd( aBody, { "", "000091", "00","CÓRREGO", "CRG"} )
	aAdd( aBody, { "", "000092", "00","CONTORNO", "CTN"} )
	aAdd( aBody, { "", "000093", "00","DESCIDA", "DSC"} )
	aAdd( aBody, { "", "000094", "00","DESVIO", "DSV"} )
	aAdd( aBody, { "", "000095", "00","ENTRE BLOCO", "EB"} )
	aAdd( aBody, { "", "000096", "00","ESTRADA INTERMUNICIPAL", "EIM"} )
	aAdd( aBody, { "", "000097", "00","ENSEADA", "ENS"} )
	aAdd( aBody, { "", "000098", "00","ESTRADA PARTICULAR", "ENT"} )
	aAdd( aBody, { "", "000099", "00","ENTRE QUADRA", "EQ"} )
	aAdd( aBody, { "", "000100", "00","ESCADA", "ESC"} )
	aAdd( aBody, { "", "000101", "00","ESCADARIA", "ESD"} )
	aAdd( aBody, { "", "000102", "00","ESTRADA ESTADUAL", "ESE"} )
	aAdd( aBody, { "", "000103", "00","ESTRADA VICINAL", "ESI"} )
	aAdd( aBody, { "", "000104", "00","ESTRADA DE LIGAÇÃO", "ESL"} )
	aAdd( aBody, { "", "000105", "00","ESTRADA MUNICIPAL", "ESM"} )
	aAdd( aBody, { "", "000107", "00","ESTRADA DE SERVIDÃO", "ESS"} )
	aAdd( aBody, { "", "000108", "00","ESTRADA VELHA", "ESV"} )
	aAdd( aBody, { "", "000109", "00","ESTRADA ANTIGA", "ETA"} )
	aAdd( aBody, { "", "000111", "00","ESTÁDIO", "ETD"} )
	aAdd( aBody, { "", "000112", "00","ESTÂNCIA", "ETN"} )
	aAdd( aBody, { "", "000113", "00","ESTRADA PARTICULAR", "ETP"} )
	aAdd( aBody, { "", "000114", "00","ESTACIONAMENTO", "ETT"} )
	aAdd( aBody, { "", "000115", "00","EVANGÉLICA", "EVA"} )
	aAdd( aBody, { "", "000116", "00","ELEVADA", "EVD"} )
	aAdd( aBody, { "", "000117", "00","EIXO INDUSTRIAL", "EX"} )
	aAdd( aBody, { "", "000118", "00","FERROVIA", "FER"} )
	aAdd( aBody, { "", "000119", "00","FONTE", "FNT"} )
	aAdd( aBody, { "", "000120", "00","FORTE", "FTE"} )
	aAdd( aBody, { "", "000121", "00","NÚCLEO HABITACIONAL", "HAB"} )
	aAdd( aBody, { "", "000122", "00","ILHA", "IA"} )
	aAdd( aBody, { "", "000123", "00","INDETERMINADO", "IND"} )
	aAdd( aBody, { "", "000124", "00","ILHOTA", "IOA"} )
	aAdd( aBody, { "", "000125", "00","JARDINETE", "JDE"} )
	aAdd( aBody, { "", "000126", "00","LOTE", "LT"} )
	aAdd( aBody, { "", "000127", "00","MERCADO", "MER"} )
	aAdd( aBody, { "", "000128", "00","MARINA", "MNA"} )
	aAdd( aBody, { "", "000129", "00","MODULO", "MOD"} )
	aAdd( aBody, { "", "000130", "00","PROJEÇÃO", "MRG"} )
	aAdd( aBody, { "", "000131", "00","MONTE", "MTE"} )
	aAdd( aBody, { "", "000133", "00","NÚCLEO RURAL", "NUR"} )
	aAdd( aBody, { "", "000134", "00","OUTEIRO", "OUT"} )
	aAdd( aBody, { "", "000135", "00","PARALELA", "PAR"} )
	aAdd( aBody, { "", "000136", "00","PASSEIO", "PAS"} )
	aAdd( aBody, { "", "000137", "00","PÁTIO", "PAT"} )
	aAdd( aBody, { "", "000139", "00","PRAÇA DE ESPORTES", "PCE"} )
	aAdd( aBody, { "", "000140", "00","PARADA", "PDA"} )
	aAdd( aBody, { "", "000141", "00","PARADOURO", "PDO"} )
	aAdd( aBody, { "", "000142", "00","PONTA", "PNT"} )
	aAdd( aBody, { "", "000143", "00","PROLONGAMENTO", "PRL"} )
	aAdd( aBody, { "", "000144", "00","PARQUE MUNICIPAL", "PRM"} )
	aAdd( aBody, { "", "000145", "00","PARQUE RESIDENCIAL", "PRR"} )
	aAdd( aBody, { "", "000146", "00","PASSAGEM DE PEDESTRE", "PSP"} )
	aAdd( aBody, { "", "000147", "00","PASSAGEM SUBTERRÂNEA", "PSS"} )
	aAdd( aBody, { "", "000148", "00","PONTE", "PTE"} )
	aAdd( aBody, { "", "000149", "00","PORTO", "PTO"} )
	aAdd( aBody, { "", "000150", "00","QUINTA", "QTA"} )
	aAdd( aBody, { "", "000151", "00","QUINTAS", "QTS"} )
	aAdd( aBody, { "", "000152", "00","RUA INTEGRAÇÃO", "R I"} )
	aAdd( aBody, { "", "000153", "00","RUA DE LIGAÇÃO", "R L"} )
	aAdd( aBody, { "", "000154", "00","RUA PARTICULAR", "R P"} )
	aAdd( aBody, { "", "000155", "00","RUA VELHA", "R V"} )
	aAdd( aBody, { "", "000156", "00","RAMAL", "RAM"} )
	aAdd( aBody, { "", "000157", "00","RECREIO", "RCR"} )
	aAdd( aBody, { "", "000158", "00","RETIRO", "RER"} )
	aAdd( aBody, { "", "000159", "00","RETA", "RET"} )
	aAdd( aBody, { "", "000160", "00","RUELA", "RLA"} )
	aAdd( aBody, { "", "000161", "00","RAMPA", "RMP"} )
	aAdd( aBody, { "", "000162", "00","RODO ANEL", "ROA"} )
	aAdd( aBody, { "", "000163", "00","ROTULA", "ROT"} )
	aAdd( aBody, { "", "000164", "00","RUA DE PEDESTRE", "RPE"} )
	aAdd( aBody, { "", "000165", "00","RETORNO", "RTN"} )
	aAdd( aBody, { "", "000166", "00","ROTATÓRIA", "RTT"} )
	aAdd( aBody, { "", "000167", "00","SEGUNDA AVENIDA", "SEG"} )
	aAdd( aBody, { "", "000168", "00","SERVIDÃO", "SRV"} )
	aAdd( aBody, { "", "000169", "00","SUBIDA", "SUB"} )
	aAdd( aBody, { "", "000170", "00","TRINCHEIRA", "TCH"} )
	aAdd( aBody, { "", "000171", "00","TERMINAL", "TER"} )
	aAdd( aBody, { "", "000172", "00","TÚNEL", "TUN"} )
	aAdd( aBody, { "", "000173", "00","TRAVESSA PARTICULAR", "TVP"} )
	aAdd( aBody, { "", "000174", "00","TRAVESSA VELHA", "TVV"} )
	aAdd( aBody, { "", "000175", "00","UNIDADE", "UNI"} )
	aAdd( aBody, { "", "000176", "00","VIA COLETORA", "V C"} )
	aAdd( aBody, { "", "000177", "00","VIA LOCAL", "V L"} )
	aAdd( aBody, { "", "000178", "00","VIA DE ACESSO", "VAC"} )
	aAdd( aBody, { "", "000179", "00","VALA", "VAL"} )
	aAdd( aBody, { "", "000180", "00","VIA COSTEIRA", "VCO"} )
	aAdd( aBody, { "", "000181", "00","VIA EXPRESSA", "V-E"} )
	aAdd( aBody, { "", "000182", "00","VIA ELEVADO", "VEV"} )
	aAdd( aBody, { "", "000183", "00","VIA LITORÁNEA", "VLT"} )
	aAdd( aBody, { "", "000184", "00","VIA DE PEDESTRE", "VPE"} )
	aAdd( aBody, { "", "000185", "00","VARIANTE", "VRT"} )
	aAdd( aBody, { "", "000186", "00","ZIGUE-ZAGUE", "ZIG"} )
		
	//Layout 2.2
	aAdd( aBody, { "", "000187", "00","BLOCO", "BL"} )
	aAdd( aBody, { "", "000188", "00","GALERIA", "GAL"} )
	aAdd( aBody, { "", "000189", "00","GRANJA", "GJA"} )
	
	//Layout 1.0
	
	aAdd( aBody, { "", "000190", "00","ALDEIA", "ALD"} )
	aAdd( aBody, { "", "000191", "00","IGARAPÉ", "IGP"} )

	aAdd( aRet, { aHeader, aBody } )
	
EndIf

Return( aRet )
