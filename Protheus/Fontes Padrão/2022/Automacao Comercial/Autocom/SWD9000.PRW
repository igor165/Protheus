#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Classe   ³ LJSweda9000ºAutor  ³ Thiago Honorato    º Data ³  DEZ/05     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Classe da impressora Sweda9000 para a biblioteca AUTOCOM   	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data   ³Bops  ³Manutencao Efetuada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºThiago H. ³14/06/06³101342³Alteracao no metodo IFAbrCNFis() para         º±±
±±º          ³        ³      ³impressao de um Comprovante NAO-FISCAL        º±±
±±º          ³        ³      ³apos a impressao do comprovante TEF.          º±±
±±º          ³        ³      ³Alterado o metodo IFAlimProp() para executar  º±±
±±º          ³        ³      ³uma funcao que ira criar um secao no arquivo 	º±±
±±º          ³        ³      ³SIGALOJA.ini com informacoes das formas de 	º±±
±±º          ³        ³      ³pagamento cadastrada na impressora.           º±±
±±º          ³        ³      ³Caso for incluida mais alguma forma de        º±±
±±º          ³        ³      ³pagamento na impressora, o conteudo gravado naº±±
±±º          ³        ³      ³secao [SWEDA9000] deve ser apagado.           º±±
±±ºThiago H. ³07/02/07³118810³Alterado o metodo PegaRegistro()para a 		º±±
±±º          ³        ³      ³correcao do problema encontrado com o         º±±
±±º          ³        ³      ³posicioanemto das Legendas Nao Fiscais    	º±±
±±ºThiago H. ³07/02/07³118810³Alterado o metodo IFAbrCNFis()para impressao	º±±
±±º          ³        ³      ³correta do numero de parcelas no CUPOM NAO  	º±±
±±º          ³        ³      ³FISCAL.                                     	º±±
±±º          ³        ³      ³Comando .19				 				  	º±±
±±ºThiago H. ³07/02/07³118810³Alterado o metodo IFAutentic()para correcao   º±±
±±º          ³        ³      ³do problema encontrado no momento de realizar º±±
±±º          ³        ³      ³a segunda autenticacao na rotina de         	º±±
±±º          ³        ³      ³RECEBIMENTO DE TITULOS						º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
CLASS LJSweda9000 FROM LJSweda
	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Atributos³
	//ÀÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Metodos  ³
	//ÀÄÄÄÄÄÄÄÄÄÙ 
	METHOD New()
	METHOD IFAutentic(cVezes, cValor,cTexto)//retorna caracter
	METHOD GravaCondPag(cCondicao)//retorna caracter
	METHOD IFAbrCNFis( cCondicao, cValor, cTotalizador, cTexto, nParcelas )//retorna caracter
    METHOD IFRegItem(cCodigo,cDescricao,cQtde,cVlrUnit,cVlrdesconto,cAliquota,cVlTotIt,cUnidMed)//retorna caracter
    METHOD IFDescTot(cVlrDesconto)//retorna caracter
    METHOD IFSupr(nTipo,cValor,cForma,cTotal,nModo)//reorna caracter
    METHOD IFFechaCup(cMensagem)//retorna caracter
    METHOD IFFchCNFis()//retorna caracter
    METHOD IFAlimProp()
	METHOD ProcuraAliq(cAliq)
	METHOD PegaRegistro(cCondicao)
	METHOD IFRecbNFis(cTotalizador, cValor, cForma)	
ENDCLASS


//-------------------------------------------------------------
METHOD New() CLASS LJSweda9000    
Return

//-------------------------------------------------------------
METHOD IFAutentic(cVezes, cValor,cTexto) CLASS LJSweda9000

Local cRet := ""
Local nVz  := 0
Local cRetorno := ""      
Local nVezes := 0
Local lCanc := .T. 

Conout("SWEDA 9000 - METHOD IFAutentic - Inicio - "+ Time() )

nVezes := Val(cVezes)

If nVezes = 0 
   nVezes := 1
Endif

nVz := 1

While nVz <= nVezes .AND. lCanc 
	If nVz == 1 
		cComando := Chr(27) + ".200N" + Replicate(" ",15) + "0N" + Replicate(" ",20) + "}"
		MsgAlert("Posicione o Documento para a "+ AllTrim(Str(nVz)) +"a. Autenticação.")  
		cRet := ::EnviaComando(Chr(27) + ".23}")
		If ".+P050" $ cRet 
			cRet  	  := ::EnviaComando( cComando ) 
		Elseif MsgYesNo("Documento não inserido. Deseja efetuar a autenticação?")
			loop
		Else
			lCanc := .F.
		Endif		
	Else
		cComando := Chr(27) + ".26}"
		MsgAlert("Posicione o Documento para a "+ AllTrim(Str(nVz)) +"a. Autenticação.")     
		If ".+" $ cRet 
			cRet  	  := ::EnviaComando( cComando ) 
		Elseif MsgYesNo("Documento não inserido. Deseja efetuar a autenticação?")
			loop
		Else
			lCanc := .F.
		Endif
	EndIf      
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Da' um tempo para o usuario fazer as duas linhas da autenticacao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Sleep(8000)

	If ::TrataRetorno( 1, cRet ) == "0"
		nVz += 1
	EndIf          
End   

if lCanc
	cRetorno := ::TrataRetorno(1,cRet)// Metodo da classe SWEDA
Endif

Conout("SWEDA 9000 - METHOD IFAutentic - Termino - "+ Time() )

Return Val(cRetorno)


