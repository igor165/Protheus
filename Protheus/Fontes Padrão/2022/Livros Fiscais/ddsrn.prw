#Include "Protheus.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DDSRN     ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 06.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³DDS - Declaracao Digital de Servicos - Municipio de Natal/RN³±±
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
Function DDSRN()

Local	cCMC := ""
Private aCfp := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivos temporarios                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraTemp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa DDSRN                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Cfp()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recupera dados do arquivo DDSRN.CFP           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xMagLeWiz("DDSRN",@aCfp,.T.)
	Processa({||ProcDDS()})
	cCMC := aCfp[1,1]
Endif

// Retorna o numero do CMC digitado na Wizard para montar o nome do arquivo magnetico
Return(StrZero(Val(cCMC),7))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcDDS    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 06.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa as informacoes do DDS-RN                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcDDS()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro: Header                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcA01()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro: Contribuinte                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcC02()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro: Documento Recebido                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcO09()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcA01    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 06.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro: Header                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcA01()

RecLock("A01",.T.)
A01->CMC		:= StrZero(Val(aCfp[1,1]),7)				//CMC - Inscricao Municipal do Contribuinte
A01->COMPETENC	:= StrZero(Year(mv_par02),4)+StrZero(Month(mv_par02),2)	//Competencia da DDS - AAAAMM
A01->TPDDS		:= IIf(Alltrim(aCfp[1,2])=="Retificadora","R","N")			//N-Normal ou R-Retificadora
A01->DATAGERA	:= StrZero(Day(Date()),2)+StrZero(Month(Date()),2)+StrZero(Year(Date()),4)	//Data da Geracao
A01->HORAGERA	:= StrTran(Time(),":","")					//Hora da Geracao
A01->APLICATIVO	:= "1000"									//Ultima versao do aplicativo - Fixo "1000"
A01->PREFEITURA	:= Alltrim(aCfp[1,3])						//Codigo da Prefeitura - "NATA"
A01->ESPECIEDDS	:= "EM"										//Especie de DDS - Fixo "EM"
A01->INDICMOV	:= IIf(Alltrim(aCfp[1,4])=="Sim","C","S")	//Indicacao de Movimento - S-Sem ou C-Com
MsUnlock()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcC02    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 06.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro: Contribuinte                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcC02()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O validador nao aceita virgula no campo endereco ³
//³e existem casos em que a fucao FisGetEnd retorna ³
//³o endereco com virgula                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cEndereco	:=	FisGetEnd(SM0->M0_ENDENT)[1]
Local nVirgula	:=	At(",",cEndereco)
If nVirgula > 0
	cEndereco := AllTrim(SubStr(cEndereco,1,nVirgula-1))
EndIf

RecLock("C02",.T.)
C02->RAZSOC		:= SM0->M0_NOMECOM
C02->ENDERECO	:= cEndereco
C02->NUMERO		:= IIf("S/N"$Upper(SM0->M0_ENDENT),"S/N",Alltrim(Str(FisGetEnd(SM0->M0_ENDENT)[2],5)))
C02->COMPLEMENT	:= SM0->M0_COMPENT
C02->BAIRRO		:= SM0->M0_BAIRENT
C02->CEP		:= Transform(SM0->M0_CEPENT,"@R 99999-999")
C02->CNPJ		:= SM0->M0_CGC
C02->DDDTEL		:= Subs(SM0->M0_TEL,1,2)
C02->TELEFONE	:= Subs(SM0->M0_TEL,3,8)
C02->DDDFAX		:= Subs(SM0->M0_FAX,1,2)
C02->FAX		:= Subs(SM0->M0_FAX,3,8)
C02->CONTADOR	:= Alltrim(aCfp[1,5])
C02->CPF_CNPJ	:= Alltrim(aCfp[1,6])
C02->EMAIL		:= Alltrim(aCfp[1,7])
C02->CRC		:= Alltrim(aCfp[1,8])
C02->TPSERV		:= Subs(AllTrim(aCfp[1,9]),7,1)
MsUnlock()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcE03    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 06.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro: Tomador / Prestador                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcE03(cTipo)

