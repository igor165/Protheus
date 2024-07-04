#Include "Protheus.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DFCGI     ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 20.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Preparacao do meio-magnetico para o DFC e GI do Parana      ³±±
±±³          ³DFC - Declaracao Fisco-Contabil                             ³±±
±±³          ³GI  - Guia de Informacoes das Operacoes e Prestacoes        ³±±
±±³          ³      Interestaduais                                        ³±±
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
Function DFCGI()

Local cPerg		:= "DFCGI"
Local dDtIni	:= mv_par01		//Data Inicial
Local dDtFim	:= mv_par02		//Data Final
Local lDFC		:= .F.

Pergunte(cPerg,.T.)
lDFC := (Str(mv_par01,2)$"21/22/24")	//Processa DFC ou GI
GeraTrb(lDFC)

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Parametros Utilizados:
	ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	MV_A1MUN	- Campo do A1 que contem o Cod. Municipio
	MV_A2MUN	- Campo do A2 que contem o Cod. Municipio
	MV_QUAD03	- Cfop's de entrada referentes as operacoes com petroleo, inclusive
				  lubrificantes, combustiveis liquidos e gasosos dele derivados e
				  energia eletrica
	MV_QUAD22	- Cfop's referentes as entradas em regime de deposito, armazenagemm,
				  consignacao ou similar
	Perguntas Utilizadas:
	ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mv_par01 -	Tipo de Documento
				21 - DFC Normal
				22 - DFC de Retificacao
				24 - DFC de Baixa
				31 - GI Normal
				32 - GI de Retificacao
				33 - GI de Baixa
	mv_par02 -	CPF do Contabilista
	mv_par03 -	Tipo Estabelecimento
				1 - MicroEmpresa e Empresa de Pequeno Porte
				2 - Servico de Transporte Inscrito no CAD/ICMS
				3 - Servico de Comunicacao
				4 - Fornecimento de Energia Eletrica
				Branco - Outros
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	
If lDFC
	ProcDFC(dDtIni,dDtFim)
Else
	ProcGI(dDtIni,dDtFim)
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ProcDFC   ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 20.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa DFC - Declaracao Fisco-Contabil                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcDFC(dDtIni,dDtFim)

Local cFilTop		:= "F3_FILIAL='"+xFilial("SF3")+"' AND F3_ENTRADA>='"+Dtos(dDtIni)+"' AND F3_ENTRADA<='"+Dtos(dDtFim)+"' AND F3_DTCANC=''"
Local cFilDbf		:= "F3_FILIAL=='"+xFilial("SF3")+"' .AND. DTOS(F3_ENTRADA)>='"+Dtos(dDtIni)+"' .AND. DTOS(F3_ENTRADA)<='"+Dtos(dDtFim)+"' .AND. EMPTY(F3_DTCANC)"
Local aArq			:= {"SF3",""}
Local aCol			:= {}
Local aVal			:= {}
Local nI			:= 0
Local lConj	 	:= .F.
Local cEntSai		:= ""
Local cChaveSft	:= ""

