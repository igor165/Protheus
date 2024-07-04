#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXFIS.CH"
#INCLUDE "MATXDEF.CH"

STATIC aCposSF3
STATIC __aPrepared := {}
STATIC oHItemRef
STATIC oHCabRef
STATIC oHResRef
STATIC oHTGITRef
STATIC oHTGNFRef
STATIC oHLFIS
STATIC oTGLFRef
Static aWriteSFT
STATIC lBuild    := GetBuild() >= "7.00.131227A"
STATIC lBdjaSon  := GetBuild() >="7.00.170117A"
STATIC lIntTMS   := IntTMS()
STATIC oHMCad 	 := Nil
 
/************************************************ FUNCOES DE CACHE DE DADOS ****************************************************
*																																				 *
*                     As 4 funcoes abaixo (Cache) NAO DEVERAO SER CHAMADAS por outros programas alem do MATXFIS.               *                         *
* 																				 																 *
********************************************************************************************************************************/

/*
³Fun‡…o    ³ GPEMxFIS  ³ Autor ³Demetrio F.de Los Rios³ Data ³20/09/2012³
³Descri‡…o ³ Retorna os Pontos de Entrada Existes                       ³
³          ³ Esta funcao foi criada apenas para NAO chamar a funcao     ³
³          ³ ExistBlock() a todo momento. Chamando ao entrar no MATXFIS ³
³          ³ Os PEs sao testados apartir do retorno da funcao que       ³
³          ³ alimenta a STATIC aPE                                      ³
*/
Function GPEMxFis()

Local aValidPE  := {}
Local nX     	:= 0
Local aPE  := {"M520SF3",;		 //	 01
				"M520SFT",;		 //	 02
				"MAAFRMM",;		 //	 03
				"MaCalcCOF",;	 //	 04
				"MaCalcCSL",;	 //	 05
				"MACALCICMS",;	 //	 06
				"MaCalcPIS",;	 //	 07
				"MaCofDif",;	 //	 08
				"MaCOFVeic",;	 //	 09
				"MaCstPiCo",;	 //	 10
				"MAFISBIR",;	 //	 11
				"MAFISOBS",;	 //	 12
				"MAFISRASTRO",;	 //	 13
				"MAFISRUR",;	 //	 14
				"MaICMVeic",;	 //	 15
				"MaPISDif",;	 //	 16
				"MaPISVeic",;	 //	 17
				"MARATEIO",;	 //	 18
				"MAVLDIMP",;	 //	 19
				"MFISIMP",;		 //	 20
				"MTA920L",;		 //	 21
				"MXTOTIT",;		 //	 22
				"PAUTICMS",;	 //	 23
				"TM200ISS",;	 //	 24
				"VISUIMP",;		 //	 25
				"VLCODRET",;	 //	 26
				"XFCD2SFT",;	 //	 27
				"XFISLF",;		 //	 28
				"MACALIRRF",;	 //	 29
				"MFISEXCE",;	 //	 30
				"MAZVSTDF",;	 // 31
				"MAEXCEFISC",;	 // 32
				"MACSOLICMS",;	 // 33
				"M410SOLI",;	 // 34
				"MAIPIVEIC",;  	 // 35
				"MAVLDCQry",;    // 36
				"MaCalcIPI",;    //  37
				"MaCPISAPU",;    //  38
				"MaCCOFAPU"}     //  39

/*  IMPORTANTE: TODA VEZ QUE CRIADO NOVO PONTO DE ENTRADA MATXFIS, DEVERA SER CRIADA A REFERENCIA NA MATXDEF
  E ADD DO PONTO DE ENTRADA NO ARRAY aParam DESTA FUNCAO OBRIGATORIAMENTE NA MESMA POSICAO(NUMERO) DO XDEF.CH */
For nX :=1 To Len(aPE)
	aAdd(aValidPE,ExistBlock(aPE[nX]) )
Next nX

Return aValidPE

/*
±±³Fun‡…o    ³ GParMxFIs ³ Autor ³Demetrio F.de Los Rios³ Data ³20/09/2012³±±
±±³Descri‡…o ³ Retorna os Parametros SX6 Utilizados na MATXFIS            ³±±
±±³          ³ Esta funcao foi criada apenas para NAO chamar as funcoes   ³±±
±±³          ³ GetNewPar() e SuperGetMV a todo momento.                   ³±±
±±³          ³ A Lista dos parametros utilizados sera armazenada na STATIC³±±
±±³          ³ aSX6 com seu conteudo e conteudo DEFAULT qdo nao existir³±±
*/
Function GParMxFis(cSX6FilAnt,cSX6EmpAnt)

Local nX		:= 0
Local lCritArr	:= (cPaisLoc == "BRA")
Local aAllSX6	:= {}
Local aParam 	:= {	{"MV_1DUPNAT",""},;	//   01
						{"MV_2DUPNAT",""},; 	//	 02
						{"MV_ACMIRPF","1"	},;  	//	 03
						{"MV_ACMIRPJ","1"	},;  	// 	 04
						{"MV_ADIFECP",""},; 	//   05
						{"MV_AGENTE","   "},; 	//	 06
						{"MV_ALFECMG",""},; 	//	 07
						{"MV_ALINSB1",""},; 	//   08
						{"MV_ALIQFRE","AC07AL07AM07AP07BA07CE07DF07ES07GO07MA07MG12MS07MT07PA07PB07PE07PI07PR12RJ12RN07RO07RR07RS12SC12SE07SP12TO07"} ,; 	//   09
						{"MV_ALIQIRF",0},; 	//   10
						{"MV_ALIQISS",0},; 	//   11
						{"MV_ALQDFB1",""},; 	//   12
						{"MV_ALQIPM",0},; 	//   13
						{"MV_ALRN944",.F.},; 	//   14
						{"MV_ARQPROD","SB1"},; 	//   15
						{"MV_ARQPROP",.F.},; 	//   16
						{"MV_ASRN944",0},; 	//   17
						{"MV_AUTOISS",'{"","","",""}'},;	//   18
						{"MV_B1CALTR",""},; 	//   19
						{"MV_B1CPSST",""},; 	//   20
						{"MV_BASERET",""},; 	//   21
						{"MV_BICMCMP",.T.},; 	//   22
						{"MV_BX10925","2"},; 	//   23
						{"MV_CALCVEI",.F.},; 	//   24
						{"MV_CODREG",""},; 	//   25
						{"MV_COFBRU","2"},; 	//   26
						{"MV_COFPAUT",.T.},; 	//   27
						{"MV_CONTSOC",""},; 	//   28
						{"MV_CONVCFO","1"},; 	//   29
						{"MV_CPCATRI",.F.},; 	//   30
						{"MV_CRDBCOF","N"},;	//   31
						{"MV_CRDBPIS","N"},;	//   32
						{"MV_CROUTSP",""},;	//   33
						{"MV_CRPRERJ",.F.},;	//   34
						{"MV_CSLLBRU","2"},;	//   35
						{"MV_CTRAUTO",.F.},;	//   36
						{"MV_CTRLFOL",.F.},;	//   37
						{"MV_DBRDIF",.T.},;	//   38
						{"MV_DBSTCFR","1"},;	//   39
						{"MV_DBSTCOF","1"},;	//   40
						{"MV_DBSTPIS","1"},;	//   41
						{"MV_DBSTPSR","1"},;	//   42
						{"MV_DECALIQ",.F.},;	//   43
						{"MV_DEDBCOF",""},;	//   44
						{"MV_DEDBPIS",""},;	//   45
						{"MV_DEISSBS",.F.},;	//   46
						{"MV_DESCISS",.F.},;	//   47
						{"MV_DESCSAI",""},;	//   48
						{"MV_DESCZF",.T.},;	//   49
						{"MV_DESPICM ",.T.},;	//   50
						{"MV_DESPSD1","N"},;	//   51
						{"MV_DESZFPC",.F.},;	//   52
						{"MV_DEVRET",.F.},;	//   53
						{"MV_DEVTOT",.T.},;	//   54
						{"MV_DPAGREG",.F.},;	//   55
						{"MV_DSZFSOL",.F.},;	//   56
						{"MV_EASY",""},;	//   57
						{"MV_ESTADO",""},;	//   58
						{"MV_ESTICM",""},;	//   59
						{"MV_FECPMT",""},;	//   60
						{"MV_FRETAUT",.T.},;	//   61
						{"MV_FRETEST",""},;	//   62
						{"MV_FRTBASE",.F.},;	//   63
						{"MV_GERIMPV",""},;	//   64
						{"MV_ICMPAD",0},;	//   65
						{"MV_ICMPAUT",.T.},;	//   66
						{"MV_ICMPFAT",""},;	//   67
						{"MV_ICPAUTA","1"},;	//   68
						{"MV_IMPCSS","S"},;	//   69
						{"MV_INDUPF",""},;	//   70
						{"MV_INITES",.F.},;	//   71
						{"MV_INSIRF","2"},;	//   72
						{"MV_INSSDES",""},;	//   73
						{"MV_IPIBRUT",""},;	//   74
						{"MV_IPINOBS",""},;	//   75
						{"MV_IPIPFAT ",""},;	//   76
						{"MV_IPIZFM",.T.},;	//   77
						{"MV_IRMP232","2"},;	//   78
						{"MV_IRSEMNT",.F.},;	//   79
						{"MV_ISSPRG","N"},;	//   80
						{"MV_LFAGREG",.F.},;	//   81
						{"MV_LIMINSS",0},;	//   82
						{"MV_LJLVFIS",1},;	//   83
						{"MV_MINDETR",0},;	//   84
						{"MV_MKPICPT","1"},;	//   85
						{"MV_NORTE",""},;	//   86
						{"MV_PCFATPC",.F.},;	//   87
						{"MV_PERCATM",0},;	//   88
						{"MV_PEREINT",0},;	//   89
						{"MV_PERFECP",0},;	//   90
						{"MV_PISBRU","2"},;	//   91
						{"MV_PISPAUT",.T.},;	//   92
						{"MV_PRCDEC",.F.},;	//   93
						{"MV_PRODLEI",""},;	//   94
						{"MV_PUPCCST",""},;	//   95
						{"MV_RASTRO","N"},;	//   96
						{"MV_RATDESP",""},;	//   97
						{"MV_RCSTIPI",""},;	//   98
						{"MV_REBICM",.F.},;	//   99
						{"MV_REGESIM",.F.},;	//  100
						{"MV_RNDANG",.F.},;	//  101
						{"MV_RNDCF2",.F.},;	//  102
						{"MV_RNDCF3",.F.},;	//  103
						{"MV_RNDCOF",.F.},;	//  104
						{"MV_RNDCSL",.F.},;	//  105
						{"MV_RNDDES",lCritArr},;	//  106
						{"MV_RNDFUN",.F.},;	//  107
						{"MV_RNDICM",.F.},;	//  108
						{"MV_RNDINS",.F.},;	//  109
						{"MV_RNDIPI",.F.},;	//  110
						{"MV_RNDIRF",.F.},;	//  111
						{"MV_RNDISS",.F.},;	//  112
						{"MV_RNDPIS",.F.},;	//  113
						{"MV_RNDPREC",10},;	//  114
						{"MV_RNDPS2",lCritArr},;	//  115
						{"MV_RNDPS3",.F.},;	//  116
						{"MV_RNDRNE",.T.},;	//  117
						{"MV_RNDSOBR",.T.},;	//  118
						{"MV_RSATIVO",.F.},;	//  119
						{"MV_SIMPLSC",.T.},;	//  120
						{"MV_SM0CONT","1"},;	//  121
						{"MV_SOLBRUT",.F.},;	//  122
						{"MV_SOMAICM",.F.},;	//  123
						{"MV_SOMAIPI",.F.},;	//  124
						{"MV_STFRETE",.F.},;	//  125
						{"MV_STPTPER",""},;	//  126
						{"MV_STREDU",.F.},;	//  127
						{"MV_TESIB",.F.},;	//  128
						{"MV_TESVEND",""},;	//  129
						{"MV_TIPOB","RS/SP/"},;	//  130
						{"MV_TMSUFPG",.F.},;	//  131
						{"MV_TMSVDEP",0},;	//  132
						{"MV_TPABISS","1"},;	//  133
						{"MV_TPALCOF","2"},;	//  134
						{"MV_TPALCSL","2"},;	//  135
						{"MV_TPALPIS","2"},;	//  136
						{"MV_TPNFISS",""},;	//  137
						{"MV_TPSOLCF",""},;	//  138
						{"MV_TXAFRMM",0},;	//  139
						{"MV_TXCOFIN",0},;	//  140
						{"MV_TXCSLL",0},;  	//  141
						{"MV_TXPIS",0},;	   //  142
						{"MV_UFERMS",""},;	//  143
						{"MV_UFPST21",""},;	//  144
						{"MV_USACFPS",.F.},;	//  145
						{"MV_VALDESP",.F.},;	//  146
						{"MV_VALICM",.F.},;	//  147
						{"MV_VISDIRF","1"},;	//  148
						{"MV_XFCOMP",.T.},;	//  149
						{"MV_B1CATRI",""},;	//  150
						{"MV_AERN944",0},;  	//  151
						{"MV_B1CCFST",""},;	// 	152
						{"MV_DESCDVI",.T.	},;	// 	153
						{"MV_ALITPDP",0},;	//  154
						{"MV_B1PTST",""},;	//  155
						{"MV_PRDDIAT",""} ,;	//  156
						{"MV_ISSXMUN",.F.},;	//  157
						{"MV_APURPIS",.F.},;	// 	158
						{"MV_APURCOF",.F.},;	// 	159
						{"MV_UFPAUTA",""},; 	// 	160
						{"MV_ALALIME",0},;	//	161
						{"MV_DIFALIQ",0},;   	// 	162
						{"MV_VRETISS",0},;   	// 	163
						{"MV_VEICICM",.F.},;  	// 	164
						{"MV_UFIRCE",'{"",""}'},;  	// 	165
						{"MV_ALTCFIS","00"},;	// 	166
						{"MV_DC5602",""},;	// 	167
						{"MV_FISAUCF",.F.},;	//	168
						{"MV_DSPREIN",.F.	},; 	//  169
						{"MV_PISCOFP",.F.	},; 	//  170
						{"MV_FISXMVA",.F.},;	//  171
						{"MV_C13906",""},;	//  172
						{"MV_139GNUF",""},;	//  173
						{"MV_RNDSEST",.F.	},;	//  174
						{"MV_RPCBIZF",.F.},;	//  175
						{"MV_PBIPITR",0},;	//  176
						{"MV_PAUTFOB",""},;	//  177
						{"MV_VL10925",5000},;	//  178
						{"MV_REMVFUT",""},;	//  179
						{"MV_REDIMPO",.F.},;	 //	180
						{"MV_SNEFCFO",.F.},; // 181
						{"MV_RPCBIUF",""},;	//  182
						{"MV_IPI2UNI",.F.},;	//  183
						{"MV_AGRPERC",'{0,0}'},;	//184
						{"MV_MVAFRP",""},;	//  185
						{"MV_MVAFRE",""},;	//  186
						{"MV_MVAFRU",""},;	//  187
						{"MV_MVAFRC",""},;	//  188
						{"MV_CSTORI",.T.},;	//  189
						{"MV_UFSTZF",""},;	//	190
						{"MV_OPTSIMP",""},;	//	191
						{"MV_ISSZERO",.F.},; //	192
						{"MV_CPRBATV",""},;	//  193
						{"MV_CPRBNF",.F.},; //  194
						{"MV_PPDIFAL",""},;	//	195
						{"MV_BASDUPL",.F.},;//	196
						{"MV_ANTVISS","2"},; // 197
						{"MV_ZRSTNEG",.T.},;  // 198
						{"MV_BASDENT",""},; // 199
						{"MV_LJINTUF",0},;	//200
						{"MV_RATAGRE",.F.},;//201
						{"MV_INTTAF","N"},; // 202
						{"MV_UFBDST",""},; //203
						{"MV_M116FOR",.F.},; //204
						{"MV_CDIFBEN",.F.},;//205
						{"MV_BASDEGO",""},;//206
						{"MV_ANTICMS",.F.},;//207
						{"MV_EISSXM",""},; //208
						{"MV_DBSTCLR","1"},; //209
						{"MV_TXPISST",0},;//210
						{"MV_TXCOFST",0},;//211
						{"MV_B1PISST",""},;//212
						{"MV_B1COFST",""},;//213
						{"MV_CFOTES",""},;//214
						{"MV_CMPALIQ",.F.},;//215
						{"MV_CRPRESC",""},;//216
						{"MV_UFBSTGO",""},;//217
						{"MV_UFSTALQ",""},;//218
						{"MV_BASDSER",""},;//219
						{"MV_BASDSSE",""},;//220
						{"MV_EIC0064",.F.},;//221
						{"MV_BASDANT",.T.},;//222
						{"MV_BASDPUF",""},;//223
						{"MV_IBGE886",.F.},;//224
						{"MV_BDSIMP",""},;	//225
						{"MV_DEVMERC",""},;	//226
						{"MV_ALCPESP",""},;//227
						{"MV_TPAPSB1",""},;//228
						{"MV_DEDBCPR","N"},;//229
						{"MV_UFBASDP","" },;//230
						{"MV_GIAEFD",.F. },;//231
						{"MV_BSICMCM",.F. },;//232
						{"MV_ULTAQUI", ""},;//233
						{"MV_UFALCMP", ""},;//234
						{"MV_ORILOTE",.F.},;//235
						{"MV_REDPT",.T.},;//236
						{"MV_DESONRJ","RJ"},;//237
						{"MV_MTCLF3K","0"},;//238
						{"MV_STMEDRD",""},; //239
						{"MV_FUNRURA",""},; //240
						{"MV_ISPPUBL",""},; //241
						{"MV_DICMISE","N"},; //242
						{"MV_BDSTREV",.F.},; //243
						{"MV_ACTLIVF",.F.},; //244
						{"MV_CDIFDEV",1},;  //245
						{"MV_RETEMPU",.F.},; //246
						{"MV_ICMDSDT",""},; //247
						{"MV_IMPZFRC",""}} //248
					
//³IMPORTANTE: TODA VEZ QUE CRIADO NOVO PARAMETRO PARA MATXFIS, DEVERA SER CRIADA A REFERENCIA NA MATXDEF³
//³  E ADD O PARAMETRO NO ARRAY aParam DESTA FUNCAO OBRIGATORIAMENTE NA MESMA POSICAO(NUMERO) DO XDEF.CH ³.
For nX:=1 to Len(aParam)
	aAdd(aAllSX6 , GetNewPar((aParam[nX,1]),aParam[nX,2])  )
Next nX

//³ Ao utilizar o Protheus com varias Filiais e possivel que em alguns processos como o de inclusao de Notas Fiscais o usuario altere  ³
//³ a filial atraves da Dialog de seleçao de filiais, com isso se faz necessario que os parametros SX6 sejam novamente carregados para ³
//³ a filial corrente refazendo o cache realizado na variavel aSX6, esta nova carga e controlada pela variavel cSX6FilAnt           ³
cSX6FilAnt := cFilAnt
cSX6EmpAnt := cEmpAnt

Return aAllSX6

/*

±±³Fun‡…o    ³ GAIMxFis  ³ Autor ³Demetrio F.de Los Rios³ Data ³20/09/2012³±±
±±³Descri‡…o ³ Retorna os ALIAS existentes no dicionario SX3              ³±±
±±³          ³ Esta funcao foi criada apenas para NAO chamar a funcao     ³±±
±±³          ³ ALIASINDIC() a todo momento. Chamando ao entrar no MATXFIS ³±±
±±³          ³ Os Alias sao verificados atraves do retorno da funcao que  ³±±
±±³          ³ alimenta a STATIC aDic                                ³±±
*/
Function GAIMxFis()

Local nX := 0
Local xRet  := {}
Local aAI_  := {	"CC6",;      // 01
					"CC7",;      // 02
					"CD2",;      // 03
					"CD3",;      // 04
					"CD4",;      // 05
					"CD5",;      // 06
					"CD6",;      // 07
					"CD7",;      // 08
					"CD8",;      // 09
					"CD9",;      // 10
					"CDA",;      // 11
					"CDC",;      // 12
					"CDD",;      // 13
					"CDE",;      // 14
					"CDF",;      // 15
					"CDG",;      // 16
					"CDO",;      // 17
					"CE0",;      // 18
					"MDL",;      // 19
					"SFT",;      // 20
					"SFU",;      // 21
					"SFX",;      // 22
					"CE1",;		 // 23
					"CC2",;		 // 24
					"CFC",;		 // 25
					"SS9",;		 // 26
					"CG1",;		 // 27
					"F0R",;      // 28
					"F13",;      // 29
					"F3K",;      // 30
					"CDV",;      // 31
					"CLI",;		 // 32
					"F20",;      // 33
					"F21",;      // 34
					"F22",;      // 35
					"F23",;      // 36
					"F24",;      // 37
					"F25",;      // 38
					"F26",;      // 39
					"F27",;      // 40
					"F28",;      // 41
					"F29",;      // 42
					"F2A",;      // 43
					"F2B",;      // 44
					"F2C",;		 // 45
					"F2D",;      // 46
					"CIN",;      // 47
					"CJ2",;      // 48
					"CJ3",;      // 49
					"CJA",;      // 50
					"CJL",;		 // 51
					"CJM"}       // 52


/*  IMPORTANTE: TODA VEZ QUE CHAMAR O ALIASINDIC() DE UMA NOVA TABELA, DEVERA SER CRIADA A REFERENCIA NA
  MATXDEF E ADD O ALIAS NO ARRAY aAI_ DESTA FUNCAO OBRIGATORIAMENTE NA MESMA POSICAO(NUMERO) DO XDEF.CH*/

For nX:=1 to Len(aAI_)
	aAdd(xRet, AliasIndic(aAI_[nX]) )
Next nX

Return xRet

/*/{Protheus.doc} GFFMxFis
	Retorna FindFunction das funções no repositorio.

	Esta funcao foi criada apenas para NAO chamar a funcao
	FindFunction() a todo momento. Chamando ao entrar no MATXFIS
	as funções sao verificados atraves do retorno da funcao que
	alimenta a STATIC aFunc

	@author Rafael.soliveira
	@since 21/01/2020
	@version 12.1.25
	@return xRet, array, Retorna array contendo resultado de cada função consultada.
	/*/

Function GFFMxFis()
	Local nX := 0
	Local xRet  := {}
	LOCAL aFF_  := {"FISXFABOV",;	//01
					"FISXFACS",;	//02
					"FISXFETHAB",;	//03
					"FISXFAMAD",;	//04
					"FISXIMA",;		//05
					"FISXFASE",;	//06
					"FISXFUNDESA",;	//07
					"FISXFNDSUL",;	//08
					"FISXTPDP",;	//09
					"FISXFUMIPQ",;	//10
					"FISXAFRMM",;	//11
					"FISXSEST",;	//12
					"FISXSENAR",;	//13
					"FISXCIDE",;	//14
					"FISXPROTEG",;	//15
					"FISXFUNRUR",;	//16
					"FISXBCFUN",;	//17
					"FISXINSS",;	//18
					"FISXIR",;		//19
					"FISIRFPF",;	//20					
					"FISXCSLL",;	//21
					"FISXCPRB",;	//22
					"FISXFEEF",;	//23
					"FISINSSPAT",;	//24
					"FISRECIR",;	//25
					"FISBASSOL",;	//26
					"FISALQSOL",;	//27
					"FISVALSOL",;	//28
					"FISVALDIFAL",;	//29
					"FISALQDIFAL",;	//30
					"FISCHKPDIF",;	//31
					"FISFECP",;	    //32
					"xFisRtComp",;	//33
					"FISXAICMS",;	//34
					"FISXBICMS",;	//35
					"FISXVICMS",;	//36
					"FISXIPI",;		//37
					"FISXULTENT",;	//38
					"FISXMARGEM",;	//39
					"FISXRTCOMP",;	//40
					"FISXNAMEFCP",;	//41
					"FISXII",;		//42	
					"FISXPIS",;		//43
					"FISXCOFINS",;	//44
					"FISXISS",;		//45
					"FISXSEEKCLI",;	//46
					"FISXISSBI",;	//47
					"FISXCRDPRE",;	//48
					"FISXDESCZF",;	//49
					"FISXDBST",;    //50		
					"FISXDC5602",;  //51							
					"FISXSITTRI",;  //52												
					"A103GRatIr",;	//53
					"XFISEND",;		//54
					"XFISSCAN",;	//55
					"XFISATUSF3",;	//56
					"XFISTES",;		//57
					"XFISCDA",;		//58
					"XFISRELIMP",;	//59
					"XFISNEWTES",;	//60
					"XFISINICPO",;	//61
					"XLFTOLIVRO",;	//62
					"XFISLF",; 		//63
					"XFSEXCECAO",;	//64
					"XMAFISAJIT",;	//65
					"XFISGETRF",;	//66
					"XFISSBCPO",;	//67
					"XFISAVTES",;	//68
					"XFISREFLD",;	//69
					"XFISLDIMP",;	//70
					"XFISIMPLD",;	//71
					"XFISINIREF",;	//72
					"XFISPOSCFC",;	//73
					"XACTLIVFIS",;  //74
					"XFISTPFORM",;	//75
					"RETINFCDY",;	//76
					"FISGRVCJ3",;	//77
					"TAFVLDAMB",;	//78 
					"EXTTAFFEXC",;	//79
					"TMSMETRICA",;	//80
					"FWLSPUTASYNCINFO",; //81
					"GETCOMPULTAQ",;	//82
					"FISDELCJM",;       //83
					"GETULTAQUI"}	//84

	/*  IMPORTANTE: TODA VEZ QUE CHAMAR O FindFunction() DE UMA NOVA FUNÇÂO, DEVERA SER CRIADA A REFERENCIA NA
	MATXDEF E ADD A FUNÇÂO ARRAY aFF_ DESTA FUNCAO OBRIGATORIAMENTE NA MESMA POSICAO(NUMERO) DO XDEF.CH*/

	For nX:=1 to Len(aFF_)
		aAdd(xRet, FindFunction(aFF_[nX]) )
	Next nX

Return xRet

/*
±±³Fun‡…o    ³ GFPMxFis  ³ Autor ³Demetrio F.de Los Rios³ Data ³20/09/2012³±±
±±³Descri‡…o ³ Retorna se os campos existem no dicionario SX3             ³±±
±±³          ³ Esta funcao foi criada apenas para NAO chamar a funcao     ³±±
±±³          ³ FIELDPOS() a todo momento. Chamando ao entrar no MATXFIS   ³±±
±±³          ³ Os Campos sao verificados atraves do retorno da funcao que ³±±
±±³          ³ alimenta a STATIC aPos                                ³±±
*/
Function GFPMxFis(aSX6)

Local nX     := 0
Local nPos   := 0
Local aAlias := {}
Local aRet 	 := {}
Local lV12Only := .F.
Local cRelSX3 := ""
Local cRPORel := GetRPORelease()
Local cVersao := GetVersao(.F.)
Local aFPCpo := {{"SA1","A1_CALCIRF"},;   // 	 01
					{"SA1","A1_CONTRIB"},;   //      02
					{"SA1","A1_PERCATM"},;   //      03
					{"SA1","A1_PERFECP"},;   //      04
					{"SA1","A1_REGESIM"},;   //      05
					{"SA1","A1_SIMPLES"},;   //      06
					{"SA1","A1_TPESSOA"},;   //      07
					{"SA2","A2_CALCIRF"},;   //      08
					{"SA2","A2_INCLTMG"},;   //      09
					{"SA2","A2_IRPROG"},;    //      10
					{"SA2","A2_NUMDEP"},;    //      11
					{"SA2","A2_RECSEST"},;   //      12
					{"SA2","A2_REGESIM"},;   //      13
					{"SA2","A2_SIMPNAC"},;   //      14
					{"SA2","A2_TPESSOA"},;   //      15
					{"SB1","B1_ALFECOP"},;   //      16
					{"SB1","B1_ALFECST"},;   //      17
					{"SB1","B1_ALFUMAC"},;   //      18
					{"SB1","B1_CHASSI"},;    //      19
					{"SB1","B1_CNATREC"},;   //      20
					{"SB1","B1_CRDPRES"},;   //      21
					{"SB1","B1_DTFIMNT"},;   //      22
					{"SB1","B1_FECOP"},;     //      23
					{"SB1","B1_FECPBA"},;    //      24
					{"SB1","B1_GRPNATR"},;   //      25
					{"SB1","B1_IMPORT"},;    //      26
					{"SB1","B1_PRN944I"},;   //      27
					{"SB1","B1_REGESIM"},;   //      28
					{"SB1","B1_REGRISS"},;   //      29
					{"SB1","B1_TNATREC"},;   //      30
					{"SB1","B1_VMINDET"},;   //      31
					{"SC6","C6_CNATREC"},;   //      32
					{"SC6","C6_DTFIMNT"},;   //      33
					{"SC6","C6_GRPNATR"},;   //      34
					{"SC6","C6_TNATREC"},;   //      35
					{"CC7","CC7_CLANAP"},;   //      36
					{"CC7","CC7_IFCOMP"},;   //      37
					{"CC7","CC7_TPREG"},;    //      38
					{"CD2","CD2_DESCZF"},;   //      39
					{"CD2","CD2_FORMU"},;    //      40
					{"CDA","CDA_IFCOMP"},;   //      41
					{"CDA","CDA_TPLANC"},;   //      42
					{"CDO","CDO_CODREF"},;   //      43
					{"CE0","CE0_NFALIQ"},;   //      44
					{"CE0","CE0_NFALVA"},;   //      45
					{"CE0","CE0_NFBASE"},;   //      46
					{"CE0","CE0_NFVALO"},;   //      47
					{"SD1","D1_ALIQSOL"},;   //      48
					{"SD1","D1_BASEFUN"},;   //      49
					{"SD1","D1_ICMSDIF"},;   //      50
					{"SD1","D1_ITEM"},;      //      51
					{"SD1","D1_MARGEM"},;    //      52
					{"SD1","D1_SLDDEP"},;    //      53
					{"SD2","D2_ALIQSOL"},;   //      54
					{"SD2","D2_BASEFUN"},;   //      55
					{"SD2","D2_ICMSDIF"},;   //      56
					{"SD2","D2_MARGEM"},;    //      57
					{"DUY","DUY_ALQISS"},;   //      58
					{"SE2","E2_BASEIRF"},;   //      59
					{"SE2","E2_FORNISS"},;   //      60
					{"SE2","E2_LOJAISS"},;   //      61
					{"SE2","E2_PRETCOF"},;   //      62
					{"SE2","E2_PRETCSL"},;   //      63
					{"SE2","E2_PRETIRF"},;   //      64
					{"SE2","E2_PRETPIS"},;   //      65
					{"SE2","E2_SEQBX"},;     //      66
					{"SE2","E2_VENCISS"},;   //      67
					{"SE2","E2_VRETCOF"},;   //      68
					{"SE2","E2_VRETCSL"},;   //      69
					{"SE2","E2_VRETIRF"},;   //      70
					{"SE2","E2_VRETPIS"},;   //      71
					{"SE5","E5_BASEIRF"},;   //      72
					{"SE5","E5_PRETCOF"},;   //      73
					{"SE5","E5_PRETCSL"},;   //      74
					{"SE5","E5_PRETIRF"},;   //      75
					{"SE5","E5_PRETPIS"},;   //      76
					{"SE5","E5_VRETCOF"},;   //      77
					{"SE5","E5_VRETCSL"},;   //      78
					{"SE5","E5_VRETIRF"},;   //      79
					{"SE5","E5_VRETPIS"},;   //      80
					{"SED","ED_BASESES"},;   //      81
					{"SED","ED_PERCSES"},;   //      82
					{"SF1","F1_CAE"},;       //      83
					{"SF1","F1_CHVNFE"},;    //      84
					{"SF1","F1_CODNFE"},;    //      85
					{"SF1","F1_CREDNFE"},;   //      86
					{"SF1","F1_DESNTRB"},;   //      87
					{"SF1","F1_EMINFE"},;    //      88
					{"SF1","F1_HORNFE"},;    //      89
					{"SF1","F1_NFELETR"},;   //      90
					{"SF1","F1_NUMRPS"},;    //      91
					{"SF1","F1_TARA"},;   	 //      92
					{"SF1","F1_TPVENT"},;    //      93
					{"SF1","F1_VCTOCAE"},;   //      94
					{"SF2","F2_CAE"},;       //      95
					{"SF2","F2_CHVNFE"},;    //      96
					{"SF2","F2_CODNFE"},;    //      97
					{"SF2","F2_CREDNFE"},;   //      98
					{"SF2","F2_DESNTRB"},;   //      99
					{"SF2","F2_DTDIGIT"},;   //     100
					{"SF2","F2_EMINFE"},;    //     101
					{"SF2","F2_HORNFE"},;    //     102
					{"SF2","F2_NFAGREG"},;   //     103
					{"SF2","F2_NFELETR"},;   //     104
					{"SF2","F2_RECISS"},;    //     105
					{"SF2","F2_TARA"},;      //     106
					{"SF2","F2_TPVENT"},;   //      107
					{"SF2","F2_VCTOCAE"},;   //     108
					{"SF2","F2_VLR_FRT"},;   //     109
					{"SF3","F3_BSREIN"},;   //      110
					{"SF3","F3_CAE"},;   //         111
					{"SF3","F3_CODNFE"},;   //      112
					{"SF3","F3_CRDEST"},;   //      113
					{"SF3","F3_CREDNFE"},;   //     114
					{"SF3","F3_CREDPRE"},;   //     115
					{"SF3","F3_CRPREPE"},;   //     116
					{"SF3","F3_DESCZFR"},;   //     117
					{"SF3","F3_DS43080"},;   //     118
					{"SF3","F3_ECF"},;   //         119
					{"SF3","F3_EMINFE"},;   //      120
					{"SF3","F3_HORNFE"},;   //      121
					{"SF3","F3_MDCAT79"},;   //     122
					{"SF3","F3_NFAGREG"},;   //     123
					{"SF3","F3_NFELETR"},;   //    124
					{"SF3","F3_NUMRPS"},;   //     125
					{"SF3","F3_SIMPLES"},;   //     126
					{"SF3","F3_TPVENT"},;   //     127
					{"SF3","F3_VCTOCAE"},;   //     128
					{"SF3","F3_VFECPMG"},;   //     129
					{"SF3","F3_VFECPMT"},;   //     130
					{"SF3","F3_VFECPRN"},;   //     131
					{"SF3","F3_VFESTMG"},;   //     132
					{"SF3","F3_VFESTMT"},;   //     133
					{"SF3","F3_VFESTRN"},;   //     134
					{"SF3","F3_VL43080"},;   //     135
					{"SF3","F3_VLINCMG"},;   //     136
					{"SF3","F3_VREINT"},;   //      137
					{"SF4","F4_AFRMM"},;   //       138
					{"SF4","F4_AGRCOF"},;   //      139
					{"SF4","F4_AGRDRED"},;   //     140
					{"SF4","F4_AGREGCP"},;   //     141
					{"SF4","F4_AGRPIS"},;   //      142
					{"SF4","F4_AGRRETC"},;   //     143
					{"SF4","F4_ALSENAR"},;   //     144
					{"SF4","F4_ANTICMS"},;   //     145
					{"SF4","F4_APLIIVA"},;   //     146
					{"SF4","F4_APLIRED"},;   //     147
					{"SF4","F4_APLREDP"},;   //     148
					{"SF4","F4_APSCFST"},;   //     149
					{"SF4","F4_ATACVAR"},;   //     150
					{"SF4","F4_BASECOF"},;   //     151
					{"SF4","F4_BASEISS"},;   //     152
					{"SF4","F4_BASEPIS"},;   //     153
					{"SF4","F4_BCPCST"},;   //      154
					{"SF4","F4_BSICMST"},;   //     155
					{"SF4","F4_BSRDICM"},;   //    156
					{"SF4","F4_BSRURAL"},;   //     157
					{"SF4","F4_CALCFET"},;   //     158
					{"SF4","F4_CFABOV"},;   //      159
					{"SF4","F4_CFACS"},;   //       160
					{"SF4","F4_CFPS"},;   //        161
					{"SF4","F4_CLFDSUL"},;   //     162
					{"SF4","F4_CNATREC"},;   //     163
					{"SF4","F4_CODBCC"},;   //      164
					{"SF4","F4_COFBRUT"},;   //     165
					{"SF4","F4_COFDSZF"},;   //     166
					{"SF4","F4_COMPRED"},;   //     167
					{"SF4","F4_CONSIND"},;   //     168
					{"SF4","F4_CONTSOC"},;   //     169
					{"SF4","F4_CPPRODE"},;   //     170
					{"SF4","F4_CPRECTR"},;   //     171
					{"SF4","F4_CPRESPR"},;   //     172
					{"SF4","F4_CRDEST"},;   //      173
					{"SF4","F4_CRDPRES"},;   //     174
					{"SF4","F4_CRDTRAN"},;   //     175
					{"SF4","F4_CREDACU"},;   //     176
					{"SF4","F4_CREDPRE"},;   //     177
					{"SF4","F4_CREDST"},;   //      178
					{"SF4","F4_CROUTGO"},;   //     179
					{"SF4","F4_CROUTSP"},;   //     180
					{"SF4","F4_CRPRELE"},;   //     181
					{"SF4","F4_CRPREPE"},;   //     182
					{"SF4","F4_CRPREPR"},;   //     183
					{"SF4","F4_CRPRERO"},;   //     184
					{"SF4","F4_CRPRESP"},;   //     185
					{"SF4","F4_CRPRSIM"},;   //     186
					{"SF4","F4_CRPRST"},;   //      187
					{"SF4","F4_CSTCOF"},;   //      188
					{"SF4","F4_CSTISS"},;   //      189
					{"SF4","F4_CSTPIS"},;   //      190
					{"SF4","F4_CTIPI"},;   //       191
					{"SF4","F4_DBSTCSL"},;   //     192
					{"SF4","F4_DBSTIRR"},;   //     193
					{"SF4","F4_DESCOND"},;   //     194
					{"SF4","F4_DESPCOF"},;   //     195
					{"SF4","F4_DESPPIS"},;   //     196
					{"SF4","F4_DSPRDIC"},;   //     197
					{"SF4","F4_DTFIMNT"},;   //     198
					{"SF4","F4_DUPLIST"},;   //     199
					{"SF4","F4_ESTCRED"},;   //     200
					{"SF4","F4_GRPNATR"},;   //     201
					{"SF4","F4_ICMSST"},;   //      202
					{"SF4","F4_ICMSTMT"},;   //     203
					{"SF4","F4_INCSOL"},;   //      204
					{"SF4","F4_INDNTFR"},;   //     205
					{"SF4","F4_INTBSIC"},;   //     206
					{"SF4","F4_IPIANT"},;   //      207
					{"SF4","F4_IPIOBS"},;   //      208
					{"SF4","F4_IPIPC"},;   //       209
					{"SF4","F4_ISEFECP"},;   //     210
					{"SF4","F4_ISEFEMG"},;   //     211
					{"SF4","F4_ISEFEMT"},;   //     212
					{"SF4","F4_ISEFERN"},;   //     213
					{"SF4","F4_ISSST"},;   //       214
					{"SF4","F4_LFICMST"},;   //     215
					{"SF4","F4_LFISS"},;   //       216
					{"SF4","F4_MALQCOF"},;   //     217
					{"SF4","F4_MKPSOL"},;   //      218
					{"SF4","F4_MOTICMS"},;   //     219
					{"SF4","F4_NORESP"},;   //      220
					{"SF4","F4_OBSICM"},;   //      221
					{"SF4","F4_OBSSOL"},;   //      222
					{"SF4","F4_OPERSUC"},;   //     223
					{"SF4","F4_PAUTICM"},;   //     224
					{"SF4","F4_PICMDIF"},;   //     225
					{"SF4","F4_PISBRUT"},;   //     226
					{"SF4","F4_PISCOF"},;   //      227
					{"SF4","F4_PISCRED"},;   //     228
					{"SF4","F4_PISDSZF"},;   //     229
					{"SF4","F4_PR35701"},;   //     230
					{"SF4","F4_PSCFST"},;   //      231
					{"SF4","F4_REDANT"},;   //      232
					{"SF4","F4_REDBCCE"},;   //     233
					{"SF4","F4_RGESPST"},;   //     234
					{"SF4","F4_SITTRIB"},;   //     235
					{"SF4","F4_SOMAIPI"},;   //     236
					{"SF4","F4_STCONF"},;   //      237
					{"SF4","F4_TNATREC"},;   //     238
					{"SF4","F4_TPPRODE"},;   //     239
					{"SF4","F4_TRFICM"},;   //      240
					{"SF4","F4_VARATAC"},;   //     241
					{"SF4","F4_VDASOFT"},;   //     242
					{"SF4","F4_VENPRES"},;   //     243
					{"SF7","F7_BSICMST"},;   //     244
					{"SF7","F7_CNATREC"},;   //     245
					{"SF7","F7_DTFIMNT"},;   //     246
					{"SF7","F7_GRUPONC"},;   //     247
					{"SF7","F7_PRCUNIC"},;   //     248
					{"SF7","F7_TNATREC"},;   //     249
					{"SF7","F7_UFBUSCA"},;   //     250
					{"SFB","FB_DESGR"},;   	//       251
					{"SFC","FC_PROV"},;   	//        252
					{"SFP","FP_QTDITEM"},;   //     253
					{"SFP","FP_TIPOFOR"},;   //    254
					{"SFQ","FQ_SEQDES"},;   //      255
					{"SFT","FT_AGREG"},;   //       256
					{"SFT","FT_ALFECMG"},;   //     257
					{"SFT","FT_ALFECMT"},;   //     258
					{"SFT","FT_ALFECRN"},;   //    259
					{"SFT","FT_ALIQSOL"},;   //     260
					{"SFT","FT_ALIQTST"},;   //     261
					{"SFT","FT_ALQFAB"},;   //      262
					{"SFT","FT_ALQFAC"},;   //      263
					{"SFT","FT_ALQFECP"},;   //     264
					{"SFT","FT_ALQFET"},;   //      265
					{"SFT","FT_ALQFUM"},;   //      266
					{"SFT","FT_ALSENAR"},;   //     267
					{"SFT","FT_ANTICMS"},;   //     268
					{"SFT","FT_BASETST"},;   //     269
					{"SFT","FT_BSEFAB"},;   //      270
					{"SFT","FT_BSEFAC"},;   //      271
					{"SFT","FT_BSEFET"},;   //      272
					{"SFT","FT_BSREIN"},;   //      273
					{"SFT","FT_BSSENAR"},;   //     274
					{"SFT","FT_CHVNFE"},;   //      275
					{"SFT","FT_CODBCC"},;   //      276
					{"SFT","FT_CODIF"},;   //       277
					{"SFT","FT_CODNFE"},;   //      278
					{"SFT","FT_COECFST"},;   //     279
					{"SFT","FT_COEPSST"},;   //     280
					{"SFT","FT_CPPRODE"},;   //     281
					{"SFT","FT_CPRESPR"},;   //     282
					{"SFT","FT_CRDPRES"},;   //     283
					{"SFT","FT_CREDNFE"},;   //     284
					{"SFT","FT_CREDPRE"},;   //     285
					{"SFT","FT_CROUTGO"},;   //     286
					{"SFT","FT_CROUTSP"},;   //     287
					{"SFT","FT_CRPREPE"},;   //     288
					{"SFT","FT_CRPREPR"},;   //     289
					{"SFT","FT_CRPRERO"},;   //     290
					{"SFT","FT_CRPRESP"},;   //     291
					{"SFT","FT_CRPRRON"},;   //     292
					{"SFT","FT_CRPRSIM"},;   //     293
					{"SFT","FT_CSTCOF"},;   //      294
					{"SFT","FT_CSTISS"},;   //      295
					{"SFT","FT_CSTPIS"},;   //      296
					{"SFT","FT_DESCICM"},;   //     297
					{"SFT","FT_DESCZFR"},;   //     298
					{"SFT","FT_EMINFE"},;   //      299
					{"SFT","FT_HORNFE"},;   //      300
					{"SFT","FT_INDNTFR"},;   //     301
					{"SFT","FT_MALQCOF"},;   //     302
					{"SFT","FT_MARGEM"},;   //      303
					{"SFT","FT_MVALCOF"},;   //     304
					{"SFT","FT_NFELETR"},;   //     305
					{"SFT","FT_NORESP"},;   //      306
					{"SFT","FT_NUMRPS"},;   //      307
					{"SFT","FT_PAUTCOF"},;   //     308
					{"SFT","FT_PAUTIC"},;   //      309
					{"SFT","FT_PAUTIPI"},;   //     310
					{"SFT","FT_PAUTPIS"},;   //     311
					{"SFT","FT_PAUTST"},;   //      312
					{"SFT","FT_PR43080"},;   //     313
					{"SFT","FT_PRCUNIC"},;   //     314
					{"SFT","FT_PRFDSUL"},;   //     315
					{"SFT","FT_PRINCMG"},;   //     316
					{"SFT","FT_RGESPST"},;   //     317
					{"SFT","FT_TPPRODE"},;   //     318
					{"SFT","FT_UFERMS"},;   //      319
					{"SFT","FT_VALANTI"},;   //     320
					{"SFT","FT_VALFAB"},;   //      321
					{"SFT","FT_VALFAC"},;   //      322
					{"SFT","FT_VALFDS"},;   //      323
					{"SFT","FT_VALFECP"},;   //     324
					{"SFT","FT_VALFET"},;   //      325
					{"SFT","FT_VALFUM"},;   //     326
					{"SFT","FT_VALTST"},;   //      327
					{"SFT","FT_VFECPMG"},;   //     328
					{"SFT","FT_VFECPMT"},;   //     329
					{"SFT","FT_VFECPRN"},;   //     330
					{"SFT","FT_VFECPST"},;   //     331
					{"SFT","FT_VFESTMG"},;   //     332
					{"SFT","FT_VFESTMT"},;   //     333
					{"SFT","FT_VFESTRN"},;   //     334
					{"SFT","FT_VLINCMG"},;   //     335
					{"SFT","FT_VLSENAR"},;   //     336
					{"SFT","FT_VREINT"},;   //      337
					{"SN1","N1_ALIQCOF"},;   //     338
					{"SN1","N1_ALIQPIS"},;   //     339
					{"SN1","N1_CODBCC"},;   //      340
					{"SN1","N1_CSTCOFI"},;   //     341
					{"SN1","N1_CSTPIS"},;   //      342
					{"SUS","US_ALIQIR"},;   //      343
					{"SUS","US_CALCSUF"},;   //     344
					{"SUS","US_CONTRIB"},;   //     345
					{"SUS","US_GRPTRIB"},;   //     346
					{"SUS","US_INSCR"},;   //       347
					{"SUS","US_NATUREZ"},;   //     348
					{"SUS","US_RECCOFI"},;   //     349
					{"SUS","US_RECCSLL"},;   //     350
					{"SUS","US_RECINSS"},;   //     351
					{"SUS","US_RECISS"},;   //      352
					{"SUS","US_RECPIS"},;   //      353
					{"SUS","US_SUFRAMA"},;   //     354
					{"SUS","US_TPESSOA"},;   //     355
					{"SWN","WN_ITEMNF"},;   //      356
					{"SWN","WN_TES"},; 		//       357
					{"SB1","B1_AFABOV"},; 	//       358
					{"SA2","A2_RFABOV"},; 	//       359
					{"SA1","A1_RFABOV"},; 	//       360
					{"SB1","B1_AFACS"},; 	//       361
					{"SA2","A2_RFACS"},; 	//       362
					{"SA1","A1_RFACS"},; 	//       363
					{"SB1","B1_AFETHAB"},;	//       364
					{"SA2","A2_RECFET"},;	//       365
					{"SA1","A1_RECFET"},; 	//       366
					{"SF3","F3_VALTPDP"},;	// 		 367
					{"SF3","F3_TIPANUL"},;	// 		 368
					{"SF3","F3_NCF"	},;		//  	 369
					{"SA1","A1_TPDP"},;		// 		 370
					{"SB1","B1_TPDP"},;		//		 371
					{"SFT","FT_B1DIAT"},;  // 		 372
					{"SB1",aSX6[MV_ALQDFB1]},; 	//		 373
					{"SB1",aSX6[MV_B1PTST]},; 	//	     374
					{"SA1","A1_CRDMA"},;	//	 	375
					{"SA1","A1_CDRDES"},;	//		376
					{"CC2","CC2_PERMAT"},;	//		377
					{"CC2","CC2_PERSER"},;	//		378
					{"CC2","CC2_MDEDMA"},;	//		379
					{"CC2","CC2_MDEDSR"},; 	//		380
					{"SB1","B1_ALFECRN"},; 	//		381
					{"SD2","D2_VALADI"},; 	//		382
					{"SF4","F4_NATOPER"},;	//		383
					{"SBI","BI_COD"},;        //  384
					{"SBI","BI_GRTRIB"},; //      385
					{"SBI","BI_CODIF"},; //       386
					{"SBI","BI_RSATIVO"},; //     387
					{"SBI","BI_POSIPI"},; //      388
					{"SBI","BI_UM"},; //          389
					{"SBI","BI_SEGUM"},; //       390
					{"SBI","BI_AFABOV"},; //      391
					{"SBI","BI_AFACS"},; //       392
					{"SBI","BI_AFETHAB"},; //     393
					{"SBI","BI_TFETHAB"},; //     394
					{"SBI","BI_PICM"},; //        395
					{"SBI","BI_FECOP"},; //       396
					{"SBI","BI_ALFECOP"},; //     397
					{"SBI","BI_ALIQISS"},; //     398
					{"SBI","BI_IMPZFRC"},; //     399
					{"SBI","BI_INT_ICM"},; //     400
					{"SBI","BI_PR43080"},; //     401
					{"SBI","BI_PRINCMG"},; //     402
					{"SBI","BI_ALFECST"},; //     403
					{"SBI","BI_PICMENT"},; //     404
					{"SBI","BI_PICMRET"},; //     405
					{"SBI","BI_IVAAJU"},; //      406
					{"SBI","BI_RASTRO"},; //      407
					{"SBI","BI_VLR_ICM"},; //     408
					{"SBI","BI_VLR_PIS"},; //     409
					{"SBI","BI_VLR_COF"},; //     410
					{"SBI","BI_ORIGEM"},; //      411
					{"SBI","BI_CRDEST"},; //      412
					{"SBI","BI_CODISS"},; //      413
					{"SBI","BI_TNATREC"},; //     414
					{"SBI","BI_CNATREC"},; //     415
					{"SBI","BI_GRPNATR"},; //     416
					{"SBI","BI_DTFIMNT"},; //     417
					{"SBI","BI_IPI"},; //         418
					{"SBI","BI_VLR_IPI"},; //     419
					{"SBI","BI_CNAE"},; //        420
					{"SBI","BI_REGRISS"},; //     421
					{"SBI","BI_REDINSS"},; //     422
					{"SBI","BI_INSS"},; //        423
					{"SBI","BI_IRRF"},; //        424
					{"SBI","BI_REDIRRF"},; //     425
					{"SBI","BI_REDPIS"},; //      426
					{"SBI","BI_PPIS"},; //        427
					{"SBI","BI_PIS"},; //         428
					{"SBI","BI_CHASSI"},; //      429
					{"SBI","BI_RETOPER"},; //     430
					{"SBI","BI_REDCOF"},; //      431
					{"SBI","BI_PCOFINS"},; //     432
					{"SBI","BI_COFINS"},; //      433
					{"SBI","BI_PCSLL"},; //       434
					{"SBI","BI_CONTSOC"},; //     435
					{"SBI","BI_PRFDSUL"},; //     436
					{"SBI","BI_FECP"},; //        437
					{"SBI","BI_FECPBA"},; //      438
					{"SBI","BI_ALFECRN"},; //     439
					{"SBI","BI_ALFUMAC"},; //     440
					{"SBI","BI_PRN944I"},; //     441
					{"SBI","BI_REGESIM"},; //     442
					{"SBI","BI_VLRISC"},; //      443
					{"SBI","BI_CRDPRES"},; //     444
					{"SBI","BI_VMINDET"},; //     445
					{"SBI","BI_IMPORT"},; //      446
					{"SBI","BI_TPDP"},; //        447
					{"SBI","BI_"+Substr(aSX6[MV_ALQDFB1],4) },; //     448
					{"SBI","BI_"+Substr(aSX6[MV_B1PTST] ,4) },; //     449
					{"SBI","BI_"+Substr(aSX6[MV_PRDDIAT],4) },; //     450
					{"SBI","BI_"+Substr(aSX6[MV_B1CALTR],4) },; //     451
					{"SBI","BI_"+Substr(aSX6[MV_B1CATRI],4) },; //     452
					{"SBI","BI_"+Substr(aSX6[MV_ICMPFAT],4) },; //     453
					{"SBI","BI_"+Substr(aSX6[MV_IPIPFAT],4) },; //     454
					{"SBI","BI_"+Substr(aSX6[MV_PUPCCST],4) },; //     455
					{"SBI","BI_"+Substr(aSX6[MV_B1CPSST],4) },; //     456
					{"SBI","BI_"+Substr(aSX6[MV_B1CCFST],4) },; //     457
					{"SBI","BI_"+Substr(aSX6[MV_FECPMT] ,4) },; //     458
					{"SBI","BI_"+Substr(aSX6[MV_ADIFECP],4) },; //     459
					{"SBI","BI_"+Substr(aSX6[MV_ALFECMG],4) },; //     460
					{"SB1","B1_COD"},; //         461
					{"SB1","B1_GRTRIB"},; //      462
					{"SB1","B1_CODIF"},; //       463
					{"SB1","B1_RSATIVO"},; //     464
					{"SB1","B1_POSIPI"},; //      465
					{"SB1","B1_UM"},; //          466
					{"SB1","B1_SEGUM"},; //       467
					{"SB1","B1_TFETHAB"},; //     468
					{"SB1","B1_PICM"},; //        469
					{"SB1","B1_ALIQISS"},; //     470
					{"SB1","B1_IMPZFRC"},; //     471
					{"SB1","B1_INT_ICM"},; //     472
					{"SB1","B1_PR43080"},; //     473
					{"SB1","B1_PRINCMG"},; //     474
					{"SB1","B1_PICMENT"},; //     475
					{"SB1","B1_PICMRET"},; //     476
					{"SB1","B1_IVAAJU"},; //      477
					{"SB1","B1_RASTRO"},; //      478
					{"SB1","B1_VLR_ICM"},; //     479
					{"SB1","B1_VLR_PIS"},; //     480
					{"SB1","B1_VLR_COF"},; //     481
					{"SB1","B1_ORIGEM"},; //      482
					{"SB1","B1_CRDEST"},; //      483
					{"SB1","B1_CODISS"},; //      484
					{"SB1","B1_IPI"},; //         485
					{"SB1","B1_VLR_IPI"},; //     486
					{"SB1","B1_CNAE"},; //        487
					{"SB1","B1_REDINSS"},; //     488
					{"SB1","B1_INSS"},; //        489
					{"SB1","B1_IRRF"},; //        490
					{"SB1","B1_REDIRRF"},; //     491
					{"SB1","B1_REDPIS"},; //      492
					{"SB1","B1_PPIS"},; //        493
					{"SB1","B1_PIS"},; //         494
					{"SB1","B1_RETOPER"},; //     495
					{"SB1","B1_REDCOF"},; //      496
					{"SB1","B1_PCOFINS"},; //     497
					{"SB1","B1_COFINS"},; //      498
					{"SB1","B1_PCSLL"},; //       499
					{"SB1","B1_CONTSOC"},; //     500
					{"SB1","B1_PRFDSUL"},; //     501
					{"SB1","B1_FECP"},; //        502
					{"SB1","B1_VLRISC"},; //      503
					{"SB1","B1_"+Substr(aSX6[MV_ALQDFB1],4) },; //     504
					{"SB1","B1_"+Substr(aSX6[MV_B1PTST] ,4) },; //     505
					{"SB1","B1_"+Substr(aSX6[MV_PRDDIAT],4) },; //     506
					{"SB1","B1_"+Substr(aSX6[MV_B1CALTR],4) },; //     507
					{"SB1","B1_"+Substr(aSX6[MV_B1CATRI],4) },; //     508
					{"SB1","B1_"+Substr(aSX6[MV_ICMPFAT],4) },; //     509
					{"SB1","B1_"+Substr(aSX6[MV_IPIPFAT],4) },; //     510
					{"SB1","B1_"+Substr(aSX6[MV_PUPCCST],4) },; //     511
					{"SB1","B1_"+Substr(aSX6[MV_B1CPSST],4) },; //     512
					{"SB1","B1_"+Substr(aSX6[MV_B1CCFST],4) },; //     513
					{"SB1","B1_"+Substr(aSX6[MV_FECPMT] ,4) },; //     514
					{"SB1","B1_"+Substr(aSX6[MV_ADIFECP],4) },; //     515
					{"SB1","B1_"+Substr(aSX6[MV_ALFECMG],4) },; //     516
					{"SBZ","BZ_PICM"},; //        517
					{"SBZ","BZ_VLR_ICM"},; //     518
					{"SBZ","BZ_INT_ICM"},; //     519
					{"SBZ","BZ_PICMRET"},; //     520
					{"SBZ","BZ_PICMENT"},; //     521
					{"SBZ","BZ_IPI"},; //         522
					{"SBZ","BZ_VLR_IPI"},; //     523
					{"SBZ","BZ_REDPIS"},; //      524
					{"SBZ","BZ_REDCOF"},; //      525
					{"SBZ","BZ_IRRF"},; //        526
					{"SBZ","BZ_ORIGEM"},; //      527
					{"SBZ","BZ_GRTRIB"},; //      528
					{"SBZ","BZ_CODISS"},; //      529
					{"SBZ","BZ_FECP"},; //        530
					{"SBZ","BZ_ALIQISS"},; //     531
					{"SBZ","BZ_PIS"},; //         532
					{"SBZ","BZ_COFINS"},; //      533
					{"SBZ","BZ_PCSLL"},; //       534
					{"SBZ","BZ_ALFUMAC"},; //     535
					{"SBZ","BZ_FECPBA"},; //      536
					{"SBZ","BZ_ALFECRN"},; //     537
					{"SBZ","BZ_CNAE"},; //        538
					{"SBI","BI_CSLL"},; //        539
					{"SB1","B1_CSLL"},; //        540
					{"SBZ","BZ_CSLL"},; //        541
					{"SF4","F4_TPCPRES"},;//       542
					{"SFT","FT_IDSF4"}  ,;  //    543
					{"SFT","FT_IDSF7"}  ,;  //    544
					{"SFT","FT_IDSA1"}  ,;  //    545
					{"SFT","FT_IDSA2"}  ,;  //    546
					{"SFT","FT_IDSB1"}  ,;  //    547
					{"SFT","FT_IDSB5"}  ,;  //    548
					{"SFT","FT_IDSBZ"}  ,;  //    549
					{"SFT","FT_IDSED"}  ,;  //    550
					{"SFT","FT_IDSFB"}  ,; //     551
					{"SF4","F4_IDHIST"} ,;  //    552
					{"SF7","F7_IDHIST"} ,;  //    553
					{"SA1","A1_IDHIST"} ,;  //    554
					{"SA2","A2_IDHIST"} ,;  //    555
					{"SB1","B1_IDHIST"} ,;  //    556
					{"SB5","B5_IDHIST"} ,;  //    557
					{"SBZ","BZ_IDHIST"} ,;  //    558
					{"SED","ED_IDHIST"} ,;  //    559
					{"SFB","FB_IDHIST"} ,;  //    560
					{"SFC","FC_IDHIST"} ,;  //    561
					{"SF1","F1_IDSA1"}  ,;  //    562
					{"SF1","F1_IDSA2"}  ,;  //    563
					{"SF1","F1_IDSED"}  ,;  //    564
					{"SF2","F2_IDSA1"}  ,;  //    565
					{"SF2","F2_IDSA2"}  ,;  //    566
					{"SF2","F2_IDSED"}  ,;  //    567
					{"SD1","D1_IDSF4"}  ,;  //    568
					{"SD1","D1_IDSF7"}  ,;  //    569
					{"SD1","D1_IDSB1"}  ,;  //    570
					{"SD1","D1_IDSBZ"}  ,;  //    571
					{"SD1","D1_IDSB5"}  ,;  //    572
					{"SD2","D2_IDSF4"}  ,;  //    573
					{"SD2","D2_IDSF7"}  ,;  //    574
					{"SD2","D2_IDSB1"}  ,;  //    575
					{"SD2","D2_IDSBZ"}  ,;  //    576
					{"SD2","D2_IDSB5"}  ,;  //    577
					{"SFT","FT_DS43080"},;   //    578
					{"SFT","FT_DESCTOT"},;   //    579
					{"SFT","FT_ACRESCI"},;   //    580
					{"SF4","F4_DEVPARC"},;   //    581
					{"SB5","B5_ALIMEN"} ,; 	 //    582
					{"SF4","F4_ALIMEN"} ,;	 //    583
					{"SF4","F4_PERCATM"},; 	 //    584
					{"SF4","F4_DICMFUN"},;   //    585
					{"SF4","F4_MALQPIS"} ,;  //    586
					{"SD1","D1_VALPMAJ"},;   //    587
					{"SFT","FT_MALQPIS"},;   //    588
					{"SFT","FT_MVALPIS"},;   //    589
					{"SF4","F4_IMPIND"} ,;   //    590
					{"SF4","F4_OPERGAR"},;   //    591
					{"SF4","F4_FRETISS"},;   //    592
					{"SBI","BI_MEPLES"},;  	 //    593
					{"SB1","B1_MEPLES"},; 	 //    594
					{"SS4","S4_CHASSI"},;	 //    595
					{"SS4","S4_VLRISC"},;	 //	   596
					{"SS4","S4_VMINDET"},;	 //    597
					{"SS4","S4_CODIF"},; 		//    598
					{"CFC","CFC_MGLQST"},;	//599
					{"CFC","CFC_ALQSTL"},;	//600
					{"SF4","F4_STLIQ"},;	//601
					{"SS9","S9_MGLQST"},;   //602
					{"SS9","S9_ALQSTL"},;	//603
					{"SED","ED_CALCCID"},;	 //604
					{"SED","ED_PERCCID"},;	 //605
					{"SED","ED_BASECID"},;	 //606
					{"SA2","A2_RECCIDE"},;	 //607
					{"SF7","F7_SITTRIB"},;	 //608
					{"SF7","F7_ORIGEM"},;	 //609
					{"SS1","S1_SITTRIB"},;	 //610
					{"SS1","S1_ORIGEM"},;	 //611
					{"CFC","CFC_MARGEM"},;	 //612
					{"SS9","S9_MARGEM"},;	 //613
					{"SA1","A1_FRETISS"},;   //614
					{"SF4","F4_CV139"},;     //615
					{"SFT","FT_CV139"},;     //616
					{"SF4","F4_RFETALG"},;   //617
					{"CFC","CFC_ALFCPO"},;	 //618
					{"SS9","S9_ALFCPO"},;	 //619
					{"CFC","CFC_FCPAUX"},;	 //620
					{"SS9","S9_FCPAUX"},;	 //621
					{"CFC","CFC_FCPXDA"},;	 //622
					{"SS9","S9_FCPXDA"},;	 //623
					{"CFC","CFC_FCPINT"},;	 //624
					{"SS9","S9_FCPINT"},;	 //625
					{"SD1","D1_BASNDES"},;	 //626
					{"SD1","D1_ICMNDES"},;  //627
					{"CFC","CFC_CODPRD"},;	 //628
					{"SD2","D2_IDCFC"},;	 //629
					{"SD1","D1_IDCFC"},;	 //630
					{"SF4","F4_PARTICM"},;	 //631
					{"CD2","CD2_PARTIC"},;	 //632
					{"CC7","CC7_CODREF"},;	//633
					{"CFC","CFC_RDCTIM"},; //634
					{"SF4","F4_BSICMRE"},; //635
					{"SB1","B1_UPRC"},;      //636
					{"SF4","F4_ALICRST"},;   //637
					{"SF4","F4_TRANFIL"},;   //638
					{"CC2","CC2_BASISS"},;   //639
					{"SED","ED_IRRFCAR"},;   //640
					{"SED","ED_BASEIRC"},;   //641
					{"SF7","F7_MSBLQD" },;   //642
					{"SB1",AllTrim(aSX6[MV_PAUTFOB]) },; //643 - Campo de Pauta ICMS
					{"CC2","CC2_CPOM"},;     //644
					{"SF4","F4_IPIVFCF"},;	//645
					{"SF3","F3_BASECPM"},;	//646
					{"SF3","F3_ALQCPM"},;	//647
					{"SF3","F3_VALCPM"},;	//648
					{"SF4","F4_RDBSICM"},; 	//649
					{"SF3","F3_BASEFMP"},; 	//650
					{"SF3","F3_VALFMP"},; 	//651
					{"SF3","F3_ALQFMP"},;	//652
					{"SED","ED_CALCFMP"},;	//653
					{"SED","ED_PERQFMP"},; 	//654
					{"SF3","F3_VALFMD "},;	//655
					{"SB1","B1_AFAMAD"},;	//656
					{"SA2","A2_RECFMD"},;	//657
					{"SA1","A1_RECFMD"},;	//658
					{"SF4","F4_CFAMAD"},;	//659
					{"SFT","FT_BSEFM" },;	//660
					{"SFT","FT_ALQFMD"},;	//661
					{"SFT","FT_VALFMD"},;	//662
					{"SF4","F4_DESCISS"},;  //663
					{"CDA","CDA_VL197"},;   //664
					{"CE0","CE0_VL197"},;	//665
					{"CC2","CC2_TPDIA"},;	//666
					{"SF4","F4_OUTPERC"},;	//667
					{"SF4","F4_PISMIN"},;  //668
					{"SF4","F4_COFMIN"},;  //669
					{"SF4","F4_IPIMIN"},;  //670
					{"SB1","B1_CONV"},;     //671
					{"SBZ","BZ_PPIS"},; 	//672
					{"SBZ","BZ_PCOFINS"},; 	//673
					{"SF4","F4_CUSENTR"},; 	//674
					{"SA1","A1_INCLTMG"},; 	//675
					{"SBI","BI_ALFECMG"},; 	//676
					{"SBI",Substr(aSX6[MV_MVAFRP],6) },; //677
					{"SB1",Substr(aSX6[MV_MVAFRP],6) },; //678
					{"SF7",Substr(aSX6[MV_MVAFRE],6) },; //679
					{"SS9",Substr(aSX6[MV_MVAFRU],6) },; //680
					{"SS1",Substr(aSX6[MV_MVAFRE],6) },; //681
					{"CFC",Substr(aSX6[MV_MVAFRU],6) },; //682
					{"SB1",Substr(aSX6[MV_MVAFRC],6) },; //683
					{"SBI",Substr(aSX6[MV_MVAFRC],6) },; //684
					{"CFC","CFC_MVAES"},;	//685
					{"SS9","SS9_MVAES"},;	//686
					{"SFT","FT_SERSAT"},;	//687
					{"SF3","F3_SERSAT"},;	//688
					{"CC7","CC7_CLANC"},;	//689
					{"CDA","CDA_CLANC"},;	//690
					{"SFT","FT_BASNDES"},;	//691
					{"SFT","FT_ICMNDES"},;	//692
					{"SF3","F3_BASNDES"},;	//693
					{"SF3","F3_ICMNDES"},;	//694
					{"SB1","B1_GRPCST"},;	//695
					{"SF4","F4_GRPCST"},;	//696
					{"SFT","FT_GRPCST"},;	//697
					{"CD2","CD2_GRPCST"},;	//698
					{"SF4","F4_IPIPECR"},;	//699
					{"SF4","F4_TXAPIPI"},;	//700
					{"SB1","B1_CEST"},;		//701
					{"SFT","FT_CEST"},;		//702
					{"CD2","CD2_CEST"},;		//703
					{"SF4","F4_CALCCPB"},;	//704
					{"SD1","D1_BASECPB"},;	//705
					{"SD1","D1_VALCPB"},;	//706
					{"SD1","D1_ALIQCPB"},;	//707
					{"SD2","D2_BASECPB"},;	//708
					{"SD2","D2_VALCPB"},;	//709
					{"SD2","D2_ALIQCPB"},;	//710
					{"SF3","F3_BASECPB"},;	//711
					{"SF3","F3_VALCPB"},;	//712
					{"SF3","F3_ALIQCPB"},;	//713
					{"SFT","FT_BASECPB"},;	//714
					{"SFT","FT_VALCPB"},;	//715
					{"SFT","FT_ALIQCPB"},; 	//716
					{"SB5","B5_CODATIV"},; 	//717
					{"SFT","FT_ATIVCPB"},;	//718
					{"CG1","CG1_ALIQ"},;  	 //719
					{"CD2","CD2_PICMDF"},;	//720
					{"SF3","F3_SERSAT"},;	//721
					{"SFT","FT_SERSAT"},;	//722
					{"SFT","FT_DIFAL"},;	//723
					{"SF3","F3_DIFAL"},;	//724
					{"SF4","F4_DIFAL"},;	//725
					{"CD2","CD2_PDDES"},;	//726
					{"CD2","CD2_PDORI"},;	//727
					{"CD2","CD2_VDDES"},;	//728
					{"CD2","CD2_ADIF"},;	//729
					{"CD2","CD2_PFCP"},;	//730
					{"CD2","CD2_VFCP"},;	//731
					{"SFT","FT_PDORI"},;	//732
					{"SFT","FT_PDDES"},;	//733
					{"SFT","FT_VFCPDIF"},;	//734
					{"SF3","F3_VFCPDIF"},;	//735
					{"SFT","FT_BASEDES"},;	//736
					{"SF3","F3_BASEDES"},;	//737
					{"SBI","BI_CEST"},;		//738
					{"CD2","CD2_DESONE"},;	//739
					{"SF4","F4_BASCMP"},;	//740
					{"CD2","CD2_PDEVOL"},;	//741
					{"SA2","A2_CONTRIB"},;	//742
					{"SF4","F4_DUPLIPI"},;	//743
					{"SD1","D1_ALIQCMP"},;	//744
					{"SD2","D2_ALIQCMP"},;	//745
					{"SF4","F4_TXAPIPI"},;	//746
					{"SA1","A1_SIMPNAC"},;   //747
					{"SF4","F4_FTRICMS"},;   //748
					{"SD2","D2_FTRICMS"},;   //749
					{"SFT","FT_FTRICMS"},;   //750
					{"SD2","D2_VRDICMS"},;   //751
					{"SFT","FT_VRDICMS"},;   //752
					{"SD1","D1_FTRICMS"},;   //753
					{"SD1","D1_VRDICMS"},;   //754
					{"SF3","F3_BSICMOR"},;	//755
					{"SFT","FT_BSICMOR"},;	//756
					{"SF4","F4_AGRISS"},;	//757
					{"SF4","F4_CFUNDES"},;	//758
					{"SF4","F4_CIMAMT"},;	//759
					{"SF4","F4_CFASE"},;		//760
					{"SB1","B1_AFUNDES"},;	//761
					{"SB1","B1_AIMAMT"},;	//762
					{"SB1","B1_AFASEMT"},;	//763
					{"SA1","A1_RFUNDES"},;	//764
					{"SA1","A1_RIMAMT"},;	//765
					{"SA1","A1_RFASEMT"},;	//766
					{"SA2","A2_RFUNDES"},;	//767
					{"SA2","A2_RIMAMT"},;	//768
					{"SA2","A2_RFASEMT"},;	//769
					{"SF1","F1_VALFUND"},;	//770
					{"SF1","F1_VALIMA"},;	//771
					{"SF1","F1_VALFASE"},;	//772
					{"SF2","F2_VALFUND"},;	//773
					{"SF2","F2_VALIMA"},;	//774
					{"SF2","F2_VALFASE"},;	//775
					{"SD1","D1_VALFUND"},;	//776
					{"SD1","D1_BASFUND"},;	//777
					{"SD1","D1_ALIFUND"},;	//778
					{"SD1","D1_VALIMA"},;	//779
					{"SD1","D1_BASIMA"},;	//780
					{"SD1","D1_ALIIMA"},;	//781
					{"SD1","D1_VALFASE"},;	//782
					{"SD1","D1_BASFASE"},;	//783
					{"SD1","D1_ALIFASE"},;	//784
					{"SD2","D2_VALFUND"},;	//785
					{"SD2","D2_BASFUND"},;	//786
					{"SD2","D2_ALIFUND"},;	//787
					{"SD2","D2_VALIMA"},;	//788
					{"SD2","D2_BASIMA"},;	//789
					{"SD2","D2_ALIIMA"},;	//790
					{"SD2","D2_VALFASE"},;	//791
					{"SD2","D2_BASFASE"},;	//792
					{"SD2","D2_ALIFASE"},;	//793
					{"SFT","FT_VALFUND"},;	//794
					{"SFT","FT_BASFUND"},;	//795
					{"SFT","FT_ALIFUND"},;	//796
					{"SFT","FT_VALIMA"},;	//797
					{"SFT","FT_BASIMA"},;	//798
					{"SFT","FT_ALIIMA"},;	//799
					{"SFT","FT_VALFASE"},;	//800
					{"SFT","FT_BASFASE"},;	//801
					{"SFT","FT_ALIFASE"},;	//802
					{"SF3","F3_VALFUND"},;	//803
					{"SF3","F3_VALIMA"},;	//804
					{"SF3","F3_VALFASE"},;	//805
					{"SFT","FT_PRCMEDP"},;	//806
					{"SF3","F3_PRCMEDP"},;	//807
					{"F0R","F0R_INDICE"},;   //808
					{"SF4","F4_INDVF"},;   //809
					{"SFT","FT_INDICE"},;   //810
					{"CFC","CFC_ADICST"},;   //811
					{"SS9","SS9_ADICST"},; //812
					{"SFT","FT_TAFKEY"},;	//813
					{"SF4","F4_AGRPEDG"},;	//814
					{"SFT","FT_VALPEDG"},;	//815
					{"SF3","F3_VALPEDG"},;	//816
					{"CFC","CFC_PICM"},;	//817
					{"SS9","S9_PICM"},;	//818
					{"SB5","B5_VLRCID"},;	//819
					{"SS5","S5_VLRCID"},;	//820
					{"SF4","F4_CSOSN"},;	//821
					{"SFT","FT_CSOSN"},;	//822
					{"SA2","A2_CALCINP"},;	//823
					{"SED","ED_CALCINP"},;	//824
					{"SED","ED_PERCINP"},;	//825
					{"SD1","D1_BASEINP"},;	//826
					{"SFT","FT_BASEINP"},;	//827
					{"SF3","F3_BASEINP"},;	//828
					{"SD1","D1_PERCINP"},;	//829
					{"SFT","FT_PERCINP"},;	//830
					{"SF3","F3_PERCINP"},;	//831
					{"SD1","D1_VALINP"},;	//832
					{"SFT","FT_VALINP"},;	//833
					{"SF3","F3_VALINP"},;	//834
					{"SFT","FT_CNAE"},;     //835
					{"SFT","FT_TRIBMUN"},;  //836
					{"SFT","FT_CLIDEST"},;  //837
					{"SFT","FT_LOJDEST"},;   //838
					{"CE1","CE1_TRIBMU"},;  //839
					{"CE1","CE1_CNAE"},;     //840
					{"CE1","CE1_RMUISE"},;   //841
					{"SBI","BI_TRIBMUN"},;	//842
					{"SB1","B1_TRIBMUN"},;   //843
					{"SS4","S4_TRIBMUN"},;	 //844
					{"SF3","F3_CNAE"},;		 //845
					{"SF3","F3_TRIBMUN"},;	 //846
					{"SF1","F1_ADIANT"},;	 //847
					{"SB1","B1_"+Substr(aSX6[MV_B1PISST],4) },; // 848
					{"SB1","B1_"+Substr(aSX6[MV_B1COFST],4) },; // 849
					{"CFC","CFC_VLICMP"},;	 //850
					{"CFC","CFC_VL_ICM"},;	 //851
					{"SS9","S9_VLICMP"},;	 //852
					{"SS9","S9_VL_ICM"},;	 //853
					{"CDA","CDA_CODREF"},;	 //854
					{"SFT","FT_VOPDIF"},;  //855
					{"SD1","D1_BASEPRO"},;  //856
					{"SD2","D2_BASEPRO"},;  //857
					{"SFT","FT_BASEPRO"},;  //858
					{"SD1","D1_ALIQPRO"},;  //859
					{"SD2","D2_ALIQPRO"},;  //860
					{"SFT","FT_ALIQPRO"},;  //861
					{"SD1","D1_VALPRO"},;  //862
					{"SD2","D2_VALPRO"},;  //863
					{"SFT","FT_VALPRO"},;  //864
					{"SF4","F4_ALIQPRO"},;  //865
					{"SFT","FT_ICMSDIF"},;  //866
					{"SM2", aSX6[MV_INDUPF]},; //867
					{"SD1","D1_BASFEEF"},;  //868
					{"SD2","D2_BASFEEF"},;  //869
					{"SFT","FT_BASFEEF"},;  //870
					{"SD1","D1_ALQFEEF"},;  //871
					{"SD2","D2_ALQFEEF"},;  //872
					{"SFT","FT_ALQFEEF"},;  //873
					{"SD1","D1_VALFEEF"},;  //874
					{"SD2","D2_VALFEEF"},;  //875
					{"SFT","FT_VALFEEF"},;  //876
					{"SF4","F4_ALQFEEF"},;   //877
					{"SFT","FT_NFISCAN"},;  //878
					{"SF3","F3_NFISCAN"},;  //879
					{"SA2","A2_DEDBSPC"},;   //880
					{"SF4","F4_DEDDIF"},;    //881
					{"SF4","F4_FCALCPR"},;   //882
					{"CFC","CFC_VL_ANT"},;   //883
					{"SF4","F4_DIFALPC"},;   //884
					{"SD1","D1_VOPDIF"},;    //885
					{"SD2","D2_VOPDIF"},;    //886
					{"SFT","FT_TES"},;       //887
					{"SA2","A2_TIPORUR"},;    //888
					{"CDA","CDA_GUIA"},;     //889
					{"CDA","CDA_UFGNRE"},; 	//890
					{"CDA","CDA_GNRE"},;   	//891
					{"CC7","CC7_GUIA"},;     //892
					{"SA1","A1_RECIRRF"},;  //893
					{"SBZ",AllTrim(aSX6[MV_PAUTFOB])},; //894
					{"SF4","F4_COLVDIF"},;//895
					{"SFT","FT_COLVDIF"},;//896
					{"SF4","F4_STREDU"},;  //897
					{"SD1","D1_ALFCPST"},;   //898
					{"SD1","D1_BFCPANT"},;   //899
					{"SD1","D1_AFCPANT"},;   //900
					{"SD1","D1_VFCPANT"},;   //901
					{"SD1","D1_ALQNDES"},;   //902
					{"SD2","D2_ALFCPST"},;   //903
					{"SFT","FT_ALFCPST"},;   //904
					{"SFT","FT_BFCPANT"},;   //905
					{"SFT","FT_AFCPANT"},;   //906
					{"SFT","FT_VFCPANT"},;   //907
					{"SFT","FT_ALQNDES"},;   //908
					{"SFT","FT_ALFCCMP"},;   //909
					{"CD2","CD2_BFCP"},;		//910
					{"SD1","D1_ALQFECP"},;   //911
					{"SD2","D2_ALQFECP"},;   //912
					{"SD1","D1_VALFECP"},;   //913
					{"SD2","D2_VALFECP"},;   //914
					{"SD1","D1_VFECPST"},;   //915
					{"SD2","D2_VFECPST"},;   //916
					{"SD1","D1_VFCPDIF"},;   //917
					{"SD2","D2_VFCPDIF"},;   //918
					{"CFC","CFC_BFCPPR"},;	 //919
					{"CFC","CFC_BFCPST"},;	 //920
					{"CFC","CFC_BFCPCM"},;	 //921
					{"CFC","CFC_AFCPST"},;   //922
					{"SD1","D1_BASFECP"},;   //923
					{"SD1","D1_BSFCPST"},;   //924
					{"SD1","D1_BSFCCMP"},;   //925
					{"SD2","D2_BASFECP"},;   //926
					{"SD2","D2_BSFCPST"},;   //927
					{"SD2","D2_BSFCCMP"},;   //928
					{"SFT","FT_BASFECP"},;   //929
					{"SFT","FT_BSFCPST"},;   //930
					{"SFT","FT_BSFCCMP"},;   //931
					{"SD1","D1_FCPAUX"},;    //932
					{"SD2","D2_FCPAUX"},;    //933
					{"SFT","FT_FCPAUX"},;    //934
					{"SF3","F3_CLIDVMC"},;   //935
					{"SF3","F3_LOJDVMC"},;   //936
					{"SFT","FT_CLIDVMC"},;   //937
					{"SFT","FT_LOJDVMC"},;   //938
					{"SF1","F1_DEVMERC"},;   //939
					{"CDA","CDA_ORIGEM"},;   //940
					{"CC7","CC7_CODIPI"},;   //941
					{"CFC","CFC_ALFEEF"},;   //942
					{"SF4","F4_FEEF"},;      //943
					{"SF7","F7_PAUTFOB"},;   //944
					{"CFC","CFC_PAUTFB"},;   //945
					{"SS9","S9_PAUTFOB"},;   //946
					{"SS1","S1_PAUTFOB"},;   //947
					{"SF4","F4_BICMCMP"},;   //948
					{"SBZ","BZ_AFUNDES"},;   //949
					{"SF4","F4_CSENAR"},;    //950
					{"SF4","F4_CINSS"},;     //951
					{"SFT","FT_SECP15"},;    //952
					{"SFT","FT_BSCP15"},;    //953
					{"SFT","FT_ALCP15"},;    //954
					{"SFT","FT_VLCP15"},;    //955
					{"SFT","FT_SECP20"},;    //956
					{"SFT","FT_BSCP20"},;    //957
					{"SFT","FT_ALCP20"},;    //958
					{"SFT","FT_VLCP20"},;    //959
					{"SFT","FT_SECP25"},;    //960
					{"SFT","FT_BSCP25"},;    //961
					{"SFT","FT_ALCP25"},;    //962
					{"SFT","FT_VLCP25"},;    //963
					{"SB1","B1_ALCPESP"},;   //964
					{"SF7","F7_BASCMP"},;    //965
					{"SA2","A2_GROSSIR"},;   //966
					{"SF4","F4_APLREPC"},;   //967
					{"SS6","S6_TRIBMUN"},;	 //968
					{"SBZ","BZ_TRIBMUN"},;	 //969
					{"F3K","F3K_CODREF"},;	 //970
					{"F3K","F3K_CST"},;	 	 //971
					{"CDV","CDV_NUMITE"},;	 //972
					{"CDV","CDV_SEQ"},;	 	 //973
					{"CDV","CDV_TPMOVI"},;	 //974
					{"CDV","CDV_ID"},;	     //975
					{"CDV","CDV_ESPECI"},;	 //976
					{"CDV","CDV_FORMUL"},;	 //977
					{"SF4","F4_INDISEN"},;   //978
					{"SFT","FT_INDISEN"},;	 //979
					{"SFT","FT_INFITEM"},;	 //980
					{"SF4","F4_INFITEM"},;	 //981
					{"SFT","FT_BASECPM"},;	 //982
					{"SFT","FT_ALQCPM"},;	 //983
					{"SFT","FT_VALCPM"},;	 //984
					{"SD2","D2_IDTRIB"},;    //985
					{"SD1","D1_IDTRIB"},;    //986
					{"SFT","FT_IDTRIB"},;    //987
					{"CE0","CE0_TRGEN"},;    //988
					{"SD1","D1_OPER"},;      //989
					{"SFT","FT_BASEFUN"},;   //990 Base Funrural
					{"SFT","FT_VALFUN"},;    //991 Valor Funrural
					{"SFT","FT_ALIQFUN"},;    //992 Alíquota Funrural
					{"SFT","FT_BICEFET"},;//993
					{"SFT","FT_PICEFET"},;//994
					{"SFT","FT_VICEFET"},;//995
					{"SFT","FT_RICEFET"},;//996
					{"SFT","FT_BSTANT"},;//997
					{"SFT","FT_PSTANT"},;//998
					{"SFT","FT_VSTANT"},;//999
					{"SFT","FT_VICPRST"},;//1000
					{"SFT","FT_BFCANTS"},;//1001
					{"SFT","FT_PFCANTS"},;//1002
					{"SFT","FT_VFCANTS"},;//1003
					{"SB1","B1_GRUPO"},; //1004 Grupo de Produtos
					{"SFT","FT_BASECPR"},;//1005 Base Crédito Presumido
					{"CDV","CDV_NFE"},;//1006 Gera codigo ajuste na NFE
					{"CDV","CDV_ZERAVL"},; //1007 Zera valor do ajuste
					{"SFT","FT_DESCFIS"},;//1008 Desconto Fiscal de imposto
					{"SF3","F3_DESCFIS"},;//1009 Desconto Fiscal de imposto
					{"SF7","F7_ALQANT"},;//1010
					{"CFC","CFC_ALQANT"},;//1011
					{"SS9","S9_ALQANT"},;//1012
					{"SS1","S1_ALQANT"},;//1013
					{"F3K","F3K_GRCLAN"},;//1014
					{"F3K","F3K_GRPLAN"},;//1015
					{"F3K","F3K_GRFLAN"},;//1016
					{"F3K","F3K_IFCOMP"},;//1017
					{"F3K","F3K_CODLAN"},;//1018
					{"CDY","CDY_DTINI"},;//1019
					{"CDY","CDY_DTFIM"},;//1020
					{"F2B","F2B_RND"},;    //1021
					{"F3K","F3K_PROD"},;   //1022
					{"F3K","F3K_CFOP"},;   //1023
					{"SF7","F7_GRTRIB"},;  //1024
					{"SF7","F7_GRPCLI"},;  //1025
					{"SS1","S1_GRTRIB"},;  //1026
					{"SF3","F3_CLIEFOR"},; //1027
					{"SF3","F3_LOJA"},;    //1028
					{"F22","F22_CLIFOR"},; //1029
					{"F22","F22_LOJA"},;   //1030
					{"F13","F13_FIMVIG"},; //1031
					{"SE2","E2_CODRET"},;  //1032
					{"SD2","D2_ITEM"},;    //1033
					{"SF3","F3_OBSERV"},;  //1034
					{"SFT","FT_OBSERV"},;  //1035
					{"SA1","A1_CGC"},;     //1036
					{"SF3","F3_NFISCAL"},; //1037
					{"CD2","CD2_ITEM"},;   //1038
					{"CD2","CD2_IMP"},;    //1039
					{"CFC","CFC_CODPRD"},; //1040
					{"CC8","CC8_CODIGO"},; //1041
					{"CC7","CC7_CODLAN"},; //1042
					{"CDA","CDA_NUMITE"},;  //1043
					{"SD1","D1_CTAREC"},;  //1044
					{"SD2","D2_CTAREC"},;  //1045
					{"CDA","CDA_TPNOTA"},; //1046
					{"SS0","S0_BICMCMP"},; //1047
					{"SFT","FT_CRDPCTR"},;  //1048	
					{"CFC","CFC_FCPBSR"},;  //1049
					{"CD2","CD2_PSCFST"},;  //1050	
					{"CD2","CD2_VFCPDI"},;  //1051
					{"CD2","CD2_VFCPEF"},;	//1052	
					{"CFC","CFC_FCPAJT"},;  //1053
					{"CD2","CD2_FCPAJT"},;	//1054
					{"CDA","CDA_REGCAL"},;  //1055
					{"CDA","CDA_VLOUTR"},;  //1056
					{"CDA","CDA_CODMSG"},;  //1057
					{"CDA","CDA_CODCPL"},;  //1058
					{"CDA","CDA_TXTDSC"},;  //1059
					{"CDA","CDA_OPBASE"},;  //1060							
					{"CDA","CDA_OPALIQ"},;  //1061					
					{"CDV","CDV_REGCAL"},;  //1062
					{"CDV","CDV_VLOUTR"},;  //1063
					{"CDV","CDV_CODMSG"},;  //1064
					{"CDV","CDV_CODCPL"},;  //1065
					{"CDV","CDV_TXTDSC"},;  //1066
					{"CDV","CDV_OPBASE"},;  //1067							
					{"CDV","CDV_OPALIQ"},;  //1068
					{"CJA","CJA_FILIAL"},;	//1069
					{"CJA","CJA_ID"},;		//1070
					{"CJA","CJA_CODREG"},;	//1071	
					{"CJA","CJA_ID_CAB"},;	//1072	
					{"CJA","CJA_REGCAL"},;	//1073
					{"CJA","CJA_CODTAB"},;	//1074
					{"CJA","CJA_CODTAB"},;	//1075
					{"CJA","CJA_CODLAN"},;	//1076
					{"CJA","CJA_VIGINI"},;	//1077
					{"CJA","CJA_VIGFIM"},;	//1078
					{"CJA","CJA_NFBASE"},;	//1079
					{"CJA","CJA_NFALIQ"},;	//1080
					{"CJA","CJA_VALOR"},;	//1081
					{"CJA","CJA_VLOUTR"},;	//1082
					{"CJA","CJA_GRGUIA"},;	//1083
					{"CJA","CJA_CODCPL"},;	//1084
					{"CJA","CJA_CODMSG"},;	//1085
					{"CJA","CJA_TXTDSC"},;	//1086
					{"CJA","CJA_GERMSG"},;	//1087
					{"CJ9","CJ9_FILIAL"},;	//1088
					{"CJ9","CJ9_ID"},;		//1089
					{"CJ9","CJ9_CODREG"},;	//1090
					{"CJ9","CJ9_DESCR"},;	//1091
					{"CJ9","CJ9_VIGINI"},;	//1092
					{"CJ9","CJ9_VIGFIM"},;	//1093
					{"CJA","CJA_GUIA"},;	//1094
					{"CJA","CJA_TITULO"},;	//1095
					{"CJA","CJA_TITGUI"},;  //1096
					{"CDA","CDA_AGRLAN"},;  //1097
					{"CDV","CDV_AGRLAN"}}	//1098
					

//  IMPORTANTE: TODA VEZ QUE CRIADO NOVO TRATAMENTO DE FIELDPOS(), DEVERA SER CRIADA A REFERENCIA NA MATXDEF
//  E ADD NO ARRAY aFPCpo DESTA FUNCAO OBRIGATORIAMENTE NA MESMA POSICAO(NUMERO) DO XDEF.CH

For nX := 1 to Len(aFPCpo)
	lV12Only := IIf(Len(aFPCpo[nX]) >= 3, aFPCpo[nX,3], .F.)
	cRelSX3 := IIf(Len(aFPCpo[nX]) >= 4, aFPCpo[nX,4], "")
	nPos := aScan( aAlias , {|x| x[1] == aFPCpo[nX,01] } )
	If nPos == 0
		aAdd( aAlias , { aFPCpo[nX,01] , AliasIndic(aFPCpo[nX,01]) } )
		nPos := Len(aAlias)
	EndIf
	aAdd(aRet , IIf( xFisVldRel(cVersao, cRPORel, lV12Only, cRelSX3) .And. aAlias[nPos,02] .And. (aFPCpo[nX,01])->(FieldPos(aFPCpo[nX,02])) > 0 , .T. , .F. ) )
Next nX

Return aRet

/******************************************************* FUNCOES ESPECIFICAS ***************************************************
*																																				 *
*                         					  Funcoes retiradas do MATXFIS em 10/02/2015                                         *
* 																																				 *
********************************************************************************************************************************/


/*/
±±³Funcao    ³xFisLdImp ³ Autor ³ Eduardo Riera         ³ Data ³20.08.2003³±±
±±³Descri‡…o ³Demonstra os impostos tratados pelo sistema                 ³±±
±±³Retorno   ³ExpA1: Array com os impostos no formato:                    ³±±
±±³          ³       [1] Codigo do imposto                                ³±±
/*/
Function xFisLdImp()

Local aCodImp := {}
Local nX      := 0

aadd(aCodImp,"ICM")
aadd(aCodImp,"IPI")
aadd(aCodImp,"ICA")
aadd(aCodImp,"SOL")
aadd(aCodImp,"CMP")
aadd(aCodImp,"ISS")
aadd(aCodImp,"IRR")
aadd(aCodImp,"INS")
aadd(aCodImp,"COF")
aadd(aCodImp,"CSL")
aadd(aCodImp,"PIS")
aadd(aCodImp,"PS2")
aadd(aCodImp,"CF2")
aadd(aCodImp,"RUR")
aadd(aCodImp,"CPB")

For nX := 1 To NMAXIV
	aadd(aCodImp,"IV"+StrZero(nX,1))
Next nX

Return(aCodImp)

/*/
±±³Funcao    ³xFisRefLd³ Autor ³ Eduardo Riera         ³ Data ³20.08.2003³±±
±±³Descri‡…o ³Demonstra as referencias dos impostos de uma tabela         ³±±
±±³Retorno   ³ExpA1: Array com os impostos no formato:                    ³±±
±±³          ³       [1] Codigo do imposto                                ³±±
±±³          ³       [2] Campo da Base do imposto                         ³±±
±±³          ³       [3] Campo da Aliquota do imposto                     ³±±
±±³          ³       [4] Campo do Valor do imposto                        ³±±
±±³Parametros³ExpC1: Alias do arquivo                                     ³±±
±±³          ³ExpC2: Tipo de Imposto                                      ³±±
±±³          ³       "IT" - Por item                                      ³±±
±±³          ³       "NF" - Por documento                                 ³±±
/*/
Function xFisRefLd(cAlias,cTipo)

Local aArea       := GetArea()
Local aReferencia := MaFisSXRef(cAlias)
Local aImposto    := {}
Local aCodImp     := {}
Local nX          := 0
Local nY          := 0

DEFAULT cTipo := "IT"

aadd(aCodImp,"ICM")
aadd(aCodImp,"IPI")
aadd(aCodImp,"ICA")
aadd(aCodImp,"SOL")
aadd(aCodImp,"CMP")
aadd(aCodImp,"ISS")
aadd(aCodImp,"IRR")
aadd(aCodImp,"INS")
aadd(aCodImp,"COF")
aadd(aCodImp,"CSL")
aadd(aCodImp,"PIS")
aadd(aCodImp,"PS2")
aadd(aCodImp,"CF2")
aadd(aCodImp,"RUR")
aadd(aCodImp,"FET")
aadd(aCodImp,"FAB")
aadd(aCodImp,"FAC")
aadd(aCodImp,"INA")
aadd(aCodImp,"CID")
aadd(aCodImp,"CPM")
aadd(aCodImp,"FMP")
aadd(aCodImp,"FMD")
aadd(aCodImp,"CPB")

For nX := 1 To NMAXIV
	aadd(aCodImp,"IV"+StrZero(nX,1))
Next nX

aadd(aCodImp,"PS3")
aadd(aCodImp,"CF3")

For nX := 1 To Len(aCodImp)
	aadd(aImposto,{aCodImp[nX],0,0,0})
	nY := aScan(aReferencia,{|x| x[2]=cTipo+"_BASE"+aCodImp[nX]})
	If nY <> 0
		aImposto[nX][2] := aReferencia[nY][1]
	EndIf
	nY := aScan(aReferencia,{|x| x[2]=cTipo+"_ALIQ"+aCodImp[nX]})
	If nY <> 0
		aImposto[nX][3] := aReferencia[nY][1]
	EndIf
	nY := aScan(aReferencia,{|x| x[2]=cTipo+"_VAL"+aCodImp[nX]})
	If nY <> 0
		aImposto[nX][4] := aReferencia[nY][1]
	EndIf
Next nX

RestArea(aArea)

Return(aImposto)

/*
±±³Funcao    xFisDc5602 ³ Autor ³Erick G. Dias          ³ Data ³20/08/2013³±±
±±³Descri‡…o ³Função que irá verificar se o item terá ou não a isenção    ³±±
±±³          ³de PIS e COFINS conforme o decreto 5602,ou não a isenção    ³±±
±±³Descri‡…o ³Função que irá verificar se o item terá ou não a isenção    ³±±
*/

Function xFisDc5602(nVlItem,cNCM,cCodNat,aSX6)
Return FISXDC5602(nVlItem,cNCM,cCodNat,aSX6)

/*
±±³Funcao    ³xFisSitTri ³ Autor ³                       ³ Data ³         ³±±
±±³Descri‡…o ³                                                            ³±±*/
Function xFisSitTri(aSX6,aPos)

If FindFunction("FISXSITTRI")
	Return FISXSITTRI(aSX6,aPos)
Else
	MaFisFinal(STR0055 + CRLF + CRLF + "FISXICMS.PRW")
EndIF

Return ""

/*±±³Fun‡…o    ³ xFisSBCpo    ³ Autor ³ Alexandre Lemes   ³ Data ³06/12/2012³±±
  ±±³Descri‡…o ³ Retorna o Conteudo do Campo Dependendo do Alias Informado. ³±±
  ±±³          ³ O Front Loja Utiliza o Arquivo SBI Como Arq. de Produtos.  ³±±*/
Function xFisSBCpo(cNome, aSX6, cAliasPROD, cCpoSBZ)

Local aArea      := GetArea()
Local nPosSB1    := 0
Local nPosSBI    := 0
Local nPosSBZ    := 0
Local xValor     := Nil
Local lExistSBZ  := .F.

If cAliasPROD == "SB1" .And. aSX6[MV_ARQPROD] == "SBZ" // Se existir registro no SBZ (Indicadores de Produtos) busca as informacoes desta tabela
	SBZ->(dbSetOrder(1))
	lExistSBZ := SBZ->( MsSeek( xFilial("SBZ") + SB1->B1_COD ) )
	nPosSBZ   := SBZ->( FieldPos( "BZ_" + cNome ) )
	If lExistSBZ .And. cNome $ cCpoSBZ .And. nPosSBZ > 0 .And. IIf( aSX6[MV_ARQPROP] , !Empty(SBZ->(FieldGet( nPosSBZ ))) , .T. )
		xValor := SBZ->( FieldGet( nPosSBZ ) )
	Else
		xValor := SB1->( FieldGet( FieldPos( "B1_"+cNome ) ) )
	EndIf
Else
	If cAliasPROD <> "SB1" .And. !Empty( nPosSBI := (cAliasPROD)->(FieldPos( Right(cAliasPROD,2) + "_" + cNome ) ) )
		xValor := (cAliasPROD)->( FieldGet( nPosSBI ) )
	ElseIf !Empty( nPosSB1 := SB1->(FieldPos( "B1_"+cNome ) ) )
		xValor := SB1->( FieldGet( nPosSB1 ) )
	EndIf
EndIf

Restarea(aArea)

Return(xValor)

/*
±±³Funcao     ³xFisRtComp     ³ Autor ³ Luciana Pires        ³ Data ³ 09.04.2008 ³±±
±±³Descricao  ³Retorna os valores da nota fiscal de complemento de ICMS       ³±±
±±³Parametros ³cAlOri   - Defino Alias da tabela pelo tipo (se Cliente/Forn)  ³±±
*/
Function xFisRtComp(cAlOri,nRecOri,aSX6)
If FindFunction("FISXRTCOMP")
	Return FISXRTCOMP(cAlOri,nRecOri,aSX6)
EndIf
Return(.F.)

/*/
±±³Funcao    ³xFisAvTes³ Autor ³ Edson Maricate         ³ Data ³02.02.2000³±±
±±³Descri‡…o ³Verifica se o TES pode ser utilizada na operacao.           ³±±
±±³Parametros³ExpC1: Tipo de movimentacao - E Entrada ou Saida            ³±±
±±³          ³ExpC2: Codigo da TES                                        ³±±
/*/
Function xFisAvTes(cOperacao,cTes)

Local lRet := .T.

Do Case
	Case cOperacao == "E"
		If SubStr(cTes,1,1) >= "5" .And. cTES <> "500"
			HELP("   ",1,"INV_TE")
			lRet := .F.
		EndIf
	Case cOperacao == "S"
		If !SubStr(cTes,1,1) >= "5" .Or. cTES == "500"
			HELP("   ",1,"INV_TS")
			lRet := .F.
		EndIf
EndCase

Return lRet
 
/*±±³Programa  ³xFisCDA  ³ Autor ³ Gustavo G. Rueda      ³ Data ³13/12/2007³±±
  ±±³Descri‡…o ³Funcao de gravacao/exclusao das informacoes do documento    ³±±
  ±±³          ³ fiscal referente ao lancamento fiscal da apuracao de icms. ³±±
  ±±³Parametros³nItem -> Numero do item                                     ³±±
  ±±³          ³nTipo -> Tipo de processamento da funcao MaFisAjIt          ³±±
  ±±³          ³lExclui -> Flag de exclusao.                                ³±±
  ±±³          ³cChaveSF -> Chave para posicionamento do CDA                ³±±
  ±±³          ³cFormul -> Indicado de formulario proprio                   ³±±
  ±±³          ³cAlias -> Alias da tabela utilizada para gravar o CDA.      ³±±*/
Function xFisCDA(nItem,nTipo,lExclui,cChaveSF,cFormul,cAlias,aDic,aPos,aNfItem,lReproc,aFunc)

Local	aGrava	 :=	{}
Local	cTpMov	 :=	"S"
Local	lRet	 :=	.F.
Local	nI		 :=	0
Local 	lCpoGNRE := aPos[FP_CDA_GNRE] .And. aPos[FP_CDA_UFGNRE]
Local 	aArea    := {}
Local   lCpoCDV  := aPos[FP_CDV_NFE] .And. aPos[FP_CDV_ZERAVL] .AND. aFunc[FF_RETINFCDY]//FindFunction("RetInfCDY")
Local   aCpoCDV	 := {}
Local	lCdaCof	 := ExecCja(aPos)

Default nItem	 := Nil
Default lExclui	 := .F.
Default cChaveSF	 := SF2->("S"+F2_ESPECIE+"S"+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
Default cFormul	 := "S"
Default cAlias	 := "SF2"
Default lReproc  := .F.

If !aDic[AI_CDA]
	Return lRet
EndIf

cTpMov := Left(cChaveSF,1)

// Reprocessamento:
// - Só exclui os lançamentos que não foram incluidos manualmente (CDA_CALPRO == "1") pois
// a CDA será gravada a partir do TES e, neste caso, os lançamentos manuais não seriam gerados novamente.
// - Só exclui os lancamentos que nao geraram GNRE pois a GNRE nao sera gerada quando
// a CDA for gravada novamente, o que poderia ocasionar divergencias entre a GNRE e a CDA.

If lExclui
	If CDA->(MsSeek(xFilial("CDA")+cChaveSF))
		While !CDA->(Eof()) .And. xFilial("CDA")+cChaveSF == CDA->(CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA) .And. ;
			IIf(lReproc .And. lCpoGNRE, Empty(CDA->CDA_GNRE) .And. Empty(CDA->CDA_UFGNRE), .T.)
			If (lReproc .And. CDA->CDA_CALPRO == "1") .Or. !lReproc
				RecLock("CDA",.F.)
				CDA->(dbDelete())
				MsUnLock()
				CDA->(FkCommit())
			EndIf
			CDA->(dbSkip())
		EndDo
	EndIf
Else
	aGrava	:=	MaFisAjIt(nItem,nTipo)
	For nI := 1 To Len(aGrava)
		iF Len(aGrava[nI]) >= 14 .And. aGrava[nI,14] == "4"
			Loop
		Endif
		If CDA->(MsSeek(xFilial("CDA")+cChaveSF+PadR(aGrava[nI,1],GTamMxFis(TAM_CDA_NUMITE))+aGrava[nI,7]))
			RecLock("CDA",.F.)
			If aPos[FP_CDA_TPNOTA] 
				If cTpMov == "S" .AND. CDA->CDA_TPNOTA <> (cAlias)->F2_TIPO
					CDA->CDA_TPNOTA := (cAlias)->F2_TIPO
				ElseIf cTpMov <> "S" .AND. CDA->CDA_TPNOTA <> (cAlias)->F1_TIPO
					CDA->CDA_TPNOTA := (cAlias)->F1_TIPO
				EndIf
			EndIf
		Else
			RecLock("CDA",.T.)
			CDA->CDA_FILIAL	:=	xFilial("CDA")
			CDA->CDA_TPMOVI	:=	cTpMov
			CDA->CDA_FORMUL	:=	cFormul
			If cTpMov=="S"
				CDA->CDA_ESPECI	:= (cAlias)->F2_ESPECIE
				CDA->CDA_NUMERO	:= (cAlias)->F2_DOC
				SerieNfId("CDA",1,"CDA_SERIE",,,,(cAlias)->F2_SERIE )
				CDA->CDA_CLIFOR	:= (cAlias)->F2_CLIENTE
				CDA->CDA_LOJA	:= (cAlias)->F2_LOJA
				
				If aPos[FP_CDA_TPNOTA] 
					CDA->CDA_TPNOTA := (cAlias)->F2_TIPO
				EndIf
			Else
				CDA->CDA_ESPECI	:= (cAlias)->F1_ESPECIE
				CDA->CDA_NUMERO	:= (cAlias)->F1_DOC
				SerieNfId("CDA",1,"CDA_SERIE",,,,(cAlias)->F1_SERIE )
				CDA->CDA_CLIFOR	:= (cAlias)->F1_FORNECE
				CDA->CDA_LOJA	:= (cAlias)->F1_LOJA
				If aPos[FP_CDA_TPNOTA] 
					CDA->CDA_TPNOTA := (cAlias)->F1_TIPO
				EndIf
			EndIf
			CDA->CDA_NUMITE	:=	PadR(aGrava[nI,1],GTamMxFis( TAM_CDA_NUMITE))
			CDA->CDA_SEQ	:=	aGrava[nI,7]
			If aPos[FP_CDA_VL197]
				CDA->CDA_VL197 :=  aGrava[nI,10]
			EndIf
		EndIf
		CDA->CDA_CODLAN	:=	aGrava[nI,2]
		CDA->CDA_CALPRO	:=	aGrava[nI,3]
		CDA->CDA_BASE	:=	aGrava[nI,4]
		CDA->CDA_ALIQ	:=	aGrava[nI,5]
		CDA->CDA_VALOR	:=	aGrava[nI,6]
		If aPos[FP_CDA_IFCOMP]
			CDA->CDA_IFCOMP	:= aGrava[nI,8]
		EndIf
		If aPos[FP_CDA_TPLANC]
			CDA->CDA_TPLANC	:= aGrava[nI,9]
		EndIf
		If aPos[FP_CDA_CLANC]
			CDA->CDA_CLANC	:= aGrava[nI,11]
		EndIf
		IF aPos[FP_CDA_CODREF]
			CDA->CDA_CODREF := aGrava[nI,12]
		Endif
		If aPos[FP_CDA_GUIA]
			CDA->CDA_GUIA := aGrava[nI,13]
		EndIf
		If aPos[FP_CDA_ORIGEM]
			CDA->CDA_ORIGEM := aGrava[nI,14]
		EndIf

		If lCdaCof .And. Len(aGrava[nI]) > 17
			CDA->CDA_TXTDSC := aGrava[nI,18]
			CDA->CDA_CODCPL := aGrava[nI,19]
			CDA->CDA_CODMSG := aGrava[nI,20]
			CDA->CDA_VLOUTR := aGrava[nI,21]
			CDA->CDA_REGCAL := aGrava[nI,22]
			CDA->CDA_OPBASE	:= aGrava[nI,23]
			CDA->CDA_OPALIQ := aGrava[nI,24]
			CDA->CDA_AGRLAN := aGrava[nI,25]
		Endif						
		MsUnLock()
		CDA->(FkCommit())
	Next nI

	//Tratamento para deletar os registros que nao foram reaproveitados acima no caso de reutilizacao de numeracao de nota
	If ValType(aNfItem) == "A"
		If CDA->(MsSeek(xFilial("CDA")+cChaveSF))
			While !CDA->(Eof()) .And. CDA->(CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA) == xFilial("CDA")+cChaveSF
				If aScan(aNfItem, {|x| AllTrim(x[IT_ITEM]) == AllTrim(CDA->CDA_NUMITE)}) == 0
					RecLock("CDA",.F.)
					CDA->(dbDelete())
					MsUnLock()
					CDA->(FkCommit())
				EndIf
				CDA->(dbSkip())
			EndDo
		EndIf
	EndIf

EndIf

If aDic[AI_CDV] .And. aPos[FP_CDV_NUMITE] .And. aPos[FP_CDV_SEQ] .And. aPos[FP_CDV_TPMOVI] .And. ;
aPos[FP_CDV_ID] .And. aPos[FP_CDV_ESPECI] .And. aPos[FP_CDV_FORMUL] .And. !Empty(CDV->(IndexKey(4)))
	aArea  	:= GetArea()
	dbSelectArea("CDV")
	CDV->(dbSetOrder(4))
	If lExclui
		If CDV->(MsSeek(xFilial("CDV")+cChaveSF))
			While !CDV->(Eof()) .And. xFilial("CDV")+cChaveSF == CDV->(CDV_FILIAL+CDV_TPMOVI+CDV_ESPECI+CDV_FORMUL+CDV_DOC+CDV_SERIE+CDV_CLIFOR+CDV_LOJA) .And. ;
					IIf(lReproc, CDV->CDV_AUTO == "1", .T.)
				RecLock("CDV",.F.)
				CDV->(dbDelete())
				MsUnLock()
				CDV->(FkCommit())
				CDV->(dbSkip())
			EndDo
		EndIf
	Else

		//Grava CDV
		For nI := 1 To Len(aGrava)
			iF Len(aGrava[nI]) >= 14 .And. aGrava[nI,14] <> "4"
				Loop
			Endif

			If CDV->(MsSeek(xFilial("CDV")+cChaveSF+PadR(aGrava[nI,1],GTamMxFis( TAM_CDV_NUMITE))+aGrava[nI,7]))
				RecLock("CDV",.F.)
			Else
				RecLock("CDV",.T.)
				CDV->CDV_FILIAL	:=	xFilial("CDV")
				CDV->CDV_TPMOVI	:=	cTpMov
				CDV->CDV_AUTO	:=	"1"
				CDV->CDV_FORMUL	:=	cFormul
				CDV->CDV_NUMITE	:=	PadR(aGrava[nI,1],GTamMxFis( TAM_CDV_NUMITE))
				CDV->CDV_SEQ	:=	aGrava[nI,7]
				If cTpMov=="S"
					CDV->CDV_ESPECI	:= (cAlias)->F2_ESPECIE
					CDV->CDV_DOC	:= (cAlias)->F2_DOC
					SerieNfId("CDV",1,"CDV_SERIE",,,,(cAlias)->F2_SERIE )
					CDV->CDV_CLIFOR	:= (cAlias)->F2_CLIENTE
					CDV->CDV_LOJA	:= (cAlias)->F2_LOJA
					CDV->CDV_PERIOD	:=	SubStr(DtoS((cAlias)->F2_EMISSAO),1,6)
				Else
					CDV->CDV_DOC	:= (cAlias)->F1_DOC
					CDV->CDV_ESPECI	:= (cAlias)->F1_ESPECIE
					SerieNfId("CDV",1,"CDV_SERIE",,,,(cAlias)->F1_SERIE )
					CDV->CDV_CLIFOR	:= (cAlias)->F1_FORNECE
					CDV->CDV_LOJA	:= (cAlias)->F1_LOJA
					CDV->CDV_PERIOD	:=	SubStr(DtoS((cAlias)->F1_EMISSAO),1,6)
				EndIf
			EndIf
			CDV->CDV_CODAJU	:=	aGrava[nI,2]
			CDV->CDV_VALOR	:=	aGrava[nI,6]
			CDV->CDV_CFOP	:=	aGrava[nI,15]
			CDV->CDV_LIVRO	:=	aGrava[nI,16]
			CDV->CDV_DESCR	:=	aGrava[nI,17]
			CDV->CDV_ID		:=	FWUUID("FISA140")

			If lCdaCof .And. Len(aGrava[nI]) > 17
				CDV->CDV_TXTDSC := aGrava[nI,18]
				CDV->CDV_CODCPL := aGrava[nI,19]
				CDV->CDV_CODMSG := aGrava[nI,20]
				CDV->CDV_VLOUTR := aGrava[nI,21]
				CDV->CDV_REGCAL := aGrava[nI,22]
				CDV->CDV_OPBASE	:= aGrava[nI,23]
				CDV->CDV_OPALIQ := aGrava[nI,24]
				CDV->CDV_AGRLAN := aGrava[nI,25]						
			Endif	

			If lCpoCDV
				aCpoCDV := RetInfCDY(aGrava[nI,2])
				CDV->CDV_NFE    := aCpoCDV[1,1]
				CDV->CDV_ZERAVL := aCpoCDV[1,2]
			EndIf

			MsUnLock()
			CDV->(FkCommit())
		Next nI


		//Tratamento para deletar os registros que nao foram reaproveitados acima no caso de reutilizacao de numeracao de nota
		If ValType(aNfItem) == "A"
			If CDV->(MsSeek(xFilial("CDV")+cChaveSF))
				While !CDV->(Eof()) .And. xFilial("CDV")+cChaveSF == CDV->(CDV_FILIAL+CDV_TPMOVI+CDV_ESPECI+CDV_FORMUL+CDV_DOC+CDV_SERIE+CDV_CLIFOR+CDV_LOJA)
					If aScan(aNfItem, {|x| AllTrim(x[IT_ITEM]) == AllTrim(CDV->CDV_NUMITE)}) == 0
						RecLock("CDV",.F.)
						CDV->(dbDelete())
						MsUnLock()
						CDV->(FkCommit())
					EndIf
					CDV->(dbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
	CDV->(dbCloseArea())
	RestArea(aArea)
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³xFisGetRF³ Autor ³ Eduardo Riera         ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avalicao das referencias existentes em uma         ³±±
±±³          ³expressao string.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Expressao contendo as referencias.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array com a seguinte estrutura                        ³±±
±±³          ³       [1] Codigo da Referencia                              ³±±
±±³          ³       [2] Nome do programa vinculado a referencia           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo verificar e retornar as referen³±±
±±³          ³cias da funcao fiscal com base numa expressao string.        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function xFisGetRF(cValid)

Local nPRefer := 0
Local cRefer  := ""
Local cProg   := ""

cValid	:= Upper(StrTran(cValid," ",""))

Do Case
Case ( "MAFISREF"$cValid )
	nPRefer := AT('MAFISREF("',cValid) + 10
	cValid  := SubStr(cValid,nPRefer)
	cRefer  := SubStr(cValid,1,AT(',',cValid)-2)
	cValid  := SubStr(cValid,AT(',',cValid)+1)
	cProg   := SubStr(cValid,2,AT(',',cValid)-3)
Case ( "MAFISGET"$cValid )
	nPRefer := AT('MAFISGET("',cValid) + 10
	cValid  := SubStr(cValid,nPRefer)
	cRefer  := SubStr(cValid,1,AT(')',cValid)-2)
EndCase

Return({cRefer,cProg})

/*/
±±³Fun‡…o    ³xFisRelImp³ Autor ³ Edson Maricate       ³ Data ³21.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array contendo todos os impostos suportados pelos³±±
±±³          ³arquivos passados para a funcao.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Codigo de referencia ao programa                    ³±±
±±³          ³ExpA2 : Array contendo o Alias dos arquivos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103,MATA116,MATA119,MATA150,MATA120,MATA930             ³±±
/*/
Function xFisRelImp(cProg,aAlias,aSX6,aRefSX3)

Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())
Local aRet		:= {}
Local nX        := 0
Local nY        := 0

Local aSX3Fields:= {}
Local cX3Valid	:= ""

DEFAULT aRefSX3 := {}

For nX := 1 to Len(aAlias)

	If aScan(aRefSX3,{|x| x[1] == aAlias[nX]}) == 0 // Verifica se o alias solicitado esta no cache de memoria e adiciona as referencia ao cache de memoria
		aSX3Fields := FWSX3Util():GetAllFields( aAlias[nX] , .F. )

		For nY := 1 To Len( aSX3Fields )
			cX3Valid := GetSx3Cache(AllTrim(aSX3Fields[nY]),"X3_VALID")

			If "MAFISREF" $ AllTrim( UPPER( cX3Valid ) )
				If !( AllTrim( aSX3Fields[nY] ) == "F1_II" .AND. ( "MAFISREF" $ cX3Valid ) .AND. aSX6[MV_EASY] == "S" )
					aadd( aRefSX3 , { aAlias[nX] , AllTrim( aSX3Fields[nY] ) , xFisGetRF(cX3Valid)[1] } )
				EndIf
			EndIf
		Next
	EndIf

	For nY := 1 To Len(aRefSX3) // Obtem as referencias do cache de memoria
		If aRefSx3[nY][1] == aAlias[nX]
			aadd( aRet , { aAlias[nX] , aRefSx3[nY][2] , aRefSx3[nY][3] } )
		EndIf
	Next nY

Next nX

RestArea(aAreaSX3)
RestArea(aArea)

Return aRet

/*±±³Funcao    ³MaFisImpLd³ Autor ³ Eduardo Riera         ³ Data ³11.08.2003³±±
  ±±³Descri‡…o ³Carregar os valores de impostos gravados em um arquivo      ³±±
  ±±³Retorno   ³ExpA1: Array com os impostos no formato:                    ³±±
  ±±³          ³       [1] Codigo do imposto                                ³±±
  ±±³          ³       [2] Base do imposto                                  ³±±
  ±±³          ³       [3] Aliquota do imposto                              ³±±
  ±±³          ³       [4] Valor do imposto                                 ³±±
  ±±³Parametros³ExpC1: Alias do arquivo                                     ³±±
  ±±³          ³ExpC2: Tipo de Imposto                                      ³±±
  ±±³          ³       "IT" - Por item                                      ³±±
  ±±³          ³       "NF" - Por documento                                 ³±±*/
Function xFisImpLd(cAlias,cTipo,cCursor)

Local aArea       := GetArea()
Local aReferencia := MaFisSXRef(cAlias)
Local aImposto    := {}
Local aCodImp     := {}
Local nX          := 0
Local nY          := 0

DEFAULT cTipo   := "IT"
DEFAULT cCursor := cAlias

aadd(aCodImp,"ICM")
aadd(aCodImp,"IPI")
aadd(aCodImp,"ICA")
aadd(aCodImp,"SOL")
aadd(aCodImp,"CMP")
aadd(aCodImp,"ISS")
aadd(aCodImp,"IRR")
aadd(aCodImp,"INS")
aadd(aCodImp,"COF")
aadd(aCodImp,"CSL")
aadd(aCodImp,"PIS")
aadd(aCodImp,"PS2")
aadd(aCodImp,"CF2")
aadd(aCodImp,"RUR")
aadd(aCodImp,"FET")
aadd(aCodImp,"FAB")
aadd(aCodImp,"FAC")
aadd(aCodImp,"INA")
aadd(aCodImp,"CPB")

For nX := 1 To NMAXIV
	aadd(aCodImp,"IV"+StrZero(nX,1))
Next nX

For nX := 1 To Len(aCodImp)
	aadd(aImposto,{aCodImp[nX],0,0,0})
	nY := aScan(aReferencia,{|x| x[2]=cTipo+"_BASE"+aCodImp[nX]})
	If nY <> 0
		aImposto[nX][2] := (cCursor)->(FieldGet(FieldPos(aReferencia[nY][1])))
	EndIf
	nY := aScan(aReferencia,{|x| x[2]=cTipo+"_ALIQ"+aCodImp[nX]})
	If nY <> 0
		aImposto[nX][3] := (cCursor)->(FieldGet(FieldPos(aReferencia[nY][1])))
	EndIf
	nY := aScan(aReferencia,{|x| x[2]=cTipo+"_VAL"+aCodImp[nX]})
	If nY <> 0
		aImposto[nX][4] := (cCursor)->(FieldGet(FieldPos(aReferencia[nY][1])))
	EndIf
Next nX

nY := 0

For nX := 1 To Len(aImposto)
	If !Empty(aImposto[nX])
		If aImposto[nX][4] == 0
			aImposto := aDel(aImposto,nX)
			nX--
		Else
			nY++
		EndIf
	EndIf
Next nX

aImposto := aSize(aImposto,nY)
RestArea(aArea)

Return(aImposto)

/*/
MaFisAtuSF3 - Edson Maricate-21.02.2000
Esta rotina tem como objetivo atualizar os livros fiscais com base em uma nota fiscal de entrada ou saida.
/*/
Function xFisAtuSF3(nCaso, cTpOper, nRecNF, cAlias, cPDV, cCNAE, cFunOrig, nCD2, cCodSef, cSerSat, cNfisCanc, aNFCab, aNFItem, cAliasPROD, aPE, aSX6, aDic, aPos, cCodRet, cProtoc, cDescRet, aFunc, aInfNat )

Local aArea		:= GetArea()
Local aAreaSF1	:= SF1->(GetArea())
Local aAreaSF2	:= SF2->(GetArea())
Local aLivro	:= {}
Local aFixos 	:= {}
Local aRecSF3	:= {}
Local aRecSFT   := {}
Local aSF3      := {}
Local aSFT      := {}
Local alAreaX   := {}
Local alAreaY   := {}
Local cConceptF3 := ""
Local aNFEletr	:= {"",cTod(""),"","",0,""}
Local cCtaCont	:= ""
Local cCliFor	:= ""
Local cLoja		:= ""
Local cNumNF	:= ""
Local cSerie	:= ""
Local dDEmissao	:= ""
Local cEspecie	:= ""
Local cFormul	:= ""
Local cQuery    := ""
Local cTpVent	:= ""
Local cCAE		:= ""
Local cChvNfe	:= ""
Local cClieForn := ""
Local cLojac    := ""
Local cSeriec   := ""
Local cNfAgreg  := ""
Local cAliasSF3 := "SF3"
Local cAliasSFT := "SFT"
Local cAliasCD2 := "CD2"
Local dEntrada	:= Ctod("")
Local dDtCAE	:= Ctod("")
Local nVlrTotal	:= 0
Local nY        := 0
Local nX        := 0
Local nZ        := 0
Local nA        := 0
Local nPautaPis := 0
Local nPautaCof := 0
Local nlBsIGVSF3:= 0
Local nPosTesX  := 0
Local nPosConc := 0
Local cDesConc := ""
Local nB       := 0
Local lObserv	:= .F.
Local lQuery    := .F.
Local lIsenEP	:= .F.
Local lNFEletr	:= .F.
Local lNFEArg	:= .F.
Local lSped		:= cPaisLoc == "BRA" .And. aDic[AI_SFU] .And. aDic[AI_SFX] .And. aDic[AI_CD3] .And.;
					aDic[AI_CD4] .And. aDic[AI_CD5] .And. aDic[AI_CD6] .And. aDic[AI_CD7] .And.;
					aDic[AI_CD8] .And. aDic[AI_CD9] .And. aDic[AI_CDC] .And. aDic[AI_CDD] .And.;
					aDic[AI_CDE] .And. aDic[AI_CDF] .And. aDic[AI_CDG]
Local lChvNfe	:= .F.
Local lNfagrSF2 := IIf(aPos[FP_F2_NFAGREG] ,.T.,.F.) // Numero NF Agregada
Local lNfagrSF3 := IIf(aPos[FP_F3_NFAGREG] ,.T.,.F.) // Numero NF Agregada
Local lTipFoSFP := IIf(aPos[FP_FP_TIPOFOR] ,.T.,.F.) // Tipo de formulario
Local lQtdItSFP := IIf(aPos[FP_FP_QTDITEM] ,.T.,.F.) // Qtde de item na Nota fiscal
Local lProcArg  := .F. // se é processo da Argentina para gerar varias faturas
Local cItemNF	:= StrZero(0,GTamMxFis( TAM_D2_ITEM ),0)			// Item da NF
Local lIcmSTTran:= .F.
Local lIndicSFT := aDic[AI_SFT]
Local nFecRN 	:=0
Local nFecStRn  :=0
Local lTAFVldAmb := aFunc[FF_TAFVLDAMB] .and. aFunc[FF_EXTTAFFEXC] .and. TAFVldAmb("1")
Local lVldIntTAF:= .T.
Local aAreaSL1    := {}
Local lLegislacao := ""
Local cAliasReproc:= ""
Local cLjEspecie  := ""
Local cCliDvMc    := ""
Local cLojDvMc    := ""
Local cMvDvMc    := aSX6[MV_DEVMERC]
Local aDevMerc	:= {}
Local cMV_ESTADO:= ""
Local cCltdest	:= ""
Local cDbType  	:= AllTrim(Upper(TcGetDb()))
Local lCJ3		:= aDic[AI_CIN] .AND. aDic[AI_CJ3] .AND. aFunc[FF_FISGRVCJ3]  //FindFunction("FisGrvCJ3")
Local lCJM		:= aDic[AI_CJM] .AND. aFunc[FF_GETCOMPULTAQ] .AND. aFunc[FF_FISDELCJM] .AND. aFunc[FF_GETULTAQUI]
Local nTrbGen	:= 0
Local nCpoIPM   := 3
Local lExecCja	:= ExecCja(aPos)

//Adicionado a busca das referências da SFT aqui e como static para q n fique a todo momento buscando
if aWriteSFT==Nil .and. cPaisLoc == "BRA"
	aWriteSFT:= MaFisRelImp("MT100",{"SFT"})
endif

If cPaisLoc == "ARG" .And. lNfagrSF2 .And. lNfagrSF3 .And. lTipFoSFP .And. lQtdItSFP ;
	.And. AllTrim(FunName())$"MATA465N|MATA467N|MATA468N" .And. aSX6[MV_CTRLFOL]
	lProcArg := .T. // se é processo da Argentina para gerar varias faturas
Endif

DEFAULT cPDV    := ""
DEFAULT cCNAE   := ""
DEFAULT cFunOrig:= ""
DEFAULT nCD2	:= 0
DEFAULT cCodSef := ""
DEFAULT cCodRet := ""
DEFAULT cProtoc := ""
DEFAULT cDescRet:= ""
DEFAULT cSerSat := ""
DEFAULT cNfisCanc := ""

If !Empty(cSerSat)
	aNFCab[NF_SERSAT] := cSerSat
EndIf

cAliasReproc:= Iif( cFunOrig == "MATA930", cAlias , "SF2" )

Do Case
Case cTpOper == "E"
	If Empty(cAlias)
		cAlias := "SF1"
		dbSelectArea("SF1")
		MsGoto(nRecNF)
	EndIf
	cCliFor	 := (cAlias)->F1_FORNECE
	cLoja	 := (cAlias)->F1_LOJA
	cNumNF	 := (cAlias)->F1_DOC
	cSerie	 := (cAlias)->F1_SERIE
	dDEmissao:= (cAlias)->F1_EMISSAO
	cEspecie := (cAlias)->F1_ESPECIE
	cFormul	 := (cAlias)->F1_FORMUL
	dEntrada := (cAlias)->F1_DTDIGIT

	If aPos[FP_F1_DEVMERC] .And. (cAlias)->F1_DEVMERC == 'S' .And. !Empty(aSX6[MV_DEVMERC])
		aDevMerc := STRTOKARR(cMvDvMc,';')
		cCliDvMc := aDevMerc[1]
		cLojDvMc := aDevMerc[2]
	Endif

	//Integracao Protheus x TAF - NATIVA.
	//A instrucao impede que documentos fiscais de entrada de terceiros
	//F1_FORMUL <> "S" ao serem excluidos, chame desnecessariamente
	//o JOB de Integracao do TAF.
	If nCaso == 2 .And. cFormul <> "S"
		lVldIntTAF	:= .F.
	EndIf

	If cPaisLoc <> "BRA"
		cTipo:=(cAlias)->F1_TIPO
	Endif

	// Verifica se a NF esta carregada nas Funcoes Fiscais.
	If nCaso == 1 .And. !MaFisFound("NF")
		MaFisIniNF(1,nRecNF)
	EndIf
	// Gravar Livro Fiscal da NF refrente ao Despacho.
	If cPaisLoc == "ARG"
		If nCaso == 1 .And. (cAlias)->F1_TIPO_NF == "9"
			MaFisF3Eic(nCaso)
		EndIf
	EndIf
	//Campos da Nota Fiscal Eletronica
	lNFEletr := aPos[FP_F1_NFELETR] .And.;
					aPos[FP_F1_EMINFE]  .And.;
					aPos[FP_F1_HORNFE]  .And.;
					aPos[FP_F1_CODNFE]  .And.;
					aPos[FP_F1_CREDNFE] .And.;
					aPos[FP_F3_NFELETR] .And.;
					aPos[FP_F3_EMINFE]  .And.;
					aPos[FP_F3_HORNFE]  .And.;
					aPos[FP_F3_CODNFE]  .And.;
					aPos[FP_F3_CREDNFE]
	If lNFEletr
		aNFEletr[01] := (cAlias)->F1_NFELETR
		aNFEletr[02] := (cAlias)->F1_EMINFE
		aNFEletr[03] := (cAlias)->F1_HORNFE
		aNFEletr[04] := (cAlias)->F1_CODNFE
		aNFEletr[05] := (cAlias)->F1_CREDNFE
		If aPos[FP_F1_NUMRPS]
			aNFEletr[06] := (cAlias)->F1_NUMRPS
		Endif
	Endif
	//Campos da NFe Argentina
	lNFEArg	:= 		cPaisLoc== "ARG" .And.;
					aPos[FP_F1_TPVENT] .And.;
					aPos[FP_F1_CAE] .And.;
					aPos[FP_F1_VCTOCAE] .And.;
					aPos[FP_F3_TPVENT] .And.;
					aPos[FP_F3_CAE] .And.;
					aPos[FP_F3_VCTOCAE]
	If lNFEArg
		cTPVent := 	(cAlias)->F1_TPVENT
		cCAE	:=	(cAlias)->F1_CAE
		dDtCAE	:= 	(cAlias)->F1_VCTOCAE
	Endif
	//Campo da NF-e SPED
	lChvNfe	:= IIf( aPos[FP_F1_CHVNFE] .And. aPos[FP_FT_CHVNFE],.T.,.F.)
	If lChvNfe
		cChvNfe := 	(cAlias)->F1_CHVNFE
	Endif
OtherWise
	If Empty(cAlias)
		cAlias := "SF2"
		dbSelectArea("SF2")
		MsGoto(nRecNF)
	EndIf

	cCliFor	 := (cAlias)->F2_CLIENTE
	cLoja	 := (cAlias)->F2_LOJA
	cNumNF	 := (cAlias)->F2_DOC
	cSerie	 := (cAlias)->F2_SERIE
	dDEmissao:= (cAlias)->F2_EMISSAO
	cEspecie := (cAlias)->F2_ESPECIE
	cFormul	 := IIf(cPaisLoc == "BRA"," ",(cAlias)->F2_FORMUL)

	If cPaisLoc <> "BRA"
		dEntrada := IIf( aPos[FP_F2_DTDIGIT] , (cAlias)->F2_DTDIGIT , dDataBase )
		cTipo    :=(cAlias)->F2_TIPO
	Else
		dEntrada :=(cAlias)->F2_EMISSAO
	Endif

	// Verifica se a NF esta carregada nas Funcoes Fiscais.( Inclusao )
	If nCaso == 1 .And. !MaFisFound("NF")
		MaFisIniNF(2,nRecNF)
	EndIf
	//Campos da Nota Fiscal Eletronica
	lNFEletr	:= 	aPos[FP_F2_NFELETR].And.;
					aPos[FP_F2_EMINFE] .And.;
					aPos[FP_F2_HORNFE] .And.;
					aPos[FP_F2_CODNFE] .And.;
					aPos[FP_F2_CREDNFE].And.;
					aPos[FP_F3_NFELETR].And.;
					aPos[FP_F3_EMINFE] .And.;
					aPos[FP_F3_HORNFE] .And.;
					aPos[FP_F3_CODNFE] .And.;
					aPos[FP_F3_CREDNFE]
	If lNFEletr
		aNFEletr[01] := (cAlias)->F2_NFELETR
		aNFEletr[02] := (cAlias)->F2_EMINFE
		aNFEletr[03] := (cAlias)->F2_HORNFE
		aNFEletr[04] := (cAlias)->F2_CODNFE
		aNFEletr[05] := (cAlias)->F2_CREDNFE
	Endif
	//Campos da NFe Argentina
	lNFEArg	:= 		cPaisLoc== "ARG" .And.;
					aPos[FP_F2_TPVENT] .And.;
					aPos[FP_F2_CAE]    .And.;
					aPos[FP_F2_VCTOCAE].And.;
					aPos[FP_F3_TPVENT] .And.;
					aPos[FP_F3_CAE]    .And.;
					aPos[FP_F3_VCTOCAE]
	If lNFEArg
		cTPVent := 	(cAlias)->F2_TPVENT
		cCAE	:=	(cAlias)->F2_CAE
		dDtCAE	:= 	(cAlias)->F2_VCTOCAE
	Endif
	//Campo da NF-e SPED
	lChvNfe	:= Iif( aPos[FP_F2_CHVNFE]  .And. aPos[FP_FT_CHVNFE],.T.,.F.)
	If lChvNfe
		cChvNfe := 	(cAlias)->F2_CHVNFE
	Endif
EndCase

Do Case
	//Inclusao dos movimentos fiscais - Cabecalho e Item
	Case nCaso == 1 .And. nCD2 == 0
	//Inclusao dos movimentos fiscais
	//Tratamento de recuperacao de registros deletados do SF3
	dbSelectArea("SF3")
	dbSetOrder( IIf( cTpOper == "S" .Or. cFormul == "S" , 5 , 4 ) )
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			cAliasSF3 := "MaFisAtuSF3"
			lQuery    := .T.
			cQuery := "SELECT F3_FILIAL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,"
			cQuery += "F3_LOJA,F3_CFO,F3_FORMUL,F3_DTCANC, R_E_C_N_O_ SF3RECNO "
			cQuery += "FROM "+RetSqlName("SF3")+" SF3 "
			cQuery += "WHERE SF3.F3_FILIAL='"+xFilial("SF3")+"' AND "
			cQuery += "SF3.F3_SERIE='"+cSerie+"' AND "
			cQuery += "SF3.F3_NFISCAL='"+cNumNF+"' AND "
			//Tratamento para filtrar igual no SFT como não tem o FT_TIPOMOV
			cQuery += IIF(cDbType $ "ORACLE|DB2", " SUBSTR(SF3.F3_CFO,1,1) ", " SUBSTRING(SF3.F3_CFO,1,1) ") + IIF(cTpOper == "E", " < '5' ", " > '4' ") + " AND "
			If !(cTpOper=="S".Or.cFormul=="S")
				cQuery += "SF3.F3_CLIEFOR='"+cCliFor+"' AND "
				cQuery += "SF3.F3_LOJA='"+cLoja+"' AND "
			EndIf
			cQuery += "SF3.D_E_L_E_T_=' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3)
			TcSetField(cAliasSF3,"F3_DTCANC","D",8,0)
		Else
	#ENDIF
		MsSeek(xFilial("SF3")+IIf(cTpOper=="S".Or.cFormul=="S",cSerie+cNumNF,cCliFor+cLoja+cNumNF+cSerie))
		#IFDEF TOP
		EndIf
		#ENDIF

	While (!Eof().And. (cAliasSF3)->F3_FILIAL == xFilial("SF3") .And.;
			(cAliasSF3)->F3_NFISCAL == cNumNF .And.;
			(cAliasSF3)->F3_SERIE == cSerie .And.;
			IIf(cTpOper=="S".Or.cFormul=="S",.T.,(cAliasSF3)->F3_CLIEFOR == cCliFor .And.;
			(cAliasSF3)->F3_LOJA == cLoja) )
		If 	( (Substr((cAliasSF3)->F3_CFO,1,1) < "5" .And. (cAliasSF3)->F3_FORMUL == "S" )  .Or.;
				(Substr((cAliasSF3)->F3_CFO,1,1) > "4")  ) .And. !Empty((cAliasSF3)->F3_DTCANC) .And. (cFormul$"S ")
			If lQuery
				aadd(aRecSF3,(cAliasSF3)->SF3RECNO)
			Else
				aadd(aRecSF3,RecNo())
			EndIf
		EndIf
		dbSelectArea(cAliasSF3)
		dbSkip()
	EndDo

	If lQuery
		dbSelectArea(cAliasSF3)
		dbCloseArea()
		dbSelectArea("SF3")
	EndIf

	If (cPaisLoc=="BRA" .And. lIndicSFT)
		//Tratamento de recuperacao de registros deletados do SFT
		dbSelectArea("SFT")
		dbSetOrder(1)
		#IFDEF TOP
			If TcSrvType()<>"AS/400"
				cAliasSFT := "MaFisAtuSFT"
				lQuery    := .T.
				cQuery := "SELECT FT_FILIAL, FT_TIPOMOV,FT_NFISCAL,FT_SERIE,FT_CLIEFOR,FT_LOJA,"
				cQuery += "FT_CFOP,FT_FORMUL,FT_DTCANC, R_E_C_N_O_ SFTRECNO "
				cQuery += "FROM "+RetSqlName("SFT")+" SFT "
				cQuery += "WHERE SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
				cQuery += "SFT.FT_SERIE='"+cSerie+"' AND "
				cQuery += "SFT.FT_NFISCAL='"+cNumNF+"' AND "
				cQuery += "SFT.FT_TIPOMOV='"+cTpOper+"' AND "
				If !(cTpOper=="S".Or.cFormul=="S")
					cQuery += "SFT.FT_CLIEFOR='"+cCliFor+"' AND "
					cQuery += "SFT.FT_LOJA='"+cLoja+"' AND "
				EndIf
				cQuery += "SFT.D_E_L_E_T_=' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFT)
				TcSetField(cAliasSFT,"FT_DTCANC","D",8,0)
			Else
		#ENDIF
				MsSeek(xFilial("SFT")+cTpOper+cSerie+cNumNF+IIf(!(cTpOper=="S".Or.cFormul=="S"),cCliFor+cLoja,""))
		#IFDEF TOP
			EndIf
		#ENDIF

		While (!Eof().And. (cAliasSFT)->FT_FILIAL == xFilial("SFT") .And.;
			(cAliasSFT)->FT_NFISCAL == cNumNF .And.;
			(cAliasSFT)->FT_SERIE == cSerie .And.;
			IIf(cTpOper=="S".Or.cFormul=="S",.T.,(cAliasSFT)->FT_CLIEFOR == cCliFor .And.;
			(cAliasSFT)->FT_LOJA == cLoja) )
			If	(((cAliasSFT)->FT_TIPOMOV=="E" .And. (cAliasSFT)->FT_FORMUL == "S") .Or.;
				(cAliasSFT)->FT_TIPOMOV=="S") .And. !Empty((cAliasSFT)->FT_DTCANC)
				If lQuery
					aadd(aRecSFT,(cAliasSFT)->SFTRECNO)
				Else
					aadd(aRecSFT,RecNo())
				EndIf
			EndIf
			dbSelectArea(cAliasSFT)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasSFT)
			dbCloseArea()
			dbSelectArea("SFT")
		EndIf
	EndIf
	If (cPaisLoc=="BRA" .And. aDic[AI_CD2])
		//Tratamento de recuperacao de registros deletados do CD2
		dbSelectArea("CD2")
		dbSetOrder(2)
		#IFDEF TOP
			If TcSrvType()<>"AS/400"
				cAliasCD2 := "MaFisAtuCD2"
				lQuery    := .T.
				cQuery := "SELECT CD2_FILIAL,CD2_TPMOV,CD2_DOC,CD2_SERIE,CD2_CODCLI,CD2_LOJCLI,CD2_CODFOR,CD2_LOJFOR,R_E_C_N_O_ CD2RECNO "
				cQuery += "FROM "+RetSqlName("CD2")+" CD2 "
				cQuery += "WHERE CD2.CD2_FILIAL='"+xFilial("CD2")+"' AND "
				cQuery += "CD2.CD2_SERIE='"+cSerie+"' AND "
				cQuery += "CD2.CD2_DOC='"+cNumNF+"' AND "
				cQuery += "CD2.CD2_TPMOV='"+cTpOper+"' AND "
				If (cTpOper=="E" .And. !aNfCab[NF_TIPONF]$"DB")
					If !cFormul=="S"
					cQuery += "CD2.CD2_CODFOR='"+cCliFor+"' AND "
					cQuery += "CD2.CD2_LOJFOR='"+cLoja+"' AND "
					EndIf
				EndIf
				If aPos[FP_CD2_FORMU] .And. cFormul=="S"
					cQuery += "CD2.CD2_FORMU='S' AND "
				EndIf
				cQuery += "CD2.D_E_L_E_T_=' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCD2)
			Else
		#ENDIF
				MsSeek(xFilial("CD2")+cTpOper+cSerie+cNumNF+IIf(!(cTpOper=="S".Or.cFormul=="S"),cCliFor+cLoja,""))
		#IFDEF TOP
			EndIf
		#ENDIF
		While (!Eof() .And.;
			(cAliasCD2)->CD2_FILIAL == xFilial("CD2") .And.;
			(cAliasCD2)->CD2_TPMOV  == cTpOper	.And.;
			(cAliasCD2)->CD2_DOC    == cNumNF  .And.;
			(cAliasCD2)->CD2_SERIE  == cSerie  .And.;
			IIf(cTpOper=="S" .Or. (cTpOper=="E" .And. aNfCab[NF_TIPONF]$"DB") .Or. cFormul=="S",.T.,(cAliasCD2)->CD2_CODFOR == cCliFor .And. (cAliasCD2)->CD2_LOJFOR == cLoja))

			If lQuery
				CD2->(dbGoto((cAliasCD2)->CD2RECNO))
			EndIf

			RecLock("CD2")
			dbdelete()
			MsUnLock()

			dbSelectArea(cAliasCD2)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasCD2)
			dbCloseArea()
			dbSelectArea("CD2")
		EndIf
	EndIf
//PE - ICMS ST e Difal e Fecop menor que R$ 1
	If aPE[PE_MAZVSTDF] .And. cFunOrig <> "MATA930" .And. (aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST]) .And.;
	((aNfCab[NF_VALSOL] < 1 .And. aNfCab[NF_VALSOL] > 0) .Or. (aNfCab[NF_DIFAL] < 1 .And. aNfCab[NF_DIFAL] > 0) .Or.;
	(aNfCab[NF_VFCPDIF] < 1 .And. aNfCab[NF_VFCPDIF] > 0) .Or. (aNfCab[NF_VFECPST] < 1 .And. aNfCab[NF_VFECPST] > 0))
		ExecBlock("MAZVSTDF",.F.,.F.,{aNFCab[NF_UFDEST],aNfCab[NF_VALSOL],aNfCab[NF_DIFAL],aNFItem,aNfCab[NF_VFCPDIF],aNfCab[NF_VFECPST]})
	Endif
	// Grava arquivo de Livros Fiscais (SF3)
	aLivro := aNFCab[NF_LIVRO]
	aFixos := xFisAFixos()
	lObserv:= .F.

	If "MATA143" $ Upper(Funname()) .And. cpaisLoc=="ARG"
		nTaxaSF3:= MaFisRet(,'NF_TXMOEDA')
		nMoedaSF3:=MaFisRet(,'NF_MOEDA')
	EndIf
	If cPaisLoc=="BRA"
		AEval(aLivro,{ |x| (nVlrTotal+=IIf(x[3]+x[4]+x[5]+x[6]+x[7]+x[9]+x[10]+x[11]+x[27]+x[131]>0,x[3]+x[4]+x[5]+x[6]+x[7]+x[9]+x[10]+x[11]+x[27]+x[131],0)),((lObserv := IIf(!Empty(x[24]),.T.,lObserv)))})
	Else
		If Len(aLivro) > 0
			aLivro:=Adel(aLivro,1)
			aLivro:=aSize(aLivro,Len(aLivro)-1)
			nVlrTotal:=Len(aLivro)
		Endif
	Endif

	If nVlrTotal > 0.00 .Or. lObserv
		//Exclui os registros cancelados que serao reaproveitados em outro
		//documento fiscal.
		For nZ := 1 To Len(aRecSFT)

			SFT->(MsGoto(aRecSFT[nZ]))
			RecLock("SFT",.F.)

			If aPos[FP_FT_TAFKEY]
				SFT->FT_TAFKEY	:= ""
			EndIf

			SFT->(dbDelete())
			MsUnLock()
		Next nZ
		// Coloca os lancamentos fiscais em ordem de CFO e CFO Extendido
		If cPaisLoc=="BRA"
			Asort(aLivro,,,{|x,y| (x[1]+x[31])<(y[1]+y[31])})
		Endif

		For nX := 1 To Len(aLivro)
			If !Empty(aLivro[nX][1]) .Or. cPaisLoc <> "BRA"
				//Não será mais recupera os registros cancelados, mesmo tratamento na SFT
				If nX <= Len(aRecSF3)
					SF3->(MsGoto(aRecSF3[nX]))
					RecLock("SF3",.F.)
						SF3->(dbDelete())
					SF3->(MsUnLock())
				EndIf
				//Inclusao
				RecLock("SF3",.T.)

				For nY := 1 to Len(aFixos)
					If SF3->(FieldPos(aFixos[nY][1])) > 0 .And. aLivro[nX][nY] <> Nil
						If cPaisLoc <> "BRA" .And. ValType(aLivro[nX][nY]) == "N" .And. Subs(aFixos[nY][1],1,6) $ "F3_VAL|F3_BAS|F3_RET|F3_DES|F3_EXE"
							If "MATA143" $ Upper(Funname()) .And. cpaisLoc=="ARG" .And. MaFisRet(,'NF_MOEDA')<>1
								FieldPut(FieldPos(aFixos[nY][1]),Round(xMoeda(aLivro[nX][nY],nMoedaSF3,1,,,nTaxaSF3),MsDecimais(1)))
							Else
								FieldPut(FieldPos(aFixos[nY][1]),Round(aLivro[nX][nY],MsDecimais(1)))
							EndIf
						Else
							If  ALLTRIM(aFixos[nY][1]) == "F3_CONCEPT"
								//Tratamiento especifico para Ecuador.
								If cPaisLoc == "EQU" .AND. FunName() == "MATA101N"  //jgr

									If Len(oLstSF3:AARRAY) > 0
										cDesConc := Rtrim(RetTitle("F3_CONCEPT"))
										nPosConc := aScan(oLstSF3:AHEADERS,{|x|RTrim(x)==cDesConc})
									    cConceptF3 := oLstSF3:AARRAY[nX,nPosConc]
									EndIf

									If !Empty(cConceptF3)
										FieldPut(FieldPos(aFixos[nY][1]), cConceptF3 )
									Else
										nPosTesX   := aScan( aFixos,{|x| x[1] == "F3_TES"}     )
										FieldPut(FieldPos(aFixos[nY][1]), GetConcept( aLivro[nX][nPosTesX]  ) )
									EndIf
								Else
									FieldPut(FieldPos(aFixos[nY][1]),aLivro[nX][nY])
								EndIf
							Else
								FieldPut(FieldPos(aFixos[nY][1]),aLivro[nX][nY])
							EndIf
						EndIf
						//TRATAMENTO EXPECIFICO PARA LOCALIZADO PERU
						// Quando o TES for referente ao imposto do IGV, o valor do IPM, o
						// qual é uma porcentagem do IGV,o valor da base, aliquota e valor do
						// imposto é gravado nos campos _BASIMP3, _ALQIMP3 e VALIMP3.
						// O valor da base é a mesma utilizada para o cálculo do IGV.
						// O valor da alíqutoa é proveniente de um paramêtro chamado
						// MV_ALQIPM.
						// O valor do imposto é a multiplicação da base pelo valor da aliquota
						// NO CASO ABAIXO O VALOR DA BASE REFERENTE AO CáLCULO DO IGV é RECUPE-
						// RADA PARA QUE POSTERIOREMENTE SEJAM GRAVADOS NOS VAMPOS F3_BASIMP3,
						// F3_ALQIMP3 E F3_VALIMP3 OS VALORES DA BASE, ALIQUOTA E VALOR DE IM-
						// POSTO REFERENTE AO IPM.
						If cPaisLoc $ "PER"
							alAreaX := SFC->(GetArea())
							alAreaY := GetArea()
							nPosTesX := aScan(aFixos,{|x| x[1] == "F3_TES"})
							DbSelectArea("SFC")
							DbSetOrder(2)
							If MsSeek(xFilial("SFC")+aLivro[nX][nPosTesX]+"IGV")
								If Alltrim(aFixos[nY][1]) $ "F3_BASIMP1"
									nlBsIGVSF3 := aLivro[nX][nY]
								EndIf
							EndIf
							RestArea(alAreaX)
							RestArea(alAreaY)
						EndIf
					EndIf
				Next nY
				//TRATAMENTO EXPECIFICO PARA LOCALIZADO PERU
				// Quando o TES for referente ao imposto do IGV, o valor do IPM, o
				// qual é uma porcentagem do IGV,o valor da base, aliquota e valor do
				// imposto é gravado nos campos _BASIMP3, _ALQIMP3 e VALIMP3.
				// O valor da base é a mesma utilizada para o cálculo do IGV.
				// O valor da alíqutoa é proveniente de um paramêtro chamado
				// MV_ALQIPM.
				// O valor do imposto é a multiplicação da base pelo valor da aliquota
				// No caso abaixo os valorres da base, aliquota e valor de imposto são
				// gravados nos campos F3_BASIMP3, F3_ALQIMP3 e F3_VALIMP3 referente ao
				// IPM.

				SF3->F3_FILIAL	:= xFilial("SF3")
				SF3->F3_ENTRADA	:= IIF(Empty(dEntrada),dDatabase,dEntrada)
				SF3->F3_NFISCAL	:= cNumNF
				SerieNfId("SF3",1,"F3_SERIE",,,, cSerie )
				SF3->F3_CLIEFOR	:= cCliFor
				SF3->F3_LOJA	:= cLoja
				SF3->F3_CLIENT	:= aNFCab[NF_CLIENT]
				SF3->F3_LOJENT	:= aNFCab[NF_LOJENT]
				SF3->F3_PDV		:= cPDV

				If Len(aPos) >= FP_F3_SERSAT .AND. aPos[FP_F3_SERSAT]
					SF3->F3_SERSAT     := aNFCab[NF_SERSAT]  // Campo da Série para o CF-e SAT
				EndIf

				// Antes de passar o valor para o campo, verifico se a variavel esta preenchida. Caso esteja, significa que o campo continha este valor na linha que foi
				// deletada(D_E_L_E_T_ = *) e por isso, nesta nova linha o valor deverá ser mantido.
				If Alltrim(cCodSef) <> ""
				   SF3->F3_CODRSEF := cCodSef
				Endif
                If Alltrim(cCodRet) <> ""
				   SF3->F3_CODRET := cCodRet
				Endif
				If Alltrim(cProtoc) <> ""
				   SF3->F3_PROTOC := cProtoc
				Endif
				If Alltrim(cDescRet) <> ""
				   SF3->F3_DESCRET:= cDescRet
				Endif
				If Alltrim(cCNAE) <> ""
					SF3->F3_CNAE := cCNAE
				Endif

				If aSX6[MV_TMSUFPG] .And. !Empty(aNFCab[NF_PNF_UF]) .And. ("CTR"$AllTrim(aNFCab[NF_ESPECIE]).Or."NFST"$AllTrim(aNFCab[NF_ESPECIE]).Or.AllTrim(aNFCab[NF_ESPECIE])$"CTE/CTEOS".Or."RPS"$AllTrim(aNFCab[NF_ESPECIE]))
					SF3->F3_ESTADO := aNFCab[NF_PNF_UF]
				Else

					IF cTpOper == "E"

						If (AllTrim(cEspecie) $ "CTR/CTE/CTA/CA/CTF/CTEOS") .Or. ("NFST" $ AllTrim(cEspecie))

							cMV_ESTADO	:= aSX6[MV_ESTADO]
							cCltdest	:= aNfCab[NF_CLIDEST]

							If Empty(cCltdest)

								If aNfCab[NF_UFORIGEM] <> cMV_ESTADO .OR. aNfCab[NF_UFDEST] <> cMV_ESTADO
									If aNfCab[NF_UFORIGEM] == cMV_ESTADO
										SF3->F3_ESTADO := aNfCab[NF_UFDEST]
									Else
										SF3->F3_ESTADO := aNfCab[NF_UFORIGEM]
									EndIf
								Else
									SF3->F3_ESTADO := cMV_ESTADO
								EndIf

							Else

								If aNfCab[NF_UFORIGEM] <> cMV_ESTADO .OR. aNfCab[NF_UFCDEST] <> cMV_ESTADO
									If aNfCab[NF_UFORIGEM] == cMV_ESTADO
										SF3->F3_ESTADO := aNfCab[NF_UFCDEST]
									ElseIf aNfCab[NF_UFORIGEM] <> cMV_ESTADO .AND. aNfCab[NF_UFCDEST] <> cMV_ESTADO
										SF3->F3_ESTADO := aNfCab[NF_UFCDEST]
									Else
										SF3->F3_ESTADO := aNfCab[NF_UFORIGEM]
									EndIf
								Else
									SF3->F3_ESTADO := cMV_ESTADO
								EndIf

							EndIf
						Else
							SF3->F3_ESTADO := aNFCab[NF_UFORIGEM]
						EndIf
					Else
						//Saídas
						SF3->F3_ESTADO := aNFCab[NF_UFDEST]
					EndIF

				EndIf

				SF3->F3_EMISSAO	:= dDEmissao
				SF3->F3_FORMUL	:= IIF(cTpOper=="E".Or.cPaisLoc<>"BRA",cFormul," ")
				SF3->F3_ESPECIE	:= cEspecie
				SF3->F3_DTCANC	:= CTOD("")

				If aPos[FP_F3_CLIDVMC] .And. aPos[FP_F3_LOJDVMC]
					SF3->F3_CLIDVMC := cCliDvMc
					SF3->F3_LOJDVMC := cLojDvMc
				Endif

				//Processamento do SIGALOJA
				If aSX6[MV_LJLVFIS] == 2 .And. cTpOper == "S"

					If Empty((cAliasReproc)->F2_PDV) .And. !Empty((cAliasReproc)->F2_NFCUPOM)
						lLegislacao := Iif( cPaisLoc == "BRA" .And. LjAnalisaLeg(43)[1] , aDic[AI_MDL] , .F. )

						aAreaSL1 := SL1->(GetArea())
						SL1->(dbSetOrder(2))
						SL1->(MsSeek(xFilial() + SubStr((cAliasReproc)->F2_NFCUPOM, 1, 3) + SubStr((cAliasReproc)->F2_NFCUPOM, 4, GTamMxFis( TAM_F3_OBSERV)) ) )	// Serie + Numero da Nota

						SF3->F3_OBSERV  := Iif( lLegislacao , "F - Simples Faturamento" , "CF/SERIE:" + SL1->L1_DOC + "/" + SerieNfId("SL1",2,"L1_SERIE") +  " ECF:" + SL1->L1_PDV )
						SF3->F3_ESPECIE := (cAliasReproc)->F2_ESPECIE
						RestArea(aAreaSL1)
					Else

						cLjEspecie := Alltrim((cAliasReproc)->F2_ESPECIE)

						If cLjEspecie == "CF" .Or. cLjEspecie == "ECF"
							If Len(aLivro) > 0
								If aLivro[nX][LF_TIPO] <> "S"
									aLivro[nX][LF_TIPO] := "L"
									SF3->F3_TIPO := "L"
								Else
									SF3->F3_OBSERV := "NOTA FISCAL DE SERVICO"
								EndIf
								SF3->F3_PDV	   := (cAliasReproc)->F2_PDV
								If aPos[FP_F3_ECF]
									SF3->F3_ECF := "1"
								Endif
							EndIf
							If LjAnalisaLeg(18)[1]
								SF3->F3_ESPECIE := "ECF"
							Endif
						EndIf

						If (cLjEspecie == "SATCE" .Or. cLjEspecie == "NFCE") .And. (Len(aLivro) > 0)
							SF3->F3_PDV	   := (cAliasReproc)->F2_PDV
						EndIf
					EndIf
				EndIf
				//
				If Type("l920Auto") == "L" .And. !l920Auto
					SF3->F3_DOCOR := If(lLote,c920NfFim,SF3->F3_DOCOR)
					SF3->F3_TIPO  := If(lLote,"L",SF3->F3_TIPO)
				EndIf
				//Campos da Nota Fiscal Eletronica de Sao Paulo
				If lNFEletr
					SF3->F3_NFELETR	:= aNFEletr[01]
					SF3->F3_EMINFE	:= aNFEletr[02]
					SF3->F3_HORNFE	:= aNFEletr[03]
					SF3->F3_CODNFE	:= aNFEletr[04]
					SF3->F3_CREDNFE	:= aNFEletr[05]
					If aPos[FP_F3_NUMRPS]
						SF3->F3_NUMRPS	:= aNFEletr[06]
					Endif
				Endif
				//Campos da NFe Argentina
				If lNFEArg
					SF3->F3_TPVENT 	:= cTPVent
					SF3->F3_CAE 	:= cCAE
					SF3->F3_VCTOCAE	:= dDtCAE
				Endif

				cChaveNf := SF3->(DToS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)

				/*
					author: Vitor Ribeiro
					since: 08/08/2017
					obs: Foi criado a função xFisMdCt79 para realizar a regra para o campo devido que a mesma regra é utilizada no MATXMAG.


					//Declaracao das variaveis para Algoritmo MD5 Cat97
					cCNPJM5 := Repl("0",TamSx3("A1_CGC")[1]-Len(Alltrim(SA1->A1_CGC)))+AllTrim(SA1->A1_CGC)
					cNumNfM5 := Repl("0",TamSx3("F3_NFISCAL")[1]-Len(AllTrim(SF3->F3_NFISCAL)))+AllTrim(SF3->F3_NFISCAL)
					//Algoritmo MD5 Cat97
					cAutDig1 := cCNPJM5+cNumNfM5+StrTran(StrZero(SF3->F3_VALCONT, 13, 2), ".", "")
					cAutDig1 += StrTran(StrZero(SF3->F3_BASEICM, 13, 2), ".", "")+StrTran(StrZero(SF3->F3_VALICM, 13, 2), ".", "")
					cAutDig1 += DToS(SF3->F3_EMISSAO) + Alltrim(SM0->M0_CGC)
				*/

				If aPos[FP_F3_MDCAT79]
					// Função para realizar o algoritmo MD5, utilizando da função Md5(), para as informações do campo F3_MDCAT79.
					// xFisMdCt79(cCnpjCli,cNFiscal,nValCont,nBaseIcm,nValIcms,dEmissao,cCnpjEmi)
					SF3->F3_MDCAT79 := xFisMdCt79(SA1->A1_CGC,SF3->F3_NFISCAL,SF3->F3_VALCONT,SF3->F3_BASEICM,SF3->F3_VALICM,SF3->F3_EMISSAO,SM0->M0_CGC)
				EndIf
				//Credito Presumido Art. 6 Decreto n28.247
				If aPos[FP_F3_CRPREPE]
					SF3->F3_CRPREPE	:= aNfCab[NF_CRPREPE]
				Endif
				//Credito Presumido Art. 6 Decreto n28.247
				If aPos[FP_F3_CREDPRE]
					SF3->F3_CREDPRE	:=	aNfCab[NF_CREDPRE]
				Endif
				// FECOP RN e FECP-MG - nao sao necessario pois ja ha tratamento dinamico dos campos
				//REINTEGRA
				If aPos[FP_F3_VREINT]
					SF3->F3_VREINT	:=	aNfCab[NF_VREINT]
				EndIf
				If aPos[FP_F3_BSREIN]
					SF3->F3_BSREIN	:=	aNfCab[NF_BSREIN]
				EndIf
				//FECP-MT
				If aPos[FP_F3_VFECPMT]
					SF3->F3_VFECPMT	:=	aNfCab[NF_VFECPMT]
				EndIf
				If aPos[FP_F3_VFESTMT]
					SF3->F3_VFESTMT	:=	aNfCab[NF_VFESTMT]
				Endif
				//Campo da NF-e SPED
				If lChvNfe
					SF3->F3_CHVNFE := cChvNfe
				Endif
				//Campo da TPDP - PB
				If aPos[FP_F3_VALTPDP]
					SF3->F3_VALTPDP := aNfCab[NF_VALTPDP]
				Endif
				// Ponto de entrada para atualizar o livro fiscal
				If aPE[PE_MTA920L]
					ExecBlock("MTA920L",.F.,.F.)
				EndIf
				// Livro de ICMS - Ajuste SINEF 03/04 - DOU 08.04.04
				If cPaisLoc == "BRA"
					If !Empty(aLivro[nX][35]) .And. (aLivro[nX][LF_ISS_ISENICM] <> 0 .Or. aLivro[nX][LF_ISS_OUTRICM] <> 0)
						aSF3 := {}
						For nY := 1 To SF3->(FCount())
							aadd(aSF3,SF3->(FieldGet(nY)))
						Next nY
						RecLock("SF3",.T.)
						For nY := 1 To Len(aSF3)
							If !"_MSIDENT"$SF3->(FieldName(nY))
								FieldPut(nY,aSF3[nY])
							EndIf
						Next nY
						SF3->F3_TIPO    := "N"
						SF3->F3_ALIQICM := aLivro[nX][LF_ISS_ALIQICMS]
						SF3->F3_BASEICM := 0
						SF3->F3_VALICM  := 0
						SF3->F3_ISENICM := aLivro[nX][LF_ISS_ISENICM]
						SF3->F3_OUTRICM := aLivro[nX][LF_ISS_OUTRICM]
						SF3->F3_BASEIPI := 0
						SF3->F3_VALIPI  := 0
						SF3->F3_ISENIPI := aLivro[nX][LF_ISS_ISENIPI]
						SF3->F3_OUTRIPI := aLivro[nX][LF_ISS_OUTRIPI]
						SF3->F3_CODISS  := ""
						SF3->F3_OBSERV  := "NOTA FISCAL DE SERVICO"
						//Desconto Zona Franca de Manaus
						If aPos[FP_F3_DESCZFR]
							SF3->F3_DESCZFR := aLivro[nX][LF_DESCZFR]
						EndIf
						//Nota Fiscal Eletronica de Sao Paulo
						If lNFEletr
							SF3->F3_NFELETR	:= aNFEletr[01]
							SF3->F3_EMINFE	:= aNFEletr[02]
							SF3->F3_HORNFE	:= aNFEletr[03]
							SF3->F3_CODNFE	:= aNFEletr[04]
							SF3->F3_CREDNFE	:= aNFEletr[05]
							If aPos[FP_F3_NUMRPS]
								SF3->F3_NUMRPS	:= aNFEletr[06]
							Endif
						Endif
						// Ponto de entrada para atualizar o livro fiscal
						If aPE[PE_MTA920L]
							ExecBlock("MTA920L",.F.,.F.)
						EndIf
					EndIf
					IF aPos[FP_BASECPM] .And. 	aPos[FP_ALQCPM] .And. aPos[FP_VALCPM]
						SF3->F3_BASECPM	:= aLivro[nX][LF_BASECPM]
						SF3->F3_ALQCPM	:= aLivro[nX][LF_ALQCPM]
						SF3->F3_VALCPM	:= aLivro[nX][LF_VALCPM]
					EndIf
					IF aPos[FP_BASEFMP] .And. 	aPos[FP_VALFMP] .And. aPos[FP_ALQFMP]
						SF3->F3_BASEFMP	:= aLivro[nX][LF_BASEFMP]
						SF3->F3_ALQFMP	:= aLivro[nX][LF_ALQFMP]
						SF3->F3_VALFMP	:= aLivro[nX][LF_VALFMP]
					EndIf
					If aPos[FP_VALFMD]
						SF3->F3_VALFMD = aLivro[nX][LF_VALFMD]
					EndIf
					IF aPos[FP_F3_BASNDES]
						SF3->F3_BASNDES	:= aLivro[nX][LF_BASNDES]
					EndIf
					If aPos[FP_F3_ICMNDES]
						SF3->F3_ICMNDES	:= aLivro[nX][LF_ICMNDES]
					EndIf
					If aPos[FP_F3_PRCMEDP]
						SF3->F3_PRCMEDP	:= aLivro[nX][LF_PRCMEDP]
					EndIf
					IF aPos[FP_F3_VALPEDG]
						SF3->F3_VALPEDG	:= aLivro[nX][LF_VALPEDG]
					EndIf
					IF aPos[FP_F3_BASEINP]
						SF3->F3_BASEINP	:= aLivro[nX][LF_BASEINP]
					EndIf
					IF aPos[FP_F3_PERCINP]
						SF3->F3_PERCINP	:= aLivro[nX][LF_PERCINP]
					EndIf
					IF aPos[FP_F3_VALINP]
						SF3->F3_VALINP	:= aLivro[nX][LF_VALINP]
					EndIf
					IF aPos[FP_F3_DESCFIS]
						SF3->F3_DESCFIS	:= aLivro[nX][LF_DESCFIS]
					EndIf
					If aPos[FP_F3_VLINCMG]
						SF3->F3_VLINCMG	:= aLivro[nX][LF_VLINCMG]
					EndIf
				EndIf

				If cPaisLoc == "BRA" .And. lIndicSFT

					// Recupera os registros cancelados
					cItemNF	:= StrZero(0,GTamMxFis( TAM_D2_ITEM),0)	// Inicializa o Item

					For nZ := 1 To Len(aNfItem)
						// Para o SIGALOJA a numeracao dos itens nao considera deletados
						If cFunOrig == "LOJA701"
							If !aNfItem[nZ][IT_DELETED]
								cItemNF := SomaIt(cItemNF)
							EndIf
						Else
							cItemNF := aNfItem[nZ][IT_ITEM]
						EndIf
						//Tratamento para ICMS-ST de transporte. Não deve possuir valor fiscal além do ICMS-ST.
						If aNFItem[nZ][IT_TS][TS_LFICM]=="Z" .And. aNFItem[nZ][IT_TS][TS_OBSSOL]=="5" .And. aNfItem[nZ][IT_VALSOL] > 0
							lIcmSTTran := .T.
						Endif
						//Verifico se a referencia com a conta ja está preenchida para não dar seek atoa. Este trabalho foi para melhorar performance, Na verdade n deveria dar seek aqui no SD2 e SD1.
						if Empty(aNfItem[nZ][IT_CTAREC]) 
							If aNFCab[NF_OPERNF] == "S" 
								dbSelectArea("SD2")
								dbSetOrder(3)
								MsSeek(xFilial("SD2")+cNumNF+cSerie+cCliFor+cLoja+aNfItem[nZ][IT_PRODUTO]+cItemNF)
								cCtaCont := SD2->D2_CONTA
							Else
								dbSelectArea("SD1")
								dbSetOrder(1)
								MsSeek(xFilial("SD1")+cNumNF+cSerie+cCliFor+cLoja+aNfItem[nZ][IT_PRODUTO]+cItemNF)
								cCtaCont := SD1->D1_CONTA
							EndIf
						endif
						//
						dbSelectArea("SFT")
						dbSetOrder(1)
						If (aNfItem[nZ][IT_LIVRO][LF_IDENT] == aLivro[nX][LF_IDENT]) .And. !aNfItem[nZ][IT_DELETED]
							RecLock("SFT",.T.)
							SFT->FT_FILIAL	:= xFilial("SFT")
							SFT->FT_TIPOMOV := cTpOper
							SFT->FT_EMISSAO	:= dDEmissao
							SFT->FT_ENTRADA	:= IIF(Empty(dEntrada),dDatabase,dEntrada)
							SFT->FT_NFISCAL	:= cNumNF
							SerieNfId("SFT",1,"FT_SERIE",,,, cSerie )
							SFT->FT_CLIEFOR	:= cCliFor
							SFT->FT_LOJA	:= cLoja
							SFT->FT_CLIENT 	:= aNFCab[NF_CLIENT]
							SFT->FT_LOJENT	:= aNFCab[NF_LOJENT]
							SFT->FT_PDV     := cPDV
							SFT->FT_IDENTF3	:=	aNfItem[nZ][IT_LIVRO][LF_IDENT]

							If aSX6[MV_TMSUFPG] .And. !Empty(aNFCab[NF_PNF_UF]) .And. (AllTrim(aNFCab[NF_ESPECIE]) $ "CTR/CTE/CTEOS/" .Or."NFST"$AllTrim(aNFCab[NF_ESPECIE]))
								SFT->FT_ESTADO	:= aNFCab[NF_PNF_UF]
							Else

								If cTpOper == "E"

									If (AllTrim(cEspecie) $ "CTR/CTE/CTA/CA/CTF/CTEOS") .Or. ("NFST" $ AllTrim(cEspecie))

										cMV_ESTADO	:= aSX6[MV_ESTADO]
										cCltdest	:= aNfCab[NF_CLIDEST]

										If Empty(cCltdest)

											If aNfCab[NF_UFORIGEM] <> cMV_ESTADO .OR. aNfCab[NF_UFDEST] <> cMV_ESTADO
												If aNfCab[NF_UFORIGEM] == cMV_ESTADO
													SFT->FT_ESTADO := aNfCab[NF_UFDEST]
												Else
													SFT->FT_ESTADO := aNfCab[NF_UFORIGEM]
												EndIf
											Else
												SFT->FT_ESTADO := cMV_ESTADO
											EndIf

										Else

											If aNfCab[NF_UFORIGEM] <> cMV_ESTADO .OR. aNfCab[NF_UFCDEST] <> cMV_ESTADO
												If aNfCab[NF_UFORIGEM] == cMV_ESTADO
													SFT->FT_ESTADO := aNfCab[NF_UFCDEST]
												ElseIf aNfCab[NF_UFORIGEM] <> cMV_ESTADO .AND. aNfCab[NF_UFCDEST] <> cMV_ESTADO
													SFT->FT_ESTADO := aNfCab[NF_UFCDEST]
												Else
													SFT->FT_ESTADO := aNfCab[NF_UFORIGEM]
												EndIf
											Else
												SFT->FT_ESTADO := cMV_ESTADO
											EndIf

										EndIf

									Else
										SFT->FT_ESTADO := aNFCab[NF_UFORIGEM]
									EndIf
								Else
									//Saídas
									SFT->FT_ESTADO := aNFCab[NF_UFDEST]
								EndIF 
							EndIf
							SFT->FT_FORMUL	:=	IIF(cTpOper=="E".Or.cPaisLoc<>"BRA",cFormul," ")
							SFT->FT_ESPECIE	:=	cEspecie
							SFT->FT_DTCANC	:=	CTOD("")
							SFT->FT_TIPO	:=	aNfItem[nZ][IT_LIVRO][LF_TIPO]
							SFT->FT_POSIPI	:=	aNfItem[nZ][IT_LIVRO][LF_POSIPI]
							SFT->FT_CLASFIS	:=	aNfItem[nZ][IT_LIVRO][LF_CLASFIS]
							SFT->FT_CTIPI	:=	aNfItem[nZ][IT_LIVRO][LF_CTIPI]
							SFT->FT_ESTOQUE	:=	aNfItem[nZ][IT_LIVRO][LF_ESTOQUE]
							SFT->FT_DESPIPI	:=	aNfItem[nZ][IT_LIVRO][LF_DESPIPI]
							SFT->FT_ISENICM	:=	aNfItem[nZ][IT_LIVRO][LF_ISENICM]
							SFT->FT_OUTRICM	:=	aNfItem[nZ][IT_LIVRO][LF_OUTRICM]
							
							//IF !(aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nZ, TRIB_ID_ICMSST)) // Não alterar quando utilizado configurador
								SFT->FT_ISENICM	-=	aNfItem[nZ][IT_LIVRO][LF_ISENRET]
								SFT->FT_OUTRICM	-=	aNfItem[nZ][IT_LIVRO][LF_OUTRRET]
							//Endif

							SFT->FT_ICMSRET	:=	aNfItem[nZ][IT_LIVRO][LF_ICMSRET]
							SFT->FT_ITEMORI	:=	aNfItem[nZ][IT_LIVRO][LF_ITEMORI]
							SFT->FT_ALIQIPI	:=	aNfItem[nZ][IT_LIVRO][LF_ALIQIPI]
							SFT->FT_CONTA	:=	Iif(!Empty(aNfItem[nZ][IT_CTAREC]),aNfItem[nZ][IT_CTAREC],cCtaCont)
							SFT->FT_VALINS	:=	aNfItem[nZ][IT_VALINS]
							SFT->FT_ALIQINS	:=	aNfItem[nZ][IT_ALIQINS]
							SFT->FT_BASEINS	:=	aNfItem[nZ][IT_BASEINS]
							SFT->FT_VALINS	:=	aNfItem[nZ][IT_VALINS]
							SFT->FT_ALIQIRR	:=	aNfItem[nZ][IT_ALIQIRR]
							SFT->FT_BASEIRR	:=	aNfItem[nZ][IT_BASEIRR]
							SFT->FT_SEGURO	:=	aNfItem[nZ][IT_SEGURO]
							SFT->FT_FRETE	:=	aNfItem[nZ][IT_FRETE]
							SFT->FT_PRODUTO	:=	aNfItem[nZ][IT_PRODUTO]
							SFT->FT_BASEIRR	:=	aNfItem[nZ][IT_BASEIRR]
							SFT->FT_ALIQIRR	:=	aNfItem[nZ][IT_ALIQIRR]
							SFT->FT_VALIRR	:=	aNfItem[nZ][IT_VALIRR]
							SFT->FT_BASEINS	:=	aNfItem[nZ][IT_BASEINS]
							SFT->FT_ALIQINS	:=	aNfItem[nZ][IT_ALIQINS]
							SFT->FT_VALINS	:=	aNfItem[nZ][IT_VALINS]
							SFT->FT_ITEM	:=	cItemNF
							SFT->FT_QUANT	:=	aNfItem[nZ][IT_QUANT]
							SFT->FT_PRCUNIT	:=	aNfItem[nZ][IT_PRCUNI]
							SFT->FT_TOTAL	:=	Iif(!lIcmSTTran,aNfItem[nZ][IT_VALMERC] + aNfItem[nZ][IT_ACRESCI],0)
							SFT->FT_DESCONT	:=	aNfItem[nZ][IT_DESCONTO]
							SFT->FT_NFORI	:=	aNfItem[nZ][IT_NFORI]
							SerieNfId("SFT",1,"FT_SERORI",,,, aNfItem[nZ][IT_SERORI] )
							SFT->FT_PESO	:=	aNfItem[nZ][IT_PESO]
							//Armazenar margem
							If aPos[FP_FT_MARGEM]
								SFT->FT_MARGEM := aNfItem[nZ][IT_MARGEM]
							EndIf
							//PIS/PASEP Apuracao
							SFT->FT_BASEPIS := aNfItem[nZ][IT_BASEPS2]
							SFT->FT_ALIQPIS := aNfItem[nZ][IT_ALIQPS2]
							SFT->FT_VALPIS	:= aNfItem[nZ][IT_VALPS2]
							//COFINS Apuracao
							SFT->FT_BASECOF	:= aNfItem[nZ][IT_BASECF2]
							SFT->FT_ALIQCOF	:= aNfItem[nZ][IT_ALIQCF2]
							SFT->FT_VALCOF	:= aNfItem[nZ][IT_VALCF2]
							//CSLL Apuracao
							SFT->FT_BASECSL	:= 0
							SFT->FT_ALIQCSL	:= 0
							SFT->FT_VALCSL	:= 0

							//Nota Fiscal Eletronica de Sao Paulo
							If lNFEletr .And. ;
								aPos[FP_FT_NFELETR] .And.;
								aPos[FP_FT_EMINFE]  .And.;
								aPos[FP_FT_HORNFE]  .And.;
								aPos[FP_FT_CODNFE]  .And.;
								aPos[FP_FT_CREDNFE]
								SFT->FT_NFELETR	:= aNFEletr[01]
								SFT->FT_EMINFE	:= aNFEletr[02]
								SFT->FT_HORNFE	:= aNFEletr[03]
								SFT->FT_CODNFE	:= aNFEletr[04]
								SFT->FT_CREDNFE	:= aNFEletr[05]
								If aPos[FP_FT_NUMRPS]
									SFT->FT_NUMRPS	:= aNFEletr[06]
								Endif
							Endif

							If aPos[FP_FT_CSTPIS]
								SFT->FT_CSTPIS := aNfItem[nZ][IT_LIVRO][LF_CSTPIS]
							EndIf
							If aPos[FP_FT_CSTCOF]
								SFT->FT_CSTCOF := aNfItem[nZ][IT_LIVRO][LF_CSTCOF]
							EndIf
							If aPos[FP_FT_CODBCC]
								SFT->FT_CODBCC := aNfItem[nZ][IT_LIVRO][LF_CODBCC]
							EndIf
							If aPos[FP_FT_CV139]
								SFT->FT_CV139 := aNfItem[nZ][IT_CV139]
							EndIf
							If aPos[FP_FT_INDNTFR]
								SFT->FT_INDNTFR := aNfItem[nZ][IT_LIVRO][LF_INDNTFR]
							EndIf
							//Campo da NF-e SPED
							If lChvNfe
								SFT->FT_CHVNFE := cChvNfe
							Endif
							//Regime Especial de Substituicao Tributaria - MG
							If aPos[FP_FT_RGESPST]
								SFT->FT_RGESPST := aNfItem[nZ][IT_RGESPST]
							Endif
							//Fundersul - Mato Grosso do Sul
							If aPos[FP_FT_VALFDS]
								SFT->FT_VALFDS := aNfItem[nZ][IT_VALFDS]
							Endif
							If aPos[FP_FT_PRFDSUL]
								SFT->FT_PRFDSUL := aNfItem[nZ][IT_PRFDSUL]
							Endif
							If aPos[FP_FT_UFERMS]
								SFT->FT_UFERMS := aNfItem[nZ][IT_UFERMS]
							Endif
							//SENAR
							If aPos[FP_FT_BSSENAR]
								SFT->FT_BSSENAR := aNfItem[nZ][IT_BSSENAR]
							Endif
							If aPos[FP_FT_VLSENAR]
								SFT->FT_VLSENAR := aNfItem[nZ][IT_VLSENAR]
							Endif
							If aPos[FP_FT_ALSENAR]
								SFT->FT_ALSENAR := aNfItem[nZ][IT_ALSENAR]
							Endif
							//FUNRURAL
							If aPos[FP_FT_BASEFUN]
								SFT->FT_BASEFUN := aNfItem[nZ][IT_BASEFUN]
							Endif
							If aPos[FP_FT_VALFUN]
								SFT->FT_VALFUN := aNfItem[nZ][IT_FUNRURAL]
							Endif
							If aPos[FP_FT_ALIQFUN]
								SFT->FT_ALIQFUN := aNfItem[nZ][IT_PERFUN]
							Endif
							//FETHAB - Mato Grosso
							If aPos[FP_FT_BSEFET]
								SFT->FT_BSEFET := aNfItem[nZ][IT_BASEFET]
							Endif
							If aPos[FP_FT_ALQFET]
								SFT->FT_ALQFET := aNfItem[nZ][IT_ALIQFET]
							Endif
							If aPos[FP_FT_VALFET]
								SFT->FT_VALFET := aNfItem[nZ][IT_VALFET]
							Endif
							//FABOV - Mato Grosso
							If aPos[FP_FT_BSEFAB]
								SFT->FT_BSEFAB := aNfItem[nZ][IT_BASEFAB]
							Endif
							If aPos[FP_FT_ALQFAB]
								SFT->FT_ALQFAB := aNfItem[nZ][IT_ALIQFAB]
							Endif
							If aPos[FP_FT_VALFAB]
								SFT->FT_VALFAB := aNfItem[nZ][IT_VALFAB]
							Endif
							//FACS - Mato Grosso
							If aPos[FP_FT_BSEFAC]
								SFT->FT_BSEFAC := aNfItem[nZ][IT_BASEFAC]
							Endif
							If aPos[FP_FT_ALQFAC]
								SFT->FT_ALQFAC := aNfItem[nZ][IT_ALIQFAC]
							Endif
							If aPos[FP_FT_VALFAC]
								SFT->FT_VALFAC := aNfItem[nZ][IT_VALFAC]
							Endif
							//FAMAD
							If aPos[FP_FT_BSEFMD]
								SFT->FT_BSEFMD := aNfItem[nZ][IT_BASEFMD]
							Endif
							If aPos[FP_FT_ALQFMD]
								SFT->FT_ALQFMD := aNfItem[nZ][IT_ALQFMD]
							Endif
							If aPos[FP_FT_VALFMD]
								SFT->FT_VALFMD := aNfItem[nZ][IT_VALFMD]
							Endif
							//CODIF - Codigo de autorizacao para operacoes com AEAC - Combustiveis
							If aPos[FP_FT_CODIF]
								SFT->FT_CODIF	:=	aNfItem[nZ][IT_CODIF]
							Endif
							If aPos[FP_FT_NORESP]
								SFT->FT_NORESP	:=	aNfItem[nZ][IT_NORESPE]
							EndIf
							//Preco Unitario utilizado para calculo da Substituição tributária para fabrixante de Cigarros
							If aPos[FP_FT_PRCUNIC]
								SFT->FT_PRCUNIC	:=	aNfItem[nZ][IT_PRCUNIC]
							EndIf
							//Coeficiente que foi utilizado para cálculo da Substituição Tributária do PIS para fabricante de cigarros.
							If aPos[FP_FT_COEPSST]
								SFT->FT_COEPSST	:=	aNfItem[nZ][IT_COEPSST]
							EndIf
							//Coeficiente que foi utilizado para cálculo da Substituição Tributária da COFINS para fabricante de cigarros.
							If aPos[FP_FT_COECFST]
								SFT->FT_COECFST	:=	aNfItem[nZ][IT_COECFST]
							EndIf
							If aPos[FP_FT_AGREG]
								SFT->FT_AGREG	:=	aNFItem[nZ][IT_TS][TS_AGREG]
							EndIf
							If aPos[FP_FT_INFITEM]
								SFT->FT_INFITEM	:=	aNFItem[nZ][IT_TS][TS_INFITEM]
							EndIf
							If aPos[FP_FT_DESCICM]
								SFT->FT_DESCICM	:=	aNfItem[nZ][IT_DEDICM]
							EndIf
							//Credito Presumido Simples Nacional - SC
							If aPos[FP_FT_CRPRSIM]
								SFT->FT_CRPRSIM	:=	aNfItem[nZ][IT_LIVRO][LF_CRPRSIM]
							Endif
							//Credito Presumido
							If aPos[FP_FT_CRDPRES]
								SFT->FT_CRDPRES	:=	aNfItem[nZ][IT_LIVRO][LF_CRDPRES]
							Endif
							//Credito Presumido - PR
							If aPos[FP_FT_CRPREPR]
								SFT->FT_CRPREPR	:=	aNfItem[nZ][IT_LIVRO][LF_CRPREPR]
							Endif
							//Cred. Presumido-art.631-A do RICMS/2008
							If aPos[FP_FT_CPRESPR]
								SFT->FT_CPRESPR	:=	aNfItem[nZ][IT_LIVRO][LF_CPRESPR]
							Endif
							//Cred. Presumido-Decreto 52.586 de 28.12.2007
							If aPos[FP_FT_CRPRESP]
								SFT->FT_CRPRESP	:=	aNfItem[nZ][IT_LIVRO][LF_CRPRESP]
							Endif
							//Cred. Presumido-Decreto 52.586 de 28.12.2007
							If aPos[FP_FT_CREDPRE]
								SFT->FT_CREDPRE	:=	aNfItem[nZ][IT_LIVRO][LF_CREDPRE]
							Endif
							//Cred. Outotgado SP -Decreto 56.018 de 16.07.2010
							If aPos[FP_FT_CROUTSP]
								SFT->FT_CROUTSP	:=	aNfItem[nZ][IT_LIVRO][LF_CROUTSP]
							Endif
							//Credito Outorgado - GO Inc.III, Art 11 Anexo IX - RCTE-GO/97
							If aPos[FP_FT_CROUTGO]
								SFT->FT_CROUTGO	:=	aNfItem[nZ][IT_LIVRO][LF_CROUTGO]
							Endif
							//Credito Presumido - RO
							If aPos[FP_FT_CRPRERO]
								SFT->FT_CRPRERO	:=	aNfItem[nZ][IT_LIVRO][LF_CRPRERO]
							Endif
							//Credito Presumido Art.39 Anexo IV- RO
							If aPos[FP_FT_CRPRRON]
								SFT->FT_CRPRRON	:=	aNfItem[nZ][IT_LIVRO][LF_CRPRERO]
							Endif
							//Credito Presumido - Art. 6 Decreto  n28.247
							If aPos[FP_FT_CRPREPE]
								SFT->FT_CRPREPE	:=	aNfItem[nZ][IT_LIVRO][LF_CRPREPE]
							Endif
							// PRODEPE
							If aPos[FP_FT_CPPRODE]
								SFT->FT_CPPRODE	:=	aNfItem[nZ][IT_LIVRO][LF_CPPRODE]
							Endif
							If aPos[FP_FT_TPPRODE]
								SFT->FT_TPPRODE	:=	aNfItem[nZ][IT_LIVRO][LF_TPPRODE]
							Endif
							//Credito presumido carga
							If aPos[FP_FT_CRDPCTR]
								SFT->FT_CRDPCTR	:=	aNfItem[nZ][IT_LIVRO][LF_CRDPCTR]
							Endif
							//Antecipacao Tribut. ICMS
							If aPos[FP_FT_ANTICMS]
								SFT->FT_ANTICMS	:=	aNfItem[nZ][IT_LIVRO][LF_ANTICMS]
							Endif
							//Valor Antecipacao ICMS
							If aPos[FP_FT_VALANTI]
								SFT->FT_VALANTI	:=	aNfItem[nZ][IT_LIVRO][LF_VALANTI]
							Endif
							//BASE CALCULO CREDITO PRESUMIDO
							If aPos[FP_FT_BASECPR]
								SFT->FT_BASECPR := aNfItem[nZ][IT_LIVRO][LF_BASECPR]
							Endif

							//Aliquota do FECP: Mantem legado se nao existirem os campos novos (FT_ALFCPST e FT_ALFCCMP).
							//Se existirem efetua a gravacao de cada aliquota em seu respectivo campo.
							If aPos[FP_FT_ALQFECP] .And. !aPos[FP_FT_ALFCPST] .And. !aPos[FP_FT_ALFCCMP]
								If aNfItem[nZ][IT_ALIQFECP] > 0
									SFT->FT_ALQFECP	:=	aNfItem[nZ][IT_ALIQFECP]
								Elseif  aNfItem[nZ][IT_ALFCST] > 0
									SFT->FT_ALQFECP	:=	aNfItem[nZ][IT_ALFCST]
								Elseif  aNfItem[nZ][IT_ALFCCMP] > 0
									SFT->FT_ALQFECP	:=	aNfItem[nZ][IT_ALFCCMP]
								Endif
							Else
								// FECP
								If aPos[FP_FT_ALQFECP] .And. aNfItem[nZ][IT_ALIQFECP] > 0
									SFT->FT_ALQFECP	:=	aNfItem[nZ][IT_ALIQFECP]
								EndIf
								// FECP-ST
								If aPos[FP_FT_ALFCPST] .And. aNfItem[nZ][IT_ALFCST] > 0
									SFT->FT_ALFCPST	:=	aNfItem[nZ][IT_ALFCST]
								EndIf
								// FECP Complementar
								If aPos[FP_FT_ALFCCMP] .And. aNfItem[nZ][IT_ALFCCMP] > 0
									SFT->FT_ALFCCMP	:=	aNfItem[nZ][IT_ALFCCMP]
								Endif
							Endif

							If aPos[FP_FT_VALFECP]
								SFT->FT_VALFECP	:=	aNfItem[nZ][IT_VALFECP]
							Endif
							If aPos[FP_FT_VFECPST]
								SFT->FT_VFECPST	:=	aNfItem[nZ][IT_VFECPST]
							Endif
							//Valor do FECOP RN
							If aPos[FP_FT_ALFECRN]
								SFT->FT_ALFECRN	:=	aNfItem[nZ][IT_ALFECRN]
							Endif
							If aPos[FP_FT_VFECPRN]
								SFT->FT_VFECPRN	:=	aNfItem[nZ][IT_VFECPRN]
							Endif
							If aPos[FP_FT_VFESTRN]
								SFT->FT_VFESTRN	:=	aNfItem[nZ][IT_VFESTRN]
							Endif
							//Valor do FECP-MG
							If aPos[FP_FT_ALFECMG]
								SFT->FT_ALFECMG	:=	aNfItem[nZ][IT_ALFECMG]
							Endif
							If aPos[FP_FT_VFECPMG]
								SFT->FT_VFECPMG	:=	aNfItem[nZ][IT_VFECPMG]
							Endif
							If aPos[FP_FT_VFESTMG]
								SFT->FT_VFESTMG	:=	aNfItem[nZ][IT_VFESTMG]
							Endif
							//Valor do FECP-MT
							If aPos[FP_FT_ALFECMT]
								SFT->FT_ALFECMT	:=	aNfItem[nZ][IT_ALFECMT]
							Endif
							If aPos[FP_FT_VFECPMT]
								SFT->FT_VFECPMT	:=	aNfItem[nZ][IT_VFECPMT]
							Endif
							If aPos[FP_FT_VFESTMT]
								SFT->FT_VFESTMT	:=	aNfItem[nZ][IT_VFESTMT]
							Endif
							//Valor de Reintegra
							If aPos[FP_FT_VREINT]
								SFT->FT_VREINT	:=	aNfItem[nZ][IT_LIVRO][LF_VREINT]
							Endif
							If aPos[FP_FT_BSREIN]
								SFT->FT_BSREIN	:=	aNfItem[nZ][IT_LIVRO][LF_BSREIN]
							Endif
							//DIAT-SC
							If aPos[FP_FT_B1DIAT]
								SFT->FT_B1DIAT	:= aNfItem[nZ][IT_B1DIAT]
							Endif
							If aPos[FP_FT_DESCTOT]
								SFT->FT_DESCTOT	:= aNfItem[nZ][IT_DESCTOT]
							Endif
							If aPos[FP_FT_ACRESCI]
								SFT->FT_ACRESCI	:= aNfItem[nZ][IT_ACRESCI]
							Endif

							If Len(aPos) >= FP_FT_SERSAT .AND.  aPos[FP_FT_SERSAT]
								SFT->FT_SERSAT	:= aNFCab[NF_SERSAT] // Campo da Série CF-e SAT
							Endif

							For nY := 1 to Len(aWriteSFT)
								If !(AllTrim (aWriteSFT[nY][2])$"FT_ISENICM/FT_OUTRICM/FT_ICMSRET/FT_FORMUL")	//SAO GRAVADOS ACIMA
									FieldPut(FieldPos(aWriteSFT[nY][2]),MaFisRet(nZ,aWriteSFT[nY][3]))
								EndIf
							Next nY

							//Valor do FUMACOP
							If aPos[FP_FT_ALQFUM]
								SFT->FT_ALQFUM	:=	aNfItem[nZ][IT_ALIQFUM]
							Endif
							If aPos[FP_FT_VALFUM]
								SFT->FT_VALFUM	:=	aNfItem[nZ][IT_VALFUM]
							Endif
							//ICMS frete autonomo - Embarcador
							If aPos[FP_FT_BASETST] .And. aPos[FP_FT_ALIQTST] .And. aPos[FP_FT_VALTST] .And. aNfCab[NF_RECFAUT] <> "2"
								SFT->FT_BASETST	:= aNfItem[nZ][IT_BASETST]
								SFT->FT_ALIQTST	:= aNfItem[nZ][IT_ALIQTST]
								SFT->FT_VALTST	:= aNfItem[nZ][IT_VALTST]
							Endif
							//Valor da aliquota de ICMS Solidario
							If aPos[FP_FT_ALIQSOL]
								If aNfItem[nZ][IT_LIVRO][LF_ICMSRET] > 0
									SFT->FT_ALIQSOL	:=	aNfItem[nZ][IT_ALIQSOL]
								Else
									SFT->FT_ALIQSOL	:= 0
								EndIf
							Endif
							//Pautas
							If aPos[FP_FT_PAUTST]
								SFT->FT_PAUTST	:=	aNfItem[nZ][IT_PAUTST]
							Endif
							If aPos[FP_FT_PAUTIC]
								SFT->FT_PAUTIC	:=	aNfItem[nZ][IT_PRD][SB_VLR_ICM]
							Endif
							If aPos[FP_FT_PAUTIPI]
								SFT->FT_PAUTIPI	:=	aNfItem[nZ][IT_PAUTIPI]
							Endif
							// Verifica se existe excecao fiscal para pauta do PIS
							If cPaisLoc=="BRA" 
								nPautaPIS := aNfItem[nZ][IT_PRD][SB_VLR_PIS]
								nPautaCOF := aNfItem[nZ][IT_PRD][SB_VLR_COF]
							Endif
							If aPos[FP_FT_PAUTPIS] .And. aNFItem[nZ][IT_PAUTAPS]
								If !Empty(aNfItem[nZ][IT_EXCECAO]) .And. !Empty(aNfItem[nZ][IT_EXCECAO][10])
									SFT->FT_PAUTPIS	:= aNfItem[nZ][IT_EXCECAO][10]
								Else
									SFT->FT_PAUTPIS	:=  nPautaPis
								EndIf
							Endif
							// Verifica se existe excecao fiscal para pauta do COFINS
							If aPos[FP_FT_PAUTCOF] .And. aNFItem[nZ][IT_PAUTACF]
								If !Empty(aNfItem[nZ][IT_EXCECAO]) .And. !Empty(aNfItem[nZ][IT_EXCECAO][11])
									SFT->FT_PAUTCOF	:= aNfItem[nZ][IT_EXCECAO][11]
								Else
									SFT->FT_PAUTCOF	:= nPautaCof
								EndIf
							Endif
							If aPos[FP_FT_CSTISS]
								SFT->FT_CSTISS	:= aNfItem[nZ][IT_LIVRO][LF_CSTISS]
							Endif
							//Percentual da reducao de base - decreto 43.080/2002 do RICMS-MG
							If aPos[FP_FT_PR43080]
								SFT->FT_PR43080	:= aNfItem[nZ][IT_PR43080]
							Endif
							//Valor do desconto - Decreto 43.080/2002 do RICMS-MG
							If aPos[FP_FT_DS43080]
								SFT->FT_DS43080:= aNfItem[nZ][IT_LIVRO][LF_DS43080]
							Endif
							If aPos[FP_FT_DESCZFR]
								SFT->FT_DESCZFR	:= aNfItem[nZ][IT_LIVRO][LF_DESCZFR]
							Endif
							//Incentivo à produção e à industrialização do leite
							If aPos[FP_FT_VLINCMG]
								SFT->FT_VLINCMG	:=	aNfItem[nZ][IT_VLINCMG]
							Endif
							If aPos[FP_FT_PRINCMG]
								SFT->FT_PRINCMG	:=	aNfItem[nZ][IT_PRINCMG]
							Endif
							//Aliquota Majorada da COFINS
							If aPos[FP_FT_MALQCOF] .And. aPos[FP_FT_MVALCOF]
								SFT->FT_MVALCOF := aNfItem[nZ][IT_LIVRO][LF_VALCMAJ]
								SFT->FT_MALQCOF := aNfItem[nZ][IT_LIVRO][LF_ALQCMAJ]
							EndIf
							//Aliquota Majorada da PIS
							If aPos[FP_FT_MALQPIS] .And. aPos[FP_FT_MVALPIS]
								SFT->FT_MVALPIS := aNfItem[nZ][IT_LIVRO][LF_VALPMAJ]
								SFT->FT_MALQPIS := aNfItem[nZ][IT_LIVRO][LF_ALQPMAJ]
							EndIf
							//MV_ISSXMUN Tribmum e Cnae preenchidos na CE1
							If aPos[FP_FT_CNAE]
								SFT->FT_CNAE	:= aNfItem[nZ][IT_CNAE]
							Endif
							If aPos[FP_FT_TRIBMUN]
								SFT->FT_TRIBMUN	:= aNfItem[nZ][IT_TRIBMU]
							EndIf
							//CPRB
							If aPos[FP_FT_ALIQCPB]
								SFT->FT_ATIVCPB	:= aNfItem[nZ][IT_CODATIV]
							Endif
							If aPos[FP_FT_BASECPB] .And. aPos[FP_FT_VALCPB] .And. aPos[FP_FT_ALIQCPB]
								SFT->FT_BASECPB := aNfItem[nZ][IT_LIVRO][LF_BASECPB]
								SFT->FT_VALCPB  := aNfItem[nZ][IT_LIVRO][LF_VALCPB]
								SFT->FT_ALIQCPB := aNfItem[nZ][IT_LIVRO][LF_ALIQCPB]
							Endif
							If aPos[FP_FT_BASFUND] .And. aPos[FP_FT_VALFUND] .And. aPos[FP_FT_VALFUND]
                                SFT->FT_BASFUND := aNfItem[nZ][IT_BASFUND]
                                SFT->FT_ALIFUND := aNfItem[nZ][IT_ALIFUND]
                                SFT->FT_VALFUND := aNfItem[nZ][IT_VALFUND]
                            Endif
							If aPos[FP_FT_BASIMA]
								SFT->FT_BASIMA := aNfItem[nZ][IT_BASIMA]
							Endif
							If aPos[FP_FT_ALIIMA]
								SFT->FT_ALIIMA := aNfItem[nZ][IT_ALIIMA]
							Endif
							If aPos[FP_FT_VALIMA]
								SFT->FT_VALIMA := aNfItem[nZ][IT_VALIMA]
							Endif

							If aPos[FP_FT_BASFASE]
								SFT->FT_BASFASE := aNfItem[nZ][IT_BASFASE]
							Endif
							If aPos[FP_FT_ALIFASE]
								SFT->FT_ALIFASE := aNfItem[nZ][IT_ALIFASE]
							Endif
							If aPos[FP_FT_VALFASE]
								SFT->FT_VALFASE := aNfItem[nZ][IT_VALFASE]
							Endif

							If aPos[FP_FT_VOPDIF]
							     SFT->FT_VOPDIF := aNfItem[nZ][IT_VOPDIF]
							EndIf

							If aPos[FP_FT_ICMSDIF]
                              SFT->FT_ICMSDIF := aNfItem[nZ][IT_ICMSDIF]
                        	EndIf

							If aPos[FP_FT_COLVDIF]
                              SFT->FT_COLVDIF := aNfItem[nZ][IT_COLVDIF]
                        	EndIf

							//Processamento do SIGALOJA
							If aSX6[MV_LJLVFIS] == 2 .And. cTpOper == "S"

								If Empty((cAliasReproc)->F2_PDV) .And. !Empty((cAliasReproc)->F2_NFCUPOM)

									lLegislacao := Iif( cPaisLoc == "BRA" .And. LjAnalisaLeg(43)[1] , aDic[AI_MDL] , .F. )

									aAreaSL1 := SL1->(GetArea())
									SL1->(dbSetOrder(2))
									SL1->(MsSeek(xFilial() + SubStr((cAliasReproc)->F2_NFCUPOM, 1, 3) + SubStr((cAliasReproc)->F2_NFCUPOM, 4, GTamMxFis(TAM_FT_OBSERV)) ) )	// Serie + Numero da Nota

									SFT->FT_OBSERV  := Iif( lLegislacao , "F - Simples Faturamento" , "CF/SERIE:" + SL1->L1_DOC + "/" + SL1->L1_SERIE +  " ECF:" + SL1->L1_PDV )
									SFT->FT_ESPECIE := (cAliasReproc)->F2_ESPECIE
									RestArea(aAreaSL1)
								Else
									cLjEspecie := Alltrim((cAliasReproc)->F2_ESPECIE)

									If cLjEspecie == "CF" .Or. cLjEspecie == "ECF"
										If Len(aNfItem) > 0
											If aNfItem[nZ][IT_LIVRO][LF_TIPO] <> "S"
												SFT->FT_TIPO := "L"
											Else
												SFT->FT_OBSERV := "NOTA FISCAL DE SERVICO"
											EndIf
										EndIf
										SFT->FT_PDV	   :=(cAliasReproc)->F2_PDV
										If LjAnalisaLeg(18)[1]
											SFT->FT_ESPECIE := "ECF"
										Endif
									EndIf

									If (cLjEspecie == "SATCE" .Or. cLjEspecie == "NFCE")
										SFT->FT_PDV	   := (cAliasReproc)->F2_PDV
									EndIf
								EndIf
							EndIf

							IF aPos[FP_FT_BASNDES]
								SFT->FT_BASNDES	:= aNfItem[nZ][IT_BASNDES]
							EndIf
							If aPos[FP_FT_ICMNDES]
								SFT->FT_ICMNDES	:= aNfItem[nZ][IT_ICMNDES]
							EndIf
							IF aPos[FP_FT_GRPCST]
								SFT->FT_GRPCST	:= aNfItem[nZ][IT_GRPCST]
							EndIf
							IF aPos[FP_FT_CEST]
								SFT->FT_CEST	:= aNfItem[nZ][IT_CEST]
							EndIf
							IF aPos[FP_FT_DIFAL] .And. aPos[FP_FT_PDORI] .And. aPos[FP_FT_PDDES]
								SFT->FT_DIFAL	:= aNfItem[nZ][IT_DIFAL]
								SFT->FT_PDORI	:= aNfItem[nZ][IT_PDORI]
								SFT->FT_PDDES	:= aNfItem[nZ][IT_PDDES]
							EndIf
							IF aPos[FP_FT_VFCPDIF]
								SFT->FT_VFCPDIF	:= aNfItem[nZ][IT_VFCPDIF]
							EndIf
							IF aPos[FP_FT_BASEDES]
								SFT->FT_BASEDES	:= aNfItem[nZ][IT_BASEDES]
							EndIf
							//Cliente de destino para notas de entrada de transporte
							IF aPos[FP_FT_CLIDEST] .And. aPos[FP_FT_LOJDEST]
								SFT->FT_CLIDEST	:= aNfItem[nZ][IT_LIVRO][LF_CLIDEST]
								SFT->FT_LOJDEST	:= aNfItem[nZ][IT_LIVRO][LF_LOJDEST]
							Endif
							IF aPos[FP_FT_FTRICMS]
								SFT->FT_FTRICMS	:= aNfItem[nZ][IT_FTRICMS]
							EndIf
							IF aPos[FP_FT_VRDICMS]
								SFT->FT_VRDICMS	:= aNfItem[nZ][IT_VRDICMS]
							EndIf
							IF aPos[FP_FT_BSICMOR]
								SFT->FT_BSICMOR	:= aNfItem[nZ][IT_BICMORI]
							EndIf
							IF aPos[FP_FT_PRCMEDP]
								SFT->FT_PRCMEDP	:= aNfItem[nZ][IT_PRCMEDP]
							EndIf
							IF aPos[FP_FTIND]
                             SFT->FT_INDICE := aNfItem[nZ][IT_INDICE]
         	                EndIf

							If aPos[FP_FT_TAFKEY]
								SFT->FT_TAFKEY	:= ""
							EndIf
							IF aPos[FP_FT_VALPEDG]
								SFT->FT_VALPEDG	:= aNfItem[nZ][IT_VALPEDG]
							EndIf

							IF aPos[FP_FT_CSOSN]
								SFT->FT_CSOSN	:=	aNfItem[nZ][IT_CSOSN]
							EndIf

							IF aPos[FP_FT_BASEINP]
								SFT->FT_BASEINP	:=	aNfItem[nZ][IT_BASEINP]
							EndIf

							IF aPos[FP_FT_VALINP]
								SFT->FT_VALINP	:=	aNfItem[nZ][IT_VALINP]
							EndIf

							IF aPos[FP_FT_PERCINP]
								SFT->FT_PERCINP	:=	aNfItem[nZ][IT_PERCINP]
							EndIf

							IF aPos[FP_FT_BASEPRO]
								SFT->FT_BASEPRO	:=	aNfItem[nZ][IT_BASEPRO]
							EndIf

							IF aPos[FP_FT_ALIQPRO]
								SFT->FT_ALIQPRO	:=	aNfItem[nZ][IT_ALIQPRO]
							EndIf

							IF aPos[FP_FT_VALPRO]
								SFT->FT_VALPRO	:=	aNfItem[nZ][IT_VALPRO]
							EndIf

							IF aPos[FP_FT_BASFEEF]
								SFT->FT_BASFEEF	:=	aNfItem[nZ][IT_BASFEEF]
							EndIf

							IF aPos[FP_FT_ALQFEEF]
								SFT->FT_ALQFEEF	:=	aNfItem[nZ][IT_ALQFEEF]
							EndIf

							IF aPos[FP_FT_VALFEEF]
								SFT->FT_VALFEEF	:=	aNfItem[nZ][IT_VALFEEF]
							EndIf

							IF aPos[FP_FT_TES]
								SFT->FT_TES	:=	aNfItem[nZ][IT_TS][TS_CODIGO]
							EndIf

							If aPos[FP_FT_BFCPANT]
								SFT->FT_BFCPANT := aNfItem[nZ][IT_LIVRO][LF_BFCPANT]
							EndIf

							If aPos[FP_FT_AFCPANT]
								SFT->FT_AFCPANT := aNfItem[nZ][IT_LIVRO][LF_AFCPANT]
							EndIf

							If aPos[FP_FT_VFCPANT]
								SFT->FT_VFCPANT := aNfItem[nZ][IT_LIVRO][LF_VFCPANT]
							EndIf

							If aPos[FP_FT_ALQNDES]
								SFT->FT_ALQNDES := aNfItem[nZ][IT_LIVRO][LF_ALQNDES]
							EndIf

							If aPos[FP_FT_ALFCCMP]
								SFT->FT_ALFCCMP := aNfItem[nZ][IT_LIVRO][LF_ALFCCMP]
							EndIf

							If aPos[FP_FT_BASFECP]
								SFT->FT_BASFECP := aNfItem[nZ][IT_LIVRO][LF_BASFECP]
							EndIf

							If aPos[FP_FT_BSFCPST]
								SFT->FT_BSFCPST := aNfItem[nZ][IT_LIVRO][LF_BSFCPST]
							EndIf

							If aPos[FP_FT_BSFCCMP]
								SFT->FT_BSFCCMP := aNfItem[nZ][IT_LIVRO][LF_BSFCCMP]
							EndIf

							If aPos[FP_FT_FCPAUX]
								SFT->FT_FCPAUX := aNfItem[nZ][IT_LIVRO][LF_FCPAUX]
							EndIf

							If aPos[FP_FT_CLIDVMC] .And. aPos[FP_FT_LOJDVMC]
								SFT->FT_CLIDVMC := cCliDvMc
								SFT->FT_LOJDVMC := cLojDvMc
							EndIf

							//Contribuição Previdenciária (INSS) Especial
							If aPos[FP_FT_SECP15]
								SFT->FT_SECP15 	:= aNfItem[nZ][IT_SECP15]
							EndIf

							If aPos[FP_FT_BSCP15]
								SFT->FT_BSCP15 	:= aNfItem[nZ][IT_BSCP15]
							EndIf

							If aPos[FP_FT_ALCP15]
								SFT->FT_ALCP15	:= aNfItem[nZ][IT_ALCP15]
							EndIf

							If aPos[FP_FT_VLCP15]
								SFT->FT_VLCP15 := aNfItem[nZ][IT_VLCP15]
							EndIf

							If aPos[FP_FT_SECP20]
								SFT->FT_SECP20 := aNfItem[nZ][IT_SECP20]
							EndIf

							If aPos[FP_FT_BSCP20]
								SFT->FT_BSCP20 := aNfItem[nZ][IT_BSCP20]
							EndIf

							If aPos[FP_FT_ALCP20]
								SFT->FT_ALCP20 := aNfItem[nZ][IT_ALCP20]
							EndIf

							If aPos[FP_FT_VLCP20]
								SFT->FT_VLCP20 := aNfItem[nZ][IT_VLCP20]
							EndIf

							If aPos[FP_FT_SECP25]
								SFT->FT_SECP25 := aNfItem[nZ][IT_SECP25]
							EndIf

							If aPos[FP_FT_BSCP25]
								SFT->FT_BSCP25 := aNfItem[nZ][IT_BSCP25]
							EndIf

							If aPos[FP_FT_ALCP25]
								SFT->FT_ALCP25 := aNfItem[nZ][IT_ALCP25]
							EndIf

							If aPos[FP_FT_VLCP25]
								SFT->FT_VLCP25 := aNfItem[nZ][IT_VLCP25]
							EndIf

							// Campo para tratamento do layout Reinf 1.4  Bruce
							//Indica se o documento fiscal possui isenção da contribuição previdenciária de acordo com a lei  n° 13.606/2018
							If aPos[FP_FT_INDISEN]
								SFT->FT_INDISEN	:=	aNFItem[nZ][IT_TS][TS_INDISEN]
							EndIf

							If aPos[FP_FT_BSCPM]
								SFT->FT_BASECPM := aNfItem[nZ][IT_BASECPM]
							EndIf

							If aPos[FP_FT_ALCPM]
								SFT->FT_ALQCPM := aNfItem[nZ][IT_ALQCPM]
							EndIf

							If aPos[FP_FT_VLCPM]
								SFT->FT_VALCPM := aNfItem[nZ][IT_VALCPM]
							EndIf

							If aPos[FP_FT_IDTRIB]
								//Grava o campo de ID dos tributos genéricos
								If cFunOrig == "MATA930"
									//Para o reprocessamento será gavado o ID de load.
									SFT->FT_IDTRIB := aNfItem[nZ][IT_ID_LOAD_TRBGEN]
								ElseIF Len(aNfItem[nZ][IT_TRIBGEN]) > 0
									//Para demais operações será considerado o ID de geração caso exista tributo genérico calculado.
									SFT->FT_IDTRIB := aNfItem[nZ][IT_ID_TRBGEN]
								EndIF
								
								//-------------------------------------------------------
								//Gravação do livro dos tributos genéricos na tabela CJ3.
								//As regras estão concentradas no CONFXFIS.
								//-------------------------------------------------------
								If lCJ3										
									For nTrbGen:= 1 to Len(aNfItem[nZ][IT_TRIBGEN])
										//Gravação d livro dos tributos genéricos
										FisGrvCJ3(aNfItem, nZ, nTrbGen)

										//-------------------------------------------------------
										//Gravação do Histórico referente as ultimas notas de entrada,
										// que foram utilizadas na composição do valor de estorno de ICMS.
										//As regras estão concentradas no CONFXFIS .
										//A tabela CJM é que armazenará os dados.
										//-------------------------------------------------------
										If lCJM  
											// Controle de execução para Produtos com Estrutura na SG1
											If aNfItem[nZ][IT_TRIBGEN][nTrbGen][TG_IT_ESTR_ULT_AQUI] 
												GetCompUltAq(aNfItem[nZ][IT_PRODUTO],aNfCab,aNfItem,nZ,nTrbGen,cNumNF,cSerie,cCliFor,cLoja,nCaso)
											Endif
											// Controle de Execução para produtos que não possuem Estrutura (Revenda)
											If aNfItem[nZ][IT_TRIBGEN][nTrbGen][TG_IT_ULT_AQUI]
												GetUltAqui(aNfItem[nZ][IT_PRODUTO], aNfCab, aNfItem, nZ, nTrbGen, cNumNF, cSerie, cCliFor, cLoja, nCaso)
											Endif
										Endif

									Next nTrbGen
								EndIF

							EndIF

							If aPos[FP_FT_BICEFET]
								SFT->FT_BICEFET := aNfItem[nZ][IT_BICEFET]
							EndIf

							If aPos[FP_FT_ICEFET]
								SFT->FT_PICEFET := aNfItem[nZ][IT_PICEFET]
							EndIf

							If aPos[FP_FT_VICEFET]
								SFT->FT_VICEFET := aNfItem[nZ][IT_VICEFET]
							EndIf

							If aPos[FP_FT_RICEFET]
								SFT->FT_RICEFET := aNfItem[nZ][IT_RICEFET]
							EndIf

							If aPos[FP_FT_BSTANT]
								SFT->FT_BSTANT := aNfItem[nZ][IT_BSTANT]
							EndIf

							If aPos[FP_FT_PSTANT]
								SFT->FT_PSTANT := aNfItem[nZ][IT_PSTANT]
							EndIf

							If aPos[FP_FT_VSTANT]
								SFT->FT_VSTANT := aNfItem[nZ][IT_VSTANT]
							EndIf

							If aPos[FP_FT_VICPRST]
								SFT->FT_VICPRST := aNfItem[nZ][IT_VICPRST]
							EndIf

							If aPos[FP_FT_BFCANTS]
								SFT->FT_BFCANTS := aNfItem[nZ][IT_BFCANTS]
							EndIf

							If aPos[FP_FT_PFCANTS]
								SFT->FT_PFCANTS := aNfItem[nZ][IT_PFCANTS]
							EndIf

							If aPos[FP_FT_VFCANTS]
								SFT->FT_VFCANTS := aNfItem[nZ][IT_VFCANTS]
							EndIf

							If aPos[FP_FT_DESCFIS]
								SFT->FT_DESCFIS := aNfItem[nZ][IT_DESCFIS]
							EndIf

						EndIf

						If aDic[AI_CD2]
							For nA := 1 To Len(aNfItem[nZ][IT_SPED])
								If (aNfItem[nZ][IT_LIVRO][LF_IDENT]==aLivro[nX][LF_IDENT]) .And. !aNfItem[nZ][IT_DELETED]
									If !(aNfItem[nZ][IT_SPED][nA][SP_IMP]$"IPI" .And. aNfItem[nZ][IT_TS][TS_IPI] == "R") //Produto adquirido de atacadista, calcula, mas não destaca IPI na nota
									//EMPRESA PÚBLICA E ISENTO
										If SA1->A1_TPESSOA$"EP" .And. aNfItem[nZ][IT_SPED][nA][SP_CST] == "40" .And. aNfItem[nZ][IT_SPED][nA][SP_IMP]$"ICM"
											lIsenEP	:= .T.
										Endif
										RecLock("CD2",.T.)
										CD2->CD2_FILIAL := xFilial("CD2")
										CD2->CD2_TPMOV  := cTpOper
										SerieNfId("CD2",1,"CD2_SERIE",,,, cSerie )
										CD2->CD2_DOC    := cNumNF
										If (cTpOper == "S" .And. !aNfItem[nZ][IT_LIVRO][LF_TIPO]$"DB") .Or.;
											(cTpOper == "E" .And. aNfItem[nZ][IT_LIVRO][LF_TIPO]$"DB")
											CD2->CD2_CODCLI := cCliFor
											CD2->CD2_LOJCLI := cLoja
										Else
											CD2->CD2_CODFOR := cCliFor
											CD2->CD2_LOJFOR	:= cLoja
										EndIf
										CD2->CD2_ITEM   := aNfItem[nZ][IT_SPED][nA][SP_ITEM]
										CD2->CD2_CODPRO := aNfItem[nZ][IT_SPED][nA][SP_CODPRO]
										CD2->CD2_IMP    := aNfItem[nZ][IT_SPED][nA][SP_IMP]
										CD2->CD2_ORIGEM := aNfItem[nZ][IT_SPED][nA][SP_ORIGEM]
										CD2->CD2_CST    := aNfItem[nZ][IT_SPED][nA][SP_CST]
										CD2->CD2_MODBC  := aNfItem[nZ][IT_SPED][nA][SP_MODBC]
										CD2->CD2_MVA    := aNfItem[nZ][IT_SPED][nA][SP_MVA]
										If aNFItem[nZ][IT_TS][TS_BASEICM]==100 .And. aNfItem[nZ][IT_TS][TS_LFICM]$"IO" .And. aNfItem[nZ][IT_SPED][nA][SP_IMP]$"SOL|ICM"
											CD2->CD2_PREDBC := aNFItem[nZ][IT_TS][TS_BASEICM]
										Else
											CD2->CD2_PREDBC := aNfItem[nZ][IT_SPED][nA][SP_PREDBC]
										Endif
										CD2->CD2_BC     := IIf(!lIsenEP,aNfItem[nZ][IT_SPED][nA][SP_BC],0)
										CD2->CD2_ALIQ   := IIf(!lIsenEP,aNfItem[nZ][IT_SPED][nA][SP_ALIQ],0)
										CD2->CD2_VLTRIB := IIf(!lIsenEP,aNfItem[nZ][IT_SPED][nA][SP_VLTRIB],0)
										IF (aNfItem[nZ][IT_SPED][nA][SP_IMP]$ "PS2|CF2")
											CD2->CD2_QTRIB  := IIF(aSX6[MV_PISPAUT] .AND. aSX6[MV_PISCOFP],aNfItem[nZ][IT_SPED][nA][SP_BC],aNfItem[nZ][IT_SPED][nA][SP_QTRIB])
										ELSE
											CD2->CD2_QTRIB  := aNfItem[nZ][IT_SPED][nA][SP_QTRIB]
										ENDIF
										// Tratamento de Pauta de Pis e Cofins
										IF (aNfItem[nZ][IT_SPED][nA][SP_IMP]$ "PS2|CF2")
											If	(aNfItem[nZ][IT_SPED][nA][SP_IMP]$ "PS2") // PIS
												If (aNfItem[nZ][IT_VALPS2] > 0 .Or. aNfItem[nZ][IT_BASEPS2] > 0) .AND.(Empty(aNFitem[nZ,IT_EXCECAO]) .Or. Empty(aNFItem[nZ,IT_EXCECAO,10]) .Or. aNfItem[nZ,IT_QUANT]==0)
													CD2->CD2_PAUTA  := aNfItem[nZ][IT_PRD][SB_VLR_PIS]
												ELSEIF !Empty(aNfItem[nZ][IT_EXCECAO]) .And. !Empty(aNfItem[nZ][IT_EXCECAO][10])
													CD2->CD2_PAUTA  := aNFItem[nZ,IT_EXCECAO,10]
												ENDIF
											ELSE	//Cofins
												IF (aNfItem[nZ][IT_VALCF2] > 0 .Or. aNfItem[nZ][IT_BASECF2] > 0) .AND. (Empty(aNFitem[nZ,IT_EXCECAO]).Or.Empty(aNFItem[nZ,IT_EXCECAO,11]).Or.aNfItem[nZ,IT_QUANT]==0)
													CD2->CD2_PAUTA  := aNfItem[nZ][IT_PRD][SB_VLR_COF]
												ELSEIF !Empty(aNfItem[nZ][IT_EXCECAO]) .And. !Empty(aNfItem[nZ][IT_EXCECAO][11])
													CD2->CD2_PAUTA  := aNFItem[nZ,IT_EXCECAO,11]
												ENDIF
											ENDIF
										ELSE
											CD2->CD2_PAUTA  := aNfItem[nZ][IT_SPED]	[nA][SP_PAUTA]
										ENDIF
										CD2->CD2_COD_MN := aNfItem[nZ][IT_SPED][nA][SP_COD_MN]

										If aPos[FP_CD2_PARTIC]
											CD2->CD2_PARTIC  := aNfItem[nZ][IT_SPED][nA][SP_PARTICM]
										EndIf
										If aPos[FP_CD2_FORMU]
											CD2->CD2_FORMU  := cFormul
										EndIf
										If aPos[FP_CD2_DESCZF]
											CD2->CD2_DESCZF  := aNfItem[nZ][IT_SPED][nA][SP_DESCZF]
										EndIf
										If aPos[FP_CD2_GRPCST]
											CD2->CD2_GRPCST  := aNfItem[nZ][IT_SPED][nA][SP_GRPCST]
										EndIf
										If aPos[FP_CD2_CEST]
											CD2->CD2_CEST  := aNfItem[nZ][IT_SPED][nA][SP_CEST]
										EndIf
										If aPos[FP_CD2_PICMDF]
											CD2->CD2_PICMDF := aNfItem[nZ][IT_SPED][nA][SP_PICMDIF]
										EndIf
										If aPos[FP_CD2_PDDES] .And. aPos[FP_CD2_PDORI] .And. aPos[FP_CD2_VDDES] .And. aPos[FP_CD2_ADIF] .And. aPos[FP_CD2_PFCP] .And. aPos[FP_CD2_VFCP]
											CD2->CD2_VDDES := aNfItem[nZ][IT_SPED][nA][SP_VDDES]
											CD2->CD2_PDDES := aNfItem[nZ][IT_SPED][nA][SP_PDDES]
											CD2->CD2_PDORI := aNfItem[nZ][IT_SPED][nA][SP_PDORI]
											CD2->CD2_ADIF := aNfItem[nZ][IT_SPED][nA][SP_ADIF]
											CD2->CD2_PFCP := aNfItem[nZ][IT_SPED][nA][SP_PFCP]
											CD2->CD2_VFCP := aNfItem[nZ][IT_SPED][nA][SP_VFCP]
										Endif
										If aPos[FP_CD2_DESONE]
											CD2->CD2_DESONE := aNfItem[nZ][IT_SPED][nA][SP_DESONE]
										EndIf
										If aPos[FP_CD2_PDEVOL]
											CD2->CD2_PDEVOL := aNfItem[nZ][IT_SPED][nA][SP_PDEVOL]
										EndIf
										If aPos[FP_CD2_BFCP]
											CD2->CD2_BFCP := aNfItem[nZ][IT_SPED][nA][SP_BFCP]
										EndIf
										If aPos[FP_CD2_PSCFST]
											CD2->CD2_PSCFST := aNFItem[nZ][IT_TS][TS_APSCFST]
										EndIf
										If aPos[FP_CD2_VFCPDI] .And. aNFItem[nZ][IT_TS][TS_ICMSDIF] <> "2" //Só calcula o valor de diferimento do FCP caso o campo F4_ICMSDIF esteja diferente de '2-Não Diferido'
											CD2->CD2_VFCPDI := Round(aNfItem[nZ][IT_SPED][nA][SP_VFCP] * (aNfItem[nZ][IT_SPED][nA][SP_PICMDIF]/100),2)
										EndIf
										If aPos[FP_CD2_VFCPEF]
											If aNFItem[nZ][IT_TS][TS_ICMSDIF] <> "2"
												aNfItem[nZ][IT_SPED][nA][SP_VFCP] := Round(aNfItem[nZ][IT_SPED][nA][SP_VFCP],2) 
												CD2->CD2_VFCPEF := aNfItem[nZ][IT_SPED][nA][SP_VFCP] - (aNfItem[nZ][IT_SPED][nA][SP_VFCP] * (aNfItem[nZ][IT_SPED][nA][SP_PICMDIF]/100))
											Else
												CD2->CD2_VFCPEF := aNfItem[nZ][IT_SPED][nA][SP_VFCP]
											Endif
										EndIf
										If aPos[FP_CD2_FCPAJT]
											CD2->CD2_FCPAJT := aNfItem[nZ][IT_SPED][nA][SP_FCPAJT]
										EndIf	
										lIsenEP	:= .F.
										MsUnLock()
									Endif
								Endif
							Next nA
						EndIf
						If (aNfItem[nZ][IT_LIVRO][LF_IDENT]==aLivro[nX][LF_IDENT]) .And. !aNfItem[nZ][IT_DELETED]
							// Ponto de entrada para atualizar o Relac.Imp.Doc.Fiscal e/ou Livro Fiscal por Item
							If aPE[PE_XFCD2SFT]
								ExecBlock("XFCD2SFT",.F.,.F.)
							EndIf
						EndIf
					Next nZ
				EndIf
			EndIf
		Next nX
	EndIf

	// Deleta os registros fiscais cancelados.
	If Len(aRecSF3) > Len(aLivro)
		For nX := (Len(aLivro)+1) To Len(aRecSF3)
			//Exclui as tabelas de complementos por NF do Sped
			If lSped
				M926DlSped(1,SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO)
			Endif
			SF3->(MsGoto(aRecSF3[nX]))
			RecLock("SF3",.F.)
			SF3->(dbDelete())
		Next nX
	EndIf

	If (cPaisLoc=="BRA" .And. aDic[AI_SFT] )
		If Len(aRecSFT) > Len(aNfItem)
			For nX := (Len(aNfItem)+1) To Len(aRecSFT)
				//Exclui as tabelas de complementos por item do Sped
				If lSped
					M926DlSped(2,SFT->FT_NFISCAL,SFT->FT_SERIE,SFT->FT_CLIEFOR,SFT->FT_LOJA,SFT->FT_TIPOMOV,SFT->FT_ITEM,SFT->FT_PRODUTO)
				Endif
				SFT->(MsGoto(aRecSFT[nX]))
				RecLock("SFT",.F.)

				If aPos[FP_FT_TAFKEY]
					SFT->FT_TAFKEY	:= ""
				EndIf

				SFT->(dbDelete())
			Next nX
		EndIf
	EndIf
Case nCD2 == 1
	If (cPaisLoc=="BRA" .And. aDic[AI_CD2])
		dbSelectArea("CD2")
		dbSetOrder(2)
		#IFDEF TOP
			If TcSrvType()<>"AS/400"
				cAliasCD2 := "MaFisAtuCD2"
				lQuery    := .T.
				cQuery := "SELECT CD2_FILIAL,CD2_TPMOV,CD2_DOC,CD2_SERIE,CD2_CODCLI,CD2_LOJCLI,CD2_CODFOR,CD2_LOJFOR,R_E_C_N_O_ CD2RECNO "
				cQuery += "FROM "+RetSqlName("CD2")+" CD2 "
				cQuery += "WHERE CD2.CD2_FILIAL='"+xFilial("CD2")+"' AND "
				cQuery += "CD2.CD2_SERIE='"+cSerie+"' AND "
				cQuery += "CD2.CD2_DOC='"+cNumNF+"' AND "
				cQuery += "CD2.CD2_TPMOV='"+cTpOper+"' AND "
				If (cTpOper=="E" .And. !aNfCab[NF_TIPONF]$"DB")
					If !cFormul=="S"
					cQuery += "CD2.CD2_CODFOR='"+cCliFor+"' AND "
					cQuery += "CD2.CD2_LOJFOR='"+cLoja+"' AND "
					EndIf
				EndIf
				If aPos[FP_CD2_FORMU] .And. cFormul=="S"
					cQuery += "CD2.CD2_FORMU='S' AND "
				EndIf
				cQuery += "CD2.D_E_L_E_T_=' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCD2)
			Else
		#ENDIF
				MsSeek(xFilial("CD2")+cTpOper+cSerie+cNumNF+IIf(!(cTpOper=="S".Or.cFormul=="S"),cCliFor+cLoja,""))
		#IFDEF TOP
			EndIf
		#ENDIF
		While (!Eof() .And.;
			(cAliasCD2)->CD2_FILIAL == xFilial("CD2") .And.;
			(cAliasCD2)->CD2_TPMOV  == cTpOper	.And.;
			(cAliasCD2)->CD2_DOC    == cNumNF  .And.;
			(cAliasCD2)->CD2_SERIE  == cSerie  .And.;
			IIf(cTpOper=="S" .Or. (cTpOper=="E" .And. aNfCab[NF_TIPONF]$"DB") .Or. cFormul=="S",.T.,(cAliasCD2)->CD2_CODFOR == cCliFor .And. (cAliasCD2)->CD2_LOJFOR == cLoja))

			If lQuery
				CD2->(dbGoto((cAliasCD2)->CD2RECNO))
			EndIf

			RecLock("CD2")
			dbdelete()
			MsUnLock()

			dbSelectArea(cAliasCD2)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasCD2)
			dbCloseArea()
			dbSelectArea("CD2")
		EndIf
	EndIf
	For nZ := 1 To Len(aNfItem)
		
		If aDic[AI_CD2]
			For nA := 1 To Len(aNfItem[nZ][IT_SPED])
				If !aNfItem[nZ][IT_DELETED]
					If !(aNfItem[nZ][IT_SPED][nA][SP_IMP]$"IPI" .And. aNfItem[nZ][IT_TS][TS_IPI] == "R")
						RecLock("CD2",.T.)
						CD2->CD2_FILIAL := xFilial("CD2")
						CD2->CD2_TPMOV  := cTpOper
						SerieNfId("CD2",1,"CD2_SERIE",,,, cSerie )
						CD2->CD2_DOC    := cNumNF
						If (cTpOper == "S" .And. !aNfItem[nZ][IT_LIVRO][LF_TIPO]$"DB") .Or.;
							(cTpOper == "E" .And. aNfItem[nZ][IT_LIVRO][LF_TIPO]$"DB")
							CD2->CD2_CODCLI := cCliFor
							CD2->CD2_LOJCLI := cLoja
						Else
							CD2->CD2_CODFOR := cCliFor
							CD2->CD2_LOJFOR	:= cLoja
						EndIf
						CD2->CD2_ITEM   := aNfItem[nZ][IT_SPED][nA][SP_ITEM]
						CD2->CD2_CODPRO := aNfItem[nZ][IT_SPED][nA][SP_CODPRO]
						CD2->CD2_IMP    := aNfItem[nZ][IT_SPED][nA][SP_IMP]
						CD2->CD2_ORIGEM := aNfItem[nZ][IT_SPED][nA][SP_ORIGEM]
						CD2->CD2_CST    := aNfItem[nZ][IT_SPED][nA][SP_CST]
						CD2->CD2_MODBC  := aNfItem[nZ][IT_SPED][nA][SP_MODBC]
						CD2->CD2_MVA    := aNfItem[nZ][IT_SPED][nA][SP_MVA]
						If aNFItem[nZ][IT_TS][TS_BASEICM]== 100 .And. aNfItem[nZ][IT_LIVRO][LF_TIPO]$"IO" .And. aNfItem[nZ][IT_SPED][nA][SP_IMP]$"SOL|ICM"
							CD2->CD2_PREDBC := aNFItem[nZ][IT_TS][TS_BASEICM]
						Else
							CD2->CD2_PREDBC := aNfItem[nZ][IT_SPED][nA][SP_PREDBC]
						Endif
						CD2->CD2_BC     := aNfItem[nZ][IT_SPED][nA][SP_BC]
						CD2->CD2_ALIQ   := aNfItem[nZ][IT_SPED][nA][SP_ALIQ]
						CD2->CD2_VLTRIB := aNfItem[nZ][IT_SPED][nA][SP_VLTRIB]
						CD2->CD2_QTRIB  := aNfItem[nZ][IT_SPED][nA][SP_QTRIB]
						CD2->CD2_PAUTA  := aNfItem[nZ][IT_SPED][nA][SP_PAUTA]
						CD2->CD2_COD_MN := aNfItem[nZ][IT_SPED][nA][SP_COD_MN]
						If aPos[FP_CD2_FORMU]
							CD2->CD2_FORMU  := cFormul
						EndIf
						If aPos[FP_CD2_DESCZF]
							CD2->CD2_DESCZF := aNfItem[nZ][IT_SPED][nA][SP_DESCZF]
						EndIf
						If aPos[FP_CD2_GRPCST]
							CD2->CD2_GRPCST  := aNfItem[nZ][IT_SPED][nA][SP_GRPCST]
						EndIf
						If aPos[FP_CD2_CEST]
							CD2->CD2_CEST  := aNfItem[nZ][IT_SPED][nA][SP_CEST]
						EndIf
						If aPos[FP_CD2_PICMDF]
							CD2->CD2_PICMDF := aNfItem[nZ][IT_SPED][nA][SP_PICMDIF]
						EndIf
						If aPos[FP_CD2_PDDES] .And. aPos[FP_CD2_PDORI] .And. aPos[FP_CD2_VDDES] .And. aPos[FP_CD2_ADIF] .And. aPos[FP_CD2_PFCP] .And. aPos[FP_CD2_VFCP]
							CD2->CD2_VDDES := aNfItem[nZ][IT_SPED][nA][SP_VDDES]
							CD2->CD2_PDDES := aNfItem[nZ][IT_SPED][nA][SP_PDDES]
							CD2->CD2_PDORI := aNfItem[nZ][IT_SPED][nA][SP_PDORI]
							CD2->CD2_ADIF := aNfItem[nZ][IT_SPED][nA][SP_ADIF]
							CD2->CD2_PFCP := aNfItem[nZ][IT_SPED][nA][SP_PFCP]
							CD2->CD2_VFCP := aNfItem[nZ][IT_SPED][nA][SP_VFCP]
						Endif
						If aPos[FP_CD2_DESONE]
							CD2->CD2_DESONE := aNfItem[nZ][IT_SPED][nA][SP_DESONE]
						EndIf
						If aPos[FP_CD2_PDEVOL]
							CD2->CD2_PDEVOL := aNfItem[nZ][IT_SPED][nA][SP_PDEVOL]
						EndIf
						If aPos[FP_CD2_BFCP]
							CD2->CD2_BFCP := aNfItem[nZ][IT_SPED][nA][SP_BFCP]
						EndIf
						If aPos[FP_CD2_PSCFST]
							CD2->CD2_PSCFST := aNFItem[nZ][IT_TS][TS_APSCFST]
						EndIf
						If aPos[FP_CD2_VFCPDI] .And. aNFItem[nZ][IT_TS][TS_ICMSDIF] <> "2" //Só calcula o valor de diferimento do FCP caso o campo F4_ICMSDIF esteja diferente de '2-Não Diferido'
							CD2->CD2_VFCPDI := Round(aNfItem[nZ][IT_SPED][nA][SP_VFCP] * (aNfItem[nZ][IT_SPED][nA][SP_PICMDIF]/100),2)
						EndIf
						If aPos[FP_CD2_VFCPEF]
							If aNFItem[nZ][IT_TS][TS_ICMSDIF] <> "2"
								aNfItem[nZ][IT_SPED][nA][SP_VFCP] := Round(aNfItem[nZ][IT_SPED][nA][SP_VFCP],2) 
								CD2->CD2_VFCPEF := aNfItem[nZ][IT_SPED][nA][SP_VFCP] - (aNfItem[nZ][IT_SPED][nA][SP_VFCP] * (aNfItem[nZ][IT_SPED][nA][SP_PICMDIF]/100))
							Else
								CD2->CD2_VFCPEF := aNfItem[nZ][IT_SPED][nA][SP_VFCP]
							Endif
						EndIf
						MsUnLock()
					Endif
				Endif
			Next nA
		EndIf
	Next nZ
	// Ponto de entrada para atualizar o Relac.Imp.Doc.Fiscal e/ou Livro Fiscal por Item
	If aPE[PE_XFCD2SFT]
		ExecBlock("XFCD2SFT",.F.,.F.)
	EndIf

OtherWise
	If (cPaisLoc=="BRA" .And. aDic[AI_CD2])
		dbSelectArea("CD2")
		dbSetOrder(2)
		#IFDEF TOP
			If TcSrvType()<>"AS/400"
				cAliasCD2 := "MaFisAtuCD2"
				lQuery    := .T.
				cQuery := "SELECT CD2_FILIAL,CD2_TPMOV,CD2_DOC,CD2_SERIE,CD2_CODCLI,CD2_LOJCLI,CD2_CODFOR,CD2_LOJFOR,R_E_C_N_O_ CD2RECNO "
				cQuery += "FROM "+RetSqlName("CD2")+" CD2 "
				cQuery += "WHERE CD2.CD2_FILIAL='"+xFilial("CD2")+"' AND "
				cQuery += "CD2.CD2_SERIE='"+cSerie+"' AND "
				cQuery += "CD2.CD2_DOC='"+cNumNF+"' AND "
				cQuery += "CD2.CD2_TPMOV='"+cTpOper+"' AND "
				If (cTpOper=="E" .And. !aNfCab[NF_TIPONF]$"DB")
					If !cFormul=="S"
					cQuery += "CD2.CD2_CODFOR='"+cCliFor+"' AND "
					cQuery += "CD2.CD2_LOJFOR='"+cLoja+"' AND "
					EndIf
				EndIf
				If aPos[FP_CD2_FORMU] .And. cFormul=="S"
					cQuery += "CD2.CD2_FORMU='S' AND "
				EndIf
				cQuery += "CD2.D_E_L_E_T_=' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCD2)
			Else
		#ENDIF
				MsSeek(xFilial("CD2")+cTpOper+cSerie+cNumNF+IIf(!(cTpOper=="S".Or.cFormul=="S"),cCliFor+cLoja,""))
		#IFDEF TOP
			EndIf
		#ENDIF
		While (!Eof() .And.;
			(cAliasCD2)->CD2_FILIAL == xFilial("CD2") .And.;
			(cAliasCD2)->CD2_TPMOV  == cTpOper	.And.;
			(cAliasCD2)->CD2_DOC    == cNumNF  .And.;
			(cAliasCD2)->CD2_SERIE  == cSerie  .And.;
			IIf(cTpOper=="S" .Or. (cTpOper=="E" .And. aNfCab[NF_TIPONF]$"DB") .Or. cFormul=="S",.T.,(cAliasCD2)->CD2_CODFOR == cCliFor .And. (cAliasCD2)->CD2_LOJFOR == cLoja))

			If lQuery
				CD2->(dbGoto((cAliasCD2)->CD2RECNO))
			EndIf

			RecLock("CD2")
			dbdelete()
			MsUnLock()

			dbSelectArea(cAliasCD2)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasCD2)
			dbCloseArea()
			dbSelectArea("CD2")
		EndIf
	EndIf

	// Carega o Array contendo os Registros Fiscais (SF3)
	dbSelectArea("SF3")
	dbSetOrder(If(cTpOper == "S".Or.cFormul=="S",5,4))
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			cAliasSF3 := "MaFisAtuSF3"
			lQuery    := .T.
			cQuery := "SELECT F3_FILIAL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,"
			cQuery += "F3_LOJA,F3_CFO,F3_FORMUL,R_E_C_N_O_ SF3RECNO "
			cQuery += "FROM "+RetSqlName("SF3")+" SF3 "
			cQuery += "WHERE SF3.F3_FILIAL='"+xFilial("SF3")+"' AND "
			cQuery += "SF3.F3_SERIE='"+cSerie+"' AND "
			cQuery += "SF3.F3_NFISCAL='"+cNumNF+"' AND "
         If cPaisLoc<>"BRA" .or. !(cTpOper=="S".Or.cFormul=="S")
				cQuery += "SF3.F3_CLIEFOR='"+cCliFor+"' AND "
				cQuery += "SF3.F3_LOJA='"+cLoja+"' AND "
			EndIf
			cQuery += "SF3.D_E_L_E_T_=' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
		Else
	#ENDIF
		MsSeek(xFilial("SF3")+IIf(cTpOper=="S".Or.cFormul=="S",cSerie+cNumNF,cCliFor+cLoja+cNumNF+cSerie))
		#IFDEF TOP
		EndIf
		#ENDIF
	While (!Eof().And. (cAliasSF3)->F3_FILIAL == xFilial("SF3") .And.;
			(cAliasSF3)->F3_NFISCAL == cNumNF .And.;
			(cAliasSF3)->F3_SERIE == cSerie .And.;
			IIf(cTpOper=="S".Or.cFormul=="S",.T.,(cAliasSF3)->F3_CLIEFOR == cCliFor .And.;
			(cAliasSF3)->F3_LOJA == cLoja) )
		If ((cTpOper == "E" .And. Substr((cAliasSF3)->F3_CFO,1,1) < "5" .And. (cAliasSF3)->F3_FORMUL == cFormul) .Or.;
				(cTpOper == "S" .And. Substr((cAliasSF3)->F3_CFO,1,1) > "4")) .Or. ( (SubStr((cAliasSF3)->F3_CFO,1,3)$"999#000") )
			If lQuery
				aadd(aRecSF3,(cAliasSF3)->SF3RECNO)
			Else
				aadd(aRecSF3,RecNo())
			EndIf
		EndIf
		dbSelectArea(cAliasSF3)
		dbSkip()
	EndDo
	If lQuery
		dbSelectArea(cAliasSF3)
		dbCloseArea()
		dbSelectArea("SF3")
	EndIf
	If (cPaisLoc=="BRA" .And. aDic[AI_SFT] )
		dbSelectArea("SFT")
		dbSetOrder(1)
		#IFDEF TOP
			cAliasSFT := "MaFisAtuSFT"
			lQuery    := .T.
			cQuery := "SELECT FT_FILIAL, FT_TIPOMOV, FT_NFISCAL,FT_SERIE,FT_CLIEFOR,FT_LOJA,"
			cQuery += "FT_CFOP,FT_FORMUL,FT_DTCANC, R_E_C_N_O_ SFTRECNO "
			cQuery += "FROM "+RetSqlName("SFT")+" SFT "
			cQuery += "WHERE SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
			cQuery += "SFT.FT_TIPOMOV='"+cTpOper+"' AND "
			cQuery += "SFT.FT_SERIE='"+cSerie+"' AND "
			cQuery += "SFT.FT_NFISCAL='"+cNumNF+"' AND "
			If !(cTpOper=="S".Or.cFormul=="S")
				cQuery += "SFT.FT_CLIEFOR='"+cCliFor+"' AND "
				cQuery += "SFT.FT_LOJA='"+cLoja+"' AND "
			EndIf
			cQuery += "SFT.D_E_L_E_T_=' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFT)
			TcSetField(cAliasSFT,"FT_DTCANC","D",8,0)
		#ELSE
			MsSeek(xFilial("SFT")+cTpOper+cSerie+cNumNF+IIf(!(cTpOper=="S".Or.cFormul=="S"),cCliFor+cLoja,""))
		#ENDIF
		While (!Eof().And. (cAliasSFT)->FT_FILIAL == xFilial("SFT") .And.;
			(cAliasSFT)->FT_NFISCAL == cNumNF .And. (cAliasSFT)->FT_SERIE == cSerie .And.;
			IIf(cTpOper=="S".Or.cFormul=="S",.T.,(cAliasSFT)->FT_CLIEFOR == cCliFor .And. (cAliasSFT)->FT_LOJA == cLoja) )
			If ((cTpOper == "E" .And. Substr((cAliasSFT)->FT_CFOP,1,1) < "5" .And. (cAliasSFT)->FT_FORMUL == cFormul) .Or.;
					(cTpOper == "S" .And. Substr((cAliasSFT)->FT_CFOP,1,1) > "4")) .Or. ( (SubStr((cAliasSFT)->FT_CFOP,1,3)$"999#000") )
				If lQuery
					aadd(aRecSFT,(cAliasSFT)->SFTRECNO)
				Else
					aadd(aRecSFT,RecNo())
				EndIf
			EndIf
			dbSelectArea(cAliasSFT)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasSFT)
			dbCloseArea()
			dbSelectArea("SFT")
		EndIf
	EndIf
	// Cancelamento dos Livros Fiscais.
	dbSelectArea('SF3')
	For nX := 1 to Len(aRecSF3)
		If cFormul == "S" .Or. cTpOper == "S"
			MsGoto(aRecSF3[nX])

			//Exclui complementos da nota (mata926)
			If lSped
				M926DlSped(1,SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO)
			Endif

			RecLock("SF3",.F.)
			If IIf(cPaisLoc<>"BRA",lAnulaSF3,.T.)
				SF3->F3_DTCANC := dDataBase
				If nModulo = 43
					SF3->F3_OBSERV := STR0046	//"CTE CANCELADO"
				Else
					If aPos[FP_F3_SERSAT] .And. !Empty(SF3->F3_SERSAT)
						SF3->F3_OBSERV := "CF-e-SAT Cancelado " + cNfisCanc //Alteração Bruno Seiji //"Adicionado o numero do documento de cancelamento do SAT junto ao campo OBSERV para que seja exibido no livro fiscal"
						If aPos[FP_F3_NFISCAN]
							SF3->F3_NFISCAN := cNfisCanc
						EndIf
					Else
						SF3->F3_OBSERV := Iif("DENEGADA"$SF3->F3_OBSERV,STR0008+"/"+SF3->F3_OBSERV,STR0008) //"NF CANCELADA" OU "NF CANCELADA/NF DENEGADA"
					EndIf
				EndIf
				If cPaisLoc == "DOM"
					If aPos[FP_F3_TIPANUL] .And. FindFunction("LcGetTAnu") // Tipo Anulacao Republica Dominicana
						SF3->F3_TIPANUL := LcGetTAnu() //Funcao Localizada em LocXNF
					EndIf
					If aPos[FP_F3_NCF]
						SF3->F3_NCF := &((cAlias)->(PrefixoCpo(cAlias)+"_NCF"))
					EndIf
				EndIf

				If cPaisLoc == "ARG" .And. lProcArg
					// Rotina para marcar todas as notas fiscais que o campo F3_NFISCAL = F3_NFAGREG
					cClieForn := SF3->F3_CLIEFOR
					cLojac    := SF3->F3_LOJA
					cSeriec   := SF3->F3_SERIE
					cNfAgreg  := SF3->F3_NFISCAL
					//
					While !EOF() .And. SF3->F3_FILIAL==xFilial("SF3") .And.;
						SF3->F3_CLIEFOR==cClieForn	.And. SF3->F3_LOJA==cLojac	.And.;
						SF3->F3_NFAGREG==cNfAgreg .And. SF3->F3_SERIE == cSeriec
						//
						RecLock("SF3",.F.)
						If  SF3->F3_NFAGREG==SF3->F3_NFISCAL
							SF3->F3_OBSERV := Iif("DENEGADA"$SF3->F3_OBSERV,STR0008+"/"+SF3->F3_OBSERV,STR0008) //"NF CANCELADA" OU "NF CANCELADA/NF DENEGADA"
						Endif
						SF3->F3_DTCANC := dDataBase
						DbSkip()
						Loop
					EndDo
				Endif
			Else

				If cPaisLoc == "ARG" .And. lProcArg .And. !Empty(SF3->F3_NFAGREG)
					// Rotina para deletar todas as notas fiscais que o campo F3_NFISCAL = F3_NFAGREG
					cClieForn := SF3->F3_CLIEFOR
					cLojac    := SF3->F3_LOJA
					cSeriec   := SF3->F3_SERIE
					cNfAgreg  := SF3->F3_NFISCAL
					//
					While !Eof() .And. SF3->F3_FILIAL==xFilial("SF3") .And.;
						SF3->F3_CLIEFOR==cClieForn	.And. SF3->F3_LOJA==cLojac	.And.;
						SF3->F3_NFAGREG==cNfAgreg .And. SF3->F3_SERIE == cSeriec
						//
						RecLock("SF3",.F.)
						DbDelete()
						MsUnLock()
						DbSkip()
						Loop
					EndDo
				Else
					dbDelete()
				Endif
			EndIf
			MsUnlock()
			If cTpOper == "S"
				// Pto de Entrada utilizado na Argentina
				If aPE[PE_M520SF3]
					ExecBlock("M520SF3",.F.,.F.)
				Endif
			EndIf
		Else
			MsGoto(aRecSF3[nX])
			//Exclui as tabelas de complementos por NF do Sped
			If lSped
				M926DlSped(1,SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA,SF3->F3_CFO)
			Endif
			RecLock("SF3",.F.,.T.)
			dbDelete()
		EndIf
	Next nX
	If (cPaisLoc=="BRA" .And. aDic[AI_SFT])
		dbSelectArea("SFT")
		For nX := 1 to Len(aRecSFT)
			If cFormul == "S" .Or. cTpOper == "S"
				MsGoto(aRecSFT[nX])

				//Exclução de complementos da nota (MATA926)
				If lSped
					M926DlSped(2,SFT->FT_NFISCAL,SFT->FT_SERIE,SFT->FT_CLIEFOR,SFT->FT_LOJA,SFT->FT_TIPOMOV,SFT->FT_ITEM,SFT->FT_PRODUTO)
				Endif

				RecLock("SFT",.F.)

				If aPos[FP_FT_TAFKEY]
					SFT->FT_TAFKEY	:= ""
				EndIf

				If IIf(cPaisLoc<>"BRA",lAnulaSF3,.T.)
					SFT->FT_DTCANC := dDataBase
					If aPos[FP_FT_SERSAT] .And. !Empty(SFT->FT_SERSAT)
						SFT->FT_OBSERV := "CF-e-SAT Cancelado " + cNfisCanc //Alteração Bruno Seiji //"Adicionado o numero do documento de cancelamento do SAT junto ao campo OBSERV para que seja exibido no livro fiscal"
						If aPos[FP_FT_NFISCAN]
							SFT->FT_NFISCAN := cNfisCanc
						EndIf
					Else
						SFT->FT_OBSERV := Iif("DENEGADA"$SFT->FT_OBSERV,STR0008+"/"+SFT->FT_OBSERV,STR0008) //"NF CANCELADA" OU "NF CANCELADA/NF DENEGADA"
					EndIf
				Else
					dbDelete()
				EndIf
				MsUnlock()
				If cTpOper == "S"
					// Pto de Entrada utilizado na Argentina
					If aPE[PE_M520SFT]
						ExecBlock("M520SFT",.F.,.F.)
					Endif
				EndIf
			Else
				MsGoto(aRecSFT[nX])
				//Exclui as tabelas de complementos por item do Sped
				If lSped
					M926DlSped(2,SFT->FT_NFISCAL,SFT->FT_SERIE,SFT->FT_CLIEFOR,SFT->FT_LOJA,SFT->FT_TIPOMOV,SFT->FT_ITEM,SFT->FT_PRODUTO)
				Endif
				RecLock("SFT",.F.)

				If aPos[FP_FT_TAFKEY]
					SFT->FT_TAFKEY	:= ""
				EndIf

				dbDelete()
			EndIf
		Next nX
	EndIf
EndCase

If cPaisLoc == "BRA" .And. aSX6[MV_INTTAF] == "S" .And. lVldIntTAF .And. aPos[FP_FT_TAFKEY]
	// Chama Job para intregacao NATIVA do documento fiscal no TAF
	If lTAFVldAmb
		/*
			Função para executar o job do extrator do TAF.
		 	Esse função controla a execução do job para que seja executado somente um job por empresa e filial da SFT.
		 	O Job em execução verifica todos os registros da SFT que não foram integrados.
		 	@author Vitor Ribeiro
		 	@since 06/12/2017
		*/
		ExtTafFExc()
    EndIf
EndIf

//## Chamada da função de construção da mensagem.
If lExecCja .And. ((nCaso == 1 .And. aNfCab[NF_TEMF2B]) .Or. nCaso == 2 )
	FISXDAGR(@oHMCad, lBuild, aNfCab, aNfItem, aPos, aSX6, aDic, aPE, aInfNat,cNumNF, cSerie, cCliFor, cLoja,cFormul,cEspecie, cTpOper, nCaso )
Endif

// Chamada da Função para Excluir registros na Tabela CJM - Contra Prova Ultima Entrada .
If lCJM .And. nCaso == 2 .and. cTpOper=='S'
    FisDelCjm(cNumNF, cSerie, cCliFor, cLoja)
Endif

RestArea(aAreaSF1)
RestArea(aAreaSF2)
RestArea(aArea)

Return(.T.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³xFisAFixos³ Autor ³ Juan Jose Pereira     ³ Data ³ 30/01/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera array aFixo com extrutura do SF3                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function xFisAFixos()

Local aFixos  := {}
Local aArea   := {}
Local aSX3    := {}

If aCposSF3 == Nil
	If cPaisLoc=="BRA"
		AADD(aFixos,{"F3_CFO",		""})
		AADD(aFixos,{"F3_ALIQICM",	0})
		AADD(aFixos,{"F3_VALCONT",	0})
		AADD(aFixos,{"F3_BASEICM",	0})
		AADD(aFixos,{"F3_VALICM",	0})
		AADD(aFixos,{"F3_ISENICM",	0})
		AADD(aFixos,{"F3_OUTRICM",	0})
		AADD(aFixos,{"F3_BASEIPI",	0})
		AADD(aFixos,{"F3_VALIPI",	0})
		AADD(aFixos,{"F3_ISENIPI",	0})
		AADD(aFixos,{"F3_OUTRIPI",	0})
		AADD(aFixos,{"F3_OBSERV",	""})
		AADD(aFixos,{"F3_VALOBSE",	0})
		AADD(aFixos,{"F3_ICMSRET",	0})
		AADD(aFixos,{"F3_LANCAM",	""})
		AADD(aFixos,{"F3_TIPO",		""})
		AADD(aFixos,{"F3_ICMSCOM",	0})
		AADD(aFixos,{"F3_CODISS",	""})
		AADD(aFixos,{"F3_IPIOBS",	0})
		AADD(aFixos,{"F3_NRLIVRO",	""})
		AADD(aFixos,{"F3_ICMAUTO",	0})
		AADD(aFixos,{"F3_BASERET",	0})
		AADD(aFixos,{"F3_FORMUL",	""})
		AADD(aFixos,{"F3_FORMULA",	""})
		AADD(aFixos,{"F3_DESPESA",	0})
		AADD(aFixos,{"F3_ICMSDIF",	0})
		AADD(aFixos,{"F3_TRFICM",	0})

		If ( SF3->(FieldPos("F3_OBSICM"))>0 )
			AADD(aFixos,{"F3_OBSICM",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If ( SF3->(FieldPos("F3_OBSSOL"))>0 )
			AADD(aFixos,{"F3_OBSSOL",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If ( SF3->(FieldPos("F3_SOLTRIB"))>0 )
			AADD(aFixos,{"F3_SOLTRIB",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If ( SF3->(FieldPos("F3_CFOEXT"))>0 )
			AADD(aFixos,{"F3_CFOEXT",""})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		AADD(aFixos,{"F3_ISSST",""})

		If ( SF3->(FieldPos("F3_RECISS"))>0 )
			AADD(aFixos,{"F3_RECISS",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		If ( SF3->(FieldPos("F3_ISSSUB"))>0 )
			AADD(aFixos,{"F3_ISSSUB",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		AADD(aFixos,{"XXX",0})//Livro de ISS no ICMS

		If ( SF3->(FieldPos("F3_CREDST"))>0 )
			AADD(aFixos,{"F3_CREDST",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		If ( SF3->(FieldPos("F3_CRDEST"))>0 ) // Credito Estimulo Manaus
			AADD(aFixos,{"F3_CRDEST",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If ( SF3->(FieldPos("F3_CRDPRES"))>0 )	//Credito Presumido
			AADD(aFixos,{"F3_CRDPRES",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If ( SF3->(FieldPos("F3_SIMPLES"))>0 )	//Simples - SC
			AADD(aFixos,{"F3_SIMPLES",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If ( SF3->(FieldPos("F3_CRDTRAN"))>0 )
			AADD(aFixos,{"F3_CRDTRAN",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If ( SF3->(FieldPos("F3_CRDZFM"))>0 ) // Credito Presumido - Zona Franca de Manaus - Entradas Interestaduais
			AADD(aFixos,{"F3_CRDZFM",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If ( SF3->(FieldPos("F3_CNAE"))>0 ) // Codigo da Atividade Economica da Prestacao de Servicos
			AADD(aFixos,{"F3_CNAE",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		If ( SF3->(FieldPos("F3_IDENTFT"))>0 ) // Link com o SFT
			AADD(aFixos,{"F3_IDENTFT",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³COMPATIBILIZACAO DE REFERENCIAS QUE NAO SAO GRAVADAS NO SF3 MAS SIM NO SFT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//LF_CLASFIS    //Classificacao fiscal de acordo com o F4_SITTRIB + B1_ORIGEM
		AADD(aFixos,{"XXX",""})
		//LF_CTIPI      //Codigo de Situacao tributaria do IPI
		AADD(aFixos,{"XXX",""})
		//LF_ESTOQUE    //Movimentacao fisica do estoque
		AADD(aFixos,{"XXX",""})
		//LF_DESPIPI    //IPI sobre despesas acessorias
		AADD(aFixos,{"XXX",""})
		//LF_POSIPI     //NCM Produto
		AADD(aFixos,{"XXX",""})
		//LF_OUTRRET    //ICMS Retido escriturado coluna Outros
		AADD(aFixos,{"XXX",0})
		//LF_ISENRET    //ICMS Retido escriturado coluna Isento
		AADD(aFixos,{"XXX",0})
		//LF_ITEMORI    //Item da NF Original
		AADD(aFixos,{"XXX",""})

		If ( SF3->(FieldPos("F3_CFPS"))>0 ) // Codigo Fiscal de Prestacao de Servicos
			AADD(aFixos,{"F3_CFPS",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		//LF_ALIQIPI Campo F3_ALIQIPI //Aliquota de IPI
		AADD(aFixos,{"XXX",0})

		//valor Credito Presumido Substituicao Tributaria retido pelo contratante do servico de transporte - Decreto 44.147/2005 (MG)
		If (SF3->(FieldPos("F3_CRPRST"))>0 )
			AADD(aFixos,{"F3_CRPRST",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//LF_TRIBRET    // ICMS Retido escriturado coluna Tributado
		AADD(aFixos,{"XXX",0})

		//
		//Desconto Zona Franca de Manaus
		//
		If (SF3->(FieldPos("F3_DESCZFR"))>0 )
			AADD(aFixos,{"F3_DESCZFR",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		// Pis/Cofins Subst. Tributaria
		If (SF3->(FieldPos("F3_BASEPS3"))>0 )
			AADD(aFixos,{"F3_BASEPS3",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_ALIQPS3"))>0 )
			AADD(aFixos,{"F3_ALIQPS3",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VALPS3"))>0 )
			AADD(aFixos,{"F3_VALPS3",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_BASECF3"))>0 )
			AADD(aFixos,{"F3_BASECF3",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_ALIQCF3"))>0 )
			AADD(aFixos,{"F3_ALIQCF3",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VALCF3"))>0 )
			AADD(aFixos,{"F3_VALCF3",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//Valor Crédito Presumido nas operações de Saída com o ICMS destacado sobre os produtos resultantes da industrialização com componentes, partes e pecas recebidos do exterior, destinados a fabricacao de produtos de informatica, eletronicos e telecomunicacoes, por estabelecimento industrial desses setores. Tratamento conforme Art. 1º do DECRETO 4.316 de 19 de Junho de 1995 (BA).
		If (SF3->(FieldPos("F3_CRPRELE"))>0 )
			AADD(aFixos,{"F3_CRPRELE",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//Valor do abatimento na base de calculo do ISS referente ao material aplicado
		If (SF3->(FieldPos("F3_ISSMAT"))>0 )
			AADD(aFixos,{"F3_ISSMAT",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//Valor do Fundersul - Mato Grosso do Sul
		If (SF3->(FieldPos("F3_VALFDS"))>0 )
			AADD(aFixos,{"F3_VALFDS",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//Valor do Estorno de Credito
		If (SF3->(FieldPos("F3_ESTCRED"))>0 )
			AADD(aFixos,{"F3_ESTCRED",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//Valor do Credito Presumido - Simples Nacional - SC
		If (SF3->(FieldPos("F3_CRPRSIM"))>0 )
			AADD(aFixos,{"F3_CRPRSIM",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//Base do ICMS Autonomo - embarcador
		If (SF3->(FieldPos("F3_BASETST"))>0 )
			AADD(aFixos,{"F3_BASETST",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//Valor do ICMS Autonomo - embarcador
		If (SF3->(FieldPos("F3_VALTST"))>0 )
			AADD(aFixos,{"F3_VALTST",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//Antecipacao de ICMS
		If (SF3->(FieldPos("F3_ANTICMS"))>0 )
			AADD(aFixos,{"F3_ANTICMS",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		//Valor Antecipacao ICMS
		If (SF3->(FieldPos("F3_VALANTI"))>0 )
			AADD(aFixos,{"F3_VALANTI",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//Valor do Credito Presumido -PR (RICMS Art. 4 - ANEXO III)
		If (SF3->(FieldPos("F3_CRPREPR"))>0 )
			AADD(aFixos,{"F3_CRPREPR",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If ( SF3->(FieldPos("F3_VALFECP"))>0 )
			AADD(aFixos,{"F3_VALFECP",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If ( SF3->(FieldPos("F3_VFECPST"))>0 )
			AADD(aFixos,{"F3_VFECPST",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_CSTPIS"))>0 )
			AADD(aFixos,{"F3_CSTPIS",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		If (SF3->(FieldPos("F3_CSTCOF"))>0 )
			AADD(aFixos,{"F3_CSTCOF",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		//Credito Acumulado de ICMS - Bahia
		If (SF3->(FieldPos("F3_CREDACU"))>0)
			AADD(aFixos,{"F3_CREDACU",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		//Valor do Credito Presumido -RO (RICMS Art. 39 - ANEXO IV)
		If (SF3->(FieldPos("F3_CRPRERO"))>0 )
			AADD(aFixos,{"F3_CRPRERO",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_LF_VALII"))>0)
			AADD(aFixos,{"F3_LF_VALII",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		//Valor do Credito Presumido - PE - Art. 6 Decreto n28.247
		If (SF3->(FieldPos("F3_CRPREPE"))>0 )
			AADD(aFixos,{"F3_CRPREPE",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_CSTISS"))>0 )
			AADD(aFixos,{"F3_CSTISS",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		//	Cred. Presumido-art.631-A do RICMS/2008
		If (SF3->(FieldPos("F3_CPRESPR"))>0 )
			AADD(aFixos,{"F3_CPRESPR",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//Valor do FETHAB - Mato Grosso
		If (SF3->(FieldPos("F3_VALFET"))>0 )
			AADD(aFixos,{"F3_VALFET",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//Valor do FABOV - Mato Grosso
		If (SF3->(FieldPos("F3_VALFAB"))>0 )
			AADD(aFixos,{"F3_VALFAB",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//Valor do FACS - Mato Grosso
		If (SF3->(FieldPos("F3_VALFAC"))>0 )
			AADD(aFixos,{"F3_VALFAC",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//	Cred. Presumido-Decreto 52.586 de 28.12.2007
		If (SF3->(FieldPos("F3_CRPRESP"))>0 )
			AADD(aFixos,{"F3_CRPRESP",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//FUMACOP - MA
		If (SF3->(FieldPos("F3_VALFUM"))>0 )
			AADD(aFixos,{"F3_VALFUM",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//motivo do CST = 40, 41 e 50
		If (SF3->(FieldPos("F3_MOTICMS"))>0 )
			AADD(aFixos,{"F3_MOTICMS",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		//Valor do Senar
		If (SF3->(FieldPos("F3_VLSENAR"))>0 )
			AADD(aFixos,{"F3_VLSENAR",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

       //Valor de Credito Outorgado SP
		If (SF3->(FieldPos("F3_CROUTSP"))>0 )
			AADD(aFixos,{"F3_CROUTSP",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If ( SF3->(FieldPos("F3_DS43080"))>0 )
			AADD(aFixos,{"F3_DS43080",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If ( SF3->(FieldPos("F3_VL43080"))>0 )
			AADD(aFixos,{"F3_VL43080",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_CPPRODE"))>0 )
			AADD(aFixos,{"F3_CPPRODE",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_TPPRODE"))>0 )
			AADD(aFixos,{"F3_TPPRODE",""})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_CODBCC"))>0 )
			AADD(aFixos,{"F3_CODBCC",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		If (SF3->(FieldPos("F3_INDNTFR"))>0 )
			AADD(aFixos,{"F3_INDNTFR",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		If (SF3->(FieldPos("F3_TNATREC"))>0 )
			AADD(aFixos,{"F3_TNATREC",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		If (SF3->(FieldPos("F3_CNATREC"))>0 )
			AADD(aFixos,{"F3_CNATREC",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		If (SF3->(FieldPos("F3_GRUPONC"))>0 )
			AADD(aFixos,{"F3_GRUPONC",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		If (SF3->(FieldPos("F3_DTFIMNT"))>0 )
			AADD(aFixos,{"F3_DTFIMNT",CTOD("  /  /  ")})
		Else
			AADD(aFixos,{"XXX",CTOD("  /  /  ")})
		EndIf

		If (SF3->(FieldPos("F3_VALTPDP"))>0 )
			AADD(aFixos,{"F3_VALTPDP",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VFECPRN"))>0 )
			AADD(aFixos,{"F3_VFECPRN",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VFESTRN"))>0 )
			AADD(aFixos,{"F3_VFESTRN",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_CROUTGO"))>0 )
			AADD(aFixos,{"F3_CROUTGO",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_CRDPCTR"))>0 )
			AADD(aFixos,{"F3_CRDPCTR",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_CREDPRE"))>0 )
			AADD(aFixos,{"F3_CREDPRE",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VFECPMG"))>0 )
			AADD(aFixos,{"F3_VFECPMG",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VFESTMG"))>0 )
			AADD(aFixos,{"F3_VFESTMG",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VREINT"))>0 )
			AADD(aFixos,{"F3_VREINT",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_BSREIN"))>0 )
			AADD(aFixos,{"F3_BSREIN",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_MVALCOF"))>0 )
			AADD(aFixos,{"F3_MVALCOF",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_MALQCOF"))>0 )
			AADD(aFixos,{"F3_MALQCOF",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VFECPMT"))>0 )
			AADD(aFixos,{"F3_VFECPMT",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VFESTMT"))>0 )
			AADD(aFixos,{"F3_VFESTMT",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VALPMAJ"))>0 )
			AADD(aFixos,{"F3_VALPMAJ",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_ALQPMAJ"))>0 )
			AADD(aFixos,{"F3_ALQPMAJ",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_BASECPM"))>0 )
			AADD(aFixos,{"F3_BASECPM",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_ALQCPM"))>0 )
			AADD(aFixos,{"F3_ALQCPM",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VALCPM"))>0 )
			AADD(aFixos,{"F3_VALCPM",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_BASEFMP"))>0 )
			AADD(aFixos,{"F3_BASEFMP",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VALFMP"))>0 )
			AADD(aFixos,{"F3_VALFMP",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_ALQFMP"))>0 )
			AADD(aFixos,{"F3_ALQFMP",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VALFMD"))>0 )
			AADD(aFixos,{"F3_VALFMD",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf
		//ICMS ST Cobrado anteriormente
		If (SF3->(FieldPos("F3_BASNDES"))>0 )
			AADD(aFixos,{"F3_BASNDES",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_ICMNDES"))>0 )
			AADD(aFixos,{"F3_ICMNDES",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_BASECPB"))>0 )
			AADD(aFixos,{"F3_BASECPB",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VALCPB"))>0 )
			AADD(aFixos,{"F3_VALCPB",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_ALIQCPB"))>0 )
			AADD(aFixos,{"F3_ALIQCPB",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//Difal ICMS
		If (SF3->(FieldPos("F3_DIFAL"))>0 )
			AADD(aFixos,{"F3_DIFAL",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VFCPDIF"))>0 )
			AADD(aFixos,{"F3_VFCPDIF",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_BASEDES"))>0 )
			AADD(aFixos,{"F3_BASEDES",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_BSICMOR"))>0 )
			AADD(aFixos,{"F3_BSICMOR",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VALFUND"))>0 )
			AADD(aFixos,{"F3_VALFUND",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VALIMA"))>0 )
			AADD(aFixos,{"F3_VALIMA",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_VALFASE"))>0 )
			AADD(aFixos,{"F3_VALFASE",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³COMPATIBILIZACAO DE REFERENCIAS QUE NAO SAO GRAVADAS NO SF3 MAS SIM NO SFT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// LF_PRCMEDP - Preço Médio Ponderado, para ser utilizado como base de ICMS ST
		AADD(aFixos,{"XXX",0})
		// LF_VALPEDG - Valor do Pedágio, informado pela rotina MATA116.
		AADD(aFixos,{"XXX",0})
		// LF_CSOSN  - CSOSN
		AADD(aFixos,{"XXX",""})
		// LF_BASEINP - Base do INSS Patronal
		AADD(aFixos,{"XXX",0})
		// LF_PERCINP - Percentual do INSS Patronal
		AADD(aFixos,{"XXX",0})

		If (SF3->(FieldPos("F3_VALINP"))>0 )
			AADD(aFixos,{"F3_VALINP",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		If (SF3->(FieldPos("F3_TRIBMUN"))>0 )
			AADD(aFixos,{"F3_TRIBMUN",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		If (SF3->(FieldPos("F3_AFRMIMP"))>0 )
			AADD(aFixos,{"F3_AFRMIMP",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³COMPATIBILIZACAO DE REFERENCIAS QUE NAO SAO GRAVADAS NO SF3 MAS SIM NO SFT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// LF_VOPDIF - Valor do ICMS da Operação - Sem diferimento (Valor como se não tivesse o diferimento)
		AADD(aFixos,{"XXX",0})

		If (SF3->(FieldPos("F3_CLIDEST"))>0 )
			AADD(aFixos,{"F3_CLIDEST",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		If (SF3->(FieldPos("F3_LOJDEST"))>0 )
			AADD(aFixos,{"F3_LOJDEST",""})
		Else
			AADD(aFixos,{"XXX",""})
		EndIf

		If (SF3->(FieldPos("F3_BFCPANT"))>0 )
			AADD(aFixos,{"F3_BFCPANT",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		// LF_AFCPANT
		AADD(aFixos,{"XXX",0})

		If (SF3->(FieldPos("F3_VFCPANT"))>0 )
			AADD(aFixos,{"F3_VFCPANT",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		// LF_ALQNDES
		AADD(aFixos,{"XXX",0})

		// LF_ALFCCMP
		AADD(aFixos,{"XXX",0})

		// LF_BASFECP
		If (SF3->(FieldPos("F3_BASFECP"))>0 )
			AADD(aFixos,{"F3_BASFECP",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		// LF_BSFCPST
		If (SF3->(FieldPos("F3_BSFCPST"))>0 )
			AADD(aFixos,{"F3_BSFCPST",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		// LF_BSFCCMP
		If (SF3->(FieldPos("F3_BSFCCMP"))>0 )
			AADD(aFixos,{"F3_BSFCCMP",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		// LF_FCPAUX
		AADD(aFixos,{"XXX",0})

		//Base do FUNRURAL
	    If (SF3->(FieldPos("F3_BASEFUN"))>0 )
	 		AADD(aFixos,{"F3_BASEFUN",0})
	 	Else
		    AADD(aFixos,{"XXX",0})
		EndIf

		//Valor do FUNRURAL
		If (SF3->(FieldPos("F3_VALFUN"))>0 )
			AADD(aFixos,{"F3_VALFUN",0})
		Else
			AADD(aFixos,{"XXX",0})
		EndIf

		//Base do CREDITO PRESUMIDO
	    If (SF3->(FieldPos("F3_BASECPR"))>0 )
	 		AADD(aFixos,{"F3_BASECPR",0})
	 	Else
		    AADD(aFixos,{"XXX",0})
		EndIf

		//Desconto Fiscal
	    If (SF3->(FieldPos("F3_DESCFIS"))>0 )
	 		AADD(aFixos,{"F3_DESCFIS",0})
	 	Else
		    AADD(aFixos,{"XXX",0})
		EndIf
		//Percentual e Valor do incentivo prod.leite artigo 207-B RICMS-MG
		If (SF3->(FieldPos("F3_VLINCMG"))>0 )
			AADD(aFixos,{"F3_VLINCMG",0})
		EndIf

	Else
		aArea := GetArea()
		dbSelectArea("SX3")
		aSX3:=GetArea()
		dbSetOrder(1)
		MsSeek("SF3")
		While !Eof() .And. SX3->X3_ARQUIVO == "SF3"
			If (X3Uso(X3_USADO) .Or. (Substr(X3_CAMPO,1,9) $ "F3_BASIMP,F3_ALQIMP,F3_VALIMP,F3_RETIMP"))
				AAdd(aFixos,{RTrim(SX3->X3_CAMPO),If(SX3->X3_TIPO="N",0,"")})
			EndIf
			dbSelectArea( "SX3" )
			dbSkip()
		EndDo
		RestArea(aSX3)
		RestArea(aArea)
	EndIf
	aCposSF3 := aClone(aFixos)
Else
	aFixos := aClone(aCposSF3)
EndIf

Return(aFixos)

/*/{Protheus.doc} xFisVldRel()
@description Funcao utilizada para validar o release do cliente.
@param
	cVersao -> Versao do sistema.
	cRelease -> Release do sistema.
	lV12Only -> Flag p/ indicar se a estrutura eh exclusiva da V12.
	cRelSX -> Release de liberacao da estrutura.
@author joao.pellegrini
@since 12/09/2016
/*/
Static Function xFisVldRel(cVersao, cRelease, lV12Only, cRelSX)

Local lRet := .T.

DEFAULT lV12Only := .F.
DEFAULT cRelSX := ""

// Se o conteudo for Empty a estrutura estará disponível para todas as
// versoes/releases, portanto nao preciso fazer a verificacao.
If !Empty(cRelSX)

	If cVersao == "12"

		// Se for versao 12, verifico se o release liberado (cRelSX) eh igual
		// ou superior ao release do ambiente.
		lRet := cRelSX >= cRelease

	Else

		// Para as demais versoes nao posso comparar com ">=" pois o release
		// do RPO sera, por exemplo, "R8" e "R8" sempre sera maior do que
		// "12.1.XXX", portanto o resultado seria sempre ".T.".
		// Assim, verifico apenas a flag "lV12Only", que indica se a estrutura
		// eh exclusiva da V12. Se nao for, entendo que a estrutura está
		// disponivel para as demais versoes e retorno ".T.".
		lRet := !lV12Only

	EndIf

EndIf

Return lRet

/*/
MaIniRef - Edson Maricate   - 10.12.99
 Inicializa as variaveis utilizadas no Retorno Fiscal
/*/
Function xFisIniRef(aItemRef, aCabRef, aLFIs, aResRef, aSX6, aPos, aTGITRef, aTGNFRef, aTGLFRef)

Local nG
Local lArredBra	:= (cPaisLoc == "BRA")
Local lCritArr	:= (cPaisLoc == "BRA")
Local lArredChi	:= (cPaisLoc <> "CHI")
Local lArredMex	:= (cPaisLoc == "MEX")
Local lArredPtg	:= (cPaisLoc == "PTG")
Local lArredArg	:= (cPaisLoc == "ARG")
Local lCritPer	:= (cPaisLoc == "PER")
Local cAToHM	:= 'AToHM'

aItemRef := {}
aCabRef	 := {}
aLFIs    := {}
aResRef	 := {}
aTGITRef := {}
aTGNFRef := {}
aTGLFRef := {}

aadd(aCabRef,{"NF_TIPONF","1",.F.})
aadd(aCabRef,{"NF_OPERNF","2",.F.})
aadd(aCabRef,{"NF_CLIFOR","3",.F.})
aadd(aCabRef,{"NF_TPCLIFOR","4",.F.})
aadd(aCabRef,{"NF_LINSCR","5",.F.})
aadd(aCabRef,{"NF_GRPCLI","6",.F.})
aadd(aCabRef,{"NF_UFDEST","7",.F.})
aadd(aCabRef,{"NF_UFORIGEM","8",.F.})
aadd(aCabRef,{"NF_DESCONTO","10",.T.})
aadd(aCabRef,{"NF_FRETE","11",.T.})
aadd(aCabRef,{"NF_DESPESA","12",.T.})
aadd(aCabRef,{"NF_SEGURO","13",.T.})
aadd(aCabRef,{"NF_AUTONOMO","14",.T.})
aadd(aCabRef,{"NF_ICMS","15",.F.})
aadd(aCabRef,{"NF_BASEICM",{15,1},.T.})
aadd(aCabRef,{"NF_VALICM",{15,2},.T.})
aadd(aCabRef,{"NF_BASESOL",{15,3},.T.})
aadd(aCabRef,{"NF_VALSOL",{15,4},.T.})
aadd(aCabRef,{"NF_BICMORI",{15,5},.T.})
aadd(aCabRef,{"NF_VALCMP",{15,6},.T.})
aadd(aCabRef,{"NF_BASEICA",{15,7},.T.})
aadd(aCabRef,{"NF_VALICA",{15,8},.T.})
aadd(aCabRef,{"NF_RECFAUT",{15,9},.T.})
aadd(aCabRef,{"NF_IPI","16",.F.})
aadd(aCabRef,{"NF_BASEIPI",{16,1},.T.})
aadd(aCabRef,{"NF_VALIPI",{16,2},.T.})
aadd(aCabRef,{"NF_BIPIORI",{16,3},.T.})
aadd(aCabRef,{"NF_TOTAL","17",.T.})
aadd(aCabRef,{"NF_VALMERC","18",.T.})
aadd(aCabRef,{"NF_FUNRURAL","19",.T.})
aadd(aCabRef,{"NF_CODCLIFOR","20",.F.})
aadd(aCabRef,{"NF_LOJA","21",.F.})
aadd(aCabRef,{"NF_LIVRO","22",.F.})
aadd(aCabRef,{"NF_ISS","23",.F.})
aadd(aCabRef,{"NF_BASEISS",{23,1},.T.})
aadd(aCabRef,{"NF_VALISS",{23,2},.T.})
aadd(aCabRef,{"NF_DESCISS",{23,3},.T.})
aadd(aCabRef,{"NF_IR","24",.F.})
aadd(aCabRef,{"NF_BASEIRR",{24,1},.T.})
aadd(aCabRef,{"NF_VALIRR",{24,2},.T.})
aadd(aCabRef,{"NF_INSS","25",.F.})
aadd(aCabRef,{"NF_BASEINS",{25,1},.T.})
aadd(aCabRef,{"NF_VALINS",{25,2},.T.})
aadd(aCabRef,{"NF_NATUREZA","26",.F.})
aadd(aCabRef,{"NF_VALEMB","27",.T.})
aadd(aCabRef,{"NF_IMPOSTOS","30",.T.})
aadd(aCabRef,{"NF_BASEDUP","31",.T.})
aadd(aCabRef,{"NF_RELIMP","32",.F.})
aadd(aCabRef,{"NF_IMPOSTOS2","33",.T.})
aadd(aCabRef,{"NF_DESCZF","34",.T.})
aadd(aCabRef,{"NF_SUFRAMA","35",.T.})
aadd(aCabRef,{"NF_BASEIMP","36",.F.})
For nG := 1 To NMAXIV
	aadd(aCabRef,{"NF_BASEIV"+NumCpoImpVar(nG),{36,nG},.T.})
Next nG
aadd(aCabRef,{"NF_VALIMP","37",.F.})
For nG := 1 To NMAXIV
	aadd(aCabRef,{"NF_VALIV"+NumCpoImpVar(nG),{37,nG},.T.})
Next nG
aadd(aCabRef,{"NF_TPCOMP","38",.F.})
aadd(aCabRef,{"NF_INSIMP","39",.F.})
aadd(aCabRef,{"NF_PESO","40",.T.})
aadd(aCabRef,{"NF_ICMFRETE","41",.T.})
aadd(aCabRef,{"NF_BSFRETE","42",.T.})
aadd(aCabRef,{"NF_BASECOF","43",.T.})
aadd(aCabRef,{"NF_VALCOF","44",.T.})
aadd(aCabRef,{"NF_BASECSL","45",.T.})
aadd(aCabRef,{"NF_VALCSL","46",.T.})
aadd(aCabRef,{"NF_BASEPIS","47",.T.})
aadd(aCabRef,{"NF_VALPIS","48",.T.})
aadd(aCabRef,{"NF_AUXACUM","50",.T.})
aadd(aCabRef,{"NF_ALIQIR","51",.T.})
aadd(aCabRef,{"NF_VNAGREG","52",.T.})
aadd(aCabRef,{"NF_RECISS","56"})
aadd(aCabRef,{"NF_MOEDA","58",.T.})
aadd(aCabRef,{"NF_TXMOEDA","59",.F.})
aadd(aCabRef,{"NF_SERIENF","60",.F.})
aadd(aCabRef,{"NF_TIPODOC","61",.F.})
aadd(aCabRef,{"NF_MINIMP","62",.F.})
For nG := 1 To NMAXIV
	aadd(aCabRef,{"NF_MINIV"+NumCpoImpVar(nG),{62,nG},.T.})
Next
aadd(aCabRef,{"NF_BASEPS2","63",.T.})
aadd(aCabRef,{"NF_VALPS2","64",.T.})
aadd(aCabRef,{"NF_ESPECIE","65",.F.})
aadd(aCabRef,{"NF_CNPJ","66",.F.})
aadd(aCabRef,{"NF_BASECF2","67",.T.})
aadd(aCabRef,{"NF_VALCF2","68",.T.})
aadd(aCabRef,{"NF_ICMSDIF","69",.T.})
aadd(aCabRef,{"NF_MODIRF","70",.T.})
aadd(aCabRef,{"NF_PNF_COD",{71,01},.T.})
aadd(aCabRef,{"NF_PNF_LOJ",{71,02},.T.})
aadd(aCabRef,{"NF_PNF_UF" ,{71,03},.T.})
aadd(aCabRef,{"NF_PNF_TPCLIFOR",{71,04},.T.})
aadd(aCabRef,{"NF_BASEAFRMM","73",.T.})
aadd(aCabRef,{"NF_VALAFRMM","74",.T.})
aadd(aCabRef,{"NF_PIS252","75",.T.})
aadd(aCabRef,{"NF_COF252","76",.T.})
aadd(aCabRef,{"NF_BASESES",{78,1},.T.})
aadd(aCabRef,{"NF_VALSES",{78,2},.T.})
aadd(aCabRef,{"NF_RECSEST","79",.T.})
aadd(aCabRef,{"NF_BASEPS3","80",.T.})
aadd(aCabRef,{"NF_VALPS3","81",.T.})
aadd(aCabRef,{"NF_BASECF3","82",.T.})
aadd(aCabRef,{"NF_VALCF3","83",.T.})
aadd(aCabRef,{"NF_VLR_FRT","84",.T.})
aadd(aCabRef,{"NF_VALFET","85",.T.})
aadd(aCabRef,{"NF_RECFET","86",.T.})
aadd(aCabRef,{"NF_CLIENT","87",.F.})
aadd(aCabRef,{"NF_LOJENT","88",.F.})
aadd(aCabRef,{"NF_VALFDS","89",.F.})
aadd(aCabRef,{"NF_ESTCRED","90",.F.})
aadd(aCabRef,{"NF_SIMPNAC","91",.T.})
aadd(aCabRef,{"NF_TRANSUF",{92,01},.T.})
aadd(aCabRef,{"NF_TRANSIN",{92,01},.T.})
aadd(aCabRef,{"NF_BASETST","93",.T.})
aadd(aCabRef,{"NF_VALTST","94",.T.})
aadd(aCabRef,{"NF_CRPRSIM","95",.T.})
aadd(aCabRef,{"NF_VALANTI","96",.T.})
aadd(aCabRef,{"NF_DESNTRB","97",.T.})
aadd(aCabRef,{"NF_TARA","98",.T.})
aadd(aCabRef,{"NF_NUMDEP","99",.T.})
aadd(aCabRef,{"NF_PROVENT","100",.T.})
aadd(aCabRef,{"NF_VALFECP","101",.T.})
aadd(aCabRef,{"NF_VFECPST","102",.T.})
aadd(aCabRef,{"NF_CRDPRES","103",.T.})
aadd(aCabRef,{"NF_IRPROG","104",.T.})
aadd(aCabRef,{"NF_VALII","105",.T.})
aadd(aCabRef,{"NF_RECIV","106",lCritPer})
aadd(aCabRef,{"NF_CRPREPE","107",.T.})
aadd(aCabRef,{"NF_VLRORIG","108",.T.})
aadd(aCabRef,{"NF_VALFAB","109",.T.})
aadd(aCabRef,{"NF_RECFAB","110",.T.})
aadd(aCabRef,{"NF_VALFAC","111",.T.})
aadd(aCabRef,{"NF_RECFAC","112",.T.})
aadd(aCabRef,{"NF_LJCIPI","113",.T.})
aadd(aCabRef,{"NF_VALFUM","114",.T.})
For nG := 1 To NMAXIV
	aadd(aCabRef,{"NF_VLRORI"+NumCpoImpVar(nG),{108,nG},.T.})
Next nG
aadd(aCabRef,{"NF_VLSENAR","115",.T.})
aadd(aCabRef,{"NF_CROUTSP","116",.T.})
aadd(aCabRef,{"NF_BSSEMDS","117",,.T.})
aadd(aCabRef,{"NF_ICSEMDS","118",,.T.})
aadd(aCabRef,{"NF_DS43080","119",,.T.})
aadd(aCabRef,{"NF_VL43080","120",,.T.})
aadd(aCabRef,{"NF_BASEFUN","121",.T.})
aadd(aCabRef,{"NF_PEDIDO","122",.T.})
aadd(aCabRef,{"NF_CODMUN","123",.T.})
aadd(aCabRef,{"NF_VALTPDP","124,01",.T.})
aadd(aCabRef,{"NF_BASTPDP","124,02",.T.})
aadd(aCabRef,{"NF_VLINCMG","125",.T.})
aadd(aCabRef,{"NF_BASEINA","126",.T.})
aadd(aCabRef,{"NF_VALINA","127",.T.})
aadd(aCabRef,{"NF_VFECPRN","128",.T.})
aadd(aCabRef,{"NF_VFESTRN","129",.T.})
aadd(aCabRef,{"NF_CREDPRE","130",.T.})
aadd(aCabRef,{"NF_VFECPMG","131",.T.})
aadd(aCabRef,{"NF_VFESTMG","132",.T.})
aadd(aCabRef,{"NF_VREINT","133",.T.})
aadd(aCabRef,{"NF_BSREIN","134",.T.})
aadd(aCabRef,{"NF_VFECPMT","135",.T.})
aadd(aCabRef,{"NF_VFESTMT","136",.T.})
aadd(aCabRef,{"NF_CLIEFAT",{144,01},.T.})
aadd(aCabRef,{"NF_LOJCFAT",{144,02},.T.})
aadd(aCabRef,{"NF_TIPOFAT",{144,03},.T.})
aadd(aCabRef,{"NF_GRPFAT" ,{144,04},.T.})
aadd(aCabRef,{"NF_NATUFAT",{144,05},.T.})
aadd(aCabRef,{"NF_ISSABMT","145",.T.})
aadd(aCabRef,{"NF_ISSABSR","146",.T.})
aadd(aCabRef,{"NF_INSABMT","147",.T.})
aadd(aCabRef,{"NF_INSABSR","148",.T.})
aadd(aCabRef,{"NF_ADIANT","149",.T.})
aadd(aCabRef,{"NF_VTOTPED","150",.T.})
aadd(aCabRef,{"NF_DTEMISS","151",.T.})
aadd(aCabRef,{"NF_IDSA1","152",.T.})
aadd(aCabRef,{"NF_IDSA2","153",.T.})
aadd(aCabRef,{"NF_IDSED","154",.T.})
aadd(aCabRef,{"NF_DESCTOT","155",.T.}) 		//155 - Valor Desc. dado no TOTAL (LOJA)
aadd(aCabRef,{"NF_ACRESCI","156",.T.}) 	    //156 - Valor Acrescimo dado no TOTAL (LOJA)
aadd(aCabRef,{"NF_TPFRETE","157",.T.}) 	    //156 - Valor Acrescimo dado no TOTAL (LOJA)
aadd(aCabRef,{"NF_UFPREISS","159",.T.})
aadd(aCabRef,{"NF_VALCIDE","161",.T.})
aadd(aCabRef,{"NF_RECCIDE","162",.T.})
aadd(aCabRef,{"NF_VALFETR","163",.T.})
aadd(aCabRef,{"NF_MODAL","164",.T.})
aadd(aCabRef,{"NF_BASECID","168",.T.})
aadd(aCabRef,{"NF_BASECPM","169",.T.})
aadd(aCabRef,{"NF_VALCPM","170",.T.})
aadd(aCabRef,{"NF_IPIVFCF","171",.T.})
aadd(aCabRef,{"NF_BASEFMP","172",.T.})
aadd(aCabRef,{"NF_VALFMP","173",.T.})
aadd(aCabRef,{"NF_VALFMD","174",.T.})
aadd(aCabRef,{"NF_RECFMD","175",.T.})
aadd(aCabRef,{"NF_SERSAT","176",.T.})
aadd(aCabRef,{"NF_ICMNDES","177",.T.})
aadd(aCabRef,{"NF_BASNDES","178",.T.})
aadd(aCabRef,{"NF_TPCOMPL","179",.T.})
aadd(aCabRef,{"NF_DIFAL","180",.T.})
aadd(aCabRef,{"NF_PPDIFAL","181",.T.})
aadd(aCabRef,{"NF_VFCPDIF","182",.T.})
aadd(aCabRef,{"NF_BASEDES","183",.T.})
aadd(aCabRef,{"NF_CLIDEST","184",.T.})
aadd(aCabRef,{"NF_LOJDEST","185",.T.})
aadd(aCabRef,{"NF_UFCDEST","186",.T.})
aadd(aCabRef,{"NF_CLIEDEST","187",.T.})
aadd(aCabRef,{"NF_VALFUND","188",.T.})
aadd(aCabRef,{"NF_VALIMA","189",.T.})
aadd(aCabRef,{"NF_VALFASE","190",.T.})
aadd(aCabRef,{"NF_VLIMAR","191",.T.})
aadd(aCabRef,{"NF_VLFASER","192",.T.})
aadd(aCabRef,{"NF_RECIMA","193",.T.})
aadd(aCabRef,{"NF_RECFASE","194",.T.})
aadd(aCabRef,{"NF_INDICE","196",.F.})
If cPaisLoc == "PER" .and. aPos[FP_F1_ADIANT]
	aadd(aCabRef,{"NF_ADIANTTOT","167",.T.})
EndIf

aadd(aCabRef,{"NF_VALPEDG","197",.T.})
aadd(aCabRef,{"NF_TPACTIV","198",.T.})
aadd(aCabRef,{"NF_CALCINP","199",.T.})
aadd(aCabRef,{"NF_VALINP","200",.T.})
aadd(aCabRef,{"NF_AFRMIMP","201",.T.})
aadd(aCabRef,{"NF_VALPRO","202",.T.})
aadd(aCabRef,{"NF_INDUFP","203",.T.})
aadd(aCabRef,{"NF_VALFEEF","204",.T.})
aadd(aCabRef,{"NF_DEDBSPC","205",.T.})
aadd(aCabRef,{"NF_M0CODMUN","206",.T.})
aadd(aCabRef,{"NF_TIPORUR","207",.T.})
aadd(aCabRef,{"NF_RECIRRF","208",.T.})
aadd(aCabRef,{"NF_BFCPANT","209",.T.})
aadd(aCabRef,{"NF_VFCPANT","210",.T.})
aadd(aCabRef,{"NF_PERFECP","211",.T.})
aadd(aCabRef,{"NF_BASFECP","212",.T.})
aadd(aCabRef,{"NF_BSFCPST","213",.T.})
aadd(aCabRef,{"NF_BSFCCMP","214",.T.})
aadd(aCabRef,{"NF_EMITENF","215",.T.})
aadd(aCabRef,{"NF_ALIQSN","216",.F.})
aadd(aCabRef,{"NF_USAALIQSN","217",.F.})
aadd(aCabRef,{"NF_GROSSIR","218",.F.})
aadd(aCabRef,{"NF_TPJFOR","219",.F.})
aadd(aCabRef,{"NF_CODDECL","220",.F.})
aadd(aCabRef,{"NF_TEMF2B","221",.F.})
aadd(aCabRef,{"NF_TRIBGEN","222",.F.})
aadd(aCabRef,{"NF_CALCTG","223",.F.})
aadd(aCabRef,{"NF_PERF_PART","224",.F.})
aadd(aCabRef,{"NF_QTDITENS","225",.F.})
aadd(aCabRef,{"NF_DEDICM","227",.T.})
If cPaisLoc == "RUS"
	//(11/04/18): For recalculation in Main Currency (in rubles)
	aadd(aCabRef,{"NF_TOTAL_C1","230",.T.})
	aadd(aCabRef,{"NF_BASEIMP_C1","231",.F.})
	For nG := 1 To NMAXIV
		aadd(aCabRef,{"NF_BASEIV"+NumCpoImpVar(nG)+"_C1",{231,nG},.T.})
	Next nG
	aadd(aCabRef,{"NF_VALIMP_C1","232",.F.})
	For nG := 1 To NMAXIV
		aadd(aCabRef,{"NF_VALIV"+NumCpoImpVar(nG)+"_C1",{232,nG},.T.})
	Next nG
	aadd(aCabRef,{"NF_VALMERC_C1","233",.T.})
EndIf
aadd(aItemRef,{"IT_GRPTRIB","1",15,.F.,.F.})
aadd(aItemRef,{"IT_EXCECAO","2",,.F.,.F.})
aadd(aItemRef,{"IT_ALIQICM","3",40,.F.,.F.})
aadd(aItemRef,{"IT_ICMS","4",,.F.,.F.})
aadd(aItemRef,{"IT_BASEICM",{4,1},70,lArredBra, aSX6[MV_RNDICM] })
aadd(aItemRef,{"IT_VALICM",{4,2},80,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_BASESOL",{4,3},100,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_ALIQSOL",{4,4},40,.F.,.F.})
aadd(aItemRef,{"IT_VALSOL",{4,5},110,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_MARGEM",{4,6},90,.F.,.F.})
aadd(aItemRef,{"IT_BICMORI",{4,7},,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_ALIQCMP",{4,8},40,.F.,.F.})
aadd(aItemRef,{"IT_VALCMP",{4,9},80,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_BASEICA",{4,10},71,lArredBra,lCritArr})
aadd(aItemRef,{"IT_VALICA",{4,11},81,lArredBra,lCritArr})
aadd(aItemRef,{"IT_DEDICM",{4,12},80,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_VLCSOL" ,{4,13},100,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_PAUTIC",{4,14},40,.F.,.F.})
aadd(aItemRef,{"IT_PAUTST",{4,15},40,.F.,.F.})
aadd(aItemRef,{"IT_PREDIC",{4,16},90,.F.,.F.})
aadd(aItemRef,{"IT_BASEDES",{4,20},70,lArredBra, aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_BSICARD",{4,21},70,lArredBra, aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_VLICARD",{4,22},70,lArredBra, aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_ALIQIPI","5",40,.F.,.F.})
aadd(aItemRef,{"IT_IPI","6",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASEIPI",{6,1},50,lArredBra,lCritArr})
aadd(aItemRef,{"IT_VALIPI",{6,2},60,lArredBra,aSX6[MV_RNDIPI] })
aadd(aItemRef,{"IT_BIPIORI",{6,3},,lArredBra,lCritArr})
aadd(aItemRef,{"IT_NFORI","7",20,.F.,.F.})
aadd(aItemRef,{"IT_SERORI","8",20,.F.,.F.})
aadd(aItemRef,{"IT_RECORI","9",20,.F.,.F.})
aadd(aItemRef,{"IT_DESCONTO","10",20,.T., aSX6[MV_RNDDES] })
aadd(aItemRef,{"IT_FRETE","11",20,.T.,lCritArr})
aadd(aItemRef,{"IT_DESPESA","12",20,.T.,lCritArr})
aadd(aItemRef,{"IT_SEGURO","13",20,.T.,lCritArr})
aadd(aItemRef,{"IT_AUTONOMO","14",20,.T.,lCritArr})
aadd(aItemRef,{"IT_VALMERC","15",,lArredChi,lCritArr})
aadd(aItemRef,{"IT_PRODUTO","16",10,.F.,.F.})
aadd(aItemRef,{"IT_TES","17",20,.F.,.F.})
aadd(aItemRef,{"IT_TOTAL","18",,lArredChi,lCritArr})
aadd(aItemRef,{"IT_CF","19",30,.F.,.F.})
aadd(aItemRef,{"IT_FUNRURAL","20",,lArredBra, aSX6[MV_RNDFUN] })
aadd(aItemRef,{"IT_PERFUN","21",,.F.,.F.})
aadd(aItemRef,{"IT_DELETED","22",,.F.,.F.})
aadd(aItemRef,{"IT_LIVRO","23",,.F.,.F.})
aadd(aItemRef,{"IT_ISS","24",,.F.,.F.})
aadd(aItemRef,{"IT_ALIQISS",{24,1},40,.F.,.F.})
aadd(aItemRef,{"IT_BASEISS",{24,2},,lArredBra,lCritArr})
aadd(aItemRef,{"IT_VALISS",{24,3},,.T., aSX6[MV_RNDISS] })
aadd(aItemRef,{"IT_CODISS",{24,4},,.F.,.F.})
aadd(aItemRef,{"IT_CFPS",{24,7},,.F.,.F.})
aadd(aItemRef,{"IT_PREDISS",{24,8},,.F.,.F.})
aadd(aItemRef,{"IT_VALISORI",{24,9},,.F.,.F.})
aadd(aItemRef,{"IT_ALISSOR",{24,10},,.F.,.F.})
aadd(aItemRef,{"IT_IR","25",,.F.,.F.})
aadd(aItemRef,{"IT_BASEIRR",{25,1},,.T.,lCritArr})
aadd(aItemRef,{"IT_REDIR",{25,2},,.F.,.F.})
aadd(aItemRef,{"IT_ALIQIRR",{25,3},40,.F.,.F.})
aadd(aItemRef,{"IT_VALIRR",{25,4},,lArredBra, aSX6[MV_RNDIRF] })
aadd(aItemRef,{"IT_INSS","26",,.F.,.F.})
aadd(aItemRef,{"IT_BASEINS",{26,1},,lArredBra,lCritArr})
aadd(aItemRef,{"IT_REDINSS",{26,2},,.F.,.F.})
aadd(aItemRef,{"IT_ALIQINS",{26,3},,.F.,.F.})
aadd(aItemRef,{"IT_VALINS",{26,4},,lArredBra, aSX6[MV_RNDINS] })

aadd(aItemRef,{"IT_SECP15",{26,6},,.F.,lCritArr})
aadd(aItemRef,{"IT_BSCP15",{26,7},,lArredBra,lCritArr})
aadd(aItemRef,{"IT_ALCP15",{26,8},,.F.,lCritArr})
aadd(aItemRef,{"IT_VLCP15",{26,9},,lArredBra, aSX6[MV_RNDINS]})

aadd(aItemRef,{"IT_SECP20",{26,10},,.F.,lCritArr})
aadd(aItemRef,{"IT_BSCP20",{26,11},,lArredBra,lCritArr})
aadd(aItemRef,{"IT_ALCP20",{26,12},,.F.,lCritArr})
aadd(aItemRef,{"IT_VLCP20",{26,13},,lArredBra, aSX6[MV_RNDINS]})

aadd(aItemRef,{"IT_SECP25",{26,14},,.F.,lCritArr})
aadd(aItemRef,{"IT_BSCP25",{26,15},,lArredBra,lCritArr})
aadd(aItemRef,{"IT_ALCP25",{26,16},,.F.,lCritArr})
aadd(aItemRef,{"IT_VLCP25",{26,17},,lArredBra,aSX6[MV_RNDINS]})

aadd(aItemRef,{"IT_VALEMB","27",,.T.,lCritArr})
aadd(aItemRef,{"IT_BASEIMP","28",,.F.,lCritArr})
For nG := 1 To NMAXIV
	aadd(aItemRef,{"IT_BASEIV"+NumCpoImpVar(nG),{28,nG},,lArredBra,lCritArr})
Next nG
aadd(aItemRef,{"IT_ALIQIMP","29",,.F.,.F.})
For nG := 1 To NMAXIV
	aadd(aItemRef,{"IT_ALIQIV"+NumCpoImpVar(nG),{29,nG},,.F.,.F.})
Next nG
aadd(aItemRef,{"IT_VALIMP","30",,.F.,.F.})
For nG := 1 To NMAXIV
	aadd(aItemRef,{"IT_VALIV"+NumCpoImpVar(nG),{30,nG},,(lArredMex .Or. lArredPtg .Or. lArredArg),lCritArr})
Next nG
aadd(aItemRef,{"IT_BASEDUP","31",,lArredChi,lCritArr})
aadd(aItemRef,{"IT_DESCZF","32",,lArredBra,lCritArr})
aadd(aItemRef,{"IT_DESCIV","33",,.F.,.F.})
aadd(aItemRef,{"IT_QUANT","34",,.F.,.F.})
aadd(aItemRef,{"IT_PRCUNI","35",,.F.,lCritArr})
aadd(aItemRef,{"IT_VIPIBICM","36",,lArredBra,lCritArr})
aadd(aItemRef,{"IT_PESO","37",,.F.,.F.})
aadd(aItemRef,{"IT_ICMFRETE","38",82,lArredBra,lCritArr})
aadd(aItemRef,{"IT_BSFRETE","39",72,lArredBra,lCritArr})
aadd(aItemRef,{"IT_BASECOF","40",,lArredBra,lCritArr})
aadd(aItemRef,{"IT_ALIQCOF","41",40, IIf( aSX6[MV_DECALIQ] , .F. , lArredBra ) , .F. })
aadd(aItemRef,{"IT_VALCOF","42",,lArredBra, aSX6[MV_RNDCOF] })
aadd(aItemRef,{"IT_BASECSL","43",,lArredBra,lCritArr})
aadd(aItemRef,{"IT_ALIQCSL","44",40,lArredBra,.F.})
aadd(aItemRef,{"IT_VALCSL","45",,lArredBra, aSX6[MV_RNDCSL] })
aadd(aItemRef,{"IT_BASEPIS","46",,lArredBra,lCritArr})
aadd(aItemRef,{"IT_ALIQPIS","47",40, IIf( aSX6[MV_DECALIQ] , .F. , lArredBra ) , .F. })
aadd(aItemRef,{"IT_VALPIS","48",,lArredBra, aSX6[MV_RNDPIS] })
aadd(aItemRef,{"IT_RECNOSB1","49",,.T.,.F.})
aadd(aItemRef,{"IT_RECNOSF4","50",,.T.,.F.})
aadd(aItemRef,{"IT_VNAGREG","51",,.T.,lCritArr})
aadd(aItemRef,{"IT_REMITO","53",,.F.,.F.})
aadd(aItemRef,{"IT_BASEPS2","54",,lArredBra,aSX6[MV_RNDPS2]})
aadd(aItemRef,{"IT_ALIQPS2","55",40, IIf( aSX6[MV_DECALIQ] , .F. , lArredBra ) , .F. })
aadd(aItemRef,{"IT_VALPS2","56",,.T., aSX6[MV_RNDPS2] })
aadd(aItemRef,{"IT_BASECF2","57",,lArredBra,aSX6[MV_RNDCF2]})
aadd(aItemRef,{"IT_ALIQCF2","58",40, IIf( aSX6[MV_DECALIQ] , .F. , lArredBra ) , .F.})
aadd(aItemRef,{"IT_VALCF2","59",,.T., aSX6[MV_RNDCF2] })
aadd(aItemRef,{"IT_ABVLINSS","60",,.F.,lCritArr})
aadd(aItemRef,{"IT_ABVLISS","61",,.F.,lCritArr})
aadd(aItemRef,{"IT_REDISS","62",,.F.,.F.})
aadd(aItemRef,{"IT_ICMSDIF","63",,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_DESCZFPIS","64",,.T., aSX6[MV_RNDPS2] })
aadd(aItemRef,{"IT_DESCZFCOF","65",,.T.,aSX6[MV_RNDCF2] })
aadd(aItemRef,{"IT_BASEAFRMM","66",,lArredBra,lCritArr})
aadd(aItemRef,{"IT_ALIQAFRMM","67",,lArredBra,.F.})
aadd(aItemRef,{"IT_VALAFRMM","68",,lArredBra,lCritArr})
aadd(aItemRef,{"IT_PIS252","69",,.F.,lCritArr})
aadd(aItemRef,{"IT_COF252","70",,.F.,lCritArr})
aadd(aItemRef,{"IT_CRDZFM","71",,.F.,lCritArr})
aadd(aItemRef,{"IT_CNAE","72",,.F.,.F.})
aadd(aItemRef,{"IT_ITEM","73",,.F.,.F.})
aadd(aItemRef,{"IT_SEST","74",,.F.,.F.})
aadd(aItemRef,{"IT_BASESES",{74,1},,lArredBra,lCritArr})
aadd(aItemRef,{"IT_ALIQSES",{74,2},,.F.,.F.})
aadd(aItemRef,{"IT_VALSES",{74,3},,lArredBra,aSX6[MV_RNDSEST]})
aadd(aItemRef,{"IT_BASEPS3","75",,lArredBra,lCritArr})
aadd(aItemRef,{"IT_ALIQPS3","76",40,lArredBra,.F.})
aadd(aItemRef,{"IT_VALPS3","77",,.T., aSX6[MV_RNDPS3] })
aadd(aItemRef,{"IT_BASECF3","78",,lArredBra,lCritArr})
aadd(aItemRef,{"IT_ALIQCF3","79",40,lArredBra,.F.})
aadd(aItemRef,{"IT_VALCF3","80",,.T., aSX6[MV_RNDCF3]  })
aadd(aItemRef,{"IT_VLR_FRT","81",,.T.,lCritArr})
aadd(aItemRef,{"IT_BASEFET","82",,.T.,lCritArr})
aadd(aItemRef,{"IT_ALIQFET","83",,.F.,.F.})
aadd(aItemRef,{"IT_VALFET","84",,.T.,lCritArr})
aadd(aItemRef,{"IT_ABSCINS","85",,.F.,lCritArr})
aadd(aItemRef,{"IT_SPED","86",,.F.,lCritArr})
aadd(aItemRef,{"IT_ABMATISS","87",,.F.,lCritArr})
aadd(aItemRef,{"IT_RGESPST","88",,.F.,.F.})
aadd(aItemRef,{"IT_PRFDSUL","89",,.F.,lCritArr})
aadd(aItemRef,{"IT_UFERMS","90",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALFDS","91",,.F.,lCritArr})
aadd(aItemRef,{"IT_ESTCRED","92",,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_CODIF","93",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASETST","94",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALIQTST","95",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALTST","96",,.F.,lCritArr})
aadd(aItemRef,{"IT_CRPRSIM","97",,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_VALANTI","98",,.F.,lCritArr})
aadd(aItemRef,{"IT_DESNTRB","99",,.F.,lCritArr})
aadd(aItemRef,{"IT_TARA","100",,.F.,lCritArr})
aadd(aItemRef,{"IT_PROVENT","101",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALFECP","102",80,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_VFECPST","103",80,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_ALIQFECP","104",,.F.,lCritArr})
aadd(aItemRef,{"IT_CRPRESC","105",,lArredBra,lCritArr})
aadd(aItemRef,{"IT_DESCPRO","106",,.F.,lCritArr})
aadd(aItemRef,{"IT_ANFORI2","107",,.F.,.F.})
aadd(aItemRef,{"IT_UFORI",{107,1},,.F.,lCritArr})
aadd(aItemRef,{"IT_ALQORI",{107,2},,.F.,lCritArr})
aadd(aItemRef,{"IT_PROPOR",{107,3},,.F.,lCritArr})
aadd(aItemRef,{"IT_ALQPROR",{107,4},,.F.,lCritArr})
aadd(aItemRef,{"IT_ALIQII",{108,1},,.F.,lCritArr})
aadd(aItemRef,{"IT_VALII",{108,2},,.F.,lCritArr})
aadd(aItemRef,{"IT_PAUTPIS","109",,.F.,lCritArr})
aadd(aItemRef,{"IT_PAUTCOF","110",,.F.,lCritArr})
aadd(aItemRef,{"IT_CLASFIS","112",,.F.,lCritArr})
aadd(aItemRef,{"IT_VLRISC","113",,.F.,lCritPer})
aadd(aItemRef,{"IT_CRPREPE","114",,.F.,lCritArr})
aadd(aItemRef,{"IT_CRPREMG","115",,.F.,lCritArr})
aadd(aItemRef,{"IT_SLDDEP","116",,.F.,lCritArr})
aadd(aItemRef,{"IT_CRPRECE","117",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASEFAB","118",,.T.,lCritArr})
aadd(aItemRef,{"IT_ALIQFAB","119",,.T.,.F.})
aadd(aItemRef,{"IT_VALFAB","120",,.T.,lCritArr})
aadd(aItemRef,{"IT_BASEFAC","121",,.T.,lCritArr})
aadd(aItemRef,{"IT_ALIQFAC","122",,.T.,.F.})
aadd(aItemRef,{"IT_VALFAC","123",,.T.,lCritArr})
aadd(aItemRef,{"IT_VALFUM","124",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALIQFUM","125",,.F.,lCritArr})
If cPaisLoc=="EQU" .OR.  cPaisLoc=="VEN"
	aadd(aItemRef,{"IT_CONCEPT","126",5,.F.,.F.})
Endif
aadd(aItemRef,{"IT_MOTICMS","127",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALSENAR","128",,.F.,lCritArr})
aadd(aItemRef,{"IT_VLSENAR","129",,lArredBra,aSX6[MV_RNDSEST]})
aadd(aItemRef,{"IT_BSSENAR","130",,lArredBra,aSX6[MV_RNDSEST]})
aadd(aItemRef,{"IT_CROUTSP","131",,.F.,lCritArr})
aadd(aItemRef,{"IT_AVLINSS","132",,.F.,lCritArr})
aadd(aItemRef,{"IT_BSSEMDS","133",,.F.,lCritArr})
aadd(aItemRef,{"IT_ICSEMDS","134",,.T.,lCritArr})
aadd(aItemRef,{"IT_PR43080","135",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASEFUN","136",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASVEIC","137",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASRESI",{138,1},,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_VALRESI",{138,2},,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_CRPREPR","140",,.F.,lCritArr})
aadd(aItemRef,{"IT_TABNTRE",{141,1},,.F.,lCritArr})
aadd(aItemRef,{"IT_CODNTRE",{141,2},,.F.,lCritArr})
aadd(aItemRef,{"IT_GRPNTRE",{141,3},,.F.,lCritArr})
aadd(aItemRef,{"IT_DATNTRE",{141,4},,.F.,lCritArr})
aadd(aItemRef,{"IT_ALITPDP",{142,1},,.F.,lCritArr})
aadd(aItemRef,{"IT_BASTPDP",{142,2},,.F.,lCritArr})
aadd(aItemRef,{"IT_VALTPDP",{142,3},,.F.,lCritArr})
aadd(aItemRef,{"IT_VLINCMG","143",,.F.,lCritArr})
aadd(aItemRef,{"IT_PRINCMG","144",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASEINA",{145,1},,.F.,lCritArr})
aadd(aItemRef,{"IT_ALIQINA",{145,2},,.F.,lCritArr})
aadd(aItemRef,{"IT_VALINA",{145,3},,.F.,lCritArr})
aadd(aItemRef,{"IT_VFECPRN","146",,.F.,lCritArr})
aadd(aItemRef,{"IT_VFESTRN","147",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALFECRN","148",,.F.,lCritArr})
aadd(aItemRef,{"IT_VLRFUE","149",,.F.,lCritArr})
aadd(aItemRef,{"IT_METODO","150",,.F.,lCritArr})
aadd(aItemRef,{"IT_NORESPE","151",,.F.,lCritArr})
aadd(aItemRef,{"IT_COEPSST","152",,.F.,lCritArr})
aadd(aItemRef,{"IT_COECFST","153",,.F.,lCritArr})
aadd(aItemRef,{"IT_CREDPRE","154",,.T.,lCritArr})
aadd(aItemRef,{"IT_PRCUNIC","155",,.F.,lCritArr})
aadd(aItemRef,{"IT_RANTSPD","156",,.F.,lCritArr})
aadd(aItemRef,{"IT_VFECPMG","157",,.F.,lCritArr})
aadd(aItemRef,{"IT_VFESTMG","158",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALFECMG","159",,.F.,lCritArr})
aadd(aItemRef,{"IT_VREINT","160",,.T.,lCritArr})
aadd(aItemRef,{"IT_VREINT",{23,109},,.T.,lCritArr})
aadd(aItemRef,{"IT_BSREIN","161",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALCMAJ","162",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALQCMAJ","163",,.F.,lCritArr})
aadd(aItemRef,{"IT_VFECPMT","164",,.F.,lCritArr})
aadd(aItemRef,{"IT_VFESTMT","165",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALFECMT","166",,.F.,lCritArr})
aadd(aItemRef,{"IT_B1DIAT","168",,.F.,lCritArr})
aadd(aItemRef,{"IT_POSIPI","172",172,.F.,.F.})
aadd(aItemRef,{"IT_ADIANT","180",,.F.,lCritArr})
aadd(aItemRef,{"IT_NATOPER","181",,.F.,lCritArr})
aadd(aItemRef,{"IT_ADIANT","180",,.F.,lCritArr})
aadd(aItemRef,{"IT_IDSF4" ,{183,1},,.F.,lCritArr})
aadd(aItemRef,{"IT_IDSF7" ,{183,2},,.F.,lCritArr})
aadd(aItemRef,{"IT_IDSA1" ,{183,3},,.F.,lCritArr})
aadd(aItemRef,{"IT_IDSA2" ,{183,4},,.F.,lCritArr})
aadd(aItemRef,{"IT_IDSB1" ,{183,5},,.F.,lCritArr})
aadd(aItemRef,{"IT_IDSB5" ,{183,6},,.F.,lCritArr})
aadd(aItemRef,{"IT_IDSBZ" ,{183,7},,.F.,lCritArr})
aadd(aItemRef,{"IT_IDSED" ,{183,8},,.F.,lCritArr})
aadd(aItemRef,{"IT_IDSFB" ,{183,9},,.F.,lCritArr})
aadd(aItemRef,{"IT_IDSFC" ,{183,10},,.F.,lCritArr})
aadd(aItemRef,{"IT_IDCFC" ,{183,11},,.F.,lCritArr})

aadd(aItemRef,{"IT_DESCTOT","184",20,.T., aSX6[MV_RNDDES] })
aadd(aItemRef,{"IT_ACRESCI","185",20,.T., aSX6[MV_RNDDES] })

aadd(aItemRef,{"IT_VALPMAJ","186",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALQPMAJ","187",,.F.,lCritArr})

aadd(aItemRef,{"IT_PRDFIS","188",,.F.,lCritArr})
aadd(aItemRef,{"IT_NCMFIS","190",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALCIDE","192",,.T.,lCritArr})
aadd(aItemRef,{"IT_PREDST",{04,17},,.F.,lCritArr})
aadd(aItemRef,{"IT_PREDIPI",{06,04},,.F.,lCritArr})
aadd(aItemRef,{"IT_VALFETR","194",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALFCST","195",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALFCCMP","196",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASNDES","197",,.F.,lCritArr})
aadd(aItemRef,{"IT_ICMNDES","198",,.F.,lCritArr})

If cPaisLoc == "PER" .and. aPos[FP_F1_ADIANT]
	aadd(aItemRef,{"IT_ADIANTTOT" ,"199",,.F.,lCritArr})
EndIf

aadd(aItemRef,{"IT_PRCCF","201",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASECID","202",,.T.,lCritArr})
aadd(aItemRef,{"IT_ALQCIDE","203",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASECPM","204",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALCPM","205",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALQCPM","206",,.F.,lCritArr})
aadd(aItemRef,{"IT_IPIVFCF","207",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASEFMP","208",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALFMP","209",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALQFMP","210",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASEFMD","211",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALFMD","212",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALQFMD","213",,.F.,lCritArr})
aadd(aItemRef,{"IT_TS","214",,.F.,lCritArr})
aadd(aItemRef,{"TS_LANCFIS",{214,87},,.F.,lCritArr})
aadd(aItemRef,{"IT_PAUTAPS","215",,.F.,lCritArr})
aadd(aItemRef,{"IT_PAUTACF","216",,.F.,lCritArr})
aadd(aItemRef,{"IT_GRPCST","217",,.F.,lCritArr})
aadd(aItemRef,{"IT_CEST","218",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASECPB","219",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALCPB","220",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALIQCPB","221",,.F.,lCritArr})
aadd(aItemRef,{"IT_DIFAL","223",,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_PDDES","224",,.F.,lCritArr})
aadd(aItemRef,{"IT_PDORI","225",,.F.,lCritArr})
aadd(aItemRef,{"IT_VFCPDIF","226",,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_FTRICMS","227",,.F.,lCritArr})
aadd(aItemRef,{"IT_VRDICMS","228",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASFUND","229",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALIFUND","230",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALFUND","231",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASIMA","232",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALIIMA","233",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALIMA","234",,.F.,lCritArr})
aadd(aItemRef,{"IT_AIMAMT","235",,.F.,lCritArr})
aadd(aItemRef,{"IT_VLIMAR","236",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASFASE","237",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALIFASE","238",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALFASE","239",,.F.,lCritArr})
aadd(aItemRef,{"IT_AFASEMT","240",,.F.,lCritArr})
aadd(aItemRef,{"IT_VLFASER","241",,.F.,lCritArr})
aadd(aItemRef,{"IT_PRCMEDP","242",,.F.,lCritArr})
aadd(aItemRef,{"IT_INDICE","243",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALPEDG","244",,.F.,lCritArr})
aadd(aItemRef,{"IT_VLSLXML","245",,.F.,lCritArr})
aadd(aItemRef,{"IT_VLRCID","246",,.F.,lCritArr})
aadd(aItemRef,{"IT_CSOSN","247",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASEINP","248",,.F.,lCritArr})
aadd(aItemRef,{"IT_PERCINP","249",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALINP","250",,lArredBra,lCritArr})
aadd(aItemRef,{"IT_TRIBMU","251",,.F.,lCritArr})
aadd(aItemRef,{"IT_AFRMIMP","252",,.F.,lCritArr})
aadd(aItemRef,{"IT_CPRESPR","253",,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_DS43080","254",,.F.,lCritArr})
aadd(aItemRef,{"IT_VOPDIF","255",,lArredBra,aSX6[MV_RNDICM]})
aadd(aItemRef,{"IT_BASEPRO","256",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALIQPRO","257",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALPRO","258",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASFEEF","259",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALQFEEF","260",,.F.,lCritArr})
aadd(aItemRef,{"IT_VALFEEF","261",,.F.,lCritArr})
aadd(aItemRef,{"IT_CODATIV","262",,.F.,lCritArr})
aadd(aItemRef,{"IT_COLVDIF","263",,.F.,lCritArr})
aadd(aItemRef,{"IT_BFCPANT","264",,.F.,lCritArr})
aadd(aItemRef,{"IT_AFCPANT","265",,.F.,lCritArr})
aadd(aItemRef,{"IT_VFCPANT","266",,.F.,lCritArr})
aadd(aItemRef,{"IT_ALQNDES","267",,.F.,lCritArr})
aadd(aItemRef,{"IT_BASFECP","268",,.F.,lCritArr})
aadd(aItemRef,{"IT_BSFCPST","269",,.F.,lCritArr})
aadd(aItemRef,{"IT_BSFCCMP","270",,.F.,lCritArr})
aadd(aItemRef,{"IT_FCPAUX","271",,.F.,lCritArr})
aadd(aItemRef,{"IT_CPPRODE","272",,.F.,lCritArr})
aadd(aItemRef,{"IT_CTAREC","273",,.F.,lCritArr})
aadd(aItemRef,{"IT_VICMBRT","274",,.F.,lCritArr})
aadd(aItemRef,{"IT_CODDECL","275",,.F.,lCritArr})
aadd(aItemRef,{"IT_TRIBGEN","276",,.F.,.F.})
aadd(aItemRef,{"IT_ID_TRBGEN","277",,.F.,.F.})
aadd(aItemRef,{"IT_ID_LOAD_TRBGEN","278",,.F.,.F.})
aadd(aItemRef,{"IT_TPOPER","279",,.F.,.F.})
aadd(aItemRef,{"IT_VIPIORI","280",,.F.,.F.})
aadd(aItemRef,{"IT_BICEFET","281",,.F.,.F.})
aadd(aItemRef,{"IT_PICEFET","282",,.F.,.F.})
aadd(aItemRef,{"IT_VICEFET","283",,.F.,.F.})
aadd(aItemRef,{"IT_RICEFET","284",,.F.,.F.})
aadd(aItemRef,{"IT_BSTANT","285",,.F.,.F.})
aadd(aItemRef,{"IT_PSTANT","286",,.F.,.F.})
aadd(aItemRef,{"IT_VSTANT","287",,.F.,.F.})
aadd(aItemRef,{"IT_VICPRST","288",,.F.,.F.})
aadd(aItemRef,{"IT_BFCANTS","290",,.F.,.F.})
aadd(aItemRef,{"IT_PFCANTS","291",,.F.,.F.})
aadd(aItemRef,{"IT_VFCANTS","292",,.F.,.F.})
aadd(aItemRef,{"IT_ICMDESONE","293",,.F.,.F.})
aadd(aItemRef,{"IT_ICMDESST","294",,.F.,.F.})
aadd(aItemRef,{"IT_TOTEFET","295",,.F.,.F.})
aadd(aItemRef,{"IT_QTDORI","296",,.F.,.F.})
aadd(aItemRef,{"IT_DESCFIS","297",20,.T., aSX6[MV_RNDDES] })
aadd(aItemRef,{"IT_ALANTICMS","298",,.F.,.F.})
If cPaisLoc == "RUS"
	//(16/04/18): For recalculation in Main Currency (in rubles)
	aadd(aItemRef,{"IT_VALMERC_C1","301",,lArredChi,lCritArr})
	aadd(aItemRef,{"IT_BASEIMP_C1","302",,.F.,lCritArr})
	For nG := 1 To NMAXIV
		aadd(aItemRef,{"IT_BASEIV"+NumCpoImpVar(nG)+"_C1",{302,nG},,lArredBra,lCritArr})
	Next nG
	aadd(aItemRef,{"IT_VALIMP_C1","303",,.F.,.F.})
	For nG := 1 To NMAXIV
		aadd(aItemRef,{"IT_VALIV"+NumCpoImpVar(nG)+"_C1",{303,nG},,(lArredMex .Or. lArredPtg .Or. lArredArg),lCritArr})
	Next nG
	aadd(aItemRef,{"IT_TOTAL_C1","304",,lArredChi,lCritArr})
EndIf
aadd(aItemRef,{"IT_EMISNFORI","305",,.F.,.F.})
aadd(aItemRef,{"IT_PRESICM","306",,lArredBra,aSX6[MV_RNDICM]})

aadd(aResRef,{"IMP_COD",1})
aadd(aResRef,{"IMP_DESC",2})
aadd(aResRef,{"IMP_BASE",3})
aadd(aResRef,{"IMP_ALIQ",4})
aadd(aResRef,{"IMP_VAL",5})
aadd(aResRef,{"IMP_NOME",6})

aadd(aTGITRef,{"TG_IT_BASE",3,,.T.,.T.})
aadd(aTGITRef,{"TG_IT_ALIQUOTA",4,,.F.,.F.})
aadd(aTGITRef,{"TG_IT_VALOR",5,,.T.,.T.})

aadd(aTGNFRef,{"TG_NF_BASE",2,.F.})
aadd(aTGNFRef,{"TG_NF_VALOR",3,.F.})

aadd(aTGLFRef,{"TG_LF_CST",1,.F.})
aadd(aTGLFRef,{"TG_LF_VALTRIB",2,.F.})
aadd(aTGLFRef,{"TG_LF_ISENTO",3,.F.})
aadd(aTGLFRef,{"TG_LF_OUTROS",4,.F.})
aadd(aTGLFRef,{"TG_LF_NAO_TRIBUTADO",5,.F.})
aadd(aTGLFRef,{"TG_LF_DIFERIDO",6,.F.})
aadd(aTGLFRef,{"TG_LF_MAJORADO",7,.F.})
aadd(aTGLFRef,{"TG_LF_PERC_MAJORACAO",8,.F.})
aadd(aTGLFRef,{"TG_LF_PERC_DIFERIDO",9,.F.})
aadd(aTGLFRef,{"TG_LF_PERC_REDUCAO",10,.F.})
aadd(aTGLFRef,{"TG_LF_PAUTA",11,.F.})
aadd(aTGLFRef,{"TG_LF_MVA",12,.F.})
aadd(aTGLFRef,{"TG_LF_AUX_MVA",13,.F.})
aadd(aTGLFRef,{"TG_LF_AUX_MAJORACAO",14,.F.})

aadd(aLFis,{"LF_CFO",1})
aadd(aLFis,{"LF_ALIQICMS",2})
aadd(aLFis,{"LF_VALCONT",3})
aadd(aLFis,{"LF_BASEICM",4})
aadd(aLFis,{"LF_VALICM",5})
aadd(aLFis,{"LF_ISENICM",6})
aadd(aLFis,{"LF_OUTRICM",7})
aadd(aLFis,{"LF_BASEIPI",8})
aadd(aLFis,{"LF_VALIPI",9})
aadd(aLFis,{"LF_ISENIPI",10})
aadd(aLFis,{"LF_OUTRIPI",11})
aadd(aLFis,{"LF_OBSERV",12})
aadd(aLFis,{"LF_VALOBSE",13})
aadd(aLFis,{"LF_ICMSRET",14})
aadd(aLFis,{"LF_LANCAM",15})
aadd(aLFis,{"LF_TIPO",16})
aadd(aLFis,{"LF_ICMSCOMP",17})
aadd(aLFis,{"LF_CODISS",18})
aadd(aLFis,{"LF_IPIOBS",19})
aadd(aLFis,{"LF_NFLIVRO",20})
aadd(aLFis,{"LF_ICMAUTO",21})
aadd(aLFis,{"LF_BASERET",22})
aadd(aLFis,{"LF_FORMUL",23})
aadd(aLFis,{"LF_FORMULA",24})
aadd(aLFis,{"LF_DESPESA",25})
aadd(aLFis,{"LF_ICMSDIF",26})
aadd(aLFis,{"LF_TRFICM",27})
aadd(aLFis,{"LF_OBSICM",28})
aadd(aLFis,{"LF_OBSSOL",29})
aadd(aLFis,{"LF_SOLTRIB",30})
aadd(aLFis,{"LF_CFOEXT",31})
aadd(aLFis,{"LF_ISSST",32})
aadd(aLFis,{"LF_RECISS",33})
aadd(aLFis,{"LF_ISSSUB",34})
aadd(aLFis,{"LF_CREDST",36})
aadd(aLFis,{"LF_CRDEST",37})
aadd(aLFis,{"LF_CRDPRES",38})
aadd(aLFis,{"LF_SIMPLES",39})
aadd(aLFis,{"LF_CRDTRAN",40})
aadd(aLFis,{"LF_CFOEXT",31})
aadd(aLFis,{"LF_CRDZFM",41})
aadd(aLFis,{"LF_CNAE",42})
aadd(aLFis,{"LF_IDENT",43})
aadd(aLFis,{"LF_CLASFIS",44})
aadd(aLFis,{"LF_CTIPI",45})
aadd(aLFis,{"LF_ESTOQUE",46})
aadd(aLFis,{"LF_DESPIPI",47})
aadd(aLFis,{"LF_POSIPI",48})
aadd(aLFis,{"LF_OUTRRET",49})
aadd(aLFis,{"LF_ISENRET",50})
aadd(aLFis,{"LF_ITEMORI",51})
aadd(aLFis,{"LF_CFPS",52})
aadd(aLFis,{"LF_ALIQIPI",53})
aadd(aLFis,{"LF_CRPRST",54})
aadd(aLFis,{"LF_TRIBRET",55})
aadd(aLFis,{"LF_DESCZFR",56})
aadd(aLFis,{"LF_BASEPS3",57})
aadd(aLFis,{"LF_ALIQPS3",58})
aadd(aLFis,{"LF_VALPS3",59})
aadd(aLFis,{"LF_BASECF3",60})
aadd(aLFis,{"LF_ALIQCF3",61})
aadd(aLFis,{"LF_VALCF3",62})
aadd(aLFis,{"LF_CRPRELE",63})
aadd(aLFis,{"LF_ISSMAT",64})
aadd(aLFis,{"LF_VALFDS",65})
aadd(aLFis,{"LF_ESTCRED",66})
aadd(aLFis,{"LF_CRPRSIM",67})
aadd(aLFis,{"LF_BASETST",68})
aadd(aLFis,{"LF_VALTST",69})
aadd(aLFis,{"LF_ANTICMS",70})
aadd(aLFis,{"LF_VALANTI",71})
aadd(aLFis,{"LF_CRPREPR",72})
aadd(aLFis,{"LF_VALFECP",73})
aadd(aLFis,{"LF_VFECPST",74})
aadd(aLFis,{"LF_CSTPIS",75})
aadd(aLFis,{"LF_CSTCOF",76})
aadd(aLFis,{"LF_CREDACU",77})
aadd(aLFis,{"LF_CRPRERO",78})
aadd(aLFis,{"LF_VALII",79})
aadd(aLFis,{"LF_CRPRERE",80})
aadd(aLFis,{"LF_CSTISS",81})
aadd(aLFis,{"LF_CPRESPR",82})
aadd(aLFis,{"LF_VALFET",83})
aadd(aLFis,{"LF_VALFAB",84})
aadd(aLFis,{"LF_VALFAC",85})
aadd(aLFis,{"LF_CRPRESP",86})
aadd(aLFis,{"LF_VALFUM",87})
aadd(aLFis,{"LF_MOTICMS",88})
aadd(aLFis,{"LF_VLSENAR",89})
aadd(aLFis,{"LF_CROUTSP",90})
aadd(aLFis,{"LF_DS43080",91})
aadd(aLFis,{"LF_VL43080",92})
aadd(aLFis,{"LF_CPPRODE",93})
aadd(aLFis,{"LF_TPPRODE",94})
aadd(aLFis,{"LF_CODBCC",95})
aadd(aLFis,{"LF_INDNTFR",96})
aadd(aLFis,{"LF_TABNTRE",97})
aadd(aLFis,{"LF_CODNTRE",98})
aadd(aLFis,{"LF_GRPNTRE",99})
aadd(aLFis,{"LF_DATNTRE",100})
aadd(aLFis,{"LF_VALTPDP",101})
aadd(aLFis,{"LF_VFECPRN",102})
aadd(aLFis,{"LF_VFESTRN",103})
aadd(aLFis,{"LF_CROUTGO",104})
aadd(aLFis,{"LF_CRDPCTR",105})
aadd(aLFis,{"LF_CREDPRE",106})
aadd(aLFis,{"LF_VFECPMG",107})
aadd(aLFis,{"LF_VFESTMG",108})
aadd(aLFis,{"LF_VREINT",109})
aadd(aLFis,{"LF_BSREIN",110})
aadd(aLFis,{"LF_VALCMAJ",111})
aadd(aLFis,{"LF_ALQCMAJ",112})
aadd(aLFis,{"LF_VFECPMT",113})
aadd(aLFis,{"LF_VFESTMT",114})
aadd(aLFis,{"LF_VALPMAJ",115})
aadd(aLFis,{"LF_ALQPMAJ",116})
aadd(aLFis,{"LF_BASECPM",117})
aadd(aLFis,{"LF_ALQCPM",118})
aadd(aLFis,{"LF_VALCPM",119})
aadd(aLFis,{"LF_BASEFMP",120})
aadd(aLFis,{"LF_VALFMP",121})
aadd(aLFis,{"LF_ALQFMP",122})
aadd(aLFis,{"LF_VALFMD",123})
aadd(aLFis,{"LF_BASNDES",124})
aadd(aLFis,{"LF_ICMNDES",125})
aadd(aLFis,{"LF_BASECPB",126})
aadd(aLFis,{"LF_VALCPB",127})
aadd(aLFis,{"LF_ALIQCPB",128})
aadd(aLFis,{"LF_DIFAL",129})
aadd(aLFis,{"LF_VFCPDIF",130})
aadd(aLFis,{"LF_BASEDES",131})
aadd(aLFis,{"LF_BSICMOR",132})
aadd(aLFis,{"LF_VALFUND",133})
aadd(aLFis,{"LF_VALIMA",134})
aadd(aLFis,{"LF_VALFASE",135})
aadd(aLFis,{"LF_PRCMEDP",136})
aadd(aLFis,{"LF_VALPEDG",137})
aadd(aLFis,{"LF_CSOSN",138})
aadd(aLFis,{"LF_BASEINP",139})
aadd(aLFis,{"LF_PERCINP",140})
aadd(aLFis,{"LF_VALINP",141})
aadd(aLFis,{"LF_TRIBMU",142})
aadd(aLFis,{"LF_AFRMIMP",143})
aadd(aLFis,{"LF_VOPDIF",144})
aadd(aLFis,{"LF_CLIDEST",145})
aadd(aLFis,{"LF_LOJDEST",146})
aadd(aLFis,{"LF_BFCPANT",147})
aadd(aLFis,{"LF_AFCPANT",148})
aadd(aLFis,{"LF_VFCPANT",149})
aadd(aLFis,{"LF_ALQNDES",150})
aadd(aLFis,{"LF_ALFCCMP",151})
aadd(aLFis,{"LF_BASFECP",152})
aadd(aLFis,{"LF_BSFCPST",153})
aadd(aLFis,{"LF_BSFCCMP",154})
aadd(aLFis,{"LF_FCPAUX",155})
aadd(aLFis,{"LF_BASEFUN",156})
aadd(aLFis,{"LF_VALFUN",157})
aadd(aLFis,{"LF_BASECPR",158})
aadd(aLFis,{"LF_DESCFIS",159})
aadd(aLFis,{"LF_ALSENAR",160})
aadd(aLFis,{"LF_BSSENAR",161})
aadd(aLFis,{"LF_BICMORI",162})
aadd(aLFis,{"LF_VLINCMG",163})

// Criando os Hashs 
if lBuild
	if oHItemRef==Nil
		oHItemRef := &cAToHM.(aItemRef)
	endif
	if oHCabRef==Nil
		oHCabRef := &cAToHM.(aCabRef)
	endif
	if oHResRef==Nil
		oHResRef := &cAToHM.(aResRef)
	endif
	if oHTGITRef==Nil
		oHTGITRef := &cAToHM.(aTGITRef)
	endif
	if oHTGNFRef==Nil
		oHTGNFRef := &cAToHM.(aTGNFRef)
	endif
	if oHLFIS==Nil
		oHLFIS := &cAToHM.(aLFIS)
	endif
	if oTGLFRef==Nil
		oTGLFRef := &cAToHM.(aTGLFRef)
	endif
endif
Return .T.

/*/{Protheus.doc} xFisCodIBGE()
@description Funcao para retornar o codigo da
UF passada como paramento conforme o IBGE. Esta funcao foi
clonada do SPEDXFUN pois caso contrario todo o cache dos
dicionarios do SPED seria feito no MATXFIS, ocasionando
perda de performance.
@author joao.pellegrini
@since 20/07/2017
/*/
Function xFisCodIBGE(cUf,lForceUF)

Local nX         := 0
Local cRetorno   := ""
Local aUF        := {}

DEFAULT lForceUF := .T.

aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})

If !Empty(cUF)
	nX := aScan(aUF,{|x| x[1] == cUF})
	If nX == 0
		nX := aScan(aUF,{|x| x[2] == cUF})
		If nX <> 0
			cRetorno := aUF[nX][1]
		EndIf
	Else
		cRetorno := aUF[nX][2]
	EndIf
Else
	cRetorno := IIF(lForceUF,"",aUF)
EndIf

Return(cRetorno)

/*/{Protheus.doc} xFisMdCt79
Função para realizar o algoritmo MD5, utilizando da função Md5(), para as informações do campo F3_MDCAT79.
Os parametros estão conforme a chave de codificação digital referida no inciso IV do artigo 2 da legislação.

@author Vitor Ribeiro (vitor.e@totvs.com.br)
@since 08/08/2017

@param cCnpjCli, caracter, Cnpj do cliente
@param cNFiscal, caracter, Numero da nota fiscal
@param nValCont, numerico, Valor contábil
@param nBaseIcm, numerico, Base de ICMS
@param nValIcms, numerico, ICMS tributado
@param dEmissao, caracter, Data de emissao da nota fiscal
@param cCnpjEmi, caracter, Cnpj do Emitente

@obs Link da legislação:
http://info.fazenda.sp.gov.br/NXT/gateway.dll/legislacao_tributaria/portaria_cat/pcat792003.htm?f=templates&fn=default.htm&vid=sefaz_tributaria:vtribut
/*/

Function xFisMdCt79(cCnpjCli,cNFiscal,nValCont,nBaseIcm,nValIcms,dEmissao,cCnpjEmi)

	Local cRetorno   := ""
    Local cNumfiscal := Repl("0",GTamMxFis(TAM_F3_NFISCAL)-Len(AllTrim(cNFiscal)))+AllTrim(cNFiscal)

	Local lDesde2017 := .F.

	Default cCnpjCli := ""
	Default cNFiscal := ""
	Default cCnpjEmi := ""

	Default nValCont := 0
	Default nBaseIcm := 0
	Default nValIcms := 0

	Default dEmissao := CtoD("")

	// (Alínea acrescentada pela Portaria CAT-122/16, de 26-12-2016; DOE 27-12-2016; Efeitos a partir de 01-01-2017)
	lDesde2017 := Alltrim(Str(Year(dEmissao))) >= '2017'

	// a) CNPJ ou CPF do destinatário ou do tomador do serviço;
	cRetorno := Repl("0",GTamMxFis(TAM_A1_CGC)-Len(Alltrim(cCnpjCli)))+AllTrim(cCnpjCli)

	// b) número do documento fiscal;
	cRetorno += iif(Len(cNumfiscal) > 9,Substring(cNumfiscal,-9,9),cNumfiscal)

	// c) valor total da nota;
	cRetorno += StrTran(StrZero(nValCont,13,2),".","")

	// d) base de cálculo do ICMS;
	cRetorno += StrTran(StrZero(nBaseIcm,13,2),".","")

	// e) valor do ICMS;
	cRetorno += StrTran(StrZero(nValIcms,13,2),".","")

	If lDesde2017
		// f) data de emissão;
		cRetorno += DToS(dEmissao)

		// g) CNPJ do emitente do documento fiscal;
		cRetorno += Alltrim(cCnpjEmi)
	EndIf

	// Criptografa com o algoritmo MD5
	cRetorno := Md5(cRetorno)

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisNameFCP

Funcao para retornar o nome do FCP conforme a UF.

@author joao.pellegrini
@since 15/09/2017
@version 11.80
/*/
//-------------------------------------------------------------------
Function xFisNameFCP(cUF, lST, lComp)
If FindFunction("FISXNAMEFCP")
	return FisxNameFCP(cUF, lST, lComp)
EndIF
Return ""

/*/
MaFisLF -  Edson Maricate - 20.12.1999
Atualiza os livros fiscais para o item.
/*/
Function xFisLF(nItem, lRecPreSt, aNFItem, aNfCab, aSX6, aPos, aPE, cAliasPROD, aFunc, aInfNat, aDic, lProcExcecao)

Local lConsumo		:= aNFItem[nItem][IT_TS][TS_CONSUMO] == "S"
Local lConsFinal    := IIf( aNfCab[NF_OPERNF] == "S" , aNfCab[NF_TPCLIFOR] == "F" , SM0->M0_PRODRUR == "F" .Or. SM0->M0_PRODRUR == "1" )
Local nRetVCtb		:= IIF(!aNFItem[nItem][IT_TS][TS_INCSOL]$"A,N,D",aNfItem[nItem][IT_VALSOL],0)
Local nDescIpi		:= IIf(aNFItem[nItem][IT_TS][TS_TPIPI]=="B" .Or. (aSX6[MV_IPIBRUT]=="S" .And. aNFItem[nItem][IT_TS][TS_TPIPI] ==" "),(aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT])+IIf(aNfCab[NF_OPERNF] == "S",aNfItem[nItem][IT_DESCZF],-1*aNfItem[nItem][IT_DESCZF]),0)
Local cIPINaOBS     := aSX6[MV_IPINOBS]  	//Primeiro S - IPI nao tributado //Segundo  S - IPI na Base do ICMS
Local lLFAgreg      := aSX6[MV_LFAGREG] .And. aNFItem[nItem][IT_TS][TS_AGREG]=="N" .And. aNFItem[nItem][IT_TS][TS_TRFICM]=="2" //Indica se deve ser feita escrituracao, mesmo nao agregando valor ao total da nota.
Local nBICMOri      := aNfItem[nItem][IT_TOTAL]+;
IIf(aNFItem[nItem][IT_TS][TS_DESCOND] == "1" ,(aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]), 0)+;
IIf(aNFItem[nItem][IT_TS][TS_AGREG]   == "N" .And. aNFItem[nItem][IT_TS][TS_TRFICM]=="2",aNfItem[nItem][IT_VALMERC],0)-;
IIf(aNFItem[nItem][IT_TS][TS_IPILICM] <> "1" .And. aNFItem[nItem][IT_TS][TS_IPI]<>"R"   ,aNfItem[nItem][IT_VALIPI] ,0)-;
IIf(aNFItem[nItem][IT_TS][TS_AGRRETC] == "1",0,nRetVCtb)-;
IIf(aNFItem[nItem][IT_TS][TS_DESPICM] == "2",aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_AFRMIMP],0)-;
IIf(aNFItem[nItem][IT_TS][TS_PSCFST] == "1" .And. aNFItem[nItem][IT_TS][TS_APSCFST] == "1",(aNfItem[nItem][IT_VALPS3]+aNfItem[nItem][IT_VALCF3]),0)

Local lImpSCred:= aNFItem[nItem][IT_TS][TS_LFIPI] == "O" .And. aNFItem[nItem][IT_TS][TS_CREDIPI] == "N" .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] =="F" .And. aNFCab[NF_TPCLIFOR] =="X" .And. Substr(aNfItem[nItem][IT_CF],1,1)=="3"

Local nBIPIOri      := aNfItem[nItem][IT_TOTAL]+IIf(aNFItem[nItem][IT_TS][TS_AGREG]=="N" .And. aNFItem[nItem][IT_TS][TS_TRFICM]=="2",aNfItem[nItem][IT_VALMERC],0)-;
IIf(aNFItem[nItem][IT_TS][TS_IPI]<>"R",aNfItem[nItem][IT_VALIPI],0) - nRetVCtb + nDescIPI - Iif(aNFItem[nItem][IT_TS][TS_AGREG]$"I|B" .And. aNFItem[nItem][IT_TS][TS_INCIDE] == "S" .And. !lImpSCred ,aNfItem[nItem][IT_VALICM],0)-If(aNFItem[nItem][IT_TS][TS_AGRPIS]=="1" .And. aNFItem[nItem][IT_TS][TS_PSCFST]<>"1",aNfItem[nItem,IT_VALPS2],0)-If(aNFItem[nItem][IT_TS][TS_AGRCOF]=="1" .And. aNFItem[nItem][IT_TS][TS_PSCFST]<>"1",aNfItem[nItem,IT_VALCF2],0)-;
IIf(aNFItem[nItem][IT_TS][TS_DESPIPI]$"N",(aNfItem[nItem][IT_DESPESA]),0)-;
IIf(aNFItem[nItem][IT_TS][TS_DESPIPI] == "O" .And. aNFCab[NF_OPERNF] == "E",aNfItem[nItem][IT_DESPESA]+aNfItem[nItem][IT_SEGURO],0)-;
IIf(aNFItem[nItem][IT_TS][TS_PSCFST] == "1" .And. aNFItem[nItem][IT_TS][TS_APSCFST] == "1",aNfItem[nItem][IT_VALPS3] + aNfItem[nItem][IT_VALCF3],0)-;
IIf(aNFItem[nItem][IT_TS][TS_AGRPIS]=="P" .And. aNFItem[nItem][IT_TS][TS_INTBSIC]$"123",aNfItem[nItem,IT_VALPS2],0)-If(aNFItem[nItem][IT_TS][TS_AGRCOF]=="C" .And. aNFItem[nItem][IT_TS][TS_INTBSIC]$"123",aNfItem[nItem,IT_VALCF2],0)+;
IIf(aNFCab[NF_TIPONF] $ "D" .And. aNFItem[nItem][IT_TS][TS_TPIPI]=="B",	aNfItem[nItem,IT_DESCZF],0)-;
IIf((aNFItem[nItem][IT_TS][TS_IPIFRET] == "N" .Or. (aNFItem[nItem][IT_TS][TS_IPIFRET] == "O" .And. aNFCab[NF_OPERNF] == "E")), aNfItem[nItem][IT_FRETE] ,0)

Local nReduzICMS := aNFItem[nItem][IT_TS][TS_BASEICM]
Local nReduzIPI  := aNFItem[nItem][IT_TS][TS_BASEIPI]
Local nReduzST	 := aNFItem[nItem][IT_TS][TS_BSICMST]
Local cMvEstado  := aSX6[MV_ESTADO]
Local lStfrete   := aSX6[MV_STFRETE] //Cod.Situação Tributaria para notas de conhecimento de frete
Local aRegra	 := {}
Local cMCSTIPI	 := aSX6[MV_RCSTIPI] //Controle de Rastro IPI

Local aMaCstPiCo := {}

Local aImp       := {"",; //SP_ITEM
                     "",; //SP_CODPRO
                     "",; //SP_IMP
                     "",; //SP_ORIGEM
                     "",; //SP_CST
					 "",; //SP_MODBC
					 0,;  //SP_MVA
					 0,;  //SP_PREDBC
					 0,;  //SP_BC
					 0,;  //SP_ALIQ
					 0,;  //SP_VLTRIB
					 0,;  //SP_QTRIB
					 0,;  //SP_PAUTA
					 "",; //SP_COD_MN
					 0,;  //SP_DESCZF
					 0,;  //SP_PARTICM
					 "",; //SP_GRPCST
					 "",; //SP_CEST
					 0,;  //SP_PICMDIF
					 0,;  //SP_VDDES
					 0,;  //SP_PDDES
					 0,;  //SP_PDORI
					 0,;  //SP_ADIF
					 0,;  //SP_PFCP
					 0,;  //SP_VFCP
					 0,;  //SP_DESONE
					 0,;  //SP_PDEVOL
					 0,;  //SP_BFCP
					 "";  //SP_FCPAJT
					 }
Local nImp       := 0
Local lLvrICM    := .F.
Local lLvrSol    := .F.
Local nBseISS    := 0
Local nDespesas  := 0
Local nQtd       := 0
Local nAliqDed   := 0
Local nAliqICMDe := 0
Local aReseta	 :=	{}
Local nValStDesone := 0
Local nBICMCheia := 0
Local nValIcOri  := 0
Local lIPITribGen := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_IPI)
Local lICMTribGen := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_ICMS)
Local lICSTTribGen := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_ICMSST)
Local nPosTrG	 := 0
// variável abaixo criada para verificar se a NF vem do EIC
Local lEIC := aSX6[MV_EASY] == "S" .and. aNfCab[NF_OPERNF] == "E" .and. aNFItem[nItem][IT_TS][TS_AGREG] $ "B|C"

Default lRecPreSt		:= .F. //-- Recalcula valor crédito presumido de substituicao tributária
Default lProcExcecao 	:= .T. //Ja passou pelo MaExcecao no MAFISLF

// decisão abaixo feita com base na ISSUE DSERFISE-1916
// primeiro verifico se é uma NF calculada no EIC e se tem valor de ICMS diferido
If lEIC .and. aNfItem[nItem][IT_ICMSDIF] > 0
	// preencho a referência IT_COLVDIF
	aNfItem[nItem][IT_COLVDIF]	:= Iif(aNFItem[nItem][IT_TS][TS_COLVDIF] $ '1/2' .AND. aNFItem[nItem][IT_TS][TS_PICMDIF]<>0 .AND.;
									   aNFItem[nItem][IT_TS][TS_PICMDIF]<>100 .AND. aPos[FP_FT_VOPDIF] , aNFItem[nItem][IT_TS][TS_COLVDIF] , '' )
	IF aNfItem[nItem][IT_COLVDIF] $ "1|2"
		// pego o que está em IT_BASEICM pois vem com o valor cheio do EIC
		nBICMOri := aNFItem[nItem][IT_BASEICM]
	EndIf
EndIf

If aNFItem[nItem][IT_TS][TS_AGREGCP]=="1" .And. aNFItem[nItem][IT_TS][TS_TPCPRES] $ "C|M"
	MaFisVTot(nItem) //Usado para este caso especifico devido diversas chamadas na pilha onde o credito presumido é agregado valor contabil.
EndIf

If aNFItem[nItem][IT_TS][TS_CONSUMO] == " " // Garante se o produto na operacao eh material de consumo mesmo que na TES nao tenha sido informado
	If (aNFItem[nItem][IT_TS][TS_INCIDE] == "S" .Or. (aNFItem[nItem][IT_TS][TS_INCIDE] == "F" .And. aNFCab[NF_TPCLIFOR] == "F" .And. aNFCab[NF_CLIFOR] == "C" )) .And.;
		( Substr(aNfItem[nItem][IT_CF],2,3)$"91 /92 /97 " .Or. (Substr(aNfItem[nItem][IT_CF],2,2) $ "55" .And. Substr(aNfItem[nItem][IT_CF],4,1)<>" ")) .And. aNFItem[nItem][IT_TS][TS_IPI] <> "R"
		lConsumo := .T.
	Endif
EndIf

//Garanto a verificacao da Excecao Fiscal
If Empty(aNFitem[nItem][IT_EXCECAO] ) .AND. lProcExcecao
	MaExcecao(nItem)
Endif

//Carrega a reducao da base do ICMS
nReduzICMS := PerRedIC(aNfItem,nItem,aNfCab)

//Carrega a reducao da base do IPI	
nReduzIPI  := PerRedIPI(aNfItem,nItem)

//Carrega a reducao da base do ICMS ST		
nReduzST	 := PerRedST(aNfItem,nItem)	


aNfItem[nItem][IT_LIVRO] := aClone(MaFisRetLF())

aNfItem[nItem][IT_LIVRO][LF_BICMORI] := IIF(aNfitem[nItem][IT_BICMORI] > 0, aNfitem[nItem][IT_BICMORI], nBICMOri)

If aNFItem[nItem][IT_TS][TS_LFICM] <> "N" .Or. aNFItem[nItem][IT_TS][TS_LFIPI] <> "N" .Or. aNFItem[nItem][IT_TS][TS_LFISS] $"TIO"
	If cPaisLoc == "BRA"
		If len(Alltrim(aNfitem[nItem][IT_CLASFIS])) < 3 .Or. ;
		(aNfitem[nItem][IT_TIPONF] == "D" .And. !Empty(aNFItem[nItem][IT_RECORI]) .And.  aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] == "C" )
            If Empty(aNfitem[nItem][IT_CLASFIS]) .Or.;
					Empty(Substr(aNfitem[nItem][IT_CLASFIS],2,2)) .Or.;
					aNfitem[nItem][IT_CLASFIS] == aNfItem[nItem][IT_PRD][SB_ORIGEM] + aNFItem[nItem][IT_TS][TS_SITTRIB] .Or.;
					aNfitem[nItem][IT_CLASFIS] == "0" + aNFItem[nItem][IT_TS][TS_SITTRIB]

				If aSX6[MV_STFRETE] .And. (AllTrim(aNFCab[NF_ESPECIE]) $ "CTR/CTE/CTA/CTF" .Or. "NFST"$AllTrim(aNFCab[NF_ESPECIE]))
					aNfitem[nItem][IT_CLASFIS] := "0" + aNFItem[nItem][IT_TS][TS_SITTRIB] // Comforme parecer da Consultoria Tributaria emitido no chamado SCSFW2
				Else
					If aNfitem[nItem][IT_TIPONF] == "D" .And. !Empty(aNFItem[nItem][IT_RECORI]) .And.  aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] == "C" .And. aSX6[MV_CSTORI]
						dbSelectArea("SD2")
						MsGoto( aNFItem[nItem][IT_RECORI] )
						aNfitem[nItem][IT_CLASFIS] := SD2->D2_CLASFIS
					Else
						aNfitem[nItem][IT_CLASFIS] := aNfItem[nItem][IT_PRD][SB_ORIGEM] + aNFItem[nItem][IT_TS][TS_SITTRIB]
					EndIf
				EndIf
			Endif
		EndIf

		aNfItem[nItem][IT_LIVRO][LF_RECISS]		:= aNfCab[NF_RECISS]
		aNfItem[nItem][IT_LIVRO][LF_ISSST]		:= aNFItem[nItem][IT_TS][TS_ISSST]
		aNfItem[nItem][IT_LIVRO][LF_CFO]		:= aNfItem[nItem][IT_CF]
		aNfItem[nItem][IT_LIVRO][LF_CFOEXT]		:= aNFItem[nItem][IT_TS][TS_CFEXT]
		aNfItem[nItem][IT_LIVRO][LF_NFLIVRO]	:= aNFItem[nItem][IT_TS][TS_NRLIVRO]
		aNfItem[nItem][IT_LIVRO][LF_FORMULA]	:= aNFItem[nItem][IT_TS][TS_FORMULA]
		aNfItem[nItem][IT_LIVRO][LF_CLASFIS]	:= aNfItem[nItem][IT_CLASFIS]
		aNfItem[nItem][IT_LIVRO][LF_POSIPI]		:= aNfItem[nItem][IT_POSIPI]

		//Troca CST no Rastro de IPI.
		If aNfItem[nItem][IT_BASEIPI] > 0 .Or. Empty(cMCSTIPI)
			aNfItem[nItem][IT_LIVRO][LF_CTIPI]	:= aNFItem[nItem][IT_TS][TS_CTIPI]
		Else
			aNfItem[nItem][IT_LIVRO][LF_CTIPI]:= cMCSTIPI
		EndIf

		aNfItem[nItem][IT_LIVRO][LF_CSTPIS]	:= aNFItem[nItem][IT_TS][TS_CSTPIS]
		aNfItem[nItem][IT_LIVRO][LF_CSTCOF]	:= aNFItem[nItem][IT_TS][TS_CSTCOF]

		If aPE[PE_MACSTPICO]
			aMaCstPiCo := ExecBlock("MaCstPiCo",.f.,.f.,{nItem,aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_TES],aNfCab[NF_CLIFOR],aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],aNfCab[NF_OPERNF]})
			aNfItem[nItem][IT_LIVRO][LF_CSTPIS]	:= aMaCstPiCo[1]
			aNfItem[nItem][IT_LIVRO][LF_CSTCOF]	:= aMaCstPiCo[2]
		EndIf

		//Se atender condição do decreto 5602 o CST de PIS e da COFINS deverão ser de alíquota zero - 06. Caso seja uma nota de devolucao o CST deve ser 73
		If aNfItem[nItem][IT_TABNTRE] == "4313" .AND. Decret5602((aNfItem[nItem][IT_VALMERC]/ aNfItem[nItem][IT_QUANT]),aNfItem[nItem][IT_POSIPI],aNfItem[nItem][IT_CODNTRE])
			If aNfitem[nItem][IT_TIPONF] == "D"
				aNfItem[nItem][IT_LIVRO][LF_CSTPIS]	:= "73"
				aNfItem[nItem][IT_LIVRO][LF_CSTCOF]	:= "73"
			ElseIf aNfCab[NF_OPERNF] == "S"
				aNfItem[nItem][IT_LIVRO][LF_CSTPIS]	:= "06"
				aNfItem[nItem][IT_LIVRO][LF_CSTCOF]	:= "06"
			EndIf
		EndIF

		aNfItem[nItem][IT_LIVRO][LF_ESTOQUE]	:= aNFItem[nItem][IT_TS][TS_ESTOQUE]
		aNfItem[nItem][IT_LIVRO][LF_DESPIPI]	:= aNFItem[nItem][IT_TS][TS_DESPIPI]
		aNfItem[nItem][IT_LIVRO][LF_CFPS]		:= aNfItem[nItem][IT_CFPS]
		aNfItem[nItem][IT_RGESPST]				:= aNFItem[nItem][IT_TS][TS_RGESPST]
		aNfItem[nItem][IT_LIVRO][LF_ANTICMS]	:= aNFItem[nItem][IT_TS][TS_ANTICMS]
		aNfItem[nItem][IT_LIVRO][LF_CREDACU]	:= aNFItem[nItem][IT_TS][TS_CREDACU]
		aNfItem[nItem][IT_LIVRO][LF_CSTISS]		:= aNFItem[nItem][IT_TS][TS_CSTISS]
		aNfItem[nItem][IT_LIVRO][LF_MOTICMS]	:= aNFItem[nItem][IT_TS][TS_MOTICMS]
		aNfItem[nItem][IT_LIVRO][LF_CODBCC]		:= aNFItem[nItem][IT_TS][TS_CODBCC]
		aNfItem[nItem][IT_LIVRO][LF_INDNTFR]	:= aNFItem[nItem][IT_TS][TS_INDNTFR]
		aNfItem[nItem][IT_LIVRO][LF_TABNTRE]	:= aNfItem[nItem][IT_TABNTRE]
		aNfItem[nItem][IT_LIVRO][LF_CODNTRE]	:= aNfItem[nItem][IT_CODNTRE]
		aNfItem[nItem][IT_LIVRO][LF_GRPNTRE]	:= aNfItem[nItem][IT_GRPNTRE]
		aNfItem[nItem][IT_LIVRO][LF_DATNTRE]	:= aNfItem[nItem][IT_DATNTRE]

		//Pegando o item da NF Original
		If aNFCab[NF_TIPONF] $ "DBCIP"
			If !Empty(aNFItem[nItem][IT_RECORI])
				If ( aNFCab[NF_CLIFOR] == "C" )
					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					aNfItem[nItem][IT_LIVRO][LF_ITEMORI] 	:= SD2->D2_ITEM
					aNfItem[nItem][IT_EMISNFORI] := SD2->D2_EMISSAO

					If !(aNFCab[NF_TIPONF] $ "P")
						dbSelectArea("CD2")
						dbSetOrder(1)
						//Se for nota de Complemento de ICMS "I", não pega o valor da Redução de base de cálculo
						If !(aNFCab[NF_TIPONF] $ "I")
							//A referencia IT_PREDIC diz respeito apenas aos registro de ICMS na tabela CD2, portanto devo procurar apenas os registros
							//de ICMS para buscar a reducao correta na origem.
							If MsSeek(xFilial("CD2")+"S"+SD2->(D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA+PadR(D2_ITEM,GTamMxFis(TAM_CD2_ITEM))+D2_COD)+PadR("ICM",GTamMxFis(TAM_CD2_IMP)))
								aNfItem[nItem][IT_PREDIC] := CD2->CD2_PREDBC								
							EndIf
						EndIF

						//Busca na tabela CD2 o valor da Pauta utilizada para o cálculo do ICMS-ST no movimento original
						If MsSeek(xFilial("CD2")+"S"+SD2->(D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA+PadR(D2_ITEM,GTamMxFis(TAM_CD2_ITEM))+D2_COD)+PadR("SOL",GTamMxFis(TAM_CD2_IMP)))
							aNfItem[nItem][IT_PAUTST] := CD2->CD2_PAUTA
						EndIf
					EndIf	

				Else
					dbSelectArea("SD1")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					aNfItem[nItem][IT_LIVRO][LF_ITEMORI] 	:= SD1->D1_ITEM
					aNfItem[nItem][IT_EMISNFORI] := SD1->D1_EMISSAO

					If !(aNFCab[NF_TIPONF] $ "IP")
						dbSelectArea("CD2")
						dbSetOrder(2)
						//A referencia IT_PREDIC diz respeito apenas aos registro de ICMS na tabela CD2, portanto devo procurar apenas os registros
						//de ICMS para buscar a reducao correta na origem.
						If MsSeek(xFilial("CD2")+"E"+SD1->(D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA+PadR(D1_ITEM,GTamMxFis(TAM_CD2_ITEM))+D1_COD)+PadR("ICM",GTamMxFis(TAM_CD2_IMP)))
							aNfItem[nItem][IT_PREDIC] := CD2->CD2_PREDBC
						EndIf

						//Busca na tabela CD2 o valor da Pauta utilizada para o cálculo do ICMS-ST no movimento original
						If MsSeek(xFilial("CD2")+"E"+SD1->(D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA+PadR(D1_ITEM,GTamMxFis(TAM_CD2_ITEM))+D1_COD)+PadR("SOL",GTamMxFis(TAM_CD2_IMP)))
							aNfItem[nItem][IT_PAUTST] := CD2->CD2_PAUTA
						EndIf
					EndIf						
				EndIf
			EndIf
		Else
			If !Empty(aNFItem[nItem][IT_RECORI])
				If ( aNFCab[NF_CLIFOR] == "C" )
					dbSelectArea("SD1")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					aNfItem[nItem][IT_LIVRO][LF_ITEMORI] := SD1->D1_ITEM
					aNfItem[nItem][IT_EMISNFORI] := SD1->D1_EMISSAO
				Else
					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					aNfItem[nItem][IT_LIVRO][LF_ITEMORI] := SD2->D2_ITEM
					aNfItem[nItem][IT_EMISNFORI] := SD2->D2_EMISSAO
				EndIf
			EndIf
		EndIf

		//Abatimento na base de calculo do ISS referente a subempreitada
		aNfItem[nItem][IT_LIVRO][LF_ISSSUB]	:= aNfItem[nItem][IT_ABVLISS]
		//Abatimento na base de calculo do ISS referente ao material aplicado
		aNfItem[nItem][IT_LIVRO][LF_ISSMAT]	:= aNfItem[nItem][IT_ABMATISS]
		//Grava o Valor dos Descontos na Observacao.
		aNfItem[nItem][IT_LIVRO][LF_VALOBSE]	:= (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT])+IIf(aNfCab[NF_OPERNF] == "S",aNfItem[nItem][IT_DESCZF],0);
		+IIf((Len(aNfItem[nItem]) > 105 .And. aNfItem[nItem][IT_DESCPRO] > 0 ),aNfItem[nItem][IT_DESCPRO],0)
		//Grava o Valor dos Descontos - Zona Franca de Manaus
		aNfItem[nItem][IT_LIVRO][LF_DESCZFR] := aNfItem[nItem][IT_DESCZF]
		//Valor do desconto e Valor do ICMS sem debito de imposto-Decreto 43.080/2002 do RICMS-MG
		If aNfItem[nItem][IT_ICSEMDS] > 0
			aNfItem[nItem][IT_LIVRO][LF_DS43080] := aNfItem[nItem][IT_DS43080]
			aNfItem[nItem][IT_LIVRO][LF_VL43080] := aNfItem[nItem][IT_TOTAL] - aNfItem[nItem][IT_BASEICM]
		Endif
		//ICMS Diferido
		If aNFItem[nItem][IT_TS][TS_ICMSDIF] $ "1/3/5/7"
			aNfItem[nItem][IT_LIVRO][LF_ICMSDIF]	:= aNfItem[nItem][IT_ICMSDIF]
		EndIf
		//Grava o Valor de PIS/COFINS Subst. Tributaria
		aNfItem[nItem][IT_LIVRO][LF_BASEPS3]	:= aNfItem[nItem][IT_BASEPS3]
		aNfItem[nItem][IT_LIVRO][LF_ALIQPS3]	:= aNfItem[nItem][IT_ALIQPS3]
		aNfItem[nItem][IT_LIVRO][LF_VALPS3]		:= aNfItem[nItem][IT_VALPS3]
		aNfItem[nItem][IT_LIVRO][LF_BASECF3]	:= aNfItem[nItem][IT_BASECF3]
		aNfItem[nItem][IT_LIVRO][LF_ALIQCF3]	:= aNfItem[nItem][IT_ALIQCF3]
		aNfItem[nItem][IT_LIVRO][LF_VALCF3]		:= aNfItem[nItem][IT_VALCF3]
		//Grava o Valor do ISS Cepom
		aNfItem[nItem][IT_LIVRO][LF_BASECPM]	:= aNfItem[nItem][IT_BASECPM]
		aNfItem[nItem][IT_LIVRO][LF_ALQCPM]		:= aNfItem[nItem][IT_ALQCPM]
		aNfItem[nItem][IT_LIVRO][LF_VALCPM]		:= aNfItem[nItem][IT_VALCPM]
		//Grava o Valor do FUMIPEQ
		aNfItem[nItem][IT_LIVRO][LF_BASEFMP]	:= aNfItem[nItem][IT_BASEFMP]
		aNfItem[nItem][IT_LIVRO][LF_VALFMP]		:= aNfItem[nItem][IT_VALFMP]
		aNfItem[nItem][IT_LIVRO][LF_ALQFMP]		:= aNfItem[nItem][IT_ALQFMP]
		//Grava o valor do FAMAD
		aNfItem[nItem][IT_LIVRO][LF_VALFMD]		:= aNfItem[nItem][IT_VALFMD]
		//Grava o valor do Fundersul - Mato Grosso do Sul
		aNfItem[nItem][IT_LIVRO][LF_VALFDS]		:= aNfItem[nItem][IT_VALFDS]
        //Grava base e valor do Senar
		aNfItem[nItem][IT_LIVRO][LF_ALSENAR]	:= aNfItem[nItem][IT_ALSENAR]
		aNfItem[nItem][IT_LIVRO][LF_BSSENAR]	:= aNfItem[nItem][IT_BSSENAR]
		aNfItem[nItem][IT_LIVRO][LF_VLSENAR]	:= aNfItem[nItem][IT_VLSENAR]
		//Grava base e valor do Funrural
		aNfItem[nItem][IT_LIVRO][LF_BASEFUN]  	:= aNfItem[nItem][IT_BASEFUN]
		aNfItem[nItem][IT_LIVRO][LF_VALFUN]  	:= aNfItem[nItem][IT_FUNRURAL]
		//Grava o valor do FETHAB - Mato Grosso
		aNfItem[nItem][IT_LIVRO][LF_VALFET]		:= aNfItem[nItem][IT_VALFET]
		//Grava o valor do FACS - Mato Grosso
		aNfItem[nItem][IT_LIVRO][LF_VALFAC]		:= aNfItem[nItem][IT_VALFAC]
		//Grava o valor do FABOV - Mato Grosso
		aNfItem[nItem][IT_LIVRO][LF_VALFAB]		:= aNfItem[nItem][IT_VALFAB]
		//Grava o valor do FAMAD - Mato Grosso
		aNfItem[nItem][IT_LIVRO][LF_VALFMD]		:= aNfItem[nItem][IT_VALFMD]
		//Grava o Valor do ICMS ST cobrado Anteriormente
		aNfItem[nItem][IT_LIVRO][LF_BASNDES]	:= aNfItem[nItem][IT_BASNDES]
		aNfItem[nItem][IT_LIVRO][LF_ICMNDES]	:= aNfItem[nItem][IT_ICMNDES]
		//Grava o valor do CPBR
		aNfItem[nItem][IT_LIVRO][LF_BASECPB]	:= aNfItem[nItem][IT_BASECPB]
		aNfItem[nItem][IT_LIVRO][LF_VALCPB]		:= aNfItem[nItem][IT_VALCPB]
		aNfItem[nItem][IT_LIVRO][LF_ALIQCPB]	:= aNfItem[nItem][IT_ALIQCPB]
		//Grava Base Original ICMS
		aNfItem[nItem][IT_LIVRO][LF_BSICMOR]	:= aNfItem[nItem][IT_BICMORI]
		//Grava FUNDESA
		aNfItem[nItem][IT_LIVRO][LF_VALFUND]	:= aNfItem[nItem][IT_VALFUND]
		//Grava IMA-MT
		aNfItem[nItem][IT_LIVRO][LF_VALIMA]	:= aNfItem[nItem][IT_VALIMA]
		//Grava FASE-MT
		aNfItem[nItem][IT_LIVRO][LF_VALFASE]	:= aNfItem[nItem][IT_VALFASE]

		//Grava o Valor Contabil.
		If aNFitem[nItem][IT_TIPONF] <> "I" .Or. aNfItem[nItem][IT_VALSOL] <> 0
			If aNFItem[nItem][IT_TS][TS_ICMSDIF] $ "3/5/7"
				aNfItem[nItem][IT_LIVRO][LF_VALCONT] := aNfItem[nItem][IT_TOTAL]+IIf(lLfAgreg,aNfItem[nItem][IT_VALMERC],0)-If(aNFItem[nItem][IT_TS][TS_LFIPI]=="N".And.aNFItem[nItem][IT_TS][TS_AGREG]=="N",aNfItem[nItem][IT_VALIPI],0)
				If aNFItem[nItem][IT_TS][TS_LFICM]=="B"
					aNfItem[nItem][IT_LIVRO][LF_VALOBSE] := aNfItem[nItem][IT_LIVRO][LF_VALCONT]
					aNfItem[nItem][IT_LIVRO][LF_VALCONT] := 0
				EndIf
			Else
				//Incentivo à produção e à industrialização do leite
				If aPos[FP_FT_VLINCMG] .And. aNfItem[nItem][IT_VLINCMG] > 0
					aNfItem[nItem][IT_LIVRO][LF_VALCONT]	:= aNfItem[nItem][IT_TOTAL]+IIf(lLfAgreg,aNfItem[nItem][IT_VALMERC],0)-aNfItem[nItem][IT_LIVRO][LF_ICMSDIF]-If(aNFItem[nItem][IT_TS][TS_LFIPI]=="N".AND.aNFItem[nItem][IT_TS][TS_AGREG]=="N",aNfItem[nItem][IT_VALIPI],0) + aNfItem[nItem][IT_VLINCMG]
				Else
					aNfItem[nItem][IT_LIVRO][LF_VALCONT]	:= aNfItem[nItem][IT_TOTAL]+Iif(lLfAgreg,aNfItem[nItem][IT_VALMERC],0)-Iif(aNFItem[nItem][IT_TS][TS_LFIPI]=="N".AND.aNFItem[nItem][IT_TS][TS_AGREG]=="N",aNfItem[nItem][IT_VALIPI],0)
				Endif
				//Tratamento Original - Foi retirado a Subtracao do ICMS DIFERIDO - CHAMADO: TDMSJ9.
				//aNfItem[nItem][IT_LIVRO][LF_VALCONT]	:= aNfItem[nItem][IT_TOTAL]+IIf(lLfAgreg,aNfItem[nItem][IT_VALMERC],0)-aNfItem[nItem][IT_LIVRO][LF_ICMSDIF]-If(aNFItem[nItem][IT_TS][TS_LFIPI]=="N".AND.aNFItem[nItem][IT_TS][TS_AGREG]=="N",aNfItem[nItem][IT_VALIPI],0)
				If aNFItem[nItem][IT_TS][TS_LFICM]=="B"
					aNfItem[nItem][IT_LIVRO][LF_VALOBSE]	:= aNfItem[nItem][IT_LIVRO][LF_VALCONT]
					aNfItem[nItem][IT_LIVRO][LF_VALCONT]	:= 0
				EndIf
			EndIf
		EndIf

		//Operacoes com Sucata
		If aNFItem[nItem][IT_TS][TS_OPERSUC]=="1" .And. aNfCab[NF_SIMPSC]<>"1" .And. aNFCab[NF_SIMPNAC]<>"1"
			aNfItem[nItem][IT_LIVRO][LF_VALCONT]:=aNfItem[nItem][IT_TOTAL]+aNfItem[nItem][IT_VALICM]
			aNfItem[nItem][IT_LIVRO][LF_OUTRICM]:=aNfItem[nItem][IT_VALICM]
		Endif

		//                                                             ATENCAO !!!

		// CREDITO PRESUMIDO / OUTORGADO / ESTIMULO

		//Existem varios nomes de campos e referencias diferentes para calculo do Credito Presumido e os mesmos NAO podem mais ser alterados,
		//contudo ficou definido (Liz) que NOVOS creditos presumidos que forem criados obedecam a nomeclatura NF_CRDPRES para o cabecalho,
		//IT_CRPRE?? onde ?? = UF do ESTADO para o item, Exemplo: IT_CRPRESP, TS_CRDPRES para TES SF4 e LF_CRDPRES para o LIVRO SF3

		//                                         NAO CRIAR FUNCAO PARA CALULAR O CREDITO PRESUMIDO
		// Colocar e alimentar a referencia IT_CRPRE?? nesta sessao, pois varias regras para o calculo dependem do VALOR CONTABIL que e
		// definido nesta funcao (MaFisLF). Siga e observe os exemplos abaixo.

		//Executa calculo do valor de Reintegra - Per/Dcomp - REINTEGRA
		aNfItem[nItem][IT_BSREIN]	:= 0
		aNfItem[nItem][IT_VREINT]	:= 0

		// Somando frete + seguro + despesas p/ agregar (ou não) na base de calculo do reintegra.
		nDespesas := aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO]

		If aSX6[MV_PEREINT] > 0 .And. aNfItem[nItem][IT_VALMERC] > 0 .And. aNfItem[nItem][IT_PRD][SB_ORIGEM] $ "0|3|5|4"
			If Alltrim(aNfItem[nItem][IT_CF])$"7101/7102/7105/7106/7127/7251/7301/7358/7551/7651/7654/7667/7504 " .And. aNfCab[NF_TPCLIFOR] == "X" .And. aNfCab[NF_UFDEST] == "EX"
				aNfItem[nItem][IT_BSREIN] :=(aNfItem[nItem][IT_VALMERC] - (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT])) + Iif(aSX6[MV_DSPREIN], nDespesas, 0)
			ElseIf Alltrim(aNfItem[nItem][IT_CF])$"5501/5502/6501/6502"
				aNfItem[nItem][IT_BSREIN] :=aNfItem[nItem][IT_VALMERC]+aNfItem[nItem][IT_DESPESA]
			EndIf
			aNfItem[nItem][IT_VREINT] := aNfItem[nItem][IT_BSREIN]*( aSX6[MV_PEREINT] / 100)
		EndIf

		aNfItem[nItem][IT_LIVRO][LF_VREINT] := aNfItem[nItem][IT_VREINT]
		aNfItem[nItem][IT_LIVRO][LF_BSREIN] := aNfItem[nItem][IT_BSREIN]

		//Calcula Credito presumido
		// CREDITO ESTIMULO MANAUS - TS_CRDEST = 1 - Nao Calcula | 2 - Produtos Eletronicos | 3 - Contrucao Civil |4 - Pelo NCM		
		FISXCRDPRE(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, nBICMOri,"1", cAliasPROD)
		
		If xFisGrossIR(nItem, aNFItem, aNfCab, "VALCONT") //Verifica se deverá considerar GrossUp do IRRF no valor contábil
			aNfItem[nItem][IT_LIVRO][LF_VALCONT]	:= aNfItem[nItem][IT_LIVRO][LF_VALCONT] / ( 1 - ( aNfItem[nItem][IT_ALIQIRR] / 100 ) )
		EndIF

		//Calculo do crédito referente à Antecipação Tributária
		If aNfItem[nItem][IT_VALSOL] > 0 .And. aNFItem[nItem][IT_TS][TS_ANTICMS] == "1" .And. !aSX6[MV_ANTICMS]
			aNfItem[nItem][IT_VALANTI]:= aNfItem[nItem][IT_VALSOL]
		Endif

		// Grava o valor do ICMS do Frete Autonomo no Livro Fiscal
		aNfItem[nItem][IT_LIVRO][LF_ICMAUTO] := IIF(aNfCab[NF_RECFAUT]<>"2",aNfItem[nItem][IT_VALICA],0)

		//Grava o valor do ICMS do Frete Autonomo no Livro Fiscal - Embarcador
		//Somente efetua gravacao se o pedido indicar que o responsavel pelo recolhimento
		//e o emissor do documento fiscal e nao o transportador.
		If aNfCab[NF_RECFAUT] <> "2"
			aNfItem[nItem][IT_LIVRO][LF_BASETST]:= aNfItem[nItem][IT_BASETST]
			aNfItem[nItem][IT_LIVRO][LF_VALTST] := aNfItem[nItem][IT_VALTST]
		Endif

		If aNfCab[NF_TIPONF] $ "DBCIP"
			aNfItem[nItem][IT_LIVRO][LF_TIPO]:= aNfCab[NF_TIPONF]
		EndIf

		//Livro de ICMS
		IF !(aNFItem[nItem][IT_TS][TS_LFICM]$'NZ') .And. aNFItem[nItem][IT_TS][TS_ISS]<>"S"

			if aNfItem[nItem][IT_VOPDIF] > 0
				If lEIC
					If aNfItem[nItem][IT_COLVDIF] == '1'
						aNfItem[nItem][IT_LIVRO][LF_OUTRICM]	:= nBICMOri * (aNFItem[nItem][IT_TS][TS_PICMDIF] / 100)
					ElseIF aNfItem[nItem][IT_COLVDIF] == '2'
						aNfItem[nItem][IT_LIVRO][LF_ISENICM]	:= nBICMOri * (aNFItem[nItem][IT_TS][TS_PICMDIF] / 100)
					EndIf
				Else
					//Diferimento de ICMS quando a diferença é gravada em Outros ou Isento
					If aNfItem[nItem][IT_COLVDIF] == '1'   //Outros
						aNfItem[nItem][IT_LIVRO][LF_OUTRICM]	:= nBICMOri - aNfItem[nItem][IT_BASEICM]
					ElseIf aNfItem[nItem][IT_COLVDIF] == '2' //Isento
						aNfItem[nItem][IT_LIVRO][LF_ISENICM] 	:= nBICMOri - aNfItem[nItem][IT_BASEICM]
					EndIF
				EndIf
			EndIf

			//Base do ICMS
			If nReduzICMS > 0 .And. nReduzICMS<>100
				If !lConsumo
					If aNFItem[nItem][IT_TS][TS_CONSUMO] == "O"
						If aNFItem[nItem][IT_TS][TS_LFICM] == "I"
							aNfItem[nItem][IT_LIVRO][LF_ISENICM] := (aNfItem[nItem][IT_BASEICM]-aNfItem[nItem][IT_VIPIBICM])+(nBICMOri-aNfItem[nItem][IT_BASEICM]+aNfItem[nItem][IT_VIPIBICM])
						Else
							aNfItem[nItem][IT_LIVRO][LF_OUTRICM] := (aNfItem[nItem][IT_BASEICM]-aNfItem[nItem][IT_VIPIBICM])+Max(nBICMOri-aNfItem[nItem][IT_BASEICM]+aNfItem[nItem][IT_VIPIBICM],0)
						EndIf
					Else
						aNfItem[nItem][IT_LIVRO][LF_BASEICM] := aNfItem[nItem][IT_BASEICM]
					Endif
				Else
					If aNFItem[nItem][IT_TS][TS_LFICM] == "I"
						aNfItem[nItem][IT_LIVRO][LF_ISENICM] := aNfItem[nItem][IT_BASEICM] - aNfItem[nItem][IT_VIPIBICM]
						aNfItem[nItem][IT_LIVRO][LF_OUTRICM] := nBICMOri-aNfItem[nItem][IT_BASEICM]+aNfItem[nItem][IT_VIPIBICM]
					Else
						aNfItem[nItem][IT_LIVRO][LF_ISENICM] := Max( nBICMOri-aNfItem[nItem][IT_BASEICM]+aNfItem[nItem][IT_VIPIBICM], 0 )
						aNfItem[nItem][IT_LIVRO][LF_OUTRICM] := aNfItem[nItem][IT_BASEICM]-aNfItem[nItem][IT_VIPIBICM]
					EndIf
				EndIf
			Else
				If aNFItem[nItem][IT_TS][TS_LFICM] == "T" .Or. (aNFItem[nItem][IT_TS][TS_LFICM] == "I" .And. aNFItem[nItem][IT_TS][TS_DESPICM]=="5")
					aNfItem[nItem][IT_LIVRO][LF_BASEICM] := aNfItem[nItem][IT_BASEICM]
				EndIf
			EndIf

			//Valor do ICMS Tributado
			If (aNFItem[nItem][IT_TS][TS_LFICM] =="T" .Or. (nReduzICMS<>100 .And. (nReduzICMS<>0.And.!lConsumo) .And. (nReduzICMS<>0 .And. !aNFItem[nItem][IT_TS][TS_CONSUMO]=="O")) .Or. (aNFItem[nItem][IT_TS][TS_LFICM] == "I" .And. aNFItem[nItem][IT_TS][TS_DESPICM]=="5"))
				aNfItem[nItem][IT_LIVRO][LF_VALICM] := aNfItem[nItem][IT_VALICM]
			EndIf

			//Tratamento para os casos do Art. 1. DECRETO 4.316 de 19 de Junho de 1995. art. 87 do RICMS/BA
			//O percentual informado no cadastro de TES deverah estar de acordo com o Art. 7. deste decreto.
			If (aNFItem[nItem][IT_TS][TS_CRPRELE]<>0)
				aNfItem[nItem][IT_LIVRO][LF_CRPRELE] := Round( aNfItem[nItem][IT_VALICM]*(aNFItem[nItem][IT_TS][TS_CRPRELE]/100), 2)
			EndIf

			// Grava o Valor do Credito Presumido - RJ - Prestacoes de Servicos de Transporte
			If aNFItem[nItem][IT_TS][TS_CRDTRAN]<>0
				If aNFItem[nItem][IT_TS][TS_TPCPRES] == "B"
					//Base de cálculo para crédito presumido será a base do ICMS
					aNfItem[nItem][IT_LIVRO][LF_CRDTRAN] := NoRound((aNfItem[nItem][IT_BASEICM] * aNFItem[nItem][IT_TS][TS_CRDTRAN]) / 100,2)
				Else
					aNfItem[nItem][IT_LIVRO][LF_CRDTRAN] := ( aNfItem[nItem][IT_VALICM] * aNFItem[nItem][IT_TS][TS_CRDTRAN]) / 100
				EndIf
			Endif

			//Valor da Coluna Isentas e Nao Tributadas
			If aNFItem[nItem][IT_TS][TS_LFICM] =="I"
				//Tanto reducao de 100% quanto a configuracao de consumo devem gravar a
				//  base como ZERO e o livro em OUTROS/ISENTO. Ex: VLr 1000, Reduca:100%,
				//  Lvr: Isento, fica = vlr contabil: 1000, Base: 0, Isento: 1000
				If nReduzICMS > 0 .And. nReduzICMS <> 100
					If !lConsumo .And. !aNFItem[nItem][IT_TS][TS_CONSUMO]=="O"
						If aNfItem[nItem][IT_PAUTIC] > 0 .And. aNfItem[nItem][IT_BICMORI] > nBICMOri
							aNfItem[nItem][IT_LIVRO][LF_ISENICM] := aNfItem[nItem][IT_BICMORI]-aNfItem[nItem][IT_BASEICM]+aNfItem[nItem][IT_VIPIBICM]
						Else
							aNfItem[nItem][IT_LIVRO][LF_ISENICM] := nBICMOri-aNfItem[nItem][IT_BASEICM]+aNfItem[nItem][IT_VIPIBICM]
						EndIf
					EndIf
				Else
					If aNFItem[nItem][IT_TS][TS_DESPICM]<> "5"
						aNfItem[nItem][IT_LIVRO][LF_ISENICM] := nBICMOri
					Else
						aNfItem[nItem][IT_LIVRO][LF_ISENICM] := (nBICMOri-aNfItem[nItem][IT_BASEICM])
					EndIf
				EndIf
			EndIf
			//Valor da Coluna Outras
			If aNFItem[nItem][IT_TS][TS_LFICM]=="O"
				If nReduzICMS > 0 .And. nReduzICMS <> 100
					If !lConsumo .And. !aNFItem[nItem][IT_TS][TS_CONSUMO]=="O"
						If aNfItem[nItem][IT_PAUTIC] > 0 .And. aNfItem[nItem][IT_BICMORI] > nBICMOri
							aNfItem[nItem][IT_LIVRO][LF_OUTRICM] := aNfItem[nItem][IT_BICMORI]-aNfItem[nItem][IT_BASEICM]+aNfItem[nItem][IT_VIPIBICM]
						Else
							aNfItem[nItem][IT_LIVRO][LF_OUTRICM] := nBICMOri-aNfItem[nItem][IT_BASEICM]+aNfItem[nItem][IT_VIPIBICM]
						EndIf
					EndIf
				Else
					aNfItem[nItem][IT_LIVRO][LF_OUTRICM] := (aNfItem[nItem][IT_BASEICM]-aNfItem[nItem][IT_VIPIBICM])+Max(nBICMOri-aNfItem[nItem][IT_BASEICM]+aNfItem[nItem][IT_VIPIBICM],0)
					// Tratamento do Diferimento  calculado pelo EIC, tendo que desconsiderar da coluna outros o valor diferido
					If ( aNFItem[nItem][IT_TS][TS_AGREG] $ "B|C" .And.	aNFItem[nItem][IT_TS][TS_ICMSDIF] $ "1|3|4|7" ) .And. aNfItem[nItem][IT_ICMSDIF]
						aNfItem[nItem][IT_LIVRO][LF_OUTRICM] -= aNfItem[nItem][IT_ICMSDIF] // Aqui ajustando para que o valor escriturado em outros desconsidere o valor diferido
						// Tratamento temporário até que o EIC envie a informação oara o campo D1_VOPDIF:
						If aNFItem[nItem][IT_TS][TS_PICMDIF]==100 .And. aNfItem[nItem][IT_VALICM] ==0
							aNfItem[nItem][IT_VOPDIF]  := aNfItem[nItem][IT_ICMSDIF]
						EndIf
					EndIf
				EndIf
			EndIf
			//Valor IPI na coluna Outros ICMS
			If aNFItem[nItem][IT_TS][TS_INCIDE] == "O"
				aNfItem[nItem][IT_LIVRO][LF_OUTRICM] += aNfItem[nItem][IT_VALIPI]
			EndIf
		EndIf

		// Grava o Valor do Credito Presumido - MG - Prestacoes de Servicos de Transporte
		If aNFItem[nItem][IT_TS][TS_LFICM]=="Z" .And. aNFItem[nItem][IT_TS][TS_OBSSOL]=="5" .And. aNfItem[nItem][IT_BASESOL] > 0 .And. aNfItem[nItem][IT_BASEICM] == 0 .And. aNFItem[nItem][IT_TS][TS_CRDTRAN]<>0
			If aNFItem[nItem][IT_TS][TS_TPCPRES] == "B"
				//Base de cálculo para crédito presumido será a base do ICMS
				aNfItem[nItem][IT_LIVRO][LF_CRDTRAN] := NoRound((aNfItem[nItem][IT_BASESOL] * aNFItem[nItem][IT_TS][TS_CRDTRAN]) / 100,2)
			Else
				aNfItem[nItem][IT_LIVRO][LF_CRDTRAN] := (aNfItem[nItem][IT_VALSOL] * aNFItem[nItem][IT_TS][TS_CRDTRAN]) / 100
			EndIf
		Endif

		// ICMS Complementar
		aNfItem[nItem][IT_LIVRO][LF_ICMSCOMP]:= aNfItem[nItem][IT_VALCMP]

		//Difal ICMS EC 87/2015
		aNfItem[nItem][IT_LIVRO][LF_DIFAL] := aNfItem[nItem][IT_DIFAL]
		aNfItem[nItem][IT_LIVRO][LF_VFCPDIF] := aNfItem[nItem][IT_VFCPDIF]
		aNfItem[nItem][IT_LIVRO][LF_BASEDES] := aNfItem[nItem][IT_BASEDES]

		// Antecipacao ICMS
		aNfItem[nItem][IT_LIVRO][LF_VALANTI] := aNfItem[nItem][IT_VALANTI]

		// Valor FECP
		aNfItem[nItem][IT_LIVRO][LF_VALFECP] := aNfItem[nItem][IT_VALFECP]
		aNfItem[nItem][IT_LIVRO][LF_VFECPST] := aNfItem[nItem][IT_VFECPST]

		// Valor FECOP RN
		aNfItem[nItem][IT_LIVRO][LF_VFECPRN] := aNfItem[nItem][IT_VFECPRN]
		aNfItem[nItem][IT_LIVRO][LF_VFESTRN] := aNfItem[nItem][IT_VFESTRN]

		// Valor FECP-MG
		aNfItem[nItem][IT_LIVRO][LF_VFECPMG] := aNfItem[nItem][IT_VFECPMG]
		aNfItem[nItem][IT_LIVRO][LF_VFESTMG] := aNfItem[nItem][IT_VFESTMG]

		// Valor FECP-MT
		aNfItem[nItem][IT_LIVRO][LF_VFECPMT] := aNfItem[nItem][IT_VFECPMT]
		aNfItem[nItem][IT_LIVRO][LF_VFESTMT] := aNfItem[nItem][IT_VFESTMT]

		// Valor do Pedágio
		aNfItem[nItem][IT_LIVRO][LF_VALPEDG] := aNfItem[nItem][IT_VALPEDG]

		// Base do INSS Patronal
		aNfItem[nItem][IT_LIVRO][LF_BASEINP] := aNfItem[nItem][IT_BASEINP]

		// Percentual do INSS Patronal
		aNfItem[nItem][IT_LIVRO][LF_PERCINP] := aNfItem[nItem][IT_PERCINP]

		// Valor do INSS Patronal
		aNfItem[nItem][IT_LIVRO][LF_VALINP] := aNfItem[nItem][IT_VALINP]

		//Credito Outorgado - GO Inc.III, Art 11 Anexo IX - RCTE-GO/97
		FISXCRDPRE(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, nBICMOri,"4", cAliasPROD)
		
		// Valor FUMACOP
		aNfItem[nItem][IT_LIVRO][LF_VALFUM]	 := aNfItem[nItem][IT_VALFUM]
		// Valor TPDP-PB
		aNfItem[nItem][IT_LIVRO][LF_VALTPDP]:= aNfItem[nItem][IT_VALTPDP]
		// Transferencia de Debito e Credito
		If aNFItem[nItem][IT_TS][TS_TRFICM]=="1"
			aNfItem[nItem][IT_LIVRO][LF_TRFICM]	 := aNfItem[nItem][IT_VALMERC]
		EndIf
		//Grava valor Credito Presumido Substituicao Tributaria retido pelo contratante do servico de transporte - Decreto 44.147/2005 (MG)		
		FISXCRDPRE(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, nBICMOri,"2",cAliasPROD)
		
		// ICMS Solidario.
		aNfItem[nItem][IT_LIVRO][LF_ICMSRET]:= aNfItem[nItem][IT_VALSOL]
		aNfItem[nItem][IT_LIVRO][LF_BASERET]:= aNfItem[nItem][IT_BASESOL]
		If aNFItem[nItem][IT_TS][TS_OBSICM] == "1"
			aNfItem[nItem][IT_LIVRO][LF_OBSICM] := aNfItem[nItem][IT_VALICM]
		Endif
		If aNFItem[nItem][IT_TS][TS_OBSSOL] == "1"
			aNfItem[nItem][IT_LIVRO][LF_OBSSOL] := aNfItem[nItem][IT_VALSOL]
		elseif aNFItem[nItem][IT_TS][TS_OBSSOL] == "3"   //icms garantido MT
			aNfItem[nItem][IT_LIVRO][LF_OBSERV] := " ICMS Garantido "
		elseif aNFItem[nItem][IT_TS][TS_OBSSOL] == "4"   //icms garantido integral MT
			aNfItem[nItem][IT_LIVRO][LF_OBSERV] := " ICMS Garantido Integral"
		EndIf

		If aNFItem[nItem][IT_TS][TS_CREDST] $ "1#3#4"
			If aNFItem[nItem][IT_TS][TS_CREDST] <> "4"
				aNfItem[nItem][IT_LIVRO][LF_SOLTRIB] := aNfItem[nItem][IT_VALSOL]
			Endif
			aNfItem[nItem][IT_LIVRO][LF_CREDST ] := aNFItem[nItem][IT_TS][TS_CREDST]
		EndIf
		// ICMS Aliquota
		If aNfItem[nItem][IT_LIVRO][LF_BASEICM] == 0
			aNfItem[nItem][IT_LIVRO][LF_ALIQICMS] := 0
		Else
			aNfItem[nItem][IT_LIVRO][LF_ALIQICMS] := aNfItem[nItem][IT_ALIQICM]
		EndIf
		//Quando o IPI estiver na base do ICMS preencher o valor do IPI na Observ.
		If aNfItem[nItem][IT_VIPIBICM]>0 .And. SubStr(cIPInaObs,2,1)=="S" .And. aNFItem[nItem][IT_TS][TS_IPIOBS] $ " 1" .And. aNFCab[NF_TPCLIFOR] <> "X"
			aNfItem[nItem][IT_LIVRO][LF_IPIOBS]   := aNfItem[nItem][IT_VIPIBICM]
		ElseIf aNfItem[nItem][IT_VIPIBICM]>0 .And. SubStr(cIPInaObs,2,1)=="S" .And. aNFItem[nItem][IT_TS][TS_IPIOBS] $ " 1"  
			//Quando o IPI estiver na base do ICMS e IPI Tributado e a Nota for de Importação preencher o valor do IPI na Observ. Dserfis1-18186
			aNfItem[nItem][IT_LIVRO][LF_IPIOBS]   := aNfItem[nItem][IT_VALIPI]
		Else
			aNfItem[nItem][IT_LIVRO][LF_IPIOBS]   := 0
		EndIf
		//Livro de ICMS-ST		
		IF (aNFItem[nItem][IT_TS][TS_LFICMST]$'IOT') .And. !lICSTTribGen .And. !lICMTribGen			
			//Valor da Coluna Isentas e Nao Tributadas
			If aNFItem[nItem][IT_TS][TS_LFICMST] =="I"
				aNfItem[nItem][IT_LIVRO][LF_ISENICM] += aNfItem[nItem][IT_VALSOL]
				aNfItem[nItem][IT_LIVRO][LF_ISENRET] += aNfItem[nItem][IT_VALSOL]
			EndIf
			//Valor da Coluna Outras
			If aNFItem[nItem][IT_TS][TS_LFICMST]=="O"
				aNfItem[nItem][IT_LIVRO][LF_OUTRICM] += aNfItem[nItem][IT_VALSOL]
				aNfItem[nItem][IT_LIVRO][LF_OUTRRET] += aNfItem[nItem][IT_VALSOL]
			EndIf
			//Valor da Coluna Tributadas
			If aNFItem[nItem][IT_TS][TS_LFICMST]=="T"
				aNfItem[nItem][IT_LIVRO][LF_BASEICM] += aNfItem[nItem][IT_BASESOL]
				//O credito deverah ser o valor integral, ou seja, o ICMS/ST + CRED PRES ST, pois quando houver valor neste campo vai se referir a 20% do valor retido que foi subtraido
				aNfItem[nItem][IT_LIVRO][LF_VALICM]  += aNfItem[nItem][IT_VALSOL]+aNfItem[nItem][IT_LIVRO][LF_CRPRST]
				aNfItem[nItem][IT_LIVRO][LF_ALIQICMS]:= aNfItem[nItem][IT_ALIQICM]
				//O credito deverah ser o valor integral, ou seja, o ICMS/ST + CRED PRES ST, pois quando houver valor neste campo vai se referir a 20% do valor retido que foi subtraido
				aNfItem[nItem][IT_LIVRO][LF_TRIBRET] += aNfItem[nItem][IT_VALSOL]+aNfItem[nItem][IT_LIVRO][LF_CRPRST]
			EndIf			
		EndIf		

		//  CREDITO PRESUMIDO PELA CARGA TRIBUTÁRIA
		//  Exemplo: DECRETO N. 42.649 DE 05 DE OUTUBRO DE 2010  /RJ		
		FISXCRDPRE(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, nBICMOri,"3", cAliasPROD)
		
		//Livro de IPI
		If !aNFItem[nItem][IT_TS][TS_LFIPI]$"NZ" .And. aNFItem[nItem][IT_TS][TS_ISS]<>"S" .And. aNfItem[nItem][IT_TIPONF] <> "I"
			If nReduzIPI == 0 .And. aNFItem[nItem][IT_TS][TS_IPI] <> "R"
				Do Case
					Case aNFItem[nItem][IT_TS][TS_LFIPI] == "T"
						aNfItem[nItem][IT_LIVRO][LF_BASEIPI] := aNfItem[nItem][IT_BASEIPI]
						aNfItem[nItem][IT_LIVRO][LF_VALIPI]  := aNfItem[nItem][IT_VALIPI]
					Case aNFItem[nItem][IT_TS][TS_LFIPI] == "I"
						aNfItem[nItem][IT_LIVRO][LF_ISENIPI] := nBIPIOri
					Case aNFItem[nItem][IT_TS][TS_LFIPI] == "O"
						If aNFItem[nItem][IT_TS][TS_CONSUMO]$"S" .And. aNfItem[nItem][IT_TIPONF]$"N" .And. aNfCab[NF_UFORIGEM] == "EX"
							aNfItem[nItem][IT_LIVRO][LF_OUTRIPI] := (aNfItem[nItem][IT_LIVRO][LF_VALCONT] - aNfItem[nItem][IT_VALIPI])
						ElseIf aNFItem[nItem][IT_TS][TS_AGREG]$"B" .And. aNfItem[nItem][IT_TIPONF]$"N"
							aNfItem[nItem][IT_LIVRO][LF_OUTRIPI] := aNfItem[nItem][IT_BASEIPI]
						Else
							aNfItem[nItem][IT_LIVRO][LF_OUTRIPI] := (aNfItem[nItem][IT_BASEIPI])+Max(nBIPIOri-aNfItem[nItem][IT_BASEIPI],0)
						ENdIf
					Case aNFItem[nItem][IT_TS][TS_LFIPI] == "P"
						aNfItem[nItem][IT_LIVRO][LF_OUTRICM] := aNfItem[nItem][IT_VALIPI]
				EndCase
			Else
				If !lConsumo
					If aNFItem[nItem][IT_TS][TS_CONSUMO] == "O"
						If aNFItem[nItem][IT_TS][TS_LFIPI] == "I"
							aNfItem[nItem][IT_LIVRO][LF_ISENIPI] := (aNfItem[nItem][IT_BASEIPI])+(nBIPIOri-aNfItem[nItem][IT_BASEIPI])
						Else
							aNfItem[nItem][IT_LIVRO][LF_OUTRIPI] := (aNfItem[nItem][IT_BASEIPI])+Max(nBIPIOri-aNfItem[nItem][IT_BASEIPI],0)
						EndIf
					Else
						aNfItem[nItem][IT_LIVRO][LF_BASEIPI] := aNfItem[nItem][IT_BASEIPI]
						aNfItem[nItem][IT_LIVRO][LF_VALIPI]  := aNfItem[nItem][IT_VALIPI]
						aNfItem[nItem][IT_LIVRO][IIf(aNFItem[nItem][IT_TS][TS_LFIPI]=="I",LF_ISENIPI,LF_OUTRIPI)] := nBIPIOri-aNfItem[nItem][IT_BASEIPI]
					Endif
				Else
					If aNFItem[nItem][IT_TS][TS_LFIPI]=="I"
						aNfItem[nItem][IT_LIVRO][LF_ISENIPI] := aNfItem[nItem][IT_BASEIPI]
						aNfItem[nItem][IT_LIVRO][LF_OUTRIPI] := nBIPIOri-aNfItem[nItem][IT_BASEIPI]
					Else
						aNfItem[nItem][IT_LIVRO][LF_ISENIPI] := nBIPIOri-aNfItem[nItem][IT_BASEIPI]
						aNfItem[nItem][IT_LIVRO][LF_OUTRIPI] := aNfItem[nItem][IT_BASEIPI]
					EndIf
				EndIf
			EndIf
		ElseIf aNFItem[nItem][IT_TS][TS_LFIPI] == "N" .And. aNFItem[nItem][IT_TS][TS_ISS] <> "S" .And. SubStr(cIPInaObs,1,1)=="S" .And. aNFItem[nItem][IT_TS][TS_IPI] <> 'R' .And. aNFItem[nItem][IT_TS][TS_IPIOBS] $ " 1"
			aNfItem[nItem][IT_LIVRO][LF_IPIOBS]	:= aNfItem[nItem][IT_VALIPI]
		EndIf

		//Para entradas irá verificar se considera o valor de frete e despesas acessórias na coluna outros do IPI.
		IF aNFCab[NF_OPERNF] == "E"
			IF aNFItem[nItem][IT_TS][TS_DESPIPI] == "O"
				aNfItem[nItem][IT_LIVRO][LF_OUTRIPI]+=aNfItem[nItem][IT_DESPESA]+aNfItem[nItem][IT_SEGURO]
			EndIF

			IF aNFItem[nItem][IT_TS][TS_IPIFRET] == "O"
				aNfItem[nItem][IT_LIVRO][LF_OUTRIPI]+=aNfItem[nItem][IT_FRETE]
			EndIF
		EndIF
		// IPI Aliquota
		If aNfItem[nItem][IT_LIVRO][LF_BASEIPI]==0
			aNfItem[nItem][IT_LIVRO][LF_ALIQIPI] := 0
		Else
			aNfItem[nItem][IT_LIVRO][LF_ALIQIPI] := aNfItem[nItem][IT_ALIQIPI]
		EndIf
		//Quando o IPI possuir uma parte nao tributada, preencher o IPI na Observ.
		If !lConsFinal .Or. (lConsFinal .And. aNFCab[NF_OPERNF]=='E')
			If nBIPIOri<>aNfItem[nItem][IT_LIVRO][LF_BASEIPI] .And. aNfItem[nItem][IT_LIVRO][LF_VALIPI]<>0
				If SubStr(cIPInaObs,1,1)=="S" .And. aNFItem[nItem][IT_TS][TS_IPI] <> 'R' .And. aNFItem[nItem][IT_TS][TS_IPIOBS] $ " 1"
					aNfItem[nItem][IT_LIVRO][LF_IPIOBS]   += NoRound((nBIPIOri-aNfItem[nItem][IT_LIVRO][LF_BASEIPI])*aNfItem[nItem][IT_LIVRO][LF_VALIPI]/aNfItem[nItem][IT_LIVRO][LF_BASEIPI],2)
				Endif
			Else
				If aNFItem[nItem][IT_TS][TS_LFIPI]$"IO" .And. aNfItem[nItem][IT_LIVRO][LF_VALIPI]==0
					If SubStr(cIPInaObs,1,1)=="S" .And. aNFItem[nItem][IT_TS][TS_IPI] <> 'R' .And. aNFItem[nItem][IT_TS][TS_IPIOBS] $ " 1"
						aNfItem[nItem][IT_LIVRO][LF_IPIOBS]   := aNfItem[nItem][IT_VALIPI]
					Endif
				EndIf
			EndIf
		EndIf
		// Zera a coluna Obs IPI caso esteja menor que zero
		aNfItem[nItem][IT_LIVRO][LF_IPIOBS] := Max(aNfItem[nItem][IT_LIVRO][LF_IPIOBS],0)
		//Livro de ISS
		If aNFItem[nItem][IT_TS][TS_ISS] == "S"
			Do Case
				Case aNFItem[nItem][IT_TS][TS_LFISS] == "T"
					aNfItem[nItem][IT_LIVRO][LF_BASEICM] := IIF(aNfCab[NF_TIPONF]=="I",0,aNfItem[nItem][IT_BASEISS])
					aNfItem[nItem][IT_LIVRO][LF_VALICM]  := IIF(aNfCab[NF_TIPONF]=="I",aNfItem[nItem][IT_BASEISS],aNfItem[nItem][IT_VALISS])
				Case aNFItem[nItem][IT_TS][TS_LFISS] == "I"
					aNfItem[nItem][IT_LIVRO][LF_ISENICM] := aNfItem[nItem][IT_BASEISS]
				Case aNFItem[nItem][IT_TS][TS_LFISS] == "O"
					aNfItem[nItem][IT_LIVRO][LF_OUTRICM] := aNfItem[nItem][IT_BASEISS]
			EndCase
			aNfItem[nItem][IT_LIVRO][LF_TIPO] := "S"
			aNfItem[nItem][IT_LIVRO][LF_CODISS] := aNfItem[nItem][IT_CODISS]
			aNfItem[nItem][IT_LIVRO][LF_CNAE]   := aNfItem[nItem][IT_CNAE]
			aNfItem[nItem][IT_LIVRO][LF_TRIBMU]	:= aNfItem[nItem][IT_TRIBMU]
			// ISS Aliquota
			If aNfItem[nItem][IT_LIVRO][LF_BASEICM]==0 .And. (aNfItem[nItem,IT_ABVLISS]==aNfItem[nItem][IT_LIVRO][LF_VALCONT] .Or. aNfItem[nItem,IT_ABMATISS]==aNfItem[nItem][IT_LIVRO][LF_VALCONT] .Or. ;
			   aNfItem[nItem][IT_TS][TS_DESCOND] == "1" .And. aNfItem[nItem][IT_LIVRO][LF_VALCONT] < aNfItem[nItem][IT_ABVLISS] )
				aNfItem[nItem][IT_LIVRO][LF_ALIQICMS] := aNfItem[nItem][IT_ALIQISS]
			elseif aNfItem[nItem][IT_LIVRO][LF_BASEICM]==0
				aNfItem[nItem][IT_LIVRO][LF_ALIQICMS] := 0
			Else
				aNfItem[nItem][IT_LIVRO][LF_ALIQICMS] := aNfItem[nItem][IT_ALIQISS]
			EndIf
			// Livro de ICMS - Ajuste SINEF 03/04 - DOU 08.04.04
			aNfItem[nItem][IT_LIVRO][LF_ISS_ALIQICMS] := 0
			Do Case
				Case aNFItem[nItem][IT_TS][TS_LFICM] == "I"
					aNfItem[nItem][IT_LIVRO][LF_ISS_ISENICM] := aNfItem[nItem][IT_LIVRO][LF_VALCONT]
				Case aNFItem[nItem][IT_TS][TS_LFICM] == "O"
					aNfItem[nItem][IT_LIVRO][LF_ISS_OUTRICM] := aNfItem[nItem][IT_LIVRO][LF_VALCONT]
			EndCase
			Do Case
				Case aNFItem[nItem][IT_TS][TS_LFIPI] == "I"
					aNfItem[nItem][IT_LIVRO][LF_ISS_ISENIPI] := aNfItem[nItem][IT_LIVRO][LF_VALCONT]
				Case aNFItem[nItem][IT_TS][TS_LFIPI] == "O"
					aNfItem[nItem][IT_LIVRO][LF_ISS_OUTRIPI] := aNfItem[nItem][IT_LIVRO][LF_VALCONT]
			EndCase

		ElseIf ( (aNFItem[nItem][IT_TS][TS_LFISS] == "I" .Or. aNFItem[nItem][IT_TS][TS_LFISS] == "O") .And. ( !Empty( aNfItem[nItem][IT_PRD][SB_CODISS] ) .Or. !Empty( aNfItem[nItem][IT_CODISS] ) ) )
			// Caso o livro de ISS esteja como isento, e exista o Codigo de ISS
			// O F3_TIPO deve ser S, mesmo que a TES esteja como calcula ISS = N
			aNfItem[nItem][IT_CFPS]				:= aNFItem[nItem][IT_TS][TS_CFPS]
			aNfItem[nItem][IT_CODISS]			:= IIf( !Empty( aNfItem[nItem][IT_CODISS]), aNfItem[nItem][IT_CODISS], aNfItem[nItem][IT_PRD][SB_CODISS] )
			aNfItem[nItem][IT_LIVRO][LF_TIPO] 	:= "S"
			aNfItem[nItem][IT_LIVRO][LF_CODISS] := aNfItem[nItem][IT_CODISS]
			aNfItem[nItem][IT_LIVRO][LF_CNAE]   := aNfItem[nItem][IT_CNAE]
			aNfItem[nItem][IT_LIVRO][LF_TRIBMU]	:= aNfItem[nItem][IT_TRIBMU]

			nBseISS := aNfItem[nItem][IT_VALMERC] - IIf( aNFItem[nItem][IT_TS][TS_DESCOND] == "2" , aNfItem[nItem][IT_DESCONTO] , 0 )
			nBseISS := IIf( aNFItem[nItem][IT_TS][TS_BASEISS] > 0 , ( nBseISS * aNFItem[nItem][IT_TS][TS_BASEISS] ) / 100 , nBseISS )
			nBseISS := Iif( aNfItem[nItem,IT_REDISS] > 0 , ( nBseISS * aNfItem[nItem,IT_REDISS] ) / 100 , nBseISS )
			nBseISS -= aNfItem[nItem,IT_ABVLISS]
			nBseISS -= aNfItem[nItem,IT_ABMATISS]

			Do Case
				Case aNFItem[nItem][IT_TS][TS_LFISS] == "I"
					aNfItem[nItem][IT_LIVRO][LF_ISENICM] := nBseISS
				Case aNFItem[nItem][IT_TS][TS_LFISS] == "O"
					aNfItem[nItem][IT_LIVRO][LF_OUTRICM] := nBseISS
			EndCase

		EndIf

		IF aPos[FP_FT_CSOSN]
			aNfItem[nItem][IT_CSOSN] := aNFItem[nItem][IT_TS][TS_CSOSN]
		EndIf

	Endif

	// Grava os Valores de Despesas
	aNfItem[nItem][IT_LIVRO][LF_DESPESA] := aNfItem[nItem][IT_DESPESA]+aNfItem[nItem][IT_FRETE]+aNfItem[nItem][IT_SEGURO]

	// Grava os Valores de AFRMM Importação
	aNfItem[nItem][IT_LIVRO][LF_AFRMIMP] := aNfItem[nItem][IT_AFRMIMP]

	//SIMPLES SC
	//Sera gravado o valor do ICMS calculado na nota fiscal.
	//Contribuintes do SIMPLES/SC devem destacar o ICMS nos documentos fiscais com
	//destino a optantes do SIMPLES, mas o valor do ICMS nao deve ser apresentado na apuracao.

	If SubStr(aNfItem[nItem][IT_LIVRO][LF_CFO],1,1) $ "56" .And. aNfItem[nItem][IT_LIVRO][LF_TIPO] <> "S"
		If aPos[FP_A1_SIMPLES] .And. aPos[FP_F3_SIMPLES]
			If aNfCab[NF_SIMPSC] <> "1" .And. cMvEstado=="SC" .And. aSX6[MV_SIMPLSC]
				aNfItem[nItem][IT_LIVRO][LF_SIMPLES] := aNfItem[nItem][IT_LIVRO][LF_VALICM]
			Endif
		Endif
	Endif

	aNfItem[nItem][IT_LIVRO][LF_ESTCRED] := aNfItem[nItem][IT_ESTCRED]
	aNfItem[nItem][IT_LIVRO][LF_VALCMAJ] := aNfItem[nItem][IT_VALCMAJ]
	aNfItem[nItem][IT_LIVRO][LF_ALQCMAJ] := aNFItem[nItem][IT_TS][TS_ALQCMAJ]
	aNfItem[nItem][IT_LIVRO][LF_VALPMAJ] := aNfItem[nItem][IT_VALPMAJ]
	aNfItem[nItem][IT_LIVRO][LF_ALQPMAJ] := aNFItem[nItem][IT_TS][TS_ALQPMAJ]

	// Preço Médio Ponderado, para ser utilizado como base de ICMS ST
	aNfItem[nItem][IT_LIVRO][LF_PRCMEDP] := aNfItem[nItem][IT_PRCMEDP]

	aNfItem[nItem][IT_LIVRO][LF_CLIDEST] := aNFCab[NF_CLIDEST]
	aNfItem[nItem][IT_LIVRO][LF_LOJDEST] := aNFCab[NF_LOJDEST]

	aNfItem[nItem][IT_LIVRO][LF_BFCPANT] := aNfItem[nItem][IT_BFCPANT]
	aNfItem[nItem][IT_LIVRO][LF_AFCPANT] := aNfItem[nItem][IT_AFCPANT]
	aNfItem[nItem][IT_LIVRO][LF_VFCPANT] := aNfItem[nItem][IT_VFCPANT]
	aNfItem[nItem][IT_LIVRO][LF_ALQNDES] := aNfItem[nItem][IT_ALQNDES]
	aNfItem[nItem][IT_LIVRO][LF_ALFCCMP] := aNfItem[nItem][IT_ALFCCMP]
	aNfItem[nItem][IT_LIVRO][LF_BASFECP] := aNfItem[nItem][IT_BASFECP]
	aNfItem[nItem][IT_LIVRO][LF_BSFCPST] := aNfItem[nItem][IT_BSFCPST]
	aNfItem[nItem][IT_LIVRO][LF_BSFCCMP] := aNfItem[nItem][IT_BSFCCMP]
	aNfItem[nItem][IT_LIVRO][LF_FCPAUX]  := aNfItem[nItem][IT_FCPAUX]
	aNfItem[nItem][IT_LIVRO][LF_VLINCMG]  := aNfItem[nItem][IT_VLINCMG]

	// Desconto Fiscal de Tributos
	aNfItem[nItem][IT_LIVRO][LF_DESCFIS] := aNfItem[nItem][IT_DESCFIS]

EndIf

//Grava Campo dos livros conforme configurador.
If lICMTribGen .OR. lIPITribGen .Or. lICSTTribGen

	If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_IPI})) > 0 		
		aNfItem[nItem][IT_LIVRO][LF_ISENIPI] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_LF][TG_LF_ISENTO]		
		aNfItem[nItem][IT_LIVRO][LF_OUTRIPI] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_LF][TG_LF_OUTROS]		
	EndIf

	If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_ICMS})) > 0
		aNfItem[nItem][IT_LIVRO][LF_ISENICM] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_LF][TG_LF_ISENTO]		
		aNfItem[nItem][IT_LIVRO][LF_OUTRICM] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_LF][TG_LF_OUTROS]
	EndIf

	If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_ICMSST})) > 0
		If aNFItem[nItem][IT_TS][TS_LFICMST] =="I"
			aNfItem[nItem][IT_LIVRO][LF_ISENRET] += aNfItem[nItem][IT_VALSOL]
			aNfItem[nItem][IT_LIVRO][LF_ISENICM] += aNfItem[nItem][IT_VALSOL]
		Elseif aNFItem[nItem][IT_TS][TS_LFICMST]=="O"
			aNfItem[nItem][IT_LIVRO][LF_OUTRRET] += aNfItem[nItem][IT_VALSOL]
			aNfItem[nItem][IT_LIVRO][LF_OUTRICM] += aNfItem[nItem][IT_VALSOL]
		Elseif aNFItem[nItem][IT_TS][TS_LFICMST]=="T"
			aNfItem[nItem][IT_LIVRO][LF_TRIBRET] += aNfItem[nItem][IT_VALSOL]
		Endif
	Endif
	
EndIf
//P.E. para gravacao dos campos por item - 18/01/10
If aPE[PE_XFISLF]
	ExecBlock( "XFISLF", .F., .F.,{nItem})
EndIf

//Verifica se o TES possui RdMake para geracao/complemento dos Livros Fiscais
If !Empty(aNFItem[nItem][IT_TS][TS_LIVRO]) .And. cPaisLoc == "BRA"
	aNfItem[nItem][IT_LIVRO] := ExecBlock(aNFItem[nItem][IT_TS][TS_LIVRO],.F.,.F.,{aNfItem[nItem][IT_LIVRO],nItem})
EndIf

//PE para manipulação dos valores dos itens (em uso na importação TSF)
If aPE[PE_MXTOTIT]
	ExecBlock("MXTOTIT",.F.,.F.,{nItem})
EndIf

//Atualiza as referencias do IT_SPED para o Item
If cPaisLoc == "BRA"

	aNfItem[nItem][IT_SPED]	:= {}

	If ( aNFItem[nItem][IT_TS][TS_ICM] == "N" .And. aNFItem[nItem][IT_TS][TS_LFICM]$'IO' .And. aNfItem[nItem][IT_VALICM] == 0 .And. aNfItem[nItem][IT_BASEICM] == 0 )
		lLvrICM := .T.
	EndIf

	If ( aNFItem[nItem][IT_TS][TS_ICM] == "N" .And. aNFItem[nItem][IT_TS][TS_LFICMST]$'IO' .And. aNfItem[nItem][IT_VALSOL] == 0 .And. aNfItem[nItem][IT_BASESOL] == 0 )
		lLvrSol := .T.
	Elseif ( aNFItem[nItem][IT_TS][TS_ICM] == "N" .And. aNFItem[nItem][IT_TS][TS_LFICM]$'Z' .And. aNfItem[nItem][IT_VALSOL] > 0 .And. aNfItem[nItem][IT_BASESOL] > 0 .And. aNFItem[nItem][IT_TS][TS_OBSSOL]=="5")
		lLvrSol := .T.
	Elseif ( aNFItem[nItem][IT_TS][TS_ICM] == "S"  .And. aNFItem[nItem][IT_TS][TS_LFICM]$'IO' .And. aNfItem[nItem][IT_TS][TS_BASEICM] == 100 )
		lLvrICM := .T.
	EndIf

	//Verifica o ICMS
	If aNfItem[nItem][IT_VALICM] > 0 .Or. aNfItem[nItem][IT_BASEICM] > 0 .Or. lLvrICM

		aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
		nImp++
		aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
		aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
		aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "ICM"
		aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := substr(aNfItem[nItem][IT_CLASFIS],1,1)
		aNfItem[nItem][IT_SPED][nImp][SP_CST]    := substr(aNfItem[nItem][IT_CLASFIS],2,2)
		aNfItem[nItem][IT_SPED][nImp][SP_FCPAJT] := aNfItem[nItem][IT_UFXPROD][UFP_FCPAJT]

		// Percentual de reducao de base - se a nota vier do SIGAEIC, pegar o % da TES.
		// A base ja vem reduzida mas sem o percentual, pois nao tem este dado no item.
		aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := IIf(aNFItem[nItem][IT_TS][TS_AGREG] $ "B|C", aNFItem[nItem][IT_TS][TS_BASEICM], IIF(aNfItem[nItem][IT_BASEICM]> 0 .Or. aNfCab[NF_TIPONF]=="I" , aNfItem[nItem][IT_PREDIC],0))

		//Alteração na base de cálculo e valor do ICMS, quando existe diferimento parcial onde a parcela diferida está em Isento ou em outros, a base de cálculo é reduzida, porém somente para
		//a transmissão da nota fiscal,  a base de cálculo e valor precisam ser demonstrada de forma integral. A princípio isso é conflitante, porém é necessário fazer, cliente possui documentado esta orientação da própria SEFAZ RS.
		//Mais detalhes no documento feito pela consultoria de segmentos http://tdn.totvs.com/display/ConSeg/ICMS+-+Diferimento+-+RS
		aNfItem[nItem][IT_SPED][nImp][SP_BC]     := Iif(aNfItem[nItem][IT_COLVDIF] $ '1/2' , nBICMOri ,aNfItem[nItem][IT_BASEICM])
		aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQICM]
		aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := Iif(aNfItem[nItem][IT_COLVDIF] $ '1/2' ,aNfItem[nItem][IT_VOPDIF] , aNfItem[nItem][IT_VALICM] )
		If aNfItem[nItem][IT_PAUTIC] > 0
			aNfItem[nItem][IT_SPED][nImp][SP_QTRIB] := aNfItem[nItem][IT_QUANT]*IIF(!Empty(aSX6[MV_ICMPFAT]) , aNfItem[nItem][IT_PRD][SB_ICMPFAT] , 1 )
			aNfItem[nItem][IT_SPED][nImp][SP_PAUTA] := aNfItem[nItem][IT_PAUTIC]
			If aNfItem[nItem][IT_SPED][nImp][SP_PAUTA] > 0 .And. aNFItem[nItem][IT_TS][TS_PAUTICM]=="2"
				aNfItem[nItem][IT_SPED][nImp][SP_MODBC] := "1"
			Else
				aNfItem[nItem][IT_SPED][nImp][SP_MODBC] := "2"
			EndIf
		Else
			aNfItem[nItem][IT_SPED][nImp][SP_MODBC] := "3"
		EndIf
		aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PARTICM] := IIF(!Empty(aNFItem[nItem][IT_TS][TS_PARTICM]), aNFItem[nItem][IT_TS][TS_PARTICM], "1")
		aNfItem[nItem][IT_SPED][nImp][SP_GRPCST] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_CEST] := aNfItem[nItem][IT_CEST]
		aNfItem[nItem][IT_SPED][nImp][SP_PICMDIF] := aNfItem[nItem][IT_TS][TS_PICMDIF]
		If !Empty(aNfItem[nItem][IT_LIVRO][LF_MOTICMS])
			If aNFItem[nItem][IT_TS][TS_AGREG]$"D/R/E" .And. aNfItem[nItem][IT_DEDICM] > 0 .And. aNfCab[NF_OPIRRF] $ "EP/OS" // tratamento para dedução de ICMS em operação para órgão público.
				aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := aNfItem[nItem][IT_DEDICM]
			ElseIf aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] > 0 .And. !cMvEstado $ aSX6[MV_DESONRJ]
				//Valor do ICMS DESONERADO para Nfe - Consultoria Tributaria http://tdn.totvs.com/pages/releaseview.action?pageId=185737442
				nAliqDed :=	aNfItem[nItem][IT_ALIQICM]

				If aNfItem[nItem][IT_BICMORI] > 0
					nValIcOri := aNfItem[nItem][IT_BICMORI]
					If aNFItem[nItem][IT_TS][TS_DESPRDIC] == "2"
						nValIcOri -=  aNfItem[nItem][IT_FRETE]
						If !(aNFItem[nItem][IT_TS][TS_DESPICM] $ "23")
							nValIcOri -=  (aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO] + aNfItem[nItem][IT_AFRMIMP])
						Endif
					Endif
				Else
					nValIcOri := (aNfItem[nItem][IT_BASEICM] * 100) / aNfItem[nItem][IT_SPED][nImp][SP_PREDBC]
				Endif	

				aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := Round( nValIcOri * (nAliqDed/100) * (1-(aNfItem[nItem][IT_SPED][nImp][SP_PREDBC]/100)),2)			
				
			Else
				If aNfItem[nItem][IT_ALIQICM] > 0
					nAliqICMDe := aNfItem[nItem][IT_ALIQICM]
				Else
					MaFisSave()
					aNFItem[nItem][IT_TS][TS_ICM] := "S"
					aNFItem[nItem][IT_RECORI]     := ""
					MaAliqIcms(nItem)
					nAliqICMDe := aNfItem[nItem][IT_ALIQICM]
					MaFisRestore()
				EndIf
				If aNFItem[nItem][IT_TS][TS_AGREG] == "D" .And. aNfItem[nItem][IT_DEDICM] > 0 .And. aNfItem[nItem][IT_ALIQICM] > 0
					aNfItem[nItem][IT_SPED][nImp][SP_DESONE]:= Round(( aNfItem[nItem][IT_LIVRO][LF_BSICMOR] * nAliqICMDe)/100,2)
				Else
					aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := Round(((aNfItem[nItem][IT_LIVRO][LF_ISENICM] + aNfItem[nItem][IT_LIVRO][LF_OUTRICM]) * nAliqICMDe)/100,2)
				EndIf
			Endif
		EndIf

		//Tratamento para o campo CD2_DESONE em casos de devoluções que controlam poder de terceiros com redução de base de cálculo.
		If !Empty(aNfItem[nItem][IT_LIVRO][LF_MOTICMS]) .And. aNFCab[NF_TIPONF] $ "DB" .And. !Empty(aNfItem[nItem][IT_LIVRO][LF_ITEMORI]) .And. aNFItem[nItem][IT_TS][TS_AGREG]$"D/R/E" .And.   aNfItem[nItem][IT_DEDICM] > 0
			aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := aNfItem[nItem][IT_DEDICM]
		EndIf

		aNfItem[nItem][IT_SPED][nImp][SP_BFCP] := aNfItem[nItem][IT_BASFECP]
		aNfItem[nItem][IT_SPED][nImp][SP_PFCP] := IIF(aNfItem[nItem][IT_BASFECP] > 0, IIF(aNfItem[nItem][IT_FCPAUX] > 0, aNfItem[nItem][IT_FCPAUX], aNfItem[nItem][IT_ALIQFECP]), 0)

		// Tratamento quando item calcula FECP e é inferior a 0,01. Subtrair o percentual de FECP do percentual de ICMS por não ter valor o suficiente de FECP.
		If Round(aNfItem[nItem][IT_VALFECP],2) < 0.01
			aNfItem[nItem][IT_SPED][nImp][SP_ALIQ] := aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]-aNfItem[nItem][IT_SPED][nImp][SP_PFCP]
		EndIf

		//Quando existir Codigo declalarotio  preencher conforme calculado
		If cMvEstado $ aSX6[MV_DESONRJ]
			If aNfItem[nItem][IT_ICMSDIF] > 0 .And. aNFItem[nItem][IT_TS][TS_ICMSDIF] =='7' .And. !aNFItem[nItem][IT_TS][TS_PICMDIF] == 100
				aNfItem[nItem][IT_SPED][nImp][SP_BC] := aNfItem[nItem][IT_SPED][nImp][SP_BFCP] := aNfItem[nItem][IT_BASEICM] + aNfItem[nItem][IT_VOPDIF]
				aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := aNfItem[nItem][IT_ICMSDIF]
			ElseIf aNfItem[nItem][IT_ICMSDIF] > 0 .And. aNFItem[nItem][IT_TS][TS_ICMSDIF] =='7' .And. aNFItem[nItem][IT_TS][TS_PICMDIF] == 100
				aNfItem[nItem][IT_SPED][nImp][SP_BC] := aNfItem[nItem][IT_SPED][nImp][SP_BFCP] := aNfItem[nItem][IT_BASEICM] / (1-((aNfItem[nItem][IT_ALIQICM]+aNfItem[nItem][IT_ALIQFECP])/100))
				aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := aNfItem[nItem][IT_ICMSDIF]
			Elseif !Empty(aNfItem[nItem][IT_LIVRO][LF_MOTICMS])
				If aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] > 0
					nBICMCheia := Iif(aNfItem[nItem][IT_BICMORI] > 0, aNfItem[nItem][IT_BICMORI], (aNfItem[nItem][IT_BASEICM] * 100) / aNfItem[nItem][IT_SPED][nImp][SP_PREDBC])
					If aNfCab[NF_PPDIFAL] .And. aNFCab[NF_LINSCR] .And. aNfItem[nItem][IT_TS][TS_DEDDIF] $ " 1"
						nAliqDed := aNfItem[nItem][IT_ALIQCMP] + aNfItem[nItem][IT_ALFCCMP]
					Else
						nAliqDed :=	aNfItem[nItem][IT_ALIQICM]
					EndIf
					aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := aNfItem[nItem][IT_ICMDESONE] := Round( nBICMCheia * (1 - ( (nAliqDed/100) * (1 -  (1 - (aNfItem[nItem][IT_SPED][nImp][SP_PREDBC]/100))  ))) / (1 -  (nAliqDed/100) ) - nBICMCheia ,2)
				Else
					aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := aNfItem[nItem][IT_ICMDESONE] := Round( ((aNfItem[ nItem,IT_LIVRO,LF_ISENICM]+aNfItem[nItem,IT_LIVRO,LF_OUTRICM]) / (1-(aNfItem[nItem][IT_ALIQICM] / 100))) * (aNfItem[nItem][IT_ALIQICM]/100)  ,2)
				EndIf
			Endif
		EndIf

		// Validacao p/ evitar gravar o FECP do ICMS Complementar (Entradas) que eh gravado no mesmo campo do ICMS Proprio.
		// Se houver base e aliquota entao sei que eh mesmo o FECP do ICMS Proprio.
		If aNfItem[nItem][IT_SPED][nImp][SP_BFCP] > 0 .And. aNfItem[nItem][IT_SPED][nImp][SP_PFCP] > 0
			If aNFItem[nItem][IT_TS][TS_ICMSDIF] <> '7'
				aNfItem[nItem][IT_SPED][nImp][SP_VFCP] := aNfItem[nItem][IT_VALFECP]
			Else
				aNfItem[nItem][IT_SPED][nImp][SP_VFCP] := aNfItem[nItem][IT_SPED][nImp][SP_BFCP] * (aNfItem[nItem][IT_SPED][nImp][SP_PFCP]/100)
			EndIf
		EndIf

		If  lLvrICM .and. aNfCab[NF_OPERNF]=="S"  .And. aNFCab[NF_CLIFOR]=="C" .And. aNFCab[NF_TPCLIFOR] $ "FL" .and. (substr(aNfItem[nItem][IT_CLASFIS],2,2)=="60".or. aNfItem[nItem][IT_CSOSN]=="500")

			//Verifica se já calculou efeitivo para este item, ou houve alteração no total da nota
			If (aNfItem[nItem][IT_VICEFET] == 0 .or. aNfItem[nItem][IT_TOTAL] <> aNfItem[nItem][IT_TOTEFET])

				//Salva Arrays com calcula  == Não
				MaFisSave()

				//Recalcula ICMS
				aNFItem[nItem][IT_TS][TS_ICM] := "S"
				MaFisRecal(,nItem)

				if aNfItem[nItem][IT_VALICM] > 0 .Or. aNfItem[nItem][IT_BASEICM] > 0
					aReseta	:=	{aNfItem[nItem][IT_SPED][nImp][SP_PREDBC],;
								aNfItem[nItem][IT_SPED][nImp][SP_BC],;
								aNfItem[nItem][IT_SPED][nImp][SP_ALIQ],;
								aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB],;
								aNfItem[nItem][IT_TOTAL]}


					//Restaura arrays com calcula  == Não
					MaFisRestore()

					//Grava CD2
					aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] 	:= aReseta[1]
					aNfItem[nItem][IT_SPED][nImp][SP_BC]		:= aReseta[2]
					aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]		:= aReseta[3]
					aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB]	:= aReseta[4]

					//Caso seja nescessario gerar dados para CDA
					aNfItem[nItem][IT_BICEFET] := aReseta[2]
					aNfItem[nItem][IT_PICEFET] := aReseta[3]
					aNfItem[nItem][IT_VICEFET] := aReseta[4]
					aNfItem[nItem][IT_TOTEFET] := aReseta[5]
				Else
					//Restaura arrays com calcula == Não
					MaFisRestore()
				Endif
			Elseif aNfItem[nItem][IT_VICEFET] > 0 .or. aNfItem[nItem][IT_BICEFET] > 0
				aNfItem[nItem][IT_SPED][nImp][SP_BC]		:= aNfItem[nItem][IT_BICEFET]
				aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]		:= aNfItem[nItem][IT_PICEFET]
				aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB]	:= aNfItem[nItem][IT_VICEFET]
			Endif
		ELSEIF aNfCab[NF_OPERNF]=="S"  .And. aNFCab[NF_CLIFOR]=="C" .And. aNFCab[NF_TPCLIFOR] $ "FL" .And. (aNfItem[nItem][IT_SPED][nImp][SP_CST]=="60" .or. aNfItem[nItem][IT_CSOSN]=="500")
			aNfItem[nItem][IT_BICEFET]  := aNfItem[nItem][IT_SPED][nImp][SP_BC]
			aNfItem[nItem][IT_PICEFET] := aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]
			aNfItem[nItem][IT_VICEFET]  := aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB]
		Endif



	EndIf

	//Verifica o ICMS / ST
	If aNfItem[nItem][IT_VALSOL] > 0 .Or. aNfItem[nItem][IT_BASESOL] > 0 .Or. lLvrSol

		aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
		nImp++
		aNfItem[nItem][IT_SPED][nImp][SP_ITEM]    := aNfItem[nItem][IT_ITEM]
		aNfItem[nItem][IT_SPED][nImp][SP_CODPRO]  := aNfItem[nItem][IT_PRODUTO]
		aNfItem[nItem][IT_SPED][nImp][SP_IMP]     := "SOL"
		aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM]  := substr(aNfItem[nItem][IT_CLASFIS],1,1)
		aNfItem[nItem][IT_SPED][nImp][SP_CST]     := substr(aNfItem[nItem][IT_CLASFIS],2,2)
		aNfItem[nItem][IT_SPED][nImp][SP_PREDBC]  := IIF(aNfItem[nItem][IT_VALSOL] > 0,aNfItem[nItem][IT_PREDST] ,0)
		aNfItem[nItem][IT_SPED][nImp][SP_BC]      := aNfItem[nItem][IT_BASESOL]
		aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]    := aNfItem[nItem][IT_ALIQSOL]
		aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB]  := aNfItem[nItem][IT_VALSOL]
		aNfItem[nItem][IT_SPED][nImp][SP_PARTICM] := IIF(!Empty(aNFItem[nItem][IT_TS][TS_PARTICM]), aNFItem[nItem][IT_TS][TS_PARTICM], "1")
		aNfItem[nItem][IT_SPED][nImp][SP_FCPAJT]  := aNfItem[nItem][IT_UFXPROD][UFP_FCPAJT]
		If aNfItem[nItem][IT_PAUTST] > 0
			aNfItem[nItem][IT_SPED][nImp][SP_QTRIB] := aNfItem[nItem][IT_QUANT]*IIF(!Empty(aSX6[MV_ICMPFAT]) , aNfItem[nItem][IT_PRD][SB_ICMPFAT] , 1 )
			aNfItem[nItem][IT_SPED][nImp][SP_PAUTA] := aNfItem[nItem][IT_PAUTST]
			If aNfItem[nItem][IT_SPED][nImp][SP_PAUTA] > 0
				aNfItem[nItem][IT_SPED][nImp][SP_MODBC] := "5"
			Else
				aNfItem[nItem][IT_SPED][nImp][SP_MODBC] := "0"
			EndIf
		Else
			If aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. (aNFCab[NF_UFORIGEM] == "MT" .Or. aNFCab[NF_UFDEST] == "MT") .And.;
			   (aNfCab[NF_OPERNF]=="E" .Or. (aNfCab[NF_OPERNF]=="S" .And. !aNFCab[NF_TIPONF]$"DB"))
				If aNfCab[NF_OPERNF]=="S"
					aNfItem[nItem][IT_SPED][nImp][SP_MVA] := Iif(aNfCab[NF_REGESIM] <> "1" .Or. aNfItem[nItem][IT_PRD][SB_REGESIM] <> "1", Iif(aNFItem[nItem][IT_TS][TS_MKPSOL] <> "1", aNfItem[nItem][IT_MARGEM], 0), Iif( aNFItem[nItem][IT_TS][TS_PERCATM]   > 0 , aNFItem[nItem][IT_TS][TS_PERCATM]   , IIf( aNFCab[NF_PERCATM] > 0 , aNFCab[NF_PERCATM] , aSX6[MV_PERCATM] )))
				ElseIf aNfCab[NF_OPERNF]=="E"
					aNfItem[nItem][IT_SPED][nImp][SP_MVA] := Iif(aNfCab[NF_REGESIM] <> "1" .Or. aNfItem[nItem][IT_PRD][SB_REGESIM] <> "1", Iif(aNFItem[nItem][IT_TS][TS_MKPSOL] <> "1", aNfItem[nItem][IT_MARGEM], 0), Iif( aNFItem[nItem][IT_TS][TS_PERCATM]   > 0 , aNFItem[nItem][IT_TS][TS_PERCATM]   , IIf( aSX6[MV_PERCATM] > 0, aSX6[MV_PERCATM],  aNFCab[NF_PERCATM] )))
				EndIf
			Else
				aNfItem[nItem][IT_SPED][nImp][SP_MVA] := IIf(aNFItem[nItem][IT_TS][TS_MKPSOL] <> "1" .OR. aNFItem[nItem][IT_TS][TS_APLIIVA] == "1", aNfItem[nItem][IT_MARGEM] , 0 )
			EndIf
			If aNFCab[NF_UFDEST] <> aNFCab[NF_UFORIGEM] .And. (aNfCab[NF_OPERNF] == "S" .Or. aNFCab[NF_TIPONF]$"DB") .And. aNfItem[nItem][IT_TS][TS_MKPCMP] == '2' .And.;
			   aNfItem[nItem][IT_TS][TS_MKPSOL] == '1' .And. aNfItem[nItem][IT_TS][TS_INCSOL] == 'S'
				aNfItem[nItem][IT_SPED][nImp][SP_MODBC] := "6"
				aNfItem[nItem][IT_SPED][nImp][SP_MVA]   := 0
			ElseIf aNfItem[nItem][IT_SPED][nImp][SP_PARTICM] == "2"
				aNfItem[nItem][IT_SPED][nImp][SP_MODBC] := "5"
				aNfItem[nItem][IT_SPED][nImp][SP_MVA]   := 0
			//Especifico para atendimento da legislação; Convênio ICMS 77/2011 e aos artigos 30 e 30-A do Anexo VIII do RCTE/GO -- DSERFISE-4396 	
			ElseIf aNFCab[NF_UFORIGEM] == "GO" .And. aNFCab[NF_UFDEST] == "GO" .And. aNFItem[nItem][IT_TS][TS_SITTRIB] $ "10,30" .And.;
			   (aNfCab[NF_OPERNF]=="E" .Or. (aNfCab[NF_OPERNF]=="S" .And. aNFCab[NF_TIPONF]$"DB"))
			    aNfItem[nItem][IT_SPED][nImp][SP_MODBC] := "6"
			Else
				aNfItem[nItem][IT_SPED][nImp][SP_MODBC] := "4"	
			EndIf
		EndIf
		aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_GRPCST] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_CEST] := aNfItem[nItem][IT_CEST]
		aNfItem[nItem][IT_SPED][nImp][SP_PICMDIF] := aNfItem[nItem][IT_TS][TS_PICMDIF]
		If aNfItem[nItem][IT_DESCZF] > 0
			// Conforme NT2013.005 v1.22 - Grupo Tributação do ICMS = 30 - Isento ou nao tributado c/ ST (Utilizado nas operacoes c/ ZFM).
			// Gerar tag "vICMSDeson" com o ICMS desonerado quando o motivo for 6, 7 ou 9.
			aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := IIf(Alltrim(aNfItem[nItem][IT_LIVRO][LF_MOTICMS]) $ "6|7|9", (aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS] + aNfItem[nItem][IT_DESCZFCOF])), 0)
		Else
			aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := Iif(!Empty(aNfItem[nItem][IT_LIVRO][LF_MOTICMS]) .And. aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] > 0,((aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] * 100) / aNfItem[nItem][IT_SPED][nImp][SP_PREDBC])-(aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB]),0)
		EndIf
		//Quando existir Codigo declaratorio  preencher conforme calculado
		If cMvEstado $ aSX6[MV_DESONRJ] .And. aNfItem[nItem][IT_DESCZF] == 0
			If aNfItem[nItem][IT_ICMSDIF] > 0 .And. aNFItem[nItem][IT_TS][TS_ICMSDIF] =='7'
				aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := aNfItem[nItem][IT_ICMSDIF]
			Elseif !Empty(aNfItem[nItem][IT_LIVRO][LF_MOTICMS]) .And. aNfItem[nItem][IT_PREDST] > 0
				nValStDesone := ((aNfItem[nItem][IT_BASESOL] / (aNfItem[nItem][IT_PREDST]/100)) * (100-aNfItem[nItem][IT_PREDST])/100) / (1-(aNfItem[nItem][IT_ALIQSOL] / 100)) * (aNfItem[nItem][IT_ALIQSOL]/100)
				aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := aNfItem[nItem][IT_ICMDESST] := nValStDesone
			Endif
		EndIf
		aNfItem[nItem][IT_SPED][nImp][SP_BFCP] := aNfItem[nItem][IT_BSFCPST]
		aNfItem[nItem][IT_SPED][nImp][SP_PFCP] := IIf(aNfItem[nItem][IT_FCPAUX] > 0, aNfItem[nItem][IT_FCPAUX], aNfItem[nItem][IT_ALFCST])
		aNfItem[nItem][IT_SPED][nImp][SP_VFCP] := aNfItem[nItem][IT_VFECPST]
	EndIf

	If aNfItem[nItem][IT_VALCMP] > 0 .Or. aNfItem[nItem][IT_VFCPDIF] > 0 .Or. aNfItem[nItem][IT_BASEDES] > 0
		aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
		nImp++
		aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
		aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
		aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "CMP"
		aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := substr(aNfItem[nItem][IT_CLASFIS],1,1)
		aNfItem[nItem][IT_SPED][nImp][SP_MVA]    := aNfItem[nItem][IT_MVACMP]
		aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := aNfItem[nItem][IT_PREDCMP]
		aNfItem[nItem][IT_SPED][nImp][SP_BC]     := Iif(aNfItem[nItem][IT_BASEDES]>0,aNfItem[nItem][IT_BASEDES],IIF(aNfItem[nItem][IT_PREDCMP]==0,aNfItem[nItem][IT_BASEICM],aNfItem[nItem][IT_BICMORI]))
		aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQCMP]
		If (;
			( aNfCab[NF_OPERNF] == "E" .AND. !( aNFCab[NF_TIPONF] $ "B|D" ) ) .OR.;
			( aNfCab[NF_OPERNF] == "S" .AND. ( aNFCab[NF_TIPONF] $ "B|D" ) );
		)
			aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_DIFAL]
			aNfItem[nItem][IT_SPED][nImp][SP_VDDES]  := aNfItem[nItem][IT_VALCMP]
		Else
			aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALCMP]
			aNfItem[nItem][IT_SPED][nImp][SP_VDDES]  := aNfItem[nItem][IT_DIFAL]
		EndIf
		aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PARTICM] := IIF(!Empty(aNFItem[nItem][IT_TS][TS_PARTICM]), aNFItem[nItem][IT_TS][TS_PARTICM], "1")
		aNfItem[nItem][IT_SPED][nImp][SP_GRPCST] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_CEST]	 := aNfItem[nItem][IT_CEST]
		aNfItem[nItem][IT_SPED][nImp][SP_PICMDIF] := aNfItem[nItem][IT_TS][TS_PICMDIF]
		aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_PDDES] := aNfItem[nItem][IT_PDDES]
		aNfItem[nItem][IT_SPED][nImp][SP_PDORI] := aNfItem[nItem][IT_PDORI]
		aNfItem[nItem][IT_SPED][nImp][SP_ADIF] := aNfItem[nItem][IT_ALIQICM]
		aNfItem[nItem][IT_SPED][nImp][SP_BFCP] := aNfItem[nItem][IT_BSFCCMP]
		aNfItem[nItem][IT_SPED][nImp][SP_PFCP] := Iif(aNfItem[nItem][IT_VFCPDIF] > 0,IIf(aNfItem[nItem][IT_FCPAUX] > 0, aNfItem[nItem][IT_FCPAUX], aNfItem[nItem][IT_ALFCCMP]),0)
		aNfItem[nItem][IT_SPED][nImp][SP_VFCP] := aNfItem[nItem][IT_VFCPDIF]
	EndIf

	If aNfItem[nItem][IT_VALIPI] > 0 .Or. aNfItem[nItem][IT_BASEIPI] > 0
		aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
		nImp++
		aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
		aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
		aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "IPI"
		aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := substr(aNfItem[nItem][IT_CLASFIS],1,1)
		aNfItem[nItem][IT_SPED][nImp][SP_CST]	  := IIf( Empty(aSX6[MV_RCSTIPI]) , aNFItem[nItem][IT_TS][TS_CTIPI] , aSX6[MV_RCSTIPI] ) //Tratamento de Rastro de ATIVO para IPI.
		aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := aNfItem[nItem][IT_PREDIPI]
		aNfItem[nItem][IT_SPED][nImp][SP_BC]     := aNfItem[nItem][IT_BASEIPI]
		aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQIPI]
		aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALIPI]
		aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := aNfItem[nItem][IT_QUANT]*IIF(!Empty(aSX6[MV_IPIPFAT]) , aNfItem[nItem][IT_PRD][SB_IPIPFAT] , 1 )
		aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := aNfItem[nItem][IT_PAUTIPI]
		aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PARTICM] := IIF(!Empty(aNFItem[nItem][IT_TS][TS_PARTICM]), aNFItem[nItem][IT_TS][TS_PARTICM], "1")
		aNfItem[nItem][IT_SPED][nImp][SP_GRPCST] := aNfItem[nItem][IT_GRPCST]
		aNfItem[nItem][IT_SPED][nImp][SP_CEST]	 := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PICMDIF] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_PDEVOL] := 0
		If aNFCab[NF_TIPONF] $ "BD"
			If !Empty(aNFItem[nItem][IT_RECORI])
				If aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] == "C"
					dbSelectArea("SD2")
					MsGoto(aNFItem[nItem][IT_RECORI])
					nQtd := SD2->D2_QUANT
				ElseIf aNFCab[NF_OPERNF] == "S" .And. aNFCab[NF_CLIFOR] == "F"
					dbSelectArea("SD1")
					MsGoto(aNFItem[nItem][IT_RECORI])
					nQtd := SD1->D1_QUANT
				EndIf
				If nQtd > 0 .And. nQtd >= aNFitem[nItem][IT_QUANT]
					aNfItem[nItem][IT_SPED][nImp][SP_PDEVOL] := 100 * aNFitem[nItem][IT_QUANT] / nQtd
				EndIf
			Elseif aNFitem[nItem][IT_QTDORI] > 0 .And. aNFitem[nItem][IT_QTDORI] >= aNFitem[nItem][IT_QUANT]
				aNfItem[nItem][IT_SPED][nImp][SP_PDEVOL] := 100 * aNFitem[nItem][IT_QUANT] / aNFitem[nItem][IT_QTDORI]
			EndIf
		EndIf
	EndIf

	If aNFItem[nItem][IT_TS][TS_ISS] == "S" .And. (aNfItem[nItem][IT_VALISS] > 0 .Or. aNfItem[nItem][IT_BASEISS] > 0)
		aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
		nImp++
		aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
		aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
		aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "ISS"
		aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := aNfItem[nItem][IT_PRD][SB_ORIGEM]
		aNfItem[nItem][IT_SPED][nImp][SP_CST]    := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := aNfItem[nItem][IT_PREDISS]
		aNfItem[nItem][IT_SPED][nImp][SP_BC]     := aNfItem[nItem][IT_BASEISS]
		aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQISS]
		// Tratamento para NFSE não leva valor quando a Natureza da Operação for Imune, Isenta, exigibilidade suspensa ou Simples Nacional e não tiver o ISS retido na fonte (TSWXFR/TT1000) http://tdn.totvs.com/pages/releaseview.action?pageId=203755129&moved=true
		aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] :=	Iif(aSX6[MV_ISSZERO] .And. (aNfItem[nItem][IT_TS][TS_ISSST]$"3/4/5/6/7/8" .Or.(aSX6[MV_OPTSIMP] == "1" .And. aNfItem[nItem][IT_LIVRO][LF_RECISS]=="2")),0,aNfItem[nItem][IT_VALISS])
		aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := 0
		aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := 0
		aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := SM0->M0_CODMUN
		aNfItem[nItem][IT_SPED][nImp][SP_PARTICM] := IIF(!Empty(aNFItem[nItem][IT_TS][TS_PARTICM]), aNFItem[nItem][IT_TS][TS_PARTICM], "1")
		aNfItem[nItem][IT_SPED][nImp][SP_GRPCST] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_CEST]	 := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PICMDIF] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := 0
	EndIf
	If aNfItem[nItem][IT_VALPS2] > 0 .Or. aNfItem[nItem][IT_BASEPS2] > 0
		aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
		nImp++
		aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
		aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
		aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "PS2"
		aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := substr(aNfItem[nItem][IT_CLASFIS],1,1)
		aNfItem[nItem][IT_SPED][nImp][SP_CST]    := aNfItem[nItem][IT_LIVRO][LF_CSTPIS]
		aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := ""
		aNfItem[nItem][IT_SPED][nImp][SP_MVA]    := 0
		aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_BC]     := aNfItem[nItem][IT_BASEPS2]
		aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQPS2]
		aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALPS2]
		aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := aNfItem[nItem,IT_QUANT]
		aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := IIF((Empty(aNFitem[nItem,IT_EXCECAO]).Or.Empty(aNFItem[nItem,IT_EXCECAO,10]).Or.aNfItem[nItem,IT_QUANT]==0.Or. aSX6[MV_PISPAUT] ),aNfItem[nItem][IT_PRD][SB_VLR_PIS],aNFItem[nItem,IT_EXCECAO,10])
		aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PARTICM] := IIF(!Empty(aNFItem[nItem][IT_TS][TS_PARTICM]), aNFItem[nItem][IT_TS][TS_PARTICM], "1")
		aNfItem[nItem][IT_SPED][nImp][SP_GRPCST] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_CEST]	 := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PICMDIF] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := 0
	EndIf

	If aNfItem[nItem][IT_VALCF2] > 0 .Or. aNfItem[nItem][IT_BASECF2] > 0
		aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
		nImp++
		aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
		aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
		aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "CF2"
		aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := substr(aNfItem[nItem][IT_CLASFIS],1,1)
		aNfItem[nItem][IT_SPED][nImp][SP_CST]    := aNfItem[nItem][IT_LIVRO][LF_CSTCOF]
		aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := ""
		aNfItem[nItem][IT_SPED][nImp][SP_MVA]    := 0
		aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_BC]     := aNfItem[nItem][IT_BASECF2]
		aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQCF2]
		aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALCF2]
		aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := aNfItem[nItem,IT_QUANT]
		aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := IIF((Empty(aNFitem[nItem,IT_EXCECAO]).Or.Empty(aNFItem[nItem,IT_EXCECAO,11]).Or.aNfItem[nItem,IT_QUANT]==0.Or. aSX6[MV_COFPAUT]),aNfItem[nItem][IT_PRD][SB_VLR_COF],aNFItem[nItem,IT_EXCECAO,11])
		aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PARTICM] := IIF(!Empty(aNFItem[nItem][IT_TS][TS_PARTICM]), aNFItem[nItem][IT_TS][TS_PARTICM], "1")
		aNfItem[nItem][IT_SPED][nImp][SP_GRPCST] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_CEST]	 := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PICMDIF] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := 0
	EndIf

	If aNfItem[nItem][IT_VALPS3] > 0 .Or. aNfItem[nItem][IT_BASEPS3] > 0
		aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
		nImp++
		aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
		aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
		aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "PS3"
		aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := substr(aNfItem[nItem][IT_CLASFIS],1,1)
		aNfItem[nItem][IT_SPED][nImp][SP_CST]    := aNFItem[nItem][IT_TS][TS_CSTPIS]
		aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := ""
		aNfItem[nItem][IT_SPED][nImp][SP_MVA]    := 0
		aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_BC]     := aNfItem[nItem][IT_BASEPS3]
		aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQPS3]
		aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALPS3]
		aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := 0
		aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := 0
		aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PARTICM] := IIF(!Empty(aNFItem[nItem][IT_TS][TS_PARTICM]), aNFItem[nItem][IT_TS][TS_PARTICM], "1")
		aNfItem[nItem][IT_SPED][nImp][SP_GRPCST] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_CEST]	 := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PICMDIF] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := 0
	EndIf

	If aNfItem[nItem][IT_VALCF3] > 0 .Or. aNfItem[nItem][IT_BASECF3] > 0
		aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
		nImp++
		aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
		aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
		aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "CF3"
		aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := substr(aNfItem[nItem][IT_CLASFIS],1,1)
		aNfItem[nItem][IT_SPED][nImp][SP_CST]    := aNFItem[nItem][IT_TS][TS_CSTCOF]
		aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := ""
		aNfItem[nItem][IT_SPED][nImp][SP_MVA]    := 0
		aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_BC]     := aNfItem[nItem][IT_BASECF3]
		aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQCF3]
		aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALCF3]
		aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := 0
		aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := 0
		aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PARTICM] := IIF(!Empty(aNFItem[nItem][IT_TS][TS_PARTICM]), aNFItem[nItem][IT_TS][TS_PARTICM], "1")
		aNfItem[nItem][IT_SPED][nImp][SP_GRPCST] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_CEST]	 := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PICMDIF] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := 0
	EndIf

	If aNfItem[nItem][IT_VALTST] > 0 .Or. aNfItem[nItem][IT_BASETST] > 0
		aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
		nImp++
		aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
		aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
		aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "TST"
		aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := aNfItem[nItem][IT_PRD][SB_ORIGEM]
		aNfItem[nItem][IT_SPED][nImp][SP_CST]    := aNFItem[nItem][IT_TS][TS_CSTCOF]
		aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := ""
		aNfItem[nItem][IT_SPED][nImp][SP_MVA]    := 0
		aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_BC]     := aNfItem[nItem][IT_BASETST]
		aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := aNfItem[nItem][IT_ALIQTST]
		aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := aNfItem[nItem][IT_VALTST]
		aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := 0
		aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := 0
		aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PARTICM] := IIF(!Empty(aNFItem[nItem][IT_TS][TS_PARTICM]), aNFItem[nItem][IT_TS][TS_PARTICM], "1")
		aNfItem[nItem][IT_SPED][nImp][SP_GRPCST] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_CEST]	 := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PICMDIF] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := 0
	EndIf

	If aNfItem[nItem][IT_DESCZF]>0 .And. aPos[FP_CD2_DESCZF]
		aadd(aNfItem[nItem][IT_SPED],aClone(aImp))
		nImp++
		aNfItem[nItem][IT_SPED][nImp][SP_ITEM]   := aNfItem[nItem][IT_ITEM]
		aNfItem[nItem][IT_SPED][nImp][SP_CODPRO] := aNfItem[nItem][IT_PRODUTO]
		aNfItem[nItem][IT_SPED][nImp][SP_IMP]    := "ZFM"
		aNfItem[nItem][IT_SPED][nImp][SP_ORIGEM] := substr(aNfItem[nItem][IT_CLASFIS],1,1)
		aNfItem[nItem][IT_SPED][nImp][SP_CST]    := substr(aNfItem[nItem][IT_CLASFIS],2,2)
		aNfItem[nItem][IT_SPED][nImp][SP_MODBC]  := ""
		aNfItem[nItem][IT_SPED][nImp][SP_MVA]    := 0
		aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_BC]     := 0
		aNfItem[nItem][IT_SPED][nImp][SP_ALIQ]   := 0
		aNfItem[nItem][IT_SPED][nImp][SP_VLTRIB] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_QTRIB]  := 0
		aNfItem[nItem][IT_SPED][nImp][SP_PAUTA]  := 0
		aNfItem[nItem][IT_SPED][nImp][SP_COD_MN] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_DESCZF] := (aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS] + aNfItem[nItem][IT_DESCZFCOF]))

		If cMvEstado $ aSX6[MV_DESONRJ] .And. !Empty(aNfItem[nItem][IT_LIVRO][LF_MOTICMS])
			If aNfItem[nItem][IT_SPED][nImp][SP_PREDBC] > 0
				If aNfCab[NF_PPDIFAL] .And. aNFCab[NF_LINSCR] .And. aNfItem[nItem][IT_TS][TS_DEDDIF] $ " 1"
					nAliqDed := aNfItem[nItem][IT_ALIQCMP] + aNfItem[nItem][IT_ALFCCMP]
				Else
					nAliqDed :=	aNfItem[nItem][IT_ALIQICM]
				EndIf
				aNfItem[nItem][IT_ICMDESONE] :=  Round(   aNfItem[nItem][IT_BICMORI] * (1 - ( (nAliqDed/100) * (1 -  (1 - (aNfItem[nItem][IT_SPED][nImp][SP_PREDBC]/100))  ))) / (1 -  (nAliqDed/100) ) - aNfItem[nItem][IT_BICMORI]  ,2)
			Else
				aNfItem[nItem][IT_ICMDESONE] := Round( ( aNfItem[nItem][IT_BICMORI] / (1-(aNfItem[nItem][IT_ALIQICM] / 100))) * (aNfItem[nItem][IT_ALIQICM]/100) ,2)
			EndIf
		EndIf

		aNfItem[nItem][IT_SPED][nImp][SP_PARTICM] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_GRPCST] := ""
		aNfItem[nItem][IT_SPED][nImp][SP_CEST]	 := ""
		aNfItem[nItem][IT_SPED][nImp][SP_PICMDIF] := 0
		aNfItem[nItem][IT_SPED][nImp][SP_DESONE] := 0

	EndIf


EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} xFisGrossIR()
Verifica se deverá realizar o GrossUp do Imposto de Renda

@return   lRet 	   - Retorna se deverá ou não fazer o GrossUp do IRRF

@author Erick Gonçalves Dias
@since 17/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function xFisGrossIR(nItem, aNFItem, aNfCab, cOpcao)

If FindFunction("xFisGIR")
	return xFisGIR(nItem, aNFItem, aNfCab, cOpcao)
EndIF
Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³GetConcept³ Autor ³jonathan gonzalez      ³ Data ³13-03-2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtiene Codigo Concepto RIR conforme la TES                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cExp1 := Codigo Concepto Retencion IR                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 := Codigo TES del libro fiscal                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetConcept( cTes )
Local aArea    := GetArea()
Local cConcept := ""

	dbSelectArea("SF4")
	SF4->(dbSetOrder(1)) //F4_FILIAL + F4_CODIGO
	IF SF4->( DbSeek(xFilial("SF4")+cTes) )

		dbSelectArea("SFC")
		SFC->(dbSetOrder(2)) //FC_FILIAL + FC_TES + FC_IMPOSTO
		SFC->( DbSeek(xFilial("SFC")+ SF4->F4_CODIGO) )
		While  !SFC->(EOF()) .AND. SFC->FC_TES == SF4->F4_CODIGO

			IF ALLTRIM( SFC->FC_IMPOSTO ) == "RIR"
				DbSelectArea("SFB")
				SFB->(DbSetOrder(1)) //FB_FILIAL + FB_CODIGO
				If SFB->(DbSeek(xFilial("SFB")+ SFC->FC_IMPOSTO))
					cConcept := SFB->FB_CODRET
				EndIf
			EndIf

			SFC->(DbSkip())
		EndDo
	EndIf

RestArea(aArea)
Return cConcept

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisTrbGen()
Função que fará o enquadramento das regras de tributos géricos, procurando
pelos perfis de operação, produto/origem, operação e origem/destino.
Esta função também fará os cálculos dos tributos genéricos, e todas as informações
das regras e valores serão atualizados diretamente no aNfItem.

@param aNfCab   - Array com as informações cabeçalho da nota fiscal
@param aNfItem  - Array com toda as informações do item da nota fiscal
@param nItem    - Número do item da nota fiscal
@param cCampo   - Campo processado na Recall
@param cExecuta - Campo com propriedade do tributo genérico que deverá ser processada, BSE, VLR ou ALQ
@param cTrib    - Tributo genérico que deverá ser processado
@param aPos    - Array com cache dos fieldpos
@param aDic    - Array com cache de aliasindic

@author Erick Gonçalves Dias
@since 26/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function xFisTrbGen(aNfCab, aNfItem, nItem, cCampo, cExecuta, cTrib, aPos, aDic, nTGITRef, aHmFor, aDepTrib, aDepVlOrig,aFunc,aUltPesqF2D)
IF FindFunction("FisTribGen")
	FisTribGen(aNfCab, aNfItem, nItem, cCampo, cExecuta, cTrib, aPos, aDic, nTGITRef, aHmFor, aDepTrib, aDepVlOrig,aFunc,aUltPesqF2D)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisCalcTG()
Função responsável por interpretar as regras e efetuar o cálculo dos
tributos genéricos conforme cadastrados.

@param aNfItem - Array com toda as informações do item da nota fiscal
@param nItem   - Número do item da nota fiscal
@param nTrbGen - Posição do tributo genério na referência IT_TRIBGEN
@param cExecuta - Indica as opções de base, alíquota e valor que deverão ser calculadas.

@author joao.pellegrini
@since 27/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function xFisCalcTG(aNFItem, nItem, nTrbGen, cExecuta)

IF FindFunction("FisCalcTG")
	FisCalcTG(aNFItem, nItem, nTrbGen, cExecuta)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisLoadTG()
Função responsável por buscar os valores dos tributos genéricos gravados
na CD2, para carregar estes valores e adicionar nas referências do IT_TRBGEN

@param aNfItem   - Array Com todas informações do aNfItem
@param nItem     - Número do item atual
@param cIdDevol  - ID da tabela F2D para as notas de devoluções
@param nTGITRef  - Posição do Id do tributo genérico que deverá ser carregado
@param aNfCab    - Array Com todas informações do aNfCab
@param aPos      - Array com o cache de fieldpos
@param aDic    	 - Array com cache das tabelas
@param aHmFor    	 
@param lReproc    	 - indica reprocessamento

@author Erick Gonçalves Dias
@since 03/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function xFisLoadTG(aNfItem, nItem, cIdDevol, nTGITRef, aNFCab, aPos, aDic, aHmFor, lReproc)

IF FindFunction("FisLoadTG")
	FisLoadTG(aNfItem, nItem, cIdDevol,nTGITRef,aNFCab, aPos, aDic, aHmFor, lReproc)
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} xFisGrbTrbGen()
Função responsável por realizar a gravação dos tributos genéricos na tabela F2D.
A gravação irá considerar as informações contidas na referência do aNfItem IT_TRBGEN

@param aNfItem - Array com todas as informações do item da nota fiscal
@param nItem - Número do item a ser processado por esta função.
@param cAlias - Alias da tabela do item que terá gravado o ID do tributo genérico.

@return cRet - Retornar o ID utilizado na gravação dos tributos na F2D, para que os fontes
consumidores possam gravar este ID em suas respectivas tabelas de itens, como a SD1 e SD2.

@author Erick Gonçalves Dias
@since 09/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function xFisGrvTrbGen(aNfItem, nItem, cAlias, aDic)

Local cRet	:= ""
IF FindFunction("FisGrvTrbGen")
	cRet := FisGrvTrbGen(aNfItem, nItem, cAlias, aDic)
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisDelTrbGen()
Função responsável por adicionar a data de exclusão do registro na
tabela F2D. Esta tabela nunca será efetivamente deletada pois caso
o documento de origem seja cancelado/excluído perderia-se a relação
entre as tabelas.

@param cIdTribGen - ID para buscar as informações que serão deletadas

@author Erick Gonçalves Dias
@since 10/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function xFisDelTrbGen(cIdTrbGen)

IF FindFunction("FisDelTrbGen")
	FisDelTrbGen(cIdTrbGen)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkTrbGen()
Função responsável por efetuar algumas validações para utilização dos
tributos genéricos.

@param cAlias - Alias da tabela no qual será gravado o ID de relacionamento
com a tabela F2D.
@para cCampo - Campo no qual será gravado o ID de relacionamento com a
tabela F2D.

@author Erick Gonçalves Dias
@since 10/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function ChkTrbGen(cAlias, cCampo)

Local lRet	:= .F.
IF FindFunction("FisChkTG")
	lRet	:= FisChkTG(cAlias, cCampo)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisDevTrbGen()
Função responsável por tratar as devoluções de venda e de compra dos tributos
genéricos.
Esta função utilizará o RECORI da SD1/SD2 para buscar o ID do tributo genérico,
fará a carga dos valores e proporcionalizará considerando a quantidade da nota
original com a nota de devolução.

@param aNfCab   - Array com as informações cabeçalho da nota fiscal
@param aNfItem  - Array com toda as informações do item da nota fiscal
@param nItem    - Número do item da nota fiscal
@param aPos    - Array com cache dos fieldpos
@param aDic    - Array com cache de aliasindic
@param cCampo  - String com o campo alterado na pilha da recall

@author Erick Gonçalves Dias
@since 11/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function xFisDevTrbGen(aNfCab, aNfItem, nItem, aPos, aDic, cCampo, aHmFor)

IF FindFunction("FisDevTrbGen")
	FisDevTrbGen(aNfCab, aNfItem, nItem, aPos, aDic, cCampo, aHmFor)
EndIf

Return

/*/{Protheus.doc} xFisHdrTG()
@description Função responsável por montar o aHeader do folder
dos tributos genéricos.
@author erick.dias
/*/
Function xFisHdrTG()

Local aHdrTrbGen	:= {}

IF FindFunction("FisHdrTG")
	aHdrTrbGen	:= FisHdrTG()
EndIf

Return aHdrTrbGen

/*/{Protheus.doc} xFisRetTG()
@description Função responsável por retornar os tributos genéricos passíveis de retenção
@author erick.dias
/*/
Function xFisRetTG(dDataOper)

Local aRet	:= {}

IF FindFunction("FisRetTG")
	aRet	:= FisRetTG(dDataOper)
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisF2F

Funcao responsável por componentizar a gravação da tabela F2F.

@author joao.pellegrini
@since 08/10/2018
@version 11.80
/*/
//-------------------------------------------------------------------
Function xFisF2F(cOper, cIdNF, cTabela, aTGCalcRec)

IF FindFunction("FisF2F")
	FisF2F(cOper, cIdNF, cTabela, aTGCalcRec)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisTitTG

Função responsável por retornar o número do título de tributo genérico
a ser gerado.

@author joao.pellegrini
@since 08/10/2018
@version 11.80
/*/
//-------------------------------------------------------------------
Function xFisTitTG()

Local cNumero	:= ""

IF FindFunction("FisTitTG")
	cNumero	:= FisTitTG()
EndIf

Return cNumero

//-------------------------------------------------------------------
/*/{Protheus.doc} FK7ToE1E2

Função responsável por converter uma chave FK7 para uma chave de SE1/SE2.

@author joao.pellegrini
@since 10/10/2018
@version 11.80
/*/
//-------------------------------------------------------------------
Function FK7ToE1E2(cChaveFK7, cTabela)

Local cChvSE	:= ""

IF FindFunction("FISFK7E1E2")
	cChvSE	:= FISFK7E1E2(cChaveFK7, cTabela)
EndIf

Return cChvSE

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisDelTit

Função responsável por retornar o número do título de tributo genérico
a ser gerado.

@params
nOpcao - Indica qual operacao deve ser efetuada:
1 - Validar Exclusão(ões)
2 - Excluir título(s) - Deve ser utilizada sempre após validar a exclusao.

@author joao.pellegrini
@since 08/10/2018
@version 11.80
/*/
//-------------------------------------------------------------------
Function xFisDelTit(cIdNF, cTabela, cOrigem, nOpcao, cNumTit)

Local lRet	:= .T.

IF FindFunction("FisDelTit")
	lRet	:= FisDelTit(cIdNF, cTabela, cOrigem, nOpcao, cNumTit)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisGetURF

Função que retornará o valor atual da URF, considerando o período
e código da URF.

@author Erick Dias
@since 06/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function xFisGetURF(dDate, cCodURF, nPercURF)

Local nUrfAtual	:= 0

IF FindFunction("FisGetURF")
	nUrfAtual	:= FisGetURF(dDate, cCodURF, nPercURF)
EndIf

Return nUrfAtual

/*/{Protheus.doc} xFisPosCFC()
@description Função que trata posicionamento da tabela CFC (UF x UF)
para prencimento das váriaveis de calculo de FECP e DIFAL.
@author joao.balbio
/*/
Function xFisPosCFC(nOpc,nItem, aDic, aPos, aNfCab, aSX6, aNfitem)
Local lAchouCFC := .F.
Default nOpc := nItem := 0
//nOpc (variavel de controle da chamada da função)
//nOpc = 1 (MaFisIni-Atualiza somente o cabeçalho, caso não encontre gera com valores defaults)
//nOpc = 2 (MafisCfo-Atualiza item com base na CFC, caso não encontre gera com valores defaults)
//nOpc = 3 (MaFisCPO-Atualiza item com base na CFC, caso não econtre o cadastro não utiliza default)
// Se houver alteração do estado de destino reposiciono a tabela CFC UF x UF.
If nOpc == 1
	If aDic[AI_CFC] .And. aPos[FP_CFC_CODPRD] .And. CFC->( MsSeek( xFilial( "CFC" ) + Iif(aNfCab[NF_TIPONF] == "D", aNFCab[NF_UFDEST] + aNFCab[NF_UFORIGEM], aNFCab[NF_UFORIGEM] + aNFCab[NF_UFDEST]) + PadR( ' ' , GTamMxFis(TAM_CFC_CODPRD) ) ) )
		aNfCab[NF_UFXUF][UF_ALIQFECP]	:= CFC->CFC_ALQFCP
		aNfCab[NF_UFXUF][UF_MARGSTLIQ]	:= Iif( aPos[FP_CFC_MGLQST] , CFC->CFC_MGLQST , 0)
		aNfCab[NF_UFXUF][UF_ALIQSTLIQ]	:= Iif( aPos[FP_CFC_ALQSTL] , CFC->CFC_ALQSTL , 0)
		aNfCab[NF_UFXUF][UF_MARGEM]		:= Iif( aPos[FP_CFC_MARGEM] , CFC->CFC_MARGEM , 0)
		aNfCab[NF_UFXUF][UF_ALQFCPO]	:= Iif( aPos[FP_CFC_ALFCPO] , CFC->CFC_ALFCPO , 0)
		aNfCab[NF_UFXUF][UF_FECPAUX]	:= Iif( aPos[FP_CFC_FCPAUX] , CFC->CFC_FCPAUX , 0)
		aNfCab[NF_UFXUF][UF_FECPDIF]	:= Iif( aPos[FP_CFC_FCPXDA] , CFC->CFC_FCPXDA , '1')
		aNfCab[NF_UFXUF][UF_FECPINT]	:= Iif( aPos[FP_CFC_FCPINT] , CFC->CFC_FCPINT , '1')
		aNfCab[NF_UFXUF][UF_RDCTIMP]	:= Iif( aPos[FP_CFC_RDCTIM] , CFC->CFC_RDCTIM , 1)
		aNfCab[NF_UFXUF][UF_MVAFRU]		:= Iif( aPos[FP_MV_MVAFRU] , &(aSX6[MV_MVAFRU]),0)
		aNfCab[NF_UFXUF][UF_MVAES]		:= Iif( aPos[FP_CFC_MVAES]  , CFC->CFC_MVAES  , '1'	)
		aNfCab[NF_UFXUF][UF_ADICST]		:= Iif( aPos[FP_CFC_ADICST] , CFC->CFC_ADICST  , 0  )
		aNfCab[NF_UFXUF][UF_PICM]		:= Iif( aPos[FP_CFC_PICM] , CFC->CFC_PICM  , 0   )
		aNfCab[NF_UFXUF][UF_VLICMP]		:= Iif( aPos[FP_CFC_VLICMP] , CFC->CFC_VLICMP  , 0 )
		aNfCab[NF_UFXUF][UF_VL_ICM]		:= Iif( aPos[FP_CFC_VL_ICM] , CFC->CFC_VL_ICM  , 0 )
		aNfCab[NF_UFXUF][UF_VL_ANT]		:= Iif( aPos[FP_CFC_VL_ANT] , CFC->CFC_VL_ANT  , 0 )
		aNfCab[NF_UFXUF][UF_BS_FCPPR]	:= Iif( aPos[FP_CFC_BFCPPR] , CFC->CFC_BFCPPR  , '' )
		aNfCab[NF_UFXUF][UF_BS_FCPST]	:= Iif( aPos[FP_CFC_BFCPST] , CFC->CFC_BFCPST  , '' )
		aNfCab[NF_UFXUF][UF_BS_FCPCM]	:= Iif( aPos[FP_CFC_BFCPCM] , CFC->CFC_BFCPCM  , '' )
		aNfCab[NF_UFXUF][UF_AFCPST]	    := Iif( aPos[FP_CFC_AFCPST] , CFC->CFC_AFCPST  , '1' )
		aNfCab[NF_UFXUF][UF_ALFEEF]	    := Iif( aPos[FP_CFC_ALFEEF] , CFC->CFC_ALFEEF  , 0 )
		aNfCab[NF_UFXUF][UF_PAUTFOB]    := Iif( aPos[FP_CFC_PAUTFB] , CFC->CFC_PAUTFB  , 0 )
		aNfCab[NF_UFXUF][UF_ALANTICMS]  := Iif( aPos[FP_CFC_ALQANT] , CFC->CFC_ALQANT  , 0 )
			aNfCab[NF_UFXUF][UF_BASRDZ]  := Iif( aPos[FP_CFC_FCPBSR] , CFC->CFC_FCPBSR  , '' )
	Else
		aNfCab[NF_UFXUF][UF_ALIQFECP]	:= 0
		aNfCab[NF_UFXUF][UF_MARGSTLIQ]	:= 0
		aNfCab[NF_UFXUF][UF_ALIQSTLIQ]	:= 0
		aNfCab[NF_UFXUF][UF_MARGEM]		:= 0
		aNfCab[NF_UFXUF][UF_ALQFCPO]	:= 0
		aNfCab[NF_UFXUF][UF_FECPAUX]	:= 0
		aNfCab[NF_UFXUF][UF_FECPDIF]	:= '1'
		aNfCab[NF_UFXUF][UF_FECPINT]	:= '1'
		aNfCab[NF_UFXUF][UF_RDCTIMP]	:= 0
		aNfCab[NF_UFXUF][UF_MVAFRU]		:= 0
		aNfCab[NF_UFXUF][UF_MVAES]		:= '1'
		aNfCab[NF_UFXUF][UF_ADICST]		:= 0
		aNfCab[NF_UFXUF][UF_PICM]		:= 0
		aNfCab[NF_UFXUF][UF_VLICMP]		:= 0
		aNfCab[NF_UFXUF][UF_VL_ICM]		:= 0
		aNfCab[NF_UFXUF][UF_VL_ANT]		:= 0
		aNfCab[NF_UFXUF][UF_BS_FCPPR]	:= ''
		aNfCab[NF_UFXUF][UF_BS_FCPST]	:= ''
		aNfCab[NF_UFXUF][UF_BS_FCPCM]	:= ''
		aNfCab[NF_UFXUF][UF_AFCPST]    := '1'
		aNfCab[NF_UFXUF][UF_ALFEEF]    := 0
		aNfCab[NF_UFXUF][UF_PAUTFOB]   := 0
		aNfCab[NF_UFXUF][UF_ALANTICMS] := 0
		aNfCab[NF_UFXUF][UF_BASRDZ] := ''
	EndIf
Else
	If (nOpc == 2 .Or. nOpc == 3) .And. aNfitem <> NIL .And. nItem > 0

		//Reposiciona no registro da CFC para buscar as regras de UF x UF com uma regra mais especifica contendo o produto ou mais genérica sem o produto para os casos do cadastro de UF x UF não possuir produto especificado.
		If aDic[AI_CFC]
			If CFC->( MsSeek( xFilial( "CFC" ) + Iif(aNfCab[NF_TIPONF] == "D", aNFCab[NF_UFDEST] + aNFCab[NF_UFORIGEM], aNFCab[NF_UFORIGEM] + aNFCab[NF_UFDEST]) + aNfItem[nItem][IT_PRD][SB_COD] ) )
				lAchouCFC := .T.
			ElseIf CFC->( MsSeek( xFilial( "CFC" ) + Iif(aNfCab[NF_TIPONF] == "D", aNFCab[NF_UFDEST] + aNFCab[NF_UFORIGEM], aNFCab[NF_UFORIGEM] + aNFCab[NF_UFDEST]) + PadR( ' ' , GTamMxFis(TAM_CFC_CODPRD) ) ) )
				lAchouCFC := .T.
			EndIf
		EndIf

		If aDic[AI_CFC] .And. lAchouCFC
			aNfItem[nItem][IT_UFXPROD][UFP_ALIQFECP]	:=	CFC->CFC_ALQFCP
			aNfItem[nItem][IT_UFXPROD][UFP_MARGSTLIQ]	:=	Iif( aPos[FP_CFC_MGLQST] , CFC->CFC_MGLQST,0)
			aNfItem[nItem][IT_UFXPROD][UFP_ALIQSTLIQ]	:=	Iif( aPos[FP_CFC_ALQSTL] , CFC->CFC_ALQSTL,0)
			aNfItem[nItem][IT_UFXPROD][UFP_MARGEM]		:=	Iif( aPos[FP_CFC_MARGEM] , CFC->CFC_MARGEM,0)
			aNfItem[nItem][IT_UFXPROD][UFP_ALQFCPO]		:=	Iif( aPos[FP_CFC_ALFCPO] , CFC->CFC_ALFCPO,0)
			aNfItem[nItem][IT_UFXPROD][UFP_FECPAUX]		:=	Iif( aPos[FP_CFC_FCPAUX] , CFC->CFC_FCPAUX,0)
			aNfItem[nItem][IT_UFXPROD][UFP_FECPDIF]		:=	Iif( aPos[FP_CFC_FCPXDA] , CFC->CFC_FCPXDA,'1')
			aNfItem[nItem][IT_UFXPROD][UFP_FECPINT]		:=	Iif( aPos[FP_CFC_FCPINT] , CFC->CFC_FCPINT,'1')
			aNfItem[nItem][IT_UFXPROD][UFP_RDCTIMP]		:=	Iif( aPos[FP_CFC_RDCTIM] , CFC->CFC_RDCTIM,1)
			aNfItem[nItem][IT_IDCFC]					:= 	CFC->CFC_IDHIST
			aNfItem[nItem][IT_UFXPROD][UFP_MVAFRU]		:=	Iif( aPos[FP_MV_MVAFRU] , &(aSX6[MV_MVAFRU]),0)
			aNfItem[nItem][IT_UFXPROD][UFP_MVAES]		:=	Iif( aPos[FP_CFC_MVAES]  , CFC->CFC_MVAES,'1')
			aNfItem[nItem][IT_UFXPROD][UFP_ADICST]   :=  Iif( aPos[FP_CFC_ADICST]  , CFC->CFC_ADICST,0)
			aNfItem[nItem][IT_UFXPROD][UFP_PICM]   :=  Iif( aPos[FP_CFC_PICM]  , CFC->CFC_PICM,0)
			aNfItem[nItem][IT_UFXPROD][UFP_VLICMP]   := Iif( aPos[FP_CFC_VLICMP]  , CFC->CFC_VLICMP,0)
			aNfItem[nItem][IT_UFXPROD][UFP_VL_ICM]   := Iif( aPos[FP_CFC_VL_ICM]  , CFC->CFC_VL_ICM,0)
			aNfItem[nItem][IT_UFXPROD][UFP_VL_ANT]   := Iif( aPos[FP_CFC_VL_ANT]  , CFC->CFC_VL_ANT,0)
			aNfItem[nItem][IT_UFXPROD][UFP_BS_FCPPR]	:= Iif( aPos[FP_CFC_BFCPPR] , CFC->CFC_BFCPPR,'')
			aNfItem[nItem][IT_UFXPROD][UFP_BS_FCPST]	:= Iif( aPos[FP_CFC_BFCPST] , CFC->CFC_BFCPST,'')
			aNfItem[nItem][IT_UFXPROD][UFP_BS_FCPCM]	:= Iif( aPos[FP_CFC_BFCPCM] , CFC->CFC_BFCPCM,'')
			aNfItem[nItem][IT_UFXPROD][UFP_AFCPST]	   := Iif( aPos[FP_CFC_AFCPST] , CFC->CFC_AFCPST, '1')
			aNfItem[nItem][IT_UFXPROD][UFP_ALFEEF]	   := Iif( aPos[FP_CFC_ALFEEF] , CFC->CFC_ALFEEF,0)
			aNfItem[nItem][IT_UFXPROD][UFP_PAUTFOB]	   := Iif( aPos[FP_CFC_PAUTFB] , CFC->CFC_PAUTFB,0)
			aNfItem[nItem][IT_UFXPROD][UFP_ALANTICMS]   := Iif( aPos[FP_CFC_ALQANT] , CFC->CFC_ALQANT,0)
			aNfItem[nItem][IT_UFXPROD][UFP_BASRDZ]   := Iif( aPos[FP_CFC_FCPBSR] , CFC->CFC_FCPBSR,'')
			aNFItem[nItem][IT_UFXPROD][UFP_FCPAJT] := Iif( aPos[FP_CFC_FCPAJT] , CFC->CFC_FCPAJT,'')
		ElseIf nOpc == 2
			aNfItem[nItem][IT_UFXPROD][UFP_ALIQFECP]	:=	0
			aNfItem[nItem][IT_UFXPROD][UFP_MARGSTLIQ]	:=	0
			aNfItem[nItem][IT_UFXPROD][UFP_ALIQSTLIQ]	:=	0
			aNfItem[nItem][IT_UFXPROD][UFP_MARGEM]		:=	0
			aNfItem[nItem][IT_UFXPROD][UFP_ALQFCPO]		:=	0
			aNfItem[nItem][IT_UFXPROD][UFP_FECPAUX]		:=	0
			aNfItem[nItem][IT_UFXPROD][UFP_FECPDIF]		:=	'1'
			aNfItem[nItem][IT_UFXPROD][UFP_FECPINT]		:=	'1'
			aNfItem[nItem][IT_UFXPROD][UFP_RDCTIMP]		:=	1
			aNfItem[nItem][IT_IDCFC]			:= 	''
			aNfItem[nItem][IT_UFXPROD][UFP_MVAFRU]		:=	Iif( aPos[FP_MV_MVAFRU] , &(aSX6[MV_MVAFRU]) , 0   )
			aNfItem[nItem][IT_UFXPROD][UFP_MVAES]		:=	'1'
			aNfItem[nItem][IT_UFXPROD][UFP_ADICST]   :=  0
			aNfItem[nItem][IT_UFXPROD][UFP_PICM]   :=  0
			aNfItem[nItem][IT_UFXPROD][UFP_VLICMP]   := 0
			aNfItem[nItem][IT_UFXPROD][UFP_VL_ICM]   := 0
			aNfItem[nItem][IT_UFXPROD][UFP_VL_ANT]   := 0
			aNfItem[nItem][IT_UFXPROD][UFP_BS_FCPPR]	:= ''
			aNfItem[nItem][IT_UFXPROD][UFP_BS_FCPST]	:= ''
			aNfItem[nItem][IT_UFXPROD][UFP_BS_FCPCM]	:= ''
			aNfItem[nItem][IT_UFXPROD][UFP_AFCPST]    := '1'
			aNfItem[nItem][IT_UFXPROD][UFP_ALFEEF]   := 0
			aNfItem[nItem][IT_UFXPROD][UFP_PAUTFOB]   := 0
			aNfItem[nItem][IT_UFXPROD][UFP_ALANTICMS] := 0
			aNfItem[nItem][IT_UFXPROD][UFP_BASRDZ]   := ''
		Endif
	EndIf
EndIf

Return

/*/
xMaFisAjIt - Gustavo Rueda  -13/12/2007
Funcao de consistencias dos ajustes dos documentos fiscais.
Parametros
nXX -> Numero do item.
nTipo -> Tipo de processamento. 1=Item a item, 2=Todos Items
/*/
Function xMaFisAjIt(nXX, nTipo, aNfCab, aNfItem, aPos, aSX6, aDic, aPE, aInfNat )
Local aArea		:= SB1->(GetArea())
Local aGrava	:= {}
Local aBkpaCls	:= {}
Local cItem		:= Iif(aNfCab[NF_OPERNF]=="S", StrZero(1,GTamMxFis(TAM_D2_ITEM)), StrZero(1,GTamMxFis(TAM_D1_ITEM)))
Local cSeq		:= "001"
Local cUfLanc	:= ""
Local cPrdImp	:= ""
Local cIFCOMP	:= ""
Local cBase		:= ""
Local cAliq		:= ""
Local cValor	:= ""
Local cTpLanc	:= ""
Local cVL197	:= ""
Local cTpLanc	:= ""
Local nI		:= 0
Local nX		:= 0
Local nPosSeq	:= 0
Local nII		:= 0
Local nIF		:= 0
Local nZ		:= 0
Local nAliqVal	:= 0
Local nValor	:= 0
Local nBase		:= 0
Local nAliq		:= 0
Local lGerou	:= .F.
Local lHasRefl	:= .F.
Local cCmp0460  := ""
Local cCodRefl	:= ""
Local cGeraGNRE := ""
Local cCMPOrig  := ""
Local aParam	:= {}
Local nTamCC8  	:= GTamMxFis(TAM_CC8_CODIGO)
Local lTribCon	:= aNfCab[NF_TEMF2B]          //aNfCab[NF_CHKTRIBLEG]
Local lExecCja	:= ExecCja(aPos)
Local  oJCodRef	:= Nil

Default	nXX	  := 1
Default	nTipo := 1
Default aInfNat := {}

//Define se a funcao sera executada para todos os itens (aNfItem) ou para o item corrente
nII := Iif(nTipo==1,nXX,1)
nIF	:= Iif(nTipo==1,nXX,Len(aNfItem))
If Len(aNfItem)>0

	If lTribCon .And. lExecCja                                   			                // Verifica se tenho algum calculo de tributo feito pelo configurador
		RetCodAp(aNfCab[NF_DTEMISS], lBdjaSon, @oJCodRef, @__aPrepared, aNfItem, aNfCab)    // Carrega tabela de código de lançamento do configurador para um Json 
	Endif	

	For nZ := nII To nIF
		//Verifica se a linha do item foi deletada
		If aNfItem[nZ,IT_DELETED]
			Loop
		EndIf
		If lTribCon .And. lExecCja				    					// Verifica se tenho algum calculo de tributo feito pelo configurador	
			BusCodLan(@aGrava,nZ,aNfItem,aNfCab, lBdjaSon, oJCodRef)		// Busca código de lançamento do configurador	
		Endif	

		//Inicializa o TES correspondente ao item corrente
		MaFisTes(aNfItem[nZ,IT_TES],,nZ)

		For nI := 1 To Len(aNFItem[nZ][IT_TS][TS_LANCFIS])
		
			If (aScan(aGrava, {|x| Alltrim(x[1]) == AllTrim(aNfItem[nZ][IT_ITEM]) .And. AllTrim(x[2]) == AllTrim(aNFItem[nZ][IT_TS][TS_LANCFIS][nI][1]) .And. AllTrim(x[8]) == "CONFIG" }) == 0 )

				lHasRefl	:=	.F.
				//Verifica qual eh a UF do codigo de ajuste corrente
				cUfLanc := Substr(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],1,2)
				//Informacao Complementar do Codigo de Ajuste
				cIFCOMP	:=	aNFItem[nZ][IT_TS][TS_LANCFIS,nI,2]
				If aPos[FP_CC7_CLANC]//Complemento para registro 0460
					cCmp0460:=	aNFItem[nZ][IT_TS][TS_LANCFIS,nI,4]
				Endif
				cCodRefl:=	aNFItem[nZ][IT_TS][TS_LANCFIS,nI,3]
				//Produto Importado: exclusivo para o codigo SC10000018
				If aNfCab[NF_OPERNF] == "S" .And. aPos[FP_B1_IMPORT]
					dbSelectArea("SD2")
					dbGoTo(aNfItem[nZ,IT_RECNOSB1])
					cPrdImp := SB1->B1_IMPORT
				Endif

				cGeraGNRE := aNFItem[nZ][IT_TS][TS_LANCFIS,nI,5]
				cCMPOrig := aNFItem[nZ][IT_TS][TS_LANCFIS,nI,6]

				//Verifica se a UF do codigo de ajuste corresponde a UF do MV_ESTADO
				If cUfLanc $ aSX6[MV_ESTADO] .OR. ( Len(aNFItem[nZ][IT_TS][ TS_LANCFIS , nI , 1 ] ) == 8 .AND. ;
														SubStr( aNFItem[nZ][IT_TS][ TS_LANCFIS , nI , 1 ]  ,3,1) == '2' .AND.  ;
														cUfLanc $aNFCab[NF_UFDEST]) .Or. (cCMPOrig =="3" .And. !EmpTy(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,3]))

					//Captura o proximos codigo de sequencia a ser utilizado
					If Len(aGrava) > 0
						nPosSeq	 :=	7
						aBkpaCls :=	aClone(aGrava)
						aSort(aBkpaCls,,,{|aX,aY| aX[nPosSeq]<aY[nPosSeq]})
						cSeq :=	aBkpaCls[Len(aBkpaCls),nPosSeq]
						cSeq  := Soma1(cSeq)
					EndIf
					// Campo que determina se o lancamento eh de Apuracao (1) ou de NF (2)

					// Alguns codigos de ajuste sao validados pelo proprio MATXFIS, ou seja, as regras sao pre-estabelecidas no codigo fonte, porem
					//foi criado o mecanismo para configuracao dos Codigos de Ajuste utilizando o Cadastro de Reflexo (CE0) junto ao Cadastro de
					//Lancamentos (CC7). Desta forma as regras serao configuradas pelo proprio usuario, que definira Base, Aliquota e Valor do Codigo
					//atraves da tabela CE0.
					// Os codigos que ja eram validadas no MATXFIS foram mantidos por questao de legado. Os demais alem desses codigos deverao ser
					//configurados conforme explicacao acima.

					cTpLanc := Iif( Len( aNFItem[nZ][IT_TS][ TS_LANCFIS , nI , 1 ] ) == 10 , "2" , "1" )

					//Apenas verifico os codigos do MATXFIS caso seja Ajuste de Documento Fiscal e nao possua um Codigo de Reflexo relacionado
					If cTpLanc == "2" .And. Empty( aNFItem[nZ][IT_TS][TS_LANCFIS,nI,3] )
						lGerou := .T.
						cItem  := aNfItem[nZ,IT_ITEM]
						//000 - OPERACAO NORMAL
						If Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)=="000" .And.;
							cUfLanc $ ("MG/MA/MS/PB/SE") .And. aNfItem[nZ,IT_VALICM]>0 .And. aNfItem[nZ,IT_VALISS]==0 .and. aNfItem[nZ][IT_VALSOL]==0 .and. aNfItem[nZ][IT_VALFECP]==0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							// Outros créditos; Op.Própria; Resp.: Informativo;Apur.: Informativo; Mercadoria;Simples Nacional
						//Tratamento do FECP de SE
						ElseIf cUfLanc$("SE") .AND. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"SE70010000" .And. aNfItem[nZ][IT_VALFECP]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQFECP], aNfItem[nZ,IT_VALFECP],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Tratamento do FECP ST de SE
						ElseIf cUfLanc$("SE") .AND. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"SE71010000" .And. aNfItem[nZ][IT_VFECPST]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASESOL], aNfItem[nZ,IT_ALIQFECP], aNfItem[nZ][IT_VFECPST],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						ElseIf cUfLanc=="MG" .And. aNfCab[NF_OPERNF]=="E"  .And. aNFCab[NF_SIMPNAC] == "1" .And. aNFItem[nZ][IT_TS][TS_LFICM] == "T" .And. (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"MG10990505")
							aAdd(aGrava, {aNfItem[nZ,IT_ITEM], aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//Informativo; Op.ST; Resp.: Informativo; Apur.: Informativo; Mercadoria; Op. Normal.
						ElseIf cUfLanc=="MG" .And. aNfCab[NF_OPERNF]=="E"  .And. aNFCab[NF_SIMPNAC] == "1" .And. aNFItem[nZ][IT_TS][TS_LFICM] == "T"  .And. (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"MG91990000") .And. aNfItem[nZ,IT_VALSOL] >0
							aAdd(aGrava, {aNfItem[nZ,IT_ITEM], aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASESOL], aNfItem[nZ,IT_ALIQSOL], aNfItem[nZ,IT_VALSOL],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							// Lançamentos de Sub-apuração de ICMS.
						ElseIf Alltrim(cUfLanc)$"ES/PA" .And. SubStr(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],4,1)$"3/4/5" .And. aNfItem[nZ,IT_VALICM] >0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//001 - DIFERENCIAL ALIQUOTA (SC=002 e 003)
							//001 - ESTORNO DE CREDITO
						ElseIf ( Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)=="001" .And.;
							cUfLanc $ ("GO") .And. (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"GO50009001") .And. aNFCab[NF_SIMPNAC] == "1") .And. aNfItem[nZ,IT_VALICM] >0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//005 - ST - DIF ALIQUOTA
						ElseIf aNfItem[nZ,IT_VALCMP]>0 .And.;
							(((Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)$"001/005" .And. cUfLanc $ ("MG/MS/PB/SE")) .Or.;
							(AllTrim(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1])$"SC40000002/SC40000003")) .Or. (AllTrim(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1])$"RJ70000002"))	//Tratamento conforme codigos da tabela tb54, tb55 e tb129.
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQCMP]-aNfItem[nZ,IT_ALIQICM]- aNfItem[nZ,IT_ALIQFECP] , aNfItem[nZ,IT_VALCMP]-aNfItem[nZ,IT_VALFECP],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//002 - TRANSFERENCIA DE CREDITO
						ElseIf Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)=="002" .And.;
							cUfLanc $ ("MG/MS/PB/SE") .And. aNFItem[nZ][IT_TS][TS_TRFICM]=="1".And. aNfItem[nZ,IT_VALMERC] >0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALMERC],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						ElseIf cUfLanc $ ("RS")  .And. (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RS10009029") .And. aNfCab[NF_OPERNF]=="E" .And. aNFItem[nZ][IT_TS][TS_TRFICM]=="1"
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALMERC],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						ElseIf cUfLanc $ ("GO")  .And. (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"GO71003005|GO71003006") .And. aNfCab[NF_OPERNF]=="E"  .And. aNfItem[nZ][IT_VALSOL] >0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1",aNfItem[nZ,IT_BASESOL], aNfItem[nZ,IT_ALIQSOL], aNfItem[nZ][IT_VALSOL],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
									//004 - ANTECIPACAO TRIBUTARIA
						ElseIf Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)=="004" .And.;
							cUfLanc $ ("MA/MS/MG/PB/SE") .And. aNFItem[nZ][IT_TS][TS_ANTICMS]=="1" .And. aNfItem[nZ,IT_VALANTI] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALANTI],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//008 - ATIVO PERMANENTE
						ElseIf ( (Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)=="008" .And.;
							cUfLanc $ ("MG/MS/PB/SE")) .Or. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"PA40000001/SC40000002/AL00000004") .And. aNfItem[nZ,IT_VALCMP]>0 .And.;
							(SubStr(aNfItem[nZ,IT_CF],2,3)$"91 " .Or. SubStr(aNfItem[nZ,IT_CF],2,3)$"551")
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALCMP],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						ElseIf cUfLanc $ ("MG") .And. (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"MG10000503") .And. aNfCab[NF_OPERNF]=="E" .And.  aNfItem[nZ,IT_BASNDES] > 0  .And. aNfItem[nZ,IT_ICMNDES] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASNDES], 0, aNfItem[nZ,IT_ICMNDES],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//009 - CREDITO PRESUMIDO
						ElseIf !Empty(aNFItem[nZ][IT_TS][TS_TPCPRES]) .And. aNfItem[nZ][IT_LIVRO][LF_CRDPRES] > 0 .And. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"ES10000100"
							If aNFItem[nZ][IT_TS][TS_TPCPRES] =="C"
								aAdd(aGrava, {aNfItem[nZ,IT_ITEM], aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ][IT_LIVRO][LF_VALCONT], aNFItem[nZ][IT_TS][TS_CRDPRES], aNfItem[nZ][IT_LIVRO][LF_CRDPRES],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							ElseIf aNFItem[nZ][IT_TS][TS_TPCPRES] =="R"
								aAdd(aGrava, {aNfItem[nZ,IT_ITEM], aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNFItem[nZ][IT_TS][TS_CRDPRES], aNfItem[nZ][IT_LIVRO][LF_CRDPRES],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							EndIf
						ElseIf ( (Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)=="009" .And.;
							cUfLanc $ ("MA/MS/SE")) .Or. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"PA10000997" ) .And. aNfItem[nZ][IT_LIVRO][LF_CRDPRES] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ][IT_LIVRO][LF_VALCONT], aNFItem[nZ][IT_TS][TS_CRDPRES], aNfItem[nZ][IT_LIVRO][LF_CRDPRES],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							lGerou	:=	.T.
							//003 - COMPENSACAO DE SALDO;//004 - ANTECIPACAO TRIBUTARIA;//006 - REEMBOLSO COMERCIAL;//007 - DESCONTO PELO ICMS;//010 - LANCAMENTO EXTEMPORANEO;//011 - RESTITUICAOO DE ICMS/ST - RESSARCIMENTO;//012 - RESTITUICAOO DE ICMS/ST - ABATIMENTO;//013 - RESTITUICAOO DE ICMS/ST - CREDITAMENTO;//014 - ST - TRANSPORTE
						ElseIf(Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)=="014" .And.;
							cUfLanc == "MG".And. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"MG10001014/MG71091014/MG91001014/MG91011014/MG91021014" .And. aNfItem[nZ,IT_VALSOL]>0)
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASESOL], aNfItem[nZ,IT_ALIQSOL], aNfItem[nZ,IT_VALSOL],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//015 - ORIGEM EM AUTUACOES;//016 - ICMS - IMPORTACAO (COMBUSTIVEIS);//017 - IMPORTACAO;//018 - CRÉDITO PRESUMIDO NAS SAÍDAS DE MERCADORIAS SUBSEQUENTES À IMPORTAÇÃO
						Elseif (Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)=="018" .And.;
							cUfLanc $ ("SC") .Or. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"SC10000018") .And. aNfCab[NF_OPERNF]=="S" .And. cPrdImp == "S".And. aNfItem[nZ,IT_BASEICM] >0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], 3, aNfItem[nZ,IT_BASEICM]*3/100,cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//019 - CREDITO PRESUMIDO NAS SAIDAS DE PEIXES CRUSTACEOS E MOLUSCOS
						ElseIf ( (Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)=="019" .And.;
							cUfLanc $ ("SC")) .Or. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"SC10000019" ) .And. aNfItem[nZ][IT_LIVRO][LF_CRDPRES] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ][IT_LIVRO][LF_VALCONT], aNFItem[nZ][IT_TS][TS_CRDPRES], aNfItem[nZ][IT_LIVRO][LF_CRDPRES],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						ElseIf cUfLanc $ ("SC") .And. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"SC10000033" .And. aNfItem[nZ][IT_LIVRO][LF_CRDPRES] > 0 .And. aNfCab[NF_OPERNF]=="S"
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ][IT_LIVRO][LF_VALCONT], aNFItem[nZ][IT_TS][TS_CRDPRES], aNfItem[nZ][IT_LIVRO][LF_CRDPRES],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//023 - TRANSFERENCIA DE CREDITO ACUMULADO
						ElseIf ( Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)=="023" .And.;
							cUfLanc $ ("GO") .And. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"GO40999023") .And. aNfItem[nZ,IT_VALICM] >0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//027 - RECEBIDO EM TRANSFERENCIA
						ElseIf ( Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)=="027" .And.;
							cUfLanc $ ("GO") .And. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"GO10990027") .And. aNfItem[nZ,IT_VALICM] >0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//029 - CREDITO DE ICMS EMITIDO NA ENTRADA DE MERCADORIA ADQUIRIDA DE FORNECEDORES ENQUADRADOS NO SIMPLES NACIONAL
						ElseIf ( Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)=="029" .And.;
							cUfLanc $ ("GO") .And. (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"GO10009029") .And. aNFCab[NF_SIMPNAC] == "1") .And. aNfItem[nZ,IT_VALICM]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						ElseIf cUfLanc $ ("PA")  .And. (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"PA00000999") .And. aNfCab[NF_OPERNF]=="E" .And. aNFCab[NF_SIMPNAC] == "1" .And. aNfItem[nZ,IT_VALICM]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//034 - CREDITO PRESUMIDO NA ENTRADA DE MERCADORIA ADQUIRIDA DE FORNECEDORES ENQUADRADOS NO SIMPLES NACIONAL
						ElseIf (Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)=="034" .And.;
							(cUfLanc $ ("SC") .Or. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"SC10000034") .And. aNfCab[NF_OPERNF]=="E"  .And. aNFCab[NF_SIMPNAC] == "1" .And. aNfItem[nZ,IT_VALICM] >0)
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//999 - OUTROS AJUSTES
							//DIFERENCIAL DE ALIQUOTA SOBRE MATERIAL DE USO/CONSUMO
						ElseIf (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"MG10000504/MG20000504/PA40000002/PA70000017/PB90990018/SC40000003/ES70009702") .And. ;
							aNfItem[nZ,IT_VALCMP]>0 .And. (SubStr(aNfItem[nZ,IT_CF],2,3)$"97 " .Or. SubStr(aNfItem[nZ,IT_CF],2,3)$"556")
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALCMP],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//ESTORNO DE CREDITO
						ElseIf (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"MA50000000/MS50000000/MS40000000/MS40000999/MS50000999/PA50000999/SC50000999/SC51000999") ;
							.And. aNFItem[nZ][IT_TS][TS_ESTCRED]>0 .And. aNfItem[nZ,IT_ESTCRED]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_VALICM], aNFItem[nZ][IT_TS][TS_ESTCRED], aNfItem[nZ,IT_ESTCRED],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//ICMS DIFERIDO
						ElseIf (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"AL99999323/AL99999324/AL99999325/AL99999326/AL99999327") .And.;
							aNFItem[nZ][IT_TS][TS_PICMDIF]>0 .And. aNFItem[nZ][IT_TS][TS_PICMDIF]<>100 .And. aNfItem[nZ,IT_ICMSDIF]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_ICMSDIF],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//FECOP RN
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RN10000002") .And.;
							cUfLanc $ ("RN") .And. aNFItem[nZ][IT_TS][TS_ISEFERN]=="2" .And. aNfItem[nZ,IT_VFECPRN] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALFECRN], aNfItem[nZ,IT_VFECPRN], cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RN11000001") .And.;
							cUfLanc $ ("RN") .And. aNFItem[nZ][IT_TS][TS_ISEFERN]=="2" .And. aNfItem[nZ,IT_VFESTRN] > 0 .And. Substr(aNfItem[nZ,IT_CF],1,1)=="5"
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASESOL], aNfItem[nZ,IT_ALFECRN], aNfItem[nZ,IT_VFESTRN], cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RN11000002") .And.;
							cUfLanc $ ("RN") .And. aNFItem[nZ][IT_TS][TS_ISEFERN]=="2" .And. aNfItem[nZ,IT_VFESTRN] > 0 .And. Substr(aNfItem[nZ,IT_CF],1,1)=="2"
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASESOL], aNfItem[nZ,IT_ALFECRN], aNfItem[nZ,IT_VFESTRN], cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RN70000001") .And.;
							cUfLanc $ ("RN") .And. aNFItem[nZ][IT_TS][TS_ISEFERN]=="2" .And. aNfItem[nZ,IT_VFECPRN] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALFECRN], aNfItem[nZ,IT_VFECPRN], cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RN71000001") .And.;
							cUfLanc $ ("RN") .And. aNFItem[nZ][IT_TS][TS_ISEFERN]=="2" .And. aNfItem[nZ,IT_VFESTRN] > 0 .And. Substr(aNfItem[nZ,IT_CF],1,1)=="5"
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASESOL], aNfItem[nZ,IT_ALFECRN], aNfItem[nZ,IT_VFESTRN], cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RN71000002") .And.;
							cUfLanc $ ("RN") .And. aNFItem[nZ][IT_TS][TS_ISEFERN]=="2" .And. aNfItem[nZ,IT_VFESTRN] > 0 .And. Substr(aNfItem[nZ,IT_CF],1,1)=="2"
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASESOL], aNfItem[nZ,IT_ALFECRN], aNfItem[nZ,IT_VFESTRN], cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RN00000002") .And.;
							cUfLanc $ ("RN") .And. aNFItem[nZ][IT_TS][TS_ANTICMS]=="1" .And. aNfItem[nZ,IT_VALANTI] > 0 .And. ;
							Substr(aNfItem[nZ,IT_CF],1,1)=="2"
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASESOL], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALANTI],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RN70000003") .And.;
							cUfLanc $ ("RN") .And. aNFItem[nZ][IT_TS][TS_ANTICMS]=="1" .And. aNfItem[nZ,IT_VALANTI] > 0 .And. ;
							Substr(aNfItem[nZ,IT_CF],1,1)=="2"
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASESOL], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALANTI],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Crédito
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RN00000010") .And. cUfLanc $ ("RN") .And. aNfCab[NF_OPERNF]=="E" .And. 	aNFItem[nZ][IT_TS][TS_CREDST]<>"3" .And. ;
							Substr(aNfItem[nZ,IT_CF],1,1)=="2" .And.  aNfItem[nZ,IT_VALSOL]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASESOL], aNfItem[nZ,IT_ALIQSOL], aNfItem[nZ,IT_VALSOL],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Débitos Especiais
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RN70000005") .And. cUfLanc $ ("RN") .And. aNfCab[NF_OPERNF]=="E" .And. Substr(aNfItem[nZ,IT_CF],1,1)=="2" .And. aNfItem[nZ,IT_VALSOL] >0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASESOL], aNfItem[nZ,IT_ALIQSOL], aNfItem[nZ,IT_VALSOL],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Còdigo informativo não leva antecipação
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RN99990004") .And. cUfLanc $ ("RN").And. aNfItem[nZ,IT_VALSOL]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASESOL], aNfItem[nZ,IT_ALIQSOL], aNfItem[nZ][IT_VALSOL],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//Diferencia de alíquota de Ativo Permanente
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RN70009002") .And. cUfLanc $ ("RN") .And. aNfCab[NF_OPERNF]=="E" .And. SubStr(aNfItem[nZ,IT_CF],2,3)$"551|552|352" .And. aNfItem[nZ][IT_VALCMP] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASESOL], aNfItem[nZ][IT_ALIQSOL], aNfItem[nZ][IT_VALSOL],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Diferencia de alíquota de Serv. de Transporte
						ElseIf aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RN70001004" .And. aNfCab[NF_OPERNF]=="E"  .And. (AllTrim(aNFCab[NF_ESPECIE]) $ "CTR/CTE" .Or. "NFST"$AllTrim(aNFCab[NF_ESPECIE])) .And. aNfItem[nZ,IT_VALCMP]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASESOL], aNfItem[nZ][IT_ALIQSOL], aNfItem[nZ][IT_VALSOL],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Diferencia de alíquota de Ativo Permanente
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RN70009005") .And.	cUfLanc $ ("RN") .And. aNfCab[NF_OPERNF]=="E" .And. SubStr(aNfItem[nZ,IT_CF],2,3)$"551|552|352" .And. aNfItem[nZ][IT_VALCMP] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ][IT_ALIQICM], aNfItem[nZ][IT_VALCMP],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Diferencia de alíquota Uso e Consumo
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RN70009006") .And.	cUfLanc $ ("RN") .And. aNfCab[NF_OPERNF]=="E" .And. SubStr(aNfItem[nZ,IT_CF],2,3)$"556|557|352" .And. aNfItem[nZ][IT_VALCMP] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ][IT_ALIQICM], aNfItem[nZ][IT_VALCMP],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//CRÉDITO PRESUMIDO NA SAÍDA RONDÔNIA
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RO10000012/RO10000006/RO10000007/RO10000003") .And.	cUfLanc $ ("RO") .And. aNfCab[NF_OPERNF]=="S" .And. aNfItem[nZ][IT_LIVRO][LF_CRPRERO] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_VALICM], aNFItem[nZ][IT_TS][TS_CRPRERO], aNfItem[nZ][IT_LIVRO][LF_CRPRERO],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//Notas Fiscais de saídas com isenção - Rondônia
						Elseif (Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)$"009/016/017/068/078/083/130/021/022/037/086/116") .And.	cUfLanc $ ("RO") .And. aNfCab[NF_OPERNF]=="S" .And. aNFItem[nZ][IT_TS][TS_LFICM] $"I".And. aNfItem[nZ,IT_VALICM] >0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1",aNfItem[nZ,IT_BASEICM], aNfItem[nZ][IT_ALIQICM], aNfItem[nZ][IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//Diferencia de alíquota de Ativo Permanente
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RO40000001/ES70009701") .And.	cUfLanc $ ("RO/ES") .And. aNfCab[NF_OPERNF]=="E" .And. SubStr(aNfItem[nZ,IT_CF],2,3)$"551|552|352" .And. aNfItem[nZ][IT_VALCMP] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ][IT_ALIQICM], aNfItem[nZ][IT_VALCMP],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Redução de Base de Calculo
						Elseif (Right(aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1],nTamCC8)$"165/166/170/175/183/195") .And. cUfLanc $ ("RO") .And. aNfCab[NF_OPERNF]=="S" .And. aNFItem[nZ][IT_TS][TS_BASEICM]>0 .And. aNFItem[nZ][IT_TS][TS_LFICM] $"IO" .And. aNFItem[nZ][IT_TS][TS_CONSUMO]$"SO"
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM],aNfItem[nZ,IT_ALIQICM],aNFItem[nZ][IT_TS][TS_BASEICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Diferencial de alíquota de transporte
						ElseIf aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"ES70009703" .And. aNfCab[NF_OPERNF]=="E"  .And. (AllTrim(aNFCab[NF_ESPECIE]) $ "CTR/CTE" .Or. "NFST"$AllTrim(aNFCab[NF_ESPECIE])) .And. aNfItem[nZ,IT_VALCMP]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ][IT_ALIQICM], aNfItem[nZ][IT_VALCMP],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//Diferencia de alíquota Uso e consumo
						Elseif (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RO40000002") .And.	cUfLanc $ ("RO") .And. aNfCab[NF_OPERNF]=="E" .And. SubStr(aNfItem[nZ,IT_CF],2,3)$"556|557|352" .And. aNfItem[nZ,IT_VALCMP]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ][IT_ALIQICM], aNfItem[nZ][IT_VALCMP],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//DEBITO POR TRANSFERENCIA DE SALDO CREDOR
						ElseIf Alltrim(aNFItem[nZ][IT_CF]) $ "5601/5602" .And. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RS40009193" .And. aNfItem[nZ,IT_VALICM]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//CÓDIGOS DO ESTADO RIO GRANDE DO SUL
						//Antecipação de ICMS Rio Grande do Sul
						ElseIf aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RS10000106/RS40000313" .And. aNFItem[nZ][IT_TS][TS_ANTICMS]=="1" .And. aNfItem[nZ,IT_VALANTI] > 0 .And. aNFCab[NF_UFDEST] == "RS" .And. aNFCab[NF_UFORIGEM] <> "RS"
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALANTI],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Devolução de Mercadoria recebida pra uso e consumo
						ElseIf aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RS10000206" .And. aNfCab[NF_OPERNF]=="S" .And. aNFCab[NF_TIPONF] $ "D" .And. SubStr(aNfItem[nZ,IT_CF],2,3)$"556" .And. aNfItem[nZ][IT_VALICM] >0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1",aNfItem[nZ,IT_BASEICM], aNfItem[nZ][IT_ALIQICM], aNfItem[nZ][IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Créditos presumidos - LIVRO I, ART. 32, LXIII - LEITE FLUIDO
						ElseIf aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RS10009269" .And. aNfCab[NF_OPERNF]=="S" .And. aNFCab[NF_UFORIGEM] == "RS" .And. aNFCab[NF_UFDEST] <> "RS" .AND. aNfItem[nZ][IT_LIVRO][LF_CRDPRES] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1",aNfItem[nZ,IT_VALICM], aNFItem[nZ][IT_TS][TS_CRDPRES], aNfItem[nZ][IT_LIVRO][LF_CRDPRES],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Créditos presumidos - LIVRO I, ART. 32, CVII.LEITE DE PROD.PROP.PROD.RUR
						ElseIf aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RS10009314" .And. aNfCab[NF_OPERNF]=="E" .And. SubStr(aNfItem[nZ,IT_CF],1,1)$"1" .And. aNfItem[nZ][IT_LIVRO][LF_CRDPRES] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1",aNfItem[nZ,IT_VALICM], aNFItem[nZ][IT_TS][TS_CRDPRES], aNfItem[nZ][IT_LIVRO][LF_CRDPRES],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						ElseIf aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RS10009906" .And. aNfCab[NF_OPERNF]=="E" .AND. cUfLanc $ ("RS") .And. !aNFItem[nZ][IT_TS][TS_LFICM]=="Z" .And. aNfItem[nZ][IT_VALICM] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1",aNfItem[nZ,IT_BASEICM], aNfItem[nZ][IT_ALIQICM], aNfItem[nZ][IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//DÉBITOS POR RESPONSABILIDADE - ICMS DIFERIDO DO DOCUMENTO DE SAÍDA
						ElseIf aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RS40000010" .And. aNfCab[NF_OPERNF]=="S" .AND. cUfLanc $ ("RS") .And. aNfItem[nZ][IT_ICMSDIF] >0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1",0, 0, aNfItem[nZ][IT_ICMSDIF],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//Diferencial de Aliquota calculado na Entrada de Outros Débitos
						ElseIf (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RS40000113") .And. aNfItem[nZ,IT_VALCMP]>0 .And. aNfCab[NF_OPERNF]=="E" .And. aNfCab[NF_UFORIGEM] <> "RS"
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM],aNfItem[nZ,IT_ALIQCMP] - aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALCMP],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//Diferencial de Aliquota calculado na Entrada de Débitos Especiais
						ElseIf (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"MG70001001") .And. aNfItem[nZ,IT_VALCMP]>0 .And. aNfCab[NF_OPERNF]=="E" .And. aNfCab[NF_UFORIGEM] <> "MG"
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALCMP],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
							//Outros Débitos
						ElseIf aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"ES40000400" .And.  aNfItem[nZ,IT_VALICM] >0
							aAdd(aGrava, {aNfItem[nZ,IT_ITEM], aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						// Códigos do RS onde o débito se dá por uma nota fiscal emitida no final do período
						ElseIf aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RS40000213/RS40001010/RS40009913/RS40000010/RS41009705" .And. aNfCab[NF_OPERNF]=="S" .And. aNFItem[nZ][IT_TS][TS_LFICM]=="Z" .And. aNfItem[nZ,IT_VALMERC]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1",0, 0, aNfItem[nZ][IT_VALMERC],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						// Códigos do RS onde o crédito se dá por uma nota fiscal emitida no final do período
						ElseIf aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RS10009906/RS10009269/RS10000106/RS10009314/RS10000206/" .And. aNfCab[NF_OPERNF]=="E" .And. aNFItem[nZ][IT_TS][TS_LFICM]=="Z" .And. aNfItem[nZ,IT_VALMERC]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1",0, 0, aNfItem[nZ][IT_VALMERC],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Debitos Especiais; Op.ST; Resp.:propria; Apur.:Recolhimento espontaneo; Mercadoria;ST interna
						//Débitos especiais; Op. ST; Resp. Solidária, Apur.; Recolhimento Espontâneo. Mercadoria; Op. Normal.
						ElseIf cUfLanc=="MG" .And. (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"MG71010501/MG71110000")  .And. aNfItem[nZ][IT_VALSOL] >0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1",0, 0, aNfItem[nZ][IT_VALSOL],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						ElseIf cUfLanc=="ES".And. aNfCab[NF_OPERNF]=="E" .And. aNfCab[NF_UFORIGEM] <> "ES" .And. (aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"ES71000712") .And. aNFItem[nZ][IT_TS][TS_ANTICMS]=="1" .And. aNfItem[nZ,IT_VALANTI] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALANTI],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//"Créditos por Transferência" - LIVRO I,ART.59,I,"A" -ESTABELECIMENTO MESMA EMPRESA - Saída
						ElseIf cUfLanc$("RS") .AND. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RS10009004" .And. aNfCab[NF_OPERNF]=="S"
							aAdd(aGrava, {aNfItem[nZ,IT_ITEM], aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", 0, 0, aNfItem[nZ,IT_VALMERC], cSeq, cIFCOMP, cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//"Créditos por Transferência" - LIVRO I, ART.58, II, NOTA01, B, E ART.58, II, "A" do RICMS/RS - Entrada
						ElseIf cUfLanc$("RS") .AND. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RS10009031" .And. aNfCab[NF_OPERNF]=="E"
							aAdd(aGrava, {aNfItem[nZ,IT_ITEM], aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", 0, 0, aNfItem[nZ,IT_VALMERC], cSeq, cIFCOMP, cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//"Ressarcimento de ICMS ST decorrente da venda para contribuinte localizado em outra unidade da fereção
						ElseIf cUfLanc$("SC") .AND. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"SC11000002" .And. aNfCab[NF_OPERNF]=="S" .And. SubStr(aNfItem[nZ,IT_CF],1,1)$"6" .And. aNfItem[nZ,IT_VALSOL]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASESOL], aNfItem[nZ,IT_ALIQSOL], aNfItem[nZ,IT_VALSOL],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Crédito proporcional a mercadoria recebida com ST quando efetuada nova retenção
						ElseIf cUfLanc$("SC") .AND. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"SC10000030" .And. aNfCab[NF_OPERNF]=="E"  .And. aNFItem[nZ][IT_TS][TS_SITTRIB]=="60" .And. aNfItem[nZ,IT_VALICM] >0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//ICMS devido na importação
						ElseIf cUfLanc$("SC") .AND. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"SC70000005" .And. aNfCab[NF_OPERNF]=="E" .And. SubStr(aNfItem[nZ,IT_CF],1,1)$"3" .And. aNfItem[nZ,IT_VALICM] >0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Crédito presumido na saída de mercadorias importadas do exterior
						ElseIf cUfLanc$("SC") .AND. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"SC10000013" .And. aNfCab[NF_OPERNF]=="S" .And. aNfItem[nZ][IT_LIVRO][LF_CRDPRES] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNFItem[nZ][IT_TS][TS_CRDPRES], aNfItem[nZ][IT_LIVRO][LF_CRDPRES],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Estorno de Débito - Produtos Primários - ICMS recolhido antecipadamente
						ElseIf cUfLanc$("RO") .AND. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RO20000002" .And. aNfCab[NF_UFORIGEM]=="RO" .And. aNfCab[NF_OPERNF]=="S" .And. aNFItem[nZ][IT_TS][TS_SITTRIB]$"10/60" .And. aNfItem[nZ,IT_VALICM] >0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALICM],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//ICMS devido pelo remetente relativo ao servico de transportadora de outra UF, RICM - art. 220, I
						ElseIf cUfLanc$("ES") .AND. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"ES70001706" .And. aNfCab[NF_UFORIGEM]=="ES" .And. aNfCab[NF_OPERNF]=="S" .And. SubStr(aNfItem[nZ,IT_CF],1,1)$"6" .And. aNfItem[nZ,IT_AUTONOMO] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICA], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALICA],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Débito de ICMS devido pela entrada de mercadorias sujeitas ao regime de substituição tributária
						ElseIf aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"SC41000002" .AND. aNFCab[NF_OPERNF] == "E" .AND. aNFItem[nZ][IT_TS][TS_ANTICMS] == "1" .AND. SubStr(aNfItem[nZ,IT_CF],1,1)$"2" .And. aNfItem[nZ,IT_VALANTI] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALANTI],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//"Outros débitos" do ICMS ST, tais os débitos do RICMS, Livro III, arts. 53-A e 53-C
						ElseIf aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RS41009705" .AND. aNFCab[NF_OPERNF] == "E" .AND. aNFItem[nZ][IT_TS][TS_ANTICMS] == "1" .AND. SubStr(aNfItem[nZ,IT_CF],1,1)$"2/3" .And. aNfItem[nZ,IT_VALANTI] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALANTI],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						ElseIf aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RS41009705" .AND. aNFCab[NF_OPERNF] == "E" .AND. aNFItem[nZ][IT_TS][TS_COMPL]=="S" .AND. SubStr(aNfItem[nZ,IT_CF],1,1)$"2/3" .And. aNfItem[nZ,IT_VALCMP] > 0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM], aNfItem[nZ,IT_VALCMP],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Diferencial de alíquota FECP Rio de Janeiro
						ElseIf cUfLanc$("RJ") .AND. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RJ70000006" .AND. aNFCab[NF_OPERNF] == "E" .And. aNfItem[nZ][IT_VALFECP]>0 .AND. aNfItem[nZ,IT_VALCMP]>0
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQFECP], aNfItem[nZ,IT_VALFECP],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Fecp na Importação para o Rio de Janeiro
						ElseIf cUfLanc$("RJ") .AND. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RJ70000005".AND. aNFCab[NF_OPERNF] == "E" .And. aNfItem[nZ][IT_VALFECP]>0 .AND. SubStr(aNfItem[nZ,IT_CF],1,1)$"3"
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQFECP], aNfItem[nZ,IT_VALFECP],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Valor de ICMS na operação de importação para o Estado do Rio de Janeiro.
						ElseIf cUfLanc$("RJ") .AND. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"RJ70000001".AND. aNFCab[NF_OPERNF] == "E" .And. aNfItem[nZ][IT_VALICM]>0 .AND. SubStr(aNfItem[nZ,IT_CF],1,1)$"3"
							aAdd(aGrava, {cItem, aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1], "1", aNfItem[nZ,IT_BASEICM], aNfItem[nZ,IT_ALIQICM]-aNfItem[nZ,IT_ALIQFECP], aNfItem[nZ,IT_VALICM]-aNfItem[nZ,IT_VALFECP],cSeq,cIFCOMP,cTpLanc,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						//Deducoes do FECOMP - MS
						ElseIf cUfLanc$("MS") .And. aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]$"MS60000011" .And. aNfItem[nZ][IT_VALICM]>0 .And. aNfItem[nZ][IT_VALFECP]>0
							aAdd(aGrava, { cItem , aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1] , "1" , aNfItem[nZ,IT_BASEICM] , aNfItem[nZ,IT_ALIQFECP] , aNfItem[nZ,IT_VALFECP] , cSeq , cIFCOMP , cTpLanc ,"",cCmp0460,cCodRefl,cGeraGNRE,cCMPOrig})
						Else
							lGerou	:= .F.
						EndIf
					Else
						//Tratamento para:
						//Estados sem a publicação de tabela de ajustes de ICMS ou;
						//Codigos de Ajuste de Apuracao com Reflexo relacionado ou;
						//Novo mecanismo de configuracao para Codigos de Ajuste de NF
						If aDic[AI_CE0]
							CE0->(dbSetOrder(1))

							//O campo CC7_CODREF podera ser utilizado em qualquer tipo de Codigo (Apuracao ou de NF). Portanto, sempre que
							//este campo for preenchido (posicao 3 do array TS_LANCFIS) devera ser priorizado na consulta a tabela CE0.
							If !Empty( aNFItem[nZ][IT_TS][TS_LANCFIS,nI,3] )
								If CE0->( DbSeek( xFilial( "CE0" ) + aNFItem[nZ][IT_TS][TS_LANCFIS,nI,3] ) )
									lHasRefl	:=	.T.
								Endif

							//Quando nao utilizar o campo CC7_CODREF, para os codigos de Apuracao ainda existe a possibilidade do reflexo
							//ter sido associado atraves do campo CDO_CODREF (que esta no proprio cadastro do Ajuste).
							Elseif cPaisLoc == "BRA" .And. cTpLanc == '1'
								If aPos[FP_CDO_CODREF]
									CDO->(dbSetOrder(1))
									If CDO->( MsSeek( xFilial( "CDO" ) + aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1] ) )
										If CE0->( DbSeek( xFilial( "CE0" ) + CDO->CDO_CODREF ) )
											lHasRefl	:=	.T.
										Endif
									Endif
								Endif
							Endif
							If lHasRefl
								aParam	:= array(17)
								aParam[1] := aNFItem[nZ][IT_TS][TS_LANCFIS,nI,1]
								aParam[2] := cSeq
								aParam[3] := cIFCOMP
								aParam[4] := cTpLanc
								aParam[5] := cCmp0460
								aParam[6] := cCodRefl
								aParam[7] := cGeraGNRE
								aParam[8] := cCMPOrig
								aParam[9] := ""
								aParam[10] := ""
								aParam[11] := ""
								aParam[12] := AllTrim(CE0->CE0_NFBASE)
								aParam[13] := AllTrim(CE0->CE0_NFALIQ)
								aParam[14] := Alltrim(CE0->CE0_NFVALO)
								aParam[15] := CE0->CE0_NFALVA
								aParam[16] := Iif(aPos[FP_CE0_VL197],CE0->CE0_VL197,"")
								aParam[17] := Iif(aPos[FP_CE0_TRGEN],CE0->CE0_TRGEN,"")

								lGerou := xMaCalcRefl(aGrava,nZ,aParam,aNfItem,aNfCab,aSX6)
							Endif
						Endif
					EndIf
				EndIf
			Endif
		Next nI

		//Processa Códigos Declaratorios
		xMaCodDecl(nZ, aNfItem, aNfCab, aSX6, aPos, aDic, aPE)
		For nX := 1 To Len(aNFItem[nZ][IT_CODDECL])
		
			If (aScan(aGrava, {|x| AllTrim(x[1]) == AllTrim(aNfItem[nZ,IT_ITEM]) .And. AllTrim(x[2]) == AllTrim(aNFItem[nZ][IT_CODDECL,nX,1]) .And. AllTrim(x[8]) == "CONFIG" }) == 0 )

				lHasRefl	:=	.F.
				//Verifica qual eh a UF do codigo de ajuste corrente
				cUfLanc  := Substr(aNFItem[nZ][IT_CODDECL,nX,1],1,2)
				cCodRefl :=	aNFItem[nZ][IT_CODDECL,nX,3]
				cCMPOrig := aNFItem[nZ][IT_CODDECL,nX,6]
				cTpLanc	 := ""
				//Verifica a origem do F3K se é para gravar CDA ou CDV
				cCmp0460 := Iif(aNFItem[nZ][IT_CODDECL,nX,6]=="4",aNFItem[nZ][IT_CODDECL,nX,2],aNFItem[nZ][IT_CODDECL,nX,7])
				cIFCOMP  := aNFItem[nZ][IT_CODDECL,nX,8]
				cGeraGNRE:= ""

				//Verifica se a UF do codigo de ajuste corresponde a UF do MV_ESTADO
				If cUfLanc $ aSX6[MV_ESTADO] .And. !Empty(cCodRefl)

					If aDic[AI_CE0]
						CE0->(dbSetOrder(1))
						If CE0->( MsSeek( xFilial( "CE0" ) + aNFItem[nZ][IT_CODDECL,nX,3] ) )
							lHasRefl	:=	.T.
						Endif
						If lHasRefl
							//Captura o proximos codigo de sequencia a ser utilizado
							If Len(aGrava) > 0
								nPosSeq	 :=	7
								aBkpaCls :=	aClone(aGrava)
								aSort(aBkpaCls,,,{|aX,aY| aX[nPosSeq]<aY[nPosSeq]})
								cSeq :=	aBkpaCls[Len(aBkpaCls),nPosSeq]
								cSeq := Soma1(cSeq)
							EndIf

							aParam	:= array(17)
							aParam[1] := aNFItem[nZ][IT_CODDECL,nX,1]
							aParam[2] := cSeq
							aParam[3] := cIFCOMP
							aParam[4] := cTpLanc
							aParam[5] := cCmp0460
							aParam[6] := cCodRefl
							aParam[7] := cGeraGNRE
							aParam[8] := cCMPOrig
							aParam[9] := aNFItem[nZ][IT_CODDECL,nX,4]
							aParam[10] := aNFItem[nZ][IT_TS][TS_NRLIVRO]
							aParam[11] := aNFItem[nZ][IT_CODDECL,nX,2]
							aParam[12] := AllTrim(CE0->CE0_NFBASE)
							aParam[13] := AllTrim(CE0->CE0_NFALIQ)
							aParam[14] := Alltrim(CE0->CE0_NFVALO)
							aParam[15] := CE0->CE0_NFALVA
							aParam[16] := Iif(aPos[FP_CE0_VL197],CE0->CE0_VL197,"")
							aParam[17] := Iif(aPos[FP_CE0_TRGEN],CE0->CE0_TRGEN,"")							

							lGerou := xMaCalcRefl(aGrava,nZ,aParam,aNfItem,aNfCab,aSX6)
						Endif
					Endif
				Endif
			Endif	
		Next nX
	Next nZ
EndIf

FreeObj(oJCodRef)
RestArea(aArea)

Return aGrava


/*/{Protheus.doc} xMaCodDecl()
Função que fará enquadramento da tabela F3K para calcular Valores Declaratorios
@author Rafael.Soliveira
20/04/2018
/*/
function xMaCodDecl(nItem, aNfItem, aNfCab, aSX6, aPos, aDic, aPE)
Local aArea    	:= GetArea()
Local aAreaF3K  := F3K->(GetArea())
Local cAliasQry	:= ""
Local lGrupos	:= aNfCab[NF_CODDECL] == "2"
Local cCST		:= Padr(SubStr(aNfItem[nItem][IT_CLASFIS],2,2),GTamMxFis(TAM_F3K_CST))
Local cCfop		:= Padr(aNfItem[nItem][IT_CF],GTamMxFis(TAM_F3K_CFOP))
Local cProduto	:= Padr(aNfItem[nItem][IT_PRODUTO],GTamMxFis(TAM_F3K_PROD))
Local lNewCpo	:= aPos[FP_F3K_GRCLAN] .And. aPos[FP_F3K_GRPLAN] .And. aPos[FP_F3K_GRFLAN] .And. aPos[FP_F3K_IFCOMP] .And. aPos[FP_F3K_CODLAN] .And. aDic[AI_CC6]

/*
aNfCab[NF_CODDECL] == "0" - Nao possui tratamento para tabela F3k
aNfCab[NF_CODDECL] == "1" - Possui tratamento para tabela F3K, sem os campos para tratamento de grupos
aNfCab[NF_CODDECL] == "2" - Possui tratamento para tabela F3K, com os campos para tratamento de grupos
*/
//Se não for top, não executa
#IFNDEF TOP
	Return
#ENDIF

If aNfCab[NF_CODDECL] == "0"
	Return
EndIf

//Valida se possui estrutura para calcular valor Declaratorio
If  Empty(aNfCab[NF_CODDECL])
	IF !aSX6[MV_GIAEFD] .And. aDic[AI_F3K] .And. aDic[AI_CDV] .And. aPos[FP_F3K_CODREF] .And. aPos[FP_F3K_CST] .And. ;
		aPos[FP_CDV_NUMITE] .And. aPos[FP_CDV_SEQ] .And. aPos[FP_CDV_TPMOVI]
		aNfCab[NF_CODDECL] := "1"
		If	Alltrim(aSX6[MV_MTCLF3K]) == "1"  .And. lNewCpo
			aNfCab[NF_CODDECL] := "2"
		EndIf
	Else
		aNfCab[NF_CODDECL] := "0"
		RestArea(aArea)
		Return
	Endif
Endif

//Validando se ja foi feito alguma vez o enquadramento na F3K e se algum valor do item mudou para repetir o enquadramento
If	(aNfItem[nItem][IT_CDDECL_AJU][CD_PRODUTO] <> aNfItem[nItem][IT_PRODUTO]) .Or. (aNfItem[nItem][IT_CDDECL_AJU][CD_CFOP] <> aNfItem[nItem][IT_CF]) .Or.;
	(aNfItem[nItem][IT_CDDECL_AJU][CD_CST] <> aNfItem[nItem][IT_CLASFIS]) .Or. (aNfItem[nItem][IT_CDDECL_AJU][CD_CODCLIFOR] <> aNfCab[NF_CODCLIFOR]) .Or.;
	(aNfItem[nItem][IT_CDDECL_AJU][CD_CLIFOR] <> aNfCab[NF_CLIFOR])

	aNFItem[nItem][IT_CODDECL] := {}

	F3K->(DbSetOrder(2)) //F3K_FILIAL+F3K_PROD+F3K_CFOP+F3K_CST

	//Para evitar um excesso de execuções da QryCdVlDec(), quando a busca for por um produto específico, será feito primeiro um seek na F3K.
	If lGrupos .Or. aPE[PE_MAVLDCQry] .Or. (!lGrupos .And. F3K->(MsSeek(xFilial("F3K")+cProduto+cCfop+cCST))) 

		cAliasQry	:= QryCdVlDec(nItem, aNfItem, aNfCab, aPos, aSX6, aPE, cProduto, cCfop, cCST)

		Do While !(cAliasQry)->(Eof())
			//Codigo valor declaratorio, preencher array para gravar a CDV
			aAdd( aNFItem[nItem][IT_CODDECL] ,;
				{(cAliasQry)->F3K_CODAJU,;  // 1 - Codigo do Valor Declaratorio
				(cAliasQry)->CDY_DESCR,; 	// 2 - Descricao Código
				(cAliasQry)->F3K_CODREF,;   // 3 - Codigo do Reflexo
				(cAliasQry)->F3K_CFOP,;     // 4 - CFOP
				(cAliasQry)->F3K_CST,;      // 5 - CST ICMS
				"4",;						// 6 - ORIGEM
				"",;						// 7 - 0460
				""})						// 8 - IFCOMP

			//Codigo de ajuste, preencher array para gravar a CDA
			If aNfCab[NF_CODDECL] == "2" .Or. (aNfCab[NF_CODDECL] == "1" .And. lNewCpo)
				If !Empty((cAliasQry)->F3K_CODLAN)
					aAdd( aNFItem[nItem][IT_CODDECL] ,;
						{(cAliasQry)->F3K_CODLAN,;  // 1 - Codigo de Ajuste
						"",;					 	// 2 - Descricao Código
						(cAliasQry)->F3K_CODREF,;   // 3 - Codigo do Reflexo
						(cAliasQry)->F3K_CFOP,;     // 4 - CFOP
						(cAliasQry)->F3K_CST,;      // 5 - CST ICMS
						"5",;      					// 6 - ORIGEM
						(cAliasQry)->F3K_CODAJU,;   // 7 - 0460
						(cAliasQry)->F3K_IFCOMP})   // 8 - IFCOMP
				EndIf
			EndIf
			(cAliasQry)->(DbSKip())
		Enddo
		//Fecha o Alias antes de sair da função
		(cAliasQry)->(DbCloseArea())
	EndIf
EndIf

RestArea(aAreaF3K)
RestArea(aArea)

Return

/*/{Protheus.doc} xMaCalcRefl()
Função que Calculo do Reflexo
@author Rafael.Soliveira
20/04/2018
/*/
Function xMaCalcRefl(aGrava, nZ, aParam, aNfItem,aNfCab,aSX6)

Local cBase		:= aParam[12] //CE0_NFBASE
Local cAliq		:= aParam[13] //CE0_NFALIQ
Local cValor	:= aParam[14] //CE0_NFVALO
Local nAliqVal	:= aParam[15] //CE0_NFALVA
Local cVL197	:= aParam[16] //CE0_VL197
Local nValor	:= 0
Local nBase		:= 0
Local nAliq		:= 0
Local lGerou	:= .F.
Local cTrbGen  	:= aParam[17] //CE0_TRGEN
Local nPosGen  	:= 0

If aSX6[MV_ULTAQUI] $ "1/2/3" .And. ( (aNfCab[NF_OPERNF]=="S" .AND. aNFCab[NF_CLIFOR]=="C") .OR. (aNFCab[NF_TIPONF] $ "DB" )) .And. (aNFCab[NF_TPCLIFOR] == "F") .And. (Substr(aNfItem[nZ][IT_CLASFIS],2,2) == "60".or. aNfItem[nZ][IT_CSOSN]=="500")
	FISXULTENT(nZ, aNfItem, aNfCab, aSX6, "IT_QUANT",.T.)
Endif

//Case para definir o valor da Base de Calculo do ajuste
Do Case
	Case cBase == '1'	; nBase	:=	aNfItem[ nZ , IT_BASEICM]
	Case cBase == '2'	; nBase	:=	aNfItem[ nZ , IT_LIVRO, LF_VALCONT]
	Case cBase == '3'	; nBase	:=	aNfItem[ nZ , IT_VALICM]
	Case cBase == '4'	; nBase	:=	aNfItem[ nZ , IT_BASESOL]
	Case cBase == '5'	; nBase	:=	aNfItem[ nZ , IT_BASEICA]
	Case cBase == '6'	; nBase	:=	aNfItem[ nZ , IT_LIVRO, LF_CRDEST]
	Case cBase == '7'	; nBase	:=	aNfItem[ nZ , IT_BASEDES]
	Case cBase == '8'	; nBase	:=	aNfItem[ nZ , IT_BICMORI]
	Case cBase == '9'	; nBase	:=	aNfItem[ nZ , IT_BASEIPI]
	Case cBase == 'A'	; nBase	:=	aNfItem[ nZ , IT_BASETST]
	Case cBase == 'B'	; nBase	:=	aNfItem[ nZ , IT_VALTST]
	Case cBase == 'C'	; nBase	:=	aNfItem[ nZ , IT_LIVRO, LF_BICMORI] - aNfItem[ nZ , IT_BASEICM ]
	Case cBase == 'D'	; nBase	:=	aNfItem[ nZ , IT_BASFEEF]
	Case cBase == 'E'  ; nBase :=  IIf((nPosGen := aScan(aNFItem[nZ][IT_TRIBGEN], {|x| AllTrim(x[TG_IT_SIGLA]) == AllTrim(cTrbGen)})) > 0, aNFItem[nZ][IT_TRIBGEN][nPosGen][TG_IT_BASE], 0)
	Case cBase == 'F'  ; nBase :=  IIf((nPosGen := aScan(aNFItem[nZ][IT_TRIBGEN], {|x| AllTrim(x[TG_IT_SIGLA]) == AllTrim(cTrbGen)})) > 0, aNFItem[nZ][IT_TRIBGEN][nPosGen][TG_IT_VALOR], 0)
	Case cBase == 'G'	; nBase	:=	aNfItem[ nZ , IT_BICEFET]
	Case cBase == 'H'	; nBase	:=	aNfItem[ nZ , IT_VALIPI]
	Case cBase == 'I'	; nBase	:=	aNfItem[ nZ , IT_BASNDES]
	Case cBase == 'J'	; nBase	:=	aNfItem[nZ][IT_DESCZF]
	Case cBase == 'K'	; nBase	:=	aNfItem[nZ][IT_DESCZF] - (aNfItem[nZ][IT_DESCZFPIS] + aNfItem[nZ][IT_DESCZFCOF])
	Case cBase == 'Z'	; nBase	:=	0
EndCase

//Case para definir o valor da Aliquota do ajuste
Do Case
	Case cAliq == '1'	; nAliq	:=	aNfItem[ nZ , IT_ALIQICM ]
	Case cAliq == '2'	; nAliq	:=	aNFItem[nZ][IT_TS][ TS_CRDPRES ]
	Case cAliq == '3'	; nAliq	:=	aNfItem[ nZ , IT_ALIQSOL ]
	Case cAliq == '4'	; nAliq	:=	aNFItem[nZ][IT_TS][ TS_ESTCRED ]
	Case cAliq == '5'	; nAliq	:=	aNfItem[ nZ , IT_ALIQCMP ] - aNfItem[ nZ, IT_ALIQICM ] - Iif( aNfItem[ nZ , IT_ALFCCMP ] > 0 , aNfItem[ nZ , IT_ALFCCMP ] , aNfItem[ nZ , IT_ALIQFECP ] )
	Case cAliq == '6'	; nAliq	:=	nAliqVal
	Case cAliq == '7'	; nAliq	:=	Iif( aNfItem[ nZ , IT_ALFCCMP ] > 0 , aNfItem[ nZ , IT_ALFCCMP ] , aNfItem[ nZ , IT_ALIQFECP ] + aNfItem[nZ, IT_ALFECMG] + aNfItem[nZ, IT_ALFECRN ] + aNfItem[nZ, IT_ALFECMT ] )
	Case cAliq == '8'	; nAliq	:=	aNfItem[ nZ , IT_ALFCST ] + aNfItem[nZ, IT_ALFECMG]	+ aNfItem[nZ, IT_ALFECRN ] + aNfItem[nZ, IT_ALFECMT ]
	Case cAliq == '9'	; nAliq	:=	aNfItem[ nZ , IT_ALIQCMP ] - aNfItem[ nZ , IT_ALIQDIF] - Iif( aNfItem[ nZ , IT_ALFCCMP ] > 0 , aNfItem[ nZ , IT_ALFCCMP ] , aNfItem[ nZ , IT_ALIQFECP ] )
	Case cAliq == 'A'	; nAliq	:=	aNfItem[ nZ , IT_ALIQIPI ]
	Case cAliq == 'B'	; nAliq	:=	aNfItem[ nZ , IT_ALIQTST]
	Case cAliq == 'C'	; nAliq	:=	aNfItem[ nZ , IT_ALQFEEF]
	Case cAliq == 'D' ; nAliq :=  IIf((nPosGen := aScan(aNFItem[nZ][IT_TRIBGEN], {|x| AllTrim(x[TG_IT_SIGLA]) == AllTrim(cTrbGen)})) > 0, aNFItem[nZ][IT_TRIBGEN][nPosGen][TG_IT_ALIQUOTA], 0)
	Case cAliq == 'E'	; nAliq	:=	aNfItem[ nZ , IT_PICEFET]
	Case cAliq == 'F'	; nAliq	:=  (aNfItem[ nZ , IT_ALIQICM ] - (aNfItem[ nZ , IT_ALIQFECP ] + aNfItem[nZ, IT_ALFECMG] + aNfItem[nZ, IT_ALFECRN ] + aNfItem[nZ, IT_ALFECMT ]))
	Case cAliq == 'G'	; nAliq	:=	aNfItem[ nZ , IT_ALQNDES]
	Case cAliq == 'H'	; nAliq	:=	Iif(!Empty(aNFitem[nz,IT_EXCECAO]) .And. aNFItem[nz,IT_EXCECAO,34] > 0, aNFItem[nz,IT_EXCECAO,34], Iif( aNfItem[nz][IT_UFXPROD][UFP_ALANTICMS] > 0, aNfItem[nz][IT_UFXPROD][UFP_ALANTICMS],0))
	Case cAliq == 'I'	; nAliq :=	aNfItem[ nZ , IT_ALIQCMP]
	Case cAliq == 'Z'	; nAliq :=	0
EndCase

//Case para definir o valor do ajuste
Do Case
	Case cValor == '1' ; nValor	:= aNfItem[ nZ , IT_VALICM ]
	Case cValor == '2' ; nValor	:= aNfItem[ nZ , IT_VALCMP ] - aNfItem[ nZ,IT_VALFECP ]
	Case cValor == '3' ; nValor	:= aNfItem[ nZ , IT_VALMERC ]
	Case cValor == '4' ; nValor	:= aNfItem[ nZ , IT_VALANTI ]
	Case cValor == '5' ; nValor	:= aNfItem[ nZ , IT_LIVRO , LF_CRDPRES ]
	Case cValor == '6' ; nValor	:= aNfItem[ nZ , IT_VALSOL ]
	Case cValor == '7' ; nValor	:= aNfItem[ nZ , IT_ESTCRED ]
	Case cValor == '8' ; nValor	:= aNfItem[ nZ , IT_ICMSDIF ]
	Case cValor == '9' ; nValor	:= nBase * (nAliq / 100)
	Case cValor == 'A' ; nValor	:= aNfItem[ nZ , IT_VALFECP ] + aNfItem[ nZ , IT_VFECPMG ] + aNfItem[ nZ , IT_VFECPRN ] + aNfItem[ nZ , IT_VFECPMT ]
	Case cValor == 'B' ; nValor	:= aNfItem[ nZ , IT_VFECPST ] + aNfItem[ nZ , IT_VFESTMG ] + aNfItem[ nZ , IT_VFESTRN ] + aNfItem[ nZ , IT_VFESTMT ]
	Case cValor == 'C' ; nValor	:= aNfItem[ nZ , IT_VALICA ]
	Case cValor == 'D' ; nValor	:= aNfItem[ nZ , IT_DIFAL ]
	Case cValor == 'E' ; nValor	:= aNfItem[ nZ , IT_VALCMP ]
	Case cValor == 'F' ; nValor	:= aNfItem[ nZ , IT_VFCPDIF]
	Case cValor == 'G' ; nValor	:= aNfItem[ nZ , IT_VLSLXML] - aNfItem[ nZ , IT_VALSOL]
	Case cValor == 'H' ; nValor	:= aNfItem[ nZ , IT_VALSOL] - aNfItem[ nZ , IT_VALANTI]
	Case cValor == 'J' ; nValor	:= aNfItem[ nZ , IT_VALICM ] - aNfItem[ nZ , IT_LIVRO , LF_CRDPRES ]
	Case cValor == 'K' ; nValor	:= aNfItem[ nZ , IT_VALIPI ]
	Case cValor == 'L' ; nValor	:= aNfItem[ nZ , IT_VALTST]
	Case cValor == 'M' ; nValor	:= (aNfItem[nZ , IT_LIVRO, LF_BICMORI] - aNfItem[ nZ , IT_BASEICM ]) * aNfItem[ nZ , IT_ALIQICM ] / 100
	Case cValor == 'N' ; nValor := IIf((nPosGen := aScan(aNFItem[nZ][IT_TRIBGEN], {|x| AllTrim(x[TG_IT_SIGLA]) == AllTrim(cTrbGen)})) > 0, aNFItem[nZ][IT_TRIBGEN][nPosGen][TG_IT_VALOR], 0)
	Case cValor == 'O' ; nValor	:= aNfItem[ nZ , IT_LIVRO , LF_ISENICM ]
	Case cValor == 'P' ; nValor	:= aNfItem[ nZ , IT_LIVRO , LF_VALCONT ]
	Case cValor == 'Q' ; nValor	:= aNfItem[ nZ , IT_LIVRO , LF_OUTRICM ]
	Case cValor == 'R' ; nValor	:= aNfItem[ nZ , IT_LIVRO , LF_CPPRODE ]
	Case cValor == 'S' ; nValor	:= aNfItem[ nZ , IT_VALFEEF ]
	Case cValor == 'T' ; nValor	:= Iif(aNFCab[NF_OPERNF] == "S", aNfItem[nZ][IT_VSTANT] , aNfItem[ nZ,  IT_ICMNDES] )
	Case cValor == 'U' ; nValor	:= aNfItem[ nZ , IT_VICEFET]
	Case cValor == 'V' ; nValor	:= aNfItem[ nZ , IT_VALSOL] + aNfItem[ nZ , IT_VALICM ]
	Case cValor == 'W' ; nValor	:= aNfItem[ nZ , IT_ICMNDES] + aNfItem[ nZ , IT_VALICM ]
	Case cValor == 'X' ; nValor	:= aNfItem[ nZ , IT_VALICM ] - (aNfItem[ nZ , IT_VALMERC ] * (aNFItem[nZ][IT_TS][TS_CRDPRES] / 100))
	Case cValor == 'Y' ; nValor	:= (aNfItem[ nZ , IT_VALICM ] - (aNfItem[ nZ , IT_VALFECP ] + aNfItem[ nZ , IT_VFECPMG ] +  aNfItem[ nZ , IT_VFECPRN ] +  aNfItem[ nZ , IT_VFECPMT ]))
	Case cValor == 'Z' ; nValor := aNfItem[ nZ , IT_ICMDESONE ]
	Case cValor == 'AA'; nValor := aNfItem[ nZ , IT_ICMDESST ]
	Case cValor == 'AB'; nValor	:= aNfItem[ nZ , IT_DESCZF]
    Case cValor == 'AC'; nValor	:= aNfItem[ nZ , IT_DESCZF] - (aNfItem[nZ , IT_DESCZFPIS] + aNfItem[nZ , IT_DESCZFCOF])
	Case cValor == 'AD'; nValor	:= Iif(aNFCab[NF_OPERNF] == "S", (aNfItem[ nZ , IT_LIVRO , LF_OUTRICM ] - aNfItem[nZ][IT_VSTANT] ) , (aNfItem[ nZ , IT_LIVRO , LF_OUTRICM ] - aNfItem[ nZ,  IT_ICMNDES] ) )
EndCase

// Tratamento para issue https://jiraproducao.totvs.com.br/browse/DSERFIS1-20559, onde preciso gerar um CDA com aliq 0,01
// Adicionado tratamento para a ISSUE https://jiraproducao.totvs.com.br/browse/DSERFISE-83. Caso o cliente tenha definido na TES um percentual
// de diferimento e o valor do diferimento for zero será gerada a CDV com valor de diferimento zerado.
If nValor > 0 .Or. (nBase == 0 .And. nAliq > 0) .Or. cValor == 'I' .Or. ; // cValor == 'I' ->Ressarcimento  
	(cValor == '8' .and. nBase > 0 .and. aNfItem[nZ][IT_VOPDIF] > 0) // cValor == '8' ->  Quando houver diferimento e valor for 0 (Zero) imprime o código
	aAdd(aGrava,{aNfItem[nZ,IT_ITEM],;//1 - Item
					aParam[1]	,;	  //2 - Codigo de Lancamento
					"1"	,;			  //3 - Sistema
					nBase,;			  //4 - Base de Calculo
					nAliq,;			  //5 - Aliquota
					nValor,;		  //6 - Valor Calculado
					aParam[2],; 	  //7 - Sequencia
					aParam[3],; 	  //8 - Informacoes Complementares
					aParam[4],; 	  //9 - Tipo de Utilidade do Lancamento
					cVL197,; 		  //10- Gravação do valor em ICMS ou OUTROS
					aParam[5],; 	  //11-Complemento para Registro 0460
					aParam[6],; 	  //12-Codigo Reflexo
					aParam[7],; 	  //13 - Gera GNRE
					aParam[8],; 	  //14 - Campo origem CC7
					aParam[9],; 	  // 15 - CFOP
					aParam[10],; 	  //16 - lIVRO
					aParam[11],; 	  //17 - Descrição DO CÓDIGO
					"",;			  // Da posição 18 em diante foi criado apenas para compatibilizar com a função do configurador
					"",;
					"",;
					0,;
					"",;
					"",;
					"",;
					""}) // Compatibilizando o agrava do legado para que na planilha financeira o campo de Vl Outros fique Zero , se houver notas com itens com lançamento de ajuste do legado e no configurador
	lGerou	:=	.T.
EndIf

Return lGerou

/*/
MaExcecao-Eduardo/Edson   -09.12.1999
Calculo das Excecoes fiscais
/*/
Function xFsExcecao( nItem , cCampo, aNfItem, aPos, aSX6, aNFCab, aPE,lHistorico)

Local aArea		:= GetArea()
Local aAreaSF7	:= SF7->(GetArea())
Local aExcecao	:= {}
Local aExceFat	:= {}
Local cGRTrib	:= ""
Local cUfOriDes	:= ""
Local cChave	:= ""
Local cHistSF7	:= ""
Local cAls		:= "SF7"
Local cOrigem	:= ""
Local cSiTrib	:= ""
Local nScan		:= 0
Local lExecuta	:= .T.
Local lSS1		:= .F.
Local lClasFis	:= Len( Alltrim( aNfItem[nItem][IT_CLASFIS] ) ) == 3
Local bCompareF7:= Nil
Local aExceAux	:= {}
Local lIntTMS   := IntTMS()
Local nTamGRTrb := GTamMxFis(TAM_F7_GRTRIB)
Local nTamGrCli := GTamMxFis(TAM_F7_GRPCLI)
Local nTS1GrTrb := GTamMxFis(TAM_S1_GRTRIB)
Local lSeek     := .F.

Default cCampo	:= ""

/* Estrutura do Array aExcecao
[01] - Aliq. de ICMS Interna
[02] - Aliq. de ICMS Externa
[03] - Margem de Lucro Presumida
[04] - Grupo de Tributacao
[05] - "S"
[06] - Aliq. de ICMS Destino
[07] - Refere-se ao ISS "S/N"
[08] - Valor do Solidario de Pauta
[09] - Valor do IPI de Pauta
[10] - Valor do PIS
[11] - Valor Cofins
[12] - Aliquota do PIS
[13] - Aliquota do Cofins
[14] - Reducao da base de calculo do ICMS
[15] - Reducao da base de calculo do IPI
[16] - Icms Pauta
[17] - Aliquota de IPI
[18] - Reducao da base de calculo do PIS
[19] - Reducao da base de calculo da COFINS
[20] - Pauta Produto "S/N"
[21] - Tab. Natureza da Receita
[22] - Codigo Natureza da Receita
[23] - Grupo Natureza da Receita
[24] - Data Final Nat. Receita
[25] - Preço Unitário de Cigarro para cálculo da Substituição tributária de Cigarros para PIS e COFINS
[26] - Reducao da base de calculo do ICMS ST
[27] - ID do Historico das alteracoes
[28] - Codigo de Origem
[29] - Codigo de Situacao Tributaria
[30] - MVA operação de frete
[31] - UF de Busca
[32] - Pauta FOB
[33] - Redução da Base Difal
*/

If Empty( cGrTrib := aNFItem[nItem,IT_GRPTRIB] )
	cGrTrib := PadR( aNfItem[nItem][IT_PRD][SB_GRTRIB], nTamGRTrb)
EndIf

If !Empty(cGRTrib)

	If aPos[FP_F7_ORIGEM] .And. aPos[FP_F7_SITTRIB]

		/* O trecho abaixo foi copiado da funcao MaFisPreCalc(), pois as pilhas de recalculo possuem a chamada da MaExcecao() antes
		   da MaFisPreCalc() - onde eh definida a Classificacao Fiscal. Por este motivo, preciso garantir que a informacao do
		   IT_CLASFIS esteja correta para utilizar nas comparacoes da Excecao Fiscal.
		   Essa alteracao foi feita para que nao se faca necessario alterar todas as pilhas de recalculo, considerando a chamada da
		   MaFisPreCalc() antes da MaExcecao(). Essa mudanca sera feita na re-estruturacao das pilhas da MATXFIS.
		   */
		If  cCampo $ "IT_PRODUTO/IT_TES" .Or. !lClasFis
			If aSX6[MV_STFRETE] .And. ( AllTrim( aNFCab[NF_ESPECIE] ) $ "CTR/CTE/CTA/CTF" .Or. "NFST"$AllTrim( aNFCab[NF_ESPECIE] ) )
				aNfitem[nItem][IT_CLASFIS] := "0" + aNFItem[nItem][IT_TS][TS_SITTRIB]
			Else
				If aNfitem[nItem][IT_TIPONF] == "D" .And. !Empty(aNFItem[nItem][IT_RECORI]) .And. aNFCab[NF_OPERNF] == "E"
					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					aNfitem[nItem][IT_CLASFIS] := SD2->D2_CLASFIS
				Else
					aNfitem[nItem][IT_CLASFIS] := aNfItem[nItem][IT_PRD][SB_ORIGEM] + aNFItem[nItem][IT_TS][TS_SITTRIB]
				EndIf
			EndIf
		Endif
		/* Verifico a necessidade de utilizar os codigos de origem e situacao tributaria
		   na comparacao junto ao Grupo Tributario, e que a cada item ocorra essa
		   verificacao para consistir a utilizacao do correto registro da SF7
		   */
		cOrigem		:= Iif( lClasFis , SubStr(aNfItem[nItem][IT_CLASFIS],1,1) , aNfItem[nItem][IT_PRD][SB_ORIGEM] )
		cSitTrib	:= Iif( lClasFis , SubStr(aNfItem[nItem][IT_CLASFIS],2,2) , aNFItem[nItem][IT_TS][TS_SITTRIB] )

		bCompareF7	:= {|x| !Empty(x[IT_EXCECAO]) .And. x[IT_EXCECAO,4]+x[IT_EXCECAO,28]+x[IT_EXCECAO,29] == cGRTrib+cOrigem+cSitTrib }
	Else
		bCompareF7	:= {|x| !Empty(x[IT_EXCECAO]) .And. x[IT_EXCECAO,4]==cGRTrib}
	Endif

	nScan := aScan( aNfItem , bCompareF7 )
	If nScan == 0
		dbSelectArea("SF7")
		SF7->(dbSetOrder(1))
		lSeek := SF7->(MsSeek(xFilial("SF7")+PadR(cGRTrib,nTamGRTrb)+Padr(aNFCab[NF_GRPCLI],nTamGrCli)))
		
		If aPE[PE_MFISEXCE]
			lExecuta  := Execblock("MFISEXCE",.F.,.F.,{Alias(),Recno()})
			IIF(Valtype(lExecuta)=="L",lExecuta,.T.)
		Endif
		If lHistorico
			//Se for reprocessamento,  e tiver habilitado para buscar os Historico Fiscais,
			//verifico se o ID do historico da Excecao e igual ao que foi gravado na Nota. Se for
			//igual é porque nao teve alterações na Excecao após a emissão. Se for diferente,
			//é porque teve alterações no cadastro, e entao os dados são carregados da tabela de
			//Historico(SS1).

			If( aNfCab[NF_CLIFOR]=="C" .And. aNfCab[NF_TIPONF]<>"D") .Or.( aNfCab[NF_CLIFOR]=="F" .And. aNfCab[NF_TIPONF]$"D|B")
				cHistSF7 :=  (cAlsItem)->D2_IDSF7
			Else
				cHistSF7 :=  (cAlsItem)->D1_IDSF7
			EndIf

			If  cPaisLoc == "BRA" .And. Alltrim(SF7->F7_IDHIST) <> Alltrim(cHistSF7)
				dbSelectArea("SS1")
				dbSetOrder(1)
				lSeek := MsSeek(xFilial("SS1")+cHistSF7+Padr(cGRTrib,nTS1GrTrb)+Padr(aNFCab[NF_GRPCLI],nTamGrCli))
				cAls   := "SS1"
				lSS1 := .T.
			EndIf
		EndIf

		If lSeek
			While !(cAls)->(Eof()) .And. lExecuta .AND. IIF(lSS1,;
															SS1->S1_FILIAL == xFilial('SS1') .AND. SS1->S1_IDHIST == cHistSF7 .And. SS1->S1_GRTRIB ==  cGRTrib  .AND. SS1->S1_GRPCLI ==  aNFCab[NF_GRPCLI],;
															SF7->F7_FILIAL == xFilial('SF7') .AND. SF7->F7_GRTRIB == cGRTrib  .AND. SF7->F7_GRPCLI == aNFCab[NF_GRPCLI] )

				If ((!aPos[FP_F7_MSBLQD]) .Or. (aPos[FP_F7_MSBLQD] .And. (SF7->F7_MSBLQD > date() .Or. Empty(SF7->F7_MSBLQD)))) // validação para não considerar item bloqueado por data
					If aPos[FP_F7_UFBUSCA] .And. (aNfCab[NF_OPERNF] == "E" .Or. (aNfCab[NF_OPERNF] == "S" .And. aNFCab[NF_TIPONF] == "D"))
						cUfOriDes := IIf(IIf(lSS1,  SS1->S1_UFBUSCA == "2", SF7->F7_UFBUSCA == "2") , aNFCab[NF_UFDEST] , aNFCab[NF_UFORIGEM] )
					ElseIf aPos[FP_F7_UFBUSCA] .And. lIntTMS .And. nModulo == 43 //SIGATMS
						cUfOriDes := IIf(IIf(lSS1,  SS1->S1_UFBUSCA == "2", SF7->F7_UFBUSCA == "2"), aNFCab[NF_UFDEST] , aNFCab[NF_UFORIGEM])
					Else
						cUfOriDes := aNFCab[NF_UFORIGEM]
					EndIf

					/* Abaixo eh feita a validacao dos campos utilizados como chave de combinacao da Excecao Fiscal
					Campos utilizados:
						- F7_EST (conforme campo F7_UFBUSCA, a comparacao sera com Uf Destino ou Uf Origem)
						- F7_TIPOCLI (compara com o tipo do cliente definido pelos cadastros A1/A2)
						- F7_ORIGEM (origem do pruduto, que esta definida no primeiro caracter dos campos D1/D2_CLASFIS)
						- F7_SITTRIB(situacao tributaria do produto, que esta definida no segundo e terceiro caracter
						dos campos D1/D2_CLASFIS) */

					If	aNFCab[NF_TIPONF] == "D" .And.;
						IIf(lSS1, ( cUfOriDes == SS1->S1_EST .Or. SS1->S1_EST == "**" ), ( cUfOriDes == SF7->F7_EST .Or. SF7->F7_EST == "**" )) .And.;
						IIf(lSS1, ( aNfCab[NF_TPCLIFOR] == SS1->S1_TIPOCLI .Or. SS1->S1_TIPOCLI == "*" ), (aNfCab[NF_TPCLIFOR] == SF7->F7_TIPOCLI .Or. SF7->F7_TIPOCLI == "*" )) .And.;
						Iif(lSS1 .And. aPos[FP_S1_ORIGEM], ( cOrigem == SS1->S1_ORIGEM .Or. Empty(SS1->S1_ORIGEM) ) , Iif( aPos[FP_F7_ORIGEM] , ( cOrigem == SF7->F7_ORIGEM .Or. Empty(SF7->F7_ORIGEM) ) , .T. ) ) .And.;
						Iif(lSS1 .And. aPos[FP_S1_SITTRIB], ( cSitTrib == SS1->S1_SITTRIB .Or. Empty(SS1->S1_SITTRIB) ) , Iif( aPos[FP_F7_SITTRIB] , ( cSitTrib == SF7->F7_SITTRIB .Or. Empty(SF7->F7_SITTRIB) ) , .T. ) )

						aadd(aExcecao,IIf(lSS1, SS1->S1_ALIQINT, SF7->F7_ALIQINT))
						aadd(aExcecao,IIf(lSS1, SS1->S1_ALIQEXT, SF7->F7_ALIQEXT))
						aadd(aExcecao,IIf(lSS1, SS1->S1_MARGEM, SF7->F7_MARGEM))
						aadd(aExcecao,IIf(lSS1, SS1->S1_GRTRIB, SF7->F7_GRTRIB))
						aadd(aExcecao,"S")
						aadd(aExcecao,IIf(lSS1, SS1->S1_ALIQDST, SF7->F7_ALIQDST))
						aadd(aExcecao,IIf(lSS1, SS1->S1_ISS, SF7->F7_ISS))
						If cPaisLoc == "BRA"
							aadd(aExcecao,IIf(lSS1, SS1->S1_VLR_ICM, SF7->F7_VLR_ICM))
							aadd(aExcecao,IIf(lSS1, SS1->S1_VLR_IPI, SF7->F7_VLR_IPI))
							aadd(aExcecao,IIf(lSS1, SS1->S1_VLR_PIS, SF7->F7_VLR_PIS))
							aadd(aExcecao,IIf(lSS1, SS1->S1_VLR_COF, SF7->F7_VLR_COF))
							aadd(aExcecao,IIf(lSS1, SS1->S1_ALIQPIS, SF7->F7_ALIQPIS))
							aadd(aExcecao,IIf(lSS1, SS1->S1_ALIQCOF, SF7->F7_ALIQCOF))
							aadd(aExcecao,IIf(lSS1, SS1->S1_BASEICM, SF7->F7_BASEICM))
							aadd(aExcecao,IIf(lSS1, SS1->S1_BASEIPI, SF7->F7_BASEIPI))
							aadd(aExcecao,IIf(lSS1, SS1->S1_VLRICMP, SF7->F7_VLRICMP))
							aadd(aExcecao,IIf(lSS1, SS1->S1_ALIQIPI, SF7->F7_ALIQIPI))
							aadd(aExcecao,IIf(lSS1, SS1->S1_REDPIS,  SF7->F7_REDPIS))
							aadd(aExcecao,IIf(lSS1, SS1->S1_REDCOF,  SF7->F7_REDCOF))
							aadd(aExcecao,IIf(lSS1, SS1->S1_ICMPAUT, SF7->F7_ICMPAUT))
							aadd(aExcecao,Iif(aPos[FP_F7_TNATREC], IIf(lSS1, SS1->S1_TNATREC, SF7->F7_TNATREC),""))
							aadd(aExcecao,Iif(aPos[FP_F7_CNATREC], IIf(lSS1, SS1->S1_CNATREC, SF7->F7_CNATREC),""))
							aadd(aExcecao,Iif(aPos[FP_F7_GRUPONC], IIf(lSS1, SS1->S1_GRUPONC, SF7->F7_GRUPONC),""))
							aadd(aExcecao,Iif(aPos[FP_F7_DTFIMNT], IIf(lSS1, SS1->S1_DTFIMNT, SF7->F7_DTFIMNT),CtoD("")))
							aadd(aExcecao,Iif(aPos[FP_F7_PRCUNIC], IIf(lSS1, SS1->S1_PRCUNIC, SF7->F7_PRCUNIC),0))
							aadd(aExcecao,Iif(aPos[FP_F7_BSICMST], IIf(lSS1, SS1->S1_BSICMST, SF7->F7_BSICMST),0))
							aadd(aExcecao,Iif(aPos[FP_F7_IDHIST],  IIf(lSS1, SS1->S1_IDHIST,  SF7->F7_IDHIST), ""))
							aadd(aExcecao,Iif(aPos[FP_F7_ORIGEM],  IIf(lSS1, SS1->S1_ORIGEM,  cOrigem ), ""))
							aadd(aExcecao,Iif(aPos[FP_F7_SITTRIB], IIf(lSS1, SS1->S1_SITTRIB, cSitTrib), ""))
							aadd(aExcecao, Iif( lSS1 .And. aPos[FP_MV_MVAFS1],  &(aSX6[MV_MVAFRE]), IIf(aPos[FP_MV_MVAFRE] , &(aSX6[MV_MVAFRE]),0)))
							aadd(aExcecao, Iif( lSS1, SS1->S1_UFBUSCA, SF7->F7_UFBUSCA))
							aadd(aExcecao,Iif(aPos[FP_F7_PAUTFOB], IIf(lSS1, SS1->S1_PAUTFOB, SF7->F7_PAUTFOB),0))
							aadd(aExcecao, Iif(aPos[FP_F7_BASCMP], IIf(lSS1, SS1->S1_BASCMP, SF7->F7_BASCMP),0))
							aadd(aExcecao, Iif(aPos[FP_F7_ALQANT], IIf(lSS1, SS1->S1_ALQANT, SF7->F7_ALQANT),0))
						Else
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,"")
							aadd(aExcecao,"")
							aadd(aExcecao,"")
							aadd(aExcecao,CToD(""))
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,"")
							aadd(aExcecao,"")
							aadd(aExcecao,"")
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,0)
							aadd(aExcecao,0)
						EndIf
					Else
						If aPos[FP_F7_UFBUSCA] .And. aNfCab[NF_OPERNF] == "E"
							cUfOriDes := IIf(IIf(lSS1,  SS1->S1_UFBUSCA == "2", SF7->F7_UFBUSCA == "2") , aNFCab[NF_UFORIGEM] , aNFCab[NF_UFDEST] )
						ElseIf aPos[FP_F7_UFBUSCA] .And. lIntTMS .And. nModulo == 43 //SIGATMS
							cUfOriDes := IIf(IIf(lSS1,  SS1->S1_UFBUSCA == "2", SF7->F7_UFBUSCA == "2")  , aNFCab[NF_UFORIGEM] , aNFCab[NF_UFDEST] )
						Else
							cUfOriDes := aNFCab[NF_UFDEST]
						EndIf

						/* Abaixo eh feita a validacao dos campos utilizados como chave de combinacao da Excecao Fiscal
						Campos utilizados:
							- F7_EST (conforme campo F7_UFBUSCA, a comparacao sera com Uf Destino ou Uf Origem)
							- F7_TIPOCLI (compara com o tipo do cliente definido pelos cadastros A1/A2)
							- F7_ORIGEM (origem do pruduto, que esta definida no primeiro caracter dos campos D1/D2_CLASFIS)
							- F7_SITTRIB(situacao tributaria do produto, que esta definida no segundo e terceiro caracter
							dos campos D1/D2_CLASFIS)*/

						If	aNFCab[NF_TIPONF] != "D" .And.;
							IIf(lSS1, ( cUfOriDes == SS1->S1_EST .Or. SS1->S1_EST == "**"), ( cUfOriDes == SF7->F7_EST .Or. SF7->F7_EST == "**")) .And.;
							IIf(lSS1, ( aNfCab[NF_TPCLIFOR] == SS1->S1_TIPOCLI .Or. SS1->S1_TIPOCLI == "*" ), (aNfCab[NF_TPCLIFOR] == SF7->F7_TIPOCLI .Or. SF7->F7_TIPOCLI == "*" )) .And.;
							Iif(lSS1, ( cOrigem == SS1->S1_ORIGEM .Or. Empty(SS1->S1_ORIGEM) ) , Iif( aPos[FP_F7_ORIGEM] , ( cOrigem == SF7->F7_ORIGEM .Or. Empty(SF7->F7_ORIGEM) ) , .T. ) ) .And.;
							Iif(lSS1, ( cSitTrib == SS1->S1_SITTRIB .Or. Empty(SS1->S1_SITTRIB) ) , Iif( aPos[FP_F7_SITTRIB] , ( cSitTrib == SF7->F7_SITTRIB .Or. Empty(SF7->F7_SITTRIB) ) , .T. ) )

							aadd(aExcecao, IIf(lSS1, SS1->S1_ALIQINT, SF7->F7_ALIQINT))
							aadd(aExcecao, IIf(lSS1, SS1->S1_ALIQEXT, SF7->F7_ALIQEXT))
							aadd(aExcecao, IIf(lSS1, SS1->S1_MARGEM, SF7->F7_MARGEM))
							aadd(aExcecao, IIf(lSS1, SS1->S1_GRTRIB, SF7->F7_GRTRIB))
							aadd(aExcecao, "S")
							aadd(aExcecao, IIf(lSS1, SS1->S1_ALIQDST, SF7->F7_ALIQDST))
							aadd(aExcecao, IIf(lSS1, SS1->S1_ISS, SF7->F7_ISS))
							If cPaisLoc == "BRA"
								aadd(aExcecao, IIf(lSS1, SS1->S1_VLR_ICM, SF7->F7_VLR_ICM))
								aadd(aExcecao, IIf(lSS1, SS1->S1_VLR_IPI, SF7->F7_VLR_IPI))
								aadd(aExcecao, IIf(lSS1, SS1->S1_VLR_PIS, SF7->F7_VLR_PIS))
								aadd(aExcecao, IIf(lSS1, SS1->S1_VLR_COF, SF7->F7_VLR_COF))
								aadd(aExcecao, IIf(lSS1, SS1->S1_ALIQPIS, SF7->F7_ALIQPIS))
								aadd(aExcecao, IIf(lSS1, SS1->S1_ALIQCOF, SF7->F7_ALIQCOF))
								aadd(aExcecao, IIf(lSS1, SS1->S1_BASEICM, SF7->F7_BASEICM))
								aadd(aExcecao, IIf(lSS1, SS1->S1_BASEIPI, SF7->F7_BASEIPI))
								aadd(aExcecao, IIf(lSS1, SS1->S1_VLRICMP, SF7->F7_VLRICMP))
								aadd(aExcecao, IIf(lSS1, SS1->S1_ALIQIPI, SF7->F7_ALIQIPI))
								aadd(aExcecao, IIf(lSS1, SS1->S1_REDPIS, SF7->F7_REDPIS))
								aadd(aExcecao, IIf(lSS1, SS1->S1_REDCOF, SF7->F7_REDCOF))
								aadd(aExcecao, IIf(lSS1, SS1->S1_ICMPAUT, SF7->F7_ICMPAUT))
								aadd(aExcecao, Iif(aPos[FP_F7_TNATREC],IIf(lSS1, SS1->S1_TNATREC, SF7->F7_TNATREC),""))
								aadd(aExcecao, Iif(aPos[FP_F7_CNATREC],IIf(lSS1, SS1->S1_CNATREC, SF7->F7_CNATREC),""))
								aadd(aExcecao, Iif(aPos[FP_F7_GRUPONC],IIf(lSS1, SS1->S1_GRUPONC, SF7->F7_GRUPONC),""))
								aadd(aExcecao, Iif(aPos[FP_F7_DTFIMNT],IIf(lSS1, SS1->S1_DTFIMNT, SF7->F7_DTFIMNT),CtoD("")))
								aadd(aExcecao, Iif(aPos[FP_F7_PRCUNIC],IIf(lSS1, SS1->S1_PRCUNIC, SF7->F7_PRCUNIC),0))
								aadd(aExcecao, Iif(aPos[FP_F7_BSICMST],IIf(lSS1, SS1->S1_BSICMST, SF7->F7_BSICMST),0))
								aadd(aExcecao, Iif(aPos[FP_F7_IDHIST], IIf(lSS1, SS1->S1_IDHIST,  SF7->F7_IDHIST), ""))
								aadd(aExcecao, Iif(aPos[FP_F7_ORIGEM], IIf(lSS1, SS1->S1_ORIGEM,  cOrigem), ""))
								aadd(aExcecao, Iif(aPos[FP_F7_SITTRIB],IIf(lSS1, SS1->S1_SITTRIB, cSitTrib),""))
								aadd(aExcecao, Iif( lSS1 .And. aPos[FP_MV_MVAFS1],  &(aSX6[MV_MVAFRE]), IIf(aPos[FP_MV_MVAFRE] , &(aSX6[MV_MVAFRE]),0)))
								aadd(aExcecao, Iif( lSS1, SS1->S1_UFBUSCA, SF7->F7_UFBUSCA))
								aadd(aExcecao, Iif(aPos[FP_F7_PAUTFOB], IIf(lSS1, SS1->S1_PAUTFOB, SF7->F7_PAUTFOB),0))
								aadd(aExcecao, Iif(aPos[FP_F7_BASCMP], IIf(lSS1, SS1->S1_BASCMP, SF7->F7_BASCMP),0))
								aadd(aExcecao, Iif(aPos[FP_F7_ALQANT], IIf(lSS1, SS1->S1_ALQANT, SF7->F7_ALQANT),0))
							Else
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,"")
								aadd(aExcecao,"")
								aadd(aExcecao,"")
								aadd(aExcecao,CToD(""))
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,"")
								aadd(aExcecao,"")
								aadd(aExcecao,"")
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,0)
								aadd(aExcecao,0)
							EndIf
							Exit
						EndIf
					EndIf
				EndIf
				(cAls)->(dbSkip())
			EndDo
		EndIf
	Else
		aExcecao := aNfItem[nScan][IT_EXCECAO]
	EndIf

	If aPE[PE_MAEXCEFISC]
			aExceAux :=  ExecBlock("MAEXCEFISC",.F.,.F.,{ aExcecao, {nItem, cGRTrib, cUfOriDes, cOrigem,cSitTrib, aNFCab[NF_ESPECIE], aNfCab[NF_TIPONF], aNFCab[NF_OPERNF], aNfCab[NF_CLIFOR], aNFCab[NF_CLIEFAT]}})
			If Len(aExceAux) >= 33
				aExcecao := aExceAux
			EndIf
	EndIf

	If cPaisLoc == "BRA" .And. aNFCab[NF_OPERNF]=="S" .And. !Empty(aNFCab[NF_CLIEFAT])
		nScan := aScan(aNfItem,{|x| !Empty(x[IT_EXCEFAT]) .And. x[IT_EXCEFAT,4] == cGRTrib })
		If nScan == 0
			If SF7->(dbSeek(xFilial("SF7") + Padr(cGRTrib,nTamGRTrb) + Padr(aNFCab[NF_GRPFAT],nTamGrCli) ) )
				If aPE[PE_MFISEXCE]
					lExecuta  := Execblock("MFISEXCE",.F.,.F.,{Alias(),Recno()})
					IIF(Valtype(lExecuta)=="L",lExecuta,.T.)
				Endif
				While !SF7->(Eof()).And.SF7->F7_FILIAL==xFilial("SF7") .And. SF7->F7_GRTRIB == cGRTrib .And. SF7->F7_GRPCLI == aNFCab[NF_GRPFAT] .And. lExecuta
					//Para o tratamento da exceção do cliente do faturamento,
					//por ser utilizado apenas para PIS e COFINS, não irá considerar o
					//o tratamento  de destino e origem.
					If 	( aNfCab[NF_TIPOFAT] == SF7->F7_TIPOCLI .Or. SF7->F7_TIPOCLI == "*" )
						aadd(aExceFat,SF7->F7_ALIQINT)
						aadd(aExceFat,SF7->F7_ALIQEXT)
						aadd(aExceFat,SF7->F7_MARGEM)
						aadd(aExceFat,SF7->F7_GRTRIB)
						aadd(aExceFat,"S")
						aadd(aExceFat,SF7->F7_ALIQDST)
						aadd(aExceFat,SF7->F7_ISS)
						aadd(aExceFat,SF7->F7_VLR_ICM)
						aadd(aExceFat,SF7->F7_VLR_IPI)
						aadd(aExceFat,SF7->F7_VLR_PIS)
						aadd(aExceFat,SF7->F7_VLR_COF)
						aadd(aExceFat,SF7->F7_ALIQPIS)
						aadd(aExceFat,SF7->F7_ALIQCOF)
						aadd(aExceFat,SF7->F7_BASEICM)
						aadd(aExceFat,SF7->F7_BASEIPI)
						aadd(aExceFat,SF7->F7_VLRICMP)
						aadd(aExceFat,SF7->F7_ALIQIPI)
						aadd(aExceFat,SF7->F7_REDPIS)
						aadd(aExceFat,SF7->F7_REDCOF)
						aadd(aExceFat,SF7->F7_ICMPAUT)
						aadd(aExceFat,Iif(aPos[FP_F7_TNATREC],SF7->F7_TNATREC,""))
						aadd(aExceFat,Iif(aPos[FP_F7_CNATREC],SF7->F7_CNATREC,""))
						aadd(aExceFat,Iif(aPos[FP_F7_GRUPONC],SF7->F7_GRUPONC,""))
						aadd(aExceFat,Iif(aPos[FP_F7_DTFIMNT],SF7->F7_DTFIMNT,CtoD("")))
						aadd(aExceFat,Iif(aPos[FP_F7_PRCUNIC],SF7->F7_PRCUNIC,0))
						aadd(aExceFat,Iif(aPos[FP_F7_BSICMST],SF7->F7_BSICMST,0))
						aadd(aExceFat,"") //IDHIST
						aadd(aExceFat,Iif(aPos[FP_F7_ORIGEM],cOrigem,""))
						aadd(aExceFat,Iif(aPos[FP_F7_SITTRIB],cSitTrib,""))
						aadd(aExceFat, Iif( aPos[FP_MV_MVAFRE] , &(aSX6[MV_MVAFRE]),0))
						aadd(aExceFat, SF7->F7_UFBUSCA)
						aadd(aExceFat,Iif(aPos[FP_F7_PAUTFOB],SF7->F7_PAUTFOB,0))
						aadd(aExceFat,Iif(aPos[FP_F7_BASCMP],SF7->F7_BASCMP,0))
						aadd(aExceFat,Iif(aPos[FP_F7_ALQANT],SF7->F7_ALQANT,0))
						Exit
					EndIf
					SF7->(dbSkip())
				EndDo
			EndIf
		Else
			aExceFat := aNfItem[nScan][IT_EXCEFAT]
		EndIf
		If aPE[PE_MAEXCEFISC]
			  aExceAux :=  ExecBlock("MAEXCEFISC",.F.,.F.,{ aExceFat, {nItem, cGRTrib, cUfOriDes, cOrigem,cSitTrib, aNFCab[NF_ESPECIE], aNfCab[NF_TIPONF], aNFCab[NF_OPERNF], aNfCab[NF_CLIFOR],aNFCab[NF_CLIEFAT]} })
			  If Len(aExceAux) >= 33
				aExceFat := aExceAux
			EndIf
		EndIf
	EndIf
EndIf

// Intervenção para que o SIGAAGRO sobreecreva a exceção
If FindFunction("OGXUtlOrig") //Usa sigaagro
	If OGXUtlOrig() .and.FindFunction("AgrICMPaut")
		If Empty(aExcecao)
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,cGRTrib)
			aadd(aExcecao,"S")
			aadd(aExcecao,0)
			aadd(aExcecao,"")
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			if cPaisLoc == "BRA"
				aadd(aExcecao,iif(lSS1, CriaVar("S1_ICMPAUT"), CriaVar("F7_ICMPAUT")))
			else
				aadd(aExcecao,0)
			endif
			aadd(aExcecao,"")
			aadd(aExcecao,"")
			aadd(aExcecao,"")
			aadd(aExcecao,CToD(""))
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,"")
			aadd(aExcecao,"")
			aadd(aExcecao,"")
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,0)
			aadd(aExcecao,0)
		Endif

		AgrICMPaut(aNfCab, aNfItem, nItem, @aExcecao )

		If aPE[PE_MAEXCEFISC] // mantem a funcionalidade do ponto de entrada.
			aExceAux :=  ExecBlock("MAEXCEFISC",.F.,.F.,{ aExcecao, {nItem, cGRTrib, cUfOriDes, cOrigem,cSitTrib, aNFCab[NF_ESPECIE], aNfCab[NF_TIPONF], aNFCab[NF_OPERNF], aNfCab[NF_CLIFOR], aNFCab[NF_CLIEFAT]}})
			If Len(aExceAux) >= 33
				aExcecao := aExceAux
			EndIf
		EndIf
	EndIF
Endif

aNfItem[nItem][IT_EXCECAO] := aExcecao
aNfItem[nItem][IT_EXCEFAT] := aExceFat

If Len(aExcecao) > 0
	aNfItem[nItem][IT_IDSF7] := aExcecao[27]
EndIf

RestArea(aAreaSF7)
RestArea(aArea)

Return(aExcecao)

/*/
MaNewFisTes - Joao Pellegrini-18/08/2015±±
Inicializa o codigo da TES utilizada no item
*/
Function xFisNewTes(cTes,nRecnoSF4,nItem,lSeek,aSX6,lHistorico,cAlsItem,aNfCab,aNfItem,aPos,aDic,aFunc)

Local aArea		:= {}
Local cHistSF4  := ""
Local lSS0 := .F.
Local aMVPPDIFAL := &(aSX6[MV_PPDIFAL])
DEFAULT cTes 	   := ""
DEFAULT nRecnoSF4  := 0
DEFAULT lSeek := !Empty(cTes) .Or. nRecnoSF4 <> 0

If lSeek
	aArea := GetArea()
	//aAreaSFC := SFC->(GetArea())
	dbSelectArea("SF4")
	If nRecnoSF4 == 0
		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4") + cTes))
		If lHistorico .And. !Empty(cAlsItem)
			//Se for reprocessamento,  e tiver habilitado para buscar os Historico Fiscais,
			//verifico se o ID do historico da TES  eh  igual ao que foi gravado na Nota. Se for
			//igual é porque nao teve alterações na TES após a emissão. Se for diferente,
			//é porque teve alterações no cadastro, e entao os dados são carregados da tabela de
			//Historico(SS0).
			If( aNfCab[NF_CLIFOR]=="C" .And. aNfCab[NF_TIPONF]<>"D") .Or.( aNfCab[NF_CLIFOR]=="F" .And. aNfCab[NF_TIPONF]$"D|B")
				cHistSF4 := (cAlsItem)->D2_IDSF4
			Else
				cHistSF4 := (cAlsItem)->D1_IDSF4
			EndIf
			If  cPaisLoc == "BRA" .And. Alltrim(SF4->F4_IDHIST)<>Alltrim(cHistSF4)
				dbSelectArea("SS0")
				SS0->(dbSetOrder(1))
				SS0->(MsSeek(xFilial("SS0")+cHistSF4+cTes))
				lSS0 := .T.
			EndIf
		EndIf
	Else
		MsGoto(nRecnoSF4)
	EndIf
EndIf

If lSeek .And. !lSS0
	aNfItem[nItem][IT_RECNOSF4]	:= SF4->(Recno())
EndIf

aNfItem[nItem][IT_TS][TS_SFC]	 := {}
aNfItem[nItem][IT_TS][TS_LANCFIS] := {}
aNfItem[nItem][IT_TS][TS_CODIGO]  := IIf(lSeek, IIf(!lSS0, SF4->F4_CODIGO, SS0->S0_CODIGO), CriaVar("F4_CODIGO",.F.) )
aNfItem[nItem][IT_TS][TS_TIPO]	 := IIf(lSeek, IIf(!lSS0, SF4->F4_TIPO, SS0->S0_TIPO), aNfCab[NF_OPERNF] )
aNfItem[nItem][IT_TS][TS_ICM]	 := IIf(lSeek .And. cPaisLoc == "BRA", IIf(!lSS0, SF4->F4_ICM, SS0->S0_ICM), IIf( cPaisLoc=="BRA",IIf(aSX6[MV_INITES]==.T.,"N","S"),"N")  )
aNfItem[nItem][IT_TS][TS_IPI]	 := IIf(lSeek .And. cPaisLoc == "BRA", IIf(!lSS0, SF4->F4_IPI, SS0->S0_IPI), IIf( cPaisLoc=="BRA",IIf(aSX6[MV_INITES]==.T.,"N","S"),"N")  )
aNfItem[nItem][IT_TS][TS_CREDICM] := IIf(lSeek , IIf(!lSS0, SF4->F4_CREDICM, SS0->S0_CREDICM), "S")
aNfItem[nItem][IT_TS][TS_CREDIPI] := IIf(lSeek , IIf(!lSS0, SF4->F4_CREDIPI,SS0->S0_CREDIPI), "N")
aNfItem[nItem][IT_TS][TS_DUPLIC]	 := IIf(lSeek , IIf(!lSS0, SF4->F4_DUPLIC, SS0->S0_DUPLIC), "S")
aNfItem[nItem][IT_TS][TS_ESTOQUE] := IIf(lSeek, IIf(!lSS0, SF4->F4_ESTOQUE, SS0->S0_ESTOQUE), "S")
If cPaisLoc == "RUS" .And. Type("aCols") == "A" .And. Empty(aNFCab[NF_ESPECIE])
	nPosCF := aScan(aHeader,{|x| AllTrim(x[2]) ==  Iif(aNfCab[NF_OPERNF] == "E",'C7_CF','C6_CF') } )
	If (nPosCF > 0)
		aNfItem[nItem][IT_TS][TS_CF]	:= aCols[nItem][nPosCF]
	EndIf
ElseIf cPaisLoc == "RUS" .And. Type("aCols") == "A" .And. !Empty(aNFCab[NF_ESPECIE])
	nPosCF := aScan(aHeader,{|x| AllTrim(x[2]) ==  Iif(aNfCab[NF_OPERNF] == "E",'D1_CF','D2_CF') } )
	If (nPosCF > 0)
		aNfItem[nItem][IT_TS][TS_CF]	:= aCols[nItem][nPosCF]
	EndIf
Else
	aNfItem[nItem][IT_TS][TS_CF] := IIf(lSeek , IIf(!lSS0, SF4->F4_CF     , SS0->S0_CF)      , IIf(aNfCab[NF_OPERNF] == "E","111","511") )
EndIf
aNfItem[nItem][IT_TS][TS_TEXTO]	 := IIf(lSeek, IIf(!lSS0, SF4->F4_TEXTO, SS0->S0_TEXTO), CriaVar("F4_TEXTO",.F.) )
aNfItem[nItem][IT_TS][TS_BASEICM] := IIf(lSeek, IIf(!lSS0, SF4->F4_BASEICM, SS0->S0_BASEICM), 0)
aNfItem[nItem][IT_TS][TS_BASEIPI] := IIf(lSeek , IIf(!lSS0, SF4->F4_BASEIPI, SS0->S0_BASEIPI), 0)
aNfItem[nItem][IT_TS][TS_PODER3]	 := IIf(lSeek , IIf(!lSS0, SF4->F4_PODER3, SS0->S0_PODER3), "N")
aNfItem[nItem][IT_TS][TS_LFICM]   := IIf(lSeek, IIf(!lSS0, SF4->F4_LFICM, SS0->S0_LFICM), IIf(aSX6[MV_INITES]==.T.,"N","T") )
aNfItem[nItem][IT_TS][TS_LFIPI]	 := IIf(lSeek, IIf(!lSS0, SF4->F4_LFIPI, SS0->S0_LFIPI), IIf(aSX6[MV_INITES]==.T.,"N","T") )
aNfItem[nItem][IT_TS][TS_DESTACA] := IIf(lSeek, IIf(!lSS0, SF4->F4_DESTACA, SS0->S0_DESTACA), "N")
aNfItem[nItem][IT_TS][TS_INCIDE]	 := IIf(lSeek, IIf(!lSS0, SF4->F4_INCIDE, SS0->S0_INCIDE), "N")
aNfItem[nItem][IT_TS][TS_COMPL]	 := IIf(lSeek, IIf(!lSS0, SF4->F4_COMPL, SS0->S0_COMPL), "N")
aNfItem[nItem][IT_TS][TS_IPIFRET] := IIf(lSeek, IIf(!lSS0, SF4->F4_IPIFRET, SS0->S0_IPIFRET), "N")
aNfItem[nItem][IT_TS][TS_ISS]	 := IIf(lSeek, IIf(!lSS0, SF4->F4_ISS, SS0->S0_ISS), " ")
aNfItem[nItem][IT_TS][TS_LFISS]	 := IIF(lSeek .And. aPos[FP_F4_LFISS], IIf(!lSS0, SF4->F4_LFISS, SS0->S0_LFISS)," ")
aNfItem[nItem][IT_TS][TS_NRLIVRO] := IIf(lSeek , IIf(!lSS0, SF4->F4_NRLIVRO, SS0->S0_NRLIVRO), " ")
aNfItem[nItem][IT_TS][TS_UPRC]	 := IIf(lSeek, IIf(!lSS0, SF4->F4_UPRC, SS0->S0_UPRC), " ")
aNfItem[nItem][IT_TS][TS_CONSUMO] := IIf(lSeek, IIf(!lSS0, SF4->F4_CONSUMO, SS0->S0_CONSUMO), " ")
aNfItem[nItem][IT_TS][TS_FORMULA] := IIf(lSeek, IIf(!lSS0, SF4->F4_FORMULA, SS0->S0_FORMULA), " ")
aNfItem[nItem][IT_TS][TS_AGREG]	 := IIf(lSeek, IIf(!lSS0, SF4->F4_AGREG, SS0->S0_AGREG), " ")
aNfItem[nItem][IT_TS][TS_AGRDRED] := IIf(lSeek .And. aPos[FP_F4_AGRDRED] .And. !Empty(IIf(!lSS0, SF4->F4_AGRDRED, SS0->S0_AGRDRED)), IIf(!lSS0, SF4->F4_AGRDRED, SS0->S0_AGRDRED), "2")
aNfItem[nItem][IT_TS][TS_INCSOL]	 := IIf(lSeek .And. aPos[FP_F4_INCSOL], IIf(!lSS0, SF4->F4_INCSOL , SS0->S0_INCSOL), " ")
aNfItem[nItem][IT_TS][TS_CIAP]	 := IIf(lSeek, IIf(!lSS0, SF4->F4_CIAP, SS0->S0_CIAP), " ")
aNfItem[nItem][IT_TS][TS_DESPIPI] := IIf(lSeek, IIf(!lSS0, SF4->F4_DESPIPI, SS0->S0_DESPIPI), "N")
aNfItem[nItem][IT_TS][TS_ATUTEC]	 := IIf(lSeek, IIf(!lSS0, SF4->F4_ATUTEC, SS0->S0_ATUTEC), " ")
aNfItem[nItem][IT_TS][TS_ATUATF]	 := IIf(lSeek, IIf(!lSS0, SF4->F4_ATUATF, SS0->S0_ATUATF), " ")
aNfItem[nItem][IT_TS][TS_TPIPI]	 := IIf(lSeek, IIf(!lSS0, SF4->F4_TPIPI, SS0->S0_TPIPI), "B")
aNfItem[nItem][IT_TS][TS_LIVRO]	 := IIf(lSeek, IIf(!lSS0, SF4->F4_LIVRO, SS0->S0_LIVRO), "")
aNfItem[nItem][IT_TS][TS_STDESC]	 := IIf(lSeek, IIf(!lSS0, SF4->F4_STDESC , SS0->S0_STDESC), " ")
aNfItem[nItem][IT_TS][TS_DESPICM] := IIf(lSeek, IIf(!lSS0, SF4->F4_DESPICM, SS0->S0_DESPICM), "2")
aNfItem[nItem][IT_TS][TS_DESPPIS] := IIf(lSeek .And. aPos[FP_F4_DESPPIS], IIf(!lSS0, SF4->F4_DESPPIS, SS0->S0_DESPPIS), "1")
aNfItem[nItem][IT_TS][TS_DESPCOF] := IIf(lSeek .And. aPos[FP_F4_DESPCOF], IIf(!lSS0, SF4->F4_DESPCOF, SS0->S0_DESPCOF), "1")
aNfItem[nItem][IT_TS][TS_BSICMST] := IIf(lSeek .And. aPos[FP_F4_BSICMST], IIf(!lSS0, SF4->F4_BSICMST, SS0->S0_BSICMST), 0)
aNfItem[nItem][IT_TS][TS_BASEISS] := IIf(lSeek .And. aPos[FP_F4_BASEISS], IIf(!lSS0, SF4->F4_BASEISS, SS0->S0_BASEISS), 0)
aNfItem[nItem][IT_TS][TS_IPILICM] := IIf(lSeek, IIf(!lSS0, SF4->F4_IPILICM, SS0->S0_IPILICM), "2")
aNfItem[nItem][IT_TS][TS_ICMSDIF] := IIf(lSeek, IIf(!lSS0, SF4->F4_ICMSDIF, SS0->S0_ICMSDIF), "2")
aNfItem[nItem][IT_TS][TS_QTDZERO] := IIf(lSeek, IIf(!lSS0, SF4->F4_QTDZERO, SS0->S0_QTDZERO), "2")
aNfItem[nItem][IT_TS][TS_TRFICM]  := IIf(lSeek .And. aPos[FP_F4_TRFICM], IIf(!lSS0, SF4->F4_TRFICM , SS0->S0_TRFICM), "2")
aNfItem[nItem][IT_TS][TS_OBSICM]  := IIf(lSeek .And. aPos[FP_F4_OBSICM], IIf(!lSS0, SF4->F4_OBSICM , SS0->S0_OBSICM), "2")
aNfItem[nItem][IT_TS][TS_OBSSOL]  := IIf(lSeek .And. aPos[FP_F4_OBSSOL], IIf(!lSS0, SF4->F4_OBSSOL , SS0->S0_OBSSOL), "2")
aNfItem[nItem][IT_TS][TS_PICMDIF] := IIf(lSeek .And. aPos[FP_F4_PICMDIF], IIf(!lSS0, SF4->F4_PICMDIF, SS0->S0_PICMDIF), 0)
aNfItem[nItem][IT_TS][TS_PISCRED] := IIf(lSeek .And. aPos[FP_F4_PISCRED], IIf(!lSS0, SF4->F4_PISCRED, SS0->S0_PISCRED), "3")
aNfItem[nItem][IT_TS][TS_PISCOF]  := IIf(lSeek .And. aPos[FP_F4_PISCOF], IIf(!lSS0, SF4->F4_PISCOF , SS0->S0_PISCOF), "4")
aNfItem[nItem][IT_TS][TS_CREDST]  := IIf(lSeek .And. aPos[FP_F4_CREDST], IIf(!lSS0, SF4->F4_CREDST , SS0->S0_CREDST), "2")
aNfItem[nItem][IT_TS][TS_BASEPIS] := IIf(lSeek .And. aPos[FP_F4_BASEPIS], IIf(!lSS0, SF4->F4_BASEPIS, SS0->S0_BASEPIS), 0)
aNfItem[nItem][IT_TS][TS_BASECOF] := IIf(lSeek .And. aPos[FP_F4_BASECOF], IIf(!lSS0, SF4->F4_BASECOF, SS0->S0_BASECOF), 0)
aNfItem[nItem][IT_TS][TS_ICMSST]  := IIf(lSeek .And. aPos[FP_F4_ICMSST], IIf(!lSS0, SF4->F4_ICMSST , SS0->S0_ICMSST), "1")
aNfItem[nItem][IT_TS][TS_ISSST]   := IIf(lSeek .And. aPos[FP_F4_ISSST], IIf(!lSS0, SF4->F4_ISSST  , SS0->S0_ISSST), "1")
aNfItem[nItem][IT_TS][TS_AGRPIS]  := IIf(lSeek .And. aPos[FP_F4_AGRPIS], IIf(!lSS0, SF4->F4_AGRPIS , SS0->S0_AGRPIS), "2")
aNfItem[nItem][IT_TS][TS_AGRCOF]  := IIf(lSeek .And. aPos[FP_F4_AGRCOF], IIf(!lSS0, SF4->F4_AGRCOF , SS0->S0_AGRCOF), "2")
aNfItem[nItem][IT_TS][TS_AGRRETC] := IIf(lSeek .And. aPos[FP_F4_AGRRETC], IIf(!lSS0, SF4->F4_AGRRETC, SS0->S0_AGRRETC), "2")
aNfItem[nItem][IT_TS][TS_PISBRUT] := IIf(lSeek .And. aPos[FP_F4_PISBRUT], IIf(!lSS0, SF4->F4_PISBRUT, SS0->S0_PISBRUT), "2")
aNfItem[nItem][IT_TS][TS_COFBRUT] := IIf(lSeek .And. aPos[FP_F4_COFBRUT], IIf(!lSS0, SF4->F4_COFBRUT, SS0->S0_COFBRUT), "2")
aNfItem[nItem][IT_TS][TS_PISDSZF] := IIf(lSeek .And. aPos[FP_F4_PISDSZF], IIf(!lSS0, SF4->F4_PISDSZF, SS0->S0_PISDSZF), "2")
aNfItem[nItem][IT_TS][TS_COFDSZF] := IIf(lSeek .And. aPos[FP_F4_COFDSZF], IIf(!lSS0, SF4->F4_COFDSZF, SS0->S0_COFDSZF), "2")
aNfItem[nItem][IT_TS][TS_CRDEST]  := IIf(lSeek .And. aPos[FP_F4_CRDEST], IIf(!lSS0, SF4->F4_CRDEST , SS0->S0_CRDEST), "1")
aNfItem[nItem][IT_TS][TS_CRDPRES] := IIf(lSeek .And. aPos[FP_F4_CRDPRES], IIf(!lSS0, SF4->F4_CRDPRES, SS0->S0_CRDPRES) , 0)
aNfItem[nItem][IT_TS][TS_AFRMM]	 := IIf(lSeek .And. aPos[FP_F4_AFRMM], IIf(!lSS0, SF4->F4_AFRMM  , SS0->S0_AFRMM), "N")
aNfItem[nItem][IT_TS][TS_CRDTRAN] := IIf(lSeek .And. aPos[FP_F4_CRDTRAN], IIf(!lSS0, SF4->F4_CRDTRAN, SS0->S0_CRDTRAN), 0)
aNfItem[nItem][IT_TS][TS_CALCFET] := IIf(lSeek .And. aPos[FP_F4_CALCFET], IIf(!lSS0, SF4->F4_CALCFET, SS0->S0_CALCFET), "2")
aNfItem[nItem][IT_TS][TS_DESCOND] := IIf(lSeek .And. aPos[FP_F4_DESCOND], IIf(!lSS0, SF4->F4_DESCOND, SS0->S0_DESCOND), "2")
aNfItem[nItem][IT_TS][TS_CRPREPR] := IIf(lSeek .And. aPos[FP_F4_CRPREPR], IIf(!lSS0, SF4->F4_CRPREPR, SS0->S0_CRPREPR), 0)
aNfItem[nItem][IT_TS][TS_INTBSIC] := IIf(lSeek .And. aPos[FP_F4_INTBSIC], IIf(!lSS0, SF4->F4_INTBSIC, SS0->S0_INTBSIC), "0")
aNfItem[nItem][IT_TS][TS_OPERSUC] := IIf(lSeek .And. aPos[FP_F4_OPERSUC], IIf(!lSS0, SF4->F4_OPERSUC, SS0->S0_OPERSUC), "2")
aNfItem[nItem][IT_TS][TS_CREDACU] := IIf(lSeek .And. aPos[FP_F4_CREDACU], IIf(!lSS0, SF4->F4_CREDACU, SS0->S0_CREDACU), "3")
aNfItem[nItem][IT_TS][TS_CRPRERO] := IIf(lSeek .And. aPos[FP_F4_CRPRERO], IIf(!lSS0, SF4->F4_CRPRERO, SS0->S0_CRPRERO), 0)
aNfItem[nItem][IT_TS][TS_APLIRED] := IIf(lSeek .And. aPos[FP_F4_APLIRED], IIf(!lSS0, SF4->F4_APLIRED, SS0->S0_APLIRED), "2")
aNfItem[nItem][IT_TS][TS_APLIIVA] := IIf(lSeek .And. aPos[FP_F4_APLIIVA], IIf(!lSS0, SF4->F4_APLIIVA, SS0->S0_APLIIVA), "2")
aNfItem[nItem][IT_TS][TS_APLREDP] := IIf(lSeek .And. aPos[FP_F4_APLREDP], IIf(!lSS0, SF4->F4_APLREDP, SS0->S0_APLREDP), "2")
aNfItem[nItem][IT_TS][TS_CRPREPE] := IIf(lSeek .And. aPos[FP_F4_CRPREPE], IIf(!lSS0, SF4->F4_CRPREPE, SS0->S0_CRPREPE), 0)
aNfItem[nItem][IT_TS][TS_CPRESPR] := IIf(lSeek .And. aPos[FP_F4_CPRESPR], IIf(!lSS0, SF4->F4_CPRESPR, SS0->S0_CPRESPR), 0)
aNfItem[nItem][IT_TS][TS_CALCFAB] := Iif(lSeek .And. aPos[FP_F4_CFABOV], IIf(!lSS0, SF4->F4_CFABOV, SS0->S0_CFABOV), "2")
aNfItem[nItem][IT_TS][TS_CALCFAC] := Iif(lSeek .And. aPos[FP_F4_CFACS], IIf(!lSS0, SF4->F4_CFACS, SS0->S0_CFACS), "2")
aNfItem[nItem][IT_TS][TS_CRPRESP] := IIf(lSeek .And. aPos[FP_F4_CRPRESP], IIf(!lSS0, SF4->F4_CRPRESP, SS0->S0_CRPRESP), 0)
aNfItem[nItem][IT_TS][TS_MOTICMS] := IIf(lSeek .And. aPos[FP_F4_MOTICMS], IIf(!lSS0, SF4->F4_MOTICMS, SS0->S0_MOTICMS), " ")
aNfItem[nItem][IT_TS][TS_DUPLIST] := IIf(lSeek .And. aPos[FP_F4_DUPLIST], IIf(!lSS0, SF4->F4_DUPLIST, SS0->S0_DUPLIST), "2")
aNfItem[nItem][IT_TS][TS_PR35701] := IIf(lSeek .And. aPos[FP_F4_PR35701], IIf(!lSS0, SF4->F4_PR35701, SS0->S0_PR35701), 0)
aNfItem[nItem][IT_TS][TS_CODBCC]  := IIf(lSeek .And. aPos[FP_F4_CODBCC], IIf(!lSS0, SF4->F4_CODBCC , SS0->S0_CODBCC), " ")
aNfItem[nItem][IT_TS][TS_INDNTFR] := IIf(lSeek .And. aPos[FP_F4_INDNTFR], IIf(!lSS0, SF4->F4_INDNTFR, SS0->S0_INDNTFR), " ")
aNfItem[nItem][IT_TS][TS_VENPRES] := IIf(lSeek .And. aPos[FP_F4_VENPRES], IIf(!lSS0, SF4->F4_VENPRES, SS0->S0_VENPRES), " ")
aNfItem[nItem][IT_TS][TS_REDBCCE] := IIf(lSeek .And. aPos[FP_F4_REDBCCE], IIf(!lSS0, SF4->F4_REDBCCE, SS0->S0_REDBCCE), 0)
aNfItem[nItem][IT_TS][TS_VARATAC] := IIf(lSeek .And. aPos[FP_F4_VARATAC], IIf(!lSS0, SF4->F4_VARATAC, SS0->S0_VARATAC), "")
aNfItem[nItem][IT_TS][TS_DUPLIPI] := IIf(lSeek .And. aPos[FP_F4_DUPLIPI], IIf(!lSS0, SF4->F4_DUPLIPI, SS0->S0_DUPLIPI), "2")
aNfItem[nItem][IT_TS][TS_AGRPEDG] := IIf(lSeek .And. aPos[FP_F4_AGRPEDG], IIf(!lSS0, SF4->F4_AGRPEDG, SS0->S0_AGRPEDG), "3")
aNfItem[nItem][IT_TS][TS_FRETAUT] := IIf(lSeek, IIf(!lSS0, SF4->F4_FRETAUT , SS0->S0_FRETAUT), "1")
aNfItem[nItem][IT_TS][TS_MKPCMP]  := IIf(lSeek, IIf(!lSS0, SF4->F4_MKPCMP , SS0->S0_MKPCMP), "2")
aNfItem[nItem][IT_TS][TS_CFEXT]   := IIf(lSeek, IIf(!lSS0, SF4->F4_CFEXT , SS0->S0_CFEXT), "")
aNfItem[nItem][IT_TS][TS_MKPSOL]  := IIf(lSeek .And. aPos[FP_F4_MKPSOL], IIf(!lSS0, SF4->F4_MKPSOL , SS0->S0_MKPSOL), "2")
aNfItem[nItem][IT_TS][TS_LFICMST] := IIf(lSeek .And. aPos[FP_F4_LFICMST], IIf(!lSS0, SF4->F4_LFICMST, SS0->S0_LFICMST), "N")
aNfItem[nItem][IT_TS][TS_DESPRDIC]:= IIf(lSeek .And. aPos[FP_F4_DSPRDIC], IIf(!lSS0, SF4->F4_DSPRDIC, SS0->S0_DSPRDIC), "1")
aNfItem[nItem][IT_TS][TS_CTIPI]   := IIf(lSeek .And. aPos[FP_F4_CTIPI], IIf(!lSS0, SF4->F4_CTIPI, SS0->S0_CTIPI),"  ")
aNfItem[nItem][IT_TS][TS_SITTRIB] := IIf(lSeek .And. aPos[FP_F4_SITTRIB], IIf(!lSS0, SF4->F4_SITTRIB, SS0->S0_SITTRIB), "  ")
aNfItem[nItem][IT_TS][TS_CFPS]    := IIf(lSeek .And. aPos[FP_F4_CFPS], IIf(!lSS0, SF4->F4_CFPS , SS0->S0_CFPS), "")
aNfItem[nItem][IT_TS][TS_CRPRST]  := IIf(lSeek .And. aPos[FP_F4_CRPRST], IIf(!lSS0, SF4->F4_CRPRST , SS0->S0_CRPRST), 0)
aNfItem[nItem][IT_TS][TS_IPIOBS]  := IIf(lSeek .And. aPos[FP_F4_IPIOBS], IIf(!lSS0, SF4->F4_IPIOBS , SS0->S0_IPIOBS), "1")
aNfItem[nItem][IT_TS][TS_IPIPC]   := IIf(lSeek .And. aPos[FP_F4_IPIPC], IIf(!lSS0, SF4->F4_IPIPC  , SS0->S0_IPIPC), "1")
aNfItem[nItem][IT_TS][TS_PSCFST]  := IIf(lSeek .And. aPos[FP_F4_PSCFST], IIf(!lSS0, SF4->F4_PSCFST , SS0->S0_PSCFST), "2")
aNfItem[nItem][IT_TS][TS_CRPRELE] := IIf(lSeek .And. aPos[FP_F4_CRPRELE], IIf(!lSS0, SF4->F4_CRPRELE, SS0->S0_CRPRELE), 0)
aNfItem[nItem][IT_TS][TS_CONTSOC] := IIf(lSeek .And. aPos[FP_F4_CONTSOC], IIf(!lSS0, SF4->F4_CONTSOC, SS0->S0_CONTSOC), "1")
aNfItem[nItem][IT_TS][TS_COMPRED] := IIf(lSeek .And. aPos[FP_F4_COMPRED] .And. !Empty(IIf(!lSS0, SF4->F4_COMPRED, SS0->S0_COMPRED)), IIf(!lSS0, SF4->F4_COMPRED, SS0->S0_COMPRED), "1")
aNfItem[nItem][IT_TS][TS_CSTPIS]  := IIf(lSeek .And. aPos[FP_F4_CSTPIS], IIf(!lSS0, SF4->F4_CSTPIS , SS0->S0_CSTPIS), "")
aNfItem[nItem][IT_TS][TS_CSTCOF]  := IIf(lSeek .And. aPos[FP_F4_CSTCOF], IIf(!lSS0, SF4->F4_CSTCOF , SS0->S0_CSTCOF), "")
aNfItem[nItem][IT_TS][TS_RGESPST] := IIf(lSeek .And. aPos[FP_F4_RGESPST], IIf(!lSS0, SF4->F4_RGESPST, SS0->S0_RGESPST), "2")
aNfItem[nItem][IT_TS][TS_CLFDSUL] := IIf(lSeek .And. aPos[FP_F4_CLFDSUL], IIf(!lSS0, SF4->F4_CLFDSUL, SS0->S0_CLFDSUL), "2")
aNfItem[nItem][IT_TS][TS_ALSENAR] := IIf(lSeek .And. aPos[FP_F4_ALSENAR], IIf(!lSS0, SF4->F4_ALSENAR, SS0->S0_ALSENAR), 0)
aNfItem[nItem][IT_TS][TS_ESTCRED] := IIf(lSeek .And. aPos[FP_F4_ESTCRED], IIf(!lSS0, SF4->F4_ESTCRED, SS0->S0_ESTCRED), 0)
aNfItem[nItem][IT_TS][TS_CRPRSIM] := IIf(lSeek .And. aPos[FP_F4_CRPRSIM], IIf(!lSS0, SF4->F4_CRPRSIM, SS0->S0_CRPRSIM), 0)
aNfItem[nItem][IT_TS][TS_ANTICMS] := IIf(lSeek .And. aPos[FP_F4_ANTICMS], IIf(!lSS0, SF4->F4_ANTICMS, SS0->S0_ANTICMS), "2")
aNfItem[nItem][IT_TS][TS_FECPANT] := IIf(lSeek, aNfItem[nItem][IT_TS][TS_ISEFECP], "2")
aNfItem[nItem][IT_TS][TS_ISEFECP] := IIf(lSeek .And. aPos[FP_F4_ISEFECP], IIf(!lSS0, SF4->F4_ISEFECP, SS0->S0_ISEFECP), "1")
aNfItem[nItem][IT_TS][TS_BCPCST]  := IIf(lSeek .And. aPos[FP_F4_BCPCST], IIf(!lSS0, SF4->F4_BCPCST , SS0->S0_BCPCST), "1")
aNfItem[nItem][IT_TS][TS_REDANT]  := IIf(lSeek .And. aPos[FP_F4_REDANT], IIf(!lSS0, SF4->F4_REDANT , SS0->S0_REDANT), 0)
aNfItem[nItem][IT_TS][TS_PAUTICM] := IIf(lSeek .And. aPos[FP_F4_PAUTICM], IIf(!lSS0, SF4->F4_PAUTICM, SS0->S0_PAUTICM), "1")
aNfItem[nItem][IT_TS][TS_ATACVAR] := IIf(lSeek .And. aPos[FP_F4_ATACVAR], IIf(!lSS0, SF4->F4_ATACVAR, SS0->S0_ATACVAR), "2")
aNfItem[nItem][IT_TS][TS_BSRURAL] := IIf(lSeek .And. aPos[FP_F4_BSRURAL], IIf(!lSS0, SF4->F4_BSRURAL, SS0->S0_BSRURAL), "1")
aNfItem[nItem][IT_TS][TS_DBSTCSL] := IIf(lSeek .And. aPos[FP_F4_DBSTCSL], IIf(!lSS0, SF4->F4_DBSTCSL, SS0->S0_DBSTCSL), "2")
aNfItem[nItem][IT_TS][TS_DBSTIRR] := IIf(lSeek .And. aPos[FP_F4_DBSTIRR], IIf(!lSS0, SF4->F4_DBSTIRR, SS0->S0_DBSTIRR), "2")
aNfItem[nItem][IT_TS][TS_CROUTGO] := IIf(lSeek .And. aPos[FP_F4_CROUTGO], IIf(!lSS0, SF4->F4_CROUTGO, SS0->S0_CROUTGO), 0)
aNfItem[nItem][IT_TS][TS_STCONF]  := IIf(lSeek .And. aPos[FP_F4_STCONF], IIf(!lSS0, SF4->F4_STCONF , SS0->S0_STCONF), "2")
aNfItem[nItem][IT_TS][TS_CSTISS]  := IIf(lSeek .And. aPos[FP_F4_CSTISS], IIf(!lSS0, SF4->F4_CSTISS , SS0->S0_CSTISS), "  ")
aNfItem[nItem][IT_TS][TS_BSRDICM] := IIf(lSeek .And. aPos[FP_F4_BSRDICM], IIf(!lSS0, SF4->F4_BSRDICM, SS0->S0_BSRDICM), "1")
aNfItem[nItem][IT_TS][TS_CROUTSP] := IIf(lSeek .And. aPos[FP_F4_CROUTSP], IIf(!lSS0, SF4->F4_CROUTSP, SS0->S0_CROUTSP), 0)
aNfItem[nItem][IT_TS][TS_ICMSTMT] := IIf(lSeek .And. aPos[FP_F4_ICMSTMT] .And. !Empty(IIf(!lSS0, SF4->F4_ICMSTMT, SS0->S0_ICMSTMT)), IIf(!lSS0, SF4->F4_ICMSTMT, SS0->S0_ICMSTMT) , "1")
aNfItem[nItem][IT_TS][TS_CPPRODE] := IIf(lSeek .And. aPos[FP_F4_CPPRODE], IIf(!lSS0, SF4->F4_CPPRODE, SS0->S0_CPPRODE), 0)
aNfItem[nItem][IT_TS][TS_TPPRODE] := IIf(lSeek .And. aPos[FP_F4_TPPRODE], IIf(!lSS0, SF4->F4_TPPRODE, SS0->S0_TPPRODE), " ")
aNfItem[nItem][IT_TS][TS_VDASOFT] := IIf(lSeek .And. aPos[FP_F4_VDASOFT], IIf(!lSS0, SF4->F4_VDASOFT, SS0->S0_VDASOFT), "2")
aNfItem[nItem][IT_TS][TS_ISEFERN] := IIf(lSeek .And. aPos[FP_F4_ISEFERN], IIf(!lSS0, SF4->F4_ISEFERN, SS0->S0_ISEFERN), "1")
aNfItem[nItem][IT_TS][TS_NORESPE] := IIf(lSeek .And. aPos[FP_F4_NORESP], IIf(!lSS0, SF4->F4_NORESP , SS0->S0_NORESP), "2")
aNfItem[nItem][IT_TS][TS_SOMAIPI] := IIf(lSeek .And. aPos[FP_F4_SOMAIPI], IIf(!lSS0, SF4->F4_SOMAIPI, SS0->S0_SOMAIPI), "1")
aNfItem[nItem][IT_TS][TS_APSCFST] := IIf(lSeek .And. aPos[FP_F4_APSCFST], IIf(!lSS0, SF4->F4_APSCFST, SS0->S0_APSCFST), "1")
aNfItem[nItem][IT_TS][TS_CPRCATR] := IIf(lSeek .And. aPos[FP_F4_CPRECTR], IIf(!lSS0, SF4->F4_CPRECTR, SS0->S0_CPRECTR), "2")
aNfItem[nItem][IT_TS][TS_CREDPRE] := IIf(lSeek .And. aPos[FP_F4_CREDPRE], IIf(!lSS0, SF4->F4_CREDPRE, SS0->S0_CREDPRE), 0)
aNfItem[nItem][IT_TS][TS_CONSIND] := IIf(lSeek .And. aPos[FP_F4_CONSIND], IIf(!lSS0, SF4->F4_CONSIND, SS0->S0_CONSIND), "2")
aNfItem[nItem][IT_TS][TS_ISEFEMG] := IIf(lSeek .And. aPos[FP_F4_ISEFEMG], IIf(!lSS0, SF4->F4_ISEFEMG, SS0->S0_ISEFEMG), "1")
aNfItem[nItem][IT_TS][TS_ALQCMAJ] := IIf(lSeek .And. aPos[FP_F4_MALQCOF], IIf(!lSS0, SF4->F4_MALQCOF, SS0->S0_MALQCOF), 0)
aNfItem[nItem][IT_TS][TS_ALQPMAJ] := IIf(lSeek .And. aPos[FP_F4_MALQPIS], IIf(!lSS0, SF4->F4_MALQPIS, SS0->S0_MALQPIS), 0)
aNfItem[nItem][IT_TS][TS_ISEFEMT] := IIf(lSeek .And. aPos[FP_F4_ISEFEMT], IIf(!lSS0, SF4->F4_ISEFEMT, SS0->S0_ISEFEMT), "1")
aNfItem[nItem][IT_TS][TS_IPIANTE] := IIf(lSeek .And. aPos[FP_F4_IPIANT], IIf(!lSS0, SF4->F4_IPIANT , SS0->S0_IPIANT), "2")
aNfItem[nItem][IT_TS][TS_AGREGCP] := IIf(lSeek .And. aPos[FP_F4_AGREGCP], IIf(!lSS0, SF4->F4_AGREGCP, SS0->S0_AGREGCP), "1")
aNfItem[nItem][IT_TS][TS_NATOPER] := Iif(lSeek .And. aPos[FP_F4_NATOPER], IIf(!lSS0, SF4->F4_NATOPER, SS0->S0_NATOPER), "")
aNfItem[nItem][IT_TS][TS_TPCPRES] := IIf(lSeek .And. aPos[FP_F4_TPCPRES], IIf(!lSS0, SF4->F4_TPCPRES, SS0->S0_TPCPRES), "")
aNfItem[nItem][IT_TS][TS_IDHIST]  := IIf(lSeek .And. aPos[FP_F4_IDHIST], IIf(!lSS0, SF4->F4_IDHIST , SS0->S0_IDHIST), "")
aNfItem[nItem][IT_TS][TS_DEVPARC] := IIf(lSeek .And. aPos[FP_F4_DEVPARC], IIf(!lSS0, SF4->F4_DEVPARC, SS0->S0_DEVPARC), "1")
aNfItem[nItem][IT_TS][TS_PERCATM] := IIf(lSeek .And. aPos[FP_F4_PERCATM], IIf(!lSS0, SF4->F4_PERCATM, SS0->S0_PERCATM), 0 )
aNfItem[nItem][IT_TS][TS_DICMFUN] := IIf(lSeek .And. aPos[FP_F4_DICMFUN], IIf(!lSS0, SF4->F4_DICMFUN, SS0->S0_DICMFUN), "")
aNfItem[nItem][IT_TS][TS_IMPIND]  := IIf(lSeek .And. aPos[FP_F4_IMPIND], IIf(!lSS0, SF4->F4_IMPIND , SS0->S0_IMPIND), "")
aNfItem[nItem][IT_TS][TS_OPERGAR] := IIf(lSeek .And. aPos[FP_F4_OPERGAR], IIf(!lSS0, SF4->F4_OPERGAR, SS0->S0_OPERGAR), "2")
aNfItem[nItem][IT_TS][TS_FRETISS] := IIf(lSeek .And. aPos[FP_F4_FRETISS], IIf(!lSS0, SF4->F4_FRETISS, SS0->S0_FRETISS), "1")
aNfItem[nItem][IT_TS][TS_F4_STLIQ]:= IIf(lSeek .And. aPos[FP_F4_STLIQ], IIf(!lSS0, SF4->F4_STLIQ  , SS0->S0_STLIQ), "")
aNfItem[nItem][IT_TS][TS_CV139]   := IIf(lSeek .And. aPos[FP_F4_CV139], IIf(!lSS0, SF4->F4_CV139  , SS0->S0_CV139), "2")
aNfItem[nItem][IT_TS][TS_RFETALG] := IIf(lSeek .And. aPos[FP_F4_RFETALG], IIf(!lSS0, SF4->F4_RFETALG, SS0->S0_RFETALG), "")
aNfItem[nItem][IT_TS][TS_PARTICM] := IIf(lSeek .And. aPos[FP_F4_PARTICM], IIf(!lSS0, SF4->F4_PARTICM, SS0->S0_PARTICM), "")
aNfItem[nItem][IT_TS][TS_BSICMRE] := IIF(lSeek .And. aPos[FP_F4_BSICMRE], IIf(!lSS0, SF4->F4_BSICMRE, SS0->S0_BSICMRE), "")
aNfItem[nItem][IT_TS][TS_ALICRST] := IIF(lSeek .And. aPos[FP_F4_ALICRST], IIf(!lSS0, SF4->F4_ALICRST, SS0->S0_ALICRST), 0)
aNfItem[nItem][IT_TS][TS_TRANFIL] := IIf(lSeek .And. aPos[FP_F4_TRANFIL], IIf(!lSS0, SF4->F4_TRANFIL, SS0->S0_TRANFIL), "2")
aNfItem[nItem][IT_TS][TS_IPIVFCF] := IIf(lSeek .And. aPos[FP_IPIVFCF], IIf(!lSS0, SF4->F4_IPIVFCF, SS0->S0_IPIVFCF), "1")
aNfItem[nItem][IT_TS][TS_RDBSICM] := IIf(lSeek .And. aPos[FP_F4_RDBSICM], IIf(!lSS0, SF4->F4_RDBSICM, SS0->S0_RDBSICM), "2")
aNfItem[nItem][IT_TS][TS_CFAMAD]  := IIf(lSeek .And. aPos[FP_CFAMAD], IIf(!lSS0, SF4->F4_CFAMAD , SS0->S0_CFAMAD), "2")
aNfItem[nItem][IT_TS][TS_DESCISS] := IIf(lSeek .And. aPos[FP_F4_DESCISS], IIf(!lSS0, SF4->F4_DESCISS, SS0->S0_DESCISS), "1")
aNfItem[nItem][IT_TS][TS_OUTPERC] := IIf(lSeek .And. aPos[FP_F4_OUTPERC], IIf(!lSS0, SF4->F4_OUTPERC, SS0->S0_OUTPERC), 0)
aNfItem[nItem][IT_TS][TS_PISMIN]  := IIf(lSeek .And. aPos[FP_F4_PISMIN], IIf(!lSS0, SF4->F4_PISMIN, SS0->S0_PISMIN), "2")
aNfItem[nItem][IT_TS][TS_COFMIN]  := IIf(lSeek .And. aPos[FP_F4_COFMIN], IIf(!lSS0, SF4->F4_COFMIN, SS0->S0_COFMIN), "2")
aNfItem[nItem][IT_TS][TS_IPIMIN]  := IIf(lSeek .And. aPos[FP_F4_IPIMIN], IIf(!lSS0, SF4->F4_IPIMIN, SS0->S0_IPIMIN), "2")
aNfItem[nItem][IT_TS][TS_CUSENTR] := IIf(lSeek .And. aPos[FP_F4_CUSENTR], IIf(!lSS0, SF4->F4_CUSENTR, SS0->S0_CUSENTR), "2")
aNfItem[nItem][IT_TS][TS_GRPCST]  := IIf(lSeek .And. aPos[FP_F4_GRPCST], IIf(!lSS0, SF4->F4_GRPCST, SS0->S0_GRPCST), "")
aNfItem[nItem][IT_TS][TS_IPIPECR] := IIf(lSeek .And. aPos[FP_F4_IPIPECR], IIf(!lSS0, SF4->F4_IPIPECR, SS0->S0_IPIPECR), 0)
aNfItem[nItem][IT_TS][TS_CALCCPB] := IIf(lSeek .And. aPos[FP_F4_CALCCPB], IIf(!lSS0, SF4->F4_CALCCPB, SS0->S0_CALCCPB), "2")
aNfItem[nItem][IT_TS][TS_DIFAL]   := IIf(lSeek .And. aPos[FP_F4_DIFAL], IIf(!lSS0, SF4->F4_DIFAL, SS0->S0_DIFAL), "")
aNfItem[nItem][IT_TS][TS_BASCMP]  := IIf(lSeek  .And. aPos[FP_F4_BASCMP], IIf(!lSS0, SF4->F4_BASCMP, SS0->S0_BASCMP), 0)
aNfItem[nItem][IT_TS][TS_TXAPIPI] := IIf(lSeek  .And. aPos[FP_F4_TXAPIPI], IIf(!lSS0, SF4->F4_TXAPIPI, SS0->S0_TXAPIPI), 0)
aNfItem[nItem][IT_TS][TS_FTRICMS] := IIf(lSeek  .And. aPos[FP_F4_FTRICMS], IIf(!lSS0, SF4->F4_FTRICMS, SS0->S0_TXAPIPI), 0)
aNfItem[nItem][IT_TS][TS_AGRISS]  := IIf(lSeek .And. aPos[FP_F4_AGRISS], IIf(!lSS0, SF4->F4_AGRISS , SS0->S0_AGRISS), "2")
aNfItem[nItem][IT_TS][TS_CFUNDES] := IIf(lSeek .And. aPos[FP_F4_CFUNDES], IIf(!lSS0, SF4->F4_CFUNDES, SS0->S0_CFUNDES), "2")
aNfItem[nItem][IT_TS][TS_CIMAMT]  := IIf(lSeek .And. aPos[FP_F4_CIMAMT], IIf(!lSS0, SF4->F4_CIMAMT, SS0->S0_CIMAMT), "2")
aNfItem[nItem][IT_TS][TS_CFASE]   := IIf(lSeek .And. aPos[FP_F4_CFASE], IIf(!lSS0, SF4->F4_CFASE, SS0->S0_CFASE), "2")
aNfItem[nItem][IT_TS][TS_INDVF]   := Iif(lSeek .And. aPos[FP_F4_INDVF], IIf(!lSS0, SF4->F4_INDVF, SS0->S0_INDVF), "2")
aNfItem[nItem][IT_TS][TS_CSOSN]   := IIf(lSeek .And. aPos[FP_F4_CSOSN], IIf(!lSS0, SF4->F4_CSOSN, SS0->S0_CSOSN), "   ")
aNfItem[nItem][IT_TS][TS_ALIQPRO] := IIf(lSeek .And. aPos[FP_F4_ALIQPRO], IIf(!lSS0, SF4->F4_ALIQPRO, SS0->S0_ALIQPRO), 0)
aNfItem[nItem][IT_TS][TS_ALQFEEF] := IIf(lSeek .And. aPos[FP_F4_ALQFEEF], IIf(!lSS0, SF4->F4_ALQFEEF, SS0->S0_ALQFEEF) , 0)
aNfItem[nItem][IT_TS][TS_DEDDIF]  := IIf(lSeek .And. aPos[FP_F4_DEDDIF], IIf(!lSS0, SF4->F4_DEDDIF, SS0->S0_DEDDIF), "1")
aNfItem[nItem][IT_TS][TS_FCALCPR] := IIf(lSeek .And. aPos[FP_F4_FCALCPR], IIf(!lSS0, SF4->F4_FCALCPR, SS0->S0_FCALCPR), "")
aNfItem[nItem][IT_TS][TS_DIFALPC] := IIf(lSeek .And. aPos[FP_F4_DIFALPC], IIf(!lSS0, SF4->F4_DIFALPC, SS0->S0_DIFALPC), "")
aNFItem[nItem][IT_TS][TS_COLVDIF] := Iif(lSeek .AND. aPos[FP_F4_COLVDIF], IIF(!lSS0 , SF4->F4_COLVDIF , SS0->S0_COLVDIF ), "")
aNfItem[nItem][IT_TS][TS_STREDU]  := IIf(lSeek .And. aPos[FP_F4_STREDU], IIf(!lSS0, SF4->F4_STREDU, SS0->S0_STREDU) , "")
aNfItem[nItem][IT_TS][TS_FEEF]    := IIf(lSeek .And. aPos[FP_F4_FEEF], IIf(!lSS0, SF4->F4_FEEF, SS0->S0_FEEF) , "")
aNfItem[nItem][IT_TS][TS_BICMCMP] := IIf(lSeek .And. aPos[FP_F4_BICMCMP], IIf(!lSS0, SF4->F4_BICMCMP, Iif(aPos[FP_S0_BICMCMP],SS0->S0_BICMCMP,"")) ,"")
aNfItem[nItem][IT_TS][TS_CSENAR]  := IIf(lSeek .And. aPos[FP_F4_CSENAR], IIf(!lSS0, SF4->F4_CSENAR, SS0->S0_CSENAR) ,"2")
aNfItem[nItem][IT_TS][TS_CINSS]   := IIf(lSeek .And. aPos[FP_F4_CINSS], IIf(!lSS0, SF4->F4_CINSS, SS0->S0_CINSS) ,"2")
aNfItem[nItem][IT_TS][TS_APLREPC] := IIf(lSeek .And. aPos[FP_F4_APLREPC], IIf(!lSS0, SF4->F4_APLREPC, SS0->S0_APLREPC) ,"4")
aNfItem[nItem][IT_TS][TS_INDISEN] := IIf(lSeek .And. aPos[FP_F4_INDISEN], IIf(!lSS0, SF4->F4_INDISEN, SS0->S0_INDISEN) ,"2")
aNfItem[nItem][IT_TS][TS_INFITEM] := IIf(lSeek .And. aPos[FP_F4_INFITEM], IIf(!lSS0, SF4->F4_INFITEM, SS0->S0_INFITEM) , "")


If lSeek
	If aDic[AI_CC7] .And. aDic[AI_CC6] .And. GTamMxFis(TAM_CC7_CODLAN) == 10 .And. aPos[FP_CC7_TPREG]
		dbSelectArea("CC7")
		dbSetOrder(1)
		If CC7->(MsSeek(xFilial("CC7")+SF4->F4_CODIGO))
			While !CC7->(Eof()) .And. xFilial("CC7")+CC7->CC7_TES==xFilial("CC7")+SF4->F4_CODIGO
				// Codigos de Ajuste de Documento Fiscal (Tabela CC6)
				If (!(CC7->CC7_TPREG == "NA")) .And. (CC6->(MsSeek(xFilial("CC6")+CC7->CC7_CODLAN)))
					//Somente serao considerados lançamentos da UF do contribuinte
					//Caso o lançamento nao seja de Apuração Propria, o lançamento podera ser de qualquer UF
					If CC6->CC6_STUF == aSX6[MV_ESTADO]  .Or. CC6->CC6_TPAPUR <> "0"
						aAdd( aNFItem[nItem][IT_TS][TS_LANCFIS] ,;
								{	CC7->CC7_CODLAN ,;									// 01 - Codigo de Ajuste
								Iif( aPos[FP_CC7_IFCOMP] , CC7->CC7_IFCOMP , "" ) ,;	// 02 - Codigo da Informacao Complementar
								Iif( aPos[FP_CC7_CODREF] , CC7->CC7_CODREF , "" ) ,;	// 03 - Codigo do Reflexo
								Iif( aPos[FP_CC7_CLANC]  , CC7->CC7_CLANC  , ""  ) ,; 	// 04 - Complemento registro 0460
								Iif( aPos[FP_CC7_GUIA]   , CC7->CC7_GUIA	, "2" ) ,;	// 05 - Gera Guia de Recolhimento
								"1"} )		// 06 - Campo com código utilizado na Tes
					EndIf
				// Codigos de Ajuste de Apuracao (Tabela CDO)
				ElseIf Empty( CC7->CC7_CODLAN ) .And. aPos[FP_CC7_CLANAP] .And. !Empty( CC7->CC7_CLANAP )
					aAdd( aNFItem[nItem][IT_TS][TS_LANCFIS] ,;
							{	CC7->CC7_CLANAP ,;
							Iif( aPos[FP_CC7_IFCOMP] , CC7->CC7_IFCOMP , "" ) ,;
							Iif( aPos[FP_CC7_CODREF] , CC7->CC7_CODREF , "" ) ,;
							Iif( aPos[FP_CC7_CLANC]  , CC7->CC7_CLANC  , ""  ) ,;
							Iif( aPos[FP_CC7_GUIA]   , CC7->CC7_GUIA	, "2" ),;
							"2"} )
				ElseIf aPos[FP_CC7_CODIPI] .And. !Empty( CC7->CC7_CODIPI ) .And.  Empty( CC7->CC7_CODLAN ) .And. Empty( CC7->CC7_CLANAP )
						aAdd(  aNFItem[nItem][IT_TS][TS_LANCFIS] ,;
								{	CC7->CC7_CODIPI ,;
									Iif( aPos[FP_CC7_IFCOMP] , CC7->CC7_IFCOMP , ""  ) ,;
									Iif( aPos[FP_CC7_CODREF] , CC7->CC7_CODREF , ""  ) ,;
									Iif( aPos[FP_CC7_CLANC]  , CC7->CC7_CLANC  , ""  ) ,;
									Iif( aPos[FP_CC7_GUIA]   , CC7->CC7_GUIA  , "2" ) ,;
									"3"} )
				EndIf
				CC7->(dbSkip())
			EndDo
		EndIf
	EndIf
	RestArea(aArea)

	// Atualizo a referencia de cabecalho NF_PPDIFAL pois ela depende da config. do TES.
	// A atualizacao eh feita nesta funcao para que nao seja necessario faze-la nas demais
	// funcoes de impostos. Toda vez que o TES for carregado ela sera atualizada.
	aNfCab[NF_PPDIFAL]	:= .F.
	aNfCab[NF_PPDIFAL] := FisChkPDif(nItem,aMVPPDIFAL,aNfCab,aNfItem)

EndIf
cTes := aNfItem[nItem][IT_TS][TS_CODIGO]
If nItem <> Nil
	aNfItem[nItem][IT_IDSF4] := aNfItem[nItem][IT_TS][TS_IDHIST]
EndIf
Return

/*/
MaFisIniCpo -Alexandre Lemes -08/12/2012
/*/
Function xFisIniCpo(nItem,lSeek,aSX6,aNfItem,lHistorico,aNfCab,aPos,aDic,cCpoSBZ,cAlsItem,cAliasPROD)
Local lSBI       := cAliasPROD == "SBI"
Local lArqProp   := Iif(cPaisLoc == "BRA",aSX6[MV_ARQPROP], .F.)
Local lSS4  := .F.
Local lSS6  := .F.
Local lSS5  := .F.
Local lSeekCG1	:= .F.
Local cHistSB1   := ""
Local cHistCFC   := ""
Local cHistSBZ   := ""
Local cHistSB5   := ""
Local cCodAtv	 := ""
Local lNewProd	 := .T.

DEFAULT lSeek    := .T.

If lSeek
	If aNfItem[nItem][IT_RECNOSB1] <> 0 .And. cAliasPROD == "SB1"
		(cAliasPROD)->(MsGoto(aNfItem[nItem][IT_RECNOSB1]))
			//Verifica se houve alteração do produto apos a inclusão no MaFisIniLoad
			//Caso Sim é neessario realizar seek do novo produto  			
		IF ( Alltrim(aNfItem[nItem][IT_PRODUTO]) == Alltrim((cAliasPROD)->B1_COD)) 
			//Complemento do produto
			SB5->(dbSetOrder(1))
			SB5->(MsSeek(xFilial("SB5")+aNfItem[nItem][IT_PRODUTO]))
			lNewProd := .F.
		Endif
	Endif
	
	IF lNewProd
		If cAliasPROD == "SBI"
			SBI->(dbSetOrder(1))
			SBI->(MsSeek(xFilial("SBI")+aNfItem[nItem][IT_PRODUTO]))
		EndIf
		//Produto
		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+aNfItem[nItem][IT_PRODUTO]))
		//Complemento do produto
		SB5->(dbSetOrder(1))
		SB5->(MsSeek(xFilial("SB5")+aNfItem[nItem][IT_PRODUTO]))
		If lHistorico
			//Se for reprocessamento,  e tiver habilitado para buscar os Historico Fiscais,
			//verifico se o ID do historico do Cliente e igual ao que foi gravado na Nota. Se for
			//igual é porque nao teve alterações no cliente após a emissão. Se for diferente,
			//é porque teve alterações no cadastro, e entao os dados são carregados da tabela de
			//Historico(SS2).
			If( aNfCab[NF_CLIFOR]=="C" .And. aNfCab[NF_TIPONF]<>"D") .Or.( aNfCab[NF_CLIFOR]=="F" .And. aNfCab[NF_TIPONF]$"D|B")
				cHistSB1 := (cAlsItem)->D2_IDSB1
				cHistSB5 := (cAlsItem)->D2_IDSB5
			Else
				cHistSB1 := (cAlsItem)->D1_IDSB1
				cHistSB5 := (cAlsItem)->D1_IDSB5
			End
			If cPaisLoc == "BRA" .And. Alltrim(SB1->B1_IDHIST)<>Alltrim(cHistSB1)
				SS4->(dbSetOrder(1))
				SS4->(MsSeek(xFilial("SS4")+cHistSB1))
				lSS4 := .T.
			EndIf
			If cPaisLoc == "BRA" .And. Alltrim(SB5->B5_IDHIST) <> Alltrim(cHistSB5)
				SS5->(dbSetOrder(1))
				SS5->(MsSeek(xFilial("SS5")+cHistSB5))
				lSS5 := .T.
			EndIf
		EndIf
	EndIf
	If cPaisLoc == "BRA"
		// Carga da CG1
		If !Empty(aSX6[MV_CPRBATV])
			cCodAtv := aSX6[MV_CPRBATV]
		Else
			cCodAtv := IIf(aPos[FP_B5_CODATIV], SB5->B5_CODATIV, "")
		Endif
		If aDic[AI_CG1]
			CG1->(dbSetOrder(1))
			If CG1->(MsSeek(xFilial("CG1")+cCodAtv+DTOS(CTOD("  /  /    "))))
				lSeekCG1 := .T.
			EndIf
		EndIf
	EndIf
EndIf

aNfItem[nItem][IT_PRD][SB_COD]    := IIf( lSBI .And. aPos[FP_BI_COD]    , SBI->BI_COD    , IIf( aPos[FP_B1_COD]    .And. lSeek , IIf(lSS4, SS4->S4_COD    , SB1->B1_COD    ), " " ) )
aNfItem[nItem][IT_PRD][SB_GRTRIB] := IIf( lSBI .And. aPos[FP_BI_GRTRIB] , SBI->BI_GRTRIB , IIf( aPos[FP_B1_GRTRIB] .And. lSeek , IIf(lSS4, SS4->S4_GRTRIB , SB1->B1_GRTRIB ), " " ) )
aNfItem[nItem][IT_PRD][SB_CODIF]  := IIf( lSBI .And. aPos[FP_BI_CODIF]  , SBI->BI_CODIF  , IIf( aPos[FP_B1_CODIF]  .And. lSeek , IIf(lSS4 .And. aPos[FP_S4_CODIF] , SS4->S4_CODIF  , SB1->B1_CODIF  ), " " ) )
aNfItem[nItem][IT_PRD][SB_RSATIVO]:= IIf( lSBI .And. aPos[FP_BI_RSATIVO], SBI->BI_RSATIVO, IIf( aPos[FP_B1_RSATIVO].And. lSeek , IIf(lSS4, SS4->S4_RSATIVO, SB1->B1_RSATIVO), " " ) )
aNfItem[nItem][IT_PRD][SB_POSIPI] := IIf( lSBI .And. aPos[FP_BI_POSIPI] , SBI->BI_POSIPI , IIf( aPos[FP_B1_POSIPI] .And. lSeek , IIf(lSS4, SS4->S4_POSIPI , SB1->B1_POSIPI ), " " ) )
aNfItem[nItem][IT_PRD][SB_UM]     := IIf( lSBI .And. aPos[FP_BI_UM]     , SBI->BI_UM     , IIf( aPos[FP_B1_UM]     .And. lSeek , IIf(lSS4, SS4->S4_UM     , SB1->B1_UM     ), " " ) )
aNfItem[nItem][IT_PRD][SB_SEGUM]  := IIf( lSBI .And. aPos[FP_BI_SEGUM]  , SBI->BI_SEGUM  , IIf( aPos[FP_B1_SEGUM]  .And. lSeek , IIf(lSS4, SS4->S4_SEGUM  , SB1->B1_SEGUM  ), " " ) )
aNfItem[nItem][IT_PRD][SB_AFABOV] := IIf( lSBI .And. aPos[FP_BI_AFABOV] , SBI->BI_AFABOV , IIf( aPos[FP_B1_AFABOV] .And. lSeek , IIf(lSS4, SS4->S4_AFABOV , SB1->B1_AFABOV ), 0   ) )
aNfItem[nItem][IT_PRD][SB_AFACS]  := IIf( lSBI .And. aPos[FP_BI_AFACS]  , SBI->BI_AFACS  , IIf( aPos[FP_B1_AFACS]  .And. lSeek , IIf(lSS4, SS4->S4_AFACS  , SB1->B1_AFACS  ), 0   ) )
aNfItem[nItem][IT_PRD][SB_AFETHAB]:= IIf( lSBI .And. aPos[FP_BI_AFETHAB], SBI->BI_AFETHAB, IIf( aPos[FP_B1_AFETHAB].And. lSeek , IIf(lSS4, SS4->S4_AFETHAB, SB1->B1_AFETHAB), 0   ) )
aNfItem[nItem][IT_PRD][SB_TFETHAB]:= IIf( lSBI .And. aPos[FP_BI_TFETHAB], SBI->BI_TFETHAB, IIf( aPos[FP_B1_TFETHAB].And. lSeek , IIf(lSS4, SS4->S4_TFETHAB, SB1->B1_TFETHAB), " " ) )
aNfItem[nItem][IT_PRD][SB_PICM]   := IIf( lSBI .And. aPos[FP_BI_PICM]   , SBI->BI_PICM   , IIf( aPos[FP_B1_PICM]   .And. lSeek , IIf(lSS4, SS4->S4_PICM   , SB1->B1_PICM   ), 0   ) )
aNfItem[nItem][IT_PRD][SB_FECOP]  := IIf( lSBI .And. aPos[FP_BI_FECOP]  , SBI->BI_FECOP  , IIf( aPos[FP_B1_FECOP]  .And. lSeek , IIf(lSS4, SS4->S4_FECOP  , SB1->B1_FECOP  ), " " ) )
aNfItem[nItem][IT_PRD][SB_ALFECOP]:= IIf( lSBI .And. aPos[FP_BI_ALFECOP], SBI->BI_ALFECOP, IIf( aPos[FP_B1_ALFECOP].And. lSeek , IIf(lSS4, SS4->S4_ALFECOP, SB1->B1_ALFECOP), 0   ) )
aNfItem[nItem][IT_PRD][SB_ALIQISS]:= IIf( lSBI .And. aPos[FP_BI_ALIQISS], SBI->BI_ALIQISS, IIf( aPos[FP_B1_ALIQISS].And. lSeek , IIf(lSS4, SS4->S4_ALIQISS, SB1->B1_ALIQISS), 0   ) )
aNfItem[nItem][IT_PRD][SB_IMPZFRC]:= IIf( lSBI .And. aPos[FP_BI_IMPZFRC], SBI->BI_IMPZFRC, IIf( aPos[FP_B1_IMPZFRC].And. lSeek , IIf(lSS4, SS4->S4_IMPZFRC, SB1->B1_IMPZFRC), " " ) )
aNfItem[nItem][IT_PRD][SB_INT_ICM]:= IIf( lSBI .And. aPos[FP_BI_INT_ICM], SBI->BI_INT_ICM, IIf( aPos[FP_B1_INT_ICM].And. lSeek , IIf(lSS4, SS4->S4_INT_ICM, SB1->B1_INT_ICM), 0   ) )
aNfItem[nItem][IT_PRD][SB_PR43080]:= IIf( lSBI .And. aPos[FP_BI_PR43080], SBI->BI_PR43080, IIf( aPos[FP_B1_PR43080].And. lSeek , IIf(lSS4, SS4->S4_PR43080, SB1->B1_PR43080), 0   ) ) 
aNfItem[nItem][IT_PRD][SB_PRINCMG]:= IIf( lSBI .And. aPos[FP_BI_PRINCMG], SBI->BI_PRINCMG, IIf( aPos[FP_B1_PRINCMG].And. lSeek , IIf(lSS4, SS4->S4_PRINCMG, SB1->B1_PRINCMG), 0   ) )
aNfItem[nItem][IT_PRD][SB_ALFECST]:= IIf( lSBI .And. aPos[FP_BI_ALFECST], SBI->BI_ALFECST, IIf( aPos[FP_B1_ALFECST].And. lSeek , IIf(lSS4, SS4->S4_ALFECST, SB1->B1_ALFECST), 0   ) )
aNfItem[nItem][IT_PRD][SB_PICMENT]:= IIf( lSBI .And. aPos[FP_BI_PICMENT], SBI->BI_PICMENT, IIf( aPos[FP_B1_PICMENT].And. lSeek , IIf(lSS4, SS4->S4_PICMENT, SB1->B1_PICMENT), 0   ) )
aNfItem[nItem][IT_PRD][SB_PICMRET]:= IIf( lSBI .And. aPos[FP_BI_PICMRET], SBI->BI_PICMRET, IIf( aPos[FP_B1_PICMRET].And. lSeek , IIf(lSS4, SS4->S4_PICMRET, SB1->B1_PICMRET), 0   ) )
aNfItem[nItem][IT_PRD][SB_IVAAJU] := IIf( lSBI .And. aPos[FP_BI_IVAAJU] , SBI->BI_IVAAJU , IIf( aPos[FP_B1_IVAAJU] .And. lSeek , IIf(lSS4, SS4->S4_IVAAJU , SB1->B1_IVAAJU ), " " ) )
aNfItem[nItem][IT_PRD][SB_RASTRO] := IIf( lSBI .And. aPos[FP_BI_RASTRO] , SBI->BI_RASTRO , IIf( aPos[FP_B1_RASTRO] .And. lSeek , IIf(lSS4, SS4->S4_RASTRO , SB1->B1_RASTRO ), " " ) )
aNfItem[nItem][IT_PRD][SB_VLR_ICM]:= IIf( lSBI .And. aPos[FP_BI_VLR_ICM], SBI->BI_VLR_ICM, IIf( aPos[FP_B1_VLR_ICM].And. lSeek , IIf(lSS4, SS4->S4_VLR_ICM, SB1->B1_VLR_ICM), 0   ) )
aNfItem[nItem][IT_PRD][SB_VLR_PIS]:= IIf( lSBI .And. aPos[FP_BI_VLR_PIS], SBI->BI_VLR_PIS, IIf( aPos[FP_B1_VLR_PIS].And. lSeek , IIf(lSS4, SS4->S4_VLR_PIS, SB1->B1_VLR_PIS), 0   ) )
aNfItem[nItem][IT_PRD][SB_VLR_COF]:= IIf( lSBI .And. aPos[FP_BI_VLR_COF], SBI->BI_VLR_COF, IIf( aPos[FP_B1_VLR_COF].And. lSeek , IIf(lSS4, SS4->S4_VLR_COF, SB1->B1_VLR_COF), 0   ) )
aNfItem[nItem][IT_PRD][SB_ORIGEM] := IIf( lSBI .And. aPos[FP_BI_ORIGEM] , SBI->BI_ORIGEM , IIf( aPos[FP_B1_ORIGEM] .And. lSeek , IIf(lSS4, SS4->S4_ORIGEM , SB1->B1_ORIGEM ), " " ) )
aNfItem[nItem][IT_PRD][SB_CRDEST] := IIf( lSBI .And. aPos[FP_BI_CRDEST] , SBI->BI_CRDEST , IIf( aPos[FP_B1_CRDEST] .And. lSeek , IIf(lSS4, SS4->S4_CRDEST , SB1->B1_CRDEST ), 0   ) )
aNfItem[nItem][IT_PRD][SB_CODISS] := IIf( lSBI .And. aPos[FP_BI_CODISS] , SBI->BI_CODISS , IIf( aPos[FP_B1_CODISS] .And. lSeek , IIf(lSS4, SS4->S4_CODISS , SB1->B1_CODISS ), " " ) )
aNfItem[nItem][IT_PRD][SB_TNATREC]:= IIf( lSBI .And. aPos[FP_BI_TNATREC], SBI->BI_TNATREC, IIf( aPos[FP_B1_TNATREC].And. lSeek , IIf(lSS4, SS4->S4_TNATREC, SB1->B1_TNATREC), " " ) )
aNfItem[nItem][IT_PRD][SB_CNATREC]:= IIf( lSBI .And. aPos[FP_BI_CNATREC], SBI->BI_CNATREC, IIf( aPos[FP_B1_CNATREC].And. lSeek , IIf(lSS4, SS4->S4_CNATREC, SB1->B1_CNATREC), " " ) )
aNfItem[nItem][IT_PRD][SB_GRPNATR]:= IIf( lSBI .And. aPos[FP_BI_GRPNATR], SBI->BI_GRPNATR, IIf( aPos[FP_B1_GRPNATR].And. lSeek , IIf(lSS4, SS4->S4_GRPNATR, SB1->B1_GRPNATR), " " ) )
aNfItem[nItem][IT_PRD][SB_DTFIMNT]:= IIf( lSBI .And. aPos[FP_BI_DTFIMNT], SBI->BI_DTFIMNT, IIf( aPos[FP_B1_DTFIMNT].And. lSeek , IIf(lSS4, SS4->S4_DTFIMNT, SB1->B1_DTFIMNT), CtoD("") ) )
aNfItem[nItem][IT_PRD][SB_IPI]    := IIf( lSBI .And. aPos[FP_BI_IPI]    , SBI->BI_IPI    , IIf( aPos[FP_B1_IPI]    .And. lSeek , IIf(lSS4, SS4->S4_IPI    , SB1->B1_IPI    ), 0   ) )
aNfItem[nItem][IT_PRD][SB_VLR_IPI]:= IIf( lSBI .And. aPos[FP_BI_VLR_IPI], SBI->BI_VLR_IPI, IIf( aPos[FP_B1_VLR_IPI].And. lSeek , IIf(lSS4, SS4->S4_VLR_IPI, SB1->B1_VLR_IPI), 0   ) )
aNfItem[nItem][IT_PRD][SB_CNAE]   := IIf( lSBI .And. aPos[FP_BI_CNAE]   , SBI->BI_CNAE   , IIf( aPos[FP_B1_CNAE]   .And. lSeek , IIf(lSS4, SS4->S4_CNAE   , SB1->B1_CNAE   ), " " ) )
aNfItem[nItem][IT_PRD][SB_REGRISS]:= IIf( lSBI .And. aPos[FP_BI_REGRISS], SBI->BI_REGRISS, IIf( aPos[FP_B1_REGRISS].And. lSeek , IIf(lSS4, SS4->S4_REGRISS, SB1->B1_REGRISS), " " ) )
aNfItem[nItem][IT_PRD][SB_REDINSS]:= IIf( lSBI .And. aPos[FP_BI_REDINSS], SBI->BI_REDINSS, IIf( aPos[FP_B1_REDINSS].And. lSeek , IIf(lSS4, SS4->S4_REDINSS, SB1->B1_REDINSS), 0   ) )
aNfItem[nItem][IT_PRD][SB_INSS]   := IIf( lSBI .And. aPos[FP_BI_INSS]   , SBI->BI_INSS   , IIf( aPos[FP_B1_INSS]   .And. lSeek , IIf(lSS4, SS4->S4_INSS   , SB1->B1_INSS   ), " " ) )
aNfItem[nItem][IT_PRD][SB_IRRF]   := IIf( lSBI .And. aPos[FP_BI_IRRF]   , SBI->BI_IRRF   , IIf( aPos[FP_B1_IRRF]   .And. lSeek , IIf(lSS4, SS4->S4_IRRF   , SB1->B1_IRRF   ), " " ) )
aNfItem[nItem][IT_PRD][SB_REDIRRF]:= IIf( lSBI .And. aPos[FP_BI_REDIRRF], SBI->BI_REDIRRF, IIf( aPos[FP_B1_REDIRRF].And. lSeek , IIf(lSS4, SS4->S4_REDIRRF, SB1->B1_REDIRRF), 0   ) )
aNfItem[nItem][IT_PRD][SB_REDPIS] := IIf( lSBI .And. aPos[FP_BI_REDPIS] , SBI->BI_REDPIS , IIf( aPos[FP_B1_REDPIS] .And. lSeek , IIf(lSS4, SS4->S4_REDPIS , SB1->B1_REDPIS ), 0   ) )
aNfItem[nItem][IT_PRD][SB_PPIS]   := IIf( lSBI .And. aPos[FP_BI_PPIS]   , SBI->BI_PPIS   , IIf( aPos[FP_B1_PPIS]   .And. lSeek , IIf(lSS4, SS4->S4_PPIS   , SB1->B1_PPIS   ), 0   ) )
aNfItem[nItem][IT_PRD][SB_PIS]    := IIf( lSBI .And. aPos[FP_BI_PIS]    , SBI->BI_PIS    , IIf( aPos[FP_B1_PIS]    .And. lSeek , IIf(lSS4, SS4->S4_PIS    , SB1->B1_PIS    ), " " ) )
aNfItem[nItem][IT_PRD][SB_CHASSI] := IIf( lSBI .And. aPos[FP_BI_CHASSI] , SBI->BI_CHASSI , IIf( aPos[FP_B1_CHASSI] .And. lSeek , IIf(lSS4  .And. aPos[FP_S4_CHASSI], SS4->S4_CHASSI , SB1->B1_CHASSI ), " " ) )
aNfItem[nItem][IT_PRD][SB_RETOPER]:= IIf( lSBI .And. aPos[FP_BI_RETOPER], SBI->BI_RETOPER, IIf( aPos[FP_B1_RETOPER].And. lSeek , IIf(lSS4, SS4->S4_RETOPER, SB1->B1_RETOPER), " " ) )
aNfItem[nItem][IT_PRD][SB_REDCOF] := IIf( lSBI .And. aPos[FP_BI_REDCOF] , SBI->BI_REDCOF , IIf( aPos[FP_B1_REDCOF] .And. lSeek , IIf(lSS4, SS4->S4_REDCOF , SB1->B1_REDCOF ), 0   ) )
aNfItem[nItem][IT_PRD][SB_PCOFINS]:= IIf( lSBI .And. aPos[FP_BI_PCOFINS], SBI->BI_PCOFINS, IIf( aPos[FP_B1_PCOFINS].And. lSeek , IIf(lSS4, SS4->S4_PCOFINS, SB1->B1_PCOFINS), 0   ) )
aNfItem[nItem][IT_PRD][SB_COFINS] := IIf( lSBI .And. aPos[FP_BI_COFINS] , SBI->BI_COFINS , IIf( aPos[FP_B1_COFINS] .And. lSeek , IIf(lSS4, SS4->S4_COFINS , SB1->B1_COFINS ), " " ) )
aNfItem[nItem][IT_PRD][SB_PCSLL]  := IIf( lSBI .And. aPos[FP_BI_PCSLL]  , SBI->BI_PCSLL  , IIf( aPos[FP_B1_PCSLL]  .And. lSeek , IIf(lSS4, SS4->S4_PCSLL  , SB1->B1_PCSLL  ), 0   ) )
aNfItem[nItem][IT_PRD][SB_CONTSOC]:= IIf( lSBI .And. aPos[FP_BI_CONTSOC], SBI->BI_CONTSOC, IIf( aPos[FP_B1_CONTSOC].And. lSeek , IIf(lSS4, SS4->S4_CONTSOC, SB1->B1_CONTSOC), " " ) )
aNfItem[nItem][IT_PRD][SB_PRFDSUL]:= IIf( lSBI .And. aPos[FP_BI_PRFDSUL], SBI->BI_PRFDSUL, IIf( aPos[FP_B1_PRFDSUL].And. lSeek , IIf(lSS4, SS4->S4_PRFDSUL, SB1->B1_PRFDSUL), 0   ) )
aNfItem[nItem][IT_PRD][SB_FECP]   := IIf( lSBI .And. aPos[FP_BI_FECP]   , SBI->BI_FECP   , IIf( aPos[FP_B1_FECP]   .And. lSeek , IIf(lSS4, SS4->S4_FECP   , SB1->B1_FECP   ), 0   ) )
aNfItem[nItem][IT_PRD][SB_FECPBA] := IIf( lSBI .And. aPos[FP_BI_FECPBA] , SBI->BI_FECPBA , IIf( aPos[FP_B1_FECPBA] .And. lSeek , IIf(lSS4, SS4->S4_FECPBA , SB1->B1_FECPBA ), 0   ) )
aNfItem[nItem][IT_PRD][SB_ALFECRN]:= IIf( lSBI .And. aPos[FP_BI_ALFECRN], SBI->BI_ALFECRN, IIf( aPos[FP_B1_ALFECRN].And. lSeek , IIf(lSS4, SS4->S4_ALFECRN, SB1->B1_ALFECRN), 0   ) )
aNfItem[nItem][IT_PRD][SB_ALFUMAC]:= IIf( lSBI .And. aPos[FP_BI_ALFUMAC], SBI->BI_ALFUMAC, IIf( aPos[FP_B1_ALFUMAC].And. lSeek , IIf(lSS4, SS4->S4_ALFUMAC, SB1->B1_ALFUMAC), 0   ) )
aNfItem[nItem][IT_PRD][SB_PRN944I]:= IIf( lSBI .And. aPos[FP_BI_PRN944I], SBI->BI_PRN944I, IIf( aPos[FP_B1_PRN944I].And. lSeek , IIf(lSS4, SS4->S4_PRN944I, SB1->B1_PRN944I), " " ) )
aNfItem[nItem][IT_PRD][SB_REGESIM]:= IIf( lSBI .And. aPos[FP_BI_REGESIM], SBI->BI_REGESIM, IIf( aPos[FP_B1_REGESIM].And. lSeek , IIf(lSS4, SS4->S4_REGESIM, SB1->B1_REGESIM), " " ) )
aNfItem[nItem][IT_PRD][SB_VLRISC] := IIf( lSBI .And. aPos[FP_BI_VLRISC] , SBI->BI_VLRISC , IIf( aPos[FP_B1_VLRISC] .And. lSeek , IIf(lSS4 .And. aPos[FP_S4_VLRISC], SS4->S4_VLRISC , SB1->B1_VLRISC ), 0   ) )
aNfItem[nItem][IT_PRD][SB_CRDPRES]:= IIf( lSBI .And. aPos[FP_BI_CRDPRES], SBI->BI_CRDPRES, IIf( aPos[FP_B1_CRDPRES].And. lSeek , IIf(lSS4, SS4->S4_CRDPRES, SB1->B1_CRDPRES), 0   ) )
aNfItem[nItem][IT_PRD][SB_VMINDET]:= IIf( lSBI .And. aPos[FP_BI_VMINDET], SBI->BI_VMINDET, IIf( aPos[FP_B1_VMINDET].And. lSeek , IIf(lSS4 .And. aPos[FP_S4_VMINDET], SS4->S4_VMINDET, SB1->B1_VMINDET), 0   ) )
aNfItem[nItem][IT_PRD][SB_IMPORT] := IIf( lSBI .And. aPos[FP_BI_IMPORT] , SBI->BI_IMPORT , IIf( aPos[FP_B1_IMPORT] .And. lSeek , IIf(lSS4, SS4->S4_IMPORT , SB1->B1_IMPORT ), " " ) )
aNfItem[nItem][IT_PRD][SB_TPDP]   := IIf( lSBI .And. aPos[FP_BI_TPDP]   , SBI->BI_TPDP   , IIf( aPos[FP_B1_TPDP]   .And. lSeek , IIf(lSS4, SS4->S4_TPDP   , SB1->B1_TPDP   ), " " ) )
aNfItem[nItem][IT_PRD][SB_CSLL]   := IIf( lSBI .And. aPos[FP_BI_CSLL]   , SBI->BI_CSLL   , IIf( aPos[FP_B1_CSLL]   .And. lSeek , IIf(lSS4, SS4->S4_CSLL   , SB1->B1_CSLL   ), " " ) )
aNfItem[nItem][IT_PRD][SB_IDHIST] := IIf( lSBI                                , ""             , IIf( aPos[FP_B1_IDHIST] .And. lSeek , IIf(lSS4, SS4->S4_IDHIST , SB1->B1_IDHIST ), " " ) )
aNfItem[nItem][IT_PRD][SB_MEPLES] := IIf( lSBI .And. aPos[FP_BI_MEPLES] , SBI->BI_MEPLES , IIf( aPos[FP_B1_MEPLES] .And. lSeek , IIf(lSS4, SS4->S4_MEPLES , SB1->B1_MEPLES ), " " ) )
aNfItem[nItem][IT_PRD][SB_UVLRC] := IIf( lSBI  								, "" 			  , IIf( aPos[FP_B1_UPRC] .And. lSeek , IIf(lSS4, SS4->S4_UVLRC , SB1->B1_UPRC ), " " ) )
aNfItem[nItem][IT_PRD][SB_ALQDFB1]:= IIf( lSBI .And. aPos[FP_BI_ALQDFB1], SBI->&("BI_"+Substr(aSX6[MV_ALQDFB1],4)), IIf( aPos[FP_B1_ALQDFB1], SB1->&("B1_"+Substr(aSX6[MV_ALQDFB1],4)) , "2" ) )
aNfItem[nItem][IT_PRD][SB_B1PTST] := IIf( lSBI .And. aPos[FP_BI_B1PTST] , SBI->&("BI_"+Substr(aSX6[MV_B1PTST] ,4)), IIf( aPos[FP_B1_B1PTST] , SB1->&("B1_"+Substr(aSX6[MV_B1PTST] ,4)) , 0   ) )
aNfItem[nItem][IT_PRD][SB_PRDDIAT]:= IIf( lSBI .And. aPos[FP_BI_PRDDIAT], SBI->&("BI_"+Substr(aSX6[MV_PRDDIAT],4)), IIf( aPos[FP_B1_PRDDIAT], SB1->&("B1_"+Substr(aSX6[MV_PRDDIAT],4)) , " " ) )
aNfItem[nItem][IT_PRD][SB_B1CALTR]:= IIf( lSBI .And. aPos[FP_BI_B1CALTR], SBI->&("BI_"+Substr(aSX6[MV_B1CALTR],4)), IIf( aPos[FP_B1_B1CALTR], SB1->&("B1_"+Substr(aSX6[MV_B1CALTR],4)) , " " ) )
aNfItem[nItem][IT_PRD][SB_B1CATRI]:= IIf( lSBI .And. aPos[FP_BI_B1CATRI], SBI->&("BI_"+Substr(aSX6[MV_B1CATRI],4)), IIf( aPos[FP_B1_B1CATRI], SB1->&("B1_"+Substr(aSX6[MV_B1CATRI],4)) , 0   ) )
aNfItem[nItem][IT_PRD][SB_ICMPFAT]:= IIf( lSBI .And. aPos[FP_BI_ICMPFAT], SBI->&("BI_"+Substr(aSX6[MV_ICMPFAT],4)), IIf( aPos[FP_B1_ICMPFAT], SB1->&("B1_"+Substr(aSX6[MV_ICMPFAT],4)) , 0   ) )
aNfItem[nItem][IT_PRD][SB_IPIPFAT]:= IIf( lSBI .And. aPos[FP_BI_IPIPFAT], SBI->&("BI_"+Substr(aSX6[MV_IPIPFAT],4)), IIf( aPos[FP_B1_IPIPFAT], SB1->&("B1_"+Substr(aSX6[MV_IPIPFAT],4)) , 0   ) )
aNfItem[nItem][IT_PRD][SB_PUPCCST]:= IIf( lSBI .And. aPos[FP_BI_PUPCCST], SBI->&("BI_"+Substr(aSX6[MV_PUPCCST],4)), IIf( aPos[FP_B1_PUPCCST], SB1->&("B1_"+Substr(aSX6[MV_PUPCCST],4)) , 0   ) )
aNfItem[nItem][IT_PRD][SB_B1CPSST]:= IIf( lSBI .And. aPos[FP_BI_B1CPSST], SBI->&("BI_"+Substr(aSX6[MV_B1CPSST],4)), IIf( aPos[FP_B1_B1CPSST], SB1->&("B1_"+Substr(aSX6[MV_B1CPSST],4)) , 0   ) )
aNfItem[nItem][IT_PRD][SB_B1CCFST]:= IIf( lSBI .And. aPos[FP_BI_B1CCFST], SBI->&("BI_"+Substr(aSX6[MV_B1CCFST],4)), IIf( aPos[FP_B1_B1CCFST], SB1->&("B1_"+Substr(aSX6[MV_B1CCFST],4)) , 0   ) )
aNfItem[nItem][IT_PRD][SB_FECPMT] := IIf( lSBI .And. aPos[FP_BI_FECPMT] , SBI->&("BI_"+Substr(aSX6[MV_FECPMT] ,4)), IIf( aPos[FP_B1_FECPMT] , SB1->&("B1_"+Substr(aSX6[MV_FECPMT] ,4)) , 0   ) )
aNfItem[nItem][IT_PRD][SB_ADIFECP]:= IIf( lSBI .And. aPos[FP_BI_ADIFECP], SBI->&("BI_"+Substr(aSX6[MV_ADIFECP],4)), IIf( aPos[FP_B1_ADIFECP], SB1->&("B1_"+Substr(aSX6[MV_ADIFECP],4)) , 0   ) )
aNfItem[nItem][IT_PRD][SB_ALFECMG]:= IIf( lSBI .And. aPos[FP_BI_ALFECMG], SBI->&("BI_"+Substr(aSX6[MV_ALFECMG],4)), IIf( aPos[FP_B1_ALFECMG], SB1->&("B1_"+Substr(aSX6[MV_ALFECMG],4)) , 0   ) )
aNfItem[nItem][IT_PRD][SB_MVAFRP] := IIf( lSBI .And. aPos[FP_MV_MVAFBI],  &(aSX6[MV_MVAFRP]),	IIf( aPos[FP_MV_MVAFRP], &(aSX6[MV_MVAFRP]) , 0   ) )
aNfItem[nItem][IT_PRD][SB_MVAFRC] := IIf( lSBI .And. aPos[FP_MV_MVAFBC],  &(aSX6[MV_MVAFRC]),	IIf( aPos[FP_MV_MVAFRC], &(aSX6[MV_MVAFRC]) , 0   ) )
aNfItem[nItem][IT_PRD][SB_AFAMAD] := IIf( aPos[FP_AFAMAD] .And. lSeek , SB1->B1_AFAMAD,0)
aNfItem[nItem][IT_PRD][SB_CONV]   := IIf( aPos[FP_B1_CONV] .And. lSeek , SB1->B1_CONV,0)
aNfItem[nItem][IT_PRD][SB_GRPCST]   := IIf( aPos[FP_B1_GRPCST] .And. lSeek , SB1->B1_GRPCST,"")
aNfItem[nItem][IT_PRD][SB_CEST]   := IIf( lSBI .And. aPos[FP_BI_CEST]  , SBI->BI_CEST, IIf( aPos[FP_B1_CEST] .And. lSeek ,  SB1->B1_CEST , " " ) )
//-- Pauta ICMS informada no parametro MV_PAUTFOB
aNfItem[nItem][IT_PRD][SB_MV_PAUTFOB]:= IIf( aPos[FP_MV_PAUTFOB], SB1->&(aSX6[MV_PAUTFOB]), 0 )
aNfItem[nItem][IT_PRD][SB_CODATIV]  := IIf(aPos[FP_B5_CODATIV] .And. lSeek, IIf(lSS5, SS5->S5_CODATIV, cCodAtv), " ")
aNfItem[nItem][IT_PRD][SB_AFUNDES] := IIf(aPos[FP_B1_AFUNDES] .And. lSeek, IIf(lSS4, SS4->S4_AFUNDES, SB1->B1_AFUNDES), 0)
aNfItem[nItem][IT_PRD][SB_AIMAMT]	:= IIf(aPos[FP_B1_AIMAMT] .And. lSeek, IIf(lSS4, SS4->S4_AIMAMT, SB1->B1_AIMAMT), 0)
aNfItem[nItem][IT_PRD][SB_AFASEMT]	:= IIf(aPos[FP_B1_AFASEMT] .And. lSeek, IIf(lSS4, SS4->S4_AFASEMT, SB1->B1_AFASEMT), 0)
aNfItem[nItem][IT_PRD][SB_VLRCID]	:= IIf(aPos[FP_B5_VLRCID] .And. lSeek, IIf(lSS5, SS5->S5_VLRCID, SB5->B5_VLRCID), 0)
aNfItem[nItem][IT_PRD][SB_CG1_ALIQ] := IIf(aPos[FP_CG1_ALIQ] .And. lSeek .And. lSeekCG1, CG1->CG1_ALIQ, 0)
aNfItem[nItem][IT_PRD][SB_TRIBMU] := IIf( lSBI .And. aPos[FP_BI_TRIBMUN], SBI->BI_TRIBMUN , IIf( aPos[FP_B1_TRIBMUN] .And. lSeek , IIf(lSS4 .And. aPos[FP_S4_TRIBMUN], SS4->S4_TRIBMUN, SB1->B1_TRIBMUN   ), " " ) )
aNfItem[nItem][IT_PRD][SB_B1PISST]	:= IIf(aPos[FP_B1_B1PISST] .And. lSeek, SB1->&("B1_"+Substr(aSX6[MV_B1PISST] ,4)), 0)
aNfItem[nItem][IT_PRD][SB_B1COFST]	:= IIf(aPos[FP_B1_B1COFST] .And. lSeek, SB1->&("B1_"+Substr(aSX6[MV_B1COFST] ,4)), 0)
aNfItem[nItem][IT_PRD][SB_B1GRUPO] :=  IIf(aPos[FP_B1_GRUPO]   .And. lSeek, SB1->B1_GRUPO,"")

// ID da SB1 - Carga separada pois nao faz parte do array "SB".
aNfItem[nItem][IT_IDSB1] := IIf(aPos[FP_B1_IDHIST] .And. lSeek, IIf(lSS4, SS4->S4_IDHIST, SB1->B1_IDHIST), "")

SBZ->(dbSetOrder(1))
If lSeek .And. cAliasPROD == "SB1" .And. aSX6[MV_ARQPROD] == "SBZ" .And. SBZ->( MsSeek( xFilial("SBZ") + SB1->B1_COD ) )

	If lHistorico
	//Se for reprocessamento,  e tiver habilitado para buscar os Historico Fiscais,
	//verifico se o ID do historico do Ind.Prod.e igual aoque foi gravado na Nota. Se for
	//igual é porque nao teve alterações no Ind.Prod.   na emissão. Se for diferente,
	//é porque teve alterações no cadastro, e entao os dados são carregados da tabela de
	//Historico(SS2).
		If( aNfCab[NF_CLIFOR]=="C" .And. aNfCab[NF_TIPONF]<>"D") .Or.( aNfCab[NF_CLIFOR]=="F" .And. aNfCab[NF_TIPONF]$"D|B")
				cHistSBZ :=  (cAlsItem)->D2_IDSBZ
		Else
				cHistSBZ := (cAlsItem)->D1_IDSBZ
		End
		If cPaisLoc == "BRA" .And. Alltrim(SBZ->BZ_IDHIST) <> Alltrim(cHistSBZ)
			SS6->(dbSetOrder(1))
			SS6->(MsSeek(xFilial("SS6")+cHistSBZ))
			lSS6 := .T.
		EndIf
	EndIf

  If "PICM"    $ cCpoSBZ .And. aPos[FP_BZ_PICM]    .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_PICM   ), !Empty(SBZ->BZ_PICM    )), .T. ) ; aNfItem[nItem][IT_PRD][SB_PICM]   := IIf(lSS6, SS6->S6_PICM    , SBZ->BZ_PICM    );EndIf
  If "VLR_ICM" $ cCpoSBZ .And. aPos[FP_BZ_VLR_ICM] .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_VLR_ICM), !Empty(SBZ->BZ_VLR_ICM )), .T. ) ; aNfItem[nItem][IT_PRD][SB_VLR_ICM]:= IIf(lSS6, SS6->S6_VLR_ICM , SBZ->BZ_VLR_ICM );EndIf
  If "INT_ICM" $ cCpoSBZ .And. aPos[FP_BZ_INT_ICM] .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_INT_ICM), !Empty(SBZ->BZ_INT_ICM )), .T. ) ; aNfItem[nItem][IT_PRD][SB_INT_ICM]:= IIf(lSS6, SS6->S6_INT_ICM , SBZ->BZ_INT_ICM );EndIf
  If "PICMRET" $ cCpoSBZ .And. aPos[FP_BZ_PICMRET] .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_PICMRET), !Empty(SBZ->BZ_PICMRET )), .T. ) ; aNfItem[nItem][IT_PRD][SB_PICMRET]:= IIf(lSS6, SS6->S6_PICMRET , SBZ->BZ_PICMRET );EndIf
  If "PICMENT" $ cCpoSBZ .And. aPos[FP_BZ_PICMENT] .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_PICMENT), !Empty(SBZ->BZ_PICMENT )), .T. ) ; aNfItem[nItem][IT_PRD][SB_PICMENT]:= IIf(lSS6, SS6->S6_PICMENT , SBZ->BZ_PICMENT );EndIf
  If "IPI"     $ cCpoSBZ .And. aPos[FP_BZ_IPI]     .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_IPI    ), !Empty(SBZ->BZ_IPI     )), .T. ) ; aNfItem[nItem][IT_PRD][SB_IPI]    := IIf(lSS6, SS6->S6_IPI     , SBZ->BZ_IPI     );EndIf
  If "VLR_IPI" $ cCpoSBZ .And. aPos[FP_BZ_VLR_IPI] .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_VLR_IPI), !Empty(SBZ->BZ_VLR_IPI )), .T. ) ; aNfItem[nItem][IT_PRD][SB_VLR_IPI]:= IIf(lSS6, SS6->S6_VLR_IPI , SBZ->BZ_VLR_IPI );EndIf
  If "REDPIS"  $ cCpoSBZ .And. aPos[FP_BZ_REDPIS]  .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_REDPIS ), !Empty(SBZ->BZ_REDPIS  )), .T. ) ; aNfItem[nItem][IT_PRD][SB_REDPIS] := IIf(lSS6, SS6->S6_REDPIS  , SBZ->BZ_REDPIS  );EndIf
  If "REDCOF"  $ cCpoSBZ .And. aPos[FP_BZ_REDCOF]  .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_REDCOF ), !Empty(SBZ->BZ_REDCOF  )), .T. ) ; aNfItem[nItem][IT_PRD][SB_REDCOF] := IIf(lSS6, SS6->S6_REDCOF  , SBZ->BZ_REDCOF  );EndIf
  If "IRRF"    $ cCpoSBZ .And. aPos[FP_BZ_IRRF]    .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_IRRF   ), !Empty(SBZ->BZ_IRRF    )), .T. ) ; aNfItem[nItem][IT_PRD][SB_IRRF]   := IIf(lSS6, SS6->S6_IRRF    , SBZ->BZ_IRRF    );EndIf
  If "ORIGEM"  $ cCpoSBZ .And. aPos[FP_BZ_ORIGEM]  .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_ORIGEM ), !Empty(SBZ->BZ_ORIGEM  )), .T. ) ; aNfItem[nItem][IT_PRD][SB_ORIGEM] := IIf(lSS6, SS6->S6_ORIGEM  , SBZ->BZ_ORIGEM  );EndIf
  If "GRTRIB"  $ cCpoSBZ .And. aPos[FP_BZ_GRTRIB]  .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_GRTRIB ), !Empty(SBZ->BZ_GRTRIB  )), .T. ) ; aNfItem[nItem][IT_PRD][SB_GRTRIB] := IIf(lSS6, SS6->S6_GRTRIB  , SBZ->BZ_GRTRIB  );EndIf
  If "CODISS"  $ cCpoSBZ .And. aPos[FP_BZ_CODISS]  .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_CODISS ), !Empty(SBZ->BZ_CODISS  )), .T. ) ; aNfItem[nItem][IT_PRD][SB_CODISS] := IIf(lSS6, SS6->S6_CODISS  , SBZ->BZ_CODISS  );EndIf
  If "FECP"    $ cCpoSBZ .And. aPos[FP_BZ_FECP]    .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_FECP   ), !Empty(SBZ->BZ_FECP    )), .T. ) ; aNfItem[nItem][IT_PRD][SB_FECP]   := IIf(lSS6, SS6->S6_FECP    , SBZ->BZ_FECP    );EndIf
  If "ALIQISS" $ cCpoSBZ .And. aPos[FP_BZ_ALIQISS] .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_ALIQISS), !Empty(SBZ->BZ_ALIQISS )), .T. ) ; aNfItem[nItem][IT_PRD][SB_ALIQISS]:= IIf(lSS6, SS6->S6_ALIQISS , SBZ->BZ_ALIQISS );EndIf
  If "PIS"     $ cCpoSBZ .And. aPos[FP_BZ_PIS]     .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_PIS    ), !Empty(SBZ->BZ_PIS     )), .T. ) ; aNfItem[nItem][IT_PRD][SB_PIS]    := IIf(lSS6, SS6->S6_PIS     , SBZ->BZ_PIS     );EndIf
  If "COFINS"  $ cCpoSBZ .And. aPos[FP_BZ_COFINS]  .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_COFINS ), !Empty(SBZ->BZ_COFINS  )), .T. ) ; aNfItem[nItem][IT_PRD][SB_COFINS] := IIf(lSS6, SS6->S6_COFINS  , SBZ->BZ_COFINS  );EndIf
  If "PCSLL"   $ cCpoSBZ .And. aPos[FP_BZ_PCSLL]   .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_PCSLL  ), !Empty(SBZ->BZ_PCSLL   )), .T. ) ; aNfItem[nItem][IT_PRD][SB_PCSLL]  := IIf(lSS6, SS6->S6_PCSLL   , SBZ->BZ_PCSLL   );EndIf
  If "ALFUMAC" $ cCpoSBZ .And. aPos[FP_BZ_ALFUMAC] .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_ALFUMAC), !Empty(SBZ->BZ_ALFUMAC )), .T. ) ; aNfItem[nItem][IT_PRD][SB_ALFUMAC]:= IIf(lSS6, SS6->S6_ALFUMAC , SBZ->BZ_ALFUMAC );EndIf
  If "FECPBA"  $ cCpoSBZ .And. aPos[FP_BZ_FECPBA]  .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_FECPBA ), !Empty(SBZ->BZ_FECPBA  )), .T. ) ; aNfItem[nItem][IT_PRD][SB_FECPBA] := IIf(lSS6, SS6->S6_FECPBA  , SBZ->BZ_FECPBA  );EndIf
  If "ALFECRN" $ cCpoSBZ .And. aPos[FP_BZ_ALFECRN] .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_ALFECRN), !Empty(SBZ->BZ_ALFECRN )), .T. ) ; aNfItem[nItem][IT_PRD][SB_ALFECRN]:= IIf(lSS6, SS6->S6_ALFECRN , SBZ->BZ_ALFECRN );EndIf
  If "CNAE"    $ cCpoSBZ .And. aPos[FP_BZ_CNAE]    .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_CNAE   ), !Empty(SBZ->BZ_CNAE    )), .T. ) ; aNfItem[nItem][IT_PRD][SB_CNAE]   := IIf(lSS6, SS6->S6_CNAE    , SBZ->BZ_CNAE    );EndIf
  If "CSLL"    $ cCpoSBZ .And. aPos[FP_BZ_CSLL]    .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_CSLL   ), !Empty(SBZ->BZ_CSLL    )), .T. ) ; aNfItem[nItem][IT_PRD][SB_CSLL]   := IIf(lSS6, SS6->S6_CSLL    , SBZ->BZ_CSLL    );EndIf
  If "PPIS"    $ cCpoSBZ .And. aPos[FP_BZ_PPIS]    .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_PPIS   ), !Empty(SBZ->BZ_PPIS   )), .T. ) ; aNfItem[nItem][IT_PRD][SB_PPIS]   := IIf(lSS6, SS6->S6_PPIS    , SBZ->BZ_PPIS    );EndIf
  If "PCOFINS" $ cCpoSBZ .And. aPos[FP_BZ_PCOFINS] .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_PCOFINS), !Empty(SBZ->BZ_PCOFINS )), .T. ) ; aNfItem[nItem][IT_PRD][SB_PCOFINS]:= IIf(lSS6, SS6->S6_PCOFINS , SBZ->BZ_PCOFINS );EndIf
  If "AFUNDES" $ cCpoSBZ .And. aPos[FP_BZ_AFUNDES] .And. IIf( lArqProp , IIf(lSS6, !Empty(SS6->S6_AFUNDES), !Empty(SBZ->BZ_AFUNDES )), .T. ) ; aNfItem[nItem][IT_PRD][SB_AFUNDES]:= IIf(lSS6, SS6->S6_AFUNDES , SBZ->BZ_AFUNDES );EndIf
  If "TRIBMUN" $ cCpoSBZ .And. aPos[FP_BZ_TRIBMUN] .And. IIf( lArqProp , IIf(lSS6 .And. aPos[FP_S6_TRIBMUN], !Empty(SS6->S6_TRIBMUN), !Empty(SBZ->BZ_TRIBMUN )), .T. ) ; aNfItem[nItem][IT_PRD][SB_TRIBMU]:= IIf(lSS6 .And. aPos[FP_S6_TRIBMUN], SS6->S6_TRIBMUN , SBZ->BZ_TRIBMUN );EndIf

  /*O tratamento do referência SB_MV_PAUTFOB é diferente das demais, pois o campo não existe no dicionário padrão na SB1, é criado pelo usuário e informado no parâmetro MV_PAUTFOB, e pode acontecer do campo existir somente na SBZ.
  Por este motivo não irei utilizar a função CpyFieldSB, irei atribuir diretamente aqui quando enquadrar SBZ.
  O campo não existe no histórico de cadastro, por este motivo não irei fazer tratamento com tabela SS6.
  */
  aNfItem[nItem][IT_PRD][SB_MV_PAUTFOB]:= IIf( aPos[FP_BZ_PAUTFOB], SBZ->&(aSX6[MV_PAUTFOB]), aNfItem[nItem][IT_PRD][SB_MV_PAUTFOB] )

If !lSBI
	aNfItem[nItem][IT_IDSBZ] := IIf( aPos[FP_BZ_IDHIST] .And. lSeek , IIf(lSS6, SS6->S6_IDHIST, SBZ->BZ_IDHIST), "" )
Else
	aNfItem[nItem][IT_IDSBZ] := ""
EndIf

EndIf

aNfItem[nItem][IT_GRPTRIB] := aNfItem[nItem][IT_PRD][SB_GRTRIB]
aNfItem[nItem][IT_RSATIVO] := aNfItem[nItem][IT_PRD][SB_RSATIVO]
aNfItem[nItem][IT_POSIPI]  := aNfItem[nItem][IT_PRD][SB_POSIPI]
aNfItem[nItem][IT_CEST]		:= aNfItem[nItem][IT_PRD][SB_CEST]
aNfItem[nItem][IT_B1UM]    := aNfItem[nItem][IT_PRD][SB_UM]
aNfItem[nItem][IT_B1SEGUM] := aNfItem[nItem][IT_PRD][SB_SEGUM]
aNfItem[nItem][IT_AFABOV]  := aNfItem[nItem][IT_PRD][SB_AFABOV]
aNfItem[nItem][IT_AFACS]   := aNfItem[nItem][IT_PRD][SB_AFACS]
aNfItem[nItem][IT_AFETHAB] := aNfItem[nItem][IT_PRD][SB_AFETHAB]
aNfItem[nItem][IT_TFETHAB] := aNfItem[nItem][IT_PRD][SB_TFETHAB]
aNfItem[nItem][IT_CPDIFST] := aNfItem[nItem][IT_PRD][SB_ALQDFB1]
aNfItem[nItem][IT_CPPERST] := aNfItem[nItem][IT_PRD][SB_B1PTST]
aNfItem[nItem][IT_CODIF]   := aNfItem[nItem][IT_PRD][SB_CODIF]
aNfItem[nItem][IT_IDSB1]   := aNfItem[nItem][IT_PRD][SB_IDHIST]
aNfItem[nItem][IT_ALQFMD]  := aNfItem[nItem][IT_PRD][SB_AFAMAD]
aNfItem[nItem][IT_AIMAMT]	:= aNfItem[nItem][IT_PRD][SB_AIMAMT]
aNfItem[nItem][IT_AFASEMT]	:= aNfItem[nItem][IT_PRD][SB_AFASEMT]
aNfItem[nItem][IT_VLRCID]	:= aNfItem[nItem][IT_PRD][SB_VLRCID]

//Carga das referencias vinculadas a tabela UF x UF
//Alimento a referência com os dados do cabecalho primeiramente, caso não encontre na CFC ou SS9
//já estará preenchida com informação do cabecalho
aNfItem[nItem][IT_UFXPROD][UFP_ALIQFECP]	:=	aNfCab[NF_UFXUF][UF_ALIQFECP]
aNfItem[nItem][IT_UFXPROD][UFP_MARGSTLIQ]	:=	aNfCab[NF_UFXUF][UF_MARGSTLIQ]
aNfItem[nItem][IT_UFXPROD][UFP_ALIQSTLIQ]	:=	aNfCab[NF_UFXUF][UF_ALIQSTLIQ]
aNfItem[nItem][IT_UFXPROD][UFP_MARGEM]		:=	aNfCab[NF_UFXUF][UF_MARGEM]
aNfItem[nItem][IT_UFXPROD][UFP_ALQFCPO]		:=	aNfCab[NF_UFXUF][UF_ALQFCPO]
aNfItem[nItem][IT_UFXPROD][UFP_FECPAUX]		:=	aNfCab[NF_UFXUF][UF_FECPAUX]
aNfItem[nItem][IT_UFXPROD][UFP_FECPDIF]		:=	aNfCab[NF_UFXUF][UF_FECPDIF]
aNfItem[nItem][IT_UFXPROD][UFP_FECPINT]		:=	aNfCab[NF_UFXUF][UF_FECPINT]
aNfItem[nItem][IT_UFXPROD][UFP_RDCTIMP]		:=  aNfCab[NF_UFXUF][UF_RDCTIMP]
aNfItem[nItem][IT_UFXPROD][UFP_MVAFRU]		:=  aNfCab[NF_UFXUF][UF_MVAFRU]
aNfItem[nItem][IT_UFXPROD][UFP_MVAES]		:=  aNfCab[NF_UFXUF][UF_MVAES]
aNfItem[nItem][IT_UFXPROD][UFP_ADICST]   := aNfCab[NF_UFXUF][UF_ADICST]
aNfItem[nItem][IT_UFXPROD][UFP_PICM]   := aNfCab[NF_UFXUF][UF_PICM]
aNfItem[nItem][IT_UFXPROD][UFP_VLICMP]   := aNfCab[NF_UFXUF][UF_VLICMP]
aNfItem[nItem][IT_UFXPROD][UFP_VL_ICM]   := aNfCab[NF_UFXUF][UF_VL_ICM]
aNfItem[nItem][IT_UFXPROD][UFP_VL_ANT]   := aNfCab[NF_UFXUF][UF_VL_ANT]
aNfItem[nItem][IT_UFXPROD][UFP_BS_FCPPR]   := aNfCab[NF_UFXUF][UF_BS_FCPPR]
aNfItem[nItem][IT_UFXPROD][UFP_BS_FCPST]   := aNfCab[NF_UFXUF][UF_BS_FCPST]
aNfItem[nItem][IT_UFXPROD][UFP_BS_FCPCM]   := aNfCab[NF_UFXUF][UF_BS_FCPCM]
aNfItem[nItem][IT_UFXPROD][UFP_AFCPST]     := aNfCab[NF_UFXUF][UF_AFCPST]
aNfItem[nItem][IT_UFXPROD][UFP_ALFEEF]     := aNfCab[NF_UFXUF][UF_ALFEEF]
aNfItem[nItem][IT_UFXPROD][UFP_PAUTFOB]     := aNfCab[NF_UFXUF][UF_PAUTFOB]
aNfItem[nItem][IT_UFXPROD][UFP_ALANTICMS]   := aNfCab[NF_UFXUF][UF_ALANTICMS]
aNfItem[nItem][IT_UFXPROD][UFP_BASRDZ]   := aNfCab[NF_UFXUF][UF_BASRDZ]
//Faz busca na CFC considerando a uf origem, uf destino e código do produto.
xFisPosCFC(3,@nItem, @aDic, @aPos, @aNfCab, @aSX6, @aNfitem)

//Trecho para caso de reprocessamento, irá buscar na tabela espelho SS9 considerando id gravado na D1/D2.
If lHistorico .AND. !Empty(cAlsItem) .AND. aDic[AI_CFC]
	If( aNfCab[NF_CLIFOR]=="C" .And. aNfCab[NF_TIPONF]<>"D") .Or.( aNfCab[NF_CLIFOR]=="F" .And. aNfCab[NF_TIPONF]$"D|B")
		cHistCFC :=  Iif( aPos[FP_D2_IDCFC], (cAlsItem)->D2_IDCFC, "" )
	Else
		cHistCFC :=  Iif( aPos[FP_D1_IDCFC], (cAlsItem)->D1_IDCFC,"" )
	EndiF
	If !Empty(cHistCFC) .AND.  Alltrim(CFC->CFC_IDHIST)<>Alltrim(cHistCFC)
		SS9->(dbSetOrder(1))
		SS9->(MsSeek(xFilial("SS9")+cHistCFC))
		aNfItem[nItem][IT_UFXPROD][UFP_ALIQFECP]	:=	SS9->S9_ALQFCP
		aNfItem[nItem][IT_UFXPROD][UFP_MARGSTLIQ]	:=	Iif( aPos[FP_S9_MGLQST] , SS9->S9_MGLQST , 0	)
		aNfItem[nItem][IT_UFXPROD][UFP_ALIQSTLIQ]	:=	Iif( aPos[FP_S9_ALQSTL] , SS9->S9_ALQSTL , 0	)
		aNfItem[nItem][IT_UFXPROD][UFP_MARGEM]		:=	Iif( aPos[FP_S9_MARGEM] , SS9->S9_MARGEM , 0	)
		aNfItem[nItem][IT_UFXPROD][UFP_ALQFCPO]		:=	Iif( aPos[FP_S9_ALFCPO] , SS9->S9_ALFCPO , 0	)
		aNfItem[nItem][IT_UFXPROD][UFP_FECPAUX]		:=	Iif( aPos[FP_S9_FCPAUX] , SS9->S9_FCPAUX , 0	)
		aNfItem[nItem][IT_UFXPROD][UFP_FECPDIF]		:=	Iif( aPos[FP_S9_FCPXDA] , SS9->S9_FCPXDA , '1'	)
		aNfItem[nItem][IT_UFXPROD][UFP_FECPINT]		:=	Iif( aPos[FP_S9_FCPINT] , SS9->S9_FCPINT , '1'	)
		aNfItem[nItem][IT_UFXPROD][UFP_RDCTIMP]	        :=	Iif( aPos[FP_S9_RDCTIM] , SS9->S9_RDCTIM , 1	)
		aNfItem[nItem][IT_IDCFC]			:= 	SS9->S9_IDHIST
		aNfItem[nItem][IT_UFXPROD][UFP_MVAFRU]		:=	Iif( aPos[FP_MV_MVAFRU] , &(aSX6[MV_MVAFRU]) , 0   )
		aNfItem[nItem][IT_UFXPROD][UFP_MVAES]		:=	Iif( aPos[FP_S9_MVAES]  , SS9->S9_MVAES ,  '1'	)
		aNfItem[nItem][IT_UFXPROD][UFP_ADICST]   :=  Iif( aPos[FP_SS9_ADICST]  , SS9->SS9_ADICST ,  0  )
		aNfItem[nItem][IT_UFXPROD][UFP_PICM]   :=  Iif( aPos[FP_S9_PICM]  , SS9->S9_PICM ,  0  )
		aNfItem[nItem][IT_UFXPROD][UFP_VLICMP]   := Iif( aPos[FP_S9_VLICMP]  , SS9->S9_VLICMP  , 0 )
		aNfItem[nItem][IT_UFXPROD][UFP_VL_ICM]   := Iif( aPos[FP_S9_VL_ICM]  , SS9->S9_VL_ICM  , 0 )
		aNfItem[nItem][IT_UFXPROD][UFP_VL_ANT]   := Iif( aPos[FP_S9_VL_ANT]  , SS9->S9_VL_ANT  , 0 )
		aNfItem[nItem][IT_UFXPROD][UFP_PAUTFOB]   := Iif( aPos[FP_S9_PAUTFOB]  , SS9->S9_PAUTFOB  , 0 )
		aNfItem[nItem][IT_UFXPROD][UFP_ALANTICMS]   := Iif( aPos[FP_S9_ALQANT]  , SS9->S9_ALQANT  , 0 )
	EndIf
EndIf

Return

/*MaFisTes-Alexandre Lemes -03/01/2013´
Inicializa o codigo da TES utilizada no item
*/
Function xFisTes(cTes,nRecnoSF4,nItemTes,aTes,lNotRemito,lHistorico,cAlsItem,aNfCab,aNfItem,aSX6,aPos,aDic)

Local aArea		:= {}
Local aAreaSFC	:= {}
Local aTmp	    := {}
Local cHistSF4  := ""
Local cConverte := ""
Local cDummy	:= "z"
Local cProvAnt	:= ""
Local nX 	    := 0
Local nSeq		:= 0
Local lOk       := .T.
Local lGera		:= .T.
Local lTotal	:= .F.
Local lAchouWN	:= .F.
Local lSS0 := .F.
Local lSort 	:= .F.
Local lArgSal	:= Iif (cPaisLoc == "ARG",Upper(Funname()) $ "MATA410|MATA467N",.F.)
DEFAULT cTes 	   := ""
DEFAULT nRecnoSF4  := 0

If cPaisLoc == "ARG"
	lSort := !(Type("l120Auto") <> "U" .and. l120Auto)
EndIf

If cTes <> aTes[TS_CODIGO] .Or. ( cPaisLoc == "ARG" .And. IIF(lSort,lNotRemito,lSort) )
	aArea	 := GetArea()
	aAreaSFC := SFC->(GetArea())
	dbSelectArea("SF4")
	If nRecnoSF4 == 0
		dbSetOrder(1)
		MsSeek(xFilial("SF4") + cTes)
		If lHistorico .And. !Empty(cAlsItem)
			If( aNfCab[NF_CLIFOR]=="C" .And. aNfCab[NF_TIPONF]<>"D") .Or.( aNfCab[NF_CLIFOR]=="F" .And. aNfCab[NF_TIPONF]$"D|B")
		   		cHistSF4 := (cAlsItem)->D2_IDSF4
			Else
				cHistSF4 := (cAlsItem)->D1_IDSF4
			End
			If  cPaisLoc == "BRA" .And. Alltrim(SF4->F4_IDHIST)<>Alltrim(cHistSF4)
				dbSelectArea("SS0")
				dbSetOrder(1)
				MsSeek(xFilial("SS0")+cHistSF4+cTes)
				lSS0 := .T.
			EndIf
		EndIf
	Else
		MsGoto(nRecnoSF4)
	EndIf

	lOk := !Empty(cTes)
	aTes[TS_SFC]	 := {}
	aTes[TS_LANCFIS] := {}

	aTes[TS_CODIGO]  := IIf(lOk, IIf(!lSS0, SF4->F4_CODIGO  , SS0->S0_CODIGO)  , CriaVar("F4_CODIGO",.F.) )
	aTes[TS_TIPO]	 := IIf(lOk, IIf(!lSS0, SF4->F4_TIPO    , SS0->S0_TIPO)    , aNfCab[NF_OPERNF] )
	aTes[TS_ICM]	 := IIf(lOk .And. cPaisLoc == "BRA"        , IIf(!lSS0, SF4->F4_ICM    , SS0->S0_ICM)     , IIf( cPaisLoc=="BRA",IIf(aSX6[MV_INITES]==.T.,"N","S"),"N")  )
	aTes[TS_IPI]	 := IIf(lOk .And. cPaisLoc == "BRA"        , IIf(!lSS0, SF4->F4_IPI    , SS0->S0_IPI)     , IIf( cPaisLoc=="BRA",IIf(aSX6[MV_INITES]==.T.,"N","S"),"N")  )
	aTes[TS_CREDICM] := IIf(lOk, IIf(!lSS0, SF4->F4_CREDICM, SS0->S0_CREDICM) , "S")
	aTes[TS_CREDIPI] := IIf(lOk, IIf(!lSS0, SF4->F4_CREDIPI,SS0->S0_CREDIPI), "N")
	aTes[TS_DUPLIC]	 := IIf(lOk , IIf(!lSS0, SF4->F4_DUPLIC , SS0->S0_DUPLIC)  , "S")
	aTes[TS_ESTOQUE] := IIf(lOk , IIf(!lSS0, SF4->F4_ESTOQUE, SS0->S0_ESTOQUE) , "S")
	If cPaisLoc == "RUS" .And. Type("aCols") == "A" .And. Empty(aNFCab[NF_ESPECIE])
		nPosCF := aScan(aHeader,{|x| AllTrim(x[2]) ==  Iif(aNfCab[NF_OPERNF] == "E",'C7_CF','C6_CF') } )
		If (nPosCF > 0)
			aTes[TS_CF]  := aCols[nItemTes][nPosCF]
		EndIf
	ElseIf cPaisLoc == "RUS" .And. Type("aCols") == "A" .And. !Empty(aNFCab[NF_ESPECIE])
		nPosCF := aScan(aHeader,{|x| AllTrim(x[2]) ==  Iif(aNfCab[NF_OPERNF] == "E",'D1_CF','D2_CF') } )
		If (nPosCF > 0)
			aTes[TS_CF]  := aCols[nItemTes][nPosCF]
		EndIf
	Else
		aTes[TS_CF]	:= IIf(lOk, IIf(!lSS0, SF4->F4_CF     , SS0->S0_CF)      , IIf(aNfCab[NF_OPERNF] == "E","111","511") )
	EndIf
	aTes[TS_TEXTO]	 := IIf(lOk  , IIf(!lSS0, SF4->F4_TEXTO  , SS0->S0_TEXTO)   , CriaVar("F4_TEXTO",.F.) )
	aTes[TS_BASEICM] := IIf(lOk , IIf(!lSS0, SF4->F4_BASEICM, SS0->S0_BASEICM) , 0)
	aTes[TS_BASEIPI] := IIf(lOk, IIf(!lSS0, SF4->F4_BASEIPI, SS0->S0_BASEIPI) , 0)
	aTes[TS_PODER3]	 := IIf(lOk , IIf(!lSS0, SF4->F4_PODER3 , SS0->S0_PODER3)  , "N")
	aTes[TS_LFICM]   := IIf(lOk, IIf(!lSS0, SF4->F4_LFICM  , SS0->S0_LFICM )  , IIf(aSX6[MV_INITES]==.T.,"N","T") )
	aTes[TS_LFIPI]	 := IIf(lOk , IIf(!lSS0, SF4->F4_LFIPI  , SS0->S0_LFIPI)   , IIf(aSX6[MV_INITES]==.T.,"N","T") )
	aTes[TS_DESTACA] := IIf(lOk , IIf(!lSS0, SF4->F4_DESTACA, SS0->S0_DESTACA) , "N")
	aTes[TS_INCIDE]	 := IIf(lOk , IIf(!lSS0, SF4->F4_INCIDE , SS0->S0_INCIDE)  , "N")
	aTes[TS_COMPL]	 := IIf(lOk , IIf(!lSS0, SF4->F4_COMPL  , SS0->S0_COMPL)   , "N")
	aTes[TS_IPIFRET] := IIf(lOk, IIf(!lSS0, SF4->F4_IPIFRET, SS0->S0_IPIFRET) , "N")
	aTes[TS_ISS]	 := IIf(lOk, IIf(!lSS0, SF4->F4_ISS    , SS0->S0_ISS)     , " ")
	aTes[TS_LFISS]	 := IIF(lOk .And. aPos[FP_F4_LFISS]   , IIf(!lSS0, SF4->F4_LFISS  , SS0->S0_LFISS)   , " ")
	aTes[TS_NRLIVRO] := IIf(lOk, IIf(!lSS0, SF4->F4_NRLIVRO, SS0->S0_NRLIVRO) , " ")
	aTes[TS_UPRC]	 := IIf(lOk, IIf(!lSS0, SF4->F4_UPRC   , SS0->S0_UPRC)    , " ")
	aTes[TS_CONSUMO] := IIf(lOk, IIf(!lSS0, SF4->F4_CONSUMO, SS0->S0_CONSUMO) , " ")
	aTes[TS_FORMULA] := IIf(lOk, IIf(!lSS0, SF4->F4_FORMULA, SS0->S0_FORMULA) , " ")
	aTes[TS_AGREG]	 := IIf(lOk, IIf(!lSS0, SF4->F4_AGREG  , SS0->S0_AGREG)   , " ")
	aTes[TS_AGRDRED] := IIf(lOk .And. aPos[FP_F4_AGRDRED] .And. !Empty(IIf(!lSS0, SF4->F4_AGRDRED, SS0->S0_AGRDRED)),  IIf(!lSS0, SF4->F4_AGRDRED, SS0->S0_AGRDRED) , "2")
	aTes[TS_INCSOL]	 := IIf(lOk .And. aPos[FP_F4_INCSOL] , IIf(!lSS0, SF4->F4_INCSOL , SS0->S0_INCSOL)   , " ")
	aTes[TS_CIAP]	 := IIf(lOk , IIf(!lSS0, SF4->F4_CIAP   , SS0->S0_CIAP)    , " ")
	aTes[TS_DESPIPI] := IIf(lOk , IIf(!lSS0, SF4->F4_DESPIPI, SS0->S0_DESPIPI) , "N")
	aTes[TS_ATUTEC]	 := IIf(lOk , IIf(!lSS0, SF4->F4_ATUTEC , SS0->S0_ATUTEC)  , " ")
	aTes[TS_ATUATF]	 := IIf(lOk, IIf(!lSS0, SF4->F4_ATUATF , SS0->S0_ATUATF)  , " ")
	aTes[TS_TPIPI]	 := IIf(lOk, IIf(!lSS0, SF4->F4_TPIPI  , SS0->S0_TPIPI)   , "B")
	aTes[TS_LIVRO]	 := IIf(lOk, IIf(!lSS0, SF4->F4_LIVRO  , SS0->S0_LIVRO)   , "")
	aTes[TS_STDESC]	 := IIf(lOk, IIf(!lSS0, SF4->F4_STDESC , SS0->S0_STDESC)  , " ")
	aTes[TS_DESPICM] := IIf(lOk, IIf(!lSS0, SF4->F4_DESPICM, SS0->S0_DESPICM) , "2")
	aTes[TS_DESPPIS] := IIf(lOk .And. aPos[FP_F4_DESPPIS] , IIf(!lSS0, SF4->F4_DESPPIS, SS0->S0_DESPPIS) , "1")
	aTes[TS_DESPCOF] := IIf(lOk .And. aPos[FP_F4_DESPCOF] , IIf(!lSS0, SF4->F4_DESPCOF, SS0->S0_DESPCOF) , "1")
	aTes[TS_BSICMST] := IIf(lOk .And. aPos[FP_F4_BSICMST] , IIf(!lSS0, SF4->F4_BSICMST, SS0->S0_BSICMST) , 0)
	aTes[TS_BASEISS] := IIf(lOk .And. aPos[FP_F4_BASEISS] , IIf(!lSS0, SF4->F4_BASEISS, SS0->S0_BASEISS) , 0)
	aTes[TS_IPILICM] := IIf(lOk , IIf(!lSS0, SF4->F4_IPILICM, SS0->S0_IPILICM) , "2")
	aTes[TS_ICMSDIF] := IIf(lOk, IIf(!lSS0, SF4->F4_ICMSDIF, SS0->S0_ICMSDIF) , "2")
	aTes[TS_QTDZERO] := IIf(lOk , IIf(!lSS0, SF4->F4_QTDZERO, SS0->S0_QTDZERO) , "2")
	aTes[TS_TRFICM]  := IIf(lOk .And. aPos[FP_F4_TRFICM]  , IIf(!lSS0, SF4->F4_TRFICM , SS0->S0_TRFICM)  , "2")
	aTes[TS_OBSICM]  := IIf(lOk .And. aPos[FP_F4_OBSICM]  , IIf(!lSS0, SF4->F4_OBSICM , SS0->S0_OBSICM)  , "2")
	aTes[TS_OBSSOL]  := IIf(lOk .And. aPos[FP_F4_OBSSOL]  , IIf(!lSS0, SF4->F4_OBSSOL , SS0->S0_OBSSOL)  , "2")
	aTES[TS_PICMDIF] := IIf(lOk .And. aPos[FP_F4_PICMDIF] , IIf(!lSS0, SF4->F4_PICMDIF, SS0->S0_PICMDIF) , 0)
	aTES[TS_PISCRED] := IIf(lOk .And. aPos[FP_F4_PISCRED] , IIf(!lSS0, SF4->F4_PISCRED, SS0->S0_PISCRED) , "3")
	aTES[TS_PISCOF]  := IIf(lOk .And. aPos[FP_F4_PISCOF]  , IIf(!lSS0, SF4->F4_PISCOF , SS0->S0_PISCOF)  , "4")
	aTes[TS_CREDST]  := IIf(lOk .And. aPos[FP_F4_CREDST]  , IIf(!lSS0, SF4->F4_CREDST , SS0->S0_CREDST)  , "2")
	aTes[TS_BASEPIS] := IIf(lOk .And. aPos[FP_F4_BASEPIS] , IIf(!lSS0, SF4->F4_BASEPIS, SS0->S0_BASEPIS) , 0)
	aTes[TS_BASECOF] := IIf(lOk .And. aPos[FP_F4_BASECOF] , IIf(!lSS0, SF4->F4_BASECOF, SS0->S0_BASECOF) , 0)
	aTes[TS_ICMSST]  := IIf(lOk .And. aPos[FP_F4_ICMSST]  , IIf(!lSS0, SF4->F4_ICMSST , SS0->S0_ICMSST)  , "1")
	aTes[TS_ISSST]   := IIf(lOk .And. aPos[FP_F4_ISSST]   , IIf(!lSS0, SF4->F4_ISSST  , SS0->S0_ISSST)   , "1")
	aTes[TS_AGRPIS]  := IIf(lOk .And. aPos[FP_F4_AGRPIS]  , IIf(!lSS0, SF4->F4_AGRPIS , SS0->S0_AGRPIS)  , "2")
	aTes[TS_AGRCOF]  := IIf(lOk .And. aPos[FP_F4_AGRCOF]  , IIf(!lSS0, SF4->F4_AGRCOF , SS0->S0_AGRCOF)  , "2")
	aTes[TS_AGRRETC] := IIf(lOk .And. aPos[FP_F4_AGRRETC] , IIf(!lSS0, SF4->F4_AGRRETC, SS0->S0_AGRRETC) , "2")
	aTes[TS_PISBRUT] := IIf(lOk .And. aPos[FP_F4_PISBRUT] , IIf(!lSS0, SF4->F4_PISBRUT, SS0->S0_PISBRUT) , "2")
	aTes[TS_COFBRUT] := IIf(lOk .And. aPos[FP_F4_COFBRUT] , IIf(!lSS0, SF4->F4_COFBRUT, SS0->S0_COFBRUT) , "2")
	aTes[TS_PISDSZF] := IIf(lOk .And. aPos[FP_F4_PISDSZF] , IIf(!lSS0, SF4->F4_PISDSZF, SS0->S0_PISDSZF) , "2")
	aTes[TS_COFDSZF] := IIf(lOk .And. aPos[FP_F4_COFDSZF] , IIf(!lSS0, SF4->F4_COFDSZF, SS0->S0_COFDSZF) , "2")
	aTes[TS_CRDEST]  := IIf(lOk .And. aPos[FP_F4_CRDEST]  , IIf(!lSS0, SF4->F4_CRDEST , SS0->S0_CRDEST)  , "1")
	aTes[TS_CRDPRES] := IIf(lOk .And. aPos[FP_F4_CRDPRES] , IIf(!lSS0, SF4->F4_CRDPRES, SS0->S0_CRDPRES) , 0)
	aTes[TS_AFRMM]	 := IIf(lOk .And. aPos[FP_F4_AFRMM]   , IIf(!lSS0, SF4->F4_AFRMM  , SS0->S0_AFRMM)   , "N")
	aTes[TS_CRDTRAN] := IIf(lOk .And. aPos[FP_F4_CRDTRAN] , IIf(!lSS0, SF4->F4_CRDTRAN, SS0->S0_CRDTRAN) , 0)
	aTes[TS_CALCFET] := IIf(lOk .And. aPos[FP_F4_CALCFET] , IIf(!lSS0, SF4->F4_CALCFET, SS0->S0_CALCFET) , "2")
	aTes[TS_DESCOND] := IIf(lOk .And. aPos[FP_F4_DESCOND] , IIf(!lSS0, SF4->F4_DESCOND, SS0->S0_DESCOND) , "2")
	aTes[TS_CRPREPR] := IIf(lOk .And. aPos[FP_F4_CRPREPR] , IIf(!lSS0, SF4->F4_CRPREPR, SS0->S0_CRPREPR) , 0)
	aTes[TS_INTBSIC] := IIf(lOk .And. aPos[FP_F4_INTBSIC] , IIf(!lSS0, SF4->F4_INTBSIC, SS0->S0_INTBSIC) , "0")
	aTes[TS_OPERSUC] := IIf(lOk .And. aPos[FP_F4_OPERSUC] , IIf(!lSS0, SF4->F4_OPERSUC, SS0->S0_OPERSUC) , "2")
	aTes[TS_CREDACU] := IIf(lOk .And. aPos[FP_F4_CREDACU] , IIf(!lSS0, SF4->F4_CREDACU, SS0->S0_CREDACU) , "3")
	aTes[TS_CRPRERO] := IIf(lOk .And. aPos[FP_F4_CRPRERO] , IIf(!lSS0, SF4->F4_CRPRERO, SS0->S0_CRPRERO) , 0)
	aTes[TS_APLIRED] := IIf(lOk .And. aPos[FP_F4_APLIRED] , IIf(!lSS0, SF4->F4_APLIRED, SS0->S0_APLIRED) , "2")
	aTes[TS_APLIIVA] := IIf(lOk .And. aPos[FP_F4_APLIIVA] , IIf(!lSS0, SF4->F4_APLIIVA, SS0->S0_APLIIVA) , "2")
	aTes[TS_APLREDP] := IIf(lOk .And. aPos[FP_F4_APLREDP] , IIf(!lSS0, SF4->F4_APLREDP, SS0->S0_APLREDP) , "2")
	aTes[TS_CRPREPE] := IIf(lOk .And. aPos[FP_F4_CRPREPE] , IIf(!lSS0, SF4->F4_CRPREPE, SS0->S0_CRPREPE) , 0)
	aTes[TS_CPRESPR] := IIf(lOk .And. aPos[FP_F4_CPRESPR] , IIf(!lSS0, SF4->F4_CPRESPR, SS0->S0_CPRESPR) , 0)
	aTes[TS_CALCFAB] := Iif(lOk .And. aPos[FP_F4_CFABOV]  , IIf(!lSS0, SF4->F4_CFABOV , SS0->S0_CFABOV)  , "2")
	aTes[TS_CALCFAC] := Iif(lOk .And. aPos[FP_F4_CFACS]   , IIf(!lSS0, SF4->F4_CFACS  , SS0->S0_CFACS)   , "2")
	aTes[TS_CRPRESP] := IIf(lOk .And. aPos[FP_F4_CRPRESP] , IIf(!lSS0, SF4->F4_CRPRESP, SS0->S0_CRPRESP) , 0)
	aTes[TS_MOTICMS] := IIf(lOk .And. aPos[FP_F4_MOTICMS] , IIf(!lSS0, SF4->F4_MOTICMS, SS0->S0_MOTICMS) , " ")
	aTes[TS_DUPLIST] := IIf(lOk .And. aPos[FP_F4_DUPLIST] , IIf(!lSS0, SF4->F4_DUPLIST, SS0->S0_DUPLIST) , "2")
	aTes[TS_PR35701] := IIf(lOk .And. aPos[FP_F4_PR35701] , IIf(!lSS0, SF4->F4_PR35701, SS0->S0_PR35701) , 0)
	aTes[TS_CODBCC]  := IIf(lOk .And. aPos[FP_F4_CODBCC]  , IIf(!lSS0, SF4->F4_CODBCC , SS0->S0_CODBCC)  , " ")
	aTes[TS_INDNTFR] := IIf(lOk .And. aPos[FP_F4_INDNTFR] , IIf(!lSS0, SF4->F4_INDNTFR, SS0->S0_INDNTFR) , " ")
	aTes[TS_VENPRES] := IIf(lOk .And. aPos[FP_F4_VENPRES] , IIf(!lSS0, SF4->F4_VENPRES, SS0->S0_VENPRES) , " ")
	aTes[TS_REDBCCE] := IIf(lOk .And. aPos[FP_F4_REDBCCE] , IIf(!lSS0, SF4->F4_REDBCCE, SS0->S0_REDBCCE) , 0)
	aTes[TS_VARATAC] := IIf(lOk .And. aPos[FP_F4_VARATAC] , IIf(!lSS0, SF4->F4_VARATAC, SS0->S0_VARATAC) , "")
	aTes[TS_DUPLIPI] := IIf(lOk .And. aPos[FP_F4_DUPLIPI] , IIf(!lSS0, SF4->F4_DUPLIPI, SS0->S0_DUPLIPI) , "2")
	aTes[TS_AGRPEDG] := IIf(lOk .And. aPos[FP_F4_AGRPEDG] , IIf(!lSS0, SF4->F4_AGRPEDG, SS0->S0_AGRPEDG) , "3")
	aTes[TS_FRETAUT] := IIf(lOk , IIf(!lSS0, SF4->F4_FRETAUT , SS0->S0_FRETAUT) , "1")
	aTes[TS_MKPCMP]  := IIf(lOk , IIf(!lSS0, SF4->F4_MKPCMP  , SS0->S0_MKPCMP)  , "2")
	aTes[TS_CFEXT]   := IIf(lOk , IIf(!lSS0, SF4->F4_CFEXT   , SS0->S0_CFEXT)   , "")
	aTes[TS_MKPSOL]  := IIf(lOk .And. aPos[FP_F4_MKPSOL]  , IIf(!lSS0, SF4->F4_MKPSOL , SS0->S0_MKPSOL)  , "2")
	aTES[TS_LFICMST] := IIf(lOk .And. aPos[FP_F4_LFICMST] , IIf(!lSS0, SF4->F4_LFICMST, SS0->S0_LFICMST) , "N")
	aTES[TS_DESPRDIC]:= IIf(lOk .And. aPos[FP_F4_DSPRDIC] , IIf(!lSS0, SF4->F4_DSPRDIC, SS0->S0_DSPRDIC) , "1")
	aTes[TS_CTIPI]   := IIf(lOk .And. aPos[FP_F4_CTIPI]   , IIf(!lSS0, SF4->F4_CTIPI  , SS0->S0_CTIPI)   , "  ")
	aTes[TS_SITTRIB] := IIf(lOk .And. aPos[FP_F4_SITTRIB] , IIf(!lSS0, SF4->F4_SITTRIB, SS0->S0_SITTRIB) , "  ")
	aTes[TS_CFPS]    := IIf(lOk .And. aPos[FP_F4_CFPS]    , IIf(!lSS0, SF4->F4_CFPS   , SS0->S0_CFPS)    , "")
	aTes[TS_CRPRST]  := IIf(lOk .And. aPos[FP_F4_CRPRST]  , IIf(!lSS0, SF4->F4_CRPRST , SS0->S0_CRPRST)  , 0)
	aTes[TS_IPIOBS]  := IIf(lOk .And. aPos[FP_F4_IPIOBS]  , IIf(!lSS0, SF4->F4_IPIOBS , SS0->S0_IPIOBS)  , "1")
	aTes[TS_IPIPC]   := IIf(lOk .And. aPos[FP_F4_IPIPC]   , IIf(!lSS0, SF4->F4_IPIPC  , SS0->S0_IPIPC)   , "1")
	aTes[TS_PSCFST]	 := IIf(lOk .And. aPos[FP_F4_PSCFST]  , IIf(!lSS0, SF4->F4_PSCFST , SS0->S0_PSCFST)  , "2")
	aTes[TS_CRPRELE] := IIf(lOk .And. aPos[FP_F4_CRPRELE] , IIf(!lSS0, SF4->F4_CRPRELE, SS0->S0_CRPRELE) , 0)
	aTes[TS_CONTSOC] := IIf(lOk .And. aPos[FP_F4_CONTSOC] , IIf(!lSS0, SF4->F4_CONTSOC, SS0->S0_CONTSOC) , "1")
	aTes[TS_COMPRED] := IIf(lOk .And. aPos[FP_F4_COMPRED] .And. !Empty(IIf(!lSS0, SF4->F4_COMPRED, SS0->S0_COMPRED)), IIf(!lSS0, SF4->F4_COMPRED, SS0->S0_COMPRED) , "1")
	aTES[TS_CSTPIS]	 := IIf(lOk .And. aPos[FP_F4_CSTPIS]  , IIf(!lSS0, SF4->F4_CSTPIS , SS0->S0_CSTPIS)  , "")
	aTES[TS_CSTCOF]	 := IIf(lOk .And. aPos[FP_F4_CSTCOF]  , IIf(!lSS0, SF4->F4_CSTCOF , SS0->S0_CSTCOF)  , "")
	aTes[TS_RGESPST] := IIf(lOk .And. aPos[FP_F4_RGESPST] , IIf(!lSS0, SF4->F4_RGESPST, SS0->S0_RGESPST) , "2")
	aTes[TS_CLFDSUL] := IIf(lOk .And. aPos[FP_F4_CLFDSUL] , IIf(!lSS0, SF4->F4_CLFDSUL, SS0->S0_CLFDSUL) , "2")
	aTes[TS_ALSENAR] := IIf(lOk .And. aPos[FP_F4_ALSENAR] , IIf(!lSS0, SF4->F4_ALSENAR, SS0->S0_ALSENAR) , 0)
	aTes[TS_ESTCRED] := IIf(lOk .And. aPos[FP_F4_ESTCRED] , IIf(!lSS0, SF4->F4_ESTCRED, SS0->S0_ESTCRED) , 0)
	aTes[TS_CRPRSIM] := IIf(lOk .And. aPos[FP_F4_CRPRSIM] , IIf(!lSS0, SF4->F4_CRPRSIM, SS0->S0_CRPRSIM) , 0)
	aTes[TS_ANTICMS] := IIf(lOk .And. aPos[FP_F4_ANTICMS] , IIf(!lSS0, SF4->F4_ANTICMS, SS0->S0_ANTICMS) , "2")
	aTes[TS_FECPANT] := IIf(lOk , aTes[TS_ISEFECP], "2")
	aTes[TS_ISEFECP] := IIf(lOk .And. aPos[FP_F4_ISEFECP] , IIf(!lSS0, SF4->F4_ISEFECP, SS0->S0_ISEFECP) , "1")
	aTes[TS_BCPCST]  := IIf(lOk .And. aPos[FP_F4_BCPCST]  , IIf(!lSS0, SF4->F4_BCPCST , SS0->S0_BCPCST)  , "1")
	aTes[TS_REDANT]  := IIf(lOk .And. aPos[FP_F4_REDANT]  , IIf(!lSS0, SF4->F4_REDANT , SS0->S0_REDANT)  , 0)
	aTes[TS_PAUTICM] := IIf(lOk .And. aPos[FP_F4_PAUTICM] , IIf(!lSS0, SF4->F4_PAUTICM, SS0->S0_PAUTICM) , "1")
	aTes[TS_ATACVAR] := IIf(lOk .And. aPos[FP_F4_ATACVAR] , IIf(!lSS0, SF4->F4_ATACVAR, SS0->S0_ATACVAR) , "2")
	aTes[TS_BSRURAL] := IIf(lOk .And. aPos[FP_F4_BSRURAL] , IIf(!lSS0, SF4->F4_BSRURAL, SS0->S0_BSRURAL) , "1")
	aTes[TS_DBSTCSL] := IIf(lOk .And. aPos[FP_F4_DBSTCSL] , IIf(!lSS0, SF4->F4_DBSTCSL, SS0->S0_DBSTCSL) , "2")
	aTes[TS_DBSTIRR] := IIf(lOk .And. aPos[FP_F4_DBSTIRR] , IIf(!lSS0, SF4->F4_DBSTIRR, SS0->S0_DBSTIRR) , "2")
	aTes[TS_CROUTGO] := IIf(lOk .And. aPos[FP_F4_CROUTGO] , IIf(!lSS0, SF4->F4_CROUTGO, SS0->S0_CROUTGO) , 0)
	aTes[TS_STCONF]  := IIf(lOk .And. aPos[FP_F4_STCONF]  , IIf(!lSS0, SF4->F4_STCONF , SS0->S0_STCONF)  , "2")
	aTes[TS_CSTISS]  := IIf(lOk .And. aPos[FP_F4_CSTISS]  , IIf(!lSS0, SF4->F4_CSTISS , SS0->S0_CSTISS)  , "  ")
	aTes[TS_BSRDICM] := IIf(lOk .And. aPos[FP_F4_BSRDICM] , IIf(!lSS0, SF4->F4_BSRDICM, SS0->S0_BSRDICM) , "1")
	aTes[TS_CROUTSP] := IIf(lOk .And. aPos[FP_F4_CROUTSP] , IIf(!lSS0, SF4->F4_CROUTSP, SS0->S0_CROUTSP) , 0)
	aTes[TS_ICMSTMT] := IIf(lOk .And. aPos[FP_F4_ICMSTMT] .And. !Empty(IIf(!lSS0, SF4->F4_ICMSTMT, SS0->S0_ICMSTMT)) , IIf(!lSS0, SF4->F4_ICMSTMT, SS0->S0_ICMSTMT) , "1")
	aTes[TS_CPPRODE] := IIf(lOk .And. aPos[FP_F4_CPPRODE] , IIf(!lSS0, SF4->F4_CPPRODE, SS0->S0_CPPRODE) , 0)
	aTes[TS_TPPRODE] := IIf(lOk .And. aPos[FP_F4_TPPRODE] , IIf(!lSS0, SF4->F4_TPPRODE, SS0->S0_TPPRODE) , " ")
	aTes[TS_VDASOFT] := IIf(lOk .And. aPos[FP_F4_VDASOFT] , IIf(!lSS0, SF4->F4_VDASOFT, SS0->S0_VDASOFT) , "2")
	aTes[TS_ISEFERN] := IIf(lOk .And. aPos[FP_F4_ISEFERN] , IIf(!lSS0, SF4->F4_ISEFERN, SS0->S0_ISEFERN) , "1")
	aTes[TS_NORESPE] := IIf(lOk .And. aPos[FP_F4_NORESP]  , IIf(!lSS0, SF4->F4_NORESP , SS0->S0_NORESP)  , "2")
	aTes[TS_SOMAIPI] := IIf(lOk .And. aPos[FP_F4_SOMAIPI] , IIf(!lSS0, SF4->F4_SOMAIPI, SS0->S0_SOMAIPI) , "1")
	aTes[TS_APSCFST] := IIf(lOk .And. aPos[FP_F4_APSCFST] , IIf(!lSS0, SF4->F4_APSCFST, SS0->S0_APSCFST) , "1")
	aTes[TS_CPRCATR] := IIf(lOk .And. aPos[FP_F4_CPRECTR] , IIf(!lSS0, SF4->F4_CPRECTR, SS0->S0_CPRECTR) , "2")
	aTes[TS_CREDPRE] := IIf(lOk .And. aPos[FP_F4_CREDPRE] , IIf(!lSS0, SF4->F4_CREDPRE, SS0->S0_CREDPRE) , 0)
	aTes[TS_CONSIND] := IIf(lOk .And. aPos[FP_F4_CONSIND] , IIf(!lSS0, SF4->F4_CONSIND, SS0->S0_CONSIND) , "2")
	aTes[TS_ISEFEMG] := IIf(lOk .And. aPos[FP_F4_ISEFEMG] , IIf(!lSS0, SF4->F4_ISEFEMG, SS0->S0_ISEFEMG) , "1")
	aTes[TS_ALQCMAJ] := IIf(lOk .And. aPos[FP_F4_MALQCOF] , IIf(!lSS0, SF4->F4_MALQCOF, SS0->S0_MALQCOF) , 0)
	aTes[TS_ALQPMAJ] := IIf(lOk .And. aPos[FP_F4_MALQPIS] , IIf(!lSS0, SF4->F4_MALQPIS, SS0->S0_MALQPIS) , 0)
	aTes[TS_ISEFEMT] := IIf(lOk .And. aPos[FP_F4_ISEFEMT] , IIf(!lSS0, SF4->F4_ISEFEMT, SS0->S0_ISEFEMT) , "1")
	aTes[TS_IPIANTE] := IIf(lOk .And. aPos[FP_F4_IPIANT]  , IIf(!lSS0, SF4->F4_IPIANT , SS0->S0_IPIANT)  , "2")
	aTes[TS_AGREGCP] := IIf(lOk .And. aPos[FP_F4_AGREGCP] , IIf(!lSS0, SF4->F4_AGREGCP, SS0->S0_AGREGCP) , "1")
	aTes[TS_NATOPER] := Iif(lOk .And. aPos[FP_F4_NATOPER] , IIf(!lSS0, SF4->F4_NATOPER, SS0->S0_NATOPER) , "")
	aTes[TS_TPCPRES] := IIf(lOk .And. aPos[FP_F4_TPCPRES] , IIf(!lSS0, SF4->F4_TPCPRES, SS0->S0_TPCPRES) , "")
	aTes[TS_IDHIST]  := IIf(lOk .And. aPos[FP_F4_IDHIST]  , IIf(!lSS0, SF4->F4_IDHIST , SS0->S0_IDHIST ) , "")
	aTes[TS_DEVPARC] := IIf(lOk .And. aPos[FP_F4_DEVPARC] , IIf(!lSS0, SF4->F4_DEVPARC, SS0->S0_DEVPARC) , "1")
	aTes[TS_PERCATM] := IIf(lOk .And. aPos[FP_F4_PERCATM] , IIf(!lSS0, SF4->F4_PERCATM, SS0->S0_PERCATM) , 0 )
	aTes[TS_DICMFUN] := IIf(lOk .And. aPos[FP_F4_DICMFUN] , IIf(!lSS0, SF4->F4_DICMFUN, SS0->S0_DICMFUN) , "")
	aTes[TS_IMPIND]  := IIf(lOk .And. aPos[FP_F4_IMPIND]  , IIf(!lSS0, SF4->F4_IMPIND , SS0->S0_IMPIND ) , "")
	aTes[TS_OPERGAR] := IIf(lOk .And. aPos[FP_F4_OPERGAR] , IIf(!lSS0, SF4->F4_OPERGAR, SS0->S0_OPERGAR) , "2")
	aTes[TS_FRETISS] := IIf(lOk .And. aPos[FP_F4_FRETISS] , IIf(!lSS0, SF4->F4_FRETISS, SS0->S0_FRETISS) , "1")
	aTes[TS_F4_STLIQ]:= IIf(lOk .And. aPos[FP_F4_STLIQ]   , IIf(!lSS0, SF4->F4_STLIQ  , SS0->S0_STLIQ  ) , "")
	aTes[TS_CV139]   := IIf(lOk .And. aPos[FP_F4_CV139]   , IIf(!lSS0, SF4->F4_CV139  , SS0->S0_CV139  ) , "2")
	aTes[TS_RFETALG] := IIf(lOk .And. aPos[FP_F4_RFETALG] , IIf(!lSS0, SF4->F4_RFETALG, SS0->S0_RFETALG) , "")
	aTes[TS_PARTICM] := IIf(lOk .And. aPos[FP_F4_PARTICM] , IIf(!lSS0, SF4->F4_PARTICM, SS0->S0_PARTICM) , "")
	aTes[TS_BSICMRE] := IIF(lOk .And. aPos[FP_F4_BSICMRE] , IIf(!lSS0, SF4->F4_BSICMRE, SS0->S0_BSICMRE) , "")
	aTes[TS_ALICRST] := IIF(lOk .And. aPos[FP_F4_ALICRST] , IIf(!lSS0, SF4->F4_ALICRST, SS0->S0_ALICRST) , 0)
	aTes[TS_TRANFIL] := IIf(lOk .And. aPos[FP_F4_TRANFIL] , IIf(!lSS0, SF4->F4_TRANFIL, SS0->S0_TRANFIL) , "2")
	aTes[TS_IPIVFCF] := IIf(lOk .And. aPos[FP_IPIVFCF]    , IIf(!lSS0, SF4->F4_IPIVFCF, SS0->S0_IPIVFCF) , "1")
	aTes[TS_RDBSICM] := IIf(lOk .And. aPos[FP_F4_RDBSICM] , IIf(!lSS0, SF4->F4_RDBSICM, SS0->S0_RDBSICM) , "2")
	aTes[TS_CFAMAD]  := IIf(lOk .And. aPos[FP_CFAMAD]     , IIf(!lSS0, SF4->F4_CFAMAD , SS0->S0_CFAMAD ) , "2")
	aTes[TS_DESCISS] := IIf(lOk .And. aPos[FP_F4_DESCISS] , IIf(!lSS0, SF4->F4_DESCISS, SS0->S0_DESCISS) , "1")
	aTes[TS_OUTPERC] := IIf(lOk .And. aPos[FP_F4_OUTPERC] , IIf(!lSS0, SF4->F4_OUTPERC, SS0->S0_OUTPERC) , 0)
	aTes[TS_PISMIN]  := IIf(lOk .And. aPos[FP_F4_PISMIN] , IIf(!lSS0, SF4->F4_PISMIN, SS0->S0_PISMIN) , "2")
	aTes[TS_COFMIN]  := IIf(lOk .And. aPos[FP_F4_COFMIN] , IIf(!lSS0, SF4->F4_COFMIN, SS0->S0_COFMIN) , "2")
	aTes[TS_IPIMIN]  := IIf(lOk .And. aPos[FP_F4_IPIMIN] , IIf(!lSS0, SF4->F4_IPIMIN, SS0->S0_IPIMIN) , "2")
	aTes[TS_CUSENTR] := IIf(lOk .And. aPos[FP_F4_CUSENTR] , IIf(!lSS0, SF4->F4_CUSENTR, SS0->S0_CUSENTR) , "2")
	aTes[TS_GRPCST]  := IIf(lOk .And. aPos[FP_F4_GRPCST] , IIf(!lSS0, SF4->F4_GRPCST, SS0->S0_GRPCST) , "")
	aTes[TS_IPIPECR] := IIf(lOk .And. aPos[FP_F4_IPIPECR] , IIf(!lSS0, SF4->F4_IPIPECR, SS0->S0_IPIPECR) , 0)
	aTes[TS_CALCCPB] := IIf(lOk .And. aPos[FP_F4_CALCCPB] , IIf(!lSS0, SF4->F4_CALCCPB, SS0->S0_CALCCPB) , "2")
	aTes[TS_DIFAL]   := IIf(lOk .And. aPos[FP_F4_DIFAL] , IIf(!lSS0, SF4->F4_DIFAL, SS0->S0_DIFAL) , "")
	aTes[TS_BASCMP]	 := IIf(lOk .And. aPos[FP_F4_BASCMP], IIf(!lSS0, SF4->F4_BASCMP, SS0->S0_BASCMP) , 0)
	aTes[TS_TXAPIPI] := IIf(lOk .And. aPos[FP_F4_TXAPIPI], IIf(!lSS0, SF4->F4_TXAPIPI, SS0->S0_TXAPIPI) , 0)
	aTes[TS_FTRICMS] := IIf(lOk .And. aPos[FP_F4_FTRICMS] , IIf(!lSS0, SF4->F4_FTRICMS, SS0->S0_FTRICMS) , 0)
	aTes[TS_AGRISS]  := IIf(lOk .And. aPos[FP_F4_AGRISS]  , IIf(!lSS0, SF4->F4_AGRISS , SS0->S0_AGRISS)  , "2")
	aTes[TS_CFUNDES] := Iif(lOk .And. aPos[FP_F4_CFUNDES], IIf(!lSS0, SF4->F4_CFUNDES, SS0->S0_CFUNDES), "2")
	aTes[TS_CIMAMT]  := Iif(lOk .And. aPos[FP_F4_CIMAMT], IIf(!lSS0, SF4->F4_CIMAMT, SS0->S0_CIMAMT), "2")
	aTes[TS_CFASE]	 := Iif(lOk .And. aPos[FP_F4_CFASE], IIf(!lSS0, SF4->F4_CFASE, SS0->S0_CFASE), "2")
	aTes[TS_INDVF]   := Iif(lOk .And. aPos[FP_F4_INDVF], IIf(!lSS0, SF4->F4_INDVF, SS0->S0_INDVF), "2")
	aTes[TS_CSOSN]   := IIf(lOk .And. aPos[FP_F4_CSOSN], IIf(!lSS0, SF4->F4_CSOSN, SS0->S0_CSOSN), "   ")
	aTes[TS_ALIQPRO] := IIf(lOk .And. aPos[FP_F4_ALIQPRO], IIf(!lSS0, SF4->F4_ALIQPRO, SS0->S0_ALIQPRO), 0)
	aTes[TS_ALQFEEF] := IIf(lOk .And. aPos[FP_F4_ALQFEEF] , IIf(!lSS0, SF4->F4_ALQFEEF, SS0->S0_ALQFEEF) , 0)
	aTes[TS_DEDDIF]  := IIf(lOk .And. aPos[FP_F4_DEDDIF] , IIf(!lSS0, SF4->F4_DEDDIF, SS0->S0_DEDDIF) , "1")
	aTes[TS_FCALCPR] := IIf(lOk .And. aPos[FP_F4_FCALCPR] , IIf(!lSS0, SF4->F4_FCALCPR, SS0->S0_FCALCPR) , "")
	aTes[TS_DIFALPC] := IIf(lOk .And. aPos[FP_F4_DIFALPC] , IIf(!lSS0, SF4->F4_DIFALPC, SS0->S0_DIFALPC) , "")
	aTes[TS_COLVDIF] := Iif(lOk .AND. aPos[FP_F4_COLVDIF] , Iif(!lSS0, SF4->F4_COLVDIF, SS0->S0_COLVDIF),"" )
	aTes[TS_STREDU] := IIf(lOk .And. aPos[FP_F4_STREDU] , IIf(!lSS0, SF4->F4_STREDU, SS0->S0_STREDU) , "")
	aTes[TS_FEEF] := IIf(lOk .And. aPos[FP_F4_FEEF] , IIf(!lSS0, SF4->F4_FEEF, SS0->S0_FEEF) , "")
	aTes[TS_BICMCMP] := IIf(lOk .And. aPos[FP_F4_BICMCMP] , IIf(!lSS0, SF4->F4_BICMCMP, Iif(aPos[FP_S0_BICMCMP],SS0->S0_BICMCMP,"")) , "")
	aTes[TS_CSENAR]  := IIf(lOk .And. aPos[FP_F4_CSENAR] , IIf(!lSS0, SF4->F4_CSENAR, SS0->S0_CSENAR) , "2")
	aTes[TS_CINSS]   := IIf(lOk .And. aPos[FP_F4_CINSS] , IIf(!lSS0, SF4->F4_CINSS, SS0->S0_CINSS) , "2")
	aTes[TS_APLREPC] := IIf(lOk .And. aPos[FP_F4_APLREPC], IIf(!lSS0, SF4->F4_APLREPC, SS0->S0_APLREPC) , "4")
	aTes[TS_INDISEN] := IIf(lOk .And. aPos[FP_F4_INDISEN], IIf(!lSS0, SF4->F4_INDISEN, SS0->S0_INDISEN) , "2")
	aTes[TS_INFITEM] := IIf(lOk .And. aPos[FP_F4_INFITEM], IIf(!lSS0, SF4->F4_INFITEM, SS0->S0_INFITEM) ,"")

	If lOk
		// Inicializa os impostos variaveis
		dbSelectArea("SFC")
		dbSetOrder(1)
		If aSX6[MV_GERIMPV] == "S" .And. !( IsRemito( 1 , "'" + aNFCab[NF_TIPODOC] + "'" ) .And. cPaisLoc <> "RUS")
			cTesImp  := SF4->F4_CODIGO
			lAchouWN := .F.
			//Bloco Especifico solicitado pela AVERAGE -FNC 152032 continuação FNC 147106.
			If cPaisLoc <> "BRA"
				If Type("lFacImport") == "L" .And. lFacImport .And. nItemTes <> Nil
					If (SD1->(MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+aNfItem[nItemTes][IT_PRODUTO]+StrZero(nItemTes,GTamMxFis(TAM_D1_ITEM)))))
						If SD1->D1_TIPO_NF $ "5678"
							//Solicitação - Average FNC 152032 continuação FNC 147106
							//Se os campos existirem entro para verificar se estão preenchidos e buscar a referencia da TES na tabela SWN
							If aPos[FP_WN_TES] .And. aPos[FP_WN_ITEMNF]
								SWN->(DbSetOrder(2))
								If SWN->(MsSeek(xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
									While !SWN->(Eof()) .And.;
										(SWN->WN_FILIAL+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA == xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA);
										//Se encontrar a referência do Item e a TES estiver preenchida pego a TES da SWN
										If SWN->WN_PRODUTO+SWN->WN_ITEMNF == SD1->D1_COD+SD1->D1_ITEM .And. !Empty(SWN->WN_TES)
											lAchouWN := .T.
											cTesImp  := SWN->WN_TES
										EndIf
										SWN->(DbSkip())
									EndDo
									//Senão encontrou deixo a referência que existia antes
									If !lAchouWN
										If (SYD->(MsSeek(xFilial("SYD")+SD1->D1_TEC)))
											cTesImp:=SYD->YD_TES
										Endif
									EndIf
								EndIf
							Else
								//Senão os campos não existirem deixo a referência que existia antes
								If (SYD->(MsSeek(xFilial("SYD")+SD1->D1_TEC)))
									cTesImp := SYD->YD_TES
								Endif
							EndIf
						Else
							If aSX6[MV_DESPSD1] == "S" .And. cPaisLoc $ "BRA|ARG|CHI|COL|PER|EQU"
								cTesImp := SD1->D1_TESDES
							Else
								//Solicitação - Average FNC 152032 continuação FNC 147106
								//Se os campos existirem entro para verificar se estão preenchidos e buscar a referencia da TES na tabela SWN
								If aPos[FP_WN_TES] .And. aPos[FP_WN_ITEMNF]
									SWN->(DbSetOrder(2))
									If SWN->(MsSeek(xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
										While !SWN->(Eof()) .And.;
											(SWN->WN_FILIAL+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA == xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA);
											//Se encontrar a referência do Item e a TES estiver preenchida pego a TES da SWN
											If SWN->WN_PRODUTO+SWN->WN_ITEMNF == SD1->D1_COD+SD1->D1_ITEM .And. !Empty(SWN->WN_TES)
												lAchouWN:=.T.
												cTesImp:=SWN->WN_TES
												SFC->(MsSeek(xFilial("SFC")+SWN->WN_TES))
											EndIf
											SWN->(DbSkip())
										End
										//Senão encontrou deixo a referência que existia antes
										If !lAchouWN
											SYD->(MsSeek(xFilial("SYD")+SD1->D1_TEC))
											cTesImp:=SYD->YD_TES
											SFC->(MsSeek(xFilial("SFC")+SYD->YD_TES))
										EndIf
									EndIf
								Else
									//Senão os campos não existirem deixo a referência que existia antes
									SYD->(MsSeek(xFilial("SYD")+SD1->D1_TEC))
									cTesImp:=SYD->YD_TES
									SFC->(MsSeek(xFilial("SFC")+SYD->YD_TES))
								EndIf
							Endif
						Endif
					Endif
				Endif
			Endif

			//Este bloco trata Impostos Variaveis BRASIL e LOCALIZADO - Tabelas SFC e SFB.
			If MsSeek(xFilial("SFC") + cTesImp )
				If nItemTes <> Nil
					cProvAnt := AllTrim(MaFisRet(nItemTes,"IT_PROVENT"))
				Endif

				While !Eof() .And. xFilial("SFC") + cTesImp == SFC->FC_FILIAL + SFC->FC_TES
					If cPaisLoc == "ARG" .And. aPos[FP_FC_PROV] .And. aSX6[MV_TESIB] == .T. .And. Alltrim(Substr(SFC->FC_IMPOSTO,1,2)) == "IB"
						If SFC->FC_PROV == cProvAnt .Or. cProvAnt == "99"
							lGera := .T.
						Else
							lGera := .F.
						Endif
					Else
						lGera := .T.
					Endif

					If lGera
						SFB->(dbSetOrder(1)) //FB_FILIAL + FB_CODIGO
						If cPaisLoc == "PER" .And. SFC->FC_IMPOSTO == 'IGV' .And. Empty(aNfCab[NF_CPOIPM]) .And. Empty(aNfCab[NF_ALQIPM])
							If SFB->(MsSeek(xFilial("SFB") + 'IPM')) 
								aNfCab[NF_CPOIPM] := NumCpoImpVar(SFB->FB_CPOLVRO)
								aNfCab[NF_ALQIPM] := SFB->FB_ALIQ
							EndIf
						EndIf
						SFB->(dbGoTop())
						SFB->(MsSeek(xFilial()+SFC->FC_IMPOSTO))
						If Ascan(aTes[TS_SFC],{|x| x[SFC_IMPOSTO]==SFC->FC_IMPOSTO})==0
							Aadd(aTes[TS_SFC],Array(21))
							nSeq := Len(aTes[TS_SFC])
							aTes[TS_SFC][nSeq][SFC_SEQ]			:= SFC->FC_SEQ
							aTes[TS_SFC][nSeq][SFC_IMPOSTO]		:= SFC->FC_IMPOSTO
							aTes[TS_SFC][nSeq][SFC_CALCULO]		:= SFC->FC_CALCULO
							If cPaisLoc == "ARG" .And. aPos[FP_FC_PROV] .And. aSX6[MV_TESIB] == .T.
								aTes[TS_SFC][nSeq][SFC_PROVENT]	:= SFC->FC_PROV
							Endif
							If IsAlpha(SFC->FC_INCDUPL)
								cConverte := SFC->FC_INCDUPL + SFC->FC_INCNOTA + SFC->FC_CREDITA
								aTes[TS_SFC][nSeq][SFC_INCDUPL]	:= IIf(Subs(cConverte,1,2)=="SN".Or.Subs(cConverte,1,2)=="NS","3",;
								IIf(Subs(cConverte,1,2)=="SS","1","2"))
								aTes[TS_SFC][nSeq][SFC_INCNOTA]	:= IIf(Subs(cConverte,2,1)=="S" ,"1",IIf(Subs(cConverte,2,1)=="R" ,"2","3"))
								aTes[TS_SFC][nSeq][SFC_CREDITA]	:= IIf(Subs(cConverte,2,2)=="SN","1",IIf(Subs(cConverte,2,2)=="NS","2","3"))
							Else
								aTes[TS_SFC][nSeq][SFC_INCDUPL]	:= SFC->FC_INCDUPL
								aTes[TS_SFC][nSeq][SFC_INCNOTA]	:= SFC->FC_INCNOTA
								aTes[TS_SFC][nSeq][SFC_CREDITA]	:= SFC->FC_CREDITA
							EndIf
							aTes[TS_SFC][nSeq][SFC_INCIMP]		:= SFC->FC_INCIMP
							aTes[TS_SFC][nSeq][SFC_BASE]		:= SFC->FC_BASE
							aTes[TS_SFC][nSeq][SFB_DESCR]		:= SFB->FB_DESCR
							aTes[TS_SFC][nSeq][SFB_CPOVREI]		:= "D1_VALIMP"+SFB->FB_CPOLVRO
							aTes[TS_SFC][nSeq][SFB_CPOBAEI]		:= "D1_BASIMP"+SFB->FB_CPOLVRO
							aTes[TS_SFC][nSeq][SFB_CPOVREC]		:= "F1_VALIMP"+SFB->FB_CPOLVRO
							aTes[TS_SFC][nSeq][SFB_CPOBAEC]		:= "F1_BASIMP"+SFB->FB_CPOLVRO
							aTes[TS_SFC][nSeq][SFB_CPOVRSI]		:= "D2_VALIMP"+SFB->FB_CPOLVRO
							aTes[TS_SFC][nSeq][SFB_CPOBASI]		:= "D2_BASIMP"+SFB->FB_CPOLVRO
							aTes[TS_SFC][nSeq][SFB_CPOVRSC]		:= "F2_VALIMP"+SFB->FB_CPOLVRO
							aTes[TS_SFC][nSeq][SFB_CPOBASC]		:= "F2_BASIMP"+SFB->FB_CPOLVRO
							aTes[TS_SFC][nSeq][SFB_FORMENT]		:= SFB->FB_FORMENT
							aTes[TS_SFC][nSeq][SFB_FORMSAI]		:= SFB->FB_FORMSAI
							If aPos[FP_FB_DESGR]
								aTes[TS_SFC][nSeq][SFB_DESGR]	:= SFB->FB_DESGR
							EndIf
							Aadd(aTmp,Val(SFB->FB_CPOLVRO))
							If aTes[TS_SFC][nSeq][SFC_CALCULO] == "T"
								lTotal	:=	.T.
							Endif
						Endif
					Endif

					If !(cPaisLoc $ "ARG|MEX|COL|PER|BOL") .and. (!empty(aTes[TS_SFC]))
					  aSORT(aTes[TS_SFC],,,{|X,Y| X[SFC_CALCULO]< Y[SFC_CALCULO]})
					ElseIf cPaisLoc == "ARG" .And. (Alltrim(Substr(SFC->FC_IMPOSTO,1,2)) == "IB");
                         .And. (Alltrim(SFC->FC_CALCULO) == "I") .And. (aTes[TS_TIPO] == "E" .or. lArgSal) .and. lSort
                           If !empty(aTes[TS_SFC])
                             aSORT(aTes[TS_SFC],,,{|X,Y| X[SFC_CALCULO]< Y[SFC_CALCULO]})
                           EndIf
                      EndIf
					dbSkip()
				EndDo

				If cPaisLoc == "ARG" .And. lTotal
			//		aSort(aTmp)
					For nX := 1 To Len(aTmp)
						If aTmp[nX] <> nX
							cDummy	:=	Str(nX,1)
							Exit
						Endif
					Next nX

					If cDummy <> "z" .And. Len(aTmp) == 1
						aSize(aTes[TS_SFC],Len(aTes[TS_SFC])+1)
						aIns(aTes[TS_SFC],1)
						aTes[TS_SFC][1]	:=	aClone(aTes[TS_SFC][2])
						aTes[TS_SFC][1][SFC_SEQ]    := "00"
						aTes[TS_SFC][1][SFC_IMPOSTO]:= "DUM"
						aTes[TS_SFC][1][SFC_CALCULO]:= "T"
						aTes[TS_SFC][1][SFB_DESCR]  := "Dummy"
						aTes[TS_SFC][1][SFB_CPOVREI]:= "D1_VALIMP"+cDummy
						aTes[TS_SFC][1][SFB_CPOBAEI]:= "D1_BASIMP"+cDummy
						aTes[TS_SFC][1][SFB_CPOVREC]:= "F1_VALIMP"+cDummy
						aTes[TS_SFC][1][SFB_CPOBAEC]:= "F1_BASIMP"+cDummy
						aTes[TS_SFC][1][SFB_CPOVRSI]:= "D2_VALIMP"+cDummy
						aTes[TS_SFC][1][SFB_CPOBASI]:= "D2_BASIMP"+cDummy
						aTes[TS_SFC][1][SFB_CPOVRSC]:= "F2_VALIMP"+cDummy
						aTes[TS_SFC][1][SFB_CPOBASC]:= "F2_BASIMP"+cDummy
						aTes[TS_SFC][1][SFB_FORMENT]:= "MaFisZero"
						aTes[TS_SFC][1][SFB_FORMSAI]:= "MaFisZero"
						MaFisZero() //Para evitar erro de compilacao
					Endif
				Endif
			Endif
		Else
			aTes[TS_SFC] := {}
		EndIf

		If aDic[AI_CC7] .And. aDic[AI_CC6] .And. GTamMxFis(TAM_CC7_CODLAN) == 10 .And. aPos[FP_CC7_TPREG]
			dbSelectArea("CC7")
			dbSetOrder(1)
			If CC7->(MsSeek(xFilial("CC7")+SF4->F4_CODIGO))
				While !CC7->(Eof()) .And. xFilial("CC7")+CC7->CC7_TES==xFilial("CC7")+SF4->F4_CODIGO
					// Codigos de Ajuste de Documento Fiscal (Tabela CC6)
					If (!(CC7->CC7_TPREG == "NA")) .And. (CC6->(MsSeek(xFilial("CC6")+CC7->CC7_CODLAN)))
						//Somente serao considerados lançamentos da UF do contribuinte
						//Caso o lançamento nao seja de Apuração Propria, o lançamento podera ser de qualquer UF
						If CC6->CC6_STUF == aSX6[MV_ESTADO]  .Or. CC6->CC6_TPAPUR <> "0"
							aAdd( aTes[TS_LANCFIS] ,;
									{	CC7->CC7_CODLAN ,;											// 01 - Codigo de Ajuste
										Iif( aPos[FP_CC7_IFCOMP] , CC7->CC7_IFCOMP , ""  ) ,;	// 02 - Codigo da Informacao Complementar
										Iif( aPos[FP_CC7_CODREF] , CC7->CC7_CODREF , ""  ) ,;	// 03 - Codigo do Reflexo
										Iif( aPos[FP_CC7_CLANC]  , CC7->CC7_CLANC  , ""  ) ,; 	// 04 - Complemento registro 0460
										Iif( aPos[FP_CC7_GUIA]   , CC7->CC7_GUIA	, "2" ) ,;	// 05 - Gera Guia de Recolhimento
										"1"} )	// 06 - Campo com código utilizado na Tes
						EndIf
					// Codigos de Ajuste de Apuracao (Tabela CDO)
					ElseIf Empty( CC7->CC7_CODLAN ) .And. aPos[FP_CC7_CLANAP] .And. !Empty( CC7->CC7_CLANAP )
						aAdd( aTes[TS_LANCFIS] ,;
								{	CC7->CC7_CLANAP ,;
									Iif( aPos[FP_CC7_IFCOMP] , CC7->CC7_IFCOMP , ""  ) ,;
									Iif( aPos[FP_CC7_CODREF] , CC7->CC7_CODREF , ""  ) ,;
									Iif( aPos[FP_CC7_CLANC]  , CC7->CC7_CLANC  , ""  ) ,;
									Iif( aPos[FP_CC7_GUIA]   , CC7->CC7_GUIA	, "2" ),;
									 "2"} )
					ElseIf aPos[FP_CC7_CODIPI] .And. !Empty( CC7->CC7_CODIPI ) .And.  Empty( CC7->CC7_CODLAN ) .And. Empty( CC7->CC7_CLANAP )
						aAdd( aTes[TS_LANCFIS] ,;
								{	CC7->CC7_CODIPI ,;
									Iif( aPos[FP_CC7_IFCOMP] , CC7->CC7_IFCOMP , ""  ) ,;
									Iif( aPos[FP_CC7_CODREF] , CC7->CC7_CODREF , ""  ) ,;
									Iif( aPos[FP_CC7_CLANC]  , CC7->CC7_CLANC  , ""  ) ,;
									Iif( aPos[FP_CC7_GUIA]   , CC7->CC7_GUIA  , "2" ) ,;
									"3"} )
					EndIf
					CC7->(dbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSFC)
	RestArea(aArea)

EndIf

cTes := aTes[TS_CODIGO]

If nItemTes <> Nil
	aNfItem[nItemTes][IT_IDSF4] := 	aTes[TS_IDHIST]
EndIf

Return
/*
Função auxiliar a MaFisSomaIt()
*/
Function xFisSomaIt(aNfItem,aNfCab,nX,lSoma,aPos,lNotRemito,cFunName,cCampo,aSX6,aDic)
Local nG		:= 0
Local nTrbGen	:= 0
Local nPosGen	:= 0

If lSoma
	// Atualiza os campos totalizadores.
	aNfCab[NF_DESCONTO]+= aNfItem[nX][IT_DESCONTO]
	aNfCab[NF_FRETE]   += aNfItem[nX][IT_FRETE]
	aNfCab[NF_DESPESA] += aNfItem[nX][IT_DESPESA]
	aNfCab[NF_SEGURO]  += aNfItem[nX][IT_SEGURO]
	aNfCab[NF_VALEMB]  += aNfItem[nX][IT_VALEMB]
	aNfCab[NF_AUTONOMO]+= aNfItem[nX][IT_AUTONOMO]
	aNfCab[NF_BASEICM] += aNfItem[nX][IT_BASEICM]
	aNfCab[NF_VALICM]  += aNfItem[nX][IT_VALICM]
	aNfCab[NF_BASESOL] += aNfItem[nX][IT_BASESOL]
	aNfCab[NF_VALSOL]  += aNfItem[nX][IT_VALSOL]
	aNfCab[NF_BICMORI] += aNfItem[nX][IT_BICMORI]
	aNfCab[NF_VALCMP]  += aNfItem[nX][IT_VALCMP]
	aNfCab[NF_DIFAL]   += aNfItem[nX][IT_DIFAL]
	aNfCab[NF_BASEIPI] += aNfItem[nX][IT_BASEIPI]
	aNfCab[NF_BIPIORI] += aNfitem[nX][IT_BIPIORI]
	aNfCab[NF_VALIPI]  += aNfItem[nX][IT_VALIPI]
	aNfCab[NF_TOTAL]   += aNfItem[nX][IT_TOTAL]
	aNfCab[NF_VALMERC] += aNfItem[nX][IT_VALMERC]-aNfItem[nX][IT_VNAGREG]
	If cPaisLoc == "RUS"
		aNfCab[NF_TOTAL_C1]   += aNfItem[nX][IT_TOTAL_C1]
		aNfCab[NF_VALMERC_C1] += aNfItem[nX][IT_VALMERC_C1]-xMoeda(aNfItem[nX][IT_VNAGREG],aNfCab[NF_MOEDA],1,dDataBase,,aNfCab[NF_TXMOEDA])
	EndIf
	aNfCab[NF_VNAGREG] += aNfItem[nX][IT_VNAGREG]
	aNfCab[NF_FUNRURAL]+= aNfItem[nX][IT_FUNRURAL]
	aNfCab[NF_BASEIRR] += aNfItem[nX][IT_BASEIRR]
	aNfCab[NF_VALIRR]  += aNfItem[nX][IT_VALIRR]
	aNfCab[NF_BASEINS] += aNfItem[nX][IT_BASEINS]
	aNfCab[NF_VALINS]  += aNfItem[nX][IT_VALINS]
	aNfCab[NF_BASEISS] += aNfItem[nX][IT_BASEISS]
	aNfCab[NF_VALISS]  += aNfItem[nX][IT_VALISS]
	aNfCab[NF_BASEDUP] += aNfItem[nX][IT_BASEDUP]
	aNfCab[NF_DESCZF]  += aNfItem[nX][IT_DESCZF]
	aNfCab[NF_PESO]	   += aNfItem[nX][IT_PESO]
	aNfCab[NF_ICMFRETE]+= aNfItem[nX][IT_ICMFRETE]
	aNfCab[NF_BSFRETE] += aNfItem[nX][IT_BSFRETE]
	aNfCab[NF_BASEICA] += aNfItem[nX][IT_BASEICA]
	aNfCab[NF_VALICA]  += aNfItem[nX][IT_VALICA]
	aNfCab[NF_BASECOF] += aNfItem[nX][IT_BASECOF]
	aNfCab[NF_VALCOF]  += aNfItem[nX][IT_VALCOF]
	aNfCab[NF_BASEPIS] += aNfItem[nX][IT_BASEPIS]
	aNfCab[NF_VALPIS]  += aNfItem[nX][IT_VALPIS]
	aNfCab[NF_BASEPS2] += aNfItem[nX][IT_BASEPS2]
	aNfCab[NF_VALPS2]  += aNfItem[nX][IT_VALPS2]
	aNfCab[NF_BASECF2] += aNfItem[nX][IT_BASECF2]
	aNfCab[NF_VALCF2]  += aNfItem[nX][IT_VALCF2]
	aNfCab[NF_BASECSL] += aNfItem[nX][IT_BASECSL]
	aNfCab[NF_VALCSL]  += aNfItem[nX][IT_VALCSL]
	aNfCab[NF_BASEFUN] += aNfItem[nX][IT_BASEFUN]
	aNfCab[NF_ADIANT]  += aNfItem[nX][IT_ADIANT]
	aNfCab[NF_DEDICM]  += aNfItem[nX][IT_DEDICM]

	If cPaisLoc == "PER" .and. aPos[FP_F1_ADIANT]
		aNfCab[NF_ADIANTTOT]+= aNfItem[nX][IT_ADIANTTOT]
	EndIf

	aNfCab[NF_DESCTOT] += aNfItem[nX][IT_DESCTOT]
	aNfCab[NF_ACRESCI] += aNfItem[nX][IT_ACRESCI]
	aNfCab[NF_VALCIDE] += aNfItem[nX][IT_VALCIDE]
	aNfCab[NF_BASECID] += aNfItem[nX][IT_BASECID]
	aNfCab[NF_BASECPM] += aNfItem[nX][IT_BASECPM]
	aNfCab[NF_VALCPM]  += aNfItem[nX][IT_VALCPM]
	aNfCab[NF_IPIVFCF]  += aNfItem[nX][IT_IPIVFCF]
	aNfCab[NF_BASEFMP] += aNfItem[nX][IT_BASEFMP]
	aNfCab[NF_VALFMP]  += aNfItem[nX][IT_VALFMP]
	aNfCab[NF_VALFMD]  += aNfItem[nX][IT_VALFMD]
	aNfCab[NF_BASNDES] += aNfItem[nX][IT_BASNDES]
	aNfCab[NF_ICMNDES] += aNfItem[nX][IT_ICMNDES]

	If cPaisLoc == "BRA" .Or. lNotRemito
		For nG := 1 To NMAXIV
			aNfCab[NF_BASEIMP][nG]+= IIf(ValType(aNfItem[nX][IT_BASEIMP][nG])<>"N",0,aNfItem[nX][IT_BASEIMP][nG])
			aNfCab[NF_VALIMP][nG] += aNfItem[nX][IT_VALIMP][nG]
			aNfCab[NF_VLRORIG][nG]+= aNfItem[nX][IT_VALIMP][nG]
			If cPaisLoc == "RUS"
				aNfCab[NF_BASEIMP_C1][nG]+= IIf(ValType(aNfItem[nX][IT_BASEIMP_C1][nG])<>"N",0,aNfItem[nX][IT_BASEIMP_C1][nG])
				aNfCab[NF_VALIMP_C1][nG] += aNfItem[nX][IT_VALIMP_C1][nG]
			EndIf
		Next nG
		aNfCab[NF_ICMSDIF]	+= aNfItem[nX][IT_ICMSDIF]
		aNfCab[NF_BASEAFRMM]+= aNfItem[nX][IT_BASEAFRMM]
		aNfCab[NF_VALAFRMM] += aNfItem[nX][IT_VALAFRMM]
		aNfCab[NF_PIS252]	+= aNfItem[nX][IT_PIS252]
		aNfCab[NF_COF252]	+= aNfItem[nX][IT_COF252]
		aNfCab[NF_BASESES]	+= aNfItem[nX][IT_BASESES]
		aNfCab[NF_VALSES]	+= aNfItem[nX][IT_VALSES]
		aNfCab[NF_BASEPS3]	+= aNfItem[nX][IT_BASEPS3]
		aNfCab[NF_VALPS3]	+= aNfItem[nX][IT_VALPS3]
		aNfCab[NF_BASECF3]	+= aNfItem[nX][IT_BASECF3]
		aNfCab[NF_VALCF3]	+= aNfItem[nX][IT_VALCF3]
		aNfCab[NF_VLR_FRT]	+= aNfItem[nX][IT_VLR_FRT]
		aNfCab[NF_VALFET]	+= aNfItem[nX][IT_VALFET]
		aNfCab[NF_VALFETR]	+= aNfItem[nX][IT_VALFETR]
		aNfCab[NF_VALFDS]	+= aNfItem[nX][IT_VALFDS]
		aNfCab[NF_ESTCRED]	+= aNfItem[nX][IT_ESTCRED]
		aNfCab[NF_BASETST]	+= aNfItem[nX][IT_BASETST]
		aNfCab[NF_VALTST]	+= aNfItem[nX][IT_VALTST]
		aNfCab[NF_CRPRSIM]	+= aNfItem[nX][IT_CRPRSIM]
		aNfCab[NF_VALANTI]	+= aNfItem[nX][IT_VALANTI]
		aNfCab[NF_DESNTRB]	+= aNfItem[nX][IT_DESNTRB]
		aNfCab[NF_TARA]		+= aNfItem[nX][IT_TARA]
		aNfCab[NF_VALFECP]	+= aNfItem[nX][IT_VALFECP]
		aNfCab[NF_VFCPDIF]	+= aNfItem[nX][IT_VFCPDIF]
		aNfCab[NF_BASEDES]	+= aNfItem[nX][IT_BASEDES]
		aNfCab[NF_VFECPST]	+= aNfItem[nX][IT_VFECPST]
		aNfCab[NF_CRDPRES]	+= aNfItem[nX][IT_CRPRESC]
		aNfCab[NF_CRDPRES]	+= aNfItem[nX][IT_CRPREMG]
		aNfCab[NF_CRDPRES]	+= aNfItem[nX][IT_CRPRECE]
		aNfCab[NF_VALII]	+= aNfItem[nX][IT_VALII]
		aNfCab[NF_CRPREPE]	+= aNfItem[nX][IT_CRPREPE]
		aNfCab[NF_VALFAB]	+= aNfItem[nX][IT_VALFAB]
		aNfCab[NF_VALFAC]	+= aNfItem[nX][IT_VALFAC]
		aNfCab[NF_VALFUM]	+= aNfItem[nX][IT_VALFUM]
		aNfCab[NF_VLSENAR]	+= aNfItem[nX][IT_VLSENAR]
		aNfCab[NF_CROUTSP]	+= aNfItem[nX][IT_CROUTSP]
		aNfCab[NF_BSSEMDS]	+= aNfItem[nX][IT_BSSEMDS]
		aNfCab[NF_ICSEMDS]	+= aNfItem[nX][IT_ICSEMDS]
		aNfCab[NF_VLINCMG]	+= aNfItem[nX][IT_VLINCMG]
		aNfCab[NF_TOTAL]	+= aNfItem[nX][IT_VLINCMG]
		If cPaisLoc == "RUS"
			aNfCab[NF_TOTAL_C1]	+= xMoeda(aNfItem[nX][IT_VLINCMG],aNfCab[NF_MOEDA],1,dDataBase,,aNfCab[NF_TXMOEDA])
		EndIf
		aNfCab[NF_BASEINA]	+= aNfItem[nX][IT_BASEINA]
		aNFCab[NF_VALINA]	+= aNfItem[nX][IT_VALINA]
		aNfCab[NF_VFECPRN]	+= aNfItem[nX][IT_VFECPRN]
		aNfCab[NF_VFESTRN]	+= aNfItem[nX][IT_VFESTRN]
		aNfCab[NF_CREDPRE]	+= aNfItem[nX][IT_CREDPRE]
		aNfCab[NF_VFECPMG]	+= aNfItem[nX][IT_VFECPMG]
		aNfCab[NF_VFESTMG]	+= aNfItem[nX][IT_VFESTMG]
		aNfCab[NF_VREINT]	+= aNfItem[nX][IT_VREINT]
		aNfCab[NF_BSREIN]	+= aNfItem[nX][IT_BSREIN]
		aNfCab[NF_VFECPMT]	+= aNfItem[nX][IT_VFECPMT]
		aNfCab[NF_VFESTMT]	+= aNfItem[nX][IT_VFESTMT]
		aNfCab[NF_ISSABMT] 	+= aNfItem[nX][IT_ABMATISS]
		aNfCab[NF_ISSABSR]	+= aNfItem[nX][IT_ABVLISS]
		aNfCab[NF_INSABMT]	+= aNfItem[nX][IT_AVLINSS]
		aNfCab[NF_INSABSR]	+= aNfItem[nX][IT_ABVLINSS]
		aNfCab[NF_VALTPDP]  += aNfItem[nX][IT_VALTPDP]
		aNfCab[NF_BASTPDP]  += aNfItem[nX][IT_BASTPDP]
		aNfCab[NF_VALFUND]	+= aNfItem[nX][IT_VALFUND]
		aNfCab[NF_VALIMA]	+= aNfItem[nX][IT_VALIMA]
		aNfCab[NF_VALFASE]	+= aNfItem[nX][IT_VALFASE]
		aNfCab[NF_VLIMAR]	+= aNfItem[nX][IT_VLIMAR]
		aNfCab[NF_VLFASER]	+= aNfItem[nX][IT_VLFASER]
		aNfCab[NF_VALINP]   += aNfItem[nX][IT_VALINP]
		aNfCab[NF_AFRMIMP]	+= aNfItem[nX][IT_AFRMIMP]
		aNfCab[NF_VALPRO]   += aNfItem[nX][IT_VALPRO]
		aNfCab[NF_BFCPANT]  += aNfItem[nX][IT_BFCPANT]
		aNfCab[NF_VFCPANT]  += aNfItem[nX][IT_VFCPANT]
		aNfCab[NF_BASFECP]  += aNfItem[nX][IT_BASFECP]
		aNfCab[NF_BSFCPST]  += aNfItem[nX][IT_BSFCPST]
		aNfCab[NF_BSFCCMP]  += aNfItem[nX][IT_BSFCCMP]

		If cPaisLoc == "BRA"
			For nTrbGen:= 1 to Len(aNfItem[nx][IT_TRIBGEN])

				If (nPosGen := aScan(aNfCab[NF_TRIBGEN], {|x| AllTrim(x[TG_NF_SIGLA]) == AllTrim(aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA])})) == 0
					aAdd(aNfCab[NF_TRIBGEN], Array(NMAX_NF_TG))
					nPosGen := Len(aNfCab[NF_TRIBGEN])
					aNfCab[NF_TRIBGEN][nPosGen][TG_NF_SIGLA] 		:= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA]
					aNfCab[NF_TRIBGEN][nPosGen][TG_NF_BASE]  		:= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_BASE]
					aNfCab[NF_TRIBGEN][nPosGen][TG_NF_VALOR] 		:= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]
					aNfCab[NF_TRIBGEN][nPosGen][TG_NF_REGRA_FIN] 	:= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_FIN]
					aNfCab[NF_TRIBGEN][nPosGen][TG_NF_ID_REGRA] 	:= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ID_REGRA]
					aNfCab[NF_TRIBGEN][nPosGen][TG_NF_ALQ_CODURF] 	:= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_CODURF]
					aNfCab[NF_TRIBGEN][nPosGen][TG_NF_ALQ_PERURF] 	:= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_PERURF]
					aNfCab[NF_TRIBGEN][nPosGen][TG_NF_IDTRIB] 	    := aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_IDTRIB]

					IF aDic[AI_CJ2]
						aNfCab[NF_TRIBGEN][nPosGen][TG_NF_DED_DEP] 		:= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_DED_DEP]
						aNfCab[NF_TRIBGEN][nPosGen][TG_NF_REGRA_GUIA]   := aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_GUIA]
						aNfCab[NF_TRIBGEN][nPosGen][TG_NF_VAL_MAJ]   	:= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_MAJORADO]
					Endif

				Else
					aNfCab[NF_TRIBGEN][nPosGen][TG_NF_BASE]  += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_BASE]
					aNfCab[NF_TRIBGEN][nPosGen][TG_NF_VALOR] += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]
					
					IF aDic[AI_CJ2]
						aNfCab[NF_TRIBGEN][nPosGen][TG_NF_DED_DEP] += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_DED_DEP]
						aNfCab[NF_TRIBGEN][nPosGen][TG_NF_VAL_MAJ] += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_MAJORADO]
					Endif
				EndIf

			Next nTrbGen
		EndIf

	EndIf
Else
	// Atualiza os campos totalizadores.
	aNfCab[NF_DESCONTO]	-= aNfItem[nX][IT_DESCONTO]
	aNfCab[NF_FRETE]	-= aNfItem[nX][IT_FRETE]
	aNfCab[NF_DESPESA]	-= aNfItem[nX][IT_DESPESA]
	aNfCab[NF_SEGURO]	-= aNfItem[nX][IT_SEGURO]
	aNfCab[NF_VALEMB]	-= aNfItem[nX][IT_VALEMB]
	aNfCab[NF_AUTONOMO]	-= aNfItem[nX][IT_AUTONOMO]
	aNfCab[NF_BASEICM]	-= aNfItem[nX][IT_BASEICM]
	aNfCab[NF_VALICM]	-= aNfItem[nX][IT_VALICM]
	aNfCab[NF_BASESOL]	-= aNfItem[nX][IT_BASESOL]
	aNfCab[NF_VALSOL]	-= aNfItem[nX][IT_VALSOL]
	aNfCab[NF_BICMORI]	-= aNfItem[nX][IT_BICMORI]
	aNfCab[NF_VALCMP]	-= aNfItem[nX][IT_VALCMP]
	aNfCab[NF_DIFAL]    -= aNfItem[nX][IT_DIFAL]
	aNfCab[NF_BASEIPI]	-= aNfItem[nX][IT_BASEIPI]
	aNfCab[NF_BIPIORI]	-= aNfitem[nX][IT_BIPIORI]
	aNfCab[NF_VALIPI]	-= aNfItem[nX][IT_VALIPI]
	aNfCab[NF_TOTAL]	-= aNfItem[nX][IT_TOTAL]
	aNfCab[NF_VALMERC]	-= aNfItem[nX][IT_VALMERC]-aNfItem[nX][IT_VNAGREG]
	If cPaisLoc == "RUS"
		aNfCab[NF_TOTAL_C1]	-= aNfItem[nX][IT_TOTAL_C1]
		aNfCab[NF_VALMERC_C1]	-= aNfItem[nX][IT_VALMERC_C1]-xMoeda(aNfItem[nX][IT_VNAGREG],aNfCab[NF_MOEDA],1,dDataBase,,aNfCab[NF_TXMOEDA])
	EndIf
	aNfCab[NF_VNAGREG] 	-= aNfItem[nX][IT_VNAGREG]
	aNfCab[NF_FUNRURAL]	-= aNfItem[nX][IT_FUNRURAL]
	aNfCab[NF_BASEIRR]	-= aNfItem[nX][IT_BASEIRR]
	aNfCab[NF_VALIRR]	-= aNfItem[nX][IT_VALIRR]
	aNfCab[NF_BASEINS]	-= aNfItem[nX][IT_BASEINS]
	aNfCab[NF_VALINS]	-= aNfItem[nX][IT_VALINS]
	aNfCab[NF_BASEISS]	-= aNfItem[nX][IT_BASEISS]
	aNfCab[NF_VALISS]	-= aNfItem[nX][IT_VALISS]
	aNfCab[NF_BASEDUP]	-= aNfItem[nX][IT_BASEDUP]
	aNfCab[NF_DESCZF]	-= aNfItem[nX][IT_DESCZF]
	aNfCab[NF_PESO]		-= aNfItem[nX][IT_PESO]
	aNfCab[NF_ICMFRETE]	-= aNfItem[nX][IT_ICMFRETE]
	aNfCab[NF_BSFRETE]	-= aNfItem[nX][IT_BSFRETE]
	aNfCab[NF_BASEICA]	-= aNfItem[nX][IT_BASEICA]
	aNfCab[NF_VALICA]	-= aNfItem[nX][IT_VALICA]
	aNfCab[NF_BASECOF]	-= aNfItem[nX][IT_BASECOF]
	aNfCab[NF_VALCOF]	-= aNfItem[nX][IT_VALCOF]
	aNfCab[NF_BASEPIS]	-= aNfItem[nX][IT_BASEPIS]
	aNfCab[NF_VALPIS]	-= aNfItem[nX][IT_VALPIS]
	aNfCab[NF_BASEPS2]  -= aNfItem[nX][IT_BASEPS2]
	aNfCab[NF_VALPS2]   -= aNfItem[nX][IT_VALPS2]
	aNfCab[NF_BASECF2]  -= aNfItem[nX][IT_BASECF2]
	aNfCab[NF_VALCF2]   -= aNfItem[nX][IT_VALCF2]
	aNfCab[NF_BASECSL]	-= aNfItem[nX][IT_BASECSL]
	aNfCab[NF_VALCSL]	-= aNfItem[nX][IT_VALCSL]
	aNfCab[NF_BASEINA]	-= aNfItem[nX][IT_BASEINA]
	aNFCab[NF_VALINA]	-= aNfItem[nX][IT_VALINA]
	aNFCab[NF_ADIANT]	-= aNfItem[nX][IT_ADIANT]
	aNfCab[NF_DESCTOT]  -= aNfItem[nX][IT_DESCTOT]
	aNfCab[NF_ACRESCI]	-= aNfItem[nX][IT_ACRESCI]
	aNfCab[NF_VALCIDE]  -= aNfItem[nX][IT_VALCIDE]
	aNfCab[NF_BASECID]  -= aNfItem[nX][IT_BASECID]
	aNfCab[NF_BASECPM]  -= aNfItem[nX][IT_BASECPM]
	aNfCab[NF_VALCPM]   -= aNfItem[nX][IT_VALCPM]
	aNfCab[NF_IPIVFCF]  -= aNfItem[nX][IT_IPIVFCF]
	aNfCab[NF_BASEFMP]  -= aNfItem[nX][IT_BASEFMP]
	aNfCab[NF_VALFMP]   -= aNfItem[nX][IT_VALFMP]
	aNfCab[NF_VALFMD]   -= aNfItem[nX][IT_VALFMD]
	aNfCab[NF_BASNDES] 	-= aNfItem[nX][IT_BASNDES]
	aNfCab[NF_ICMNDES]  -= aNfItem[nX][IT_ICMNDES]
	aNfCab[NF_DEDICM]   -= aNfItem[nX][IT_DEDICM]

	If cPaisLoc == "PER" .and. aPos[FP_F1_ADIANT]
		aNfCab[NF_ADIANTTOT]-= aNfItem[nX][IT_ADIANTTOT]
	EndIf

	If cPaisLoc == "BRA" .Or. lNotRemito
		For nG := 1 To NMAXIV
			aNfCab[NF_BASEIMP][nG] -= aNfItem[nX][IT_BASEIMP][nG]
			aNfCab[NF_VALIMP][nG]  -= aNfItem[nX][IT_VALIMP][nG]
			aNfCab[NF_VLRORIG][nG] -= aNfItem[nX][IT_VALIMP][nG]
			If cPaisLoc == "RUS"
				aNfCab[NF_BASEIMP_C1][nG] -= aNfItem[nX][IT_BASEIMP_C1][nG]
				aNfCab[NF_VALIMP_C1][nG]  -= aNfItem[nX][IT_VALIMP_C1][nG]
			EndIf
		Next nG
	EndIf
	If cPaisLoc <> "BRA" .And. (cCampo=="IT_DESCONTO" .OR. cCampo=="IT_DESCTOT") .And. (aNfCab[NF_OPERNF] =='S' .Or. (aNFitem[nX][IT_TIPONF ]$"DB" .And. Alltrim(cFunName) $ "MATA465N|MATA462DN" .And. cPaisLoc $ "MEX|PAR|PER|VEN|COL" .And. cCampo<>"IT_TES")) .And. aSX6[MV_DESCSAI]=='1'
		aNFitem[nX][IT_VALMERC] += (aNFitem[nX][IT_DESCONTO]+aNFitem[nX][IT_DESCTOT])
		aNFitem[nX][IT_PRCUNI]  := aNFitem[nX][IT_VALMERC] / Max(aNFitem[nX][IT_QUANT],1)
	ElseIf cPaisLoc == "ARG" .And. (cCampo == "IT_QUANT" .Or. cCampo == "IT_PRCUNI") .And. Alltrim(FunName()) $ "MATA467N|MATA465N"
		If aNFitem[nX][IT_DESCONTO]+aNFitem[nX][IT_DESCTOT] <> 0
			If (cCampo == "IT_QUANT") .And. aNfCab[NF_OPERNF] =='S' .And. aSX6[MV_DESCSAI]=='1'
				aNFitem[nX][IT_PRCUNI] += ((aNFitem[nX][IT_DESCONTO]+aNFitem[nX][IT_DESCTOT])/aNFitem[nX][IT_QUANT])
			EndIf
		EndIf
	EndIf
	aNfCab[NF_ICMSDIF]	-= aNfItem[nX][IT_ICMSDIF]
	aNfCab[NF_BASEAFRMM]-= aNfItem[nX][IT_BASEAFRMM]
	aNfCab[NF_VALAFRMM] -= aNfItem[nX][IT_VALAFRMM]
	aNfCab[NF_PIS252]	-= aNfItem[nX][IT_PIS252]
	aNfCab[NF_COF252]	-= aNfItem[nX][IT_COF252]
	aNfCab[NF_BASESES]	-= aNfItem[nX][IT_BASESES]
	aNfCab[NF_VALSES]	-= aNfItem[nX][IT_VALSES]
	aNfCab[NF_BASEPS3]	-= aNfItem[nX][IT_BASEPS3]
	aNfCab[NF_VALPS3]	-= aNfItem[nX][IT_VALPS3]
	aNfCab[NF_BASECF3]	-= aNfItem[nX][IT_BASECF3]
	aNfCab[NF_VALCF3]	-= aNfItem[nX][IT_VALCF3]
	aNfCab[NF_VLR_FRT]	-= aNfItem[nX][IT_VLR_FRT]
	aNfCab[NF_VALFET]	-= aNfItem[nX][IT_VALFET]
	aNfCab[NF_VALFETR]	-= aNfItem[nX][IT_VALFETR]
	aNfCab[NF_VALFDS]	-= aNfItem[nX][IT_VALFDS]
	aNfCab[NF_ESTCRED]	-= aNfItem[nX][IT_ESTCRED]
	aNfCab[NF_BASETST]	-= aNfItem[nX][IT_BASETST]
	aNfCab[NF_VALTST]	-= aNfItem[nX][IT_VALTST]
	aNfCab[NF_CRPRSIM]	-= aNfItem[nX][IT_CRPRSIM]
	aNfCab[NF_VALANTI]	-= aNfItem[nX][IT_VALANTI]
	aNfCab[NF_DESNTRB]	-= aNfItem[nX][IT_DESNTRB]
	aNfCab[NF_TARA]		-= aNfItem[nX][IT_TARA]
	aNfCab[NF_VALFECP]	-= aNfItem[nX][IT_VALFECP]
	aNfCab[NF_VFCPDIF]	-= aNfItem[nX][IT_VFCPDIF]
	aNfCab[NF_BASEDES]	-= aNfItem[nX][IT_BASEDES]
	aNfCab[NF_VFECPST]	-= aNfItem[nX][IT_VFECPST]
	aNfCab[NF_CRDPRES]	-= aNfItem[nX][IT_CRPRESC]
	aNfCab[NF_CRDPRES]	-= aNfItem[nX][IT_CRPREMG]
	aNfCab[NF_CRDPRES]	-= aNfItem[nX][IT_CRPRECE]
	aNfCab[NF_VALII]	-= aNfItem[nX][IT_VALII]
	aNfCab[NF_CRPREPE]	-= aNfItem[nX][IT_CRPREPE]
	aNfCab[NF_VALFAB] 	-= aNfItem[nX][IT_VALFAB]
	aNfCab[NF_VALFAC] 	-= aNfItem[nX][IT_VALFAC]
	aNfCab[NF_VALFUM]	-= aNfItem[nX][IT_VALFUM]
	aNfCab[NF_VLSENAR]	-= aNfItem[nX][IT_VLSENAR]
	aNfCab[NF_CROUTSP]	-= aNfItem[nX][IT_CROUTSP]
	aNfCab[NF_BSSEMDS]	-= aNfItem[nX][IT_BSSEMDS]
	aNfCab[NF_ICSEMDS]	-= aNfItem[nX][IT_ICSEMDS]
	aNfCab[NF_BASEFUN]	-= aNfItem[nX][IT_BASEFUN]
	aNfCab[NF_VLINCMG]	-= aNfItem[nX][IT_VLINCMG]
	aNfCab[NF_TOTAL]	-= aNfItem[nX][IT_VLINCMG]
	If cPaisLoc == "RUS"
		aNfCab[NF_TOTAL_C1]	-= xMoeda(aNfItem[nX][IT_VLINCMG],aNfCab[NF_MOEDA],1,dDataBase,,aNfCab[NF_TXMOEDA])
	EndIf
	aNfCab[NF_VFECPRN]	-= aNfItem[nX][IT_VFECPRN]
	aNfCab[NF_VFESTRN]	-= aNfItem[nX][IT_VFESTRN]
	aNfCab[NF_CREDPRE]	-= aNfItem[nX][IT_CREDPRE]
	aNfCab[NF_VFECPMG]	-= aNfItem[nX][IT_VFECPMG]
	aNfCab[NF_VFESTMG]	-= aNfItem[nX][IT_VFESTMG]
	aNfCab[NF_VREINT]	-= aNfItem[nX][IT_VREINT]
	aNfCab[NF_BSREIN]	-= aNfItem[nX][IT_BSREIN]
	aNfCab[NF_VFECPMT]	-= aNfItem[nX][IT_VFECPMT]
	aNfCab[NF_VFESTMT]	-= aNfItem[nX][IT_VFESTMT]
	aNfCab[NF_ISSABMT] 	-= aNfItem[nX][IT_ABMATISS]
	aNfCab[NF_ISSABSR]	-= aNfItem[nX][IT_ABVLISS]
	aNfCab[NF_INSABMT]	-= aNfItem[nX][IT_AVLINSS]
	aNfCab[NF_INSABSR]	-= aNfItem[nX][IT_ABVLINSS]
	aNfCab[NF_VALTPDP]  -= aNfItem[nX][IT_VALTPDP]
	aNfCab[NF_BASTPDP]  -= aNfItem[nX][IT_BASTPDP]
	aNfCab[NF_VALFUND]	-= aNfItem[nX][IT_VALFUND]
	aNfCab[NF_VALIMA]	-= aNfItem[nX][IT_VALIMA]
	aNfCab[NF_VALFASE]	-= aNfItem[nX][IT_VALFASE]
	aNfCab[NF_VLIMAR]	-= aNfItem[nX][IT_VLIMAR]
	aNfCab[NF_VLFASER]	-= aNfItem[nX][IT_VLFASER]
	aNfCab[NF_VALINP]   -= aNfItem[nX][IT_VALINP]
	aNfCab[NF_AFRMIMP]	-= aNfItem[nX][IT_AFRMIMP]
	aNfCab[NF_VALPRO]   -= aNfItem[nX][IT_VALPRO]
	aNfCab[NF_BFCPANT]  -= aNfItem[nX][IT_BFCPANT]
	aNfCab[NF_VFCPANT]  -= aNfItem[nX][IT_VFCPANT]
	aNfCab[NF_BASFECP]  -= aNfItem[nX][IT_BASFECP]
	aNfCab[NF_BSFCPST]  -= aNfItem[nX][IT_BSFCPST]
	aNfCab[NF_BSFCCMP]  -= aNfItem[nX][IT_BSFCCMP]

	If cPaisLoc == "BRA"
		For nTrbGen:= 1 to Len(aNfItem[nx][IT_TRIBGEN])

			If (nPosGen := aScan(aNfCab[NF_TRIBGEN], {|x| AllTrim(x[TG_NF_SIGLA]) == AllTrim(aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA])})) > 0
				aNfCab[NF_TRIBGEN][nPosGen][TG_NF_BASE]  -= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_BASE]
				aNfCab[NF_TRIBGEN][nPosGen][TG_NF_VALOR] -= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]
				
				If aDic[AI_CJ2]
					aNfCab[NF_TRIBGEN][nPosGen][TG_NF_DED_DEP] -= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_DED_DEP]
				Endif

				// Quando a base e o valor forem zerados, excluo a posição do totalizador. Isso evita que o cabeçalho
				// contenha referências zeradas de tributos que podem, eventualmente, não ser calculados no item. Por
				// exemplo na hipótese de alteração de alguma referência "chave" de forma que antes eram calculados
				// 3 tributos e depois de alterar são calculados só 2 devido ao re-enquadramento das regras.
				If aNfCab[NF_TRIBGEN][nPosGen][TG_NF_BASE] == 0 .And. aNfCab[NF_TRIBGEN][nPosGen][TG_NF_VALOR] == 0
					aDel(aNfCab[NF_TRIBGEN], nPosGen)
					aSize(aNfCab[NF_TRIBGEN], Len(aNfCab[NF_TRIBGEN])-1)
				EndIf
			EndIf

		Next nTrbGen
	EndIf
EndIf
Return

/*/
MaFisScan-Eduardo/Edson   -02.04.2002
Func de procura da posicao da referencia nos arrays internos
/*/
Function xFisScan(cCampo,lErro,aItemRef,aCabRef,aLFis,aResRef,aTGITRef,aTGNFRef,aTGLFRef)

Local cPosCpo := 0
Local nScan   := 0
Local lRefVld := .F.
Local aScan	  :={}
Local cHMGet  := 'HMGet'

DEFAULT lErro := .T.

If Substr(cCampo,1,2) == "IT"
	if lbuild .and. oHItemRef <> Nil .and. &cHMGet.(oHItemRef,cCampo,@aScan)
		cPosCpo	:= aScan[1][2]
	else
		nScan	:= aScan(aItemRef,{|x|x[1]==cCampo})
		If nScan > 0
			cPosCpo	:= aItemRef[nScan][2]
		Else
			If lErro
				If IsBlind() //Utilizado IsBlind() + UserException() em detrimento de Final() para interromper a aplicacao quando utilizado em EAI Mensagem Unica/ WS / Rotinas Automaticas.
					UserException( STR0001 + cCampo ) //"ERRO MATXFIS - Referencia de imposto invalida "
				Else
					MsgAlert(STR0001 + cCampo ) //"ERRO MATXFIS - Referencia de imposto invalida : "
					MsgAlert(STR0029+STR0030+CHR(13)+CHR(10)+CHR(13)+CHR(10)+ STR0031)
					Final(STR0002) //"ERRO MATXFIS - Referencia de imposto invalida "
				EndIf
			EndIf
		EndIf
	endif
ElseIf Substr(cCampo,1,2) == "NF"
	if lbuild .and. oHCabRef <> Nil .and. &cHMGet.(oHCabRef,cCampo,@aScan)
		cPosCpo	:= aScan[1][2]
	else
		nScan	:= aScan(aCabRef,{|x|x[1]==cCampo})
		If nScan > 0
			cPosCpo	:= aCabRef[nScan][2]
		Else
			If lErro
				If IsBlind()
					UserException( STR0001 + cCampo ) //"ERRO MATXFIS - Referencia de imposto invalida "
				Else
					MsgAlert(STR0001 + cCampo ) //"ERRO MATXFIS - Referencia de imposto invalida : "
					MsgAlert(STR0029+STR0030+CHR(13)+CHR(10)+CHR(13)+CHR(10)+ STR0031)
					Final(STR0002) //"ERRO MATXFIS - Referencia de imposto invalida "
				EndIf
			EndIf
		EndIf
	endif
ElseIf Substr(cCampo,1,2) == "LF"
	if lbuild .and. oHLFis <> Nil .and. &cHMGet.(oHLFis,cCampo,@aScan)
		cPosCpo	:= aScan[1][2]
	else
		nScan	:= aScan(aLFis,{|x|x[1]==cCampo})
		If nScan > 0
			cPosCpo	:= aLFis[nScan][2]
		Else
			If lErro
				If IsBlind()
					UserException( STR0001 + cCampo ) //"ERRO MATXFIS - Referencia de imposto invalida "
				Else
					MsgAlert(STR0001 + cCampo ) //"ERRO MATXFIS - Referencia de imposto invalida : "
					MsgAlert(STR0029+STR0030+CHR(13)+CHR(10)+CHR(13)+CHR(10)+ STR0031)
					Final(STR0002) //"ERRO MATXFIS - Referencia de imposto invalida "
				EndIf
			EndIf
		EndIf
	endif
ElseIf Substr(cCampo,1,3) == "IMP"
	if lbuild .and. oHResRef <> Nil .and. &cHMGet.(oHResRef,cCampo,@aScan)
		cPosCpo	:= aScan[1][2]
	else
		nScan 	:= aScan(aResRef,{|x|x[1]==cCampo})
		If nScan > 0
			cPosCpo	:= aResRef[nScan][2]
		Else
			If lErro
				If IsBlind()
					UserException( STR0001 + cCampo ) //"ERRO MATXFIS - Referencia de imposto invalida "
				Else
					MsgAlert(STR0001 + cCampo ) //"ERRO MATXFIS - Referencia de imposto invalida : "
					MsgAlert(STR0029+STR0030+CHR(13)+CHR(10)+CHR(13)+CHR(10)+ STR0031)
					Final(STR0002) //"ERRO MATXFIS - Referencia de imposto invalida "
				EndIf
			EndIf
		EndIf
	endif
ElseIf Substr(cCampo,1,2) == "TG"

	If Substr(cCampo,1,5) == "TG_IT"
		if lbuild .and. oHTGITRef <> Nil .and. &cHMGet.(oHTGITRef,cCampo,@aScan)
			cPosCpo	:= aScan[1][2]
			lRefVld := .T.
		else
			If (nScan := aScan(aTGITRef,{|x|x[1]==cCampo})) > 0
				cPosCpo	:= aTGITRef[nScan][2]
				lRefVld := .T.
			EndIf
		endif
	ElseIf Substr(cCampo,1,5) == "TG_NF"
		if lbuild .and. oHTGNFRef <> Nil .and. &cHMGet.(oHTGNFRef,cCampo,@aScan)
			cPosCpo	:= aScan[1][2]
			lRefVld := .T.
		else
			If (nScan 	:= aScan(aTGNFRef,{|x|x[1]==cCampo})) > 0
				cPosCpo	:= aTGNFRef[nScan][2]
				lRefVld := .T.
			EndIF
		endif
	ElseIf Substr(cCampo,1,5) == "TG_LF"
		if lbuild .and. oTGLFRef <> Nil .and. &cHMGet.(oTGLFRef,cCampo,@aScan)
			cPosCpo	:= aScan[1][2]
			lRefVld := .T.
		Else	
			If (nScan 	:= aScan(aTGLFRef,{|x|x[1]==cCampo})) > 0
				cPosCpo	:= aTGLFRef[nScan][2]
				lRefVld := .T.
			EndIF
		EndIF
	EndIf

	If !lRefVld
		If lErro
			If IsBlind()
				UserException( STR0001 + cCampo ) //"ERRO MATXFIS - Referencia de imposto invalida "
			Else
				MsgAlert(STR0001 + cCampo ) //"ERRO MATXFIS - Referencia de imposto invalida : "
				MsgAlert(STR0029+STR0030+CHR(13)+CHR(10)+CHR(13)+CHR(10)+ STR0031)
				Final(STR0002) //"ERRO MATXFIS - Referencia de imposto invalida "
			EndIf
		EndIf
	EndIf

EndIf

Return(cPosCpo)

/*
MaFisLFToLivro - Edson Maricate - 07.03.2000
Adiciona o item nos livros fiscais
*/
Function xLFToLivro(nItem,aNotasOri,lSoma,aPos,aNfItem,aTes,aNfCab,aPE,aSX6)
Local alAreaX  := {}
Local aGetBook := {}
Local aSFB     := {}
Local aSFC     := {}
Local aSF4     := {}

Local cAux     := ""
Local cIdent   := ""
Local cNFOri   := ""
Local cObs     := ""

Local cObsCab  := ""
Local nIniCSS  := 0
Local nFimCSS  := 0
Local nVlrCSS  := 0

Local nLF      := 0
Local nY       := 0
Local nX       := 0
Local nS	   := 0

Local dDataEmi := dDataBase

Local lImport  := .F.
Local lFildPSWN:= aPos[FP_WN_TES] .And. aPos[FP_WN_ITEMNF]
Local lAchouWN := .F.
Local nPosTESM	:= 0
Local nTasaMoneda := 0	//OPTIMIZA
Local lIncIPM    := .T.
Local nCpoIPM    := 3

DEFAULT lSoma  := .T.

//Campo de Libro y IPM 
If cPaisLoc == "PER"
	If aNfCab[NF_CPOIPM] <> 0
		nCpoIPM := aNfCab[NF_CPOIPM]
	EndIf
EndIf

If aNfItem[nItem][IT_TES] <> aTes[TS_CODIGO]
	If cPaisLoc == "ARG"
		If Type("aTesMXF") <> "U"
			nPosTESM := Ascan(aTesMXF,{|X| X[1] == nItem})
		EndIf
		If nPosTESM > 0
			aTes := aClone(aTesMXF[nPosTESM][2])
		Else
			MaFisTes(aNfItem[nItem][IT_TES],aNfItem[nItem][IT_RECNOSF4],nItem)
			If Type("aTesMXF") <> "U" .and. nPosTESM == 0
				AADD(aTesMXF,{nItem,aClone(aTes)})
			EndIf
		EndIf
	Else
		MaFisTes(aNfItem[nItem][IT_TES],aNfItem[nItem][IT_RECNOSF4],nItem)
	EndIf
EndIf

//Montagem dos Livros Fiscals ( aLivro )
If cPaisLoc == "BRA"
	If 	aNfItem[nItem][IT_LIVRO][3] +;
		aNfItem[nItem][IT_LIVRO][4] +;
		aNfItem[nItem][IT_LIVRO][5] +;
		aNfItem[nItem][IT_LIVRO][6] +;
		aNfItem[nItem][IT_LIVRO][7] +;
		aNfItem[nItem][IT_LIVRO][9] +;
		aNfItem[nItem][IT_LIVRO][10]+;
		aNfItem[nItem][IT_LIVRO][11]+;
		aNfItem[nItem][IT_LIVRO][27]+;
		aNfItem[nItem][IT_LIVRO][131] <> 0 .Or. !Empty(aNfItem[nItem][IT_LIVRO][24])

		If aNfItem[nItem][IT_CALCISS] == "S"
			nLF	:= aScan(aNfCab[NF_LIVRO],{|x|x[LF_CFO] == aNfItem[nItem][IT_LIVRO][LF_CFO] .And. ;
			x[LF_CODISS]  == aNfItem[nItem][IT_LIVRO][LF_CODISS]  .And. ;
			x[LF_ALIQICMS]== aNfItem[nItem][IT_LIVRO][LF_ALIQICMS].And. ;
			x[LF_NFLIVRO] == aNfItem[nItem][IT_LIVRO][LF_NFLIVRO] .And. ;
			x[LF_FORMULA] == aNfItem[nItem][IT_LIVRO][LF_FORMULA] .And. ;
			x[LF_ANTICMS] == aNfItem[nItem][IT_LIVRO][LF_ANTICMS] .And. ;
			x[LF_CFPS]    == aNfItem[nItem][IT_LIVRO][LF_CFPS]})
		Else
			nLF	:= aScan(aNfCab[NF_LIVRO],{|x|x[LF_CFO] == aNfItem[nItem][IT_LIVRO][LF_CFO] .And. ;
			x[LF_CFOEXT]  == aNfItem[nItem][IT_LIVRO][LF_CFOEXT]  .And. ;
			x[LF_ALIQICMS]== aNfItem[nItem][IT_LIVRO][LF_ALIQICMS].And. ;
			x[LF_NFLIVRO] == aNfItem[nItem][IT_LIVRO][LF_NFLIVRO] .And. ;
			x[LF_FORMULA] == aNfItem[nItem][IT_LIVRO][LF_FORMULA] .And. ;
			x[LF_CODISS]  == aNfItem[nItem][IT_LIVRO][LF_CODISS]  .And. ;
			x[LF_ANTICMS] == aNfItem[nItem][IT_LIVRO][LF_ANTICMS] .And. ;
			x[LF_CREDACU] == aNfItem[nItem][IT_LIVRO][LF_CREDACU] .And. ;
			x[LF_CFPS]    == aNfItem[nItem][IT_LIVRO][LF_CFPS]})
		EndIf

		cIdent := StrZero(nLF,6)

		If nLF == 0

			aNotasOri := {}
			aadd( aNfCab[NF_LIVRO] , MaFisRetLF() )
			nLF	:= Len(aNfCab[NF_LIVRO])

			aNfCab[NF_LIVRO][nLF][LF_CFO]     := aNfItem[nItem][IT_LIVRO][LF_CFO]
			aNfCab[NF_LIVRO][nLF][LF_CFOEXT]  := aNfItem[nItem][IT_LIVRO][LF_CFOEXT]
			aNfCab[NF_LIVRO][nLF][LF_ALIQICMS]:= aNfItem[nItem][IT_LIVRO][LF_ALIQICMS]
			aNfCab[NF_LIVRO][nLF][LF_NFLIVRO] := aNfItem[nItem][IT_LIVRO][LF_NFLIVRO]
			aNfCab[NF_LIVRO][nLF][LF_FORMULA] := aNfItem[nItem][IT_LIVRO][LF_FORMULA]
			aNfCab[NF_LIVRO][nLF][LF_TIPO]    := aNfItem[nItem][IT_LIVRO][LF_TIPO]
			aNfCab[NF_LIVRO][nLF][LF_CODISS]  := aNfItem[nItem][IT_LIVRO][LF_CODISS]
			aNfCab[NF_LIVRO][nLF][LF_FORMUL]  := aNfItem[nItem][IT_LIVRO][LF_FORMUL]
			aNfCab[NF_LIVRO][nLF][LF_ISSST]   := aNfItem[nItem][IT_LIVRO][LF_ISSST]
			aNfCab[NF_LIVRO][nLF][LF_RECISS]  := aNfItem[nItem][IT_LIVRO][LF_RECISS]
			aNfcab[NF_LIVRO][nLF][LF_CREDST]  := aNfItem[nItem][IT_LIVRO][LF_CREDST]
			aNfcab[NF_LIVRO][nLF][LF_CNAE]    := aNfItem[nItem][IT_LIVRO][LF_CNAE]
			aNfcab[NF_LIVRO][nLF][LF_TRIBMU]  := aNfItem[nItem][IT_LIVRO][LF_TRIBMU]

			//  Inconsistencia descoberta no SIGALOJA quanto utiliza-se
			//  MAFISALT depois de carregar todos os itens do cupom, onde necessita-se
			//  alterar centavos para manter o calculo da impressora igual ao do sistema.
			//  Esta condicao determina que o codigo indentificador de relacionamento ??_IDENT
			//  seja reutilizado do IT_ para o NF_ depois de ter passado pelo aDEL abaixo, onde
			//  exclui o indice do array que possui os valores zerados, porem nao exluir do aNFITEM
			//  O retorno do codigo identificador foi implementado pelo For/Next de nX abaixo
			If IsInCallStack("LJXCONFICM") .And. aScan(aNfcab[NF_LIVRO] , {|x| Alltrim(x[LF_IDENT]) == StrZero(nLF,6)}) > 0 //SIGALOJA
				For nX := 1 To Len(aNfcab[NF_LIVRO]) + 1
					If aScan(aNfcab[NF_LIVRO], {|x| x[LF_IDENT] == StrZero(nX,6)}) == 0
						Exit
					EndIf
				Next nX
				aNfcab[NF_LIVRO][nLF][LF_IDENT]:= StrZero(nX,6)
			Else
				aNfcab[NF_LIVRO][nLF][LF_IDENT]:= StrZero(nLF,6)
			EndIf

			cIdent := aNfcab[NF_LIVRO][nLF][LF_IDENT]

			aNfCab[NF_LIVRO][nLF][LF_CFPS]   := aNfItem[nItem][IT_LIVRO][LF_CFPS]
			aNfCab[NF_LIVRO][nLF][LF_ALIQIPI]:= aNfItem[nItem][IT_LIVRO][LF_ALIQIPI]
			aNfCab[NF_LIVRO][nLF][LF_ALIQCF3]:= aNfItem[nItem][IT_LIVRO][LF_ALIQCF3]
			aNfCab[NF_LIVRO][nLF][LF_ALIQPS3]:= aNfItem[nItem][IT_LIVRO][LF_ALIQPS3]
			aNfCab[NF_LIVRO][nLF][LF_ANTICMS]:= aNfItem[nItem][IT_LIVRO][LF_ANTICMS]
			aNfCab[NF_LIVRO][nLF][LF_CREDACU]:= aNfItem[nItem][IT_LIVRO][LF_CREDACU]
			aNfCab[NF_LIVRO][nLF][LF_CSTISS] := aNfItem[nItem][IT_LIVRO][LF_CSTISS]
			aNfCab[NF_LIVRO][nLF][LF_MOTICMS]:= aNfItem[nItem][IT_LIVRO][LF_MOTICMS]
			aNfCab[NF_LIVRO][nLF][LF_TPPRODE]:= aNfItem[nItem][IT_LIVRO][LF_TPPRODE]
			aNfCab[NF_LIVRO][nLF][LF_ALIQCPB]:= aNfItem[nItem][IT_LIVRO][LF_ALIQCPB]
			aNfCab[NF_LIVRO][nLF][LF_PERCINP]:= aNFItem[nItem][IT_LIVRO][LF_PERCINP]

			// REMOVIDO TRATAMENTO DE CAMPOS DO FECOP RN NO CHAMADO THIBOA, NAO DEVE SER COLOCADO AQUI POIS O TRATAMENTO EH DINAMICO.

			aNfCab[NF_LIVRO][nLF][LF_CLIDEST] := aNfItem[nItem][IT_LIVRO][LF_CLIDEST]
			aNfCab[NF_LIVRO][nLF][LF_LOJDEST] := aNfItem[nItem][IT_LIVRO][LF_LOJDEST]
			aNfCab[NF_LIVRO][nLF][LF_ALQCMAJ] := aNfItem[nItem][IT_LIVRO][LF_ALQCMAJ]

		EndIf

		For nY	:= 1 to Len(aNfCab[NF_LIVRO][nLf])
			If !AllTrim(StrZero(nY,3))$"001#002#015#016#018#020#023#024#031#032#033#036#042#043#044#045#046#047#048#051#052#053#058#061#070#075#076#077#081#088#094#095#096#097#098#099#100#112#116#128#140#142#145#146#148#150#151#155"
				If lSoma
					If AllTrim(StrZero(nY,3)) == "012"
						If aNfItem[nItem][IT_FUNRURAL] > 0 .And. aNfItem[nItem][IT_VLSENAR] > 0 .And. aNfItem[nItem][IT_VALINS] > 0 .AND. aSX6[MV_IMPCSS] == "S" // Imprime Contribuicao Seguridade Social
							cObs := STR0021 + Alltrim(Transform(aNfItem[nItem][IT_FUNRURAL]+aNfItem[nItem][IT_VLSENAR]+aNfItem[nItem][IT_VALINS],"@E 999,999,999.99")) //"CONT.SEG.SOCIAL: "
							cObsCab := cObs

							If STR0021 $ aNfCab[NF_LIVRO][nLF][LF_OBSERV]
								nIniCSS := AT( STR0021, aNfCab[NF_LIVRO][nLF][LF_OBSERV] ) + Len( STR0021 )
								nFimCSS := AT( ",", SubStr( aNfCab[NF_LIVRO][nLF][LF_OBSERV], 1 + Len( STR0021 ) ) ) + 2

								nVlrCSS := Val( Replace( Replace( SubStr( aNfCab[NF_LIVRO][nLF][LF_OBSERV], nIniCSS, nFimCSS ), ".", "" ), ",", "." ) )
								cObsCab := STR0021 + Alltrim( Transform( nVlrCSS + aNfItem[nItem][IT_FUNRURAL]+aNfItem[nItem][IT_VLSENAR]+aNfItem[nItem][IT_VALINS],"@E 999,999,999.99") )
							EndIf
						EndIf

						If !Empty(cObs) .OR. !Empty( cObsCab )
							aNfCab[NF_LIVRO][nLF][LF_OBSERV]   := IIF( !Empty( cObsCab ), cObsCab, cObs )
						EndIf
						
						aNfItem[nItem][IT_LIVRO][LF_OBSERV]:= cObs
					Else
						If Valtype(aNfItem[nItem][IT_LIVRO][nY])<>"A"
							aNfCab[NF_LIVRO][nLF][nY] += aNfItem[nItem][IT_LIVRO][nY]
						Else
							For nS := 1 To Len(aNfCab[NF_LIVRO][nLF][nY])
								aNfCab[NF_LIVRO][nLF][nY][nS] += aNfItem[nItem][IT_LIVRO][nY][nS]
							Next nS
						EndIf
					EndIf
				Else
					If AllTrim(StrZero(nY,3)) == "012"
						If STR0021 $ aNfCab[NF_LIVRO][nLF][LF_OBSERV]
							nIniCSS := AT( STR0021, aNfCab[NF_LIVRO][nLF][LF_OBSERV] ) + Len( STR0021 )
							nFimCSS := AT( ",", SubStr( aNfCab[NF_LIVRO][nLF][LF_OBSERV], 1 + Len( STR0021 ) ) ) + 2

							nVlrCSS := Val( Replace( Replace( SubStr( aNfCab[NF_LIVRO][nLF][LF_OBSERV], nIniCSS, nFimCSS ), ".", "" ), ",", "." ) )
							nVlrCSS -= aNfItem[nItem][IT_FUNRURAL]+aNfItem[nItem][IT_VLSENAR]+aNfItem[nItem][IT_VALINS]

							If nVlrCSS > 0
								aNfCab[NF_LIVRO][nLF][nY] := STR0021 + Alltrim( Transform( nVlrCSS, "@E 999,999,999.99" ) ) //"CONT.SEG.SOCIAL: "
							Else
								aNfCab[NF_LIVRO][nLF][nY] := ""
							EndIf
						EndIf
					Else
						If Valtype(aNfItem[nItem][IT_LIVRO][nY])<>"A"
							aNfCab[NF_LIVRO][nLF][nY] -= aNfItem[nItem][IT_LIVRO][nY]
						Else
							For nS := 1 To Len(aNfCab[NF_LIVRO][nLF][nY])
								aNfCab[NF_LIVRO][nLF][nY][nS] += aNfItem[nItem][IT_LIVRO][nY][nS]
							Next nS
						EndIf
					EndIf
				EndIf
			EndIf
		Next nY

		//Preenche a Observacao dos livros Fiscais
		cNFOri := IIf(!Empty(aNfItem[nItem][IT_NFORI]),aNfItem[nItem][IT_NFORI]+"/"+Substr(aNfItem[nItem][IT_SERORI],1,3),"")
		If !Empty(cNFOri) .And. aScan(aNotasOri,cNFOri) == 0
			aadd(aNotasOri,cNFOri)
		EndIf

		cNFOri := IIf(Len(aNotasOri)>1,STR0009,cNFOri) //"DIVERSAS"

		//Ponto de entrada para alteracao da mensagem quanto a devolucao
		If !Empty( aNotasOri )
			If aPE[PE_MAFISOBS]
				cNFOri := ExecBlock( "MAFISOBS", .F., .F., { cNfOri, AClone( aNotasOri ) } )
			EndIf
		EndIf

		Do Case
			Case aNfCab[NF_TIPONF]=="D"
				cObs := IIf( !Empty(cNFOri) , STR0011 + cNFOri , "" )      // "DEVOLUCAO N.F.:"
			Case aNfCab[NF_TIPONF]=="C" .And. aNfCab[NF_TPCOMP] == "F"
				cObs := STR0012                                             // "CONHEC. FRETE"
			Case aNfCab[NF_TIPONF]=="C" .And. aNfCab[NF_TPCOMP] == "D"
				cObs := STR0013                                             // "NF DESPESA"
			Case aNfCab[NF_TIPONF]=="C"
				If !Empty(aNfCab[NF_ESPECIE])
					cObs := STR0014 + "(" + aNfCab[NF_ESPECIE] + ")"+cNFOri // "COMPL.N.F.: "
				Else
					cObs := STR0014 + cNFOri                                 // "COMPL.N.F.: "
				EndIf
			Case aNfCab[NF_TIPONF] == "B".And. aNFItem[nItem][IT_TS][TS_PODER3] <> "R"
				cObs := IIf( !Empty(cNFOri) , STR0015 + cNFOri , "" )       // "N.F.ORIG.: "
			Case aNfCab[NF_TIPONF] == "P"
				If	aNfCab[NF_VALICM] > 0
					cObs := STR0047 + cNFOri                    					 // "COMPL.IPI + ICMS N.F.: "
				Else
					cObs := STR0016 + cNFOri                                     // "COMPL.IPI N.F.: "
				EndIf
			Case aNfCab[NF_TIPONF] == "I"
				If "CIAP" $ Upper(cNFORi)
					cObs := ""
				Else
					cObs := IIf( aNFItem[nItem][IT_TS][TS_ISS]<>"N",STR0022,STR0017)+cNFOri  // "COMPL.ICMS N.F.: " OU "COMPL.ISS N.F.: "
				EndIf
			Case aNfCab[NF_TPCLIFOR] == "X" .And. aNfCab[NF_OPERNF] == "S"
				cObs := ""
				If !Empty(cNFOri) .And. !AllTrim(aNfItem[nItem][IT_CF]) $ "5663/5664/5665/5666/6663/6664/6665/6666"
					cObs := STR0018 + cNFOri                                // "EXPORTACAO-GE No.: "
				Endif
			Case aNFItem[nItem][IT_TS][TS_IPI]=="R" .And. Empty(aNFItem[nItem][IT_TS][TS_TXAPIPI])
				cObs := STR0019                                             // "AQUIS.COMERC.NAO-CONTRIB.IPI"
			Case aNfCab[NF_TIPONF] == "N" .And. aNFItem[nItem][IT_TS][TS_PODER3] == "D" .And. aNFItem[nItem][IT_TS][TS_CONSIND] <> "1"
				cObs := Iif( !Empty(cNfOri) , (STR0020+cNFOri) , "" )      // "Dev. Benef. N.F.ORIG.: "
			Case aNFItem[nItem][IT_TS][TS_OBSSOL] == "3"
				cObs := " ICMS GARANTIDO "
			Case aNFItem[nItem][IT_TS][TS_OBSSOL] == "4"
				cObs := " ICMS GARANTIDO INTEGRAL "
			Case aNfCab[NF_CREDPRE] > 0
				cObs := " CREDITO PRESUMIDO R$ " + Alltrim(Transform(aNfCab[NF_CREDPRE],"@E 999,999,999.99"))
			Case aNfCab[NF_TIPONF] == "N" .And. aNFItem[nItem][IT_TS][TS_PODER3] == "D" .And. aNFItem[nItem][IT_TS][TS_CONSIND] == "1"
				If !Empty(cNfOri)
					cObs := "CONSIG INDUS,NF " + cNFOri + "DE " + DtoC(SD2->D2_EMISSAO)
				EndIf
			Case aNfCab[NF_VALFUND] > 0
				cObs := "CONT.FUNDESA LEI 12.380/05 R$ " + Alltrim(Transform(aNfCab[NF_VALFUND],"@E 999,999,999.99"))
		EndCase

		If !Empty(cObs) .OR. !Empty( cObsCab )
			aNfCab[NF_LIVRO][nLF][LF_OBSERV]   := IIF( !Empty( cObsCab ), cObsCab, cObs )
		EndIf
		aNfItem[nItem][IT_LIVRO][LF_OBSERV]:= cObs

		//Zera a coluna outras caso esteja menor que zero
		aNfCab[NF_LIVRO,nLF,LF_OUTRICM] := Max(aNfCab[NF_LIVRO,nLF,LF_OUTRICM],0)
		aNfCab[NF_LIVRO,nLF,LF_OUTRIPI] := Max(aNfCab[NF_LIVRO,nLF,LF_OUTRIPI],0)

		//Vinculo do item do livro com o cabecalho
		aNfcab[NF_LIVRO][nLF][LF_IDENT]   := cIdent
		aNfItem[nItem][IT_LIVRO][LF_IDENT]:= cIdent

		//Exclusao dos itens sem valor
		If 	aNfCab[NF_LIVRO][nLF][3]+;
			aNfCab[NF_LIVRO][nLF][4]+;
			aNfCab[NF_LIVRO][nLF][5]+;
			aNfCab[NF_LIVRO][nLF][6]+;
			aNfCab[NF_LIVRO][nLF][7]+;
			aNfCab[NF_LIVRO][nLF][9]+;
			aNfCab[NF_LIVRO][nLF][10]+;
			aNfCab[NF_LIVRO][nLF][11]+;
			aNfCab[NF_LIVRO][nLF][27]+;
			aNfCab[NF_LIVRO][nLF][131] == 0 .And. Empty(aNfCab[NF_LIVRO][nLF][LF_FORMULA])
			aDel(aNfCab[NF_LIVRO],nLF)
			aSize(aNfCab[NF_LIVRO],Len(aNfCab[NF_LIVRO])-1)
		EndIf
	EndIf
Else
	If !(cPaisLoc == "MEX" .And. funname() == "LOJA701") //OPTIMIZA
		lImport := Type("lFacImport") == "L" .And. lFacImport
	EndIf
	aSF4:=SF4->(GetArea())
	aSFB:=SFB->(GetArea())
	aSFC:=SFC->(GetArea())
	If aSFC[2] <> 2	//OPTIMIZA...
		SFC->(DbSetOrder(2))
	EndIf
	If aSFB[2] <> 1
		SFB->(DbSetOrder(1))
	EndIf
	If aSF4[2] <> 1
		SF4->(DbSetOrder(1))
	EndIf
	If !(SF4->(F4_FILIAL+F4_CODIGO) == xFilial("SF4")+aNfItem[nItem][IT_TES])
		SF4->(MsSeek(xFilial("SF4")+aNfItem[nItem][IT_TES]))
	EndIf //...OPTIMIZA
	If cPaisLoc $ "COL|URU|EQU"
		aImpVar:=Array(10)
	Else
		aImpVar:=Array(8)
	EndIf
	aImpVar[1] := aNfItem[nItem][IT_QUANT]
	If aNFCab[NF_OPERNF] == 'E' .Or. aSX6[MV_DESCSAI]=='2'
		If cPaisLoc $ "ARG" .And. aNFCab[NF_OPERNF] == 'S' .And. Alltrim(FunName()) <> "MATA410" .And. (( Type("INCLUI" )=="L" .And. !INCLUI) .Or. ( Type("lVisualiza" )=="L" .And. lVisualiza ))
			aImpVar[2] := aNfItem[nItem][IT_VALMERC] /Max(aNfItem[nItem][IT_QUANT],1)
			aImpVar[3] := aNfItem[nItem][IT_VALMERC]
		Else
			If cPaisLoc == "ARG" .And. aNfCab[NF_CLIFOR]=="C" .And. aSX6[MV_DESCSAI]=='1'
				aImpVar[2] := aNfItem[nItem][IT_PRCUNI]
				aImpVar[3] := aNfItem[nItem][IT_VALMERC]
			ElseIf cPaisLoc == "MEX" .And. Alltrim(FunName()) $ "MATA466N" .And. ( Type("lVisualiza" )=="L" .And. lVisualiza ) .AND. aSX6[MV_DESCSAI]=='2'
				aImpVar[2] := aNfItem[nItem][IT_VALMERC] /Max(aNfItem[nItem][IT_QUANT],1)
				aImpVar[3] := aNfItem[nItem][IT_VALMERC]
			ElseIf cPaisLoc $ "MEX|PER|COL" .And. Alltrim(FunName()) $ "MATA465N" .And. aSX6[MV_DESCSAI]=='1' .And. aNFCab[NF_TIPODOC] == "04"
				aImpVar[2] := aNfItem[nItem][IT_VALMERC] / Max(aNfItem[nItem][IT_QUANT],1)
				aImpVar[3] := aNfItem[nItem][IT_VALMERC]
			Else
				aImpVar[2] := (aNfItem[nItem][IT_VALMERC]-(aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]) )/Max(aNfItem[nItem][IT_QUANT],1)
				aImpVar[3] := aNfItem[nItem][IT_VALMERC]-(aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT])
			EndIf
		EndIF
	Else
		aImpVar[2] := aNfItem[nItem][IT_PRCUNI]
		aImpVar[3] := aNfItem[nItem][IT_VALMERC]
	Endif
	If cPaisLoc $ "MEX|PER"
		aImpVar[3] -= aNfItem[nItem][IT_ADIANT]
	EndIf
	aImpVar[4] := aNfItem[nItem][IT_FRETE]
	aImpVar[5] := aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO] + Iif(cPaisLoc=="PTG",aNfItem[nItem][IT_DESNTRB]+aNfItem[nItem][IT_TARA],0)
	aImpVar[6] := {}
	aImpVar[7] := ""
	If cPaisLoc $ "COL"
		aImpVar[9] := aNfItem[nItem][IT_SEGURO]
	EndIf
	If cPaisLoc $ "URU|EQU|COL|MEX"
		aImpVar[8] := nItem
	Endif

	If cPaisLoc $ "BOL | ARG"
		aImpVar[8] := aNfItem[nItem][IT_CF]
	EndIf
	If cPaisLoc $ "COL"
		aImpVar[10] := aNfItem[nItem][IT_CF]
	EndIf

	If aNfItem[nItem][IT_TES] <> aTes[TS_CODIGO]
		MaFisTes(aNfItem[nItem][IT_TES],aNfItem[nItem][IT_RECNOSF4],nItem)
	EndIf

	For nY := 1 to Len(aTes[TS_SFC])
		If (cPaisLoc <> "ARG".Or. aTes[TS_SFC][nY][SFC_IMPOSTO]<> "DUM") //Ignmorar o DUMMY
			lAchouWN:=.F.
			nImp:=NumCpoImpVar(RIGHT(Alltrim(aTes[TS_SFC][nY][SFB_CPOVREI]),1))
			aadd(aImpVar[6],Array(18))
			nX:=Len(aImpVar[6])
			// No caso abaixo o código do imposto (ISC,IGV,PIV,DIG) é gravado
			// na primeira posição do array aImpVar[6][nX], pois o mesmo é
			// utilizado nas funções de formação dos livros fiscais GetBook,
			// M460LIVR  e M100LIVR.
			// OBS. No caso do não localizado o valor do código do produto é
			// é passado como parâmetro, porém não é utilizado.

			If cPaisLoc $ "PER" .Or. cPaisLoc $ "COL"
				aImpVar[6][nX][1] := aTes[TS_SFC][nY][SFC_IMPOSTO]
			Else
				aImpVar[6][nX][1] :=aNfItem[nItem][IT_PRODUTO]
			EndIf
			aImpVar[6][nX][2] :=aNfItem[nItem][IT_ALIQIMP][nImp]
			aImpVar[6][nX][3] :=aNfItem[nItem][IT_BASEIMP][nImp]
			aImpVar[6][nX][4] :=aNfItem[nItem][IT_VALIMP][nImp]
			If (lImport)
				SD1->(MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+aNfItem[nItem][IT_PRODUTO]))
				If SF1->F1_TIPO_NF$"5678"
					//Solicitação - Average FNC 152032 continuação FNC 147106
					//Se os campos existirem entro para verificar se estão preenchidos e buscar a referencia da TES na tabela SWN
					If lFildPSWN
						SWN->(DbSetOrder(2))
						If SWN->(MsSeek(xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
							While !SWN->(Eof()) .And.;
								(SWN->WN_FILIAL+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA == xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA);
								//Se encontrar a referência do Item e a TES estiver preenchida pego a TES da SWN
								If SWN->WN_PRODUTO+SWN->WN_ITEMNF == SD1->D1_COD+SD1->D1_ITEM .And. !Empty(SWN->WN_TES)
									lAchouWN:=.T.
									SFC->(MsSeek(xFilial("SFC")+SWN->WN_TES+aTes[TS_SFC][nY][SFC_IMPOSTO]))
								EndIf
								SWN->(DbSkip())
							End
							//Senão encontrou deixo a referência que existia antes
							If !lAchouWN
								SYD->(MsSeek(xFilial("SYD")+SD1->D1_TEC))
								SFC->(MsSeek(xFilial("SFC")+SYD->YD_TES+aTes[TS_SFC][nY][SFC_IMPOSTO]))
							EndIf
						EndIf
					Else
						//Senão os campos não existirem deixo a referência que existia antes
						SYD->(MsSeek(xFilial("SYD")+SD1->D1_TEC))
						SFC->(MsSeek(xFilial("SFC")+SYD->YD_TES+aTes[TS_SFC][nY][SFC_IMPOSTO]))
					EndIf
				Else
					If aSX6[MV_DESPSD1]=="S" .And. cPaisLoc == "BRA"
						SFC->(MsSeek(xFilial("SFC")+SD1->D1_TESDES+aTes[TS_SFC][nY][SFC_IMPOSTO]))
					Else
						//Solicitação - Average FNC 152032 continuação FNC 147106
						//Se os campos existirem entro para verificar se estão preenchidos e buscar a referencia da TES na tabela SWN
						If lFildPSWN
							SWN->(DbSetOrder(2))
							If SWN->(MsSeek(xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
								While !SWN->(Eof()) .And.;
									(SWN->WN_FILIAL+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA == xFilial("SWN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA);
									//Se encontrar a referência do Item e a TES estiver preenchida pego a TES da SWN
									If SWN->WN_PRODUTO+SWN->WN_ITEMNF == SD1->D1_COD+SD1->D1_ITEM .And. !Empty(SWN->WN_TES)
										lAchouWN:=.T.
										SFC->(MsSeek(xFilial("SFC")+SWN->WN_TES+aTes[TS_SFC][nY][SFC_IMPOSTO]))
									EndIf
									SWN->(DbSkip())
								End
								//Senão encontrou deixo a referência que existia antes
								If !lAchouWN
									SYD->(MsSeek(xFilial("SYD")+SD1->D1_TEC))
									SFC->(MsSeek(xFilial("SFC")+SYD->YD_TES+aTes[TS_SFC][nY][SFC_IMPOSTO]))
								EndIf
							EndIf
						Else
							//Senão os campos não existirem deixo a referência que existia antes
							SYD->(MsSeek(xFilial("SYD")+SD1->D1_TEC))
							SFC->(MsSeek(xFilial("SFC")+SYD->YD_TES+aTes[TS_SFC][nY][SFC_IMPOSTO]))
						EndIf
					Endif
				Endif
				SFB->(MsSeek(xFilial("SFB")+aTes[TS_SFC][nY][SFC_IMPOSTO]))
				cAux:=SFC->FC_INCDUPL+SFC->FC_INCNOTA+SFC->FC_CREDITA
				If IsAlpha(SFC->FC_INCDUPL)
					aImpVar[6][nX][5]:=IIf(Subs(cAux,1,2)=="SN".Or.Subs(cAux,1,2)=="NS","3",;
					IIf(Subs(cAux,1,2)=="SS","1","2"))
					aImpVar[6][nX][5]+=IIf(Subs(cAux,2,1)=="S" ,"1",IIf(Subs(cAux,2,1)=="R" ,"2","3"))
					aImpVar[6][nX][5]+=IIf(Subs(cAux,2,2)=="SN","1",IIf(Subs(cAux,2,2)=="NS","2","3"))
				Else
					aImpVar[6][nX][5]:=cAux
				EndIf
				If cPaisLoc == "PER" .And. nCpoIPM == Val(SFB->FB_CPOLVRO) 
					lIncIPM := .F.
				EndIf
				aImpVar[6][nX][17]:=SFB->FB_CPOLVRO
			Else
				aImpVar[6][nX][5]:=	aTes[TS_SFC][nY][SFC_INCDUPL]+	aTes[TS_SFC][nY][SFC_INCNOTA]+	aTes[TS_SFC][nY][SFC_CREDITA]
				If cPaisLoc == "PER" .And. nCpoIPM == Val(Right(aTes[TS_SFC][nY][SFB_CPOVREI],1)) 
					lIncIPM := .F.
				EndIf
				aImpVar[6][nX][17]:=Right(aTes[TS_SFC][nY][SFB_CPOVREI],1)
				aImpVar[6][nX][18]:= aTes[TS_SFC][nY][SFB_DESGR]
			Endif
		Endif
	Next nY
	If !(cPaisLoc == "MEX" .And. funname() == "LOJA701") //OPTIMIZA
		If Type('dDEmissao') == "D" .And. !Empty(dDEmissao)
			dDataEmi	:=	dDEmissao
		Endif
	Endif
	//          TRATAMENTO EXPECIFICO PARA LOCALIZADO PERU
	// Quando o TES for referente ao imposto do IGV, o valor do IPM, o
	// qual é uma porcentagem do IGV,o valor da base, aliquota e valor do
	// imposto é gravado nos campos _BASIMP3, _ALQIMP3 e VALIMP3.
	// O valor da base é a mesma utilizada para o cálculo do IGV.
	// O valor da alíqutoa é proveniente de um paramêtro chamado
	// MV_ALQIPM.
	// O valor do imposto é a multiplicação da base pelo valor da aliquota
	// NO CASO ABAIXO FOI INCLUIDA UMA CONDIçãO PARA O FLUXO POSSIBILITAR
	// QUE O VALOR DOS CAMPOS _BASIMP3, _ALQIMP3 E _VALIMP3 SEJAM PREENCHI-
	// DOS.
	
	If cPaisLoc == "PER" .And. lIncIPM .And. nCpoIPM > 0 .And. ValType(aNfItem[nItem][IT_ALIQIMP][nCpoIPM]) == "N"
		alAreaX := GetArea()
			aadd(aImpVar[6],Array(17))
			nX:=Len(aImpVar[6])
			aImpVar[6][nX][1] := "IGV"
			aImpVar[6][nX][2] :=aNfItem[nItem][IT_ALIQIMP][nCpoIPM]
			aImpVar[6][nX][3] :=aNfItem[nItem][IT_BASEIMP][nCpoIPM]
			aImpVar[6][nX][4] :=aNfItem[nItem][IT_VALIMP][nCpoIPM]

			aImpVar[6][nX][5] := "333"
			aImpVar[6][nX][17]:= Alltrim(Str(nCpoIPM))
		RestArea(alAreaX)
	EndIf

	
	//OPTIMIZA
	If cPaisLoc == "MEX" .And. funname() == "LOJA701"
		nTasaMoneda := nTXMoeda
	Else
		nTasaMoneda := If(Type("nTaxa")=="N",nTaxa,If(Type("nTXMoeda")=="N",nTXMoeda,1))
	Endif

	aNfCab[NF_LIVRO]:=GetBook(@aGetBook,aImpVar,If(aNfCab[NF_CLIFOR]=="C","V","C"),nTasaMoneda,aNfCab[NF_LIVRO],aNfCab[NF_OPERNF],lSoma,,,,,,dDataEmi) //OPTIMIZA
	RestArea(aSF4)
	RestArea(aSFB)
	RestArea(aSFC)
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} QryCdVlDec()
Função que fará query na tabela de Itens x Cod.Val.Declaratorios,
buscando as regras considerando os grupos.
O retorno desta função será o alias com o resultado da query.

@param nItem   - Código do produto informado no item da nota fiscal
@param aNfItem - Array com as infomracoes do item da nota fiscal
@param aNfCab  - Array com as infomracoes do cabecalho da nota fiscal
@param aPos    - Array com as infomracoes do FieldPos
@param aSX6    - Array com o cacheamento dos parâmetros SX6

@return   cAlias  - Alias da query processada

@author Renato Rezende
@since 30/10/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function QryCdVlDec(nItem, aNfItem, aNfCab, aPos, aSX6, aPE, cProduto, cCfop, cCST)
Local cSelect	:= ""
Local cFrom	    := ""
Local cWhere	:= ""
Local cAliasQry	:= ""
Local cGrpTrbPd	:= aNFItem[nItem,IT_GRPTRIB]
Local cGrpCliFor:= aNFCab[NF_GRPCLI]
Local cCliFor	:= aNfCab[NF_CLIFOR]
Local lGrupos	:= aNfCab[NF_CODDECL] == "2"
Local cWherePe  := ""

Local aInsert 		:= {}
Local nLen 			:= 0 
Local nPosPrepared	:= 0 
Local cMD5 			:= "" 
Local nX			:= 0

Default cProduto:= aNfItem[nItem][IT_PRODUTO]
Default cCfop	:= aNfItem[nItem][IT_CF]
Default cCST	:= SubStr(aNfItem[nItem][IT_CLASFIS],2,2)

//aNfCab[NF_CODDECL] == "2" é a validacao para o novo tratamento da rotina FISA140

//Guarda as referências para nao executar a query caso nenhum campo chave tenha cido alterados
aNfItem[nItem][IT_CDDECL_AJU][CD_PRODUTO]	:= cProduto
aNfItem[nItem][IT_CDDECL_AJU][CD_CFOP]		:= cCfop
aNfItem[nItem][IT_CDDECL_AJU][CD_CST]	 	:= aNfItem[nItem][IT_CLASFIS]
aNfItem[nItem][IT_CDDECL_AJU][CD_CODCLIFOR] := aNfCab[NF_CODCLIFOR]
aNfItem[nItem][IT_CDDECL_AJU][CD_CLIFOR]	:= cCliFor

If aPE[PE_MAVLDCQry]
	//Secao do Select
	cSelect += "F3K.F3K_FILIAL, F3K.F3K_PROD, F3K.F3K_CFOP, F3K.F3K_CST, F3K.F3K_CODAJU, F3K.F3K_CODREF "

	If lGrupos
		cSelect += ",F3K.F3K_GRCLAN, F3K.F3K_GRFLAN, F3K.F3K_GRPLAN, F3K.F3K_IFCOMP, F3K.F3K_CODLAN "
		cSelect += ",CC6.CC6_CODLAN, CC6.CC6_DESCR, CC6.CC6_STUF, CC6.CC6_TPAPUR "
	EndIf

	cSelect += ",CDY.CDY_CODAJU, CDY.CDY_DESCR "

	//Secao do From
	cFrom += RetSQLName("F3K") + " F3K "

	//Coloquei LEFT porque pode ter registro vencido na CDY
	cFrom += "LEFT OUTER JOIN " + RetSQLName("CDY") + " CDY ON CDY.CDY_FILIAL = " + ValToSQL(xFilial("CDY")) + " AND CDY.CDY_CODAJU = F3K.F3K_CODAJU AND CDY.D_E_L_E_T_ = ' ' "

	If lGrupos
		//Coloquei LEFT porque nem todo registro do F3K_CODLAN estará preenchido podendo retornar a descricao em branca
		cFrom += "LEFT OUTER JOIN " + RetSQLName("CC6") + " CC6 ON CC6.CC6_FILIAL = " + ValToSQL(xFilial("CC6")) + " AND CC6.CC6_CODLAN = F3K.F3K_CODLAN AND CC6.D_E_L_E_T_ = ' ' "
		//Somente serao considerados lançamentos da UF do contribuinte
		//Caso o lançamento nao seja de Apuração Propria, o lançamento podera ser de qualquer UF
		cFrom += "AND (CC6.CC6_STUF = " + ValToSQL(aSX6[MV_ESTADO]) + " OR CC6.CC6_TPAPUR <> '0') "
	EndIf

	//Secao do Where
	cWhere += "F3K.F3K_FILIAL = " + ValToSQL( xFilial("F3K") ) + " "
	cWhere += "AND F3K.D_E_L_E_T_ = ' ' "

	If lGrupos
		cWhere += "AND (F3K.F3K_PROD = " + ValToSQL(cProduto) + " OR F3K.F3K_PROD = ' ' ) "
	Else
		cWhere += "AND (F3K.F3K_PROD = " + ValToSQL(cProduto) + " ) "
	EndIf

	cWhere += "AND F3K.F3K_CFOP= " + ValToSQL(cCfop) + " AND F3K.F3K_CST= " + ValToSQL(cCST) + " "
	cWhere += "AND SUBSTRING(F3K.F3K_CODAJU ,1,2) = " + ValToSQL(aSX6[MV_ESTADO]) + " "

	If lGrupos
		//Grupo de produto
		cWhere += " AND F3K.F3K_GRPLAN = " + ValToSQL(cGrpTrbPd) + " "

		//Grupo de Clientes ou Fornecedor
		If !Empty(cGrpCliFor)
			//Cliente
			If cCliFor == "C"
				cWhere += "AND F3K.F3K_GRCLAN = " + ValToSQL(cGrpCliFor) + " "
			//Fornecedor
			ElseIf cCliFor == "F"
				cWhere += "AND F3K.F3K_GRFLAN = " + ValToSQL(cGrpCliFor) + " "
			EndIf
		Else
			cWhere +=	"AND F3K.F3K_GRCLAN = " + ValToSQL(cGrpCliFor) + " AND F3K.F3K_GRFLAN = " + ValToSQL(cGrpCliFor) + " "
		EndIf
	EndIf

	//No fonte FISXAPURA tem validação de fieldpos nesses campos
	If aPos[FP_CDY_DTINI] .And. aPos[FP_CDY_DTFIM]
		cWhere += "AND CDY.CDY_DTINI <> ' ' AND CDY.CDY_DTINI <= " + ValToSql(dDataBase) + " AND (CDY.CDY_DTFIM >= " + ValToSql(dDataBase) + " OR CDY.CDY_DTFIM = ' ') "
	EndIf

	If aPE[PE_MAVLDCQry]
		cWherePe := ExecBlock("MAVLDCQry",.F.,.F.,{cWhere,cCST,cCfop,cProduto,cGrpTrbPd,cGrpCliFor,cCliFor})
		If !Empty(cWherePe)
			cWhere := cWherePe
		EndIf

	Endif

	//Concatenará o % e executará a query.
	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"

	cAliasQry := GetNextAlias()

	BeginSQL Alias cAliasQry

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
	EndSQL
Else
	//Secao do Select
	aInsert := {}

	cSelect += "F3K.F3K_FILIAL, F3K.F3K_PROD, F3K.F3K_CFOP, F3K.F3K_CST, F3K.F3K_CODAJU, F3K.F3K_CODREF, F3K.F3K_IFCOMP, F3K.F3K_CODLAN "

	If lGrupos
		cSelect += ",F3K.F3K_GRCLAN, F3K.F3K_GRFLAN, F3K.F3K_GRPLAN, F3K.F3K_IFCOMP, F3K.F3K_CODLAN "
		cSelect += ",CC6.CC6_CODLAN, CC6.CC6_DESCR, CC6.CC6_STUF, CC6.CC6_TPAPUR "
	EndIf

	cSelect += ",CDY.CDY_CODAJU, CDY.CDY_DESCR "

	//Secao do From
	cFrom += RetSqlName("F3K") + " F3K "

	//Coloquei LEFT porque pode ter registro vencido na CDY
	cFrom += " LEFT OUTER JOIN " + RetSQLName("CDY") + " "

	Aadd(aInsert,cValToChar(xFilial("CDY")))
	cFrom += " CDY ON CDY.CDY_FILIAL = ? "

	cFrom += " AND CDY.CDY_CODAJU = F3K.F3K_CODAJU AND CDY.D_E_L_E_T_ = ' ' "

	If lGrupos
		//Coloquei LEFT porque nem todo registro do F3K_CODLAN estará preenchido podendo retornar a descricao em branca
		cFrom += "LEFT OUTER JOIN " + RetSQLName("CC6") + " "

		Aadd(aInsert,cValToChar(xFilial("CC6")))
		cFrom += " CC6 ON CC6.CC6_FILIAL = ? "
		cFrom += " AND CC6.CC6_CODLAN = F3K.F3K_CODLAN AND CC6.D_E_L_E_T_ = ' ' "
		//Somente serao considerados lançamentos da UF do contribuinte
		//Caso o lançamento nao seja de Apuração Propria, o lançamento podera ser de qualquer UF
		Aadd(aInsert,cValToChar(aSX6[MV_ESTADO]))
		cFrom += "AND (CC6.CC6_STUF = ? "
		cFrom += " OR CC6.CC6_TPAPUR <> '0') "
	EndIf

	//Secao do Where
	Aadd(aInsert,cValToChar(xFilial("F3K")))
	cWhere += "F3K.F3K_FILIAL = ? "
	cWhere += "AND F3K.D_E_L_E_T_ = ' ' "

	If lGrupos
		Aadd(aInsert,cValToChar(cProduto))
		cWhere += "AND (F3K.F3K_PROD = ? OR F3K.F3K_PROD = ' ' ) "
	Else
		Aadd(aInsert,cValToChar(cProduto))
		cWhere += "AND (F3K.F3K_PROD = ? ) "
	EndIf

	Aadd(aInsert,cValToChar(cCfop))
	cWhere += " AND F3K.F3K_CFOP= ? "

	Aadd(aInsert,cValToChar(cCST))
	cWhere += "AND F3K.F3K_CST= ? "

	Aadd(aInsert,cValToChar(aSX6[MV_ESTADO]))
	cWhere += "AND SUBSTRING(F3K.F3K_CODAJU ,1,2) = ? "

	If lGrupos
		//Grupo de produto
		Aadd(aInsert,cValToChar(cGrpTrbPd))
		cWhere += " AND F3K.F3K_GRPLAN = ? "

		//Grupo de Clientes ou Fornecedor
		If !Empty(cGrpCliFor)
			//Cliente
			If cCliFor == "C"
				Aadd(aInsert,cValToChar(cGrpCliFor))
				cWhere += "AND F3K.F3K_GRCLAN = ? "
			//Fornecedor
			ElseIf cCliFor == "F"
				Aadd(aInsert,cValToChar(cGrpCliFor))
				cWhere += "AND F3K.F3K_GRFLAN = ? "
			EndIf
		Else
			Aadd(aInsert,cValToChar(cGrpCliFor))
			Aadd(aInsert,cValToChar(cGrpCliFor))
			cWhere +=	"AND F3K.F3K_GRCLAN = ? AND F3K.F3K_GRFLAN = ? "
		EndIf
	EndIf

	//No fonte FISXAPURA tem validação de fieldpos nesses campos
	If aPos[FP_CDY_DTINI] .And. aPos[FP_CDY_DTFIM]
		Aadd(aInsert,cValToChar(DTOS(dDataBase)))
		cWhere += "AND CDY.CDY_DTINI <> ' ' AND CDY.CDY_DTINI <= ? "

		Aadd(aInsert,cValToChar(DTOS(dDataBase)))
		cWhere += " AND (CDY.CDY_DTFIM >= ? OR CDY.CDY_DTFIM = ' ') "
	EndIf

	cQuery := " SELECT " + cSelect + " FROM " + cFrom + " WHERE " + cWhere
	nLen := Len(aInsert)
	cMD5 := MD5(cQuery)
	If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0 
		Aadd(__aPrepared,{FWPreparedStatement():New(),cMD5})
		nPosPrepared := Len(__aPrepared)
		__aPrepared[nPosPrepared][1]:SetQuery(ChangeQuery(cQuery))
	EndIf 
	For nX := 1 to nLen
		__aPrepared[nPosPrepared][1]:SetString(nX,aInsert[nX])
	Next 
	cQuery := __aPrepared[nPosPrepared][1]:getFixQuery()

	aInsert := aSize(aInsert,0)

	cAliasQry := GetNextAlias()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
EndIf

Return cAliasQry

//-----------------------------------------------------------------
/*/{Protheus.doc} STamMxFis

Encapsula chamada da TamSX3 para MATXFIS/IMPXFIS e fontes derivados, alimentando a variável STATIC aTamSx3.

@author leandro.faggyas
@since 19/05/2020
@version 1.0
/*/
//----------------------------------------------------------------
Function STamMxFis( aPos )
Local aRet := {}
Local aCpo := {}
Local aTam := {}
Local nX   := 0

Default aPos := {}

If Len(aPos) > 0

	aCpo := {;
			  "F3K_PROD"   ,; //01
			  "F3K_CFOP"   ,; //02	
			  "F3K_CST"    ,; //03
			  "F7_GRTRIB"  ,; //04
			  "F7_GRPCLI"  ,; //05
			  "S1_GRTRIB"  ,; //06
			  "F3_CLIEFOR" ,; //07
			  "F3_LOJA"    ,; //08
			  "F22_CLIFOR" ,; //09
			  "F22_LOJA"   ,; //10
			  "F13_FIMVIG" ,; //11
			  "D1_OPER"    ,; //12
			  "B1_TRIBMUN" ,; //13
			  "E2_FORNISS" ,; //14
			  "E2_LOJAISS" ,; //15
			  "E2_CODRET"  ,; //16
			  "B1_VLR_PIS" ,; //17
			  "B1_PPIS"    ,; //18
			  "D1_ITEM"    ,; //19
			  "CE1_TRIBMU" ,; //20
			  "CDA_NUMITE" ,; //21
			  "CDV_NUMITE" ,; //22
			  "D2_ITEM"    ,; //23
			  "F3_OBSERV"  ,; //24
			  "FT_OBSERV"  ,; //25
			  "A1_CGC"     ,; //26
			  "F3_NFISCAL" ,; //27
			  "CD2_ITEM"   ,; //28
			  "CD2_IMP"    ,; //29
			  "CFC_CODPRD" ,; //30
			  "CC8_CODIGO" ,; //31
			  "CC7_CODLAN" ,; //32
			  "CE1_FORISS" ,; //33
			  "CE1_LOJISS" ,; //34
			  "CE1_MUNISS"  ; //35
			  }

	For nX := 1 To Len(aCpo)
		aTam := TamSX3(aCpo[nX])
		If ValType(aTam) == "A" .And. Len(aTam) > 0
			aAdd(aRet,aTam[1])
		Else
			aAdd(aRet,0)
		EndIf
	Next nX

EndIf

Return aRet

/*/
xFisEnd - Matheus Massarotto   - 27/08/2020
Destroi objetos, arrays e etc usados na impxfis.
/*/
Function xFisEnd

IF Valtype(oHItemRef) =='O'
	FreeObj(oHItemRef)
	oHItemRef 	:= Nil
ENDIF

IF Valtype(oHCabRef) =='O'
	FreeObj(oHCabRef)
	oHCabRef	:= Nil
ENDIF
IF Valtype(oHResRef) =='O'
	FreeObj(oHResRef)
	oHResRef	:= Nil
ENDIF
IF Valtype(oHTGITRef) =='O'
	FreeObj(oHTGITRef)
	oHTGITRef	:= Nil
ENDIF
IF Valtype(oHTGNFRef) =='O'
	FreeObj(oHTGNFRef)
	oHTGNFRef	:= Nil
ENDIF
IF Valtype(oHLFIS) =='O'
	FreeObj(oHLFIS)
 	oHLFIS		:= Nil
ENDIF
IF Valtype(oTGLFRef) =='O'
	FreeObj(oTGLFRef)
	oTGLFRef	:= Nil
ENDIF
if Valtype(oHMCad)=="O" 
	FISXDFIH(oHMCad)
endif

FWFreeArray(aWriteSFT)

Return

/*/{Proteus.doc} RetLFLeg
	Retorna o DE/PARA da INCIDE da escrituração do configurador para o Livro fiscal da TES 
	@type  Function
	@author Erich Buttner
	@since 24/11/2020
	@version version
	@param 
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	nPosTrb -> Posição do tributo no array de escrituração do Configurador
	nRefer -> numero da referencia do livro dos tributos	
	@return cIncide
	/*/
Function RetLFLeg(aNfItem,nItem,nPosTrb,nRefer)

Local cConv := aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_REGRA_ESCR][RE_INCIDE]
Local lRed	:= !(Empty(aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_REGRA_ESCR][RE_INC_PARC_RED]))

//Verifica se tem redução para trocar o livro
If lRed
	cConv:= aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_REGRA_ESCR][RE_INC_PARC_RED]
EndIf

If cConv == "1" .And. !lRed //Livro Tributado
	cIncide := "T"
ElseIf (cConv == "2" .And. !lRed) .Or. (lRed .And. cConv == "1") // Livro Isento
	cIncide := "I"
ElseIf (cConv == "3".And. !lRed) .Or. (lRed .And. cConv == "2")// Livro Outros
	cIncide := "O"
Else
	cIncide := aNFItem[nItem][IT_TS][nRefer]
EndIf

Return cIncide