Local aArea		:= GetArea()
Local lGrava	:= .F.
Local aDados	:= Array(19)
Local cCMCSA1	:= GetNewPar("MV_CMCSA1","")	//CMC do Cadastro de Cliente
Local cCMCSA2	:= GetNewPar("MV_CMCSA2","")	//CMC do Cadastro de Fornecedor

If cTipo == "C"		//Cliente ou Tomador
	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+SFT->FT_CLIEFOR+SFT->FT_LOJA)
		lGrava		:= .T.
		aDados[01]	:= cTipo
		aDados[02]	:= SA1->A1_COD+SA1->A1_LOJA
		aDados[03]	:= aFisFill(SA1->A1_CGC,20)
		aDados[04]	:= IIf(Empty(cCMCSA1),"",SA1->&(cCMCSA1))
		aDados[05]	:= SA1->A1_NOME
		aDados[06]	:= AllTrim(FisGetEnd(SA1->A1_END)[1])
		aDados[07]	:= Alltrim(IIf(Empty(FisGetEnd(SA1->A1_END)[2]),"S/N",Str(FisGetEnd(SA1->A1_END)[2])))
		aDados[08]	:= ""	//Complemento de Endereco
		aDados[09]	:= SA1->A1_BAIRRO
		aDados[10]	:= SA1->A1_MUN
		aDados[11]	:= SA1->A1_EST
		aDados[12]	:= Transform(SA1->A1_CEP,"@R 99999-999")
		aDados[13]	:= StrZero(Val(SA1->A1_DDD),2)		//DDD - Tel
		aDados[14]	:= SA1->A1_TEL
		aDados[15]	:= StrZero(Val(SA1->A1_DDD),2)		//DDD - Fax
		aDados[16]	:= SA1->A1_FAX
		aDados[17]	:= SA1->A1_EMAIL
		aDados[18]	:= IIf(SA1->A1_TIPO=="X","S","N")
		aDados[19]	:= SA1->A1_RECISS
	Endif
Else				//Fornecedor ou Prestador
	dbSelectArea("SA2")
	dbSetOrder(1)
	If dbSeek(xFilial("SA2")+SFT->FT_CLIEFOR+SFT->FT_LOJA)
		lGrava		:= .T.
		aDados[01]	:= cTipo
		aDados[02]	:= SA2->A2_COD+SA2->A2_LOJA
		aDados[03]	:= aFisFill(SA2->A2_CGC,20)
		aDados[04]	:= IIf(Empty(cCMCSA2),"",SA2->&(cCMCSA2))
		aDados[05]	:= SA2->A2_NOME
		aDados[06]	:= Alltrim(FisGetEnd(SA2->A2_END)[1])
		aDados[07]	:= Alltrim(IIf(Empty(FisGetEnd(SA2->A2_END)[2]),"S/N",Str(FisGetEnd(SA2->A2_END)[2])))
		aDados[08]	:= SA2->A2_ENDCOMP		//Complemento de Endereco
		aDados[09]	:= SA2->A2_BAIRRO
		aDados[10]	:= SA2->A2_MUN
		aDados[11]	:= SA2->A2_EST
		aDados[12]	:= Transform(SA2->A2_CEP,"@R 99999-999")
		aDados[13]	:= StrZero(Val(SA2->A2_DDD),2)		//DDD - Tel
		aDados[14]	:= SA2->A2_TEL
		aDados[15]	:= StrZero(Val(SA2->A2_DDD),2)		//DDD - Fax
		aDados[16]	:= SA2->A2_FAX
		aDados[17]	:= SA2->A2_EMAIL
		aDados[18]	:= IIf(SA2->A2_TIPO=="X","S","N")
		aDados[19]	:= SA2->A2_RECISS
	Endif
Endif	
     