//----------------------------------------------------------------------------
METHOD GravaCondPag(cCondicao) CLASS LJSweda9000
Local cRet    := ""
Local cLinha  := 0
Local aPagto  
Local nCont   := 0
Local nLenPag := 0
Local cRetorno := ""

Conout("SWEDA 9000 - METHOD GravaCondPag - Inicio - "+ Time() )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso desta versao da Sweda, se o primeiro caracter da string           ³
//³condicao for igual a "=" sera' acumulado na legenda NAO-FISCAL "TROCO     ³
//³DE CHEQUE" ou se o primeiro caracter for igual a "#" sera' acumulado na   ³
//³legenda NAO-FISCAL "CONTRA-VALE".                                         ³
//³                                                                          ³
//³Nessa versao a programacao das Modalidades de Pagamento so' pode ser feita³
//³em Modo Intervencao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³Monta vetor com formas existentes³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  cRet  := ::FormasPgto
  aPgto := MontArray(cRet)

  nLenPag := Len(aPagto) - 1
  cRetorno  := "0"
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³Acrescenta os 15 espacos 		  ³
  //³obrigatorios					  ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
  For nCont := 1 to nLenPag 
    aPagto[nCont] := aPagto[nCont] + Space( 15 - Len(aPagto[nCont]))
  Next nCont
  
  If Len(cCondicao ) < 15 
  	cCondicao := cCondicao + Space(15 - Len(cCondicao) )
  Endif            
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³Verifica se ja' existe a forma de³
  //³pagamento						  ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
  For nCont := 1 to nLenPag 
    If Upper (aPagto[nCont]) = Upper(cCondicao)
      MsgStop( "Já existe a condição de pagamento: " + cCondicao )
      Return "4|"
    Endif
  Next nCont
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³Se o contador for igual ao total ³
  //³de formas de pagamento, ja' tem  ³
  //³o total de formas				  ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
  If (nLenPag + 1) = 10 
    MsgStop( "Sem espaço em memória para armazenar a nova forma de pagamento." )
    cRetorno := "6|"
  Endif
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³Monta linha para mandar		  ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
  cLinha := ""
  For nCont := 1 to nLenPag
    cLinha := cLinha + "S"+Upper( SubStr(aPagto[nCont],1,15) )
  Next nCont
  
  cLinha := cLinha + "S" +cCondicao

  If SubStr(cRetorno,1,1) = "0" 
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Grava nova forma de pagamento    ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
    cRet := ::EnviaComando( Chr(27)+".39" + cLinha + "}" )// Metodo da classe SWEDA 
    If ::EnviaComando(1,cRet) <> "0"// Metodo da classe SWEDA 
        MsgStop( "Esse comando tem efeito apenas entre a Redução Z e a primeira venda do dia." )
    Endif
       
    cRetorno := ::EnviaComando(1,cRet)// Metodo da classe SWEDA
  Endif

Conout("SWEDA 9000 - METHOD GravaCondPag - Termino - "+ Time() )

Return cRetorno

//----------------------------------------------------------------------------
METHOD IFAbrCNFis( cCondicao,cValor,cTotalizador,cTexto,nParcelas) CLASS LJSweda9000
Local cRet := ""
Local cNumAnt := ""
Local nI := 0
Local aFormas := {}
Local cFormas := ""
Local cPos := ""
Local cPosTot := ""
Local nPos := 0
Local nTamanho := 0
Local cRetorno := ""
Local nVz := 0
Local lContinua := .T.
Local cTotFormaPagto := ""
Local cTotRecIni := ""  


Conout("SWEDA 9000 - METHOD IFAbrCNFis - Inicio - "+ Time() )

If AllTrim(cTotalizador)= "" 
    cTotalizador := "SIGALOJA"
Endif

nVz := 1
While nVz <= 5 .AND. lContinua
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Pegando o numero do ultimo cupom ³
    //³impresso							³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
	cNumAnt := ::EnviaComando( Chr(27)+".271}")// Metodo da classe SWEDA 
	
	If SubStr( ::TrataRetorno(1,cNumAnt),1,1 ) = "0"// Metodo da classe SWEDA 
	   cNumAnt := SubStr(cNumAnt,14,4)
	   lContinua := .F.
	Else
	   nVz++
	Endif

	If nVz > 5 .AND. lContinua
		Return 1
	Endif

End     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta vetor com formas existentes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
cRet  := ::FormasPgto
While (At("|", cRet) > 0) 
   nPos := At("|", cRet)
   cFormas := SubStr(cRet, 1, nPos-1)
   AAdd(aFormas,cFormas)
   cRet := SubStr(cRet, nPos+1, Len(cRet))
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificando qual o codigo da 	³
//³condicao de pagamento utilizado	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
cPos := "0"
  
For nI := 1 to Len(aFormas) 
   If Upper(AllTrim(aFormas[nI])) = Upper(AllTrim(cCondicao)) 
     cPos := AllTrim(Str(nI))
   Endif  
Next nI  

If Len(cPos) < 2 
  cPos := "0" + cPos
Endif  
cTotFormaPagto := cPos  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abrindo cupom nao fiscal 		³
//³vinculado "00"					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ           
cTotRecIni := GetPvProfString("Recarga Celular", "Totalizador", "", GetClientDir()+"SIGALOJA.INI")

