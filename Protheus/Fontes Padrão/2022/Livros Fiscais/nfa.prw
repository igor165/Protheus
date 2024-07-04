#Include "nfa.ch" 
#Include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �NFA       � Autor �  Roberto Souza        � Data � 17.06.09 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Nota Fiscal Alagoana                                  	  ���
���          �      													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpD -> Data incial do periodo - mv_par01     			  ���
���          �ExpD -> Data final do periodo - mv_par02                    ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function NFA()
	Local aTrbs		:= {}
	Private aCfp 	:= {}
    Private aStru10 := {}
    Private aStru20 := {}
    Private aStru21 := {}
    Private aStru22 := {}        	
    Private aStru90 := {}    
	Private nQuant20:= 0
	Private nQuant21:= 0
	Private nQuant22:= 0
	Private nTotal20:= 0			
	Private lCancel := .F.
	//�����������������������������������������Ŀ
	//�Carrega os parametros atrav�s da LoadCfp �
	//�������������������������������������������
	If LoadCfp()
		//������������������������������������������������������������������������Ŀ
		//�Recupera dados do arquivo Cfp                                           �
		//��������������������������������������������������������������������������
		xMagLeWiz("NFA",@aCfp,.T.)
		//�������������������������������������Ŀ
		//�Gera arquivos temporarios            �
		//���������������������������������������
		aTrbs := GeraTemp()
		Processa({||ProcNFA() })
		
	Endif
	IncProc(STR0001) //"Apagando dados tempor�rios..."

	NfaDel(aTrbs)
Return()

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ProcNFA    � Autor �Roberto Souza          � Data � 07.02.06 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Processa Registro da NFA                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function ProcNFA()

Local DtAIni  := Stod(aCfp[1][01])
Local DtAFim  := Stod(aCfp[1][02])
Local cDir    := AllTrim(aCfp[1][03])
Local cArqTxt := AllTrim(aCfp[1][04])
 
//������������������������������������������������������������������������Ŀ
//�Processa Regitros                                                       �
//��������������������������������������������������������������������������
ProcRegua(-1)

ProcReg10(DtAIni, DtAFim)
ProcReg20(DtAIni, DtAFim)
ProcReg21(DtAIni, DtAFim)


 
//--------------------------------------------------------//
// Verifica se diret�rio contem barra para designar pasta //
//--------------------------------------------------------//
If Substr(cDir,(Len(cDir)-1),1) <> "\"
	cDir += "\"
EndIf
//--------------------------------------------------------//
// Se diret�rio n�o existir, cria                         //
//--------------------------------------------------------//
If !ExistDir(cDir)
	Makedir(cDir)
EndIf
//--------------------------------------------------------//
// Cria o Arquivo //
//--------------------------------------------------------//
nArq1 := MSFCREATE(cDir+cArqTxt)

GravaArq("10",aStru10)
GravaArq("20",aStru20)

ProcReg90(DtAIni, DtAFim)  
GravaArq("90",aStru90)


fClose(nArq1)  

If Len(Memoread(cDir+cArqTxt)) >= 500000
	cMensagem := ""
    cMensagem += STR0035 //"Arquivo muito grande para ser transmitido."+CRLF
    cMensagem += STR0036 // "Diminua o periodo de gera��o e tente gerar novamente."
	Aviso("NFA",cMensagem,{STR0014})	
EndIf	


If lCancel
	MsgInfo(STR0002)//"Opera��o Cancelada!"
Else
	MsgInfo(STR0003 + cDir+cArqTxt)//"Arquivo gerado com sucesso em "
EndIf
Return Nil


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ProcReg10  � Autor �Roberto Souza          � Data � 17.06.09 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Processa Registro Tipo 10                                    ���
���			 �                                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function ProcReg10(dDtInicial, dDtFinal)

	RecLock("RT10",.T.)
	RT10->TIPOREG := "10"
	RT10->VERSAO  := aCfp[1][05]
	RT10->CNPJ    := StrZero(Val(GravaCpo(SM0->M0_CGC)),14)
	RT10->DATAINI := GravaCpo(dDtInicial)
	RT10->DATAFIM := GravaCpo(dDtFinal)
	MsUnlock()

Return Nil


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ProcReg20  � Autor �Roberto Souza          � Data � 17.06.09 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Processa Registro Tipo 20                                    ���
���			 �                                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function ProcReg20(dDtInicial, dDtFinal)

Local cAlias20  := ""
Local lQuery 	:= .F.
Local cQuery 	:= ""
Local cSerIni   := AllTrim(aCfp[2][01])
Local cNFIni    := AllTrim(aCfp[2][02])
Local cSerFim   := AllTrim(aCfp[2][03])
Local cNFFim    := AllTrim(aCfp[2][04])
Local cSerie1   := AllTrim(aCfp[3][01])
Local cSerie2   := AllTrim(aCfp[3][02])
Local cSerie3   := AllTrim(aCfp[3][03])
Local cSerDoc   := "3"
Local cVdaPrazo := Iif(Substr(aCfp[3][07],1,1)=="S","1","2")
Local cEntDom   := Iif(Substr(aCfp[3][08],1,1)=="S","1","2")

Local cSerieId	:= SerieNfId("SF2",3,"F2_SERIE")

If Empty(cSerie1) .Or. Empty(cSerie2) .Or. Empty(cSerie3)

	cAviso := STR0004 + CRLF+CRLF
	cAviso += STR0005 + cSerie1 +CRLF
	cAviso += STR0006 + cSerie2 +CRLF
	cAviso += STR0007 + cSerie3 +CRLF+CRLF
	cAviso += STR0008 + STR0009  + cSerDoc+CRLF
	cAviso += Replicate("#",150)
	If Aviso(STR0016 ,cAviso,{STR0010 ,STR0011 }) == 1
		lCancel:= .T.
    	Return(Nil)
	EndIf
EndIf

