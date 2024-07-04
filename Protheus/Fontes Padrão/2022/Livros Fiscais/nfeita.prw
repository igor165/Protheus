#Include "Protheus.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³NFEITA     ³ Autor ³ Diego Dias Godas		³ Data ³ 15.04.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Nota Fiscal Eletronica - Itaquaquecetuba - São Paulo        ³±±
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
Function NFEITA(dDataIni,dDataFin)
Local aArea		:=  GetArea()
Local aTRB 		:= {}
Local aTRBIT		:= {}
Local aTRBFI		:= {}
Local cArq			:= ""
Local cChave		:= ""
Local cChave2		:= ""
Local cAliasSE1	:= "SE1"
Local cAlias	:= ""

Local nCont		:= 0
Local nParc		:= 0
Local nValServ	:= 0
Local nValImp 	:= 0
Local nValTot		:= 0
Local nValCof		:= 0
Local nValPis		:= 0
Local nValIr		:= 0
Local nValInss	:= 0
Local nValCsll	:= 0
Local nAliqIss	:= 0

DbSelectArea("SM0")
SM0->(DbGoTop ())
SM0->(MsSeek(cEmpAnt + cFilAnt))

////////////////////////
////// NOTA FISCAL 1////
////////////////////////
aadd(aTRB,{"TIPOREG",   	 	'C',01,0}) //1- (1) Registro Detalhe
aadd(aTRB,{"SEQUENCIA",    	'C',08,0}) //2-Seq. de registros de Nf comentando com 1 p/ cada arq.
aadd(aTRB,{"NF",     		'C',08,0}) //3-(0)Preencher obrigatoriamente com zeros
aadd(aTRB,{"SITUACNF",		'C',01,0}) //4-(1) Situração normal (2)Situação Cancelada
aadd(aTRB,{"DTEMISSAO",		'C',08,0}) //5-Data de Emissão da Nota
aadd(aTRB,{"CODATIV",      	'C',06,0}) //6-Código de Atividade
aadd(aTRB,{"CFPS",    		'C',03,0}) //7-Cód Fiscal de Prestação de Serviço(verificar tabela)
aadd(aTRB,{"SERIE", 			'C',02,0}) //8-Sério da Nota Fiscal ( Valor "17" fixo)
aadd(aTRB,{"CPFCNPJ", 		'C',14,0}) //9-Indentificação da Empresa Tomadora
aadd(aTRB,{"RSOCIAL",		'C',100,0})//10-Nome
aadd(aTRB,{"CEP", 			'C',08,0}) //11-CEP
aadd(aTRB,{"ENDERECO",    	'C',100,0}) //12-Nome do endereço
aadd(aTRB,{"BAIRRO", 		'C',50,0}) //13-Bairro
aadd(aTRB,{"CIDADE", 		'C',60,0}) //14-Cidade
aadd(aTRB,{"CODUF", 	    	'C',02,0}) //15-Estado
aadd(aTRB,{"ENDCOBR",     	'C',100,0})//16-End. Cobrança
aadd(aTRB,{"EMAIL", 	    	'C',80,0}) //17-Emial
aadd(aTRB,{"ENVEMAIL", 		'C',01,0}) //18-Enviar por Email S-SIM ou NÃO
aadd(aTRB,{"ISSRETIDO", 		'C',01,0}) //19-Indicador de ISS Retido S - SIM; N – NÃO
aadd(aTRB,{"VALSERVICO", 	'N',14,2}) //20-Valor do Serviço Prestado
aadd(aTRB,{"VALDEDUC", 		'N',14,2}) //21-Valor das Deduções
aadd(aTRB,{"VALIMPOST", 		'N',14,2}) //22-Valor de Imposto
aadd(aTRB,{"ALIQUOTA", 		'N',04,2}) //23-Alíquota
aadd(aTRB,{"VALTOTNF", 		'N',14,2}) //24-Valor total da nota
aadd(aTRB,{"VALCOF",        'N',14,2}) //25-Valor COFINS
aadd(aTRB,{"VALPIS", 		'N',14,2}) //26-Valor PIS
aadd(aTRB,{"VALIR", 			'N',14,2}) //27-Valor IR
aadd(aTRB,{"VALINSS", 		'N',14,2}) //28-Valor INSS
aadd(aTRB,{"VALCSLL", 		'N',14,2}) //29-Valor CSLL
aadd(aTRB,{"RPS", 			'C',08,0}) //30-Numero do Rec. Prov. de Serviço
aadd(aTRB,{"MODELO",			'C',01,0}) //31-(F) FATURA OU (S) SIMPLES - Modelo de NF
aadd(aTRB,{"OBSERV",			'C',255,0})//32- Observação
aadd(aTRB,{"DTEMISRPS",		'C',08,0}) //33-Data de Emissão do Recibo Provisório de Serviço
aadd(aTRB,{"TIPOTOMAD",		'C',01,0}) //34-(J) Pessoa Jurídica, (F)PEssoa Física ou (O) Outro
aadd(aTRB,{"RGINSEST",		'C',20,0}) //35-Numero do RG ou Ins. Estadual da Empresa
aadd(aTRB,{"TRANSPNOME",		'C',150,0})//36-Nome da Transportadora
aadd(aTRB,{"TRANSCNPJ",		'C',20,0}) //37-CNPJ da Transportadora
aadd(aTRB,{"TRANSEND",		'C',250,0})//38-End. da Transportadora
aadd(aTRB,{"TRANSFRE",		'C',100,0})//39-Tipo de Frete. da Transportadora
aadd(aTRB,{"TRANSPQTD",		'N',14,2}) //40-Qtnd do produto Transportado
aadd(aTRB,{"TRANESPE",		'C',50,0}) //41-Especie do produto Transportado
aadd(aTRB,{"TRANPLIQ",		'N',14,2}) //42-Qtnd Liquido Transportado
aadd(aTRB,{"TRANPBRUT",		'N',14,2}) //43-Peso bruto do produto Transportado
aadd(aTRB,{"CSDECUNI",		'N',01,0}) //44-Qntd de casas decimais para o valor unitário
aadd(aTRB,{"CSDECTOT",		'N',01,0}) //45-Qntd de casas decimais para o valor total
aadd(aTRB,{"OUTROSDESC",		'N',14,2}) //46-Outros tipos de retenções**
aadd(aTRB,{"CCMTOMADOR",		'N',14,0}) //47-CCM do tomador
aadd(aTRB,{"SERVCIDADE",		'C',100,0})//48-Cidade onde o serviço foi prestado
aadd(aTRB,{"SERVESTADO",		'C',02,0}) //49-Estado onde o serviço foi prestado
aadd(aTRB,{"VALAPRXIMP",		'N',14,2}) //50-Valor Aprox. do Imp. da Nota
aadd(aTRB,{"ALIQIMPPX",		'N',05,2}) //51-Valor da Aliq. Aprox. do Imp.
aadd(aTRB,{"FONTEIMPPX",		'C',11,0}) //52-Fonte do Imp. Aprox.
aadd(aTRB,{"CLIENTE",		'C',TamSX3("A1_COD")[1],0}) //52-Cliente

