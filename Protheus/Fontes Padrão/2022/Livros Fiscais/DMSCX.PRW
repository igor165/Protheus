#Include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DMSCX     ³ Autor ³Nereu Humberto Jr      ³ Data ³09.10.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada para montar um arquivo de trabalho para ser³±±
±±³          ³ processado atraves do INI. Esta funcao foi necessaria por  ³±±
±±³          ³ haver a nescessidade de gerar o arquivo texto para cada    ³±±
±±³          ³ documento fiscal em ordem decrescente de aliquota.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ARRAY -> Array contendo o nome fisico do arquito de trabalho³±±
±±³          ³         e alias do mesmo.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc     -> 1=Para gerar a movimentacao para o INI e 2=Para ³±±
±±³          ³         excluir o arquivo de trabalho.                     ³±±
±±³          ³aDelArqs -> Array contendo o nome fisico do arquito de      ³±±
±±³          ³         trabalho e alias do mesmo.                         ³±±
±±³          ³lMVF3RECIS -> Conteudo do parametro MV_F3RECIS.             ³±±
±±³          ³cSeries -> Serie validas na geracao do arquivo magnetico.   ³±±
±±³          ³cEspecs -> Especies validas na geracao do arquivo magnetico.³±±
±±³          ³lMVISSST -> Conteudo do parametro MV_ISSST.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function DMSCX(nOpc,aDelArqs,lMVF3RECIS,cSeries,cEspecs,lMVISSST)
Local	aStru		:=	{}
Local	cArq		:=	""
Local	nI			:=	0
Local	cES			:=	""
Local	cFormIss	:=	""
Local	cRecIss		:=	""
Local	cAtividade	:=	""
Local	aSf3		:=	{}

#IFDEF TOP
	Local	cQuery	:=	""
	Local	cAls	:=	"TOP"
#ENDIF

If nOpc==2
	For nI:= 1 To Len(aDelArqs)
		If File(aDelArqs[nI,1]+GetDBExtension())
			dbSelectArea(aDelArqs[nI,2])
			dbCloseArea()
			Ferase(aDelArqs[nI,1]+GetDBExtension())
			Ferase(aDelArqs[nI,1]+OrdBagExt())
		Endif	
	Next