If lGrava
	dbSelectArea("E03")
	If !dbSeek(cTipo+SFT->FT_CLIEFOR+SFT->FT_LOJA)
		RecLock("E03",.T.) 
		E03->TIPO			:= aDados[01]
		E03->CODIGO			:= aDados[02]
		E03->CPFCNPJPAS		:= aDados[03]
		E03->CMC			:= aDados[04]
		E03->NOME			:= aDados[05]
		E03->ENDERECO		:= aDados[06]
		E03->NUMERO			:= aDados[07]
		E03->COMPLEMENT		:= aDados[08]
		E03->BAIRRO			:= aDados[09]
		E03->MUNICIPIO		:= aDados[10]
		E03->ESTADO			:= aDados[11]
		E03->CEP			:= aDados[12]						
		E03->DDDTEL			:= aDados[13]
		E03->TELEFONE		:= aDados[14]
		E03->DDDFAX			:= aDados[15]
		E03->FAX			:= aDados[16]
		E03->EMAIL			:= aDados[17]
		E03->ESTRANGEIR		:= aDados[18]
		MsUnlock()
	Endif
Endif
RestArea(aArea)

Return(aDados)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcO09    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 06.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro: Documento Recebido                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcO09()

	Local nSeq		:= 0
	Local aArq		:= {"SFT",""}
	Local cTop		:= "FT_FILIAL='"+xFilial("SFT")+"' AND FT_EMISSAO>='"+DTOS(MV_PAR01)+"' AND FT_EMISSAO<='"+DTOS(MV_PAR02)+"' AND FT_TIPOMOV='E' AND FT_TIPO='S'"
	Local cRecISS	:= ""
	Local cCampos	:= ""
	Local cGroup	:= ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionando as Tabelas                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA1->(dbSetOrder(1))
	SA2->(dbSetOrder(1))
	SFT->(dbSetOrder(3))

	// array com campos que serão utilizados no SELECT
	cCampos	:= SFT->(IndexKey())
	cCampos	:= StrTran(cCampos,"+",",")
	cCampos	:= StrTran(cCampos,"DTOS(","")
	cCampos	:= StrTran(cCampos,")","")
	cCampos	+= ",FT_EMISSAO,FT_RECISS,FT_ALIQICM"

	// monta o GROUP BY com todos os campos do SELECT
	cGroup	:= cCampos

	// acrescenta os campos com agregação
	cCampos += ", SUM(FT_VALCONT) FT_VALCONT, SUM(FT_BASEICM) FT_BASEICM, SUM(FT_VALICM) FT_VALICM"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Documento Recebido                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FsQuery(aArq,1,cTop,,SFT->(IndexKey()),,,cCampos,cGroup)
	dbGoTop()
	While !Eof()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Registro: Tomador / Prestador                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aE03 := ProcE03("F")

		RecLock("O09",.T.)		
		O09->SEQUENCIAL	:= StrZero(++nSeq,6)			//Sequencial
		O09->PRESTADOR	:= aE03[05]					//Nome ou Razao Social do Prestador
		O09->ENDERECO		:= aE03[06]					//Endereco
		O09->NUMERO		:= aE03[07]					//Numero
		O09->COMPLEMENT	:= aE03[08]					//Complemento de Endereco
		O09->BAIRRO		:= aE03[09]					//Bairro
		O09->MUNICIPIO	:= aE03[10]					//Municipio
		O09->ESTADO		:= aE03[11]					//Estado
		O09->CEP			:= aE03[12]					//CEP - 99999-999
		O09->CPF_CNPJ		:= aE03[03]					//CPF / CNPJ
		O09->DOCTIPO		:= "N"							//Tipo Documento - N-Nota Fiscal / P-Processo / R-Recibo
		O09->SERIE			:= SerieNfId("SFT",2,"FT_SERIE")			//Serie da NF 
		O09->SUBSERIE		:= ""							//Subserie da NF
		O09->NFISCAL		:= SFT->FT_NFISCAL			//Nota Fiscal
		O09->DATAEMIS		:= StrZero(Day(SFT->FT_EMISSAO),2)+StrZero(Month(SFT->FT_EMISSAO),2)+StrZero(Year(SFT->FT_EMISSAO),4)	//Data de Emissao 
		O09->DATAPGTO		:= RetDtPag()					//Data de Pagamento
		O09->CMC			:= aE03[04]					//CMC
		O09->VALORSERV	:= SFT->FT_VALCONT			//Valor do Servico

		cRecISS := SFT->FT_RECISS
		//ISS Retido - Recolhe ISS Nao	
		If cRecISS<>"1"	
			O09->ALIQUOTA	:= SFT->FT_ALIQICM			//% da Aliquota de ISS
			O09->BASECALC	:= SFT->FT_BASEICM			//Base de Calculo
			O09->ISSRET		:= SFT->FT_VALICM			//Valor do ISS Retido
			O09->RETIDO		:= "S"
		Else
			O09->RETIDO		:= "N"
		Endif
		
		O09->SEQRECIBO		:= "000000"				//Sequencial do Recibo
		O09->CODBASELEG		:= Iif(O09->VALORSERV<>O09->BASECALC,"1","")						//Codigo da Base Legal	
		MsUnlock()
		dbSelectArea("SFT")
		dbSkip()
	Enddo
	FsQuery(aArq,2)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CFP        ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 06.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina CFP                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CFP()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao das variaveis                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nPos			:= 0