#IFDEF TOP

    If TcSrvType()<>"AS/400"

		lQuery 		:= .T.
		cAlias20	:= GetNextAlias()   
        
		cQuery += " SELECT SF2.F2_FILIAL
		cQuery += " ,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_CLIENTE,SF2.F2_LOJA,SF2.F2_COND,SF2.F2_DUPL,SF2.F2_EMISSAO,SF2.F2_EST,SF2.F2_FRETE,SF2.F2_SEGURO"
		cQuery += " ,SF2.F2_ICMFRET,SF2.F2_TIPOCLI,SF2.F2_VALBRUT,SF2.F2_VALMERC,SF2.F2_DESCONT,SF2.F2_TIPO,SF2.F2_TRANSP,SF2.F2_DTLANC"
		cQuery += " ,SF2.F2_DESPESA,SF2.F2_ESPECIE,SF2.F2_PREFIXO,SF2.F2_TIPODOC,SF2.F2_DTDIGIT,SF2.F2_CLIENT,SF2.F2_LOJENT"

		If cSerieId == "F2_SDOC"
			cQuery += " ,SF2.F2_SDOC"
		EndIf

		cQuery += " ,A1_NOME,A1_PESSOA,A1_END,A1_EST,A1_MUN,A1_BAIRRO,A1_ESTADO,A1_CEP,A1_DDD,A1_TEL,A1_CGC,A1_INSCR"
		cQuery += " FROM "
		cQuery += RetSqlName("SF2") + " SF2,"
		cQuery += RetSqlName("SA1") + " SA1 "		
		cQuery += " WHERE "
		cQuery += " SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "
		cQuery += " SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
		cQuery += " SF2.F2_CLIENTE = SA1.A1_COD AND SF2.F2_LOJA = SA1.A1_LOJA AND"
		cQuery += " SF2.F2_EMISSAO >= '"+Dtos(dDtInicial)+"' AND "
		cQuery += " SF2.F2_EMISSAO <= '"+Dtos(dDtFinal)  +"' AND "

		If cSerieId == "F2_SDOC"
			cQuery += " (SF2.F2_SDOC BETWEEN '"+cSerIni+"' AND '"+cSerFim+"') AND " 		
		Else
			cQuery += " (SF2.F2_SERIE BETWEEN '"+cSerIni+"' AND '"+cSerFim+"') AND " 		
		EndIf

		cQuery += " (SF2.F2_DOC BETWEEN '"+cNFIni+"' AND '"+cNFFim+"') AND " 		
		cQuery += " SF2.F2_TIPO NOT IN ('D','B') AND "
		cQuery += " SF2.D_E_L_E_T_='' AND "
		cQuery += " SA1.D_E_L_E_T_=''"
		cQuery += " ORDER BY F2_EMISSAO,F2_DOC,F2_SERIE"
	
		cQuery := ChangeQuery(cQuery)                       
        
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias20,.T.,.T.)
		
		TcSetField(cAlias20,"F2_EMISSAO","D",8,0)

		DbSelectArea(cAlias20)

	Else
#ELSE

	dbSelectArea("SF2")
	cIndSF2	:=	CriaTrab(NIL,.F.)
	cChave	:=	IndexKey()
	cFiltro	:=	"SF2->F2_FILIAL=='"+xFilial("SF2")+"' .And. DTOS(SF2->F2_EMISSAO)>='"+Dtos(dDtInicial)+"' .AND. DTOS(SF2->F2_EMISSAO)<='"+Dtos(dDtFinal)+"'"						
	cFiltro	+=  " .And. SF2->F2_SERIE >= '"+cSerIni+"'"
	cFiltro	+=  " .And. SF2->F2_SERIE <= '"+cSerFim+"'" 		
	cFiltro	+=  " .And. SF2->F2_DOC >= '"+cNFIni+"'"
	cFiltro	+=  " .And. SF2->F2_DOC <= '"+cNFFim+"'" 		
	cFiltro	+=  " .And. SF2->F2_TIPO !$ 'DB'"
 
	IndRegua("SF2",cIndSF2,cChave,,cFiltro)
	SF2->(DbgoTop()) 

#ENDIF

#IFDEF TOP
	Endif    

	Do While ! (cAlias20)->(Eof())
		DbSelectArea("RT20")
		
		If	SerieNfId(cAlias20,2,"F2_SERIE") $ cSerie1
			cSerDoc := "1"		
		ElseIf SerieNfId(cAlias20,2,"F2_SERIE") $ cSerie2
			cSerDoc := "2"		
		ElseIf SerieNfId(cAlias20,2,"F2_SERIE") $ cSerie3
			cSerDoc := "3"		
		EndIf

		If AllTrim((cAlias20)->F2_CLIENT) == "" .And. AllTrim((cAlias20)->F2_LOJENT) == ""
            
			If DbSeek(xFilial("SA1")+ (cAlias20)->F2_CLIENT + (cAlias20)->F2_LOJENT)
				cEndEnt := (FisGetEnd(SA1->A1_END)[1])
				cNumEnt	:= IIF(FisGetEnd(SA1->A1_END)[2]<>0, AllTrim(Str(FisGetEnd(SA1->A1_END)[2])) ,"SN") 
				cCompEnt:= FisGetEnd( SA1->A1_END )[4]  
				cBairEnt:= AllTrim(SA1->A1_BAIRRO)
				cMunEnt := AllTrim(SA1->A1_MUN)
				cUfEnt  := AllTrim(SA1->A1_EST)
			Else			
				cEndEnt := cNumEnt := cCompEnt := cBairEnt := cMunEnt := cUfEnt := ""
			EndIf
		Else
			cEndEnt := cNumEnt := cCompEnt := cBairEnt := cMunEnt := cUfEnt := ""
		EndIf        


		RecLock("RT20",.T.)

		RT20->TIPOREG		:= "20"
		RT20->SERIEDOC		:= GravaCpo((cAlias20)->F2_SERIE)
		RT20->CLIENTE		:= GravaCpo((cAlias20)->F2_CLIENTE)
		RT20->LOJA			:= GravaCpo((cAlias20)->F2_LOJA)
		RT20->SERIE         := GravaCpo(cSerDoc)
		RT20->SUBSERIE      := GravaCpo(" ")
		RT20->NUMERO        := GravaCpo((cAlias20)->F2_DOC)		//
		RT20->DTEMISS		:= GravaCpo((cAlias20)->F2_EMISSAO)	//"       ,"C",010,0})
		RT20->DTSAIDA		:= GravaCpo((cAlias20)->F2_EMISSAO)	//"       ,"C",010,0})
		RT20->CPFCNPJ		:= GravaCpo((cAlias20)->A1_CGC)		//"       ,"C",014,0})
		RT20->NOMEDEST		:= GravaCpo((cAlias20)->A1_NOME)		//"      ,"C",060,0})//	Nome do destinat�rio
		RT20->LOGRADOURO	:= GravaCpo( FisGetEnd( (cAlias20)->A1_END )[1] )
		RT20->NUMEND		:= IIF(FisGetEnd((cAlias20)->A1_END)[2]<>0, AllTrim(Str(FisGetEnd((cAlias20)->A1_END)[2])) ,"SN") 
		RT20->COMPL			:= GravaCpo(FisGetEnd( (cAlias20)->A1_END )[4] ) 
		RT20->BAIRRO		:= GravaCpo((cAlias20)->A1_BAIRRO)		//"        ,"C",060,0})//	Bairro / Distrito
		RT20->MUNICPIO		:= GravaCpo((cAlias20)->A1_MUN)		//"      ,"C",060,0})// Munic�pio
		RT20->UF			:= GravaCpo((cAlias20)->A1_EST)		//"            ,"C",002,0})// UF
		RT20->CEP			:= GravaCpo((cAlias20)->A1_CEP)		//"           ,"C",008,0})//	CEP
		RT20->TELEFONE		:= GravaCpo( Strzero(Val((cAlias20)->A1_DDD),2)+AllTrim(Str(FisGetTel((cAlias20)->A1_TEL)[3]))    )		//"      ,"C",010,0})// Telefone
		RT20->VALTOT		:= GravaCpo((cAlias20)->F2_VALMERC)	//"        ,"C",015,2})// Valor total dos produtos
		RT20->VALDESC		:= GravaCpo((cAlias20)->F2_DESCONT)	//"       ,"C",015,2})// Valor total do desconto
		RT20->VALFRETE		:= GravaCpo((cAlias20)->F2_FRETE)		//"      ,"C",015,2})//	Valor total do frete
		RT20->VALSEGURO		:= GravaCpo((cAlias20)->F2_SEGURO)		//"     ,"C",015,2})// Valor total do seguro
		RT20->VALDESPESA	:= GravaCpo((cAlias20)->F2_DESPESA)	//"    ,"C",015,2})// Outras despesas acess�rias
		RT20->DESCDESP		:= GravaCpo(" ") 						//	Descri��o das outras despesas acess�rias
		RT20->TOTNF			:= GravaCpo((cAlias20)->F2_VALBRUT)	//	Valor total da NFVC
		RT20->INFOCOMP		:= GravaCpo(" ")						// 	Informa��es complementares do interesse do contribuinte
		RT20->INFOFISCO		:= GravaCpo(" ")						//	Informa��es complementares de interesse do fisco
		RT20->ENTREGA		:= cEntDom 								//	Realiza entrega em domic�lio
		RT20->LOGRENTR		:= GravaCpo(cEndEnt)					//	Logradouro do local de entrega	-	60	Alfanum�rico	N�o	Texto livre
		RT20->NUMENTR		:= GravaCpo(cNumEnt)					//	N�mero do local de entrega	-	60	Alfanum�rico	N�o	Texto livre
		RT20->COMPLENTR		:= GravaCpo(cCompEnt)					//	Complemento do local de entrega	-	60	Alfanum�rico	N�o	Texto livre
		RT20->BAIRROENTR	:= GravaCpo(cBairEnt)					//  Bairro / Distrito do local de entrega	-	60	Alfanum�rico	N�o	Texto livre
		RT20->MUNENTR		:= GravaCpo(cMunEnt) 					//	Munic�pio do local de entrega	-	60	Alfanum�rico	N�o	Texto livre
		RT20->UFENTR		:= GravaCpo(cUfEnt)						//  UF do local de entrega	-	2	Alfanum�rico	N�o	 
		RT20->VENDAPRAZO	:= cVdaPrazo 							//  Realiza venda a prazo	1	 	Num�rico	Sim	Preencher com valor "1" para resposta afirmativa ou valor "2" para resposta negativa
		RT20->PRECOVISTA	:= GravaCpo(" ")						//	Pre�o � vista	2 (casas decimais)	15 (antes da v�rgula)	Num�rico	N�o	Valor da venda � vista
		RT20->PRECOFINAL	:= GravaCpo(" ")						//	Pre�o final			Num�rico	N�o	Valor do pre�o final na venda a prazo
		RT20->PARCELAS		:= "" 									//	Quantidade de parcelas nas vendas a prazo	-	2	Num�rico	N�o	Indicar a quantidade de parcelas. Preencher apenas com n�mero INTEIRO, sem v�rgula.
	
		RT20->(MsUnlock())
		
		IncProc()
        nTotal20 += (cAlias20)->F2_VALBRUT

		(cAlias20)->(dbSkip())  				
	EndDo

