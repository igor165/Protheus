#Include "Protheus.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³NFEVRSIM	  ³ Autor ³ Diego Dias Godas  	³ Data ³ 11.07.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Nota Fiscal Eletronica - Volta Redonda - Rio de Janeiro     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function NFEVRSIM(dDataIni,dDataFin,aFiltro)
Local aArea		:=  GetArea()
Local aTRB 		:= {}
Local aTRBIT		:= {}
Local cArq			:= ""
Local cChave		:= ""
Local cAlias		:= ""
Local nValServ	:= 0
Local nValImp 	:= 0
Local nValTot		:= 0
Local nValCof		:= 0
Local nValPis		:= 0
Local nValIr		:= 0
Local nValInss	:= 0
Local nValCsll	:= 0
Local nAliqIss	:= 0
Local nBaseIss	:= 0
Local nRelac		:= 0
Local nValDed		:= 0
Local cWhere		:= ''
Default aFiltro	:={}

DbSelectArea("SM0")
SM0->(DbGoTop ())
SM0->(MsSeek(cEmpAnt + cFilAnt))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TRB - Registro Tipo 1 - Corpo do Arquivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aTRB,{"IDENTIF",   	 	'C',01,0}) //1-Número correspondente ao conteúdo da nota
aadd(aTRB,{"LOTERPS",    	'C',15,0}) //2-Número do lote enviado que deverá ser sequencial e único. Deverá ser iniciado no número 1 e continuar essa sequência nos demais arquivos enviados posteriormente. Cada arquivo deverá ser composto por um único lote
aadd(aTRB,{"CPFCNPJ",   		'C',14,0}) //3-CPF/CNPJ do Prestador
aadd(aTRB,{"INSCRMUNIC",		'C',15,0}) //4-Inscrição Municipal do Prestador
aadd(aTRB,{"CODMUNPRES",		'C',07,0}) //5-Código do município do Prestador conforme a tabela do IBGE
aadd(aTRB,{"NUMRPS", 		'C',09,0}) //6-Numero do Rec. Prov. de Serviço
aadd(aTRB,{"SERIE", 			'C',05,0}) //7-Série do RPS
aadd(aTRB,{"DTEMISSAO",		'C',10,0}) //8-Data de Emissão do Recibo Provisório de Serviço
aadd(aTRB,{"CODNATOPE",		'C',01,0}) //9-Código da Natureza da Operação
aadd(aTRB,{"CODREGESP",		'C',02,0}) //10-Código de identificação do Regime Especial de Tributação que descreve o tipo em que se enquadra o contribuinte.
aadd(aTRB,{"SIMPNAC",		'C',01,0}) //11-Optante pelo Simples Nacional
aadd(aTRB,{"STATUSRPS",		'C',01,0}) //12-Status do RPS
aadd(aTRB,{"CODESPATVF",  	'C',10,0}) //13-Código de especificação da Atividade Federal
aadd(aTRB,{"CODESPATVM",   	'C',20,0}) //14-Código de especificação da Atividade Municipal
aadd(aTRB,{"CNAE",   		'C',07,0}) //15-Código CNAE. Use apenas números nesse campo.
aadd(aTRB,{"DESCRSERV",		'C',200,0})//16-Descrição do Serviço
aadd(aTRB,{"VALSERVICO", 	'C',18,2}) //17-Valor do Serviço Prestado
aadd(aTRB,{"VLDEDUCO", 		'C',18,2}) //18-Valor das Deduções
aadd(aTRB,{"VALPIS", 		'C',18,2}) //19-Valor PIS
aadd(aTRB,{"VALCOF",        'C',18,2}) //20-Valor COFINS
aadd(aTRB,{"VALINSS", 		'C',18,2}) //21-Valor INSS
aadd(aTRB,{"VALIR", 			'C',18,2}) //22-Valor IR
aadd(aTRB,{"VALCSLL", 		'C',18,2}) //23-Valor CSLL
aadd(aTRB,{"ISSRETIDO", 		'C',01,0}) //24-Indicador de ISS Retido 1 - SIM; 2 – NÃO
aadd(aTRB,{"VALISS", 		'C',18,2}) //25-Valor do ISS
aadd(aTRB,{"VALISSRET", 		'C',18,2}) //26-Valor do ISS Retido
aadd(aTRB,{"VLOUTRRET", 		'C',18,2}) //27-Valor de outras retenções
aadd(aTRB,{"VLBASECALC",		'C',18,2}) //28-Valor da base de cálculo
aadd(aTRB,{"ALIQUOTA", 		'C',05,0}) //29-Alíquota
aadd(aTRB,{"VALLIQNFS", 		'C',18,2}) //30-Valor líquido da Nota Fiscal
aadd(aTRB,{"VLDESCINC", 		'C',18,2}) //31-Valor de desconto incondicionado
aadd(aTRB,{"VLDESCCON", 		'C',18,2}) //32-Valor de desconto condicionado
aadd(aTRB,{"TOMTIPOCGC",		'C',01,0}) //33-Tipo do CPF/CNPJ do Tomador do Serviço
aadd(aTRB,{"TOMCGC", 		'C',14,0}) //34-CPF/CNPJ do Tomador do Serviço
aadd(aTRB,{"TOMINSCMUN",		'C',15,0}) //35-Inscrição Municipal do Tomador do Serviço
aadd(aTRB,{"TOMRSOCIAL",		'C',120,0})//36-Razão Social do Tomador do Serviço
aadd(aTRB,{"TOMENDEREC",   	'C',130,0})//37-Endereço do Tomador do Serviço
aadd(aTRB,{"TOMNUMERO",   	'C',010,0})//38-Número do endereço do Tomador do Serviço
aadd(aTRB,{"TOMCOMPEND",   	'C',060,0})//39-Complemento do endereço do Tomador do Serviço
aadd(aTRB,{"TOMBAIRRO", 		'C',60,0}) //40-Bairro do endereço do Tomador do Serviço
aadd(aTRB,{"TOMESTADO",		'C',02,0}) //41-Estado do endereço do Tomador do Serviço
aadd(aTRB,{"TOMCEP", 		'C',08,0}) //42-CEP do endereço do Tomador do Serviço
aadd(aTRB,{"TOMCODMUN", 		'C',07,0}) //43-Código do município do Tomador do Serviço conforme a tabela do IBGE
aadd(aTRB,{"TOMADORTEL",		'C',15,0}) //44-Telefone do Tomador do Serviço
aadd(aTRB,{"TOMEMAIL", 		'C',100,0})//45-E-mail do Tomador do Serviço
aadd(aTRB,{"INTRSOCIAL",		'C',120,0})//46-Razão Social do Intermediário do Serviço
aadd(aTRB,{"INTCGC",			'C',14,0}) //47-CPF/CNPJ do Intermediário do Serviço
aadd(aTRB,{"INTTIPOCGC",		'C',01,0}) //48-Tipo do CPF/CNPJ do Intermediário do Serviço
aadd(aTRB,{"INTINSCMUN",		'C',15,0}) //49-Inscrição Municipal do Intermediário do Serviço
aadd(aTRB,{"CODOBRA",		'C',15,0}) //50-Código Obra Construção Civil
aadd(aTRB,{"CODARTCONS",		'C',15,0}) //51-Código Art Construção Civil
aadd(aTRB,{"NUMRPSSUBS",		'C',08,0}) //52-Número do RPS substituta. Indica o número do RPS que está substituindo o anterior.
aadd(aTRB,{"SERIESUBS",		'C',05,0}) //53-Série do RPS substituta
aadd(aTRB,{"MUNTRIBISS",		'C',07,0}) //54-Código do município conforme a tabela do IBGE. Município onde o imposto será tributado
aadd(aTRB,{"UFTRIBISS", 		'C',02,0}) //55-Estado do município onde o imposto será tributado
aadd(aTRB,{"OUTRASINF", 		'C',255,0})//56-Informações adicionais ao documento
aadd(aTRB,{"TOMINSCEST",		'C',20,0}) //57-Inscrição Estadual do Tomador do Serviço
aadd(aTRB,{"SEQUENCIA",		'N',03,0}) //-Identificador da TRB para fazer o relacionamento com a tabela TRI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria tabela temporaria e indice que será³
//³no registro tipo 1 - Corpo do Arquivo   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArq := CriaTrab(aTRB,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.,.F.)
IndRegua("TRB",cArq,"SEQUENCIA")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TRI - Registro Tipo 2 - Lista de itens  ³ 
//³de serviço									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aTRBIT,{"IDENTIF",		'C',01,0}) //1-Identifica a lista de serviço
aadd(aTRBIT,{"ITDESCR",     'C',100,0})//2-Descrição do item de serviço
aadd(aTRBIT,{"ITQUANT",		'C',10,5}) //3-Item
aadd(aTRBIT,{"ITVUNIT",		'C',18,2}) //4-Valor de cada unidade
aadd(aTRBIT,{"ITISSTRIB",	'C',01,0}) //5-Incidência de recolhimento de ISS. Somente poderão declarar esse campo como "Não" tributável os contribuintes que possuam autorização prévia do município para essa operação.
aadd(aTRBIT,{"SEQUENCIA",	'N',03,0}) //-Identificador da TRI para fazer o relacionamento com a tabela TRB

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria tabela temporaria e indice que será³
//³no registro tipo 2 - Lista de itens de  ³
//³serviço										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArq := CriaTrab(aTRBIT,.T.)
dbUseArea(.T.,,cArq,"TRI",.T.,.F.)
IndRegua("TRI",cArq,"SEQUENCIA")
          
