#Include 'Protheus.ch'
#Include 'RwMake.ch'

/*/{Protheus.doc} FisaExtSx_Class
	(Classe que contém as informações dos SX's.)

	@type Class
	@author Vitor Ribeiro
	@since 15/03/2018

	@return Nil, nulo, não tem retorno.
    /*/
Class FisaExtSx_Class

    Data _SX2 as array ReadOnly
    Data _SX3 as array ReadOnly
    Data _SX6 as array ReadOnly

    /*
        Inicio - Atributos referentes ao SX2
    */
    Data _AI0 as logical ReadOnly
    Data _AIF as logical ReadOnly
    Data _CCF as logical ReadOnly
    Data _CD3 as logical ReadOnly
    Data _CD5 as logical ReadOnly
    Data _CDG as logical ReadOnly
    Data _CDL as logical ReadOnly
    Data _CDN as logical ReadOnly
    Data _CDT as logical ReadOnly
    Data _CDV as logical ReadOnly
    Data _CF2 as logical ReadOnly
    Data _CF5 as logical ReadOnly
    Data _CF6 as logical ReadOnly
    Data _CF8 as logical ReadOnly
    Data _CF9 as logical ReadOnly
    Data _CT1 as logical ReadOnly
    Data _DT3 as logical ReadOnly
    Data _DT5 as logical ReadOnly
    Data _DUL as logical ReadOnly
    Data _F0F as logical ReadOnly
    Data _F0I as logical ReadOnly
    Data _F2Q as logical ReadOnly    
    Data _SA1 as logical ReadOnly
    Data _SA2 as logical ReadOnly
    Data _SB1 as logical ReadOnly
    Data _SD1 as logical ReadOnly
    Data _SD2 as logical ReadOnly
    Data _SF1 as logical ReadOnly
    Data _SF4 as logical ReadOnly
    Data _SF9 as logical ReadOnly
    Data _SFA as logical ReadOnly
    Data _SFT as logical ReadOnly
    Data _SFU as logical ReadOnly
    Data _SFX as logical ReadOnly
    Data _SL1 as logical ReadOnly
    Data _SL4 as logical ReadOnly
    Data _SLG as logical ReadOnly
    Data _SON as logical ReadOnly
    Data _DHR as logical ReadOnly
    Data _DHT as logical ReadOnly
    /*
        Fim - Atributos referentes ao SX2
    */

    /*
        Inicio - Atributos referentes ao SX3
     */
    Data _A1_REGPB as logical ReadOnly
    Data _A1_SIMPNAC as logical ReadOnly
    Data _A2_CPRB as logical ReadOnly
    Data _A2_DESPORT as logical ReadOnly
    Data _A2_REGPB as logical ReadOnly
    Data _A2_SIMPNAC as logical ReadOnly
    Data _B1_CNATREC as logical ReadOnly
    Data _B1_DTFIMNT as logical ReadOnly
    Data _B1_GRPNATR as logical ReadOnly
    Data _B1_TNATREC as logical ReadOnly
    Data _CCF_IDITEM as logical ReadOnly
    Data _CCF_INDAUT as logical ReadOnly
    Data _CCF_SUSEXI as logical ReadOnly
    Data _CCF_TRIB as logical ReadOnly
    Data _CCF_INDSUS as logical ReadOnly
    Data _CD3_CHV115 as logical ReadOnly
    Data _CD3_VOL115 as logical ReadOnly
    Data _CD5_ACDRAW as logical ReadOnly
    Data _CD5_DTPCOF as logical ReadOnly
    Data _CD5_DTPPIS as logical ReadOnly
    Data _CD5_LOCAL as logical ReadOnly
    Data _CDG_ITEM as logical ReadOnly
    Data _CDG_ITPROC as logical ReadOnly
    Data _CDL_CHVEXP as logical ReadOnly
    Data _CDL_DOCORI as logical ReadOnly
    Data _CDL_EMIEXP as logical ReadOnly
    Data _CDL_ESPEXP as logical ReadOnly
    Data _CDL_FORNEC as logical ReadOnly
    Data _CDL_ITEMNF as logical ReadOnly
    Data _CDL_LOJFOR as logical ReadOnly
    Data _CDL_NFEXP as logical ReadOnly
    Data _CDL_QTDEXP as logical ReadOnly
    Data _CDL_SEREXP as logical ReadOnly
    Data _CDL_SERORI as logical ReadOnly
    Data _CDN_TPSERV as logical ReadOnly
    Data _CDT_DCCOMP as logical ReadOnly
    Data _CDT_DTAREC as logical ReadOnly
    Data _CDT_INDFRT as logical ReadOnly
    Data _CDT_SITEXT as logical ReadOnly
    Data _CF5_TIPAJU as logical ReadOnly
    Data _CF6_CNPJ as logical ReadOnly
    Data _CT1_DTEXIS as logical ReadOnly
    Data _D1_ALFCCMP as logical ReadOnly
    Data _D1_ALIQCMP as logical ReadOnly
    Data _D1_TPREPAS as logical ReadOnly
    Data _D2_TPREPAS as logical ReadOnly
    Data _DT3_TIPCMP as logical ReadOnly
    Data _DT5_CODSOL as logical ReadOnly
    Data _DUL_CODCLI as logical ReadOnly
    Data _F0F_INDPAA as logical ReadOnly
    Data _F1_TPCTE as logical ReadOnly
    Data _F2Q_TPSERV as logical ReadOnly    
    Data _F4_CNATREC as logical ReadOnly
    Data _F4_DTFIMNT as logical ReadOnly
    Data _F4_GRPNATR as logical ReadOnly
    Data _F4_TNATREC as logical ReadOnly
    Data _F4_VLAGREG as logical ReadOnly
    Data _F9_CODBAIX as logical ReadOnly
    Data _F9_PARCRED as logical ReadOnly
    Data _F9_QTDPARC as logical ReadOnly
    Data _F9_SLDPARC as logical ReadOnly
    Data _F9_TIPO as logical ReadOnly
    Data _FA_TOTSAI as logical ReadOnly
    Data _FA_TOTTRIB as logical ReadOnly
    Data _FT_CHVNFE as logical ReadOnly
    Data _FT_CLIDVMC as logical ReadOnly
    Data _FT_CNATREC as logical ReadOnly
    Data _FT_CSTCOF as logical ReadOnly
    Data _FT_CSTPIS as logical ReadOnly
    Data _FT_DESCICM as logical ReadOnly
    Data _FT_DESCZFR as logical ReadOnly
    Data _FT_DESPICM as logical ReadOnly
    Data _FT_DIFAL as logical ReadOnly
    Data _FT_DTFIMNT as logical ReadOnly
    Data _FT_GRUPONC as logical ReadOnly
    Data _FT_INDNTFR as logical ReadOnly
    Data _FT_MALQCOF as logical ReadOnly
    Data _FT_MVALCOF as logical ReadOnly
    Data _FT_PAUTCOF as logical ReadOnly
    Data _FT_PAUTIPI as logical ReadOnly
    Data _FT_PAUTIPIK as logical ReadOnly
    Data _FT_PAUTPIS as logical ReadOnly
    Data _FT_TAFKEY as logical ReadOnly
    Data _FT_TNATREC as logical ReadOnly
    Data _FT_VFCPDIF as logical ReadOnly
    Data _FU_CLASCON as logical ReadOnly
    Data _FU_CLASSIF as logical ReadOnly
    Data _FU_GRUPT as logical ReadOnly
    Data _FU_TIPLIGA as logical ReadOnly
    Data _FU_VLFORN as logical ReadOnly
    Data _FX_TPASSIN as logical ReadOnly
    Data _LG_SERSAT as logical ReadOnly

    Data _A2_ISEIMUN as logical ReadOnly
    Data _A2_ESTEX   as logical ReadOnly
    Data _A2_TELRE   as logical ReadOnly
    Data _A2_NIFEX   as logical ReadOnly
    Data _A2_MOTNIF  as logical ReadOnly
    Data _A2_TRBEX   as logical ReadOnly




    /*
        Fim - Atributos referentes ao SX3
    */

    /*
        Inicio - Atributos referentes ao SX6
    */
    Data _MV_ESTADO as string ReadOnly
    Data _MV_UFRESPD as string ReadOnly
    Data _MV_EASY as string ReadOnly
    Data _MV_OPSEMF as string ReadOnly
    Data _MV_COMPFRT as string ReadOnly
    Data _MV_STUF as string ReadOnly
    Data _MV_STUFS as string ReadOnly
    Data _MV_STNIEUF as string ReadOnly
    Data _MV_RESF3FT as logical ReadOnly
    Data _MV_APUSEP as string ReadOnly
    Data _MV_LJSPED as string ReadOnly
    Data _MV_CODBCCR as string ReadOnly
    Data _MV_CODBCCC as string ReadOnly
    Data _MV_SPCBPRH as logical ReadOnly
    Data _MV_SPCBPSE as string ReadOnly
    Data _MV_DATCIAP as string ReadOnly
    Data _MV_LC102 as string ReadOnly
    Data _MV_CIAPDAC as string ReadOnly
    Data _MV_F9ITEM as string ReadOnly
    Data _MV_F9PROD as string ReadOnly
    Data _MV_F9ESP as string ReadOnly
    Data _MV_F9CHVNF as string ReadOnly
    Data _MV_F9CC as string ReadOnly
    Data _MV_F9PL as string ReadOnly
    Data _MV_F9FRT as string ReadOnly
    Data _MV_F9ICMST as string ReadOnly
    Data _MV_F9DIF as string ReadOnly
    Data _MV_F9SKPNF as logical ReadOnly
    Data _MV_F9FUNC as string ReadOnly
    Data _MV_SF9PDES as string ReadOnly
    Data _MV_F9CTBCC as string ReadOnly
    Data _MV_F9GENCC as string ReadOnly
    Data _MV_F9GENCT as string ReadOnly
    Data _MV_F9VLLEG as string ReadOnly
    Data _MV_RNDCIAP as logical ReadOnly
    Data _MV_DACIAP as string ReadOnly
    Data _MV_F9CDATF as logical ReadOnly
    Data _MV_APRCOMP as logical ReadOnly
    Data _MV_DAPIC04 as string ReadOnly
    Data _MV_EECFAT as logical ReadOnly
    Data _MV_EECSPED as logical ReadOnly
    Data _MV_PISCOFP as logical ReadOnly
    Data _MV_SPDIFC as numeric ReadOnly
    Data _MV_PRFSPED as string ReadOnly
    Data _MV_HISTTAB as logical ReadOnly
    Data _MV_BLKTP00 as string ReadOnly
    Data _MV_BLKTP01 as string ReadOnly
    Data _MV_BLKTP02 as string ReadOnly
    Data _MV_BLKTP03 as string ReadOnly
    Data _MV_BLKTP04 as string ReadOnly
    Data _MV_BLKTP06 as string ReadOnly
    Data _MV_BLKTP10 as string ReadOnly
    Data _MV_TAFGST2 as logical ReadOnly
    Data _MV_TAFTDB as string ReadOnly
    Data _MV_TAFTALI as string ReadOnly
    Data _MV_TAFPORT as numeric ReadOnly
    Data _MV_DIMPTAF as string ReadOnly
    Data _MV_SPEDNAT as logical ReadOnly
    Data _MV_EXTQTHR as numeric ReadOnly
    Data _MV_SUBTRIB as string ReadOnly
    Data _MV_DTINCB1 as string ReadOnly
    Data _MV_ICMPAD as numeric ReadOnly
    Data _MV_RLCSPD as logical ReadOnly
    Data _MV_RE as string ReadOnly
    Data _MV_RECBNAT as string ReadOnly
    Data _MV_ESTTEL as logical ReadOnly
    Data _MV_TPAPSB1 as string ReadOnly
    Data _MV_EXTATHR as logical ReadOnly
    Data _MV_UFIPM as string ReadOnly
    Data _MV_TMSUFPG as logical ReadOnly
    /*
        Fim - Atributos referentes ao SX6
    */

    Method New() Constructor
    Method LoadSX2()
    Method LoadSX3()
    Method LoadSX6()

