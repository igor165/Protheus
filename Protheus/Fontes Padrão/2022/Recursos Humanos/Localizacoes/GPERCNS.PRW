#Include "PROTHEUS.CH"
#INCLUDE "GPERCNS.CH" 
#DEFINE   nColMax	2350
#DEFINE   nLinMax  2900
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPERCNS  ³ Autor ³ Erika Kanamori        ³ Data ³ 03.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Geracao do Comprobante de Pago Mensual de Aportes           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPERCNS()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³Cham. ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Leandro Dr. ³30/10/08³004801³Validacao do periodo fechado.             ³±±
±±³R.Berti     ³25/04/12³TEUBWI³Corrigido error log qdo parâmetro Mes/Ano ³±±
±±³            ³        ³      ³deixado em branco.              		  ³±±
±±³M. Silveira ³18/03/13³TGUIA3³Ajuste para gerar o relatorio para mais de³±±
±±³            ³        ³      ³uma caixa de saude conforme os parametros.³±±
±±³A.Shibao    ³09/10/13³THQ311³Ajuste no layout conforme modelo boliviano³±±
±±³Claudinei S.³05/11/13³THZFAZ³Incluidos os valores de importe para cada ³±±
±±³            ³        ³      ³um dos afastamentos.                      ³±±
±±³Claudinei S.³18/11/13³THOVO4³Incluidos os valores de enfermedad profe- ³±±
±±³            ³        ³      ³sional e novos campos conforme o leiaute. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function GPERCNS()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Locais (Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cDesc1 		:= STR0001		//"Comprobante de Pago Mensual de Aportes"
Local cDesc2 		:= STR0002		//"Se imprimira de acuerdo con los parametros solicitados por el usuario."
Local cDesc3 		:= STR0003		//""Obs.: Debe imprimirse un Formulario Mensual para cada Filial.""
Local cString		:= "SRA"        // alias do arquivo principal (Base)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Private(Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private nomeprog	:= "GPERCNS"
Private aReturn 	:= { , 1,, 2, 2, 1,"",1 }	
Private nLastKey 	:= 0
Private cPerg   	:= "GPRCNS"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis Utilizadas na funcao de Impressao                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private Titulo		:= STR0001		//"Comprobante de Pago Mensual de Aportes" - titulo da janela de pergunte
Private nTamanho	:= "M" 
Private nOrdem         
Private cFilialDe   := ""
Private cFilialAte  := "" 
Private cMes		:= ""
Private cAno		:= ""
Private cMatDe      := ""
Private cMatAte     := ""
Private cCustoDe    := ""
Private cCustoAte   := ""
Private cNomeDe     := ""
Private cNomeAte    := "" 
Private cSit		:= ""
Private cCat		:= "" 
Private cCajaDe		:= ""
Private cCajaAte	:= ""
Private cNumFol		:= ""
Private cNumComp	:= ""
Private dDataRef	:= cToD("//")
Private aTabS004 	:= {}
Private aTabS007 	:= {}
Private lEnd

Private oPrint
Private oFont12, oFont10, oFont14n, oFont09 

	oFont12	:= TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)
	oFont10 := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	oFont14n:= TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)     //Negrito//
	oFont09	:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
	oFont07	:= TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
	oFont06	:= TFont():New("Courier New",06,06,,.F.,,,,.T.,.F.)
	oFont05	:= TFont():New("Courier New",05,05,,.F.,,,,.T.,.F.)

nEpoca:= SET(5,1910)
//-- MUDAR ANO PARA 4 DIGITOS 
SET CENTURY ON     

//Checa se foram criados os campos e tabelas usadas no GPER715.
If !fValSx3CNS()
	Return()
EndIf

//Verifica se a tabela S007 esta atualizada.
dDataRef := cToD( "01/" + cMes + "/" + cAno)
fCarrTab ( @aTabS007, "S007", dDataRef, .T.)            			            

If (Len(aTabS007) < 0 .Or. Len(aTabS007[1]) < 15) 
	MsgAlert( oemToAnsi(STR0057))
	Return()
EndIf

        
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Atualiza Help Pergunte  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
AjustaHlp()

pergunte("GPRCNS",.F.)  

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Envia controle para a funcao SETPRINT                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
wnrel:="GPERCNS"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,nTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis utilizadas para parametros                         ³
³ mv_par01        //  Filial De						           ³ 
³ mv_par02        //  Filial Ate					           ³
³ mv_par03        //  Mes/Ano?     				               |
³ mv_par04        //  Matricula De                             ³
³ mv_par05        //  Matricula Ate                            ³
³ mv_par06        //  Centro de Custo De                       ³
³ mv_par07        //  Centro de Custo Ate                      ³   
³ mv_par08        //  Nome De                                  ³
³ mv_par09        //  Nome Ate                                 ³
³ mv_par10        //  Situações a imp?                         ³
³ mv_par11        //  Categorias a imp?                        ³                 
³ mv_par12        //  Caixa De?                                ³
³ mv_par13        //  Caixa Ate?                               ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nOrdem   	:= aReturn[8]