//CRIA TABELA TEMPORARIA E INDICE QUE SERA UTILIZADO NO REGISTRO 1
cArq := CriaTrab(aTRB,.T.)
dbUseArea(.T.,,cArq,"TRB",.T.,.F.)

///////////////////////////
////// DETALHE DO ITEM 2///
///////////////////////////
aadd(aTRBIT,{"TIPOREG",   	 	'C',01,0}) //1-(2)Registro Detalhe
aadd(aTRBIT,{"SEQUENCIA",    	'C',08,0}) //2-Seq. de registros de Nf comentando com 1 p/ cada arq.
aadd(aTRBIT,{"ITEM",				'C',08,0}) //3-Item
aadd(aTRBIT,{"QNTDITEM",			'N',14,4}) //4-qntd Item
aadd(aTRBIT,{"UN",				'C',02,0}) //5-Unidade do item
aadd(aTRBIT,{"VLRUNIT",			'N',19,9}) //6-Vlr Unitario
aadd(aTRBIT,{"VLRTOTITEM",		'N',19,9}) //7-Vlr Total do Item
aadd(aTRBIT,{"DESCR",			'C',911,0}) //8-Descrição

//CRIA TABELA TEMPORARIA E INDICE QUE SERA UTILIZADO NO REGISTRO 2
cArq := CriaTrab(aTRBIT,.T.)
dbUseArea(.T.,,cArq,"TRI",.T.,.F.)

///////////////////////////
////// PARCELA DO ITEM 3///
///////////////////////////
aadd(aTRBFI,{"TIPOREG",   	 	'C',01,0}) //1-(3)Registro Detalhe
aadd(aTRBFI,{"SEQUENCIA",    	'C',08,0}) //2-Seq. de registros de Nf comentando com 1 p/ cada arq.
aadd(aTRBFI,{"NUMPARCELA",		'C',02,0}) //3-Número da Parcela
aadd(aTRBFI,{"DTVENC",			'C',08,0}) //4-Data de Vencimento da Parcela (ddmmyyyy)
aadd(aTRBFI,{"VLRTITULO",		'N',14,2}) //5-Valor da Parcela