#ELSE

	Do While !SF2->(Eof())
		DbSelectArea("RT20")
		
		If SerieNfId("SF2",2,"F2_SERIE") $ cSerie1
			cSerDoc := "1"		
		ElseIf SerieNfId("SF2",2,"F2_SERIE") $ cSerie2
			cSerDoc := "2"		
		ElseIf SerieNfId("SF2",2,"F2_SERIE") $ cSerie3
			cSerDoc := "3"		
		EndIf
        
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbGoTop()
		If AllTrim(SF2->F2_CLIENT) == "" .And. AllTrim(SF2->F2_LOJENT) == ""
            
			If DbSeek(xFilial("SA1")+ SF2->F2_CLIENT + SF2->F2_LOJENT)
				cEndEnt := (FisGetEnd(SA1->A1_END)[1])
				cNumEnt	:= IIF(FisGetEnd(SA1->A1_END)[2]<>0, AllTrim(Str(FisGetEnd(SA1->A1_END)[2])) ,"SN") 
				cCompEnt:= FisGetEnd( SA1->A1_END )[4]  
				cBairEnt:= AllTrim(SA1->A1_BAIRRO)
				cMunEnt := AllTrim(SA1->A1_MUN)
				cUfEnt  := AllTrim(SA1->A1_EST)
			Else			
				cEndEnt := cNumEnt := cCompEnt := cBairEnt := cMunEnt := cUfEnt := ""
			EndIf
		Else
			cEndEnt := cNumEnt := cCompEnt := cBairEnt := cMunEnt := cUfEnt := ""
		EndIf        

		DbSeek(xFilial("SA1")+ SF2->F2_CLIENTE + SF2->F2_LOJA)
		
		RecLock("RT20",.T.)

		RT20->TIPOREG		:= "20"
		RT20->SERIEDOC		:= GravaCpo(SF2->F2_SERIE)
		RT20->CLIENTE		:= GravaCpo(SF2->F2_CLIENTE)
		RT20->LOJA			:= GravaCpo(SF2->F2_LOJA)
		RT20->SERIE         := GravaCpo(cSerDoc)
		RT20->SUBSERIE      := GravaCpo(" ")
		RT20->NUMERO        := GravaCpo(SF2->F2_DOC)		//
		RT20->DTEMISS		:= GravaCpo(SF2->F2_EMISSAO)	//"       ,"C",010,0})
		RT20->DTSAIDA		:= GravaCpo(SF2->F2_EMISSAO)	//"       ,"C",010,0})
		RT20->CPFCNPJ		:= GravaCpo(SA1->A1_CGC)		//"       ,"C",014,0})
		RT20->NOMEDEST		:= GravaCpo(SA1->A1_NOME)		//"      ,"C",060,0})//	Nome do destinat�rio
		RT20->LOGRADOURO	:= GravaCpo( FisGetEnd( SA1->A1_END )[1] )
		RT20->NUMEND		:= IIF(FisGetEnd(SA1->A1_END)[2]<>0, AllTrim(Str(FisGetEnd(SA1->A1_END)[2])) ,"SN") 
		RT20->COMPL			:= GravaCpo(FisGetEnd( SA1->A1_END )[4] ) 
		RT20->BAIRRO		:= GravaCpo(SA1->A1_BAIRRO)		//"        ,"C",060,0})//	Bairro / Distrito
		RT20->MUNICPIO		:= GravaCpo(SA1->A1_MUN)		//"      ,"C",060,0})// Munic�pio
		RT20->UF			:= GravaCpo(SA1->A1_EST)		//"            ,"C",002,0})// UF
		RT20->CEP			:= GravaCpo(SA1->A1_CEP)		//"           ,"C",008,0})//	CEP
		RT20->TELEFONE		:= GravaCpo( Strzero(Val(SA1->A1_DDD),2)+AllTrim(Str(FisGetTel(SA1->A1_TEL)[3])) )		//"      ,"C",010,0})// Telefone
		RT20->VALTOT		:= GravaCpo(SF2->F2_VALMERC)	//"        ,"C",015,2})// Valor total dos produtos
		RT20->VALDESC		:= GravaCpo(SF2->F2_DESCONT)	//"       ,"C",015,2})// Valor total do desconto
		RT20->VALFRETE		:= GravaCpo(SF2->F2_FRETE)		//"      ,"C",015,2})//	Valor total do frete
		RT20->VALSEGURO		:= GravaCpo(SF2->F2_SEGURO)		//"     ,"C",015,2})// Valor total do seguro
		RT20->VALDESPESA	:= GravaCpo(SF2->F2_DESPESA)	//"    ,"C",015,2})// Outras despesas acess�rias
		RT20->DESCDESP		:= GravaCpo(" ") 						//	Descri��o das outras despesas acess�rias
		RT20->TOTNF			:= GravaCpo(SF2->F2_VALBRUT)	//	Valor total da NFVC
		RT20->INFOCOMP		:= GravaCpo(" ")						// 	Informa��es complementares do interesse do contribuinte
		RT20->INFOFISCO		:= GravaCpo(" ")						//	Informa��es complementares de interesse do fisco
		RT20->ENTREGA		:= cEntDom 								//	Realiza entrega em domic�lio
		RT20->LOGRENTR		:= GravaCpo(cEndEnt)					//	Logradouro do local de entrega	-	60	Alfanum�rico	N�o	Texto livre
		RT20->NUMENTR		:= GravaCpo(cNumEnt)					//	N�mero do local de entrega	-	60	Alfanum�rico	N�o	Texto livre
		RT20->COMPLENTR		:= GravaCpo(cCompEnt)					//	Complemento do local de entrega	-	60	Alfanum�rico	N�o	Texto livre
		RT20->BAIRROENTR	:= GravaCpo(cBairEnt)					//  Bairro / Distrito do local de entrega	-	60	Alfanum�rico	N�o	Texto livre
		RT20->MUNENTR		:= GravaCpo(cMunEnt) 					//	Munic�pio do local de entrega	-	60	Alfanum�rico	N�o	Texto livre
		RT20->UFENTR		:= GravaCpo(cUfEnt)						//  UF do local de entrega	-	2	Alfanum�rico	N�o	 
		RT20->VENDAPRAZO	:= cVdaPrazo 							//  Realiza venda a prazo	1	 	Num�rico	Sim	Preencher com valor "1" para resposta afirmativa ou valor "2" para resposta negativa
		RT20->PRECOVISTA	:= GravaCpo(" ")						//	Pre�o � vista	2 (casas decimais)	15 (antes da v�rgula)	Num�rico	N�o	Valor da venda � vista
		RT20->PRECOFINAL	:= GravaCpo(" ")						//	Pre�o final			Num�rico	N�o	Valor do pre�o final na venda a prazo
		RT20->PARCELAS		:= "" 									//	Quantidade de parcelas nas vendas a prazo	-	2	Num�rico	N�o	Indicar a quantidade de parcelas. Preencher apenas com n�mero INTEIRO, sem v�rgula.
	
		RT20->(MsUnlock())
		
		IncProc()
        nTotal20 += SF2->F2_VALBRUT

		SF2->(dbSkip())  				
	EndDo