EndClass

/*/{Protheus.doc} New
	(Methodo construtor)

	@type Class
	@author Vitor Ribeiro
	@since 15/03/2018

	@return Nil, nulo, não tem retorno.
    /*/
Method New() Class FisaExtSx_Class

    // Inicializa o array e carrega o SX2
    Self:_SX2 := {}
    Self:LoadSX2()

    // Inicializa o array e carrega o SX3
    Self:_SX3 := {}
    Self:LoadSX3()

    // Inicializa o array e carrega o SX6
    Self:_SX6 := {}
    Self:LoadSX6()

Return Nil

/*/{Protheus.doc} LoadSX2
	(Methodo para carregar as informações do SX2)

	@type Class
	@author Vitor Ribeiro
	@since 15/03/2018

	@return Nil, nulo, não tem retorno.
    /*/
Method LoadSX2() Class FisaExtSx_Class

    Local nCount := 0

    Local bCodBlock := {|| }

    Aadd(Self:_SX2,"AI0")    // COMPLEMENTOS DE CLIENTES
    Aadd(Self:_SX2,"AIF")    // HISTÓRICO ALTERAÇÕES CLI/FOR
    Aadd(Self:_SX2,"CCF")    // PROCESSOS REFERENCIADOS
    Aadd(Self:_SX2,"CD3")    // COMPLEMENTO DE GÁS CANALIZADO
    Aadd(Self:_SX2,"CD5")    // COMPLEMENTO DE IMPORTAÇÃO
    Aadd(Self:_SX2,"CDG")    // PROCESSOS REFER. NO DOCUMENTO
    Aadd(Self:_SX2,"CDL")    // COMPLEMENTO DE EXPORTAÇÃO
    Aadd(Self:_SX2,"CDN")    // COD. ISS
    Aadd(Self:_SX2,"CDT")    // CDT - Inf. complementares por NF
    Aadd(Self:_SX2,"CDV")    // INFORMACOES ADICIONAIS DA APUR
    Aadd(Self:_SX2,"CF2")    // DEDUÇÕES PIS COFINS
    Aadd(Self:_SX2,"CF5")    // AJUSTE CREDITO PIS/COFINS
    Aadd(Self:_SX2,"CF6")    // CRÉDITOS EXTEMPORÂNEOS
    Aadd(Self:_SX2,"CF8")    // DEMAIS DOCS. PIS COFINS
    Aadd(Self:_SX2,"CF9")    // ESTOQUE DE ABERTURA
    Aadd(Self:_SX2,"CT1")    // PLANO DE CONTAS 
    Aadd(Self:_SX2,"DT3")    // COMPONENTES DE FRETE
    Aadd(Self:_SX2,"DT5")    // SOLICITAÇÃO DE COLETA
    Aadd(Self:_SX2,"DUL")    // ENDEREÇOS DO SOLICITANTE
    Aadd(Self:_SX2,"F0F")    // COMPLEMENTO DE ESTABELECIMENTO
    Aadd(Self:_SX2,"F0I")    // APURACAO DIFAL/FECP
    Aadd(Self:_SX2,"F2Q")    // COMPLEMENTO FISCAL
    Aadd(Self:_SX2,"SA1")    // CLIENTES
    Aadd(Self:_SX2,"SA2")    // FORNECEDORES
    Aadd(Self:_SX2,"SB1")    // DESCRIÇÃO GENÉRICA DO PRODUTO
    Aadd(Self:_SX2,"SD1")    // ITENS DAS NF DE ENTRADA
    Aadd(Self:_SX2,"SD2")    // ITENS DE VENDA DA NF
    Aadd(Self:_SX2,"SF1")    // CABEÇALHO DAS NF DE ENTRADA
    Aadd(Self:_SX2,"SF4")    // TIPOS DE ENTRADA E SAIDA
    Aadd(Self:_SX2,"SF9")    // MANUTENÇÃO CIAP
    Aadd(Self:_SX2,"SFA")    // ESTORNO MENSAL CIAP
    Aadd(Self:_SX2,"SFT")    // LIVRO FISCAL POR ITEM DE NF
    Aadd(Self:_SX2,"SFU")    // COMPLEMENTO ENERGIA ELÉTRICA
    Aadd(Self:_SX2,"SFX")    // COMPLEMENTO DE COMUN/TELECOM
    Aadd(Self:_SX2,"SL1")    // ORÇAMENTO
    Aadd(Self:_SX2,"SL4")    // CONDIÇÃO NEGOCIADA
    Aadd(Self:_SX2,"SLG")    // ESTAÇÕES
    Aadd(Self:_SX2,"SON")    // CADASTRO NACIONAL DE OBRAS
    Aadd(Self:_SX2,"DHR")    // NF x Natureza de Rendimento   
    Aadd(Self:_SX2,"DHT")    // Fornecedor x Dependentes      

    For nCount := 1 To Len(Self:_SX2)
        // Guarda em um bloco de codigo
        bCodBlock := &('{|| Self:_' + Self:_SX2[nCount] + ' := AliasIndic("' + Self:_SX2[nCount] + '")}')

        // Executa o bloco de codigo
        Eval(bCodBlock)
    Next