If (cTotRecIni <> cTotalizador)
	cRet := ::EnviaComando( Chr(27)+".1900"+cNumAnt+cPos+Space(20)+StrZero(nParcelas,2)+"}")// Metodo da classe SWEDA 
	cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA

	If SubStr(cRet,1,2) <> ".+"
		cNumAnt := AllTrim(StrZero(Val(cNumAnt)-1, 4 ) ) 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Abrindo cupom nao fiscal 		³
		//³vinculado "00"					³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cRet := ::EnviaComando( Chr(27)+".1900"+cNumAnt+cPos+Space(20)+StrZero(nParcelas,2)+"}")// Metodo da classe SWEDA 
		cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA	
	EndIf
Else
	cRetorno := '1'
EndIf
If SubStr(cRetorno,1,1) = "1" // Impressao do Cupom nao fiscal nao vinculado
	cRet    := " -"
	cValor  := FormataTexto(AllTrim(cValor),12,2,2)
	cRet    := "789ABCD"
	cFormas := ""
    
	For nI := 1 to 7
		cPos     := ::EnviaComando( Chr(27)+".29"+SubStr(cRet,nI,1)+"}")// Metodo da classe SWEDA
		nTamanho := Len(cPos)
		cFormas  := cFormas+SubStr(cPos,8,nTamanho)
	Next nI
	
	cFormas := SubStr(cFormas,31,Len(cFormas))
	aFormas := {}
	While AllTrim(cFormas) <> ""
		AAdd(aFormas, SubStr(cFormas,1,15))
		cFormas := SubStr(cFormas,16,Len(cFormas))
	End
	
	If Val(cTotalizador) > 0//== "C"
		bTotalizadorIsNum := .T.
	Else
		bTotalizadorIsNum := .F.
	EndIf
	cPos       := "0"
	cPosTot    := "0"
	
	For nI := 1 to Len(aFormas)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo.³
		//³Pois a legenda somente podera ser do mesmo titulo.                              ³
		//³Ex.                                                                             ³
		//³01 &GAVETA                -> Titulos                                            ³
		//³02    + Recebimento       -> Legendas                                           ³
		//³03    - Sangria           -> Legendas                                           ³
		//³04 &Sigaloja              -> Titulos                                            ³
		//³05    + Entrada Diversas  -> Legendas                                           ³
		//³06    - Saidas diversas   -> Legendas                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If bTotalizadorIsNum
			cPos  := cTotalizador
			If SubStr(aFormas[nI],1,1)="&"
				cPosTot:= FormataTexto(Str(nI),2,0,2)
			EndIf
			If FormataTexto(AllTrim(Str(nI)),2,0,2) = AllTrim(cPos)
				Exit
			Else
				cPos := "0"	
			EndIf
		Else
			If SubStr(aFormas[nI],1,1)="&"
				cPosTot:= FormataTexto(Str(nI),2,0,2)
			ElseIf AllTrim(Upper(SubStr(aFormas[nI],2,15))) == AllTrim(Upper(cTotalizador))
				cPos := FormataTexto(Str(nI),2,0,2)
				Exit			
			EndIf				
		EndIf

	Next nI

	If cPos == "0"
		Alert("Totalizador " + cTotalizador + " não encontrado na Impressora Fiscal")
		cRet := "1"	
	Else	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Abre o cupom não vinculado		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
		If Len(AllTrim(cPos)) < 2
			cPos := "0" + AllTrim(cPos)
		EndIf
		If Len(AllTrim(cPosTot)) < 2
			cPosTot := "0" + AllTrim(cPosTot)
		EndIf
		oAutocom:cBuffer := Space(128) 
		conout(".19" + cPosTot + "      }")
		
		cRet := ::EnvCmdEspera( Chr(27) +".19" + AllTrim(cPosTot) + "      }" ) 
		conout(cRet)
		If cRet = "0"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz o recebimento nao fiscal		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			oAutocom:cBuffer := Space(128) 
			conout(".07" + cPos + cValor + "}")
			cRet := ::EnvCmdEspera( Chr(27) +".07" + AllTrim(cPos) + cValor + "}", 3 )  
			conout(cRet)
			If cRet = "0"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Faz o recebimento nao fiscal		³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oAutocom:cBuffer := Space(128)  
				conout(".10" + cTotFormaPagto + cValor+"}")
				cRet := ::EnvCmdEspera( Chr(27) +".10" + cTotFormaPagto + cValor+"}", 3 ) 
				conout(cRet)
				If cRet = "0"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Fecha o cupom indicando que 		³
					//³havera' um vinculado				³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oAutocom:cBuffer := Space(128) 
					conout(".12N}")
					cRet := ::EnvCmdEspera( Chr(27) +".12N}", 3 )
					conout(cRet)
					If cRet = "0"
						oAutocom:cBuffer := Space(128)             
						conout(".271}")
						cRet := ::EnvCmdEspera( Chr(27) +".271}", 10 )
						conout(cRet)
						If cRet = "0"
							cNumAnt := SubStr( ::cBuffer, 14, 4 )
							conout(cNumAnt)
							oAutocom:cBuffer := Space(128)
							conout(".1900"+cNumAnt+cTotFormaPagto+"}")
							cRet := ::EnvCmdEspera( Chr(27) +".1900"+cNumAnt+cTotFormaPagto+Space(20)+"01}", 10 ) 
							conout(cRet)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf	
	oAutocom:cBuffer := cRet
	nRet := Val(::TrataRetorno( 1, oAutocom:cBuffer ))
EndIf
Conout("SWEDA 9000 - METHOD IFAbrCNFis - Termino - "+ Time() )

Return Val(cRet)

//----------------------------------------------------------------------------
METHOD ProcuraAliq(cAliq) CLASS LJSweda9000