#ENDIF

	//���������������������������������������Ŀ
	//�Exclui area de trabalho utilizada - SF2�
	//�����������������������������������������

	If lQuery
		dbSelectArea(cAlias20)
		dbCloseArea()
	ElSE
		RetIndex("SF2")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Endif

Return Nil



/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ProcReg21  � Autor �Roberto Souza          � Data � 17.06.09 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Processa Registro Tipo 21                                    ���
���			 �                                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function ProcReg21(dDtInicial, dDtFinal)
Local cAlias21  := ""
Local lQuery 	:= .F.
Local cQuery 	:= ""
Local cSerIni   := AllTrim(aCfp[2][01])
Local cNFIni    := AllTrim(aCfp[2][02])
Local cSerFim   := AllTrim(aCfp[2][03])
Local cNFFim    := AllTrim(aCfp[2][04])
Local cRec1     := AllTrim(aCfp[3][04])
Local cRec2     := AllTrim(aCfp[3][05])
Local cRec3     := AllTrim(aCfp[3][06])

Local cSerieId	:= SerieNfId("SD2",3,"D2_SERIE")

#IFDEF TOP

    If TcSrvType()<>"AS/400"

		lQuery 		:= .T.
		cAlias21	:= GetNextAlias()   
        
		cQuery += " SELECT SD2.D2_FILIAL
		cQuery += " ,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_EMISSAO"
		cQuery += " ,SD2.D2_COD,SD2.D2_CF,SD2.D2_ITEM,SD2.D2_QUANT,SD2.D2_PRCVEN,SD2.D2_TOTAL"

		If cSerieId == "D2_SDOC"
			cQuery += " ,SD2.D2_SDOC"
		EndIf

		cQuery += " ,B1_FILIAL,B1_COD,B1_DESC,B1_UM"
		cQuery += " FROM "
		cQuery += RetSqlName("SD2") + " SD2,"
		cQuery += RetSqlName("SB1") + " SB1 "		
		cQuery += " WHERE "
		cQuery += " SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND "
		cQuery += " SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
		cQuery += " SD2.D2_EMISSAO >='"+Dtos(dDtInicial)+ "' AND "
		cQuery += " SD2.D2_EMISSAO <='"+Dtos(dDtFinal)  + "' AND "
		cQuery += " SD2.D2_COD = B1_COD AND "
		cQuery += " SD2.D2_TIPO NOT IN ('D','B') AND "

		If cSerieId == "D2_SDOC"
			cQuery += " (SD2.D2_SDOC BETWEEN '"+cSerIni+"' AND '"+cSerFim+"') AND " 		
		Else
			cQuery += " (SD2.D2_SERIE BETWEEN '"+cSerIni+"' AND '"+cSerFim+"') AND " 		
		EndIf

		cQuery += " (SD2.D2_DOC BETWEEN '"+cNFIni+"' AND '"+cNFFim+"') AND " 		
		cQuery += " SD2.D_E_L_E_T_='' AND "
		cQuery += " SB1.D_E_L_E_T_=''"
		cQuery += " ORDER BY D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_ITEM"
	
		cQuery := ChangeQuery(cQuery)                       
        
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias21,.T.,.T.)
		
		TcSetField(cAlias21,"D2_EMISSAO","D",8,0)

		DbSelectArea(cAlias21)

	Else
#ELSE


	dbSelectArea("SD2")
	cIndSD2	:=	CriaTrab(NIL,.F.)
	cChave	:=	IndexKey()
	cFiltro	:=	"SD2->D2_FILIAL=='"+xFilial("SD2")+"' .And. DTOS(SD2->D2_EMISSAO)>='"+Dtos(dDtInicial)+"' .AND. DTOS(SD2->D2_EMISSAO)<='"+Dtos(dDtFinal)+"'"						
	cFiltro	+=  " .And. SD2->D2_SERIE >= '"+cSerIni+"'"
	cFiltro	+=  " .And. SD2->D2_SERIE <= '"+cSerFim+"'" 		
	cFiltro	+=  " .And. SD2->D2_DOC >= '"+cNFIni+"'"
	cFiltro	+=  " .And. SD2->D2_DOC <= '"+cNFFim+"'" 		
	cFiltro	+=  " .And. SD2->D2_TIPO !$ 'DB'"
 
	IndRegua("SD2",cIndSD2,cChave,,cFiltro)
	SF2->(DbgoTop()) 


#ENDIF