Return Nil

/*/{Protheus.doc} LoadSX3
	(Methodo para carregar as informações do SX3)

	@type Class
	@author Vitor Ribeiro
	@since 15/03/2018

	@return Nil, nulo, não tem retorno.
    /*/
Method LoadSX3() Class FisaExtSx_Class

    Local nPosicao := 0
    Local nCount1 := 0
    Local nCount2 := 0

    Local bCodBlock := {|| }

    Aadd(Self:_SX3,{"CCF",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"CCF_IDITEM")
    Aadd(Self:_SX3[nPosicao][2],"CCF_INDAUT")
    Aadd(Self:_SX3[nPosicao][2],"CCF_SUSEXI")
    Aadd(Self:_SX3[nPosicao][2],"CCF_TRIB")
    Aadd(Self:_SX3[nPosicao][2],"CCF_INDSUS")

    Aadd(Self:_SX3,{"CD3",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"CD3_CHV115")
    Aadd(Self:_SX3[nPosicao][2],"CD3_VOL115")

    Aadd(Self:_SX3,{"CD5",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"CD5_ACDRAW")
    Aadd(Self:_SX3[nPosicao][2],"CD5_DTPCOF")
    Aadd(Self:_SX3[nPosicao][2],"CD5_DTPPIS")
    Aadd(Self:_SX3[nPosicao][2],"CD5_LOCAL")

    Aadd(Self:_SX3,{"CDG",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"CDG_ITEM")
    Aadd(Self:_SX3[nPosicao][2],"CDG_ITPROC")

    Aadd(Self:_SX3,{"CDL",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"CDL_CHVEXP")
    Aadd(Self:_SX3[nPosicao][2],"CDL_DOCORI")
    Aadd(Self:_SX3[nPosicao][2],"CDL_EMIEXP")
    Aadd(Self:_SX3[nPosicao][2],"CDL_ESPEXP")
    Aadd(Self:_SX3[nPosicao][2],"CDL_FORNEC")
    Aadd(Self:_SX3[nPosicao][2],"CDL_ITEMNF")
    Aadd(Self:_SX3[nPosicao][2],"CDL_LOJFOR")
    Aadd(Self:_SX3[nPosicao][2],"CDL_NFEXP")
    Aadd(Self:_SX3[nPosicao][2],"CDL_QTDEXP")
    Aadd(Self:_SX3[nPosicao][2],"CDL_SEREXP")
    Aadd(Self:_SX3[nPosicao][2],"CDL_SERORI")

    Aadd(Self:_SX3,{"CDN",{}})
    nPosicao := Len(Self:_SX3)
    Aadd(Self:_SX3[nPosicao][2],"CDN_TPSERV")

    Aadd(Self:_SX3,{"CDT",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"CDT_SITEXT")
    Aadd(Self:_SX3[nPosicao][2],"CDT_DCCOMP")
    Aadd(Self:_SX3[nPosicao][2],"CDT_DTAREC")
    Aadd(Self:_SX3[nPosicao][2],"CDT_INDFRT")

    Aadd(Self:_SX3,{"CF5",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"CF5_TIPAJU")

    Aadd(Self:_SX3,{"CF6",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"CF6_CNPJ")

    Aadd(Self:_SX3,{"CT1",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"CT1_DTEXIS")

    Aadd(Self:_SX3,{"DT3",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"DT3_TIPCMP")

    Aadd(Self:_SX3,{"DT5",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"DT5_CODSOL")

    Aadd(Self:_SX3,{"DUL",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"DUL_CODCLI")

    Aadd(Self:_SX3,{"F0F",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"F0F_INDPAA")

    Aadd(Self:_SX3,{"F2Q",{}})
    nPosicao := Len(Self:_SX3)
    Aadd(Self:_SX3[nPosicao][2],"F2Q_TPSERV")

    Aadd(Self:_SX3,{"SA1",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"A1_REGPB")
    Aadd(Self:_SX3[nPosicao][2],"A1_SIMPNAC")

    Aadd(Self:_SX3,{"SA2",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"A2_CPRB")
    Aadd(Self:_SX3[nPosicao][2],"A2_DESPORT")
    Aadd(Self:_SX3[nPosicao][2],"A2_REGPB")
    Aadd(Self:_SX3[nPosicao][2],"A2_SIMPNAC")

    //Campos do bloco 40
    Aadd(Self:_SX3[nPosicao][2],"A2_ISEIMUN")
    Aadd(Self:_SX3[nPosicao][2],"A2_ESTEX")
    Aadd(Self:_SX3[nPosicao][2],"A2_TELRE")
    Aadd(Self:_SX3[nPosicao][2],"A2_NIFEX")
    Aadd(Self:_SX3[nPosicao][2],"A2_MOTNIF")
    Aadd(Self:_SX3[nPosicao][2],"A2_TRBEX")


    Aadd(Self:_SX3,{"SB1",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"B1_CNATREC")
    Aadd(Self:_SX3[nPosicao][2],"B1_DTFIMNT")
    Aadd(Self:_SX3[nPosicao][2],"B1_GRPNATR")
    Aadd(Self:_SX3[nPosicao][2],"B1_TNATREC")

    Aadd(Self:_SX3,{"SD1",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"D1_ALFCCMP")
    Aadd(Self:_SX3[nPosicao][2],"D1_ALIQCMP")
    Aadd(Self:_SX3[nPosicao][2],"D1_TPREPAS")

    Aadd(Self:_SX3,{"SD2",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"D2_TPREPAS")

    Aadd(Self:_SX3,{"SF1",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"F1_TPCTE")

    Aadd(Self:_SX3,{"SF4",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"F4_CNATREC")
    Aadd(Self:_SX3[nPosicao][2],"F4_DTFIMNT")
    Aadd(Self:_SX3[nPosicao][2],"F4_GRPNATR")
    Aadd(Self:_SX3[nPosicao][2],"F4_TNATREC")
    Aadd(Self:_SX3[nPosicao][2],"F4_VLAGREG")

    Aadd(Self:_SX3,{"SF9",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"F9_CODBAIX")
    Aadd(Self:_SX3[nPosicao][2],"F9_PARCRED")
    Aadd(Self:_SX3[nPosicao][2],"F9_QTDPARC")
    Aadd(Self:_SX3[nPosicao][2],"F9_SLDPARC")
    Aadd(Self:_SX3[nPosicao][2],"F9_TIPO")

    Aadd(Self:_SX3,{"SFA",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"FA_TOTSAI")
    Aadd(Self:_SX3[nPosicao][2],"FA_TOTTRIB")

    Aadd(Self:_SX3,{"SFT",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"FT_CHVNFE")
    Aadd(Self:_SX3[nPosicao][2],"FT_CLIDVMC")
    Aadd(Self:_SX3[nPosicao][2],"FT_CNATREC")
    Aadd(Self:_SX3[nPosicao][2],"FT_CSTCOF")
    Aadd(Self:_SX3[nPosicao][2],"FT_CSTPIS")
    Aadd(Self:_SX3[nPosicao][2],"FT_DESCICM")
    Aadd(Self:_SX3[nPosicao][2],"FT_DESCZFR")
    Aadd(Self:_SX3[nPosicao][2],"FT_DESPICM")
    Aadd(Self:_SX3[nPosicao][2],"FT_DIFAL")
    Aadd(Self:_SX3[nPosicao][2],"FT_DTFIMNT")
    Aadd(Self:_SX3[nPosicao][2],"FT_GRUPONC")
    Aadd(Self:_SX3[nPosicao][2],"FT_INDNTFR")
    Aadd(Self:_SX3[nPosicao][2],"FT_MALQCOF")
    Aadd(Self:_SX3[nPosicao][2],"FT_MVALCOF")
    Aadd(Self:_SX3[nPosicao][2],"FT_PAUTCOF")
    Aadd(Self:_SX3[nPosicao][2],"FT_PAUTIPI")
    Aadd(Self:_SX3[nPosicao][2],"FT_PAUTIPI")
    Aadd(Self:_SX3[nPosicao][2],"FT_PAUTPIS")
    Aadd(Self:_SX3[nPosicao][2],"FT_TAFKEY")
    Aadd(Self:_SX3[nPosicao][2],"FT_TNATREC")
    Aadd(Self:_SX3[nPosicao][2],"FT_VFCPDIF")

    Aadd(Self:_SX3,{"SFU",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"FU_CLASCON")
    Aadd(Self:_SX3[nPosicao][2],"FU_CLASSIF")
    Aadd(Self:_SX3[nPosicao][2],"FU_GRUPT")
    Aadd(Self:_SX3[nPosicao][2],"FU_TIPLIGA")
    Aadd(Self:_SX3[nPosicao][2],"FU_VLFORN")

    Aadd(Self:_SX3,{"SFX",{}})
    nPosicao := Len(Self:_SX3)

    Aadd(Self:_SX3[nPosicao][2],"FX_TPASSIN")

    Aadd(Self:_SX3,{"SLG",{}}) 
    nPosicao := Len(Self:_SX3) 

    Aadd(Self:_SX3[nPosicao][2],"LG_SERSAT")

    For nCount1 := 1 To Len(Self:_SX3) 
        For nCount2 := 1 To Len(Self:_SX3[nCount1][2])
            // Guarda em um bloco de codigo
            bCodBlock := &('{|| Self:_' + Self:_SX3[nCount1][2][nCount2] + ' := Self:_' + Self:_SX3[nCount1][1] + ' .And. ("' + Self:_SX3[nCount1][1] + '")->(FieldPos("' + Self:_SX3[nCount1][2][nCount2] + '")) > 0 }')

            // Executa o bloco de codigo
            Eval(bCodBlock) 
        Next
    Next
    
Return Nil

/*/{Protheus.doc} LoadSX6
	(Methodo para carregar as informações do SX6)

	@type Class
	@author Vitor Ribeiro
	@since 15/03/2018

	@return Nil, nulo, não tem retorno.
    /*/
Method LoadSX6() Class FisaExtSx_Class

    Local nCount := 0

    Local bCodBlock := {|| }

    Aadd(Self:_SX6,{"MV_ESTADO"	,"","C"})
    Aadd(Self:_SX6,{"MV_UFRESPD","GO","C"})
    Aadd(Self:_SX6,{"MV_EASY"	,"N","C"})
    Aadd(Self:_SX6,{"MV_OPSEMF"	,"","C"})
    Aadd(Self:_SX6,{"MV_COMPFRT","{}","C"})
    Aadd(Self:_SX6,{"MV_STUF"	,"","C"})
    Aadd(Self:_SX6,{"MV_STUFS"	,"","C"})
    Aadd(Self:_SX6,{"MV_STNIEUF","","C"})
    Aadd(Self:_SX6,{"MV_RESF3FT",.F.,"L"})
    Aadd(Self:_SX6,{"MV_APUSEP"	,"","C"})
    Aadd(Self:_SX6,{"MV_LJSPED"	,"","C"})
    Aadd(Self:_SX6,{"MV_CODBCCR","201#202#203#204#208#301#302#303#304#307#308","C"})
    Aadd(Self:_SX6,{"MV_CODBCCC","301#302#303#304#308","C"})
    Aadd(Self:_SX6,{"MV_SPCBPRH",.F.,"L"})
    Aadd(Self:_SX6,{"MV_SPCBPSE","","C"})
    Aadd(Self:_SX6,{"MV_DATCIAP","","C"})
    Aadd(Self:_SX6,{"MV_LC102"	,"","C"})
    Aadd(Self:_SX6,{"MV_CIAPDAC","S","C"})
    Aadd(Self:_SX6,{"MV_F9ITEM"	,"F9_ITEMNFE","C"})
    Aadd(Self:_SX6,{"MV_F9PROD"	,"","C"})
    Aadd(Self:_SX6,{"MV_F9ESP"	,"","C"})
    Aadd(Self:_SX6,{"MV_F9CHVNF","","C"})
    Aadd(Self:_SX6,{"MV_F9CC"	,"","C"})
    Aadd(Self:_SX6,{"MV_F9PL"	,"","C"})
    Aadd(Self:_SX6,{"MV_F9FRT"	,"","C"})
    Aadd(Self:_SX6,{"MV_F9ICMST","","C"})
    Aadd(Self:_SX6,{"MV_F9DIF"	,"","C"})
    Aadd(Self:_SX6,{"MV_F9SKPNF",.F.,"L"})
    Aadd(Self:_SX6,{"MV_F9FUNC"	,"F9_FUNCIT","C"})
    Aadd(Self:_SX6,{"MV_SF9PDES","F9_DESCRI","C"})
    Aadd(Self:_SX6,{"MV_F9CTBCC","2","C"})
    Aadd(Self:_SX6,{"MV_F9GENCC","","C"})
    Aadd(Self:_SX6,{"MV_F9GENCT","","C"})
    Aadd(Self:_SX6,{"MV_F9VLLEG","F9_VLLEG","C"})
    Aadd(Self:_SX6,{"MV_RNDCIAP",.T.,"L"})
    Aadd(Self:_SX6,{"MV_DACIAP"	,"S","C"})
    Aadd(Self:_SX6,{"MV_F9CDATF",.F.,"L"})
    Aadd(Self:_SX6,{"MV_APRCOMP",.F.,"L"})
    Aadd(Self:_SX6,{"MV_DAPIC04","","C"})
    Aadd(Self:_SX6,{"MV_EECFAT"	,.F.,"L"})
    Aadd(Self:_SX6,{"MV_EECSPED",.F.,"L"})
    Aadd(Self:_SX6,{"MV_BLKTP00","'ME'","C"})
    Aadd(Self:_SX6,{"MV_BLKTP01","'MP'","C"})
    Aadd(Self:_SX6,{"MV_BLKTP02","'EM'","C"})
    Aadd(Self:_SX6,{"MV_BLKTP03","'PP'","C"})
    Aadd(Self:_SX6,{"MV_BLKTP04","'PA'","C"})
    Aadd(Self:_SX6,{"MV_BLKTP06","'PI'","C"})
    Aadd(Self:_SX6,{"MV_BLKTP10","'OI'","C"})
    Aadd(Self:_SX6,{"MV_PISCOFP",.F.,"L"})
    Aadd(Self:_SX6,{"MV_SPDIFC"	,0,"N"})
    Aadd(Self:_SX6,{"MV_PRFSPED","","C"})
    Aadd(Self:_SX6,{"MV_HISTTAB",.F.,"L"})
    Aadd(Self:_SX6,{"MV_BLKTP00","'ME'","C"})
    Aadd(Self:_SX6,{"MV_BLKTP01","'MP'","C"})
    Aadd(Self:_SX6,{"MV_BLKTP02","'EM'","C"})
    Aadd(Self:_SX6,{"MV_BLKTP03","'PP'","C"})
    Aadd(Self:_SX6,{"MV_BLKTP04","'PA'","C"})
    Aadd(Self:_SX6,{"MV_BLKTP06","'PI'","C"})
    Aadd(Self:_SX6,{"MV_BLKTP10","'OI'","C"})
    Aadd(Self:_SX6,{"MV_TAFGST2",.T.,"L"}) 
    Aadd(Self:_SX6,{"MV_TAFTDB"	,"","C"}) 
    Aadd(Self:_SX6,{"MV_TAFTALI","","C"})
    Aadd(Self:_SX6,{"MV_TAFPORT",7890,"N"})
    Aadd(Self:_SX6,{"MV_DIMPTAF","","C"})
    Aadd(Self:_SX6,{"MV_SPEDNAT",.F.,"L"})
    Aadd(Self:_SX6,{"MV_EXTQTHR",0,"N"})
    Aadd(Self:_SX6,{"MV_SUBTRIB","","C"})
    Aadd(Self:_SX6,{"MV_DTINCB1","","C"})
    Aadd(Self:_SX6,{"MV_ICMPAD"	,18,"N"})
    Aadd(Self:_SX6,{"MV_RLCSPD"	,.T.,"L"})
    Aadd(Self:_SX6,{"MV_RE"		,"","C"})
    Aadd(Self:_SX6,{"MV_RECBNAT","{}","C"})
    Aadd(Self:_SX6,{"MV_ESTTEL" ,.F.,"L"})
    Aadd(Self:_SX6,{"MV_TPAPSB1","","C"})
    Aadd(Self:_SX6,{"MV_EXTATHR","","C"})
    Aadd(Self:_SX6,{"MV_UFIPM"  ,"","C"})
    Aadd(Self:_SX6,{"MV_TMSUFPG",.T.,"L"}) //T - Pagador de documentos de transporte F - Destinatário da Mercadoria

    For nCount := 1 To Len(Self:_SX6)
        // Guarda em um bloco de codigo
        bCodBlock := &('{|| Self:_' + Self:_SX6[nCount][1] + ' := GetNewPar("' + Self:_SX6[nCount][1] + '",' + fConvert(Self:_SX6[nCount][2],Self:_SX6[nCount][3]) + ') }')

        // Executa o bloco de codigo
        Eval(bCodBlock) 
    Next

Return Nil

/*/{Protheus.doc} fConvert
    (Função para converter um valor para string)

    @type Static Function
    @author Vitor Ribeiro
    @since 15/03/2018

    @param x_Valor, undefined, valor para converção
    @param c_Tipo, caracter, tipo do valor

    @return cRetorno, caracter, retorna o valor como string
    /*/ 
Static Function fConvert(x_Valor,c_Tipo)

    Local cRetorno := ""

    Default x_Valor := Nil

    Default c_Tipo := ""

    If c_Tipo == "L"
        cRetorno := IIf(x_Valor,'.T.','.F.')
    ElseIf c_Tipo == "N"
        cRetorno := AllTrim(Str(x_Valor))
    ElseIf c_Tipo == "D"
        If "/" $ x_Valor
            cRetorno := 'CToD(' + x_Valor + ')'
        Else
            cRetorno := 'SToD(' + x_Valor + ')'
        EndIf
    Else
        cRetorno := '"' + AllTrim(x_Valor) + '"'
    EndIf

Return cRetorno