//CRIA TABELA TEMPORARIA E INDICE QUE SERA UTILIZADO NO REGISTRO 2
cArq := CriaTrab(aTRBFI,.T.)
dbUseArea(.T.,,cArq,"TRF",.T.,.F.)

	Do While !SM0->(Eof()) .And. cEmpAnt==SM0->M0_CODIGO .And. 	cFilAnt == FWCodFil()
		If SuperGetMv("MV_ESTADO",,.F.) == "SP"		
			cAlias	:=	GetNextAlias()
			      
			BeginSql Alias cAlias
		   	
				COLUMN FT_EMISSAO AS DATE
				COLUMN FT_DTCANC AS DATE
								
				SELECT	SFT.FT_DTCANC,
				SFT.FT_EMISSAO,
				SFT.FT_ITEM,
				SFT.FT_NFISCAL,
				SFT.FT_ESPECIE,
				SFT.FT_CLIEFOR,
				SFT.FT_LOJA,
				SFT.FT_SERIE,
				SFT.FT_CFOP,
				SFT.FT_CODISS,
				SFT.FT_CFPS,
				SFT.FT_QUANT,
				SFT.FT_TOTAL,
				SFT.FT_PRCUNIT,
				SFT.FT_VALCONT,
				SFT.FT_VALCOF,
				SFT.FT_VALPIS,
				SFT.FT_VALINS,
				SFT.FT_VALCSL,
				SFT.FT_VALIRR,
				SFT.FT_VRETCOF,
				SFT.FT_VRETPIS,
				SFT.FT_VRETCSL,
				SFT.FT_VALICM,
				SFT.FT_ALIQICM,
				SFT.FT_FILIAL,				
				SB1.B1_COD,
				SB1.B1_DESC,
				SB1.B1_CODISS,
				SB1.B1_CNAE,
				SB1.B1_UM,				
				SD2.D2_UM,
				SA1.A1_COD,
				SA1.A1_LOJA,
				SA1.A1_CGC,
				SA1.A1_NOME,
				SA1.A1_CEP,
				SA1.A1_END,
				SA1.A1_ENDCOB,
				SA1.A1_BAIRRO,
				SA1.A1_MUN,
				SA1.A1_EST,
				SA1.A1_EMAIL,
				SA1.A1_RECISS,
				SA1.A1_PESSOA,
				SF2.F2_PREFIXO				
				FROM
				%TABLE:SFT% SFT
				INNER JOIN %TABLE:SB1% SB1
				ON(SB1.B1_FILIAL=%XFILIAL:SB1%
				AND SFT.FT_PRODUTO = SB1.B1_COD
				AND SB1.%NOTDEL%)
				LEFT JOIN %TABLE:SD2% SD2
				ON(SD2.D2_FILIAL=%XFILIAL:SD2%
				AND SFT.FT_NFISCAL = SD2.D2_DOC
				AND SFT.FT_SERIE = SD2.D2_SERIE
				AND SFT.FT_CLIEFOR = SD2.D2_CLIENTE
				AND SFT.FT_LOJA = SD2.D2_LOJA
				AND SFT.FT_ITEM = SD2.D2_ITEM
				AND SD2.%NOTDEL%)
				INNER JOIN %TABLE:SA1% SA1
				ON(SA1.A1_FILIAL=%XFILIAL:SA1%
				AND SA1.A1_COD = SFT.FT_CLIEFOR
				AND SA1.A1_LOJA = SFT.FT_LOJA
				AND SA1.%NOTDEL%)
				LEFT JOIN %TABLE:SF2% SF2
				ON(SF2.F2_FILIAL=%XFILIAL:SF2%
				AND SFT.FT_NFISCAL = SF2.F2_DOC
				AND SFT.FT_SERIE = SF2.F2_SERIE
				AND SFT.FT_CLIEFOR = SF2.F2_CLIENTE
				AND SFT.FT_LOJA = SF2.F2_LOJA
				AND SF2.%NOTDEL%)
				WHERE
				SFT.FT_FILIAL=%XFILIAL:SFT%
				AND SFT.FT_EMISSAO >= %EXP:DTOS(DDATAINI)%
				AND SFT.FT_EMISSAO <= %EXP:DTOS(DDATAFIN)%
				AND SFT.FT_CODISS <> ' '
				AND SFT.FT_ESPECIE = 'RPS'
				AND SFT.%NOTDEL%
				ORDER BY SFT.FT_EMISSAO, SFT.FT_NFISCAL
			EndSql
			
			DbSelectArea (cAlias)
			(cAlias)->(DbGoTop())
			
			While (cAlias)->(!EOF())				
				//NOTA FISCAL
				nCont++
				RecLock("TRB",.T.)
				TRB->TIPOREG 		:= "1"														//1- (1) Registro Detalhe
				TRB->SEQUENCIA	:=	StrZero(nCont,8)							   			//2-Seq. de registros de Nf comentando com 1 p/ cada arq.
				TRB->NF			:=	"00000000"												//3-(0)Preencher obrigatoriamente com zeros
				TRB->SITUACNF 	:=	Iif(Empty((cAlias)->FT_DTCANC),"1","2")			//4-(1) Situração normal (2)Situação Cancelada
				TRB->DTEMISSAO 	:=  StrTran(Dtoc((cAlias)->FT_EMISSAO),"/","")		//5-Data de Emissão da Nota
				TRB->CODATIV		:= 	StrZero(Val((cAlias)->B1_CODISS),6)									 //6-Código de Atividade
				TRB->CFPS			:=	Iif(!Empty((cAlias)->FT_CFPS),(cAlias)->FT_CFPS,StrZero(0,3))	//7-Cód Fiscal de Prestação de Serviço(verificar tabela)
				TRB->SERIE			:=	(cAlias)->FT_SERIE							//8-Sério da Nota Fiscal ( Valor "17" fixo)
				TRB->CPFCNPJ		:=	StrZero (Val ((cAlias)->A1_CGC ), 14)				  				//9-CPF ou CNPJ
				TRB->RSOCIAL 		:=	(cAlias)->A1_NOME    						//10-Nome ou Razão Social
				TRB->CEP 			:=	(cAlias)->A1_CEP								//11-CEP
				TRB->ENDERECO		:=	StrTran((cAlias)->A1_END,",","")	 		//12-Endereco
				TRB->ENDCOBR		:=	StrTran((cAlias)->A1_ENDCOB,",","")	 	//-Endereco cobranca
				TRB->BAIRRO 		:=	(cAlias)->A1_BAIRRO							//13-Bairro
				TRB->CIDADE 		:=	(cAlias)->A1_MUN								//14-Cidade
				TRB->CODUF 		:=	(cAlias)->A1_EST								//15-Código da Unidade de Federação
				TRB->EMAIL 		:=	(cAlias)->A1_EMAIL							//16-EMAIL
				TRB->ISSRETIDO 	:= Iif((cAlias)->A1_RECISS$"1", "S", "N") 	//19-Indicador de ISS Retido S - SIM; N – NÃO
				TRB->ENVEMAIL		:= Iif(!Empty((cAlias)->A1_EMAIL),"S","N")    //-EnviarNFporemail (S)IM ou (N)ÃO
				//Tipo de Pessoa   
				TRB->TIPOTOMAD := (cAlias)->A1_PESSOA								//34-(J) Pessoa Jurídica, (F)PEssoa Física ou (O) Outro
				IF 	(cAlias)->A1_EST = 'EX'
					TRB->TIPOTOMAD := "O"											//34-(J) Pessoa Jurídica, (F)PEssoa Física ou (O) Outro
				EndIf
				nTamRps			:= Len(alltrim((cAlias)->FT_NFISCAL))
				TRB->RPS			:=	IIF(nTamRps<8,StrZero(0,8-nTamRps),"")+ Right(Alltrim((cAlias)->FT_NFISCAL),8)					//30-Numero do Rec. Prov. de Serviço
				TRB->MODELO		:=	Iif(Alltrim((cAlias)->FT_ESPECIE)=="RPS" .And. Alltrim(TRB->SITUACNF)=="1","F","S")		//31-(F) FATURA OU (S) SIMPLES - Modelo de NF
				TRB->DTEMISRPS	:=	StrTran(Dtoc((cAlias)->FT_EMISSAO),"/","")	//33-Data de Emissão do Recibo Provisório de Serviço
				TRB->CSDECUNI 	:= TamSX3("FT_PRCUNIT")[2]								//44-Qntd de casas decimais para o valor unitário
				TRB->CSDECTOT 	:= TamSX3("FT_VALCONT")[2] 							//45-Qntd de casas decimais para o valor total

				TRB->(MSunlock())

				cChave 	:= (cAlias)->(DTOS(FT_EMISSAO) + FT_NFISCAL)
				cChave2 	:= (cAlias)->(FT_FILIAL + FT_CLIEFOR + FT_LOJA + F2_PREFIXO + FT_NFISCAL)
				nValServ	:= 0
				nValImp 	:= 0
				nValTot	:= 0
				nValCof	:= 0
				nValPis	:= 0
				nValIr		:= 0
				nValInss	:= 0
				nValCsll	:= 0
				
				While (cAlias)->(!EOF()) .and. cChave ==  (cAlias)->(DTOS(FT_EMISSAO) + FT_NFISCAL)
					//DETALHE DO ITEM					
					RecLock("TRI",.T.)
					TRI->TIPOREG 		:= "2"								//1- (2) Registro Detalhe
					TRI->SEQUENCIA 	:=	StrZero(nCont,8)				//2-Seq. de registros de Nf comentando com 1 p/ cada arq.
					TRI->ITEM			:= StrZero(Val((cAlias)->FT_ITEM),8)   //3-Item
					TRI->QNTDITEM		:= (cAlias)->FT_QUANT			//4-qntd Item
					If Len(Alltrim((cAlias)->D2_UM)) > 0
						TRI->UN			:= (cAlias)->D2_UM				//5-Unidade do item
					Else
						TRI->UN			:= (cAlias)->B1_UM				//5-Unidade do item
					EndIf
					TRI->VLRUNIT		:= (cAlias)->FT_PRCUNIT			//6-Vlr Unitario
					TRI->VLRTOTITEM	:= (cAlias)->FT_TOTAL			//7-Vlr Total do Item
					TRI->DESCR			:= (cAlias)->B1_DESC				//8-Descr. do Item
					TRI->(MSunlock())
					
					nValServ	+=		(cAlias)->FT_VALCONT		//20-Valor do Serviço Prestado
					nValImp 	+=		(cAlias)->FT_VALICM 		//22-Valor de Imposto
					nValTot	+=		(cAlias)->FT_TOTAL
					nValCof	+=		(cAlias)->FT_VRETCOF		//25-Valor COFINS
					nValPis	+=		(cAlias)->FT_VRETPIS 		//26-Valor PIS
					nValIr		+=		(cAlias)->FT_VALIRR		//27-Valor IR
					nValInss	+=		(cAlias)->FT_VALINS		//28-Valor CSLL
					nValCsll	+=		(cAlias)->FT_VRETCSL		//29-Valor CSLL
					nAliqIss	:= 		(cAlias)->FT_ALIQICM

					(cAlias)->(dbSkip())
				EndDo
			   	
				RecLock("TRB",.F.)
				TRB->VALSERVICO 	:=	nValServ											//20-Valor do Serviço Prestado
				TRB->VALIMPOST 	:=	nValImp											//22-Valor de Imposto
				TRB->ALIQUOTA		:=	nAliqIss											//23-Alíquota
				TRB->VALTOTNF		:=	nValTot											//24-Valor total da nota
				TRB->VALCOF		:=	nValCof											//25-Valor COFINS
				TRB->VALPIS		:=	nValPis											//26-Valor PIS
				TRB->VALIR			:=	nValIr												//27-Valor IR
				TRB->VALINSS		:=	nValInss											//28-Valor CSLL
				TRB->VALCSLL		:=	nValCsll											//29-Valor CSLL
				TRB->(MSunlock())
	 		 	
				DbSelectArea(cAliasSE1)
				(cAliasSE1)->(DbGoTop())
				(cAliasSE1)->(dbSetOrder(2))
				(cAliasSE1)->(MsSeek(cChave2))
	 				 			
				While (cAliasSE1)->(!EOF()) .and. (cChave2 ==  (cAliasSE1)->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM))
					nParc++
					RecLock("TRF",.T.)
					TRF->TIPOREG 		:= "3"								//1-(3) Parcela Nota Fiscal
					TRF->SEQUENCIA 	:=	StrZero(nCont,8)				//2-Seq. de registros de Nf comentando com 1 p/ cada arq.
					TRF->NUMPARCELA	:=	StrZero(nParc,2)				//3-Número da Parcela
					TRF->DTVENC		:=	StrZero(Day((cAliasSE1)->E1_VENCTO),2) + StrZero(Month(SE1->E1_VENCTO),2)+StrZero(Year(SE1->E1_VENCTO),4) //4-Data do Vencimento do Titulo
					TRF->VLRTITULO	:=	(cAliasSE1)->E1_VALOR		//5-Valor do Titulo
					TRF->(MSunlock())
					
					(cAliasSE1)->(dbSkip())
				EndDo
				(cAliasSE1)->(DbCloseArea())
			EndDo
			(cAlias)->(DbCloseArea())
		EndIf
		SM0->(DbSkip ())
	EndDo
RestArea(aArea)
TRB->(DbGoTop())
TRI->(DbGoTop())
TRF->(DbGoTop())
	
Return