#IFDEF TOP
	Endif    

	Do While ! (cAlias21)->(Eof())
		DbSelectArea("RT21")
		
		cReceita:= "1"
		Do Case
			Case (cAlias21)->D2_CF $ cRec1
				cReceita:= "1"
			Case (cAlias21)->D2_CF $ cRec2						
				cReceita:= "2"
			Case (cAlias21)->D2_CF $ cRec3		
				cReceita:= "3"
		EndCase
		
		RecLock("RT21",.T.)
		RT21->TIPOREG   := "21"     //"       ,"C",002,0})
		RT21->NUMITEM   := GravaCpo((cAlias21)->D2_ITEM)    //"       ,"C",003,0})//	N�mero do item	-	3	Num�rico	Sim	N�mero seq�encial dos itens informados 
		RT21->CODPROD   := GravaCpo((cAlias21)->D2_COD)    //"       ,"C",060,0})//	C�digo do produto	-	60	Alfanum�rico	N�o	C�digo interno utilizado pelo emitente, quando existir
		RT21->TIPOREC   := GravaCpo(cReceita)    //"       ,"C",001,0})//	Tipo de receita	1	-	Num�rico	Sim	Preencher com os seguintes valores:
		RT21->DESCPROD  := GravaCpo((cAlias21)->B1_DESC)    //"      ,"C",120,0})//	Descri��o da mercadoria	-	120	Alfanum�rico	Sim	Texto livre
		RT21->UNIDADE   := GravaCpo((cAlias21)->B1_UM)    //"       ,"C",006,0})//	Unidade de comercializa��o	-	6	Alfanum�rico	N�o	Texto livre
		RT21->QUANT     := GravaCpo((cAlias21)->D2_QUANT)    //"         ,"C",015,0})//	Quantidade	-	11 (antes da v�rgula) 3 (casas decimais)	Num�rico	Sim	Quantidade relativa � unidade de comercializa��o. Preencher com n�mero inteiro ou com 3 casas decimais (a utiliza��o da v�rgula � opcional). Ex.: "12" ou "12,000"
		RT21->VALUNIT   := GravaCpo((cAlias21)->D2_PRCVEN)    //"       ,"C",018,0})//	Valor unit�rio	2 (casas decimais)	15 (antes da v�rgula)	Num�rico	Sim	Preencher SEMPRE com duas casas decimais, inclusive para valor zero. Ex.: "15,00", "16,85", "2435,05", "101000,00", "0,00".
		RT21->VALTOT    := GravaCpo((cAlias21)->D2_TOTAL)    //"        ,"C",018,0})//	Valor total	2 (casas decimais)	15 (antes da v�rgula)	Num�rico	Sim	Deve corresponder ao resultado do c�lculo: Qtdd x valor unit�rio. Preencher SEMPRE com duas casas decimais, inclusive para valor zero. Ex.: "15,00", "16,85", "2435,05", "101000,00", "0,00". 
		RT21->DOC		:= GravaCpo((cAlias21)->D2_DOC)
		RT21->SERIE		:= GravaCpo((cAlias21)->D2_SERIE)
		RT21->CLIENTE	:= GravaCpo((cAlias21)->D2_CLIENTE)
		RT21->LOJA		:= GravaCpo((cAlias21)->D2_LOJA)
		MsUnlock()

		IncProc()
		(cAlias21)->(dbSkip())  				
	EndDo

#ELSE


	Do While ! SD2->(Eof())
		DbSelectArea("RT21")
		
		cReceita:= "1"
		Do Case
			Case SD2->D2_CF $ cRec1
				cReceita:= "1"
			Case SD2->D2_CF $ cRec2						
				cReceita:= "2"
			Case SD2->D2_CF $ cRec3		
				cReceita:= "3"
		EndCase
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+SD2->D2_COD)
		
		RecLock("RT21",.T.)
		RT21->TIPOREG   := "21"     //"       ,"C",002,0})
		RT21->NUMITEM   := GravaCpo(SD2->D2_ITEM)    //"       ,"C",003,0})//	N�mero do item	-	3	Num�rico	Sim	N�mero seq�encial dos itens informados 
		RT21->CODPROD   := GravaCpo(SD2->D2_COD)    //"       ,"C",060,0})//	C�digo do produto	-	60	Alfanum�rico	N�o	C�digo interno utilizado pelo emitente, quando existir
		RT21->TIPOREC   := GravaCpo(cReceita)    //"       ,"C",001,0})//	Tipo de receita	1	-	Num�rico	Sim	Preencher com os seguintes valores:
		RT21->DESCPROD  := GravaCpo(SB1->B1_DESC)    //"      ,"C",120,0})//	Descri��o da mercadoria	-	120	Alfanum�rico	Sim	Texto livre
		RT21->UNIDADE   := GravaCpo(SB1->B1_UM)    //"       ,"C",006,0})//	Unidade de comercializa��o	-	6	Alfanum�rico	N�o	Texto livre
		RT21->QUANT     := GravaCpo(SD2->D2_QUANT)    //"         ,"C",015,0})//	Quantidade	-	11 (antes da v�rgula) 3 (casas decimais)	Num�rico	Sim	Quantidade relativa � unidade de comercializa��o. Preencher com n�mero inteiro ou com 3 casas decimais (a utiliza��o da v�rgula � opcional). Ex.: "12" ou "12,000"
		RT21->VALUNIT   := GravaCpo(SD2->D2_PRCVEN)    //"       ,"C",018,0})//	Valor unit�rio	2 (casas decimais)	15 (antes da v�rgula)	Num�rico	Sim	Preencher SEMPRE com duas casas decimais, inclusive para valor zero. Ex.: "15,00", "16,85", "2435,05", "101000,00", "0,00".
		RT21->VALTOT    := GravaCpo(SD2->D2_TOTAL)    //"        ,"C",018,0})//	Valor total	2 (casas decimais)	15 (antes da v�rgula)	Num�rico	Sim	Deve corresponder ao resultado do c�lculo: Qtdd x valor unit�rio. Preencher SEMPRE com duas casas decimais, inclusive para valor zero. Ex.: "15,00", "16,85", "2435,05", "101000,00", "0,00". 
		RT21->DOC		:= GravaCpo(SD2->D2_DOC)
		RT21->SERIE		:= GravaCpo(SD2->D2_SERIE)
		RT21->CLIENTE	:= GravaCpo(SD2->D2_CLIENTE)
		RT21->LOJA		:= GravaCpo(SD2->D2_LOJA)
		MsUnlock()

		IncProc()
		SD2->(dbSkip())  				
	EndDo



#ENDIF

	//���������������������������������������Ŀ
	//�Exclui area de trabalho utilizada - SD2�
	//�����������������������������������������

	If lQuery
		dbSelectArea(cAlias21)
		dbCloseArea()
	ElSE
		RetIndex("SD2")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Endif

Return Nil


              

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ProcReg90  � Autor �Roberto Souza          � Data � 17.06.09 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Processa Registro Tipo 90                                    ���
���			 �                                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function ProcReg90(dDtInicial, dDtFinal)

	RecLock("RT90",.T.)
	RT90->TIPOREG := "90"
	RT90->QUANT20 := AllTrim(Str(nQuant20,5))
	RT90->QUANT21 := AllTrim(Str(nQuant21,5))
	RT90->QUANT22 := AllTrim(Str(nQuant22,5))
	RT90->TOTAL20 := AllTrim(StrTran(TRANSFORM(nTotal20,"999999999999999.99"),".",","))
	MsUnlock()

Return Nil