cWhere := "SFT.FT_FILIAL='"+xFilial("SFT")+"'AND "
cwhere += "SFT.FT_EMISSAO>='"+DTOS(DDATAINI)+"'AND "
cwhere += "SFT.FT_EMISSAO<='"+DTOS(DDATAFIN)+"'AND "
cwhere += "SFT.FT_CODISS<>' 'AND "
cwhere += "SFT.FT_ESPECIE = 'RPS'AND "
If !Empty(aFiltro) 
	If !Empty(aFiltro[2][3]) 
		cWhere += "SFT.FT_CLIEFOR>='"+Alltrim(aFiltro[2][1])+"'AND "
		cWhere += "SFT.FT_CLIEFOR<='"+Alltrim(aFiltro[2][3])+"'AND "
	Endif
	If !Empty(aFiltro[2][4])
		cWhere += "SFT.FT_LOJA>='"+Alltrim(aFiltro[2][2])+"'AND "
		cWhere += "SFT.FT_LOJA<='"+Alltrim(aFiltro[2][4])+"'AND "
	Endif
	If !Empty(aFiltro[2][6])
		cWhere += "SFT.FT_NFISCAL>='"+Alltrim(aFiltro[2][5])+"'AND "
		cWhere += "SFT.FT_NFISCAL<='"+Alltrim(aFiltro[2][6])+"'AND "
	Endif
	If !Empty(aFiltro[2][8])
		cWhere += "SFT.FT_SERIE>='"+Alltrim(aFiltro[2][7])+"'AND "
		cWhere += "SFT.FT_SERIE<='"+Alltrim(aFiltro[2][8])+"'AND "
	Endif