dbSelectArea("SF3")
SF3->(dbSetOrder(1))
FsQuery(aArq,1,cFilTop,cFilDbf,IndexKey())
SF3->(dbGoTop())
While !Eof()

	If MV_PAR04 == 1
		If AllTrim(SF3->F3_CFO) $ AllTrim(MV_PAR05) .And. Alltrim(SF3->F3_TIPO) == "S"
			
			//Tipo da nota, Entrada ou Saida, para realizar a busca na SFT
			cEntSai := If(Val(Substring(SF3->F3_CFO,1,1)) >= 4 , "S", "E") 
		
			dbSelectArea("SFT")
			SFT->(dbSetOrder(3))
			
			If SFT->(MsSeek(xFilial("SFT")+cEntSai+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_SERIE+SF3->F3_NFISCAL))
			
				cChaveSft := SFT->(FT_FILIAL+FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL) 
				
				While !SFT->(Eof()) .And. cChaveSft == SFT->(FT_FILIAL+FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL) 
					//Se algum dos itens não for um serviço, significa que a nota é conjulgada, portanto deve ser gerado				
					If !SFT->FT_TIPO == "S"
						lConj := .T.
					EndIf						
				
				SFT->(DbSkip())
				EndDo
			
			EndIf
			
			If !lConj
				SF3->(dbSkip())
				Loop
			EndIf	
			
			lConj := .F.	
		
		EndIf
	EndIf
	
	aCol	:= {}
	aVal	:= {}
	Do Case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quadro 17 - Processa Entradas                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case Val(SF3->F3_CFO)>=1101 .And. Val(SF3->F3_CFO)<=1126	.Or. ;
			Alltrim(SF3->F3_CFO)$"1401/1403"						.Or. ;
			Val(SF3->F3_CFO)>=1651 .And. Val(SF3->F3_CFO)<=1653
			aCol := {"8010","8260","8510","8760"}

		Case Alltrim(SF3->F3_CFO)$"1151/1152/1154"					.Or. ;
			Val(SF3->F3_CFO)>=1408 .And. Val(SF3->F3_CFO)<=1411	.Or. ;
			Val(SF3->F3_CFO)>=1201 .And. Val(SF3->F3_CFO)<=1209	.Or. ;
			Val(SF3->F3_CFO)>=1658 .And. Val(SF3->F3_CFO)<=1662			
			aCol := {"8020","8270","8520","8770"}
		
		Case Val(SF3->F3_CFO)>=1251 .And. Val(SF3->F3_CFO)<=1257	.Or. ;
			Alltrim(SF3->F3_CFO)=="1153"
			aCol := {"8030","8280","8530","8780"}

		Case Val(SF3->F3_CFO)>=1301 .And. Val(SF3->F3_CFO)<=1306
			aCol := {"8040","8290","8540","8790"}

		Case Val(SF3->F3_CFO)>=1351 .And. Val(SF3->F3_CFO)<=1356	.Or. ;
			Alltrim(SF3->F3_CFO)$"1931/1932"		
			aCol := {"8050","8300","8550","8800"}

		Case Alltrim(SF3->F3_CFO)$"1128/1406/1407"						.Or. ;
			Val(SF3->F3_CFO)>=1551 .And. Val(SF3->F3_CFO)<=1557
			aCol := {"8060","8310","8560","8810"}

		Case Alltrim(SF3->F3_CFO)$"1451/1452"						.Or. ;
			Val(SF3->F3_CFO)>=1501 .And. Val(SF3->F3_CFO)<=1504	.Or. ;
			Alltrim(SF3->F3_CFO)$"1910/1911"
		    aCol := {"8070","8320","8570","8820"}

		Case Val(SF3->F3_CFO)>=1601 .And. Val(SF3->F3_CFO)<=1605	.Or. ;
			Alltrim(SF3->F3_CFO)$"1414/1415"						.Or. ;
			Val(SF3->F3_CFO)>=1901 .And. Val(SF3->F3_CFO)<=1909	.Or. ;
			Val(SF3->F3_CFO)>=1912 .And. Val(SF3->F3_CFO)<=1926	.Or. ;			
			Alltrim(SF3->F3_CFO)$"1949/1663/1664/1933"             .Or. ; 	  
    		Alltrim(SF3->F3_CFO)$"1505"	.Or. ;
    		Alltrim(SF3->F3_CFO)$"1934"
			aCol := {"8080","8330","8580","8830"}

		Case Val(SF3->F3_CFO)>=2101 .And. Val(SF3->F3_CFO)<=2126	.Or. ;
			Alltrim(SF3->F3_CFO)$"2401/2403/2151/2152/2154"			.Or. ;
			Val(SF3->F3_CFO)>=2408 .And. Val(SF3->F3_CFO)<=2411	.Or. ;
			Val(SF3->F3_CFO)>=2201 .And. Val(SF3->F3_CFO)<=2209	.Or. ;
			Val(SF3->F3_CFO)>=2651 .And. Val(SF3->F3_CFO)<=2662
		    aCol := {"8090","8340","8590","8840"}

		Case Val(SF3->F3_CFO)>=2251 .And. Val(SF3->F3_CFO)<=2257	.Or. ;
			Alltrim(SF3->F3_CFO)=="2153"	
		    aCol := {"8100","8350","8600","8850"}

		Case Val(SF3->F3_CFO)>=2301 .And. Val(SF3->F3_CFO)<=2306
		    aCol := {"8110","8360","8610","8860"}

		Case Val(SF3->F3_CFO)>=2351 .And. Val(SF3->F3_CFO)<=2356	.Or. ;
			Alltrim(SF3->F3_CFO)$"2931/2932"
		    aCol := {"8120","8370","8620","8870"}

		Case Alltrim(SF3->F3_CFO)$"2128/2406/2407"						.Or. ;
			Val(SF3->F3_CFO)>=2551 .And. Val(SF3->F3_CFO)<=2557
		    aCol := {"8130","8380","8630","8880"}

		Case Val(SF3->F3_CFO)>=2501 .And. Val(SF3->F3_CFO)<=2504	.Or. ;
			Alltrim(SF3->F3_CFO)$"2910/2911"
		    aCol := {"8140","8390","8640","8890"}

		Case Alltrim(SF3->F3_CFO)$"2603/2414/2415"					.Or. ;
			Val(SF3->F3_CFO)>=2901 .And. Val(SF3->F3_CFO)<=2909	.Or. ;
			Val(SF3->F3_CFO)>=2912 .And. Val(SF3->F3_CFO)<=2925	.Or. ;
			Alltrim(SF3->F3_CFO)$"2949/2663/2664/2933/2934"
		    aCol := {"8150","8400","8650","8900"} 

		Case Val(SF3->F3_CFO)>=3101 .And. Val(SF3->F3_CFO)<=3126	.Or. ;
			Val(SF3->F3_CFO)>=3201 .And. Val(SF3->F3_CFO)<=3207	.Or. ;
			Alltrim(SF3->F3_CFO)=="3503"							.Or. ;
			Val(SF3->F3_CFO)>=3651 .And. Val(SF3->F3_CFO)<=3653
		    aCol := {"8160","8410","8660","8910"}

		Case Alltrim(SF3->F3_CFO)=="3251"
		    aCol := {"8170","8420","8670","8920"}

		Case Alltrim(SF3->F3_CFO)=="3301"
		    aCol := {"8180","8430","8680","8930"}

		Case Val(SF3->F3_CFO)>=3351 .And. Val(SF3->F3_CFO)<=3356
		    aCol := {"8190","8440","8690","8940"}

		Case Val(SF3->F3_CFO)>=3551 .And. Val(SF3->F3_CFO)<=3556
		    aCol := {"8200","8450","8700","8950"}

		Case Alltrim(SF3->F3_CFO)$"3127/3211"
		    aCol := {"8210","8460","8710","8960"}

		Case Alltrim(SF3->F3_CFO)$"3930/3949"
		    aCol := {"8220","8470","8720","8970"}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quadro 18 - Processa Saidas                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case Val(SF3->F3_CFO)>=5101 .And. Val(SF3->F3_CFO)<=5125	.Or. ;
			Val(SF3->F3_CFO)>=5401 .And. Val(SF3->F3_CFO)<=5411	.Or. ;
			Alltrim(SF3->F3_CFO)$"5151/5152/5155/5156"				.Or. ;
			Val(SF3->F3_CFO)>=5201 .And. Val(SF3->F3_CFO)<=5210	.Or. ;
			Val(SF3->F3_CFO)>=5651 .And. Val(SF3->F3_CFO)<=5656	.Or. ;
			Val(SF3->F3_CFO)>=5658 .And. Val(SF3->F3_CFO)<=5662
			aCol := {"9010","9260","9510","9760"}

		Case Val(SF3->F3_CFO)>=5251 .And. Val(SF3->F3_CFO)<=5258	.Or. ;
			Alltrim(SF3->F3_CFO)=="5153"
			aCol := {"9020","9270","9520","9770"}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processa Quadro 22 - Item 13.9.3 (Forn. de Energia Eletrica)   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par03=="4"	//Fornecedor de Energia Eletrica
				Quadro22()
			Endif
		
		Case Val(SF3->F3_CFO)>=5301 .And. Val(SF3->F3_CFO)<=5307
			aCol := {"9030","9280","9530","9780"}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processa Quadro 22 - Item 13.9.3 (Prest. Serv. de Comunicacao) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par03=="3"	//Prestador de Servico de Comunicacao
				Quadro22()
    		Endif
    		
		Case Val(SF3->F3_CFO)>=5351 .And. Val(SF3->F3_CFO)<=5357	.Or. ;
			Alltrim(SF3->F3_CFO)$"5931/5932/5359"
			aCol := {"9040","9290","9540","9790"}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processa Quadro 22 - Item 13.9.2 (Transportadora)              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Transportadora Inscrita no CAD/ICMS
			If mv_par03=="2" .And. !(Alltrim(SF3->F3_CFO)$"5931/5932")
				Quadro22(2)
			Endif

		Case Alltrim(SF3->F3_CFO)$"5412/5413"						.Or. ;		
			Val(SF3->F3_CFO)>=5551 .And. Val(SF3->F3_CFO)<=5557
			aCol := {"9050","9300","9550","9800"}

		Case Alltrim(SF3->F3_CFO)=="5451"							.Or. ;
			Val(SF3->F3_CFO)>=5501 .And. Val(SF3->F3_CFO)<=5503	.Or. ;
			Alltrim(SF3->F3_CFO)$"5910/5911/5927/5928"
			aCol := {"9060","9310","9560","9810"}

		Case Alltrim(SF3->F3_CFO)$"5414/5415"						.Or. ;
			Val(SF3->F3_CFO)>=5601 .And. Val(SF3->F3_CFO)<=5605	.Or. ;
			Val(SF3->F3_CFO)>=5901 .And. Val(SF3->F3_CFO)<=5909	.Or. ;			
			Val(SF3->F3_CFO)>=5912 .And. Val(SF3->F3_CFO)<=5926	.Or. ;			
			Alltrim(SF3->F3_CFO)$"5929/5949/5657/5933/5934"				.Or. ;
			Val(SF3->F3_CFO)>=5663 .And. Val(SF3->F3_CFO)<=5666    .Or. ;
			Alltrim(SF3->F3_CFO)$"5505"			
			aCol := {"9070","9320","9570","9820"}

		Case Val(SF3->F3_CFO)>=6101 .And. Val(SF3->F3_CFO)<=6125	.Or. ;
			Val(SF3->F3_CFO)>=6401 .And. Val(SF3->F3_CFO)<=6411	.Or. ;
			Alltrim(SF3->F3_CFO)$"6151/6152/6155/6156"				.Or. ;
			Val(SF3->F3_CFO)>=6201 .And. Val(SF3->F3_CFO)<=6210	.Or. ;
			Val(SF3->F3_CFO)>=6651 .And. Val(SF3->F3_CFO)<=6656	.Or. ;			
			Val(SF3->F3_CFO)>=6658 .And. Val(SF3->F3_CFO)<=6662
			aCol := {"9080","9330","9580","9830"}

		Case Val(SF3->F3_CFO)>=6251 .And. Val(SF3->F3_CFO)<=6258	.Or. ;
			Alltrim(SF3->F3_CFO)=="6153"
			aCol := {"9090","9340","9590","9840"}

		Case Val(SF3->F3_CFO)>=6301 .And. Val(SF3->F3_CFO)<=6307
			aCol := {"9100","9350","9600","9850"}

		Case Val(SF3->F3_CFO)>=6351 .And. Val(SF3->F3_CFO)<=6357	.Or. ;
			Alltrim(SF3->F3_CFO)$"6931/6932/6359"
			aCol := {"9110","9360","9610","9860"}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processa Quadro 22 - Item 13.9.2 (Transportadora)              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Transportadora Inscrita no CAD/ICMS
			If mv_par03=="2" .And. !(Alltrim(SF3->F3_CFO)$"6931/6932")
				Quadro22(2)
			Endif

		Case Alltrim(SF3->F3_CFO)$"6412/6413"						.Or. ; 
			Val(SF3->F3_CFO)>=6551 .And. Val(SF3->F3_CFO)<=6557
			aCol := {"9120","9370","9620","9870"}

		Case Val(SF3->F3_CFO)>=6501 .And. Val(SF3->F3_CFO)<=6503	.Or. ;
			Alltrim(SF3->F3_CFO)$"6910/6911"
			aCol := {"9130","9380","9630","9880"}
                                                 
		Case Alltrim(SF3->F3_CFO)=="6603"							.Or. ;
			Val(SF3->F3_CFO)>=6901 .And. Val(SF3->F3_CFO)<=6909	.Or. ;
			Alltrim(SF3->F3_CFO)$"6414/6415"						.Or. ;
			Val(SF3->F3_CFO)>=6912 .And. Val(SF3->F3_CFO)<=6929	.Or. ;			
			Alltrim(SF3->F3_CFO)$"6949/6657/6933/6934"					.Or. ;
			Val(SF3->F3_CFO)>=6663 .And. Val(SF3->F3_CFO)<=6666
			aCol := {"9140","9390","9640","9890"}

		Case Val(SF3->F3_CFO)>=7101 .And. Val(SF3->F3_CFO)<=7106	.Or. ;
			Alltrim(SF3->F3_CFO)$"7127/7501"						.Or. ;
			Val(SF3->F3_CFO)>=7651 .And. Val(SF3->F3_CFO)<=7654
			aCol := {"9150","9400","9650","9900"}

		Case Val(SF3->F3_CFO)>=7201 .And. Val(SF3->F3_CFO)<=7210	.Or. ;
			Alltrim(SF3->F3_CFO)=="7211"
			aCol := {"9160","9410","9660","9910"}

		Case Alltrim(SF3->F3_CFO)=="7251"
			aCol := {"9170","9420","9670","9920"}

		Case Alltrim(SF3->F3_CFO)=="7301"
			aCol := {"9180","9430","9680","9930"}

		Case Alltrim(SF3->F3_CFO)=="7358"
			aCol := {"9190","9440","9690","9940"}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processa Quadro 22 - Item 13.9.2 (Transportadora)              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par03=="2"	//Transportadora Inscrita no CAD/ICMS
				Quadro22(2)
			Endif

		Case Val(SF3->F3_CFO)>=7551 .And. Val(SF3->F3_CFO)<=7556	.Or. ;
			Alltrim(SF3->F3_CFO)$"7930/7949"
			aCol := {"9200","9450","9700","9950"}
	EndCase

	If Left(Alltrim(SF3->F3_CFO),1)=="1"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processa Quadro 22 - Item 13.9.1 - Entradas provinientes (...) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Quadro22(1)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa Quadro 19 - Incluir/Excluir nas Entradas Contabeis³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	Quadro19()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa Quadro 20 - Incluir/Excluir nas Saidas Contabeis  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	Quadro20()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava no arquivo R2 - Valores dos Campos   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aVal := {SF3->F3_VALCONT,SF3->F3_BASEICM,SF3->F3_ISENICM,SF3->F3_OUTRICM}
	For nI:=1 To Len(aCol)
		If !Empty(aVal[nI])
    	    GravaR2(aCol[nI],aVal[nI])
  		Endif
	Next
	dbSelectArea("SF3")
	dbSkip()