/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �GeraTemp   � Autor �Roberto Souza          � Data � 17.06.09 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Gera arquivos temporarios                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function GeraTemp()
	Local aTrbs		:= {}
	Local cArq		:= ""
	//���������������������������������������������������������������������������������������������������������������Ŀ
	//�RT10 - Registro Tipo 10 - Cabe�alho (obrigat�rio um registro por arquivo)  									  �
	//�����������������������������������������������������������������������������������������������������������������
	aStru10	:= {}
	cArq	:= ""
	
	AADD(aStru10,{"TIPOREG"	    ,"C",002,0})
	AADD(aStru10,{"VERSAO"    	,"C",004,0})
	AADD(aStru10,{"CNPJ"	   	,"C",014,0})
	AADD(aStru10,{"DATAINI"   	,"C",010,0})
	AADD(aStru10,{"DATAFIM"   	,"C",010,0})
	
	cArq := CriaTrab(aStru10)
	dbUseArea(.T.,__LocalDriver,cArq,"RT10")
	IndRegua("RT10",cArq,"TIPOREG")
	AADD(aTrbs,{cArq,"RT10"})


	//���������������������������������������������������������������������������������������������������������������Ŀ
	//�RT20 - Registro Tipo 20 - Registro da NFVC (obrigat�rio, no m�nimo, um registro por arquivo) 				  �
	//�����������������������������������������������������������������������������������������������������������������
	aStru20	:= {}
	cArq	:= ""
	
	AADD(aStru20,{"TIPOREG"       ,"C",002,0})
	AADD(aStru20,{"SERIE"         ,"C",001,0})
	AADD(aStru20,{"SUBSERIE"      ,"C",006,0})
	AADD(aStru20,{"NUMERO"        ,"C",009,0})
	AADD(aStru20,{"DTEMISS"       ,"C",010,0})
	AADD(aStru20,{"DTSAIDA"       ,"C",010,0})
	AADD(aStru20,{"CPFCNPJ"       ,"C",014,0})
	AADD(aStru20,{"NOMEDEST"      ,"C",060,0})//	Nome do destinat�rio
	AADD(aStru20,{"LOGRADOURO"    ,"C",060,0})//	Logradouro
	AADD(aStru20,{"NUMEND"        ,"C",060,0})// NUmero
	AADD(aStru20,{"COMPL"         ,"C",060,0})// Complemento
	AADD(aStru20,{"BAIRRO"        ,"C",060,0})//	Bairro / Distrito
	AADD(aStru20,{"MUNICPIO"      ,"C",060,0})// Munic�pio
	AADD(aStru20,{"UF"            ,"C",002,0})// UF
	AADD(aStru20,{"CEP"           ,"C",008,0})//	CEP
	AADD(aStru20,{"TELEFONE"      ,"C",010,0})// Telefone
	AADD(aStru20,{"VALTOT"        ,"C",018,0})// Valor total dos produtos
	AADD(aStru20,{"VALDESC"       ,"C",018,0})// Valor total do desconto
	AADD(aStru20,{"VALFRETE"      ,"C",018,0})//	Valor total do frete
	AADD(aStru20,{"VALSEGURO"     ,"C",018,0})// Valor total do seguro
	AADD(aStru20,{"VALDESPESA"    ,"C",018,0})// Outras despesas acess�rias
	AADD(aStru20,{"DESCDESP"      ,"C",060,0})//	Descri��o das outras despesas acess�rias
	AADD(aStru20,{"TOTNF"         ,"C",018,0})//	Valor total da NFVC
	AADD(aStru20,{"INFOCOMP"      ,"C",256,0})// Informa��es complementares do interesse do contribuinte
	AADD(aStru20,{"INFOFISCO"     ,"C",256,0})//	Informa��es complementares de interesse do fisco
	AADD(aStru20,{"ENTREGA"       ,"C",001,0})//	Realiza entrega em domic�lio
	AADD(aStru20,{"LOGRENTR"      ,"C",060,0})//	Logradouro do local de entrega	-	60	Alfanum�rico	N�o	Texto livre
	AADD(aStru20,{"NUMENTR"       ,"C",060,0})//	N�mero do local de entrega	-	60	Alfanum�rico	N�o	Texto livre
	AADD(aStru20,{"COMPLENTR"     ,"C",060,0})//	Complemento do local de entrega	-	60	Alfanum�rico	N�o	Texto livre
	AADD(aStru20,{"BAIRROENTR"    ,"C",060,0})//	Bairro / Distrito do local de entrega	-	60	Alfanum�rico	N�o	Texto livre
	AADD(aStru20,{"MUNENTR"       ,"C",060,0})//	Munic�pio do local de entrega	-	60	Alfanum�rico	N�o	Texto livre
	AADD(aStru20,{"UFENTR"        ,"C",002,0})//	UF do local de entrega	-	2	Alfanum�rico	N�o	 
	AADD(aStru20,{"VENDAPRAZO"    ,"C",001,0})//	Realiza venda a prazo	1	 	Num�rico	Sim	Preencher com valor "1" para resposta afirmativa ou valor "2" para resposta negativa
	AADD(aStru20,{"PRECOVISTA"    ,"C",018,0})//	Pre�o � vista	2 (casas decimais)	15 (antes da v�rgula)	Num�rico	N�o	Valor da venda � vista
	AADD(aStru20,{"PRECOFINAL"    ,"C",018,0})//	Pre�o final			Num�rico	N�o	Valor do pre�o final na venda a prazo
	AADD(aStru20,{"PARCELAS"      ,"C",002,0})//	Quantidade de parcelas nas vendas a prazo	-	2	Num�rico	N�o	Indicar a quantidade de parcelas. Preencher apenas com n�mero INTEIRO, sem v�rgula.
	/* Campos que n�o v�o para o arquivo*/
	AADD(aStru20,{"SERIEDOC"      ,"C",TamSx3("F2_SERIE")[1],0})
	AADD(aStru20,{"CLIENTE"       ,"C",006,0})
	AADD(aStru20,{"LOJA"          ,"C",002,0})	
	
	cArq := CriaTrab(aStru20)
	dbUseArea(.T.,__LocalDriver,cArq,"RT20")
	IndRegua("RT20",cArq,"TIPOREG")
	AADD(aTrbs,{cArq,"RT20"})

	//���������������������������������������������������������������������������������������������������������������Ŀ
	//�RT21 - Registro Tipo 21 - Itens da NFVC, modelo 2 (obrigat�rio, no m�nimo, um registro por NFVC)				  �
	//�����������������������������������������������������������������������������������������������������������������
	aStru21	:= {}
	cArq	:= ""
	
	AADD(aStru21,{"TIPOREG"       ,"C",002,0})
	AADD(aStru21,{"NUMITEM"       ,"C",003,0})//	N�mero do item	-	3	Num�rico	Sim	N�mero seq�encial dos itens informados 
	AADD(aStru21,{"CODPROD"       ,"C",060,0})//	C�digo do produto	-	60	Alfanum�rico	N�o	C�digo interno utilizado pelo emitente, quando existir
	AADD(aStru21,{"TIPOREC"       ,"C",001,0})//	Tipo de receita	1	-	Num�rico	Sim	Preencher com os seguintes valores:
	AADD(aStru21,{"DESCPROD"      ,"C",120,0})//	Descri��o da mercadoria	-	120	Alfanum�rico	Sim	Texto livre
	AADD(aStru21,{"UNIDADE"       ,"C",006,0})//	Unidade de comercializa��o	-	6	Alfanum�rico	N�o	Texto livre
	AADD(aStru21,{"QUANT"         ,"C",015,0})//	Quantidade	-	11 (antes da v�rgula) 3 (casas decimais)	Num�rico	Sim	Quantidade relativa � unidade de comercializa��o. Preencher com n�mero inteiro ou com 3 casas decimais (a utiliza��o da v�rgula � opcional). Ex.: "12" ou "12,000"
	AADD(aStru21,{"VALUNIT"       ,"C",018,0})//	Valor unit�rio	2 (casas decimais)	15 (antes da v�rgula)	Num�rico	Sim	Preencher SEMPRE com duas casas decimais, inclusive para valor zero. Ex.: "15,00", "16,85", "2435,05", "101000,00", "0,00".
	AADD(aStru21,{"VALTOT"        ,"C",018,0})//	Valor total	2 (casas decimais)	15 (antes da v�rgula)	Num�rico	Sim	Deve corresponder ao resultado do c�lculo: Qtdd x valor unit�rio. Preencher SEMPRE com duas casas decimais, inclusive para valor zero. Ex.: "15,00", "16,85", "2435,05", "101000,00", "0,00". 
	/* Campos que n�o v�o para o arquivo*/
	AADD(aStru21,{"DOC"           ,"C",009,0})
	AADD(aStru21,{"SERIE"         ,"C",TamSx3("D2_SERIE")[1],0})
	AADD(aStru21,{"CLIENTE"       ,"C",006,0})
	AADD(aStru21,{"LOJA"          ,"C",002,0})	
	
	cArq := CriaTrab(aStru21)
	dbUseArea(.T.,__LocalDriver,cArq,"RT21")
	IndRegua("RT21",cArq,"DOC+SERIE+CLIENTE+LOJA+NUMITEM")
	AADD(aTrbs,{cArq,"RT21"})

	//���������������������������������������������������������������������������������������������������������������Ŀ
	//�RT22 - Registro Tipo 22 - Vendas a prazo (registro opcional)                                 				  �
	//�����������������������������������������������������������������������������������������������������������������
	aStru22	:= {}
	cArq	:= ""
	
	AADD(aStru22,{"TIPOREG"       ,"C",002,0})//	Tipo de registro	2	-	Num�rico	Sim	Preencher com o valor "22" para indicar o tipo de registro.
	AADD(aStru22,{"VALPARC"       ,"C",002,0})//	Valor da parcela	2 (casas decimais)	15 (antes da v�rgula)	Num�rico	Sim	Preencher SEMPRE com duas casas decimais, inclusive para valor zero. Ex.: "15,00", "16,85", "2435,05", "101000,00", "0,00".
	AADD(aStru22,{"VENCPARC"      ,"C",002,0})//	Data de vencimento da parcela	10	-	DD/MM/AAAA	Sim	Preencher no formato : DD/MM/AAAA (dia, m�s e ano separados por barras).
	
	cArq := CriaTrab(aStru22)
	dbUseArea(.T.,__LocalDriver,cArq,"RT22")
	IndRegua("RT22",cArq,"TIPOREG")
	AADD(aTrbs,{cArq,"RT22"})

	//���������������������������������������������������������������������������������������������������������������Ŀ
	//�RT90 - Registro do Tipo 90 - Registro rodap� (obrigat�rio um registro por arquivo)             				  �
	//�����������������������������������������������������������������������������������������������������������������
	aStru90	:= {}
	cArq	:= ""

	AADD(aStru90,{"TIPOREG"       ,"C",002,0})//	Tipo de registro	2	-	Num�rico	Sim	Preencher com o valor "90" para indicar o tipo de registro
	AADD(aStru90,{"QUANT20"       ,"C",005,0})//	Quantidade de registros tipo 20	 	5	Num�rico	Sim	Indicar quantidade de registros tipo "20" no arquivo
	AADD(aStru90,{"QUANT21"       ,"C",005,0})//	Quantidade de registros tipo 21	 	5	Num�rico	Sim	Indicar quantidade de registros tipo "21" no arquivo
	AADD(aStru90,{"QUANT22"       ,"C",005,0})//	Quantidade de registros tipo 22	 	5	Num�rico	Sim	Indicar quantidade de registros tipo "22" no arquivo
	AADD(aStru90,{"TOTAL20"       ,"C",018,0})//	Somat�ria dos valores totais das NFVC informadas no arquivo	2 (casas decimais)	15 (antes da v�rgula)	Num�rico	Sim	Somat�ria dos campos "Valor total da NFVC" informados nos registros tipo "20". Preencher SEMPRE com duas casas decimais, inclusive para valor zero. Ex.: "15,00", "16,85", "2435,05", "101000,00", "0,00".
	
	cArq := CriaTrab(aStru90)
	dbUseArea(.T.,__LocalDriver,cArq,"RT90")
	IndRegua("RT90",cArq,"TIPOREG")
	AADD(aTrbs,{cArq,"RT90"})