Local aTxtPre 		:= {}
Local aPaineis 		:= {}
Local cTitObj1		:= ""
Local cTitObj2		:= ""       
Local nMask14		:= Replicate("9",14)
Local cMask35		:= Replicate("!",35)
Local cMask55		:= Replicate("!",55)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta wizard com as perguntas necessarias          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aTxtPre,"Assistente de parametrização da DDS-RN")
AADD(aTxtPre,"Atenção!")
AADD(aTxtPre,"Para a correta geração do arquivo magnético preencha as informações solicitadas")
AADD(aTxtPre,"DDS - Declaracao Digital de Serviços - Declaração Municipal               Estado do Rio Grande do Norte")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Painel com as informacoes gerais e do contribuinte ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aPaineis,{})
nPos :=	Len(aPaineis)
aAdd(aPaineis[nPos],"Preenchimento das Informações Gerais e do Contribuinte")
aAdd(aPaineis[nPos],"")
aAdd(aPaineis[nPos],{})

cTitObj1 :=	"CMC do Contribuinte ?" 				//Cfp[1][01]
cTitObj2 :=	"Tipo da DDS ?"   			    		//Cfp[1][02]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2,,"XXXXXXX",1,,,,7})
aAdd(aPaineis[nPos][3],{3,,,,,{"Normal","Retificadora"},,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

cTitObj1 :=	"Código da Prefeitura ?" 				//Cfp[1][03]
cTitObj2 :=	"Declaracao com Movimento ?"			//Cfp[1][04]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2,,"!!!!",1,,,,4})
aAdd(aPaineis[nPos][3],{3,,,,,{"Sim","Não"},,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

cTitObj1 :=	"Nome do Contabilista ?"				//Cfp[1][05]
cTitObj2 :=	"CPF/CNPJ do Contabilista ?"			//Cfp[1][06]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2,,cMask55,1,,,,55})
aAdd(aPaineis[nPos][3],{2,,nMask14,1,,,,14})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})     
aAdd(aPaineis[nPos][3],{0,"",,,,,,})     

cTitObj1 :=	"Email do Contabilista ?"				//Cfp[1][07]
cTitObj2 :=	"CRC do Contabilista ?"					//Cfp[1][08]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
aAdd(aPaineis[nPos][3],{2,,cMask35,1,,,,35})
aAdd(aPaineis[nPos][3],{2,,"9999999",1,,,,7})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})     