cFilialDe 	:= mv_par01
cFilialAte  := mv_par02 
cMes 		:= substr( mv_par03, 1, 2 ) 
cAno 		:= substr( mv_par03, 3, 4 )
cMatDe		:= mv_par04
cMatAte     := mv_par05
cCustoDe    := mv_par06
cCustoAte   := mv_par07   
cNomeDe		:= mv_par08
cNomeAte	:= mv_par09
cSit        := mv_par10
cCat        := mv_par11            
cCajaDe		:= mv_par12
cCajaAte	:= mv_par13
cNumFol		:= mv_par14
cNumComp	:= mv_par15


	//-- Objeto para impressao grafica
	oPrint 	:= TMSPrinter():New( STR0001 ) //"Comprobante de Pago Mensual de Aportes"
 	oPrint:SetPortrait()                

Titulo := ( STR0001 ) //"Comprobante de Pago Mensual de Aportes" 
											 
RptStatus({|lEnd| IMPCNS(@lEnd,wnRel,cString,.F. )},Capital(Titulo))   

	oPrint:Preview()  							// Visualiza impressao grafica antes de imprimir
                                                                              
Return                       


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPCNS    ºAutor  ³Erika Kanamori      º Data ³  03/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IMPCNS()                 
            
Local cAcessaSRA	:= &( " { || " + ChkRH( "GPERCNS" , "SRA", "2" ) + " } " )       

Local nSavRec
Local nSavOrdem
Local nAux
Local cVerCodFol
Local nCajaSalud
Local aPerAberto	:= {}
Local aPerFechado	:= {}
Local aPerTodos		:= {}
Local aCodFol		:= {} 
Local cFim 			:= ""
Local cFilAnt		:= ""   

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis para controle em ambientes TOP.                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/ 
Local cAlias   := ""   
Local cQrySRA := "SRA"   
Local cQuery        
Local aStruct  := {}      
Local lQuery  := .F.   
Local cSitu
Local cCateg


//Vaviaveis private para impressao  

Private aInfo		:= {}      
Private cNit
Private cEmplead    
Private nTotFunc    := 0 
Private nTotSal     := 0
Private nTotAfas    := 0
Private nTotEnferm	:= 0
Private nTotMatern	:= 0
Private nTotAciden	:= 0
Private nTotEnfPro  := 0
Private nEnferm     := 0
Private nMatern     := 0
Private nAciden     := 0
Private nEnfermPro  := 0
Private nCNSSeg     := 0
Private nCotiz      := 0
Private cActividad  := ""  
Private cModulo	    := ""  
Private cIdRepLeg	:= ""