Return (aTrbs)
                 
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �CFP        � Autor �Roberto Souza  		 � Data �19/06/2009���
��������������������������������������������������������������������������Ĵ��
���Descricao �Rotina LoadCFP                                               ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function LoadCFP()
	Local aTxtPre 		:= {}
	Local aPaineis 		:= {}
	
	Local cTitObj1		:= ""
	Local cTitObj2		:= ""       
	Local cMask2		:= Replicate("!",20)
	Local cMask3		:= Replicate("!",50)
    Local cMask4		:= Replicate("!",04)
    Local cMask5		:= Replicate("!",03)
    Local cMask6		:= Replicate("!",09)    
	Local nPos			:= 0

	//�����������������������������������������Ŀ
	//�Monta wizard com as perguntas necessarias�
	//�������������������������������������������
	AADD(aTxtPre,STR0015)			//"Assistente de parametriza��o da NFA Nota Fiscal Alagoana"
	AADD(aTxtPre,STR0016)			//"Aten��o"
	AADD(aTxtPre,STR0017)			//"Preencha as informa��es solicitadas para a gera��o do arquivo magnetico"
	AADD(aTxtPre,STR0018)	   		//"NFA Nota Fiscal Alagoana - Sefaz AL"

		

	//���������������������������������������������������������������������������������������Ŀ
	//�Painel 1 -  Configura��o do per�odo e parametros da gera��o :                          �
	//�����������������������������������������������������������������������������������������
	
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0019)	//"Assistente de parametriza��o"
	aAdd(aPaineis[nPos],STR0020)	//"Configura��o do per�odo e parametros da gera��o : "

	aAdd(aPaineis[nPos],{})
	
	cTitObj1 :=	STR0012 //"Data Inicial "		
	cTitObj2 :=	STR0013// "Data Final "		    
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})	
	aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	

	cTitObj1 :=	STR0031 //"Diretorio de Geracao"
	cTitObj2 :=	STR0032 //"Nome do arquivo"  	
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,20})
	aAdd(aPaineis[nPos][3],{2,,cMask2,1,,,,20})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     

	cTitObj1 :=	STR0033 //"Vers�o do arquivo"
	cTitObj2 :=	""				          
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask4,1,,,,20})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     

	//���������������������������������������������������������������������������������������Ŀ
	//�Painel 2 - Informa��o de Filtro                                                        �
	//�����������������������������������������������������������������������������������������
	
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0019)
	aAdd(aPaineis[nPos],STR0037)//"Informa��o de Filtro" ) 
	aAdd(aPaineis[nPos],{})


	cTitObj1 :=	STR0038//"Serie Inicial"
	cTitObj2 :=	STR0039//"Nota Fiscal Inicial"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask5,1,,,,20})
	aAdd(aPaineis[nPos][3],{2,,cMask6,1,,,,20})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     


	cTitObj1 :=	STR0040 //"Serie Final"
	cTitObj2 :=	STR0041 //"Nota Fiscal Final"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask5,1,,,,20})
	aAdd(aPaineis[nPos][3],{2,,cMask6,1,,,,20})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     


	//���������������������������������������������������������������������������������������Ŀ
	//�Painel 3 - Informa��o de opera�]oes fiscais                                            �
	//�����������������������������������������������������������������������������������������
	
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0019)
	aAdd(aPaineis[nPos],STR0034 ) //"Informa��o de operacoes fiscais e financeiras"
	aAdd(aPaineis[nPos],{})
	
	cTitObj1 :=	STR0021 //"Serie D (Separadas por '/' - Exemplo: '001/2  /UNI')"
	cTitObj2 :=	STR0022 //"Serie D Unica (Separadas por '/' - Exemplo: '001/2  /UNI')"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,20})	
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,20})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	
	cTitObj1 :=	STR0023 //"Serie Unica (Separadas por '/' - Exemplo: '001/2  /UNI')"		          		    	            //Cfp[1][01]
	cTitObj2 :=	STR0028 //"CFOP's Revenda"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,20})
	aAdd(aPaineis[nPos][3],{2,,cMask2,1,,,,20})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     
	
	cTitObj1 :=	STR0029 //"CFOP's Venda Industrializa��o"
	cTitObj2 :=	STR0030 //"CFOP's Venda Substitui��o tribut�ria"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,20})	
	aAdd(aPaineis[nPos][3],{2,,cMask3,1,,,,20})	
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     

	cTitObj1 :=	STR0024 //"Empresa efetua venda � prazo?"
	cTitObj2 := STR0025 //"Empresa entrega em domicilio?"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{3,,,,,{STR0026,STR0027},,}) //"Sim"###"N�o"
	aAdd(aPaineis[nPos][3],{3,,,,,{STR0026,STR0027},,}) //"Sim"###"N�o"
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})     
		