Conout("SWEDA 9000 - METHOD ProcuraAliq - Inicio - "+ Time() )

cAliq := FormataTexto(cAliq,4,2,1)
cAliq := SubStr(cAliq,1,2)+SubStr(cAliq,4,2)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procura a aliquota no primeiro 	³
//³pacote...						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If At(cAliq,::cCmd293) > 0 
	cRetorno := SubStr(::cCmd293,At(cAliq,::cCmd293)-3,3)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso nao encontre no primeiro 	³
	//³pacote. Procura a aliquota no 	³
	//³segundo pacote					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If At(cAliq,::cCmd294) > 0 
    	cRetorno := SubStr(::cCmd294,At(cAliq,::cCmd294)-3,3)
    Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso nao encontre no segundo  	³
		//³pacote. Procura a aliquota no 	³
		//³ultimoo pacote					³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    	
        If At(cAliq,::cCmd295) > 0
        	cRetorno := SubStr(::cCmd295,At(cAliq,::cCmd295)-3,3)
        Else
            cRetorno := "T  "
        Endif
    Endif
Endif

Conout("SWEDA 9000 - METHOD ProcuraAliq - Termino - "+ Time() )

Return cRetorno
//----------------------------------------------------------------------------
METHOD IFRegItem(cCodigo,cDescricao,cQtde,cVlrUnit,cVlrdesconto,cAliquota,cVlTotIt,cUnidMed) CLASS LJSweda9000
 
Local cAliq     := ""
Local cSituacao := ""
Local cRet      := ""
Local aAliq 	:= {}
Local nPos		:= 0
Local nI		:= 0
Local nTamanho  := 0
Local nSeqAtual := 0
Local cRetorno  := 0