/*/
----------------------------------------------------------------------------------------------
   Tipos de Servicos:
   Opcao 1: Servicos em geral tributados pelo ISS  e nao especificados nos itens abaixo
   Opcao 2: Sevicos tributados pelo ISS com autorizacao especifica
   Opcao 3: Servicos executados por Instituicao Financeira
   Opcao 4: Servicos executados por Empresas de Educacao
   Opcao 5: Empresas enquadradas no regime de estimativa
   Opcao 6: Empresas que apenas tem obrigacao de substituicao tributaria (Ex: Orgaos Publicos)
----------------------------------------------------------------------------------------------
/*/
cTitObj1 :=	"Serviços Executados pela Empresa ?"	//Cfp[1][09]
aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
aAdd(aPaineis[nPos][3],{3,,,,,{"Opção 2","Opção 6",1},,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})     

Return(xMagWizard(aTxtPre,aPaineis,"DDSRN"))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetDtPag   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 06.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a Data de Pagamento do Titulo                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetDtPag()

Local aArea := GetArea()
Local dData := SFT->FT_EMISSAO

dbSelectArea("SE2")
dbSetOrder(6)
If dbSeek(xFilial("SE2")+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_SERIE+SFT->FT_NFISCAL)
	If !Empty(SE2->E2_BAIXA	)
		dData := SE2->E2_BAIXA
	Else
		dData := SE2->E2_VENCREA
	Endif
Endif
RestArea(aArea)

Return(StrZero(Day(dData),2)+StrZero(Month(dData),2)+StrZero(Year(dData),4))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 06.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera Arquivos Temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp()