Return(xMagWizard(aTxtPre,aPaineis,"NFA")) 



/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �NfaDel      �Autor  �Roberto Souza       � Data � 19/06/2009  ���
���������������������������������������������������������������������������͹��
���Desc.     �Deleta os arquivos temporarios processados                    ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �NFA                                                           ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/         
Function NfaDel(aDelArqs)
	Local aAreaDel := GetArea()
	Local nI := 0
	
	For nI:= 1 To Len(aDelArqs)
		If File(aDelArqs[nI,1]+GetDBExtension())
			dbSelectArea(aDelArqs[ni,2])
			dbCloseArea()
			Ferase(aDelArqs[nI,1]+GetDBExtension())
			Ferase(aDelArqs[nI,1]+OrdBagExt())
		Endif	
	Next
	
	RestArea(aAreaDel)
	
Return


Static Function NFADATA(dDataEnt,cChar) 
Local cData  := ""
Default cChar:= "/"

cData := Dtos(dDataEnt)
cData := Substr(cData,7,2) + cChar + Substr(cData,5,2) + cChar + Substr(cData,1,4)

Return(cData)





Static Function GravaCpo(uDado,nTamMax) 
Local uRetorno  := ""
Default nTamMax := 0

Do Case 
	Case ValType(uDado)=="C"
		uDado := StrTran(uDado,".","")
		uDado := StrTran(uDado,",","")
		uDado := StrTran(uDado,"-","")
		uDado := StrTran(uDado,"_","")

		If nTamMax > 0
			uRetorno := Substr(uDado,1,nTamMax)
		Else
			uRetorno := uDado
		EndIf

	Case ValType(uDado)=="N"
		uRetorno := StrTran(TRANSFORM(uDado,"999999999999999.99"),".",",")

	Case ValType(uDado)=="D"	
			uRetorno := NFADATA(uDado,"/")
	OtherWise
			uRetorno := uDado
EndCase

Return(uRetorno)

                



Static Function GravaArq(cReg,aStruImp) 
Local lRetorno  := ""
Local Nx        := 0
Local Ny        := 0
Local cAlias    := "RT"+cReg
Default aStruImp:= {}

DbSelectArea(cAlias)
DbSetOrder(1)
DbGoTop()
Do Case
	Case cReg == "20"
		nLenStru := len(aStruImp) - 3
		Do While (cAlias)->(!Eof())
			For nX := 1 to nLenStru
				If Nx == nLenStru	
					GravaReg( AllTrim( (cAlias)->&(aStruImp[nx][1]) ) ,"END" )  
					nQuant20 += 1					
					DbSelectArea("RT21")
					DbSetOrder(1)			
					DbGoTop()
					If DbSeek(Padr((cAlias)->NUMERO,9)+(cAlias)->SERIEDOC+Padr((cAlias)->CLIENTE,6)+Padr((cAlias)->LOJA,2))
						nLenStru21 := len(aStru21) - 4
						Do While (cAlias)->(!Eof()) .And. (cAlias)->NUMERO == AllTrim(RT21->DOC) ;
							 .And. AllTrim((cAlias)->SERIEDOC) == AllTrim(RT21->SERIE) ;
							 .And. AllTrim((cAlias)->CLIENTE) == AllTrim(RT21->CLIENTE);
							 .And. AllTrim((cAlias)->LOJA) == AllTrim(RT21->LOJA)
				
							For nY := 1 to nLenStru21
								If Ny == nLenStru21	
									GravaReg( AllTrim( RT21->&(aStru21[ny][1]) ) ,"END" )  
									nQuant21 += 1
								Else
									GravaReg( AllTrim( RT21->&(aStru21[ny][1]) ) ,"|"   )  
								EndIf				
							Next
																						
						RT21->(dbSkip())		    		
					    EndDo
					EndIf 
					
				Else
					GravaReg( AllTrim( (cAlias)->&(aStruImp[nx][1]) ) ,"|"   )  
				EndIf				
			Next
			(cAlias)->(dbSkip())
		EndDo
		
	OtherWise
		nLenStru := len(aStruImp)
		Do While (cAlias)->(!Eof())
			For nX := 1 to nLenStru
				If Nx == nLenStru	
					GravaReg( AllTrim( (cAlias)->&(aStruImp[nx][1]) ) ,"END" )  
				Else
					GravaReg( AllTrim( (cAlias)->&(aStruImp[nx][1]) ) ,"|"   )  
				EndIf				
			Next
			(cAlias)->(dbSkip())
		EndDo
EndCase

Return(.T.)     


Static Function GravaReg(cDetalhe, cChar)

	cHandle := "nArq1"
    If cChar == "END"
		FWrite(&cHandle,cDetalhe + CRLF)
    Else
		FWrite(&cHandle,cDetalhe + cChar,Len(cDetalhe+cChar))    
    EndIf

Return 