Else
	aAdd(aStru,{"TRB_INDICE",	"C",	010,	0})
	aAdd(aStru,{"TRB_ES",		"C",	001,	0})
	aAdd(aStru,{"TRB_ESPECI",	"C",	005,	0})
	aAdd(aStru,{"TRB_SERIE",		"C",	TamSx3("F3_SERIE")[1],	0})
	aAdd(aStru,{"TRB_NUMERO",	"C",	010,	0})
	aAdd(aStru,{"TRB_STATUS",	"C",	001,	0})
	aAdd(aStru,{"TRB_CNPJ_P",	"C",	015,	0})
	aAdd(aStru,{"TRB_CNPJ_T",	"C",	015,	0})
	aAdd(aStru,{"TRB_EMISSA",	"C",	010,	0})
	aAdd(aStru,{"TRB_VALOR",		"N",	017,	2})
	aAdd(aStru,{"TRB_DEDUCA",	"N",	017,	2})
	aAdd(aStru,{"TRB_ALIQ",		"N",	005,	2})
	aAdd(aStru,{"TRB_RETIDO",	"C",	001,	0})
	aAdd(aStru,{"TRB_ATIVID",	"C",	008,	0})
	aAdd(aStru,{"TRB_SDOC",		"C",	005,	0})
	
	cArq	:=	CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"TRB")
	IndRegua("TRB",cArq,"TRB_INDICE+TRB_ES")
	
	#IFDEF TOP
		cQuery	:=	"SELECT COUNT(SF3.F3_FILIAL) CTDREG FROM "+RetSqlName("SF3")+" SF3 WHERE F3_FILIAL='"+xFilial ("SF3")+"' AND F3_EMISSAO>='"+DToS (MV_PAR01)+"' AND F3_EMISSAO<='"+DToS (MV_PAR02) + "' AND F3_TIPO='S' AND D_E_L_E_T_=' ' "
		DbUseArea (.T., "TOPCONN", TcGenQry (,,cQuery), cAls)

		ProcRegua ((cAls)->CTDREG)

		DbSelectArea (cAls)
		(cAls)->(dbCloseArea ())
	#ELSE
		ProcRegua (SF3->(LastRec()))
		SF3->(dbGotop())
	#ENDIF

	While !SF3->(Eof())
		//Escrituracao por nota para gerar o arquivo de trabalho em seguida.
		If Len(aSf3)==0 .Or. SF3->(F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA)==aSf3[1,1]+aSf3[1,2]+aSf3[1,3]+aSf3[1,4]+aSf3[1,5]
			aAdd(aSf3, {SF3->F3_FILIAL,;  										//	01
			SF3->F3_SERIE,;		   											//	02
			SF3->F3_NFISCAL,;		 											//	03
			SF3->F3_CLIEFOR,;	 												//	04
			SF3->F3_LOJA,;		 											//	05
			SF3->F3_ESPECIE,;	  												//	06
			SF3->F3_ALIQICM,;	 												//	07
			SF3->F3_DTCANC,;	   												//	08
			SF3->F3_OBSERV,;		 											//	09
			SF3->F3_EMISSAO,;													//	10
			SF3->F3_BASEICM,;													//	11
			SF3->F3_ISSSUB,;	//	12
			SF3->F3_ISSMAT,;	//	13
			SF3->F3_CFO,;			  											//	14
			SF3->F3_RECISS,;													//	15
			SF3->F3_ISSST,; 	//	16
			SerieNfId("SF3",2,"F3_SERIE")})									// 	17
			
			SF3->(dbSkip())
			IncProc()
			If !SF3->(Eof())
				Loop
			EndIf
		EndIf

	 	aSort(aSf3,,,{|x,y| x[7]>y[7]})
		For nI := 1 To Len(aSf3)
			cES := Iif(Left(aSf3[nI,14],1)>="5","S","E")
	
			//Posicionando SA2-Fornecedor quando for entrada ou SA1-Cliente quando for saida
			If cES=="S"
				SA1->(dbSeek(xFilial("SA1")+aSf3[nI,4]+aSf3[nI,5]))
			Else
				SA2->(dbSeek(xFilial("SA2")+aSf3[nI,4]+aSf3[nI,5]))
			EndIf
			
			//Tratamento para o _RECISS
			cRecIss	:=	Iif(cES=="S", SA1->A1_RECISS, SA2->A2_RECISS)
			cRecIss	:=	Iif(lMVF3RECIS, aSf3[nI,15], cRecIss)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|               Tratamento para retencao do ISS.                  |
			//|                                                                 |
			//³Layout diz que quando for saida temos retencao dentro ou fora do ³
			//³   municipio. Layout nao diz a mesma regra na entrada, ou seja,  ³
			//³   sempre sera dentro do municipio.                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lMVISSST	//Podemos utilizar o parametro MV_ISSST para indicar se o pagamento do ISS eh dentro do municipio ou fora. Com este campo, 
						//	mesmo que o servico seja prestado fara do municipio, pode-se indicar que o pagamento serah dentro ou fora do municipio
						//	do prestador de servico.
				cFormIss	:=	Iif(cES=="S",Iif(cRecIss$"1S", Iif(aSf3[nI,16]=="1","M","F"),"N"), "")
				cFormIss	:=	Iif(cES=="E",Iif(cRecIss$"2N",Iif(aSf3[nI,16]=="1","M",""),"N"), cFormIss)
				
			Else	//Podemos utilizar o campo A1_MUN para indicar se o pagamento do ISS eh dentro do municipio ou nao. Neste caso assumimos que o 
					//	municipio onde o servico estah sendo prestado eh o municipio de pagamento do ISS.
				cFormIss	:=	Iif(cES=="S",Iif(cRecIss$"1S", Iif("CAXIAS DO SUL"$SA1->A1_MUN,"M","F"),"N"), "")
				cFormIss	:=	Iif(cES=="E",Iif(cRecIss$"2N", Iif("CAXIAS DO SUL"$SA2->A2_MUN,"M",""),"N"),cFormIss)
			EndIf
	
			cAtividade	:=	Iif(cES=="S",AllTrim(SA1->A1_ATIVIDA),"0")
		
			If !Empty(cFormIss)
				RecLock("TRB",.T.)
				TRB->TRB_INDICE	:=	StrZero(TRB->(Recno()),10)
				TRB->TRB_ES		:=	cES
	
				If nI>1
					TRB->TRB_ESPECI	:=	"ND"
					TRB->TRB_SERIE	:=	"ND"
					TRB->TRB_SDOC		:=	"ND"
				Else
					TRB->TRB_ESPECI	:=	Iif(","+AllTrim(aSf3[nI,6])+","$cEspecs, aSf3[nI,6], "ND")
					TRB->TRB_SERIE	:=	Iif(","+AllTrim(aSf3[nI,2])+","$cSeries, aSf3[nI,2], Iif(Empty(aSf3[nI,2]),"S/S", "ND"))
					TRB->TRB_SDOC 	:=	Iif(","+AllTrim(aSf3[nI,17])+","$cSeries, aSf3[nI,17], Iif(Empty(aSf3[nI,17]),"S/S", "ND"))
				EndIf
	
				TRB->TRB_NUMERO	:=	aSf3[nI,3]
				TRB->TRB_STATUS	:=	Iif(Empty(aSf3[nI,8]) .And. !"CANCELAD"$aSf3[nI,9],"N","C")
				TRB->TRB_CNPJ_P	:=	Iif(cES=="S",SM0->M0_CGC,SA2->A2_CGC)
				TRB->TRB_CNPJ_T	:=	Iif(cES=="S",SA1->A1_CGC,SM0->M0_CGC)
				TRB->TRB_EMISSA	:=	StrZero(Day(aSf3[nI,10]),2)+"/"+StrZero(Month(aSf3[nI,10]),2)+"/"+StrZero(Year(aSf3[nI,10]),4)
				TRB->TRB_VALOR	:=	Iif(TRB->TRB_STATUS=="C",0,aSf3[nI,11])
				TRB->TRB_DEDUCA	:=	aSf3[nI,12]+aSf3[nI,13]
				TRB->TRB_ALIQ	:=	aSf3[nI,7]
				TRB->TRB_RETIDO	:=	cFormIss
				TRB->TRB_ATIVID	:=	cAtividade
				MsUnLock()	
			EndIf
		Next nI
		
		aSf3	:=	{}
	End
EndIf
Return ({{cArq,"TRB"}})