Conout("SWEDA 9000 - METHOD IFRegItem - Inicio - "+ Time() )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a casa decimal dos 		³
//³parametros						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    	
cQtde := AllTrim(StrTran(cQtde,",","."))
cVlrUnit := AllTrim(StrTran(cVlrUnit,",","."))
cVlrDesconto := AllTrim(StrTran(cVlrDesconto,",","."))
cVlTotIt := AllTrim(StrTran(cVlTotIt,",","."))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se e' para registra a 	³
//³venda do item ou so' o desconto	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    	
If AllTrim(cCodigo+cDescricao+cQtde+cVlrUnit) = "" 
	If Val(cVlrdesconto) <> 0 
	   	cRet := ::EnviaComando(Chr(27)+".02"+"0000"+FormataTexto(cVlrdesconto,12,2,2)+"}")// Metodo da classe SWEDA 
		cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA
    Else
    	cRetorno := "0"
    Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz o tratamento da aliquota		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    	
	cSituacao := SubStr(cAliquota,1,1)
	cAliquota := AllTrim(SubStr(cAliquota,2,5))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a aliquota eh     ³
	//³ISENTA,                       ³
	//³com  SUBSTITUICAO TRIBUTARIA, ³
	//³NAO TRIBUTAVEL OU ISS         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cSituacao = "T" 
		aAliq := MontArray(AllTrim(::Aliquotas))  
	    nPos := 0
	    For nTamanho := 1 to Len(aAliq)
	      If AllTrim(aAliq[nTamanho]) == AllTrim(cAliquota)
	        If nPos = 0 
	          nPos := nTamanho + 1
	        Endif  
	      Endif
	    Next nTamanho
	    
	    If (nPos = 0) .AND. (At(cSituacao,"TS") > 0) 
	      MsgStop("Aliquota não cadastrada.")
	      cRetorno := "1|"
	    Else
		    cAliq := ::ProcuraAliq(cAliquota)
	    Endif
	    
	ElseIf AllTrim(cSituacao) = "I" 
	    cAliq:= "I  "
	ElseIf AllTrim(cSituacao) = "F" 
		cAliq:= "F  "
	ElseIf AllTrim(cSituacao) = "N" 
	    cAliq:= "N  "
	Else
	    cAliq := "T0 "
	Endif
	  
	  
	cVlTotIt   := FormataTexto(cVlTotIt,12,2,2)
	cVlrUnit   := FormataTexto(cVlrUnit,9,2,2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua o registro do item		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    			
	cCodigo := Padl(AllTrim(cCodigo),13,"0")
	cRet := ::EnviaComando( Chr(27)+".01"+ cCodigo+;
                                            FormataTexto(cQtde,7,3,2)+;
                                            cVlrUnit+;
                                            cVlTotIt+;
                                            SubStr(cDescricao+Space(24),1,24)+;
                                            cAliq + "06" + "}")// Metodo da classe SWEDA                                               	                                              
	If ((cRet = ".-P006}") .OR. (cRet = ".-P002}") )
		nI := 0
	 	While ((nI < 3) .OR. (SubStr(cRet,2,1) != "+"))
	 		cRet := ::EnviaComando( Chr(27)+".23}")// Metodo da classe SWEDA
			nI++
	    End
	
		If (SubStr(cRet,2,1)="+") 
			nSeqAtual := Val(SubStr(cRet, 9, 4))
			If nSeqAtual = (::nUltimoSeq +1)
				cRet := SubStr(cRet, 7, 7)
			Else
				cRetorno := ::TrataRetorno (1, cRet)// Metodo da classe SWEDA
			Endif    
		Else
	    	cRetorno := ::TrataRetorno (1, cRet)// Metodo da classe SWEDA
	    Endif	
	ElseIf At(".-", cRet) > 0 
			cRetorno := ::TrataRetorno (1, cRet)// Metodo da classe SWEDA
	Else
		::nUltimoSeq := Val(SubStr(cRet, 3, 4))
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se houve erro no registro do item e registra o ³
	//³desconto                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SubStr( ::TrataRetorno(1,cRet),1,1 ) = "0"// Metodo da classe SWEDA 
		If val(cVlrdesconto) <> 0 
	      cRet := ::EnviaComando( Chr(27)+".02"+"0000"+FormataTexto(cVlrdesconto,12,2,2) + "}")// Metodo da classe SWEDA 
	    Endif  
	Endif

Endif

cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA

Conout("SWEDA 9000 - METHOD IFRegItem - Termino - "+ Time() )

Return Val(cRetorno)

//----------------------------------------------------------------------------
METHOD IFDescTot(cVlrDesconto) CLASS LJSweda9000
Local cRet := ""
Local cRetorno := ""

Conout("SWEDA 9000 - METHOD IFDescTot - Inicio - "+ Time() )

cRet := ::EnviaComando( Chr(27)+".03"+"0000"+FormataTexto(cVlrDesconto,12,2,2)+"S}")// Metodo da classe SWEDA 
cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA

Conout("SWEDA 9000 - METHOD IFDescTot - Termino - "+ Time() )
  
Return Val(cRetorno)

//----------------------------------------------------------------------------
METHOD PegaRegistro(cCondicao) CLASS LJSweda9000

Local cRet         := ""
Local nI           := 0
Local aFormas      := {}
Local cFormas      := ""
Local cPos         := ""
Local lIndiceTot   := .T.
Local nTamanho     := 0
Local cTotalizador := ""

Conout("SWEDA 9000 - METHOD PegaRegistro - Inicio - "+ Time() )

cRet    := "789ABCD"
cFormas := ""

For nI := 1 to 7 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Lendo todos as descricoes dos 	³
	//³registradores.					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    			
	cPos := ::EnviaComando( Chr(27)+".29"+SubStr(cRet,nI,1)+"}")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criado devido ao Sistema 		³
	//³Operacional LINUX, que nao 		³
	//³traz o "}" 						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    			
	If At("}",cPos) = 0
		cPos := cPos + "}"
	Endif
	nTamanho := (At("}",cPos)-1) - 7
	cFormas  := cFormas+SubStr(cPos,8,nTamanho)
Next nI        
cFormas := SubStr(cFormas,31,Len(cFormas))

While AllTrim(cFormas) <> "" 
	AAdd(aFormas, SubStr(cFormas,1,15))
	cFormas := SubStr(cFormas,16,Len(cFormas))
End

cPos         := "00"
cTotalizador := "00"
lIndiceTot   := .F.

For nI := 1 to Len(aFormas)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo.³
	//³Pois a legenda somente podera ser do mesmo titulo.                              ³
	//³Ex.                                                                             ³
	//³01 &GAVETA                 -> Titulos                                           ³
	//³02    + Recebimento        -> Legendas                                          ³
	//³03    - Sangria            -> Legendas                                          ³
	//³04 &Sigaloja               -> Titulos                                           ³
	//³05    + Entrada Diversas   -> Legendas                                          ³
	//³06    - Saidas diversas    -> Legendas                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (SubStr(aFormas[nI],1,1) = "&") .AND. (lIndiceTot = .F.)
		cTotalizador := "00"
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pegar o codigo do titulo			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    				
	If SubStr(AllTrim(Upper(aFormas[nI])),1,1) == "&"
		cTotalizador := FormataTexto(Str(nI),2,0,2)
		lIndiceTot   := .T.
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pegar o codigo da Legenda		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( AllTrim(Upper(SubStr(aFormas[nI],2,15))) = AllTrim(Upper(cCondicao)) ) .AND.(cTotalizador <> "00" ) 
		cPos := FormataTexto(Str(nI),2,0,2)
	Endif

Next nI
If Len (AllTrim(cPos)) == 1
	cPos := "0" + AllTrim(cPos)
Endif

If Len (AllTrim(cTotalizador)) == 1
	cTotalizador := "0" + AllTrim(cTotalizador)
Endif

cRetorno := AllTrim(cPos)+AllTrim(cTotalizador)  

Conout("SWEDA 9000 - METHOD PegaRegistro - Termino - "+ Time() )

Return cRetorno

//----------------------------------------------------------------------------
METHOD IFSupr(nTipo,cValor,cForma,cTotal,nModo) CLASS LJSweda9000

Local cRet 		:= ""
Local nI   		:= 0
Local aFormas 	:= {}
Local cFormas 	:= ""
Local cPos 		:= ""
Local nTamanho  := 0
Local cCondicao := ""
Local aPgto 	:= {}
Local cRetorno  := ""

Conout("SWEDA 9000 - METHOD IFSupr - Inicio - "+ Time() )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tipo = 1 - Verifica se tem troco disponivel		³
//³Tipo = 2 - Grava o valor informado no Suprimentos³
//³Tipo = 3 - Sangra o valor informado				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    					
cRet := " -"
cCondicao := cForma
cValor    := FormataTexto(cValor,12,2,2)
cRet      := "789ABCD"
cFormas   := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se tem troco disponivel	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo = 1 
	cRet    :="67"
    For nI  := 1 to 2 
	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  //³Lendo os totais das modalidades  ³
	  //³de pagamento					  ³
	  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      cPos     := ::EnviaComando( Chr(27)+".27"+SubStr(cRet,nI,1)+"}")// Metodo da classe SWEDA 
      nTamanho := (At("}",cPos)-1) - 7
      If nI = 2 
        cFormas  := cFormas+SubStr(cPos,8,48)
      Else
        cFormas  := AllTrim(SubStr(cPos,8,nTamanho))
      Endif
      
      While AllTrim(cFormas) <> "" 
        AAdd(aFormas, SubStr(cFormas,5,12))
        cFormas := SubStr(cFormas,17,Len(cFormas))
      End
    Next nI
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Le as condicoes de pagamento		³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    cRet := ::IFLeConPag()//Metodo da classe SWEDA
    cRet := SubStr(cRet, 3, Len(cRet))
    aPgto := MontArray(cRet)
    
    For nI := 1 to Len(aPgto)
	  If Upper(AllTrim(aPgto[nI]))="DINHEIRO" 
        cPos:=Str(nI)
        Exit
      End
    Next nI
    
    If Val(aFormas[Val(sPos)]) >= Val(Valor)
      Return "8"
    Else
      Return "9" 
    Endif
Else
	cFormas :="DINHEIRO"
	If AllTrim(SubStr(cForma,3,Len(cForma))) <> "" 
		cFormas := AllTrim(SubStr(cForma,3,Len(cForma)))
	Endif
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Grava o valor informado no 		³
    //³Suprimentos						³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	  
	If (nTipo = 2) .AND. (AllTrim(cForma) = "") 
		cCondicao:="FUNDO DE CAIXA"
	Endif  
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Sangra o valor informado			³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	  	  
	If (nTipo = 3) .AND. (AllTrim(cForma) = "")
		cCondicao:="SANGRIA"
	Endif
	  	
	If ( AllTrim(SubStr(cForma,1,2)) <> "") .AND. (AllTrim(SubStr(cTotal,1,2)) <> "")
		cPos := SubStr(cForma,1,2) + SubStr(cTotal,1,2)
	Else
		cPos := ::PegaRegistro( cCondicao)
	Endif
	If (AllTrim(SubStr(cTotal,1,2)) = "") .AND. ((SubStr(cPos,1,2) = "00") .OR. (SubStr(cPos,3,2) = "00")) 
	    MsgStop("Não existe o Totalizador Não-Fiscal "+cCondicao+;
	      		'" dentro do Título Não-Fiscal "SIGALOJA".'+Chr(13)+'Adicione-o após uma Redução Z e antes de realizar uma venda.')
	    cRetorno := "1"
	Else
		cRet := ::EnviaComando( Chr(27)+".19" + SubStr(cPos,3,2)+ Space(26)+"00}")// Metodo da classe SWEDA 
		cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA
		Sleep(2000)
		If SubStr(cRetorno,1,1) = "0" 
			cRet := ::EnviaComando( Chr(27)+".07" + SubStr(cPos,1,2)+cValor+"}")// Metodo da classe SWEDA 
		    cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA
		    If SubStr(cRetorno,1,1) = "0"
		      Sleep(500)
		      If nTipo = 2
				cValor   := AllTrim(Str(Val(cValor)))
		        ::IFPagto(cFormas+"|"+cValor,"N")
		        Sleep(500)
		      Endif
		    Endif
		    cRet := ::EnviaComando( Chr(27)+".12N}")// Metodo da classe SWEDA 
		    Sleep(2000)
		    cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA
		Endif
	Endif
Endif

Conout("SWEDA 9000 - METHOD IFSupr - Termino - "+ Time() )

Return Val(cRetorno)

//----------------------------------------------------------------------------
METHOD IFFechaCup(cMensagem) CLASS LJSweda9000
Local cRet := ""
Local cLinha := ""
Local cCmd := ""
Local nLinha := 0
Local nX := 0
Local cRetorno := ""

Conout("SWEDA 9000 - METHOD IFFechaCup - Inicio - "+ Time() )
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Laco para imprimir toda a 		³
    //³mensagem							³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	  	      
    nLinha := 0
    cCmd := ""
    While (AllTrim(cMensagem) <> "" ) .AND. (nLinha < 9 )
 	  cLinha := ""
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³Laco para pegar 40 caracter do   ³
      //³Texto							  ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	  	      
      For nX := 1 to 40 
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      	 //³Caso encontre um CHR(Line Feed)  ³
    	 //³imprime a linha					 ³
	     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	  	      
         If SubStr(cMensagem,nX,1) = Chr(10)
            Exit
         Endif
         cLinha := cLinha+SubStr(cMensagem,nX,1)
  	  Next nX	
  	  
      cLinha := SubStr(cLinha+space(40),1,40)
      cCmd := cCmd+"0"+cLinha
      cMensagem := SubStr(cMensagem,nX+1,Len(cMensagem))

      nLinha++
    End
    cRet := ::EnviaComando( Chr(27)+".12N"+cCmd+"}")// Metodo da classe SWEDA 
    cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Tempo necessario para aguardar a ³
    //³Finalizacao do Cupom				³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Sleep(4000)

Conout("SWEDA 9000 - METHOD IFFechaCup - Termino - "+ Time() )

Return Val(cRetorno)

//----------------------------------------------------------------------------
METHOD IFFchCNFis() CLASS LJSweda9000
Local cRet 		:= ""
Local cRetorno  := ""
Local nI		:= 0 // controle de loop
  
Conout("SWEDA 9000 - METHOD IFFchCNFis - Inicio - "+ Time() )

For nI := 1 to 2 
  cRet   := ::EnviaComando( Chr(27)+".12}")// Metodo da classe SWEDA 
  cRetorno := ::TrataRetorno( 1,cRet )// Metodo da classe SWEDA
Next nI 

Conout("SWEDA 9000 - METHOD IFFchCNFis - Termino - "+ Time() )

Return Val(cRetorno)

//------------------------------------------------------------
// Propriedades da impressora
METHOD IFAlimProp() CLASS LJSweda9000
Local  cRet1 	:= ""
Local  cRet2 	:= ""
Local  cRet3 	:=	""
Local  cRet4 	:= ""
Local  cRetorno := ""
Local  cForma 	:= ""
Local  cLinha 	:= ""
Local  cAux 	:= ""
Local  nI 		:= 0

Conout("SWEDA 9000 - METHOD IFAlimProp - Inicio - "+ Time() )
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³Aliquotas de ICMS				  ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
  nI :=0 
  cComando := Chr(27)+".293}"
  cRet1 := ::EnviaComando( cComando )
  ::cCmd293 := cRet1
  nI += 1
  While ((SubStr(cRet1,2,1) == "-") .AND. (nI < 20))
     cRet1 := ::EnviaComando( cComando )
     ::cCmd293 := cRet1
     nI += 1
  End

  nI := 0 
  cComando := Chr(27)+".294}"
  cRet2 := ::EnviaComando( cComando )
  ::cCmd294 := cRet2
  nI += 1
  While ((SubStr(cRet2,2,1) == "-") .AND. (nI < 20))
     cRet2 := ::EnviaComando( cComando )
     ::cCmd294 := cRet2
     nI += 1
  End

  nI := 0
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³cria uma secao no SIGALOJA.ini com informacoes do comando .295³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  cRet3 := GetPvProfString( "SWEDA9000", "Comando 295", "", GetClientDir() + "SIGALOJA.INI" )
  If Empty(cRet3)
	  cComando := Chr(27)+".295}"
	  cRet3 := ::EnviaComando( cComando )
	  ::cCmd295 := cRet3 
	  WritePProString( "SWEDA9000", "Comando 295", cRet3, GetClientDir() + "SIGALOJA.INI" )
	  nI += 1
	  While ((SubStr(cRet3,2,1) == "-") .AND. (nI < 20))
	     cRet3 := ::EnviaComando( cComando )
		 WritePProString( "SWEDA9000", "Comando 295", cRet3, GetClientDir() + "SIGALOJA.INI" )	     
		 ::cCmd295 := cRet3
		 nI += 1
	  End 
  Endif
  nI := 0
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³cria uma secao no SIGALOJA.ini com informacoes do comando .296³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  cRet4 := GetPvProfString( "SWEDA9000", "Comando 296", "", GetClientDir() + "SIGALOJA.INI" )  
  If Empty(cRet4)
	  cComando := Chr(27)+".296}"
	  cRet4 := ::EnviaComando( cComando )
	  ::cCmd296 := cRet4
      WritePProString( "SWEDA9000", "Comando 296", cRet4, GetClientDir() + "SIGALOJA.INI" )	  
	  nI += 1
	  While ((SubStr(cRet4,2,1) == "-") .AND. (nI < 20))
	     cRet4 := ::EnviaComando( cComando )
	  	 WritePProString( "SWEDA9000", "Comando 296", cRet4, GetClientDir() + "SIGALOJA.INI" )	     
	     ::cCmd296 := cRet4
		 nI += 1
	  End
  Endif
  ::IFPegPDV()
  Conout("SWEDA 9000 - METHOD IFAlimProp Len(cRet3) antes" + Str(Len(cRet3)))  
  If Len(cRet3) < 128
  	cRet3 := cRet3 + Space(128 - Len(cRet3))
  Endif
  Conout("SWEDA 9000 - METHOD IFAlimProp Len(cRet3) depois" + Str(Len(cRet3)))  
  cLinha := ""
  If (SubStr(::TrataRetorno(1,cRet1),1,1) <> "0") .OR. (SubStr(::TrataRetorno(1,cRet2),1,1) <> "0") .OR. (SubStr(::TrataRetorno(1,cRet3),1,1) <> "0")// Metodo da classe SWEDA 
    ::Aliquotas := cLinha
  Else
	  cRetorno := SubStr(cRet1,49,28) + SubStr(cRet2,8,49) + SubStr(cRet3,8,28)
	
	  nI := 0
	  While (nI <= 15) .AND. (AllTrim(SubStr(cRetorno,(7 * nI)+1,7)) <> "") 
	    cAux := Str(Val(SubStr(cRetorno,(7 * nI) + 4,4)))
	    If (FormataTexto(cAux,4,2,2) <> "0000") 
	      If SubStr(cRetorno,(7 * nI) + 1,1) = "T" 
	        cLinha := cLinha + FormataTexto(cAux,4,2,1,".") + "|"
	      Endif  
	    Endif    
	    nI += 1
	  End
	  ::Aliquotas := cLinha
	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  //³Aliquotas de ISS 				  ³
	  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  	
	  cLinha := ""
	  If (SubStr(::TrataRetorno(1,cRet1),1,1) <> "0") .OR. (SubStr(::TrataRetorno(1,cRet2),1,1) <> "0") .OR. (SubStr(::TrataRetorno(1,cRet3),1,1) <> "0")// Metodo da classe SWEDA 
	    ::ISS := cLinha
	  Endif  
	  
	  cRetorno := SubStr(cRet1,49,28) + SubStr(cRet2,8,49) + SubStr(cRet3,8,28)
	  nI := 0
	  While (nI <= 15) .AND. (AllTrim(SubStr(cRetorno,(7 * nI) + 1,7)) <> "") 
	    cAux := Str(Val(SubStr(cRetorno,(7 * nI) + 4,4)))
	    If (FormataTexto(cAux,4,2,2) <> "0000") 
	      If SubStr(cRetorno,(7 * nI) + 1,1) = "S" 
	        cLinha := cLinha + FormataTexto(cAux,4,2,1,".") + "|"
	      Endif  
	    Endif    
	    nI += 1
	  End
	
	  ::ISS := cLinha
	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  //³Formas de Pagamento			  ³
	  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  		
	  cLinha := ""
	  If (SubStr(::TrataRetorno(1,cRet3),1,1) <> "0") .OR. (SubStr(::TrataRetorno(1,cRet4),1,1) <> "0")// Metodo da classe SWEDA
	    ::FormasPgto := cLinha
	  Else
		  cForma := SubStr(cRet3,36,48) + SubStr(cRet4,8,112)
		  For nI := 0 to 9 
		    If nI = 0 
		        cAux := AllTrim(SubStr(cForma,2,15))
		    Else
		        cAux := AllTrim(SubStr(cForma,(nI*16)+2,15))
		    Endif    
		    If cAux <> "" 
		      cLinha := cLinha + cAux + "|"
		    Endif  
		  Next nI
	  ::FormasPgto := cLinha	  
  	  Endif
  Endif

Conout("SWEDA 9000 - METHOD IFAlimProp - Termino - "+ Time() )

Return cRetorno

User Function ()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³IFRecbNFisºAutor  ³Adrianne            ºData  ³  xx/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre um comprovante nao fiscal	                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA / FRONTLOJA, interfaces de venda  - Autocom.dll    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAdrianne  ³08/07/05 - 811 ³BOPS: 83590 								  º±±
±±º          ³               ³- Implementacao do Recebimento Nao Fiscal   º±±
±±º          ³               ³- Correcao/Melhorias na funcao IFAbrCNFis   º±±
±±º          ³               ³- Correcao na funcao IFTxtNFis, para tratar º±±
±±º          ³               ³  corretamente o numero de vias do compro-  º±±
±±º          ³               ³  vante									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndre M.  ³22/07/05 - 811 ³Correcao do BOPS: 83590                     º±±
±±º			 ³				 ³- Inicializado a vairavel  nUltimoSeq := 1  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAdrianne  ³16/09/05 - 811 ³Correcao do BOPS: 86386                     º±±
±±º			 ³				 ³- Alterado comando de fechamento do compro- º±±
±±º			 ³				 ³vante nao-fiscal. Ocorria erro no recebimen º±±
±±º			 ³				 ³to no Front Loja.                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
METHOD IFRecbNFis(cTotalizador, cValor, cForma) CLASS LJSweda9000
Local cRet     				//Retorno na impressora
Local cRetorno	:= ""	 	// Retorno da função
Local cPos
Local nVz 		:= 0   	 	// Controle de laco
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tem que escrever no SIGALOJA.INI o acumulador que vai ser utilizado para o recebimento. 	   ³
//³Ex.:																						   ³
//³                                                                                            ³
//³[Recebimento Titulos]                                                                       ³
//³Totalizadores=RECEBIMENTO                                                                   ³
//³                                                                                            ³
//³Esse totalizador deverá estar abaixo do título &SIGALOJA.                                   ³
//³Ex.:                                                                                        ³
//³                                                                                            ³
//³04 &SIGALOJA              -> Titulos                                                        ³
//³05    + FUNDO DE CAIXA    -> Legendas                                                       ³
//³06    + RECEBIMENTOS      -> Legendas                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Conout("SWEDA 9000 - METHOD IFRecbNFis - Inicio - "+ Time() )
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³A forma de pagamento a ser 		³
    //³utilizada nesse comprovante, 	³
    //³sera' a apontada no parametro 	³
    //³MV_NATRECEB						³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  		

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Inicializada a variavel 			³
    //³nUltimoSeq						³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  		
	::nUltimoSeq := 1 
    cValor   :=FormataTexto(AllTrim(cValor),12,2,2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz um controle de 5 tentativas ³
	//³ para registrar o recebimento 	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While nVz <= 5 .AND. SubStr(cRetorno,1,1) <> "0"

	    cPos := ::PegaRegistro(cForma)  
	                                                           
	    cRet := ::EnviaComando( Chr(27)+".19" + SubStr(cPos,3,2)+ "      " + Space(20) + "}")
	    cRetorno := ::TrataRetorno( 1,cRet )
	    if SubStr(cRetorno,1,1) = "0"
	       Sleep(2000)
	       cRet := ::EnviaComando( Chr(27) + ".07" + SubStr(cPos,1,2) + cValor + "}")
	       cRetorno := ::TrataRetorno( 1,cRet )
	       Sleep(500)
	       cValor := AllTrim(cValor)
	
	       cRet:=::IFPagto(cForma+"|"+cValor,"N")
	
	       if SubStr(cRetorno,1,1) = "0" 
	          cRet := ::EnviaComando( Chr(27)+	".12}")
	          Sleep(2000)
	          cRetorno := ::TrataRetorno( 1,cRet )
	       Endif
	    Endif   
	    
	    nVz ++ 
	    Sleep(1000)
	End
	    
Conout("SWEDA 9000 - METHOD IFRecbNFis - Termino - "+ Time() )
	    
Return (Val(cRetorno))