#IfDef TOP    			
		
	//Filtra do SRA: filial, matricula de/ate, centro de custo de/ate, categoria e situacoes   
		cAlias := "SRA"
	
		cQrySRA := "QSRA"
		       
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Buscar Situacao e Categoria em formato para SQL              ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/ 
		cSitu   := "("
		For nAux := 1 To (Len( cSit )-1)
			cSitu += "'" + Substr( cSit, nAux, 1) + "',"
		Next nAux
		cSitu 	+= "'" + Substr( cSit, len(cSit), 1) + "')"

		cCateg   := "("
		For nAux := 1 To (Len( cCat )-1)
			cCateg += "'" + Substr( cCat, nAux, 1) + "',"
		Next nAux
		cCateg	+= "'" + Substr( cCat, len(cCat), 1) + "')"


		//montagem da query
		cQuery := "SELECT"
        cQuery += " RA_FILIAL,RA_MAT,RA_NOME,RA_CC,RA_ADMISSA,"
        cQuery += " RA_CATFUNC,RA_SITFOLH,RA_CAJSAL"
		cQuery += " FROM " + RetSqlName(cAlias)
		cQuery += " WHERE"
		cQuery += " RA_FILIAL BETWEEN '" + cFilialDe + "' AND '" + cFilialAte + "'"
		cQuery += " AND RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'"
		cQuery += " AND RA_NOME BETWEEN '" + cNomeDe + "' AND '" + cNomeAte + "'"
		cQuery += " AND RA_CC BETWEEN '" + cCustoDe + "' AND '" + cCustoAte + "'"
		cQuery += " AND RA_CAJSAL BETWEEN '" + cCajaDe + "' AND '" + cCajaAte + "'"
		cQuery += " AND RA_SITFOLH IN " + cSitu
		cQuery += " AND RA_CATFUNC IN " + cCateg
		cQuery += " AND D_E_L_E_T_ <> '*'"
		cQuery += " ORDER BY RA_FILIAL, RA_MAT"

		cQuery := ChangeQuery(cQuery)      
		aStruct := (cAlias)->(dbStruct())  

		If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRA,.T.,.T.)
			For nAux := 1 To Len(aStruct)
				If ( aStruct[nAux][2] <> "C" )
					TcSetField(cQrySRA,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
				EndIf
			Next nAux
		Endif  

	lQuery := .T.
	dbSelectArea(cQrySRA)
	(cQrySRA)->(dbGoTop())		 
   
#ELSE
	   
		dbSelectArea("SRA")
		nSavRec   := RecNo()
		nSavOrdem := IndexOrd()
		dbSetOrder(1)
		dbSeek( cFilialDe + cMatDe, .T. )
		
#ENDIF		 

	cFim     := cFilialAte + cMatAte	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Regua de Processamento                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	(cQrySRA)->( SetRegua(RecCount()) )
	SetPrc(0,0)   
	
	
	While (cQrySRA)->(!Eof()) .And. ((cQrySRA)->(RA_FILIAL+RA_MAT) <= cFim )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Movimenta Regua de Processamento                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      
	    IncRegua() 
	     
		If lEnd
			@Prow()+1,0 PSAY cCancel
			Exit
	    Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste Parametrizacao do Intervalo de Impressao            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  !lQuery .And. ;
			((SRA->RA_MAT < cMatDe)   .Or. (SRA->RA_MAT > cMatAte)    .Or. ;
			(SRA->RA_CC  < cCustoDe) .Or. (SRA->RA_CC  > cCustoAte)   .Or. ;
			(SRA->RA_NOME < cNomeDe) .Or. (SRA->RA_NOME > cNomeAte)   .Or. ;
			!(SRA->RA_CATFUNC $ cCat) .Or. !(SRA->RA_SITFOLH $ cSit))
			SRA->(dbSkip(1))		
			Loop
		EndIf           
	        
		 
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Consiste Filiais e Acessos                                             ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF !( (cQrySRA)->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
	      	(cQrySRA)->( dbSkip() )
	       	Loop
		Endif            
				
		
		//se filial eh diferente da anterior, inicia-se nova pagina
		If cFilAnt <> (cQrySRA)->RA_FILIAL   
			
		   	If nTotFunc <> 0	 
			    //totaliza campos
			    nTotCot := nCotiz //- nTotAfas 
			    
				//imprime relatorio
				oPrint:Endpage()
				ImprCNS()  
			Endif     
		 	
			//Zera variaveis para cada filial
			nTotSal  	:= nTotFunc 	:= nTotAfas 	:= nCotiz   := 0
			nEnferm  	:= nMatern  	:= nAciden  	:= nTotCot  := 0
			nTotMatern	:= nTotEnferm	:= nTotAciden	:= 0
		 	
			//armazena o numero correspondente a Caja Nacional de Salud
			nAux:= fPosTab("S006", "S", "=", 6) 
			nCajaSalud:= If(fTabela("S006", nAux, 4, ) <> NIL ,fTabela("S006", nAux, 4, ), )  
					
					
			fInfo(@aInfo, (cQrySRA)->RA_FILIAL)     //carrega informacoes da filial   
			
			//carrega campos especificos de cada filial, da tabela S007
			fCarrTab ( @aTabS004, "S004", dDataRef, .T.)

			nCNSSeg		:= aTabS004[1][7]
			cEmplead	:= aTabS007[1][6]
			cNit		:= aTabS007[1][8]
			cActividad	:= aTabS007[1][9]
			cIdRepLeg	:= aTabS007[1][12]
			cModulo		:= aTabS007[1][13]
			
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Carrega Variaveis Codigos Da Folha                           ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If !fP_CodFol(@aCodFol,(cQrySRA)->RA_FILIAL)
				Return
			Endif
			
			//carrega periodo da competencia selecionada
			fRetPerComp( cMes , cAno , , , , @aPerAberto , @aPerFechado , @aPerTodos )  

			cFilAnt:= (cQrySRA)->RA_FILIAL
			
		Endif          
		  
		//desconsidera funcionarios empregados depois do periodo selecionado
		If !len(aPerAberto) < 1 .And. (cQrySRA)->RA_ADMISSA > aPerAberto[len(aPerAberto)][6]
			(cQrySRA)->(dbSkip(1))
			Loop 
		Elseif !len(aPerFechado) < 1 .And. (cQrySRA)->RA_ADMISSA > aPerFechado[len(aPerFechado)][6]
			(cQrySRA)->(dbSkip(1))
			Loop
		Endif   
		
			
		//procura registros do funcionario no SRD
		If !(len(aPerAberto) < 1)                                          	
			dbSelectArea("SRC")                                     	
			dbSetOrder(6)                  			
			For nAux:=1 to len(aPerAberto)    
				SRC->(dbGoTop())           
				dbSeek( (cQrySRA)->(RA_FILIAL+RA_MAT) + aPerAberto[nAux][7] + "FOL" + aPerAberto[nAux][1] + aPerAberto[nAux][2]) 
				While SRC->(!Eof()) .And. (cQrySRA)->(RA_FILIAL+RA_MAT) + aPerAberto[nAux][7] + "FOL" + aPerAberto[nAux][1] + aPerAberto[nAux][2] == SRC->(RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA)  
					Do Case
						Case SRC->RC_PD == aCodFol[737, 1]
							nTotSal += SRC->RC_VALOR   
						Case SRC->RC_PD == aCodFol[751, 1]
							nEnferm += 1
							nTotEnferm += SRC->RC_VALOR
							nTotAfas+= SRC->RC_VALOR
						Case SRC->RC_PD == aCodFol[750, 1]
							nMatern += 1
							nTotMatern += SRC->RC_VALOR 
							nTotAfas+= SRC->RC_VALOR
						Case SRC->RC_PD == aCodFol[752, 1]
							nAciden += 1
							nTotAciden += SRC->RC_VALOR
							nTotAfas+= SRC->RC_VALOR
						Case SRC->RC_PD == aCodFol[1351, 1]
							nEnfermPro += 1
							nTotEnfPro += SRC->RC_VALOR
							nTotAfas+= SRC->RC_VALOR  	
						Case SRC->RC_PD == aCodFol[736, 1]
							nCotiz+= SRC->RC_VALOR
					EndCase
					SRC->(dbSkip())         
				End   
			Next nAux     
		Endif             
	
		         
		//procura registros do funcionario no SRD	       
		If !(len(aPerFechado) < 1)                                          	
			dbSelectArea("SRD")                                     	
			dbSetOrder(5)                  		
			For nAux:=1 to len(aPerFechado)    
				SRD->(dbGoTop())           
				dbSeek( (cQrySRA)->(RA_FILIAL+RA_MAT) + aPerFechado[nAux][7] + "FOL" + aPerFechado[nAux][1] + aPerFechado[nAux][2]) 
				While SRD->(!Eof()) .And. (cQrySRA)->(RA_FILIAL+RA_MAT) + aPerFechado[nAux][7] + "FOL" + aPerFechado[nAux][1] + aPerFechado[nAux][2] == SRD->(RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA)  
					Do Case                  
						Case SRD->RD_PD == aCodFol[737, 1]
							nTotSal+= SRD->RD_VALOR 
						Case SRD->RD_PD == aCodFol[751, 1]
							nEnferm += 1
							nTotEnferm += SRD->RD_VALOR
							nTotAfas+= SRD->RD_VALOR
						Case SRD->RD_PD == aCodFol[750, 1]
							nMatern += 1
							nTotMatern += SRD->RD_VALOR
							nTotAfas+= SRD->RD_VALOR
						Case SRD->RD_PD == aCodFol[752, 1]
							nAciden += 1
							nTotAciden += SRD->RD_VALOR
							nTotAfas+= SRD->RD_VALOR  
						Case SRD->RD_PD == aCodFol[1351, 1]
							nEnfermPro += 1
							nTotEnfPro += SRD->RD_VALOR
							nTotAfas+= SRD->RD_VALOR  							
						Case SRD->RD_PD == aCodFol[736, 1]
							nCotiz+= SRD->RD_VALOR
					EndCase
					SRD->(dbSkip())         
				End   
			Next nAux     
		Endif	
	     
		If len(aPerAberto) >= 1 .Or. len(aPerFechado) >= 1
			nTotFunc+= 1
		EndIf
		(cQrySRA)->(dbSkip()) 
					
	EndDo

	//imprime relatorio 
  	If nTotFunc <> 0

		//totaliza campos 
		nTotCot := nCotiz //- nTotAfas
		
  		oPrint:Endpage()
		ImprCNS()
  	Endif
	
	If !lQuery		
		dbSelectArea(cQrySRA)
		dbSetOrder(nSavOrdem)
		dbGoTo(nSavRec)      
	Endif                              

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o alias padrao                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	If Select(cQrySRA) > 0
		(cQrySRA)->(dbCloseArea())
	Endif
EndIf

Return
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImprCNS   ºAutor  ³Erika Kanamori      º Data ³  03/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime Comprobante de Pago Mensual de Aportes.             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImprCNS()  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³FORMULARIO DE PAGO DE CONTRIBUCIONES                                        |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oPrint:StartPage() 			//Inicia uma nova pagina    
    
//oPrint:say ( 0200, 0830, STR0004, oFont14n)// "RESUMEN DE APORTES"
oPrint:say ( 0200, 0045, STR0026, oFont14n)// "CAJA NACIONAL DE SALUD" 
oPrint:box ( 0200, 1040, 0250, 1520) //box
oPrint:say ( 0200, 1050, STR0027, oFont14n)// "Form. RCI - 1A" 
oPrint:say ( 0250, 0095, STR0005, oFont10)//"SISTEMAS DE COTIZACIONES"  
oPrint:say ( 0250, 1840, STR0028 + ": " + cNumFol, oFont10)//"Numero de Folio:"  
                                                                     
oPrint:box ( 0340, 0550, 0400, 1785) //box
oPrint:say ( 0340, 0590, STR0001, oFont14n) //"Comprobante de Pago Mensual de Aportes"

oPrint:box ( 0780, 0040, 0860, 2390) //box
oPrint:say ( 0800, 0045, STR0029 + " " + cMes +" DE " + cAno, oFont12) //Mes + Ano
               
oPrint:box ( 0500, 0040, 0780, 2390) //box
oPrint:line( 0550, 0040, 0550, 2390) //horizontal 
oPrint:line( 0500, 1230, 0650, 1230) //NIT
oPrint:line( 0500, 1630, 0650, 1630) //EMPLEADOR
oPrint:line( 0500, 2030, 0650, 2030) //ASEGURADO
oPrint:line( 0650, 0040, 0650, 2390) 
oPrint:line( 0690, 0040, 0690, 2390) 

oPrint:say ( 0500, 0045, STR0006, oFont10) //"NOMBRE O RAZON SOCIAL DEL EMPLEADOR"   
oPrint:say ( 0580, 0045, aInfo[3], oFont09)       

oPrint:say ( 0500, 1370, STR0007, oFont10) //"Nº NIT"
oPrint:say ( 0580, 1350, cNit, oFont09)

oPrint:say ( 0500, 1660, STR0008, oFont10) //"Nº DEL EMPLEADOR"
oPrint:say ( 0580, 1770, cEmplead, oFont09)

oPrint:say ( 0500, 2040, STR0031, oFont10) //"Nº DEL ASEGURADO"  

oPrint:line( 0650, 0680, 0780, 0680) //vertical

oPrint:say ( 0650, 0045, STR0022, oFont10) //"DOMICILIO ZONA"  
oPrint:say ( 0730, 0045, aInfo[5], oFont09)   

oPrint:say ( 0650, 1020, STR0032, oFont10) //"CALLE NUMERO"  
oPrint:say ( 0730, 0730, aInfo[4], oFont09)   

oPrint:line( 0650, 1630, 0780, 1630) //vertical CALLE NUMERO 

oPrint:say ( 0650, 1760, STR0033, oFont10) //"TELEFONO"  
oPrint:say ( 0730, 1730, aInfo[10], oFont09)  

oPrint:line( 0650, 2030, 0780, 2030) //vertical TELEFONO

oPrint:say ( 0650, 2060, STR0034, oFont10) //"N COMPROBANTE"  
oPrint:say ( 0730, 2060, cNumComp, oFont09)  

oPrint:box ( 0860, 0040, 2190, 2390) //box
oPrint:line ( 0910, 0040, 0910,  2390)  //horizontal

oPrint:say ( 0860, 0045, STR0021, oFont10) //"RAMO DE ACTIVIDAD" 
oPrint:say ( 0940, 0045, cActividad, oFont09)
oPrint:line( 0860, 0550, 0990, 0550)   
oPrint:say ( 0860, 0570, STR0019, oFont10) //"Nº TRAB."     
oPrint:say ( 0940, 0580, Transform(nTotFunc,"99999"), oFont09)
oPrint:line( 0860, 0750, 0990, 0750)
oPrint:say ( 0860, 0820, STR0020, oFont10) //"TOTAL SALARIOS" 
oPrint:say ( 0940, 0850, Transform(nTotSal,"999,999,999.99"), oFont09) 
oPrint:line( 0860, 1190, 1590, 1190)  //vertical
oPrint:say ( 0860, 1250, STR0009, oFont10) //"TASA"   
oPrint:say ( 0940, 1260, Transform(nCNSSeg,"99")+"%", oFont09)
oPrint:line( 0860, 1390, 0990, 1390)
oPrint:say ( 0860, 1435, STR0010, oFont10) //"MODULO"
oPrint:say ( 0940, 1450, cModulo, oFont09)  
oPrint:line( 0860, 1590, 1790, 1590)  //vertical
oPrint:say ( 0860, 1720, STR0013, oFont10) //"COTIZACION"    
oPrint:say ( 0940, 1660, Transform(nCotiz,"999,999,999.99"), oFont09)
oPrint:line( 0990, 0040, 0990, 2090) //horizontal riesgos profesionales
oPrint:line( 0860, 2090, 1790, 2090) //vertical
oPrint:say ( 0860, 2150, STR0035, oFont10) //"KARDIXTA"    

oPrint:say ( 0990, 0045, STR0011, oFont10) //"RIESGOS PROFESIONALES A CORTO PLAZO"
oPrint:line( 0990, 0950, 1290, 0950) //vertical afastamentos
oPrint:say ( 0990, 1010, STR0012, oFont10) //"CASOS"
oPrint:say ( 0990, 1330, STR0014, oFont10) //"IMPORTES"

oPrint:line( 1040, 0040, 1040, 1590) // horizontal importe

oPrint:say ( 1040, 0045, STR0015, oFont10) //"1.- ENFERMEDAD COMUN"
oPrint:say ( 1040, 0960, Transform(nEnferm,"99999"), oFont09)
oPrint:say ( 1040, 1210, Transform(nTotEnferm,"999,999,999.99"), oFont09)
oPrint:line( 1090, 0040, 1090, 1590)  //horizontal

oPrint:say ( 1090, 0045, STR0016, oFont10) //"2.- MATERNIDAD" 
oPrint:say ( 1090, 0960, Transform(nMatern,"99999"), oFont09) 
oPrint:say ( 1090, 1210, Transform(nTotMatern,"999,999,999.99"), oFont09)
oPrint:line( 1140, 0040, 1140, 1590) //horizontal

oPrint:say ( 1140, 0045, STR0017, oFont10) //"3.- ACCIDENTE DE TRABAJO"
oPrint:say ( 1140, 0960, Transform(nAciden,"99999"), oFont09)
oPrint:say ( 1140, 1210, Transform(nTotAciden,"999,999,999.99"), oFont09)
oPrint:line( 1190, 0040, 1190, 1590) //horizontal

oPrint:say ( 1190, 0045, STR0025, oFont10) //"4.- ENFERMEDAD PROFESIONAL"
oPrint:say ( 1190, 0960, Transform(nEnfermPro,"99999"), oFont09)
oPrint:say ( 1190, 1210, Transform(nTotEnfPro,"999,999,999.99"), oFont09)
oPrint:line( 1240, 0040, 1240, 1590)
oPrint:line( 1290, 0040, 1290, 2390)

oPrint:say ( 1320, 0045, STR0018, oFont10) //"TOTAL"   
oPrint:say ( 1320, 1210, Transform(nTotAfas,"999,999,999.99"), oFont09)  
oPrint:say ( 1320, 1660, Transform(nTotCot,"999,999,999.99"), oFont09)
oPrint:say ( 1320, 2120, STR0056, oFont10) //"VERIFICADOR"     
oPrint:line( 1390, 0040, 1390, 2390)

oPrint:say ( 1390, 0045, STR0036, oFont10) //"RECARGO DE LEY" 
oPrint:line( 1440, 0040, 1440, 1590) // horizontal IMPORTES 
oPrint:say ( 1440, 0045, STR0037, oFont10) //"INTERES"  
oPrint:line( 1490, 0040, 1490, 1190) 
oPrint:say ( 1490, 0045, STR0038, oFont10) //"MULTA"  
oPrint:line( 1540, 0040, 1540, 1190)
oPrint:line( 1590, 0040, 1590, 1590)

oPrint:say ( 1390, 1330, STR0014, oFont10) //"IMPORTES"

oPrint:say ( 1620, 0045, STR0039, oFont10) //"TOTAL A CANCELAR" 
oPrint:line( 1690, 0040, 1690, 1590) 
oPrint:say ( 1690, 0045, STR0040, oFont10) //"SALDO EN FAVOR DE LA C.N.S."  
oPrint:line( 1740, 0040, 1740, 1590) 
oPrint:say ( 1740, 0045, STR0041, oFont10) //"SALDO EN FAVOR DEL EMPLEADOR"  
oPrint:line( 1790, 0040, 1790, 2390)                         

oPrint:say ( 1790, 0050, STR0042, oFont05) //"Como representante legal de la empresa declaro bajo juramento"
oPrint:say ( 1790, 0840, STR0044, oFont10) //"FORMA DE PAGO"
oPrint:say ( 1790, 1320, STR0045, oFont10) //BANCO
oPrint:say ( 1790, 1660, Transform(nTotCot,"999,999,999.99"), oFont09)
oPrint:say ( 1790, 2120, STR0046, oFont10) //N. CONTROL
oPrint:say ( 1810, 0050, STR0043, oFont05) // "la exactitud de los datos consignados en este documento"
oPrint:line( 1790, 0770, 1990, 0770) // vertical assinatura

oPrint:line( 1840, 0770, 1840, 2390) 
oPrint:say ( 1840, 0780, STR0047, oFont10) //CH. N.
oPrint:say ( 1910, 0075, replicate(".",51), oFont06)
oPrint:say ( 1930, 0340, STR0048, oFont06)  //Firma
oPrint:line( 1890, 0770, 1890, 2090) 
oPrint:say ( 1890, 0780, STR0049, oFont10) //EFECTIVO
oPrint:line( 1940, 0770, 1940, 2090) 
oPrint:say ( 1940, 0780, STR0050, oFont10) //TOTAL PAGADO
oPrint:say ( 1940, 1660, Transform(nTotCot,"999,999,999.99"), oFont09)
oPrint:say ( 1960, 0075, STR0051 + " " + cIdRepLeg, oFont07) //Carnet de Identidad
oPrint:line( 1790, 1190, 1990, 1190) // vertical FORMA DE PAGO
oPrint:line( 1790, 1590, 1990, 1590) // vertical BANCO
oPrint:line( 1790, 2090, 1990, 2090) // vertical Nº CONTROL

oPrint:line( 1990, 0040, 1990, 2390)
oPrint:say ( 1990, 0050, STR0052, oFont10) //OBSERVACIONES
oPrint:say ( 1990, 0710, STR0053, oFont10) //LIQUIDADO POR:
oPrint:say ( 1990, 1300, STR0055, oFont10) //CAJA - RECIBIDO POR: 
oPrint:say ( 1990, 1930, STR0054, oFont10)  //REGISTRO DE CAJA 
oPrint:line( 1990, 0700, 2190, 0700) // vertical OBS
oPrint:line( 1990, 1250, 2190, 1250) // vertical LIQUIDADO
oPrint:line( 1990, 1800, 2190, 1800) // vertical CAJA
oPrint:line( 2040, 0040, 2040, 2390) 



oPrint:EndPage()

Return        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AjustaHLPºAutor  ³ Ricardo Berti      º Data ³  25/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclui / atualiza Helps SX1						          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPERCNS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaHLP()

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}
Local aRegs		:= {}
Local lUpdate	:= .T.

//-------- Help .GPRCNS03.
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

AADD(aHelpPor,'Informe o mês e ano para a geração do ')
AADD(aHelpPor,'relatório, no formato MMAAAA.')

AADD(aHelpSpa,'Informe el mes y el año para generar ')
AADD(aHelpSpa,'el informe, en el formato MMAAAA.')

AADD(aHelpEng,'Enter "S" so that the system can assess ')
AADD(aHelpEng,'generating the report, using the format ')
AADD(aHelpEng,'MMYYYY.')

PutSX1Help("P"+".GPRCNS03.",aHelpPor,aHelpEng,aHelpSpa,lUpDate)

//-------- Help XINVMESANO
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
AADD(aHelpPor,'Período inválido.')
AADD(aHelpSpa,'Perido invalido.')
AADD(aHelpEng,'Invalid Period.')

PutSX1Help("P"+"XINVMESANO",aHelpPor,aHelpEng,aHelpSpa,lUpDate)

aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
AADD(aHelpPor,'Favor preencher mês e ano no formato: ')
AADD(aHelpPor,'MMAAAA. Ex. 012012.')
AADD(aHelpSpa,'Por favor, llene mes y ano en el ')
AADD(aHelpSpa,'formato: MMAAAA. Ej. 012012.')
AADD(aHelpEng,'Please, enter month and year in the following')
AADD(aHelpEng,'following format: MMYYYY. Ex.:012012.')

PutSX1Help("S"+"XINVMESANO",aHelpPor,aHelpEng,aHelpSpa,lUpDate)


aHelpPor:= {"Informe o código da Caixa de Saúde ",;
			"Inicial para a geração do relatório"}
aHelpSpa:= {"Informe el codigo de la Caja de    ",;
			"Salud Inicial para la generacion   ",;
			"del informe."}
aHelpEng:= {"Report the codigo of the Box of    ",;
			"Initial Health for the generacion  ",;
			"of the report."}
PutSX1Help("P"+".GPRCNS12.",aHelpPor,aHelpEng,aHelpSpa,lUpDate)


aHelpPor:= {"Informe o código da Caixa de Saúde ",;
			"Final para a geração do relatório"}
aHelpSpa:= {"Informe el codigo de la Caja de    ",;
			"Salud Final para la generacion del ",;
			"informe."}
aHelpEng:= {"Report the codigo of the Box of    ",;
			"Final Health for the generacion of ",;
			"the report."}
PutSX1Help("P"+".GPRCNS13.",aHelpPor,aHelpEng,aHelpSpa,lUpDate)

aHelpPor	:= {}
aHelpSpa	:= {}

AADD(aHelpPor,"Favor preencher com o número da folha do" )
AADD(aHelpPor,"formulário.                             " )
AADD(aHelpSpa,"Por favor, complete con el numero del   " )
AADD(aHelpSpa,"folio del formulario.                   " )
		
PutSX1Help("P"+".GPRCNS14.",aHelpPor,,aHelpSpa,lUpDate)   

aHelpPor	:= {}
aHelpSpa	:= {}

AADD(aHelpPor,"Favor preencher com o número do         " )
AADD(aHelpPor,"comprovante.                            " )
AADD(aHelpSpa,"Por favor, complete con el numero del   " )
AADD(aHelpSpa,"comprobante                             " )
	
PutSX1Help("P"+".GPRCNS15.",aHelpPor,,aHelpSpa,lUpDate) 


/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³             Grupo     Ordem   Perg.Port.                    Perg.Esp.                       Perg.Ingles              Variavel     Tipo    Tamanho          Decimal    Presel  GSC   Valid          Var01          Def01    DefSPA1  DefEng1   Cnt01   Var02    Def02    DefSpa2   DefEng2   Cnt02   Var03    Def03    DefSpa3    DefEng3    Cnt03    Var04    Def04    DefSpa4    DefEng4  Cnt04	Var05   Def05    DefSpa5   DefEng5   Cnt05    XF3      GrgSxg     cPyme    aHelpPor     aHelpEng        aHelpSpa       cHelp        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Aadd( aRegs,{ cPerg,	'01',	"Filial De?                ", "¿De Sucursal ?              ", "From Branch ?       ", "MV_CH1",    	"C",    FWGETTAMFILIAL,	0,         0,      "G",  "",            "MV_PAR01",    "",      "",      "",      "",     "",      "",      "",       "",       "",     "",      "",      "",       "",        "",      "",      "",      "",        "",     "",     "",    "",      "",       "",       "",    	"XM0",     	"033",   "S",     "",          "",             "",            ".RHFILDE."  } )
Aadd( aRegs,{ cPerg,	'02',	"Filial Até?               ", "¿A Sucursal ?               ", "To Branch ?         ", "MV_CH2",    	"C",    FWGETTAMFILIAL,	0,         0,      "G",  "naovazio",    "MV_PAR02",    "",      "",      "",      "",     "",      "",      "",       "",       "",     "",      "",      "",       "",        "",      "",      "",      "",        "",     "",     "",    "",      "",       "",       "",    	"XM0",     	"033",   "S",     "",          "",             "",            ".RHFILAT."  } )
Aadd( aRegs,{ cPerg,	'03',	"Mês/Ano ?                 ", "¿Mes/Ano ?                  ", "Month/Year ?        ", "MV_CH3",    	"C",    6,             	0,         0,      "G",  "FCHKCOMP()",  "MV_PAR03",    "",      "",      "",      "",     "",      "",      "",       "",       "",     "",      "",      "",       "",        "",      "",      "",      "",        "",     "",     "",    "",      "",       "",       "",    	"",        	"",      "S",     "",          "",             "",            ".GPRCNS03." } )
Aadd( aRegs,{ cPerg,	'04',	"Matrícula De ?            ", "¿De Matricula ?             ", "From Registration ? ", "MV_CH4",    	"C",    6,             	0,         0,      "G",  "",            "MV_PAR04",    "",      "",      "",      "",     "",      "",      "",       "",       "",     "",      "",      "",       "",        "",      "",      "",      "",        "",     "",     "",    "",      "",       "",       "",    	"SRA",     	"",      "S",     "",          "",             "",            ".RHMATD."   } )
Aadd( aRegs,{ cPerg,	'05',	"Matrícula Até ?           ", "¿A Matricula ?              ", "To Registration ?   ", "MV_CH5",    	"C",    6,             	0,         0,      "G",  "naovazio",    "MV_PAR05",    "",      "",      "",      "",     "",      "",      "",       "",       "",     "",      "",      "",       "",        "",      "",      "",      "",        "",     "",     "",    "",      "",       "",       "",    	"SRA",     	"",      "S",     "",          "",             "",            ".RHMATA."   } )
Aadd( aRegs,{ cPerg,	'06',	"Centro de Custo De ?      ", "¿De Centro de Costo ?       ", "From Cost Center ?  ", "MV_CH6",    	"C",    9,             	0,         0,      "G",  "",            "MV_PAR06",    "",      "",      "",      "",     "",      "",      "",       "",       "",     "",      "",      "",       "",        "",      "",      "",      "",        "",     "",     "",    "",      "",       "",       "",    	"CTT",     	"004",   "S",     "",          "",             "",            ".RHCCDE."   } )
Aadd( aRegs,{ cPerg,	'07',	"Centro de Custo Até ?     ", "¿A Centro de Costo ?        ", "To Cost Center ?    ", "MV_CH7",    	"C",    9,             	0,         0,      "G",  "naovazio",    "MV_PAR07",    "",      "",      "",      "",     "",      "",      "",       "",       "",     "",      "",      "",       "",        "",      "",      "",      "",        "",     "",     "",    "",      "",       "",       "",    	"CTT",     	"004",   "S",     "",          "",             "",            ".RHCCAT."   } )
Aadd( aRegs,{ cPerg,	'08',	"Nome De ?                 ", "¿De Nombre ?                ", "From Name ?         ", "MV_CH8",    	"C",    30,            	0,         0,      "G",  "",            "MV_PAR08",    "",      "",      "",      "",     "",      "",      "",       "",       "",     "",      "",      "",       "",        "",      "",      "",      "",        "",     "",     "",    "",      "",       "",       "",    	"",        	"",      "S",     "",          "",             "",            ".RHNOMEA."  } )
Aadd( aRegs,{ cPerg,	'09',	"Nome Até ?                ", "¿A Nombre ?                 ", "To Name ?           ", "MV_CH9",    	"C",    30,            	0,         0,      "G",  "naovazio",    "MV_PAR09",    "",      "",      "",      "",     "",      "",      "",       "",       "",     "",      "",      "",       "",        "",      "",      "",      "",        "",     "",     "",    "",      "",       "",       "",    	"",        	"",      "S",     "",          "",             "",            ".RHNOMED."  } )
Aadd( aRegs,{ cPerg,	'10',	"Situações a Imp. ?        ", "¿Situaciones por Imp. ?     ", "Status to Print ?   ", "MV_CH0",    	"C",    5,             	0,         0,      "G",  "fSituacao",   "MV_PAR10",    "",      "",      "",      "",     "",      "",      "",       "",       "",     "",      "",      "",       "",        "",      "",      "",      "",        "",     "",     "",    "",      "",       "",       "",    	"",        	"",      "S",     "",          "",             "",            ".RHSITUA."  } )
Aadd( aRegs,{ cPerg,	'11',	"Categorias a Imp. ?       ", "¿Categorias por Imp. ?      ", "Categories to Print?", "MV_CHA",    	"C",    15,            	0,         0,      "G",  "fCategoria",  "MV_PAR11",    "",      "",      "",      "",     "",      "",      "",       "",       "",     "",      "",      "",       "",        "",      "",      "",      "",        "",     "",     "",    "",      "",       "",       "",    	"",        	"",      "S",     "",          "",             "",            ".RHCATEG."  } )
Aadd( aRegs,{ cPerg,	'12',	"Caixa De ?                ", "¿Caja De ?                  ", "From Box ?          ", "MV_CHB",    	"C",    2,             	0,         0,      "G",  "",            "MV_PAR12",    "",      "",      "",      "",     "",      "",      "",       "",       "",     "",      "",      "",       "",        "",      "",      "",      "",        "",     "",     "",    "",      "",       "",       "",    	"SBO06",   	"",      "S",     "",          "",             "",            ".GPRCNS12." } )
Aadd( aRegs,{ cPerg,	'13',	"Caixa Ate ?               ", "¿Caja Ate ?                 ", "To Box ?            ", "MV_CHC",   	"C",    2,             	0,         0,      "G",  "naovazio",    "MV_PAR13",    "",      "",      "",      "",     "",      "",      "",       "",       "",     "",      "",      "",       "",        "",      "",      "",      "",        "",     "",     "",    "",      "",       "",       "",    	"SBO06",   	"",      "S",     "",          "",             "",            ".GPRCNS13." } )
Aadd( aRegs,{ cPerg,	'14',	"Numero da Folha ?         ", "¿Numero de Folio ?          ", "Number of Page ?    ", "MV_CHD",    	"C",    8,             	0,         0,      "G",  "naovazio",    "MV_PAR14",    "",      "",      "",      "",     "",      "",      "",       "",       "",     "",      "",      "",       "",        "",      "",      "",      "",        "",     "",     "",    "",      "",       "",       "",    	"",   		"",      "S",     "",          "",             "",            ".GPRCNS14." } )
Aadd( aRegs,{ cPerg,	'15',	"Número Comprovante ?      ", "¿Numero Comprobante ?       ", "Receipt Number ?    ", "MV_CHE",   	"C",    15,            	0,         0,      "G",  "naovazio",    "MV_PAR15",    "",      "",      "",      "",     "",      "",      "",       "",       "",     "",      "",      "",       "",        "",      "",      "",      "",        "",     "",     "",    "",      "",       "",       "",   	"",   		"",      "S",     "",          "",             "",            ".GPRCNS15." } )

ValidPerg(aRegs,cPerg,lUpDate)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AjustaHLPºAutor  ³ A.Shibao           º Data ³  09/10/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida campos e tabelas usadas no relatorio GPER715, pois  º±±
±±º          ³ e necessario tambem no GPERCNS                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPER715                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fValSx3CNS()

	Local aAreaSX3	:= SX3->( GetArea() )
	Local lRet		:= .T.

	dbSelectArea("SX3")
	dbSetOrder(2)

    IF SX3->(!dbSeek("R8_DTBLEG")) .Or. SX3->(!dbSeek("RCM_TPIMSS")) .or. SX3->(!dbSeek("R8_RESINC"))
			Aviso(OemToAnsi(STR0024), OemToAnsi(STR0023), {"OK"})	//"Antes de continuar, es necesario ejecutar la actualizacion '229' disponible para el modulo SIGAGPE en el compatibilizador RHUPDMOD."  	               
    		lRet := .F.
	Endif
	
	RestArea(aAreaSX3)	
	
Return(lRet)