Enddo	
FsQuery(aArq,2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava Total de Registro Tipo 2 no Registro Tipo 1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrvTotR2()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ProcGI    ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 20.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa GI - Guia de Inf. Oper. e Prest. Interestaduais    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcGI(dDtIni,dDtFim)

Local cFilTop	:= "F3_FILIAL='"+xFilial("SF3")+"' AND F3_ENTRADA>='"+Dtos(dDtIni)+"' AND F3_ENTRADA<='"+Dtos(dDtFim)+"' AND (F3_CFO LIKE '2%' OR F3_CFO LIKE '6%') AND F3_DTCANC=''"
Local cFilDbf	:= "F3_FILIAL=='"+xFilial("SF3")+"' .AND. DTOS(F3_ENTRADA)>='"+Dtos(dDtIni)+"' .AND. DTOS(F3_ENTRADA)<='"+Dtos(dDtFim)+"'.AND. LEFT(ALLTRIM(F3_CFO),1)$'2/6' .AND. EMPTY(F3_DTCANC)"
Local aArq		:= {"SF3",""}
Local cCodigo	:= ""
Local aVlrEnt	:= {}
Local aVlrSai	:= {}
Local cCodTab	:= ""	//Codigo da UF
Local nI		:= 0
Local cQuad03	:= GetNewPar("MV_QUAD03","")	//Petroleo/Energia Eletrica
Local lConj	 	:= .F.
Local cEntSai		:= ""
Local cChaveSft	:= ""

dbSelectArea("SF3")
dbSetOrder(1) 
FsQuery(aArq,1,cFilTop,cFilDbf,IndexKey())
dbGoTop()
While !Eof()

	If MV_PAR04 == 1
		If AllTrim(SF3->F3_CFO) $ AllTrim(MV_PAR05) .And. Alltrim(SF3->F3_TIPO) == "S"
			
			//Tipo da nota, Entrada ou Saida, para realizar a busca na SFT
			cEntSai := If(Val(Substring(SF3->F3_CFO,1,1)) >= 4 , "S", "E") 
		
			dbSelectArea("SFT")
			SFT->(dbSetOrder(3))
			
			If SFT->(MsSeek(xFilial("SFT")+cEntSai+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_SERIE+SF3->F3_NFISCAL))
			
				cChaveSft := SFT->(FT_FILIAL+FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL) 
				
				While !SFT->(Eof()) .And. cChaveSft == SFT->(FT_FILIAL+FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL) 
					//Se algum dos itens não for um serviço, significa que a nota é conjulgada, portanto deve ser gerado				
					If !SFT->FT_TIPO == "S"
						lConj := .T.
					EndIf						
				
				SFT->(DbSkip())
				EndDo
			
			EndIf
			
			If !lConj
				SF3->(dbSkip())
				Loop
			EndIf	
			
			lConj := .F.
		
		EndIf
	EndIf

	cCodigo	:= ""
	cCodTab	:= TabelaUF()[1]	//Codigo da UF
	aVlrEnt	:= {0,0,0,0,0}
	aVlrSai	:= {0,0,0,0,0,0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa Entradas Interestaduais                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Val(SF3->F3_CFO)>=2101 .And. Val(SF3->F3_CFO)<=2949
		aVlrEnt[1] := SF3->F3_VALCONT
		aVlrEnt[2] := SF3->F3_BASEICM
		aVlrEnt[3] := SF3->F3_ISENICM+SF3->F3_OUTRICM
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Operacoes Petroleo/Energia Eletrica                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SF3->F3_ICMSRET)
			If Alltrim(SF3->F3_CFO)$cQuad03
				aVlrEnt[4] := SF3->F3_ICMSRET
			Else
				aVlrEnt[5] := SF3->F3_ICMSRET
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravando Entradas                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI:=1 To 5
			If !Empty(aVlrEnt[nI])
				cCodigo := "3"+cCodTab+Str(nI,1)
				GravaR2(cCodigo,aVlrEnt[nI])
			Endif
		Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa Saidas Interestaduais                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf Val(SF3->F3_CFO)>=6101 .And. Val(SF3->F3_CFO)<=6949
		If Alltrim(SF3->F3_CFO)$"6107/6108/6258/6307/6357"
			aVlrSai[1] := SF3->F3_VALCONT
			aVlrSai[3] := SF3->F3_BASEICM
		Else		
			aVlrSai[2] := SF3->F3_VALCONT
			aVlrSai[4] := SF3->F3_BASEICM
	    Endif
	    aVlrSai[5] := SF3->F3_ISENICM+SF3->F3_OUTRICM
	    aVlrSai[6] := SF3->F3_ICMSRET

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravando Saidas                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI:=1 To 6
			If !Empty(aVlrSai[nI])
				cCodigo := "5"+cCodTab+Str(nI,1)
				GravaR2(cCodigo,aVlrSai[nI])
			Endif
		Next
	Endif
	dbSelectArea("SF3")
	dbSkip()
Enddo
FsQuery(aArq,2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava Total de Registro Tipo 2 no Registro Tipo 1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrvTotR2()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Quadro19  ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 20.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valores a Incluir/Excluir nas Entradas Contabeis            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Quadro19()
Local aArea := GetArea()
If Alltrim(SF3->F3_CFO)$"1414/2414/1415/2415/1904/2904"
	GravaR2("6720",SF3->F3_VALCONT)
ElseIf Alltrim(SF3->F3_CFO)$"5103/6103/5104/6104"
	GravaR2("6720",(-1*SF3->F3_VALCONT))
Endif
RestArea(aArea)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Quadro20  ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 20.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valores a Incluir/Excluir nas Saidas Contabeis              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Quadro20()
Local aArea := GetArea()
If Left(Alltrim(SF3->F3_CFO),1)>="5"
	//Campo 682
	If Alltrim(SF3->F3_CFO)$"5414/6414/5415/6415"
		GravaR2("6820",SF3->F3_VALCONT)
	ElseIf Alltrim(SF3->F3_CFO)$"5103/6103/5104/6104"
		GravaR2("6820",(-1*SF3->F3_VALCONT))
	Endif
	//Campo 681
	If !Empty(SF3->F3_ICMSRET)
		GravaR2("6810",SF3->F3_ICMSRET)
	Endif
Endif
RestArea(aArea)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Quadro22  ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 20.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Quadro 22 - Demonstrativo de Valores por Municipio          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Quadro22(nOpc)

Local aArea		:= GetArea()
Local cCodMun	:= TabelaUF(nOpc)[2]		//Codigo do Municipio
Local cIE		:= Upper(Alltrim(TabelaUF()[3]))	//IE do Fornecedor
Local lProdRur	:= TabelaUF()[4]					//Produtor Rural
Local lGrava	:= .T.
Local cQuad22	:= GetNewPar("MV_QUAD22","")
Local cQuad22A	:= GetNewPar("MV_QUAD22A","")
Default nOpc	:= 0

If !Empty(cCodMun)
	//Quadro 22 - Item 13.9.1 do Manual de Preenchimento
	If  nOpc==1
		If !Empty(cQuad22A)
	   		If !(lProdRur .And. ;
				!(Alltrim(SF3->F3_CFO)$cQuad22) .And. Alltrim(SF3->F3_CFO)$cQuad22A)
				lGrava := .F.
			Endif  
		Else 
			If !(lProdRur .And. ;
				!(Alltrim(SF3->F3_CFO)$cQuad22))
				lGrava := .F.
			Endif
		Endif
	Endif
	If lGrava
		GravaR2(cCodMun,SF3->F3_VALCONT)
	Endif
Endif
RestArea(aArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GravaR2   ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 20.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava no Registro Tipo 2 - Valores dos Campos               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaR2(cLinha,nValor)
Local aArea := GetArea()
dbSelectArea("R02")
dbSetOrder(1)
If !dbSeek(cLinha)
	RecLock("R02",.T.)
	R02->LINHA := cLinha
Else
	RecLock("R02",.F.)
Endif
R02->VALOR += nValor
MsUnlock()
RestArea(aArea)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GrvTotR2  ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 20.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava Total de Registro Tipo 2 no Registro Tipo 1           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GrvTotR2()

dbSelectArea("R01")
dbGoTop()
RecLock("R01",.F.)
R01->QTDLIN := R02->(LastRec())
MsUnlock()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TabelaUf  ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 20.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o Codigo da UF, conforme a Tabela                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TabelaUf(nOpc)

Local aArea		:= GetArea()
Local aCod		:= {"","","",.F.}
Local cUf		:= ""
Local cA1Mun	:= GetNewPar("MV_A1MUN","")		//Codigo do Municipio - Clientes
Local cA2Mun	:= GetNewPar("MV_A2MUN","")		//Codigo do Municipio - Fornecedores
Local cMunPar	:= aFisFill(GetNewPar("MV_QUAD22B",""),4)		//Codigo do Municipio da Transportadora
Local cMunDUE	:= GetNewPar("MV_MUNDUE","")
Local cMunDUL	:= GetNewPar("MV_MUNDUL","")
Local cSolDT5	:= GetNewPar("MV_SOLDT5","")
Local lIntTms	:= GetNewPar("MV_INTTMS",.F.)
Local nMunA1		:= Iif(!Empty(cA1Mun),SA1->(FieldPos((cA1Mun))),0)
Local nMunA2		:= Iif(!Empty(cA2Mun),SA2->(FieldPos((cA2Mun))),0)
Local nMunDUE		:= Iif(!Empty(cMunDUE),DUE->(FieldPos((cMunDUE))),0)
Local nMunDUL		:= Iif(!Empty(cMunDUL),DUL->(FieldPos((cMunDUL))),0)
Local nSolDT5		:= Iif(!Empty(cSolDT5),DT5->(FieldPos((cSolDT5))),0)

Default nOpc	:= 0

/*Utiliza TMS e Tipo de Estabelecimento - Transportadora*/
If lIntTms .And. nOpc==2	//Quadro 22 - Item 13.9.2 (Transportadora)
	DbSelectArea("DT6")
	DT6->(dbSetOrder(1))

	If (DT6->(MsSeek(xFilial("DT6")+SF3->F3_FILIAL+SF3->F3_NFISCAL+SF3->F3_SERIE)))
		DTC->(DbSetOrder(1))
		If DTC->(MsSeek(xFilial('DTC') + DT6->(DT6_FILORI + DT6_LOTNFC)))
			/*Quanto o inicio do Frete for na Transportadora*/
			If DTC->DTC_SELORI == "1" 
				/*Inicio do Frete*/
				If SM0->(MsSeek(cEmpAnt+cFilAnt))
					/*Estado*/
					cUf := SM0->M0_ESTENT
					/*Se o parâmetro não estiver preenchido pego da SM0*/
					If !Empty(cMunPar)
						aCod[2] := aFisFill(cMunPar,4)	
					Else
						aCod[2] := aFisFill(SM0->M0_CODMUN,4)
					EndIf
				EndIf
			/*Quanto o inicio do Frete for no Cliente*/
			ElseIf DTC->DTC_SELORI == "2" 
				/*Inicio do Frete*/
				DbSelectArea("SA1")
				SA1->(DbSeek(xFilial("SA1")+DT6->(DT6_CLIREM+DT6_LOJREM)))
				/*Estado*/
				cUf := SA1->A1_EST														
				/*Se o parâmetro não estiver preenchido pego do A1_COD_MUN*/
				If nMunA1 > 0
					aCod[2] := aFisFill(SA1->(FieldGet(nMunA1)),4)
				Else					
					aCod[2] :=	 aFisFill(SA1->A1_COD_MUN,4)
				EndIf
			/*Origem e Local de Coleta*/		  	
			ElseIf	DTC->DTC_SELORI == "3" 
				/*Inicio do Frete*/
				If !Empty(DTC->DTC_NUMSOL)
					/*Posiciona na Ordem de Coleta*/
					DT5->(DbSetOrder(1))
					If DT5->(MsSeek(xFilial("DT5")+DTC->DTC_FILORI+DTC->DTC_NUMSOL))
						/*Verifica se o Solicitante tem Sequencias de Endereco*/
						If Empty (DT5->DT5_SEQEND)								
							If	nSolDT5 > 0
								DUE->(dbSetOrder(3))
								DUE->(MsSeek(xFilial("DUE")+DT5->(FieldGet(nSolDT5))))									
							Else
								DUE->(dbSetOrder(1))
								DUE->(MsSeek(xFilial("DUE")+DT5->(DT5_DDD+DT5_TEL)))										
							EndIf
							/*Estado*/
							cUf := DUE->DUE_EST
							/*Se o parâmetro não estiver preenchido pego do DUE_CODMUN*/
							If nMunDUE > 0
								aCod[2] := aFisFill(DUE->(FieldGet(nMunDUE)),4)
							Else								
								aCod[2] := aFisFill(DUE->DUE_CODMUN,4)
							EndIf
						Else                                                               
							If	nSolDT5 > 0
								DUL->(dbSetOrder(2))
								DUL->(MsSeek(xFilial("DUL")+DT5->(FieldGet(nSolDT5)+DT5_SEQEND)))									
							Else
								DUL->(dbSetOrder(1))
								DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_DDD+DT5_TEL+DT5_SEQEND)))
							EndIf
							/*Estado*/
							cUf := DUL->DUL_EST	
							/*Se o parâmetro não estiver preenchido pego do DUL_CODMUN*/
							If nMunDUL > 0
								aCod[2] := aFisFill(DUL->(FieldGet(nMunDUL)),4)
							Else								
								aCod[2] :=	aFisFill(DUL->DUL_CODMUN,4)
							EndIf	
						EndIf
					EndIf		
				EndIf					
			EndIf
		EndIf
	EndIf				