Endif		
cWhere += "SFT.D_E_L_E_T_=' '"
cWhere	:= '%'+cWhere+'%'

Do While !SM0->(Eof()) .And. cEmpAnt==SM0->M0_CODIGO .And. 	cFilAnt == FWCodFil()
	If SuperGetMv("MV_ESTADO",,.F.) == "RJ"		
		cAlias	:=	GetNextAlias()			      
		BeginSql Alias cAlias
		   	
		COLUMN FT_EMISSAO AS DATE
		COLUMN FT_DTCANC AS DATE
								
		SELECT	SFT.FT_NFISCAL,
	   	SFT.FT_SERIE,
	   	SFT.FT_EMISSAO,
	   	SFT.FT_ISSST,
	   	SA1.A1_SIMPNAC,
	   	SFT.FT_DTCANC,
	   	SFT.FT_CODISS,
	   	SA1.A1_CNAE,
	   	SA1.A1_RECISS,
	   	SA1.A1_EST,
	   	SA1.A1_CGC,
	   	SA1.A1_PESSOA,
	   	SA1.A1_INSCRM,
	   	SA1.A1_NOME,
	   	SA1.A1_END,
	   	SA1.A1_BAIRRO,
	   	SA1.A1_CEP,	   	
	   	SA1.A1_COD_MUN,
	   	SA1.A1_TEL,
	   	SA1.A1_EMAIL,
	   	SFT.FT_ISSST,
	   	SA1.A1_INSCR,
	   	SB1.B1_DESC,	
	   	SFT.FT_QUANT,
	   	SFT.FT_PRCUNIT,
	   	SFT.FT_CSTISS,
       SFT.FT_VALCONT,
       SFT.FT_VALICM,
       SFT.FT_TOTAL,
       SFT.FT_VRETCOF,
       SFT.FT_VRETPIS,
       SFT.FT_VALIRR,
       SFT.FT_VALINS,
       SFT.FT_VRETCSL,
       SFT.FT_ALIQICM,
       SFT.FT_BASEICM,
       SFT.FT_ISSSUB,
       SFT.FT_DESCONT				
		FROM
		%TABLE:SFT% SFT
		INNER JOIN %TABLE:SB1% SB1
		ON(SB1.B1_FILIAL=%XFILIAL:SB1%
		AND SFT.FT_PRODUTO = SB1.B1_COD
		AND SB1.%NOTDEL%)		
		INNER JOIN %TABLE:SA1% SA1
		ON(SA1.A1_FILIAL=%XFILIAL:SA1%
		AND SA1.A1_COD = SFT.FT_CLIEFOR
		AND SA1.A1_LOJA = SFT.FT_LOJA
		AND SA1.%NOTDEL%)				
		WHERE%Exp:cWhere%		
		ORDER BY SFT.FT_EMISSAO, SFT.FT_NFISCAL
		EndSql
			
		DbSelectArea (cAlias)
		(cAlias)->(DbGoTop())
			
		While (cAlias)->(!EOF())
			nRelac++				
			//-- Prestador de Serviços - Corpo do Arquivo		
			RecLock("TRB",.T.)
			TRB->SEQUENCIA	:=	nRelac
			TRB->NUMRPS		:=	Alltrim((cAlias)->FT_NFISCAL)
			TRB->SERIE			:=	Alltrim((cAlias)->FT_SERIE)
			TRB->DTEMISSAO 	:=	Transform(DTOS((cAlias)->FT_EMISSAO), "@R 9999-99-99")
			TRB->CODNATOPE	:=	Iif ((cAlias)->FT_ISSST$"6","6",Iif((cAlias)->FT_ISSST$"2","2",Iif((cAlias)->FT_ISSST$"3","3",Iif((cAlias)->FT_ISSST$"4","4",Iif((cAlias)->FT_ISSST$"5","5","1")))))
			TRB->SIMPNAC		:=	Iif(Alltrim((cAlias)->A1_SIMPNAC)=="1","1","2")
			TRB->STATUSRPS	:=	Iif(!Empty((cAlias)->FT_DTCANC), "2", "1")
			
			If	Len(Alltrim((cAlias)->FT_CODISS)) == 3
				TRB->CODESPATVF	:=	Substr(Alltrim((cAlias)->FT_CODISS), 1,1) + '.' + Substr(Alltrim((cAlias)->FT_CODISS), 2,2)
				TRB->CODESPATVM	:=	TRB->CODESPATVF
			ElseIf	Len(Alltrim((cAlias)->FT_CODISS)) == 4
				TRB->CODESPATVF	:=	Substr(Alltrim((cAlias)->FT_CODISS), 1,2) + '.' + Substr(Alltrim((cAlias)->FT_CODISS), 3,2)
				TRB->CODESPATVM	:=	TRB->CODESPATVF
			Else
				TRB->CODESPATVF	:=	AllTrim((cAlias)->FT_CODISS)
				TRB->CODESPATVM	:=	AllTrim((cAlias)->FT_CODISS)
			EndIf
			
			TRB->CNAE	:=	 StrTran( StrTran( AllTrim(SM0->M0_CNAE), "-", "" ), "/", "" )			
			If	SX5->(MsSeek(xFilial("SX5")+"60"+(cAlias)->FT_CODISS))
				TRB->DESCRSERV	:=	AllTrim(SX5->X5_DESCRI)
			EndIf
			
			TRB->ISSRETIDO 	:=	Iif(Alltrim((cAlias)->A1_RECISS)$"1", "1", "2")
			TRB->TOMTIPOCGC	:=	Iif(Alltrim((cAlias)->A1_EST) == 'EX', '3', Iif((cAlias)->A1_PESSOA == 'F', '1', '2'))
			TRB->TOMCGC		:=	Iif(Alltrim(TRB->TOMTIPOCGC) == '3', '00000000000', Alltrim((cAlias)->A1_CGC))
			TRB->TOMINSCMUN	:=	Alltrim((cAlias)->A1_INSCRM)
			TRB->TOMRSOCIAL	:=	Alltrim((cAlias)->A1_NOME)
			TRB->TOMENDEREC	:=	PADR(FisGetEnd(Alltrim((cAlias)->A1_END))[1],130)
			TRB->TOMNUMERO	:=	PADR(FisGetEnd(Alltrim((cAlias)->A1_END))[3],10)
			TRB->TOMCOMPEND	:=	PADR(FisGetEnd(Alltrim((cAlias)->A1_END))[4],60)
			TRB->TOMBAIRRO	:=	Alltrim((cAlias)->A1_BAIRRO)
			TRB->TOMESTADO	:=	Alltrim((cAlias)->A1_EST)
			TRB->TOMCEP 		:=	Alltrim((cAlias)->A1_CEP)
			TRB->TOMCODMUN	:=	UfCodIBGE(Alltrim((cAlias)->A1_EST)) + Alltrim((cAlias)->A1_COD_MUN)
			TRB->TOMADORTEL	:=	Alltrim((cAlias)->A1_TEL)												
			TRB->TOMEMAIL 	:=	Alltrim((cAlias)->A1_EMAIL)
			TRB->MUNTRIBISS	:=	Iif(Alltrim((cAlias)->FT_ISSST)=="1",SM0->M0_CODMUN,Iif((cAlias)->A1_RECISS $" /2",SM0->M0_CODMUN,UfCodIBGE(Alltrim((cAlias)->A1_EST))+Alltrim((cAlias)->A1_COD_MUN)))
			TRB->UFTRIBISS	:=	Iif(Alltrim((cAlias)->FT_ISSST)=="1",SM0->M0_ESTCOB,Iif((cAlias)->A1_RECISS $" /2",SM0->M0_ESTCOB,Alltrim((cAlias)->A1_EST)))												
			TRB->TOMINSCEST	:=	Alltrim((cAlias)->A1_INSCR)
			
			TRB->(MSunlock())

			cChave 	:= (cAlias)->(DTOS(FT_EMISSAO) + FT_NFISCAL)			
			nValServ	:= 0
			nValImp 	:= 0
			nValTot	:= 0
			nValCof	:= 0
			nValPis	:= 0
			nValIr		:= 0
			nValInss	:= 0
			nValCsll	:= 0
			nAliqIss	:= 0
			nBaseIss	:= 0
			nValDed	:= 0
							
			While (cAlias)->(!EOF()) .and. cChave ==  (cAlias)->(DTOS(FT_EMISSAO) + FT_NFISCAL)
				//-- Lista de Itens de Serviço				
				RecLock("TRI",.T.)
				TRI->SEQUENCIA	:=	nRelac
				TRI->ITDESCR		:=	Alltrim((cAlias)->B1_DESC)
				TRI->ITQUANT		:=	Alltrim(Transform((cAlias)->FT_QUANT, "@R 99999.99999"))
				TRI->ITVUNIT		:=	Alltrim(Transform((cAlias)->FT_PRCUNIT,	"@R 9999999999999999.99"))
				TRI->ITISSTRIB	:=	IIf((cAlias)->FT_CSTISS=="00","1","2")
								
				TRI->(MSunlock())
					
				nValServ	+=		(cAlias)->FT_VALCONT
				nValImp 	+=		(cAlias)->FT_VALICM
				nValTot	+=		(cAlias)->FT_TOTAL
				nValCof	+=		(cAlias)->FT_VRETCOF
				nValPis	+=		(cAlias)->FT_VRETPIS
				nValIr		+=		(cAlias)->FT_VALIRR
				nValInss	+=		(cAlias)->FT_VALINS
				nValCsll	+=		(cAlias)->FT_VRETCSL
				nAliqIss	:= 		(cAlias)->FT_ALIQICM
				nBaseIss	+= 		(cAlias)->FT_BASEICM
				nValDed	+=		(cAlias)->FT_ISSSUB
								
				(cAlias)->(dbSkip())
			EndDo
			//-- Prestador de Serviços - Corpo do Arquivo	   	
			RecLock("TRB",.F.)
			TRB->VALSERVICO 	:=	Alltrim(Transform(nValServ, "@R 9999999999999999.99"))
			TRB->VLDEDUCO		:=	Alltrim(Transform(nValDed,  "@R 9999999999999999.99"))
			TRB->VALPIS		:=	Alltrim(Transform(nValPis,	"@R 9999999999999999.99"))
			TRB->VALCOF		:=	Alltrim(Transform(nValCof,	"@R 9999999999999999.99"))
			TRB->VALINSS		:=	Alltrim(Transform(nValInss, "@R 9999999999999999.99"))
			TRB->VALIR			:=	Alltrim(Transform(nValIr,	"@R 9999999999999999.99"))
			TRB->VALCSLL		:=	Alltrim(Transform(nValCsll, "@R 9999999999999999.99"))			
			TRB->VALISS	 	:=	Alltrim(Transform(nValImp,  "@R 9999999999999999.99"))			
			TRB->VALISSRET	:=	Iif(TRB->ISSRETIDO == '1', TRB->VALISS, '0.00')
			TRB->VLOUTRRET	:=	'0.00'
			TRB->VLBASECALC	:=	Alltrim(Transform(nBaseIss,  "@R 9999999999999999.99"))	
			TRB->ALIQUOTA		:=	Alltrim(Transform(nAliqIss,  "@R 9.9999"))
			TRB->VALLIQNFS	:=	Alltrim(Transform((nValServ - (nValPis+nValCof+nValInss+nValIr+nValCsll+Val(TRB->VALISSRET))),  "@R 9999999999999999.99"))
			TRB->VLDESCINC	:=	'0.00'
			TRB->VLDESCCON	:=	'0.00'
						
			TRB->(MSunlock())	 		 					
		EndDo
		(cAlias)->(DbCloseArea())
	EndIf
	SM0->(DbSkip ())
EndDo
RestArea(aArea)
TRB->(DbGoTop())
TRI->(DbGoTop())
	
Return