Local aStru	:= {}
Local cArq	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A01 - Registro: Header                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru,{"CMC"			,"C",007,0})	//CMC - Inscricao Municipal do Contribuinte
AADD(aStru,{"COMPETENC"		,"C",006,0})	//Competencia da DDS - AAAAMM
AADD(aStru,{"TPDDS"			,"C",001,0})	//N-Normal ou R-Retificadora
AADD(aStru,{"DATAGERA"		,"C",008,0})	//Data da Geração
AADD(aStru,{"HORAGERA"		,"C",006,0})	//Hora da Geração
AADD(aStru,{"APLICATIVO"	,"C",004,0})	//Ultima versao do aplicativo - Fixo "1000"
AADD(aStru,{"PREFEITURA"	,"C",004,0})	//Codigo da Prefeitura - Fixo "NATA"
AADD(aStru,{"ESPECIEDDS"	,"C",002,0})	//Especie de DDS - Fixo "EM"
AADD(aStru,{"INDICMOV"		,"C",001,0})	//Indicacao de Movimento - S-Sem ou C-Com

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"A01")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³C02 - Registro: Contribuinte                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"RAZSOC"		,"C",055,0})		//Razao Social
AADD(aStru,{"ENDERECO"		,"C",035,0})		//Endereco
AADD(aStru,{"NUMERO"		,"C",005,0})		//Numero
AADD(aStru,{"COMPLEMENT"	,"C",012,0})		//Complemento
AADD(aStru,{"BAIRRO"		,"C",019,0})		//Bairro
AADD(aStru,{"CEP"			,"C",009,0})		//CEP
AADD(aStru,{"CNPJ"			,"C",014,0})		//CNPJ
AADD(aStru,{"DDDTEL"		,"C",002,0})		//DDD Tel
AADD(aStru,{"TELEFONE"		,"C",008,0})		//Telefone
AADD(aStru,{"DDDFAX"		,"C",002,0})		//DDD Fax
AADD(aStru,{"FAX"			,"C",008,0})		//Fax
AADD(aStru,{"CONTADOR"		,"C",055,0})		//Nome do Contabilista Responsavel
AADD(aStru,{"CPF_CNPJ" 		,"C",014,0})		//CPF/CNPJ do Contabilista 
AADD(aStru,{"EMAIL"			,"C",035,0})		//Email do Contabilista 
AADD(aStru,{"CRC"			,"C",007,0})		//CRC do Contabilista 
AADD(aStru,{"TPSERV"		,"C",001,0})		//Tipo de Servico:	Opcao 1 a 6 (Conforme Documentacao)

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"C02")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³E03 - Registro: Tomador / Prestador                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"TIPO"			,"C",001,0})		//Tipo - C-Cliente ou F-Fornecedor
AADD(aStru,{"CODIGO"		,"C",008,0})		//Codigo do Tomador / Prestador
AADD(aStru,{"CPFCNPJPAS"	,"C",020,0})		//CPF/CNPJ/PASSAPORTE
AADD(aStru,{"CMC"			,"C",007,0})		//CMC - Inscricao Municipal
AADD(aStru,{"NOME"			,"C",055,0})		//Nome ou Razao Social
AADD(aStru,{"ENDERECO"		,"C",035,0})		//Endereco
AADD(aStru,{"NUMERO"		,"C",005,0})		//Numero
AADD(aStru,{"COMPLEMENT"	,"C",012,0})		//Complemento de Endereco
AADD(aStru,{"BAIRRO"		,"C",019,0})		//Bairro
AADD(aStru,{"MUNICIPIO"		,"C",025,0})		//Municipio
AADD(aStru,{"ESTADO"		,"C",002,0})		//Estado
AADD(aStru,{"CEP"			,"C",009,0})		//CEP
AADD(aStru,{"DDDTEL"		,"C",002,0})		//DDD do Telefone
AADD(aStru,{"TELEFONE"		,"C",008,0})		//Telefone
AADD(aStru,{"DDDFAX"		,"C",002,0})		//DDD do Fax
AADD(aStru,{"FAX"			,"C",008,0})		//Fax
AADD(aStru,{"EMAIL"			,"C",035,0})		//Email
AADD(aStru,{"ESTRANGEIR"	,"C",001,0})		//Estrangeiro

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"E03")
IndRegua("E03",cArq,"TIPO+CODIGO")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O09 - Registro: Documento Recebido                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cArq	:= ""
AADD(aStru,{"SEQUENCIAL"	,"C",006,0})		//Sequencial
AADD(aStru,{"PRESTADOR"		,"C",055,0})		//Nome ou Razao Social do Prestador
AADD(aStru,{"ENDERECO"		,"C",035,0})		//Endereco
AADD(aStru,{"NUMERO"		,"C",005,0})		//Numero
AADD(aStru,{"COMPLEMENT"	,"C",012,0})		//Complemento de Endereco
AADD(aStru,{"BAIRRO"		,"C",019,0})		//Bairro
AADD(aStru,{"MUNICIPIO"		,"C",025,0})		//Municipio
AADD(aStru,{"ESTADO"		,"C",002,0})		//Estado
AADD(aStru,{"CEP"			,"C",009,0})		//CEP - 99999-999
AADD(aStru,{"CPF_CNPJ"		,"C",020,0})		//CPF / CNPJ
AADD(aStru,{"DOCTIPO"		,"C",001,0})		//Tipo Documento - N-Nota Fiscal / P-Processo / R-Recibo
AADD(aStru,{"SERIE"			,"C",002,0})		//Serie da NF 
AADD(aStru,{"SUBSERIE"		,"C",003,0})		//Subserie da NF
AADD(aStru,{"NFISCAL"		,"C",014,0})		//Nota Fiscal
AADD(aStru,{"DATAEMIS"		,"C",008,0})		//Data de Emissao 
AADD(aStru,{"DATAPGTO"		,"C",008,0})		//Data de Pagamento
AADD(aStru,{"CMC"			,"C",007,0})		//CMC
AADD(aStru,{"VALORSERV"		,"N",011,2})		//Valor do Servico
AADD(aStru,{"ALIQUOTA"		,"N",004,2})		//% da Aliquota de ISS
AADD(aStru,{"BASECALC"		,"N",011,2})		//Base de Calculo
AADD(aStru,{"ISSRET"		,"N",011,2})		//Valor do ISS Retido
AADD(aStru,{"RETIDO"		,"C",001,0})		//Retido - S-Sim ou N-Nao 
AADD(aStru,{"SEQRECIBO"		,"C",006,0})		//Sequencial do Recibo
AADD(aStru,{"CODBASELEG"	,"C",005,0})		//Codigo da Base Legal	

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"O09")

Return Nil