/*Cliente e Fornecedor*/
ElseIf Left(Alltrim(SF3->F3_CFO),1)<"5" .And. !(SF3->F3_TIPO$"BD") .Or. ;
	Left(Alltrim(SF3->F3_CFO),1)>="5" .And. (SF3->F3_TIPO$"BD")
	dbSelectArea("SA2")
	dbSetOrder(1)
	If dbSeek(xFilial("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA)
		cUf 	:= SA2->A2_EST
		aCod[2]	:= aFisFill(IIf(!Empty(cA2Mun),SA2->&(cA2Mun),""),4)
		aCod[3]	:= aRetDig(SA2->A2_INSCR,.T.,SA2->A2_EST)
		aCod[4]	:= !Empty(SA2->A2_TIPORUR)	//Produtor Rural
	Endif
Else
	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA)
		cUf 	:= SA1->A1_EST
		aCod[2]	:= aFisFill(IIf(!Empty(cA1Mun),SA1->&(cA1Mun),""),4)
	Endif
Endif

dbSelectArea("TUF")
dbSetOrder(1)
If dbSeek(cUf)
	aCod[1] := TUF->CODIGO
Endif

RestArea(aArea)

Return(aCod)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GeraTrb   ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 20.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos de trabalho                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTrb(lDFC)

Local cArq	:= ""
Local aStru	:= {}
Local aTab	:= {}
Local nI	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 1 - Identificao do Contribuinte (Obrigatorio)             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru,{"TIPODOC"	,"N",002,0})	//Tipo do Documento
AADD(aStru,{"IE"		,"C",010,0})	//Inscricao Estadual
AADD(aStru,{"CNPJ"		,"C",014,0})	//CNPJ
AADD(aStru,{"CPF"		,"C",015,0})	//CPF do Contabilista Responsavel
AADD(aStru,{"MODELO"	,"C",001,0})	//DFC: 8-Modelo Unico / GI: em branco
AADD(aStru,{"QTDLIN"	,"N",003,0})	//Qtde. de Registros Tipo 2

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R01")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Registro Tipo 2 - Valores dos Campos (Opcional)                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArq	:= ""
aStru	:= {}
AADD(aStru,{"LINHA"		,"C",004,0})	//Numero da Linha do Documento
AADD(aStru,{"VALOR"		,"N",TamSx3("F3_BASEICM")[1],TamSx3("F3_BASEICM")[2]})

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R02")
IndRegua("R02",cArq,"LINHA")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TUF - Tabela de Unidade Federativa                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArq	:= ""
aStru	:= {}
AADD(aStru,{"UF"		,"C",002,0})	//UF
AADD(aStru,{"CODIGO"	,"C",002,0})	//Codigo da UF

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"TUF")
IndRegua("TUF",cArq,"UF")

Aadd(aTab,{"AC","01"})	//01-Acre
Aadd(aTab,{"AL","02"})	//02-Alagoas
Aadd(aTab,{"AP","03"})	//03-Amapa
Aadd(aTab,{"AM","04"})	//04-Amazonas
Aadd(aTab,{"BA","05"})	//05-Bahia
Aadd(aTab,{"CE","06"})	//06-Ceara
Aadd(aTab,{"DF","07"})	//07-Acre
Aadd(aTab,{"ES","08"})	//08-Espirito Santo
Aadd(aTab,{"GO","10"})	//10-Goias
Aadd(aTab,{"MA","12"})	//12-Maranhao
Aadd(aTab,{"MT","13"})	//13-Mato Grosso
Aadd(aTab,{"MG","14"})	//14-Minas Gerais
Aadd(aTab,{"PA","15"})	//15-Para
Aadd(aTab,{"PB","16"})	//16-Paraiba
Aadd(aTab,{"PR","17"})	//17-Parana - Usado somente para o DFC
Aadd(aTab,{"PE","18"})	//18-Pernambuco
Aadd(aTab,{"PI","19"})	//19-Piaui
Aadd(aTab,{"RN","20"})	//20-Rio Grande do Norte
Aadd(aTab,{"RS","21"})	//21-Rio Grande do Sul
Aadd(aTab,{"RJ","22"})	//22-Rio de Janeiro
Aadd(aTab,{"RO","23"})	//23-Rondonia
Aadd(aTab,{"RR","24"})	//24-Roraima
Aadd(aTab,{"SC","25"})	//25-Santa Catarina
Aadd(aTab,{"SP","26"})	//26-Sao Paulo
Aadd(aTab,{"SE","27"})	//27-Sergipe
Aadd(aTab,{"MS","28"})	//28-Mata Grosso do Sul
Aadd(aTab,{"TO","29"})	//29-Tocantins

dbSelectArea("TUF")
For nI:=1 To Len(aTab)
	RecLock("TUF",.T.)
	TUF->UF		:= aTab[nI,1]
	TUF->CODIGO	:= aTab[nI,2]
	MsUnlock()
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava Dados no Registro Tipo 1 - Identificao do Contribuinte            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("R01")
RecLock("R01",.T.)
R01->TIPODOC	:= mv_par01
R01->IE		:= aFisFill(Num2Chr(Val(aRetDig(SM0->M0_INSC,.F.)),10,0),10)
R01->CNPJ		:= aFisFill(Num2Chr(Val(aRetDig(SM0->M0_CGC,.F.)),14,0),14)
R01->CPF		:= aFisFill(mv_par02,15)
R01->MODELO	:= IIf(lDFC,"8","")
MsUnlock()

Return Nil
