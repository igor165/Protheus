#INCLUDE "FIsR012.ch"
#INCLUDE "RwMake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FISR012   ³ Autor ³ Sergio Daniel	        ³ Data ³10/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatoriorio livro fiscal. Peru			    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISR012()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Livros fiscais.	                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS     ³  Motivo da Alteracao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³26/12/16³SERINN001-³Se modifica uso de tablas temporales  ³±±
±±³            ³        ³      715 ³por motivo de limpieza de CTREE. y se ³±±
±±³            ³        ³          ³elimina funcion ajustaSX1()           ³±±
±±³M.Camargo   ³02/22/18³DMINA-760 ³Se retira función AjustaSX1. Se reali-³±±
±±³            ³        ³          ³za merge de 11.8 con cambios generados³±±
±±³            ³        ³          ³por Cesar Bautista.                   ³±±
±±³            ³        ³          ³Se eliminan variables no usadas.      ³±±
±±³LuisEnriquez³22/04/18³DMINA-2638³Se elimina alltrim para condicionar el³±±
±±³            ³        ³          ³vacío del campo A2_TIPDOC. (COL)      ³±±
±±³gsantacruz  ³19/05/18³DMINA-2933³Se hace uso del campo FILORGI, para   ³±±
±±³            ³        ³DMINA-3102³considerar financiero compartido.     ³±±
±±³  Oscar G.  ³05/01/19³DMINA-4919³Se actualiza fuente de 11.8 a 12.1.17 ³±±
±±³            ³        ³          ³para estabilización. (PER)            ³±±
±±³  Oscar G.  ³05/06/19³DMINA-6885³Modificaciones enviadas por Percy:    ³±±
±±³            ³        ³          ³La factura solo debe salir en el libro³±±
±±³            ³        ³          ³de compras, en la fecha que esta fue  ³±±
±±³            ³        ³          ³cancelada. 							  ³±±
±±³            ³        ³          ³La factura tiene que salir en el libro³±±
±±³            ³        ³          ³de compras la fecha (mes) que fue     ³±±
±±³            ³        ³          ³cancelada la detracción.  			  ³±±
±±³  Oscar G.  ³22/10/19³DMINA-7328³Se realiza merge de cambios realizados³±±
±±³            ³        ³          ³por Percy, ademas se realiza el uso de³±±
±±³            ³        ³          ³tReport en lugar de TmsPrinter.(PER)  ³±±
±±³  gSantacruz³04/12/19³DMINA-7966³Cambios enviado por Percy el 22/11/19 ³±±
±±³            ³        ³          ³por Percy: Se identificaron que los   ³±±
±±³            ³        ³          ³documentos tipos notas de crédito del ³±±
±±³            ³        ³          ³proveedor no estaban siendo filtrados ³±±
±±³            ³        ³          ³ por el periodo seleccionado.         ³±±
±±³  gSantacruz³10/01/20³DMINA-8184³Se identificaron que los documentos   ³±±
±±³            ³        ³          ³tipos notas de crédito del proveedor  ³±±
±±³            ³        ³          ³no estaban siendo filtrados por el	  ³±±
±±³            ³        ³          ³periodo seleccionado.				  ³±±
±±³  Marco A.  ³17/07/20³DMINA-9479³Se agrega valor a la impresion de la  ³±±
±±³            ³        ³          ³columna 34 en el archivo TXT (PER)    ³±±
±±³  Marco A.  ³24/07/20³DMINA-9757³Se agrega tratamiento para AdvPR.     ³±±
±±³  Jose Glez.³19/10/20³DMINA-    ³Se da tratamiento para los 5 dias     ³±±
±±³            ³        ³     10346³hábiles en detracciones |PERU|    	  ³±±
±±³  Jose Glez.³12/11/20³DMINA-    ³Se da tratamiento para que la razon   ³±±
±±³            ³        ³     10570³social en el Archivo txt se pueda     ³±±
±±³            ³        ³          ³imprimir hasta 100 caracteres |PERU|  ³±±
±±³  Jose Glez.³18/11/20³DMINA-    ³Se da tratamiento para los 5 dias     ³±±
±±³            ³        ³     10555³hábiles en detracciones |PERU|    	  ³±±
±±³  Jose Glez.³02/12/20³DMINA-    ³Se da tratamiento para los 5 dias     ³±±
±±³            ³        ³     10605³hábiles en Libro de Compras |PERU|	  ³±±
±±³ARodriguez  ³20/12/20³DMINA-    ³Incluir columna de ICBPER             ³±±
±±³            ³        ³     10545³                                      ³±±
±±³  Jose Glez.³08/01/21³DMINA-    ³Se da tratamiento para los 5 dias     ³±±
±±³            ³        ³     10830³hábiles en Libro de Compras |PERU|	  ³±±
±±³  Marco A.  ³25/03/21³DMINA-    ³Se modifica impresion de columna 8    ³±±
±±³            ³        ³     11655³para el libro 8.2 (PER)               ³±±
±±³Veronica F. ³29/04/21³DMINA-    ³Se modifica el tratamiento en colum. 7³±±
±±³            ³        ³     12215³para el libro 8.2 (PER)               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FISR012()
  
 	Local lRet		:= .T.
	Local clPerg	:= "FISR012"
	Local clNomProg	:= FunName()
	Local clTitulo	:= Alltrim(STR0001) //Registros de Vendas e Ingressos
	
  	Private npPagina	:= 0
	Private opPrint		:= Nil
	Private lAutomato	:= IsBlind() //Variable utilizada para identificar automatizados
	
	// Determina o uso dos campos _SERIE2 para o Peru
	Private lSerie2 := SF1->(ColumnPos("F1_SERIE2")) > 0 .and.;
					   SF2->(ColumnPos("F2_SERIE2")) > 0 .and.;
					   SF3->(ColumnPos("F3_SERIE2")) > 0 .and.;
					   GetNewPar("MV_LSERIE2",.F.)
					   
	Private lRenta		:= SF1->(ColumnPos("F1_TPRENTA")) > 0 .And. SF2->(ColumnPos("F2_TPRENTA")) > 0
	Private lSerY		:= SF1->(ColumnPos("F1_YSERIE")) > 0	   
	Private lMeslib		:= SFE->(ColumnPos( "FE_MESLIB" )) > 0
	Private nPLEPeru	:= SuperGetMv("MV_PLEPERU", .F., 5150)		// Número de versión del PLE, v5.1.5.0 vigente hasta Jun/2020, v5.1.8.1 vigente hasta Dic/2020
	Private lICBPER		:= (SFB->(ColumnPos("FB_VALIMPU")) > 0)		// Usa impuesto al consumo de bolsas de plástico

  	If SF1->(ColumnPos("F1_TPDOC")) == 0 .Or. SF2->(ColumnPos("F2_TPDOC")) == 0
		Aviso(STR0059,STR0060,{"Ok"},3)	//"Atenção" # "Por favor solicite a última atualização do programa U_UPDCOM13 para criar os campos F1_TPDOC e F2_TPDOC e execute-o para poder emitir este livro"
		lRet	:=	.F.
	Endif
	
	If SFE->(ColumnPos("FE_CERTDET")) == 0
		Aviso(STR0059,STR0061,{"Ok"},3)	//"Atenção" # "Por favor solicite a última atualização do programa U_UPDfin para criar o campo FE_CERTDET e execute-o para poder emitir este livro"
		lRet	:=	.F.
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³mv_par01 - ¿Fecha Inicial?            ³
	//³mv_par02 - ¿Fecha Final?              ³
	//³mv_par03 - ¿Imprime paginas?          ³
	//³mv_par04 - ¿N. Pag. Inicial?          ³
	//³mv_par05 - ¿Sel. Sucursales?          ³
	//³mv_par06 - ¿Genera archivo?           ³
	//³mv_par07 - ¿Directorio?               ³
	//³mv_par08 - ¿Sujetos domiciliados?     ³
	//³mv_par09 - ¿Imp. Clas. Bienes y Serv.?³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lRet
		opPrint := TReport():New(clNomProg,clTitulo,clPerg, {|opPrint| FImpLivFis(opPrint)},"") //"REGISTRO DE COMPRAS"
		opPrint:oPage:setPaperSize(8)		//Tamaño hoja A3
		opPrint:SetLandscape(.T.)			// Formato paisagem
		opPrint:lHeaderVisible := .F.		// Não imprime cabeçalho do protheus
		opPrint:lFooterVisible := .F.		// Não imprime rodapé do protheus
		opPrint:DisableOrientation(.T.)		//Deshabilita orientación de página
		Pergunte(opPrint:uParam,.F.)
		opPrint:PrintDialog()
	Endif
    
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FImpLivFis³ Autor ³ Sergio Daniel	        ³ Data ³10/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Relatoriorio.					    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FImpLivFis()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Livros fiscais.	                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FImpLivFis(opPrint)

Local nlBi1P      := 0
Local nlBi2P      := 0
Local nlBi3P      := 0
Local nlBi1T      := 0
Local nlBi2T      := 0
Local nlBi3T      := 0
Local nlIGV1P     := 0
Local nlIGV2P     := 0
Local nlIGV3P     := 0
Local nlIGV1T     := 0
Local nlIGV2T     := 0
Local nlIGV3T     := 0
Local nlVAGP      := 0
Local nlVAGT      := 0
Local nlISCP      := 0
Local nlISCT      := 0
Local nlOTRP      := 0
Local nlOTRT      := 0
Local nlImpTotP   := 0
Local nlImpTotT   := 0
Local cpArqTRB    := ""
Local cpArqTRB2   := CriaTrab(Nil,.F.)
Local clF1DOC     := ""
Local clF1TpDoc   := ""
Local clF1SERIE   := ""
Local clF1EMISSAO	:= ""
Local lImprime		:= .T.
Local cMesInic		:= ""
Local cAnoInic		:= ""
Local cMesFin		:= ""
Local cAnoFin		:= ""
Local cPrefixo		:= ""
Local cNumero		:= ""
Local cParcela		:= ""
Local cTipo			:= ""
Local nPos			:= 0
Local aRet			:= {}
Local cFilSE2		:= xFilial('SE2')
Local cFilSF4		:= xFilial("SF4")
Local cProve		:= ""
Local cSerie		:= ""
Local dFecha		:= ctod(" / / ")
Local dTraFecha		:= ctod(" / / ")
Local aFiliais		:= {}//Seleciona Filiais
Local nlCont		:= 0
Local lDev4			:= opPrint:nDevice == 4	//Impresion mediante opcion 4 - Planilla 
Local lDev6			:= opPrint:nDevice == 6	//Impresion mediante opcion 6 - PDF
Local cNombre		:= ""
Local cCertif		:= ""
Local cTienda		:= ""
Local nlICBP		:= 0
Local nlICBT		:= 0

Private dDUtilInic	:= 0
Private dDUtilFin	:= 0
Private cAnoDua		:= "" //Homologacao Livro Fiscal Peru - OAS (16/04/13)
Private cMV_1DUP	:= Padr(SuperGetMV("MV_1DUP",,"1"),GetSx3Cache("E5_PARCELA","X3_TAMANHO"))
Private aOrder		:= {}
Private aCampos		:= {}
Private oTmpTRB4	:= Nil	
	
npPagina := MV_PAR04

aFiliais := MatFilCalc(MV_PAR05 == 1) //Seleciona Filiais
	
FMontQuery(aFiliais)      

DbSelectArea("TRB3")
If TRB3->(Eof())
	If MV_PAR06 == 1 .And. MV_PAR08 == 2
		If !lAutomato //Tratamiento para automatizados
			If MsgYesNo(STR0065,"") //"¿CONFIRMA LA GENERACIÓN DEL ARCHIVO TXT?"
	   			Processa({|| GerArq2(AllTrim(MV_PAR07))},,STR0063) //"GENERANDO ARCHIVO Txt"
	   		EndIf
	   	Else
	   		GerArq2(AllTrim(MV_PAR07))
   		EndIf
   	ElseIf MV_PAR06 == 1 .And. MV_PAR08 == 1
   		If !lAutomato //Tratamiento para automatizados
	   		If MsgYesNo(STR0065,"") //"¿CONFIRMA LA GENERACIÓN DEL ARCHIVO TXT?"
	   			Processa({|| GerArq2(AllTrim(MV_PAR07))},,STR0063) ////"GENERANDO ARCHIVO Txt"
	   		EndIf
	   	Else
	   		GerArq2(AllTrim(MV_PAR07))
   		EndIf			
	EndIf
	F12CABEC()
	opPrint:PrintText(STR0056,opPrint:Row(),2125)//"SIN MOVIMIENTO"
	opPrint:EndPage()
	If Select("TRB")>0
		TRB->(dbCloseArea())
	EndIf	
	If Select("TRB3")>0
	    TRB3->(dbCloseArea())
	EndIf
	Return
EndIf

//Crea tabla temporal a partir de TRB3
F012CreTab(cpArqTRB2)

TRB3->(DbCloseArea())

F12CABEC()
TRB4->(DbGoTop())

If TRB4->(!Eof())
	cMesInic := SUBSTR(DtoS(MV_PAR01),5,2)  // Mes Inicial Selecionado
	cAnoInic := SUBSTR(DtoS(MV_PAR01),3,2)  // Ano Incial Selecionado
	cMesFin  := SUBSTR(DtoS(MV_PAR02),5,2)  // Mes Final Selecionado
	cAnoFin  := SUBSTR(DtoS(MV_PAR02),3,2)  // Ano Final Selecionado
	
	If Alltrim(cMesInic) == "1"
		cMesInic := "12"
		cAnoInic := Str(Val(cAno)-1)
	Else
		//Homologacao Livro Fiscal Peru - OAS (16/04/13)
		cMesInic :=	Strzero(Val(cMesInic)-1,2)
	EndIF
	
	dDUtilInic := RetDiaUtil(cMesInic, cAnoInic) //  Retorna o Quinto dia util do mes Inicial selecionado
	dDUtilFin := RetDiaUtil(cMesFin, cAnoFin) //  Retorna o Quinto dia util do proximo mes Final selecionado
EndIf

Do While TRB4->(!Eof())
	If AllTrim(TRB4->F3_ESPECIE) $ "NCP|NDI"
			if TRB4->F3_ENTRADA < MV_PAR01 .Or. TRB4->F3_ENTRADA > MV_PAR02
				TRB4->( dbSkip() )
				loop
			endif
	endif
	If AllTrim(TRB4->F1_TPDOC) $ '14'
		If TRB4->F3_ENTRADA <= TRB4->E2_VENCTO  // ENTRADA MENOR QUE VENCIMENTO OU MENOR QUE BAIXA
			If TRB4->E2_BAIXA <= TRB4->E2_VENCTO  // BAJA MENOR QUE EL VENCIMIENTO
				If TRB4->E2_BAIXA >= MV_PAR01 .And. TRB4->E2_BAIXA <= MV_PAR02
				ElseIf TRB4->E2_VENCTO >= MV_PAR01 .And. TRB4->E2_VENCTO <= MV_PAR02 .And. empty(TRB4->E2_BAIXA)
				Else
					TRB4->(DbSkip())
					Loop													
				EndIf
			ElseIf TRB4->E2_BAIXA > TRB4->E2_VENCTO	    // BAJA MAYOR QUE EL VENCIMIENTO
				IF TRB4->E2_VENCTO >= MV_PAR01 .And. TRB4->E2_VENCTO <= MV_PAR02    
			    Else 
			    	TRB4->(DbSkip())
					Loop
				EndIf
			EndIf
		ElseIf TRB4->F3_ENTRADA >= TRB4->E2_VENCTO			// F3_ENTRADA MAYOR QUE QUE EL VENCIMIENTO Y EL PAGO
			If TRB4->E2_BAIXA <= TRB4->E2_VENCTO
				If TRB4->E2_VENCTO < MV_PAR01 .And. empty(TRB4->E2_BAIXA)
				ElseIf TRB4->E2_BAIXA < MV_PAR01
				Else
					TRB4->(DbSkip())
					Loop
				EndIf 
			ElseIf TRB4->E2_BAIXA > TRB4->E2_VENCTO
			 	If TRB4->F3_ENTRADA >= MV_PAR01 .AND. TRB4->F3_ENTRADA<=MV_PAR02
			 	Else
					TRB4->(DbSkip())
					Loop		
			 	EndIf   
			EndIF
		EndIF
	Endif
	
	lImprime := .F.
	If TRB4->F3_VALIMP5 >0 //Detraccion
				
		aRet := DetIGVFnPeru(TRB4->F3_CLIEFOR,TRB4->F3_LOJA,(MV_PAR01-30),(dDUtilFin),TRB4->F3_FILIAL,TRB4->F3_ENTRADA) // Preenche o array aRet de acordo com a funcao - RETROCEDE 30 DIAS PARA QUE TOME LA TX
		aretMes:= DetIGVFnPeru(TRB4->F3_CLIEFOR,TRB4->F3_LOJA,(MV_PAR01),(dDUtilFin),TRB4->F3_FILIAL,TRB4->F3_ENTRADA) // Preenche o array aRet de acordo com a funcao		
		
		nPos :=Ascan(aRet,{|x| x[1]+x[2]+x[5] == TRB4->F3_SERIE+TRB4->F3_NFISCAL+iif(empty(TRB4->E2_PARCELA),cMV_1DUP,TRB4->E2_PARCELA)})
		nPosMes:=Ascan(aretMes,{|x| x[1]+x[2]+x[5] == TRB4->F3_SERIE+TRB4->F3_NFISCAL+iif(empty(TRB4->E2_PARCELA),cMV_1DUP,TRB4->E2_PARCELA)})
		lImprime := .F.
		
		If nPos>0 .and. TRB4->F3_ENTRADA <= dDUtilFin .AND. alltrim(TRB4->F3_ESPECIE)='NF' .AND. TRB4->E2_BAIXA <= dDUtilFin   //ADICIONE QRY->F3_ESPECIE='NF' .AND. Ctod(QRY->E2_BAIXA) <= MV_PAR02
			cPrefixo := aRet[nPos,1]// Prefixo
			cNumero  := aRet[nPos,2]// Numero do Titulo
			cParcela := aRet[nPos,5]// Parcela
			cTipo := PADR("TX",GetSx3Cache("E2_TIPO","X3_TAMANHO"))  			 // Tipo que deve ser TX
			
			If cNumero == TRB4->F3_NFISCAL //Verifica se o titulo do aRet e o mesmo do TRB4
				cProve	:= TRB4->F3_CLIEFOR
				cTienda	:= TRB4->F3_LOJA
				DbselectArea("SE2")
				SE2->(DbGoTop())
				SE2->(dbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
				If SE2->(MsSeek(cFilSE2+cProve+cTienda+cPrefixo+cNumero+cParcela+cTipo)) //Procura o titulo TX no SE2, se encontrar deve imprimir
					dFecha:=SE2->E2_BAIXA
					//---------------------------TRATAMIENTO DE LA FECHA PARA MESES ANTERIORES AL ACTUAL------------------------------------------//
				    If SUBSTR(DTOS(mv_par01),5,2) $ "05|07|08|10|12"
						dTraFecha:=(mv_par01-30)
				    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "02|04|06|09|11"
						dTraFecha:=(mv_par01-31)
				    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "01"
						dTraFecha:=(mv_par01-31)
				    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "03"
						dTraFecha:=(mv_par01-28)
				    EndIf
				    //------------------------------------------------------------------------------------------------------------------------------//
				    IF lMeslib .and. TRB4->FE_MESLIB <> SUBSTR(DtoS(MV_PAR01),5,2) + SUBSTR(DtoS(MV_PAR01),1,4)      
						If !empty(TRB4->FE_MESLIB) 
							lImprime := .F.
							TRB4->(DbSkip())
							Loop
						Endif
					EndIF
					If dFecha>=(mv_par01) .AND. dFecha<=(dDUtilFin) .AND. TRB4->F3_ENTRADA>=(mv_par01) .AND. TRB4->F3_ENTRADA<=(dDUtilFin)
					   lImprime := .T.
					ElseIf dFecha>(dDUtilInic) .AND. dFecha<=(dDUtilFin) .AND. TRB4->F3_ENTRADA<(mv_par01) .AND. TRB4->F3_ENTRADA>=dTraFecha
			      	   lImprime := .T.
					ElseIf dFecha>=(mv_par01) .AND. dFecha<=(dDUtilFin) .AND. TRB4->F3_ENTRADA<dTraFecha
			      	   lImprime := .T.
					Else
			      	   lImprime := .F.
					EndIf
				EndIf
			EndIf
		ElseIf nPos>0 .and. TRB4->F3_ENTRADA <= MV_PAR02 .AND. TRB4->F3_ESPECIE='NF' .AND. TRB4->E2_BAIXA > MV_PAR02   //ADICIONE QRY->F3_ESPECIE='NF' .AND. Ctod(QRY->E2_BAIXA) > MV_PAR02
			cPrefixo := aRet[nPos,1]// Prefixo
			cNumero  := aRet[nPos,2]// Numero do Titulo
			cParcela := aRet[nPos,5]// Parcela
			cTipo := PADR("TX",GetSx3Cache("E2_TIPO","X3_TAMANHO"))		// Tipo que deve ser TX
			If cNumero == TRB4->F3_NFISCAL //Verifica se o titulo do aRet e o mesmo do TRB4
				cProve	:= TRB4->F3_CLIEFOR
				cTienda	:= TRB4->F3_LOJA
				DbselectArea("SE2")
				SE2->(DbGoTop())
				SE2->(dbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
				If SE2->(MsSeek(cFilSE2+cProve+cTienda+cPrefixo+cNumero+cParcela+cTipo)) //Procura o titulo TX no SE2, se encontrar deve imprimir
					dFecha:=SE2->E2_BAIXA
					//---------------------------TRATAMIENTO DE LA FECHA PARA MESES ANTERIORES AL ACTUAL------------------------------------------//
				    If SUBSTR(DTOS(mv_par01),5,2) $ "05|07|08|10|12"
						dTraFecha:=(mv_par01-30)
				    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "02|04|06|09|11"
						dTraFecha:=(mv_par01-31)
				    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "01"
						dTraFecha:=(mv_par01-31)
				    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "03"
						dTraFecha:=(mv_par01-28)
				    EndIf
				    //------------------------------------------------------------------------------------------------------------------------------//
					If dFecha>=(mv_par01) .AND. dFecha<=(dDUtilFin) .AND. TRB4->F3_ENTRADA>=(mv_par01) .AND. TRB4->F3_ENTRADA<=(mv_par02)
					   lImprime := .T.
					ElseIf dFecha>(dDUtilInic) .AND. dFecha<=(mv_par02) .AND. TRB4->F3_ENTRADA<(mv_par01) .AND. TRB4->F3_ENTRADA>=dTraFecha
			      	   lImprime := .T.
					ElseIf dFecha>=(mv_par01) .AND. dFecha<=(mv_par02) .AND. TRB4->F3_ENTRADA<dTraFecha
			      	   lImprime := .T.
					Else
			      	   lImprime := .F.
					EndIf
				EndIf
			EndIf
		EndIf

		If nPosMes>0 .and. TRB4->F3_ENTRADA >= MV_PAR01 .and. TRB4->F3_ENTRADA <= MV_PAR02 .AND. TRB4->E2_BAIXA <= MV_PAR02
			cPrefixo := aretMes[nPosMes,1]// Prefixo
			cNumero  := aretMes[nPosMes,2]// Numero do Titulo
			cParcela := aretMes[nPosMes,5]// Parcela
			cTipo := PADR("TX",GetSx3Cache("E2_TIPO","X3_TAMANHO"))			// Tipo que deve ser TX
			If cNumero == TRB4->F3_NFISCAL //Verifica se o titulo do aRet e o mesmo do TRB4
				cProve	:= TRB4->F3_CLIEFOR 
				cTienda	:= TRB4->F3_LOJA
				DbselectArea("SE2")
				SE2->(DbGoTop())
				SE2->(dbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
				If SE2->(MsSeek(cFilSE2+cProve+cTienda+cPrefixo+cNumero+cParcela+cTipo)) //Procura o titulo TX no SE2, se encontrar deve imp
					dFecha:=SE2->E2_BAIXA 
					//---------------------------TRATAMIENTO DE LA FECHA PARA MESES ANTERIORES AL ACTUAL------------------------------------------//
				    If SUBSTR(DTOS(mv_par01),5,2) $ "05|07|08|10|12"
						dTraFecha:=(mv_par01-30)
				    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "02|04|06|09|11"
						dTraFecha:=(mv_par01-31)
				    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "01"
						dTraFecha:=(mv_par01-31)
				    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "03"
						dTraFecha:=(mv_par01-28)
				    EndIf
				    //------------------------------------------------------------------------------------------------------------------------------//
					If dFecha>=(mv_par01) .AND. dFecha<=(dDUtilFin) .AND. TRB4->F3_ENTRADA>=(mv_par01) .AND. TRB4->F3_ENTRADA<=(mv_par02)
					   lImprime := .T.
					ElseIf dFecha>(dDUtilInic) .AND. dFecha<=(mv_par02) .AND. TRB4->F3_ENTRADA<(mv_par01) .AND. TRB4->F3_ENTRADA>=dTraFecha
			      	   lImprime := .T.
					ElseIf dFecha>=(mv_par01) .AND. dFecha<=(mv_par02) .AND. TRB4->F3_ENTRADA<dTraFecha
			      	   lImprime := .T.
					Else
			      	   lImprime := .F.
					EndIf
				EndIf
			EndIf
		ElseIf nPosMes>0 .and. TRB4->F3_ENTRADA >= MV_PAR01 .and. TRB4->F3_ENTRADA <= MV_PAR02 .AND. TRB4->E2_BAIXA > MV_PAR02
			cPrefixo := aretMes[nPosMes,1]// Prefixo
			cNumero  := aretMes[nPosMes,2]// Numero do Titulo
			cParcela := aretMes[nPosMes,5]// Parcela
			cTipo := PADR("TX",GetSx3Cache("E2_TIPO","X3_TAMANHO"))		// Tipo que deve ser TX
			If cNumero == TRB4->F3_NFISCAL //Verifica se o titulo do aRet e o mesmo do TRB4
				cProve	:= TRB4->F3_CLIEFOR 
				cTienda	:= TRB4->F3_LOJA
				DbselectArea("SE2")
				SE2->(DbGoTop())
				SE2->(dbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
				If SE2->(MsSeek(cFilSE2+cProve+cTienda+cPrefixo+cNumero+cParcela+cTipo)) //Procura o titulo TX no SE2, se encontrar deve imprimir   					
					dFecha:=SE2->E2_BAIXA
					//---------------------------TRATAMIENTO DE LA FECHA PARA MESES ANTERIORES AL ACTUAL------------------------------------------//
				    If SUBSTR(DTOS(mv_par01),5,2) $ "05|07|08|10|12"
						dTraFecha:=(mv_par01-30)
				    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "02|04|06|09|11"
						dTraFecha:=(mv_par01-31)
				    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "01"
						dTraFecha:=(mv_par01-31)
				    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "03"
						dTraFecha:=(mv_par01-28)
				    EndIf
				    //------------------------------------------------------------------------------------------------------------------------------//
					If dFecha>=(mv_par01) .AND. dFecha<=(dDUtilFin) .AND. TRB4->F3_ENTRADA>=(mv_par01) .AND. TRB4->F3_ENTRADA<=(mv_par02)
					   lImprime := .T.
					ElseIf dFecha>(dDUtilInic) .AND. dFecha<=(mv_par02) .AND. TRB4->F3_ENTRADA<(mv_par01) .AND. TRB4->F3_ENTRADA>=dTraFecha
			      	   lImprime := .T.
					ElseIf dFecha>=(mv_par01) .AND. dFecha<=(mv_par02) .AND. TRB4->F3_ENTRADA<dTraFecha
			      	   lImprime := .T.
					Else
			      	   lImprime := .F.
					EndIf
				EndIf
			EndIf 
		EndIf

		If !lImprime // Se nao encontrar nao imprime
			X:=1
			TRB4->(DbSkip())
			Loop
		EndIf

	EndIf
	
	If opPrint:Cancel()
		Exit
	EndIf
	
	If opPrint:Row() > 3300 .And. !lDev4

		opPrint:Box ( opPrint:Row()-2, 1450, opPrint:Row()+30, 3650) 

		opPrint:Line( opPrint:Row()-2,1660,opPrint:Row()+30,1660 )
		opPrint:Line( opPrint:Row()-2,1850,opPrint:Row()+30,1850 )
		opPrint:Line( opPrint:Row()-2,2050,opPrint:Row()+30,2050 )
		opPrint:Line( opPrint:Row()-2,2250,opPrint:Row()+30,2250 )
		opPrint:Line( opPrint:Row()-2,2450,opPrint:Row()+30,2450 )
		opPrint:Line( opPrint:Row()-2,2650,opPrint:Row()+30,2650 )
		opPrint:Line( opPrint:Row()-2,2850,opPrint:Row()+30,2850 )
		opPrint:Line( opPrint:Row()-2,3070,opPrint:Row()+30,3070 )
		opPrint:Line( opPrint:Row()-2,3260,opPrint:Row()+30,3260 )
		opPrint:Line( opPrint:Row()-2,3470,opPrint:Row()+30,3470 )

		/*ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  ³ Total Parcial, que e impressso no rodape de cada pagina. ³
		  ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁ*/
		opPrint:PrintText(STR0057,opPrint:Row(),1455)//"SUBTOTAL"
		opPrint:PrintText(PadL((Transform(nlBi1P	,"@E 999,999,999.99")),14," "),opPrint:Row(),1685)
		opPrint:PrintText(PadL((Transform(nlIGV1P	,"@E 999,999,999.99")),14," "),opPrint:Row(),1885)
		opPrint:PrintText(PadL((Transform(nlBi2P	,"@E 999,999,999.99")),14," "),opPrint:Row(),2085)
		opPrint:PrintText(PadL((Transform(nlIGV2P	,"@E 999,999,999.99")),14," "),opPrint:Row(),2295)
		opPrint:PrintText(PadL((Transform(nlBi3P	,"@E 999,999,999.99")),14," "),opPrint:Row(),2495)
		opPrint:PrintText(PadL((Transform(nlIGV3P	,"@E 999,999,999.99")),14," "),opPrint:Row(),2695)
		opPrint:PrintText(PadL((Transform(nlVAGP	,"@E 999,999,999.99")),14," "),opPrint:Row(),2900)
		opPrint:PrintText(PadL((Transform(nlISCP	,"@E 999,999,999.99")),14," "),opPrint:Row(),3110)
		opPrint:PrintText(PadL((Transform(nlOTRP	,"@E 999,999,999.99")),14," "),opPrint:Row(),3265)
		opPrint:PrintText(PadL((Transform(nlImpTotP	,"@E 999,999,999.99")),14," "),opPrint:Row(),3490)
		opPrint:PrintText(PadL((Transform(nlICBP	,"@E 999,999,999.99")),14," "),opPrint:Row(),4860)
		
		opPrint:EndPage()
		opPrint:StartPage()

		F12CABEC()        
        
		opPrint:Box ( opPrint:Row()-2,0010,opPrint:Row()+110,0010 )		
	    opPrint:Line( opPrint:Row()-2,0205,opPrint:Row()+110,0205 )//1
      	opPrint:Line( opPrint:Row()-2,0380,opPrint:Row()+110,0380 )//2
	   	opPrint:Line( opPrint:Row()-2,0540,opPrint:Row()+110,0540 )//3
	   	opPrint:Line( opPrint:Row()-2,0650,opPrint:Row()+110,0650 )//4
	   	opPrint:Line( opPrint:Row()-2,0810,opPrint:Row()+110,0810 )//5
	   	opPrint:Line( opPrint:Row()-2,0960,opPrint:Row()+110,0960 )//6
		opPrint:Line( opPrint:Row()-2,1190,opPrint:Row()+110,1190 )//7
		opPrint:Line( opPrint:Row()-2,1300,opPrint:Row()+110,1300 )//8
		opPrint:Line( opPrint:Row()-2,1450,opPrint:Row()+110,1450 )//9
		opPrint:Line( opPrint:Row()-2,1660,opPrint:Row()+110,1660 )//10
		opPrint:Line( opPrint:Row()-2,1850,opPrint:Row()+110,1850 )//11
		opPrint:Line( opPrint:Row()-2,2050,opPrint:Row()+110,2050 )//12
		opPrint:Line( opPrint:Row()-2,2250,opPrint:Row()+110,2250 )//13
		opPrint:Line( opPrint:Row()-2,2450,opPrint:Row()+110,2450 )//14
		opPrint:Line( opPrint:Row()-2,2650,opPrint:Row()+110,2650 )//15
		opPrint:Line( opPrint:Row()-2,2850,opPrint:Row()+110,2850 )//16
		opPrint:Line( opPrint:Row()-2,3070,opPrint:Row()+110,3070 )//17
		opPrint:Line( opPrint:Row()-2,3260,opPrint:Row()+110,3260 )//18
		opPrint:Line( opPrint:Row()-2,3470,opPrint:Row()+110,3470 )//19
		opPrint:Line( opPrint:Row()-2,3650,opPrint:Row()+110,3650 )//20
		opPrint:Line( opPrint:Row()-2,3900,opPrint:Row()+110,3900 )//21
		opPrint:Line( opPrint:Row()-2,4020,opPrint:Row()+110,4020 )//22
		opPrint:Line( opPrint:Row()-2,4150,opPrint:Row()+110,4150 )//23
		opPrint:Line( opPrint:Row()-2,4252,opPrint:Row()+110,4252 )//24
		opPrint:Line( opPrint:Row()-2,4382,opPrint:Row()+110,4382 )//25
		opPrint:Line( opPrint:Row()-2,4482,opPrint:Row()+110,4482 )//26
		opPrint:Line( opPrint:Row()-2,4572,opPrint:Row()+110,4572 )//27
		opPrint:Line( opPrint:Row()-2,4785,opPrint:Row()+110,4785 )//28
		opPrint:SkipLine(0.5)
		
		opPrint:PrintText(STR0067,opPrint:Row(),0100)//"VIENE"
		opPrint:PrintText(PadL((Transform(nlBi1P	,"@E 999,999,999.99")),14," "),opPrint:Row(),1685)
		opPrint:PrintText(PadL((Transform(nlIGV1P	,"@E 999,999,999.99")),14," "),opPrint:Row(),1885)
		opPrint:PrintText(PadL((Transform(nlBi2P	,"@E 999,999,999.99")),14," "),opPrint:Row(),2085)
		opPrint:PrintText(PadL((Transform(nlIGV2P	,"@E 999,999,999.99")),14," "),opPrint:Row(),2295)
		opPrint:PrintText(PadL((Transform(nlBi3P	,"@E 999,999,999.99")),14," "),opPrint:Row(),2495)
		opPrint:PrintText(PadL((Transform(nlIGV3P	,"@E 999,999,999.99")),14," "),opPrint:Row(),2695)
		opPrint:PrintText(PadL((Transform(nlVAGP	,"@E 999,999,999.99")),14," "),opPrint:Row(),2900)
		opPrint:PrintText(PadL((Transform(nlISCP	,"@E 999,999,999.99")),14," "),opPrint:Row(),3110)
		opPrint:PrintText(PadL((Transform(nlOTRP	,"@E 999,999,999.99")),14," "),opPrint:Row(),3265)
		opPrint:PrintText(PadL((Transform(nlImpTotP	,"@E 999,999,999.99")),14," "),opPrint:Row(),3490)
		opPrint:PrintText(PadL((Transform(nlICBP	,"@E 999,999,999.99")),14," "),opPrint:Row(),4860)

		opPrint:SkipLine(3)

		nlBi1P := 	nlBi2P := nlBi3P := nlIGV1P := 	nlIGV2P := nlIGV3P := nlVAGP := nlISCP := nlOTRP := nlImpTotP := nlICBP := 0
      
	EndIf 

	opPrint:Box (opPrint:Row()-IIf(!lDev6,2,0), 0010, opPrint:Row()+88, 4785 + 200)
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),0205,opPrint:Row()+88,0205 )//1
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),0380,opPrint:Row()+88,0380 )//2
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),0540,opPrint:Row()+88,0540 )//3
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),0650,opPrint:Row()+88,0650 )//4
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),0810,opPrint:Row()+88,0810 )//5
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),0960,opPrint:Row()+88,0960 )//6
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),1190,opPrint:Row()+88,1190 )//7
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),1300,opPrint:Row()+88,1300 )//8
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),1450,opPrint:Row()+88,1450 )//9
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),1660,opPrint:Row()+88,1660 )//10
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),1850,opPrint:Row()+88,1850 )//11
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),2050,opPrint:Row()+88,2050 )//12
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),2250,opPrint:Row()+88,2250 )//13
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),2450,opPrint:Row()+88,2450 )//14
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),2650,opPrint:Row()+88,2650 )//15
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),2850,opPrint:Row()+88,2850 )//16
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),3070,opPrint:Row()+88,3070 )//17
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),3260,opPrint:Row()+88,3260 )//18
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),3470,opPrint:Row()+88,3470 )//19
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),3650,opPrint:Row()+88,3650 )//20
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),3900,opPrint:Row()+88,3900 )//21
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),4020,opPrint:Row()+88,4020 )//22
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),4150,opPrint:Row()+88,4150 )//23
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),4252,opPrint:Row()+88,4252 )//24
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),4382,opPrint:Row()+88,4382 )//25
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),4482,opPrint:Row()+88,4482 )//26
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),4572,opPrint:Row()+88,4572 )//27
	opPrint:Line( opPrint:Row()-IIf(!lDev6,2,0),4785,opPrint:Row()+88,4785 )//28
		
	If 	Alltrim(TRB4->F3_ESPECIE) == "NCP" .OR.Alltrim(TRB4->F3_ESPECIE) == "NDI"
		opPrint:PrintText(TRB4->F2_NODIA, opPrint:Row(), 0030)//1
	Else
		opPrint:PrintText(TRB4->F1_NODIA, opPrint:Row(), 0030)//1
	Endif
	opPrint:PrintText(DtoC(TRB4->F3_EMISSAO), opPrint:Row(), 0250)//2

	IF AllTrim(TRB4->F1_TPDOC) $'14' 
		dFecha := ctod("//")

		If !Empty(TRB4->E2_BAIXA)
			If TRB4->E2_BAIXA <= TRB4->E2_VENCTO	// BAJA MENOR QUE EL VENCIMIENTO
				If TRB4->E2_BAIXA >= MV_PAR01 .And. TRB4->E2_BAIXA <= MV_PAR02
					dFecha := TRB4->E2_BAIXA
				EndIf
			ElseIf TRB4->E2_BAIXA > TRB4->E2_VENCTO	    // BAJA MAYOR QUE EL VENCIMIENTO
				If TRB4->E2_VENCTO >= MV_PAR01 .And. TRB4->E2_VENCTO <= MV_PAR02    
					dFecha := TRB4->E2_VENCTO
				EndIf
			EndIf
		Else
			If TRB4->E2_VENCTO >= MV_PAR01 .And. TRB4->E2_VENCTO <= MV_PAR02
				dFecha := TRB4->E2_VENCTO
			EndIf
		EndIf

		If Empty(dFecha)
			opPrint:PrintText("-",opPrint:Row(),0420)//3
		Else
			opPrint:PrintText(Dtoc(dFecha),opPrint:Row(),0420)//3
		EndIf

	ElseIF AllTrim(TRB4->F1_TPDOC) $'46' //retenciones de IGV No Domiciliados
		opPrint:PrintText(Dtoc(TRB4->F3_ENTRADA),opPrint:Row(),0420)//3
	Else
       	//--[ejemplo]---------------------------------------//
       	// periodo informado	= 05						//
       	// mes siguiente		= 06						//
       	// condicion			= menor o igual del mes 06	//
       	//--------------------------------------------------//
       	nMesActual	:= month(MV_PAR01)
       	nAnoActual	:= year(MV_PAR01)
       	nProxMes	:= nMesActual+1
       	If nProxMes>12
       		nProxMes:=1
       		nAnoActual++
       	EndIf
       	nUltDia:=lastday(ctod("01/"+strzero(nProxMes,2)+"/"+strzero(nAnoActual,4)),2)
		If TRB4->E2_VENCTO<=nUltDia		// menor o igual al mes siguiente del periodo informado
			opPrint:PrintText(Dtoc(TRB4->E2_VENCTO),opPrint:Row(),0420)//3
		Else
			opPrint:PrintText("",opPrint:Row(),0420)
		EndIf

	EndIf
	
	If 	Alltrim(TRB4->F3_ESPECIE) == "NCP" .OR.Alltrim(TRB4->F3_ESPECIE) == "NDI"
		opPrint:PrintText(TRB4->F2_TPDOC,opPrint:Row(),0580)//4
	Else
		opPrint:PrintText(TRB4->F1_TPDOC,opPrint:Row(),0580)//4
	Endif
	
	// ----------------------------------------------------------------------------------- //
	// Adicionado por SISTHEL para impresion de la serie 3 ( campo customizado )		   //
	// ----------------------------------------------------------------------------------- //
	lSerie3 := .F.
	If !lSerY  
		lSerie3 := .T.
	Else
		SF1->( DbSetOrder(1) ) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		If lSerY .AND. SF1->( MsSeek(TRB4->F3_FILIAL+TRB4->F3_NFISCAL+TRB4->F3_SERIE+TRB4->F3_CLIEFOR+TRB4->F3_LOJA) )
			lSerie3 := Empty(SF1->F1_YSERIE)
		Else
			lSerie3 := .T.
		EndIf
	EndIf
	
	If lSerY .AND. !lSerie3
		cSerie:=SF1->F1_YSERIE
	Else
		cSerie:= TRB4->F3_SERIE
		If lSerie2 .AND. !Empty(TRB4->F3_SERIE2)
			cSerie:=TRB4->F3_SERIE2
		EndIf
	EndIf	
	if empty(cSerie)
		cSerie := "0000"
	endif
	lRetnSer:=.T. 
	If ExistBlock("FISR12AS")
		lRetnSer:=ExecBlock("FISR12AS",.F.,.F.,{cSerie,TRB4->F1_TPDOC})
    Endif
	
	If AllTrim(TRB4->F1_TPDOC) $'50|52'   
		cSerie := Right(cSerie,3)
	ElseIf AllTrim(TRB4->F1_TPDOC) $ ('05')
		cSerie := "3"
	EndIf 
	
	If AllTrim(TRB4->F1_TPDOC) $'50|52|05'   
		opPrint:PrintText(cSerie,opPrint:Row(),0700)//5
	Else
		opPrint:PrintText(Iif(lRetnSer,RetNewSer(cSerie),cSerie),opPrint:Row(),0700)//5
	EndIf

	opPrint:PrintText(Space(1),opPrint:Row(),0700)//6
	
	opPrint:PrintText(TRB4->F3_NFISCAL,opPrint:Row(),0985)//7
	
	opPrint:PrintText(TRB4->A2_TIPDOC,opPrint:Row(),1230)//8

    opPrint:PrintText(IIf(!Empty(TRB4->A2_CGC),TRB4->A2_CGC,TRB4->A2_PFISICA),opPrint:Row(),1320)//9
		
    cNombre:=Subs( TRB4->A2_NOME,1,30)
    If lDev4
    	opPrint:PrintText(cNombre,opPrint:Row(),1460)	//10
    EndIf
	
	opPrint:PrintText(PadL(Transform(TRB4->BASECRD1  ,"@E 999,999,999.99"),14," "),opPrint:Row(),1685) //11 Base Imponible
	opPrint:PrintText(PadL(Transform(TRB4->VALORCRD1 ,"@E 999,999,999.99"),14," "),opPrint:Row(),1885) //12 IGV
	opPrint:PrintText(PadL(Transform(TRB4->BASECRD3  ,"@E 999,999,999.99"),14," "),opPrint:Row(),2085) //13 Base Imponible
	opPrint:PrintText(PadL(Transform(TRB4->VALORCRD3 ,"@E 999,999,999.99"),14," "),opPrint:Row(),2285) //14 IGV
	opPrint:PrintText(PadL(Transform(TRB4->BASECRD2  ,"@E 999,999,999.99"),14," "),opPrint:Row(),2475) //15 Base Imponible
	opPrint:PrintText(PadL(Transform(TRB4->VALORCRD2 ,"@E 999,999,999.99"),14," "),opPrint:Row(),2675) //16 IGV
	opPrint:PrintText(PadL(Transform(TRB4->F3_EXENTAS,"@E 999,999,999.99"),14," "),opPrint:Row(),2885) //17 Valor de las aquisiciones no gravadas
	opPrint:PrintText(PadL(Transform(TRB4->F3_VALIMP2,"@E 999,999,999.99"),14," "),opPrint:Row(),3095) //18 ISC
	opPrint:PrintText(PadL(Transform(TRB4->OUTROS    ,"@E 999,999,999.99"),14," "),opPrint:Row(),3295) //19 Outros tributos e cargos
	
	//Verificar se a TES é de importacao ou se o tipo da nota é de importação
	llAduan := .F.
	dbSelectArea("SD1")
	SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	If SD1->(MsSeek(TRB4->F3_FILIAL+TRB4->F3_NFISCAL+TRB4->F3_SERIE+TRB4->F3_CLIEFOR+TRB4->F3_LOJA))
		Do While SD1->(!EOF()) .And. TRB4->F3_FILIAL == SD1->D1_FILIAL .And. TRB4->F3_NFISCAL == SD1->D1_DOC .And.;
			TRB4->F3_SERIE == SD1->D1_SERIE .And. TRB4->F3_CLIEFOR == SD1->D1_FORNECE .And. TRB4->F3_LOJA == SD1->D1_LOJA
			
			//Homologacao Livro Fiscal Peru - OAS (16/04/13)
			dbSelectArea("SF4")
			SF4->(dbSetOrder(1)) //F4_FILIAL+F4_CODIGO
			IF SF4->(ColumnPos("F4_ADUANA")) > 0
				If SF4->( MsSeek( cFilSF4+SD1->D1_TES ) )
					If SF4->F4_ADUANA == "1"
						llAduan := .T.
						cAnoDua := STR(YEAR(SD1->D1_EMISSAO),4)
						Exit
					Else
						dbSelectArea("SF1")
						SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
						If SF1->(MsSeek(SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
							IF SF1->F1_TPDOC == "50"
								llAduan := .T.
								cAnoDua := STR(YEAR(SF1->F1_EMISSAO),4)
								Exit
							EndIf
						EndIf
					EndIf
				Endif
			EndIF
			SD1->(dbSkip())
		EndDo
	EndIf
	
	If llAduan
		opPrint:PrintText(PadL(Transform(TRB4->BASECRD1+TRB4->VALORCRD1+TRB4->F3_EXENTAS,"@E 999,999,999.99"),14," "),opPrint:Row(),3490)//20 
		opPrint:PrintText(cAnoDua,opPrint:Row(),0840) //Homologacao Livro Fiscal Peru - OAS (16/04/13)
	Else
		opPrint:PrintText(PadL(Transform(TRB4->F3_VALCONT,"@E 999,999,999.99"),14," "),opPrint:Row(),3490)//20
	EndIf
	                                
	If TRB4->F3_EXENTAS <> 0 .and. TRB4->A2_TIPO == 'X'
		opPrint:PrintText(AllTrim(Transform(TRB4->F3_NFISCAL,PesqPict("SF3","F3_NFISCAL"))),opPrint:Row(),3690)//21
	Else
		opPrint:PrintText("",opPrint:Row(),3690)//21
	EndIf

	cCertif := ""
	If TRB4->F3_VALIMP5 <> 0
		cCertif		:= TRB4->FE_CERTDET
		If lDev4
			opPrint:PrintText(cCertif,opPrint:Row(),3914)//22
		EndIf
		opPrint:PrintText(AllTrim(Transform(TRB4->FE_EMISSAO,PesqPict("SFE","FE_EMISSAO"))),opPrint:Row(),4045)//23
	Else
		If lDev4
			opPrint:PrintText("",opPrint:Row(),3914)//22
			opPrint:PrintText("",opPrint:Row(),4045)//23
		EndIf
	EndIf

	If 	Alltrim(TRB4->F3_ESPECIE) == "NCP" .OR.Alltrim(TRB4->F3_ESPECIE) == "NDI" 
		opPrint:PrintText(AllTrim(Transform(TRB4->F2_TXMOEDA,PesqPict("SF2","F2_TXMOEDA"))),opPrint:Row(),4180)//24		
	Else
		opPrint:PrintText(AllTrim(Transform(TRB4->F1_TXMOEDA,PesqPict("SF1","F1_TXMOEDA"))),opPrint:Row(),4180)//24
	Endif

	clF1DOC		 := ""
	clF1SERIE    := ""
	clF1EMISSAO  := ""
	clF1TpDoc	 :=	""        
	//Procura documento original para as notas de credito
	If 	Alltrim(TRB4->F3_ESPECIE) == "NCP" .OR.Alltrim(TRB4->F3_ESPECIE) == "NDI"
		DbSelectArea("SD2")
		SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		SD2->(MsSeek(TRB4->F3_FILIAL + TRB4->F3_NFISCAL + TRB4->F3_SERIE + TRB4->F3_CLIEFOR + TRB4->F3_LOJA))
		While TRB4->F3_FILIAL + TRB4->F3_NFISCAL + TRB4->F3_SERIE + TRB4->F3_CLIEFOR + TRB4->F3_LOJA == ;
			SD2->D2_FILIAL + SD2->D2_DOC	    +  SD2->D2_SERIE +  SD2->D2_CLIENTE +  SD2->D2_LOJA .And.;
			Empty(clF1TpDoc) .And. !EOF()
			If SD2->D2_ESPECIE == TRB4->F3_ESPECIE .And. !Empty(SD2->D2_NFORI)
				clF1DOC		 := SD2->D2_NFORI
				clF1SERIE    := SD2->D2_SERIORI
				DbSelectArea("SF1")
				SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
				If SF1->(MsSeek(SD2->D2_FILIAL+SD2->D2_NFORI+SD2->D2_SERIORI+SD2->D2_CLIENTE+SD2->D2_LOJA))
					clF1DOC		 := PADR(SF1->F1_DOC,GetSx3Cache("F1_DOC","X3_TAMANHO")," ")				
					If lSerY .And. !Empty(SF1->F1_YSERIE)
						clF1SERIE    := PADR(SF1->F1_YSERIE,GetSx3Cache("F1_YSERIE","X3_TAMANHO")," ")
					Else
						IF	lSerie2 .And. !Empty(SF1->F1_SERIE2)
							clF1SERIE    := PADR(SF1->F1_SERIE2,GetSx3Cache("F1_SERIE2","X3_TAMANHO")," ")
						Else
							clF1SERIE    := PADR(SF1->F1_SERIE,GetSx3Cache("F1_SERIE","X3_TAMANHO")," ")
							If Len(Alltrim(clF1SERIE))==3
								clF1SERIE := "0"+clF1SERIE
							EndIf
						EndIf	
			 		Endif
			 		clF1EMISSAO  := DtoC(SF1->F1_EMISSAO)
					clF1TpDoc	 :=	IIF(Empty(SF1->F1_TPDOC),"00",SF1->F1_TPDOC)				
				Endif
			Endif
			SD2->(DbSkip())
		Enddo
		//Procura documento original para as notas de debito
	ElseIf 	Alltrim(TRB4->F3_ESPECIE) == "NDP" .OR.Alltrim(TRB4->F3_ESPECIE) == "NCI"
		DbSelectArea("SD1")
		SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		SD1->(MsSeek(TRB4->F3_FILIAL + TRB4->F3_NFISCAL + TRB4->F3_SERIE + TRB4->F3_CLIEFOR + TRB4->F3_LOJA))
		While TRB4->F3_FILIAL + TRB4->F3_NFISCAL + TRB4->F3_SERIE + TRB4->F3_CLIEFOR + TRB4->F3_LOJA == ;
			SD1->D1_FILIAL + SD1->D1_DOC	    +  SD1->D1_SERIE +  SD1->D1_FORNECE +  SD1->D1_LOJA .And.;
			Empty(clF1TpDoc).And. !EOF()
			If SD1->D1_ESPECIE == TRB4->F3_ESPECIE .And. !Empty(SD1->D1_NFORI)
				clF1DOC		 := SD1->D1_NFORI
				clF1SERIE    := SD1->D1_SERIORI
				DbSelectArea("SF1")
				SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
				If SF1->(MsSeek(SD1->D1_FILIAL+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA))
					clF1DOC		 := PADR(SF1->F1_DOC,GetSx3Cache("F1_DOC","X3_TAMANHO")," ")
					If lSerY .And. !Empty(SF1->F1_YSERIE)
						clF1SERIE := PADR(SF1->F1_YSERIE,GetSx3Cache("F1_YSERIE","X3_TAMANHO")," ")    
					Else
						If	lSerie2 .And. !Empty(SF1->F1_SERIE2)
							clF1SERIE    := PADR(SF1->F1_SERIE2,GetSx3Cache("F1_SERIE2","X3_TAMANHO")," ")
						Else
							clF1SERIE    := PADR(SF1->F1_SERIE,GetSx3Cache("F1_SERIE","X3_TAMANHO")," ")
							If Len(Alltrim(clF1SERIE))==3
								clF1SERIE := "0"+clF1SERIE
							EndIf
						EndIf	
					EndIf
					clF1EMISSAO  := PADR(DtoC(SF1->F1_EMISSAO),GetSx3Cache("F1_EMISSAO","X3_TAMANHO")," ")
					clF1TpDoc	 :=	SF1->F1_TPDOC
				Endif
			Endif
			SD1->(DbSkip())
		EndDo
	EndIf
	
	opPrint:PrintText(clF1EMISSAO,opPrint:Row(),4280)//25
	opPrint:PrintText(clF1TpDoc,opPrint:Row(),4420)//26
	opPrint:PrintText(clF1SERIE,opPrint:Row(),4510)//27
	opPrint:PrintText(clF1DOC,opPrint:Row(),4645)//28
	opPrint:PrintText(PadL(Transform(TRB4->F3_VALICB,"@E 999,999,999.99"),14," "),opPrint:Row(),4860)//29
	
	If !lDev4
		For nlCont	:= 1 To 3
			If !Empty(MemoLine(cNombre, 15,nlCont,3,.T.)	)	//10
				opPrint:PrintText(MemoLine(cNombre, 15,nlCont,3,.T.),opPrint:Row(),1460)
			EndIf
			If !Empty(MemoLine(cCertif, 12,nlCont,3,.T.)	)	//22
				opPrint:PrintText(MemoLine(cCertif, 12,nlCont,3,.T.),opPrint:Row(),3914)
			EndIf
			opPrint:SkipLine(1)
		Next nlCont
	Else
		opPrint:SkipLine(1)
	EndIf
 			
	/*ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ Carregando variaveis para os totais. ³
	  ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁ*/		
  	nlBi1P 	+= TRB4->BASECRD1
	nlBi1T 	+= TRB4->BASECRD1
	nlIGV1P += TRB4->VALORCRD1
  	nlIGV1T += TRB4->VALORCRD1
    
  	nlBi2P 	+= TRB4->BASECRD3
  	nlBi2T 	+= TRB4->BASECRD3
  	nlIGV2P += TRB4->VALORCRD3
  	nlIGV2T += TRB4->VALORCRD3
  	
  	nlBi3P += TRB4->BASECRD2 
  	nlBi3T += TRB4->BASECRD2
  	nlIGV3P += TRB4->VALORCRD2
  	nlIGV3T += TRB4->VALORCRD2
  	
  	nlVAGP += TRB4->F3_EXENTAS
  	nlVAGT += TRB4->F3_EXENTAS
  	
  	nlISCP += TRB4->F3_VALIMP2
  	nlISCT += TRB4->F3_VALIMP2
  	
  	nlOTRP += TRB4->OUTROS
  	nlOTRT += TRB4->OUTROS
  	
  	If llAduan
	  	nlImpTotP += TRB4->BASECRD1+TRB4->VALORCRD1+TRB4->F3_EXENTAS
	  	nlImpTotT += TRB4->BASECRD1+TRB4->VALORCRD1+TRB4->F3_EXENTAS
  	Else
	  	nlImpTotP += TRB4->F3_VALCONT
	  	nlImpTotT += TRB4->F3_VALCONT
	EndIf

	nlICBP += TRB4->F3_VALICB
	nlICBT += TRB4->F3_VALICB

	TRB4->(DbSkip())
EndDo      
/*ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Total Geral, que e impressso no rodape da ultima pagina. ³
  ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁ*/ 
opPrint:Box ( opPrint:Row()-2,1450,opPrint:Row()+30,3650)
opPrint:Line( opPrint:Row()-2,1660,opPrint:Row()+30,1660 )
opPrint:Line( opPrint:Row()-2,1850,opPrint:Row()+30,1850 )
opPrint:Line( opPrint:Row()-2,2050,opPrint:Row()+30,2050 )
opPrint:Line( opPrint:Row()-2,2250,opPrint:Row()+30,2250 )
opPrint:Line( opPrint:Row()-2,2450,opPrint:Row()+30,2450 )
opPrint:Line( opPrint:Row()-2,2650,opPrint:Row()+30,2650 )
opPrint:Line( opPrint:Row()-2,2850,opPrint:Row()+30,2850 )
opPrint:Line( opPrint:Row()-2,3070,opPrint:Row()+30,3070 )
opPrint:Line( opPrint:Row()-2,3260,opPrint:Row()+30,3260 )
opPrint:Line( opPrint:Row()-2,3470,opPrint:Row()+30,3470 )

IIf(lDev4, EspCabec(9), )
opPrint:PrintText(STR0058,opPrint:Row(),1455) //"TOTAL GENERAL:   "
opPrint:PrintText(PadL((Transform(nlBi1T	,"@E 999,999,999.99")),14," "),opPrint:Row(),1685)
opPrint:PrintText(PadL((Transform(nlIGV1T	,"@E 999,999,999.99")),14," "),opPrint:Row(),1885)
opPrint:PrintText(PadL((Transform(nlBi2T	,"@E 999,999,999.99")),14," "),opPrint:Row(),2085)
opPrint:PrintText(PadL((Transform(nlIGV2T	,"@E 999,999,999.99")),14," "),opPrint:Row(),2295)
opPrint:PrintText(PadL((Transform(nlBi3T	,"@E 999,999,999.99")),14," "),opPrint:Row(),2495)
opPrint:PrintText(PadL((Transform(nlIGV3T	,"@E 999,999,999.99")),14," "),opPrint:Row(),2695)
opPrint:PrintText(PadL((Transform(nlVAGT	,"@E 999,999,999.99")),14," "),opPrint:Row(),2900)
opPrint:PrintText(PadL((Transform(nlISCT	,"@E 999,999,999.99")),14," "),opPrint:Row(),3110)
opPrint:PrintText(PadL((Transform(nlOTRT	,"@E 999,999,999.99")),14," "),opPrint:Row(),3265)
opPrint:PrintText(PadL((Transform(nlImpTotT	,"@E 999,999,999.99")),14," "),opPrint:Row(),3490)
opPrint:PrintText(PadL((Transform(nlICBT	,"@E 999,999,999.99")),14," "),opPrint:Row(),4860)

opPrint:EndPage()

If File( AllTrim(cpArqTRB)+GetDBExtension())       
	Ferase(AllTrim(cpArqTRB)+GetDBExtension())       
EndIf         

If MV_PAR06 == 1 .And. MV_PAR08 == 1
	If !lAutomato //Tratamiento para automatizados
		Processa({|| GerArq(AllTrim(MV_PAR07))},,STR0063) //"GENERANDO ARCHIVO Txt"
	Else
		GerArq(AllTrim(MV_PAR07))
	EndIf
EndIf
If MV_PAR06 == 1 .And. MV_PAR08 == 2
	If !lAutomato //Tratamiento para automatizados
		Processa({|| GerArq1(AllTrim(MV_PAR07))},,STR0063) //"GENERANDO ARCHIVO Txt"
	Else
		GerArq1(AllTrim(MV_PAR07))
	EndIf
EndIf

//Cierra tabla temporal.
F012DelTab()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F12CABEC  ³ Autor ³ Sergio Daniel	        ³ Data ³12/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Cabeçalho do Relatoriorio.			    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ F12CABEC()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					             							  ³±±
±±³			 ³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Livros fiscais.	                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F12CABEC() 

	Local aPosText	:= {20, 205, 380, 540, 650, 810, 960, 1190, 1300, 1450, 1660, 1850, 2050, 2250, 2450, 2650, 2850, 3070, 3260, 3470, 3650, 3900, 4020, 4150, 4252, 4382, 4482, 4572, 4795}
	Local lDev4		:= opPrint:nDevice == 4	//Impresion mediante opcion 4 - Planilla 
	
	If !lDev4
		opPrint:oFontBody:Name := "Times New Roman"
		opPrint:oFontBody:nHeight := -6
	EndIf
	
	If opPrint:nDevice == 6
		//opPrint:oPrint:NMargLeft	:= 5
		//opPrint:oPrint:NMargRight	:= 5
		opPrint:oPrint:NPageWidth	:= 4960.5 + 200
		opPrint:oPrint:NPageHeight	:= 3478
	EndIf

	opPrint:PrintText(IIf(MV_PAR08 == 1, STR0066, STR0068), opPrint:Row(), 0005) //"FORMATO 8.1: REGISTRO DE COMPRAS"#"FORMATO 8.2: REGISTRO DE COMPRAS - INFORMACIÓN DE OPERACIONES CON SUJETOS NO DOMICILIADOS"
	opPrint:SkipLine(1) 
   	
	opPrint:PrintText(STR0002+AllTrim(Str(Month(MV_PAR01)))+"/"+AllTrim(Str(Year(MV_PAR01))) +" - " + AllTrim(Str(Month(MV_PAR02)))+"/"+AllTrim(Str(Year(MV_PAR02))), opPrint:Row(), 0005) //"PERIODO: "
	opPrint:SkipLine(1)
	
	opPrint:PrintText(STR0003+AllTrim(SM0->M0_CGC), opPrint:Row(), 0005) //"RUC: "
	opPrint:SkipLine(1) 
	
	opPrint:PrintText(STR0004+Upper(AllTrim(Capital(SM0->M0_NOMECOM))), opPrint:Row(), 0005) //"APELLIDOS Y NOMBRES, DENOMINACION O RAZON SOCIAL: "
	opPrint:SkipLine(1) 
		
	// BOX DO CABECALHO
	opPrint:Box ( 0125, 0010, 0613, 4785 + 200)               
	                                  
	//LINHAS HORIZONTAIS
	opPrint:Line( 0365,0540,0365,0960 )
	opPrint:Line( 0440,1190,0440,1450 )
	opPrint:Line( 0365,1190,0365,4150 )
	opPrint:Line( 0365,4252,0365,4785 )   
	
	// LINHAS VERTICAIS
	opPrint:Line( 0125,0205,0613,0205 )//1
	opPrint:Line( 0125,0380,0613,0380 )//2
	opPrint:Line( 0125,0540,0613,0540 )//3
	opPrint:Line( 0365,0650,0613,0650 )//4
	opPrint:Line( 0365,0810,0613,0810 )//5
	opPrint:Line( 0125,0960,0613,0960 )//6
	opPrint:Line( 0125,1190,0613,1190 )//7
	opPrint:Line( 0440,1300,0613,1300 )//8
	opPrint:Line( 0365,1450,0613,1450 )//9
	opPrint:Line( 0125,1660,0613,1660 )//10
	opPrint:Line( 0365,1850,0613,1850 )//11
	opPrint:Line( 0125,2050,0613,2050 )//12
	opPrint:Line( 0365,2250,0613,2250 )//13
	opPrint:Line( 0125,2450,0613,2450 )//14
	opPrint:Line( 0365,2650,0613,2650 )//15
	opPrint:Line( 0125,2850,0613,2850 )//16
	opPrint:Line( 0365,3070,0613,3070 )//17
	opPrint:Line( 0365,3260,0613,3260 )//18
	opPrint:Line( 0365,3470,0613,3470 )//19
	opPrint:Line( 0365,3650,0613,3650 )//20
	opPrint:Line( 0125,3900,0613,3900 )//21
	opPrint:Line( 0365,4020,0613,4020 )//22
	opPrint:Line( 0125,4150,0613,4150 )//23
	opPrint:Line( 0125,4252,0613,4252 )//24
	opPrint:Line( 0365,4382,0613,4382 )//25
	opPrint:Line( 0365,4482,0613,4482 )//26
	opPrint:Line( 0365,4572,0613,4572 )//27
	opPrint:Line( 0125,4785,0613,4785 )//28

IIf(lDev4, EspCabec(6), )
opPrint:PrintText(STR0071,opPrint:Row(),aPosText[7]+90)//"N° DEL"
opPrint:SkipLine(1)

IIf(lDev4, EspCabec(6), )
opPrint:PrintText(STR0072,opPrint:Row(),aPosText[7]+20)//"COMPROBANTE DE"
opPrint:SkipLine(1)

IIf(lDev4, EspCabec(6), )
opPrint:PrintText(STR0073,opPrint:Row(),aPosText[7]+15)//"PAGO, DOCUMENTO,"
IIf(lDev4, EspCabec(7), )
opPrint:PrintText(STR0074,opPrint:Row(),aPosText[13]+120)//"ADQUISICIONES"
opPrint:SkipLine(1)

IIf(lDev4, EspCabec(6), )
opPrint:PrintText(STR0075,opPrint:Row(),aPosText[7]+30)//"N° DE ORDEN DEL"
IIf(lDev4, EspCabec(5), )
opPrint:PrintText(STR0074,opPrint:Row(),aPosText[11]+120)//"ADQUISICIONES"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0076,opPrint:Row(),aPosText[13]+60)//"GRAVADAS DESTINADAS A"
opPrint:SkipLine(1)

IIf(lDev4, EspCabec(6), )
opPrint:PrintText(STR0077,opPrint:Row(),aPosText[7]+15)//"FORMULARIO FISICO"
IIf(lDev4, EspCabec(3), )
opPrint:PrintText(STR0076,opPrint:Row(),aPosText[11]+60)//"GRAVADAS DESTINADAS A"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0078,opPrint:Row(),aPosText[13]+90)//"OPERACIONES GRAVADAS"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0074,opPrint:Row(),aPosText[15]+120)//"ADQUISICIONES"
opPrint:SkipLine(1)

IIf(lDev4, EspCabec(3), )
opPrint:PrintText(STR0079,opPrint:Row(),aPosText[5])//"COMPROBANTE DE PAGO"
IIf(lDev4, EspCabec(2), )
opPrint:PrintText(STR0080,opPrint:Row(),aPosText[7]+30)//"O VIRTUAL, N° DE"
IIf(lDev4, EspCabec(3), )
opPrint:PrintText(STR0081,opPrint:Row(),aPosText[11]+80)//"A OPERACIONES GRAVADAS"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0082,opPrint:Row(),aPosText[13]+90)//"Y/O DE EXPORTACION Y A"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0076,opPrint:Row(),aPosText[15]+60)//"GRAVADAS DESTINADAS A"
IIf(lDev4, EspCabec(5), )
opPrint:PrintText(STR0083,opPrint:Row(),aPosText[22])//"CONSTANCIA DE DEPOSITO"
IIf(lDev4, EspCabec(3), )
opPrint:PrintText(STR0084,opPrint:Row(),aPosText[25]+80)//"REFERENCIA DEL COMPROBANTE DE PAGO"
opPrint:SkipLine(1)

IIf(lDev4, EspCabec(6), )
opPrint:PrintText(STR0085,opPrint:Row(),aPosText[7]+70)//"DUA, DSI O"
IIf(lDev4, EspCabec(3), )
opPrint:PrintText(STR0086,opPrint:Row(),aPosText[11]+90)//"Y/O DE EXPORTACION"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0087,opPrint:Row(),aPosText[13]+80)//"OPERACIONES NO GRAVADAS"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0087,opPrint:Row(),aPosText[15]+60)//"OPERACIONES NO GRAVADAS"
IIf(lDev4, EspCabec(5), )
opPrint:PrintText(STR0088,opPrint:Row(),aPosText[22]+40)//"DE DETRACCION(3)"
IIf(lDev4, EspCabec(3), )
opPrint:PrintText(STR0089,opPrint:Row(),aPosText[25]+80)//"O DOCUMENTO ORIGINAL QUE SE MODIFICA"
opPrint:SkipLine(1)

IIf(lDev4, EspCabec(6), )
opPrint:PrintText(STR0090,opPrint:Row(),aPosText[7]+30)//"LIQUIDACION DE"
opPrint:SkipLine(1)

IIf(lDev4, EspCabec(6), )
opPrint:PrintText(STR0091,opPrint:Row(),aPosText[7]+40)//"COBRANZA U"
opPrint:PrintText(STR0092,opPrint:Row(),aPosText[8]+40)//"DOCUMENTO DE"
opPrint:SkipLine(1)

IIf(lDev4, EspCabec(6), )
opPrint:PrintText(STR0093,opPrint:Row(),aPosText[7]+80)//"OTROS"
opPrint:PrintText(STR0094,opPrint:Row(),aPosText[8]+60)//"IDENTIDAD"
opPrint:SkipLine(1)

IIf(lDev4, EspCabec(4), )
opPrint:PrintText(STR0095,opPrint:Row(),aPosText[5]+40)//"SERIE O"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0096,opPrint:Row(),aPosText[7]+40)//"DOCUMENTOS"
IIf(lDev4, EspCabec(13), )
opPrint:PrintText(STR0097,opPrint:Row(),aPosText[21]+100)//"N° DE"
opPrint:SkipLine(1)

opPrint:PrintText(STR0098,opPrint:Row(),aPosText[1]+45)//"NUMERO"
opPrint:PrintText(STR0099,opPrint:Row(),aPosText[2]+30)//"FECHA DE"
IIf(lDev4, EspCabec(2), )
opPrint:PrintText(STR0100,opPrint:Row(),aPosText[5]+35)//"CODIGO"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0101,opPrint:Row(),aPosText[7]+40)//"EMITIDOS POR"
IIf(lDev4, EspCabec(13), )
opPrint:PrintText(STR0102,opPrint:Row(),aPosText[21]+50)//"COMPROBANTE"
opPrint:SkipLine(1)

opPrint:PrintText(STR0103,opPrint:Row(),aPosText[1]+20)//"CORRELATIVO"
opPrint:PrintText(STR0104,opPrint:Row(),aPosText[2]+20)//"EMISION DEL"
opPrint:PrintText(STR0099,opPrint:Row(),aPosText[3]+20)//"FECHA DE"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0105,opPrint:Row(),aPosText[5]+60)//"DE LA"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0106,opPrint:Row(),aPosText[7]+40)//"SUNAT PARA"
IIf(lDev4, EspCabec(2), )
opPrint:PrintText(STR0107,opPrint:Row(),aPosText[10]+30)//"APELLIDOS Y"
IIf(lDev4, EspCabec(10), )
opPrint:PrintText(STR0108,opPrint:Row(),aPosText[21]+80)//"DE PAGO"
IIf(lDev4, EspCabec(6), )
opPrint:PrintText(STR0071,opPrint:Row(),aPosText[28]+70)//"N° DEL"
opPrint:SkipLine(1)

opPrint:PrintText(STR0109,opPrint:Row(),aPosText[1]+10)//"DEL REGISTRO O"
opPrint:PrintText(STR0102,opPrint:Row(),aPosText[2]+10)//"COMPROBANTE"
opPrint:PrintText(STR0111,opPrint:Row(),aPosText[3]+10)//"VENCIMIENTO"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0112,opPrint:Row(),aPosText[5]+10)//"DEPENDENCIA"
opPrint:PrintText(STR0113,opPrint:Row(),aPosText[6]+40)//"ANO DE"
opPrint:PrintText(STR0114,opPrint:Row(),aPosText[7]+30)//"ACREDITAR EL"
IIf(lDev4, EspCabec(2), )
opPrint:PrintText(STR0115,opPrint:Row(),aPosText[10]+40)//"NOMBRES"
IIf(lDev4, EspCabec(6), )
opPrint:PrintText(STR0116,opPrint:Row(),aPosText[17]+50)//"VALOR DE LAS"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0093,opPrint:Row(),aPosText[19]+60)//"OTROS"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0117,opPrint:Row(),aPosText[21]+60)//"EMITIDO POR"
IIf(lDev4, EspCabec(6), )
opPrint:PrintText(STR0102,opPrint:Row(),aPosText[28]+45)//"COMPROBANTE"
opPrint:SkipLine(1)

opPrint:PrintText(STR0118,opPrint:Row(),aPosText[1])//"CODIGO UNICO DE"
opPrint:PrintText(STR0119,opPrint:Row(),aPosText[2]+30)//"DE PAGO O"
opPrint:PrintText(STR0120,opPrint:Row(),aPosText[3]+20)//"O FECHA DE"
opPrint:PrintText(STR0121,opPrint:Row(),aPosText[4]+30)//"TIPO"
opPrint:PrintText(STR0122,opPrint:Row(),aPosText[5]+15)//"ADUANERA"
opPrint:PrintText(STR0123,opPrint:Row(),aPosText[6]+20)//"EMISION DE"
opPrint:PrintText(STR0124,opPrint:Row(),aPosText[7]+20)//"CREDITO FISCAL EN"
opPrint:PrintText(STR0121,opPrint:Row(),aPosText[8]+30)//"TIPO"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0125,opPrint:Row(),aPosText[10]+10)//"DENOMINACION O"
opPrint:PrintText(STR0126,opPrint:Row(),aPosText[11]+50)//"BASE"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0126,opPrint:Row(),aPosText[13]+50)//"BASE"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0126,opPrint:Row(),aPosText[15]+50)//"BASE"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0074,opPrint:Row(),aPosText[17]+30)//"ADQUISICIONES"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0127,opPrint:Row(),aPosText[19]+50)//"TRIBUTOS"
opPrint:PrintText(STR0128,opPrint:Row(),aPosText[20]+60)//"IMPORTE"
opPrint:PrintText(STR0129,opPrint:Row(),aPosText[21]+80)//"SUJETO NO"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0099,opPrint:Row(),aPosText[23]+20)//"FECHA DE"
opPrint:PrintText(STR0130,opPrint:Row(),aPosText[24]+10)//"TIPO DE"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0121,opPrint:Row(),aPosText[26]+20)//"TIPO"
IIf(lDev4, EspCabec(1), )
opPrint:PrintText(STR0119,opPrint:Row(),aPosText[28]+55)//"DE PAGO O"
opPrint:SkipLine(1)

opPrint:PrintText(STR0131,opPrint:Row(),aPosText[1]+10)//"LA OPERACION"
opPrint:PrintText(STR0132,opPrint:Row(),aPosText[2]+20)//"DOCUMENTO"
opPrint:PrintText(STR0133,opPrint:Row(),aPosText[3]+40)//"PAGO(1)"
opPrint:PrintText(STR0134,opPrint:Row(),aPosText[4]+02)//"(TABLA 10)"
opPrint:PrintText(STR0135,opPrint:Row(),aPosText[5]+30)//"(TABLA 11)"
opPrint:PrintText(STR0136,opPrint:Row(),aPosText[6]+05)//"LA DUA O DSI"
opPrint:PrintText(STR0137,opPrint:Row(),aPosText[7]+20)//"LA IMPORTACION"
opPrint:PrintText(STR0138,opPrint:Row(),aPosText[8]+10)//"TABLA(2)"
opPrint:PrintText(STR0098,opPrint:Row(),aPosText[9]+20)//"NUMERO"
opPrint:PrintText(STR0139,opPrint:Row(),aPosText[10]+30)//"RAZON SOCIAL"
opPrint:PrintText(STR0140,opPrint:Row(),aPosText[11]+30)//"IMPONIBLE"
opPrint:PrintText(STR0141,opPrint:Row(),aPosText[12]+80)//"IGV"
opPrint:PrintText(STR0140,opPrint:Row(),aPosText[13]+30)//"IMPONIBLE"
opPrint:PrintText(STR0141,opPrint:Row(),aPosText[14]+80)//"IGV"
opPrint:PrintText(STR0140,opPrint:Row(),aPosText[15]+30)//"IMPONIBLE"
opPrint:PrintText(STR0141,opPrint:Row(),aPosText[16]+80)//"IGV"
opPrint:PrintText(STR0142,opPrint:Row(),aPosText[17]+40)//"NO GRAVADAS"
opPrint:PrintText(STR0143,opPrint:Row(),aPosText[18]+80)//"ISC"
opPrint:PrintText(STR0144,opPrint:Row(),aPosText[19]+40)//"Y CARGOS"
opPrint:PrintText(STR0145,opPrint:Row(),aPosText[20]+70)//"TOTAL"
opPrint:PrintText(STR0146,opPrint:Row(),aPosText[21]+50)//"DOMICILIADO(2)"
opPrint:PrintText(STR0098,opPrint:Row(),aPosText[22]+10)//"NUMERO"
opPrint:PrintText(STR0147,opPrint:Row(),aPosText[23]+25)//"EMISION"
opPrint:PrintText(STR0148,opPrint:Row(),aPosText[24]+10)//"CAMBIO"
opPrint:PrintText(STR0149,opPrint:Row(),aPosText[25]+30)//"FECHA"
opPrint:PrintText(STR0134,opPrint:Row(),aPosText[26])//"(TABLA 10)"
opPrint:PrintText(STR0150,opPrint:Row(),aPosText[27]+15)//"SERIE"
opPrint:PrintText(STR0132,opPrint:Row(),aPosText[28]+50)//"DOCUMENTO"
opPrint:PrintText(STR0152,opPrint:Row(),aPosText[29]+80)//"ICBPER"
opPrint:SkipLine(1.2)

If !lDev4
	opPrint:oFontBody:Name := "Times New Roman"
	opPrint:oFontBody:nHeight := -7
EndIf

Return(.T.)	      
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FMontQuery³ Autor ³ Sergio Daniel	        ³ Data ³10/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta Querys utilizadas para a impressão do relatório.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FMontQuery()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Livros fiscais.	                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/	
Static Function FMontQuery(aFiliais)

Local nI       := 0
Local clQuery  := ""
Local cICBPER   := ""

// Campo del nuevo impuesto ICBPER
If lICBPER
	SFB->( dbGoTop() )
	Do While !SFB->( EoF() )
		If "M100ICB" $ SFB->FB_FORMENT .And. "M460ICB" $ Upper(SFB->FB_FORMSAI)
			cICBPER := SFB->FB_CPOLVRO
			Exit
		EndIf

		SFB->( DbSkip() )
	EndDo

	lICBPER := ( SF3->( ColumnPos("F3_VALIMP"+cICBPER) ) > 0 )
EndIf

/*ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Query para trazer os registros que seraoimpressos. ³
ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁ*/

clQuery := " SELECT  "
clQuery += " 	SUM(F3_EXENTAS) AS F3_EXENTAS,  "
clQuery += " 	SUM(F3_VALIMP2) AS F3_VALIMP2,  "
clQuery += " 	SUM(F3_VALIMP5) AS F3_VALIMP5,  "
clQuery += " 	SUM(F3_VALCONT) AS F3_VALCONT,  "
clQuery += " 	SUM(OUTROS) 	AS OUTROS,  "
clQuery += " 	SUM(BASECRD1) AS BASECRD1,  "
clQuery += " 	SUM(BASECRD2) AS BASECRD2,  "
clQuery += " 	SUM(BASECRD3) AS BASECRD3,  "
clQuery += " 	SUM(VALORCRD1) AS VALORCRD1,  "
clQuery += " 	SUM(VALORCRD2) AS VALORCRD2,  "
clQuery += " 	SUM(VALORCRD3) AS VALORCRD3,  "
clQuery += " 	SUM(F3_VALICB) AS F3_VALICB,  "
clQuery += " 	F3_FILIAL, F3_EMISSAO, F3_SERIE, F3_NFISCAL, A2_TIPDOC, A2_TIPO,  "
If lSerie2
	clQuery += " (CASE WHEN F3_SERIE2 = '' THEN F3_SERIE ELSE F3_SERIE2 END) AS F3_SERIE2,"
EndIf
clQuery += "         A2_PFISICA,A2_CGC, A2_NOME, E2_VENCTO,E2_BAIXA,E2_PARCELA,F3_ESPECIE,F3_CLIEFOR,F3_LOJA,  "
If lRenta
	clQuery += "         F1_NODIA,F2_NODIA,  FE_CERTDET,FE_TIPO, FE_EMISSAO, F1_TXMOEDA, F2_TXMOEDA,F1_TPDOC,F2_TPDOC, F3_ENTRADA, A2_DOMICIL,	A2_CODNAC, A2_CONVEN, F1_MOEDA, F2_MOEDA, F1_TPRENTA, F2_TPRENTA " + IIF(lMeslib,",FE_MESLIB","") 
Else
	clQuery += "         F1_NODIA,F2_NODIA,  FE_CERTDET,FE_TIPO, FE_EMISSAO, F1_TXMOEDA, F2_TXMOEDA,F1_TPDOC,F2_TPDOC, F3_ENTRADA, A2_DOMICIL,	A2_CODNAC, A2_CONVEN, F1_MOEDA, F2_MOEDA" + IIF(lMeslib,",FE_MESLIB","") 
EndIf

If SF1->(ColumnPos("F1_TIPOPE")) > 0
	clQuery += ", F1_TIPOPE"
EndIf

clQuery += "  FROM (  "

clQuery += " SELECT	"

clQuery += " F3_FILIAL, "

clQuery += " F3_EMISSAO, "

clQuery += " F3_SERIE, "

clQuery += " A2_DOMICIL, " 

clQuery += " A2_CODNAC, " 

clQuery += " A2_CONVEN, " 

clQuery += " F1_MOEDA, " 

clQuery += " F2_MOEDA, " 

If lRenta
	clQuery += " F1_TPRENTA, " 
	clQuery += " F2_TPRENTA, "
EndIf

If SF1->(ColumnPos("F1_TIPOPE")) > 0
	clQuery += " F1_TIPOPE, "
EndIf

If lMeslib
	clQuery += " FE_MESLIB,"
EndIf

If lSerie2
	clQuery += " (CASE WHEN F3_SERIE2 = '' THEN F3_SERIE ELSE F3_SERIE2 END) AS F3_SERIE2, "
EndIf

clQuery += " F3_NFISCAL, F1_TPDOC,F2_TPDOC, "

clQuery += " CASE	WHEN	F3_DTCANC = '' "
clQuery += "		THEN 	A2_TIPDOC "
clQuery += "		ELSE '06' "
clQuery += " END			AS A2_TIPDOC, "

clQuery += " A2_TIPO, "

clQuery += " CASE	WHEN	F3_DTCANC = '' "
clQuery += "		THEN 	A2_CGC "
clQuery += "		ELSE 'Anulado' "
clQuery += " END			AS A2_CGC, "

clQuery += " CASE	WHEN	F3_DTCANC = '' "
clQuery += "		THEN 	A2_PFISICA "
clQuery += "		ELSE 'Anulado' "
clQuery += " END			AS A2_PFISICA, "

clQuery += " A2_NOME, "

//Para F4_CREDIGV == 1
clQuery += " CASE	WHEN	F3_DTCANC = '' AND F4_CREDIGV IN (' ','1') AND F3_ESPECIE NOT IN ('NCP','NDI') AND F1_TPDOC<> '25' "
clQuery += "		THEN 	SUM(F3_BASIMP1) "
clQuery += "		WHEN	F3_DTCANC = '' AND F4_CREDIGV IN (' ','1') AND ( F3_ESPECIE IN ('NCP','NDI') OR F1_TPDOC ='25' ) "
clQuery += "		THEN 	SUM(F3_BASIMP1*-1) "
clQuery += "		ELSE 0 "
clQuery += " END			AS BASECRD1, "

clQuery += " CASE	WHEN	F3_DTCANC = '' AND F4_CREDIGV IN (' ','1') AND F3_ESPECIE NOT IN ('NCP','NDI') AND F1_TPDOC<> '25' "
clQuery += "		THEN 	SUM(F3_VALIMP1) "
clQuery += "		WHEN	F3_DTCANC = '' AND F4_CREDIGV IN (' ','1') AND ( F3_ESPECIE IN ('NCP','NDI') OR F1_TPDOC ='25' ) "
clQuery += "		THEN 	SUM(F3_VALIMP1*-1) "
clQuery += "		ELSE 0 "
clQuery += " END			AS VALORCRD1, "
//Para F4_CREDIGV == 2
clQuery += " CASE	WHEN	F3_DTCANC = '' AND F4_CREDIGV ='2' AND F3_ESPECIE NOT IN ('NCP','NDI') AND F1_TPDOC<> '25' "
clQuery += "		THEN 	SUM(F3_BASIMP1) "
clQuery += "		WHEN	F3_DTCANC = '' AND F4_CREDIGV ='2' AND ( F3_ESPECIE IN ('NCP','NDI') OR F1_TPDOC ='25' ) "
clQuery += "		THEN 	SUM(F3_BASIMP1*-1) "
clQuery += "		ELSE 0 "
clQuery += " END			AS BASECRD2, "

clQuery += " CASE	WHEN	F3_DTCANC = '' AND F4_CREDIGV ='2' AND F3_ESPECIE NOT IN ('NCP','NDI') AND F1_TPDOC<> '25' "
clQuery += "		THEN 	SUM(F3_VALIMP1) "
clQuery += "        WHEN	F3_DTCANC = '' AND F4_CREDIGV ='2' AND ( F3_ESPECIE IN ('NCP','NDI') OR F1_TPDOC ='25' )"
clQuery += "		THEN 	SUM(F3_VALIMP1*-1) "
clQuery += "		ELSE 0 "
clQuery += " END			AS VALORCRD2, "

//Para F4_CREDIGV == 3
clQuery += " CASE	WHEN	F3_DTCANC = '' AND F4_CREDIGV = '3'  AND F3_ESPECIE NOT IN ('NCP','NDI') AND F1_TPDOC<> '25' "
clQuery += "		THEN 	SUM(F3_BASIMP1) "
clQuery += "     	WHEN	F3_DTCANC = '' AND F4_CREDIGV = '3'  AND ( F3_ESPECIE IN ('NCP','NDI') OR F1_TPDOC ='25' )"
clQuery += "		THEN 	SUM(F3_BASIMP1* -1) "
clQuery += "		ELSE 0 "
clQuery += " END			AS BASECRD3, "

clQuery += " CASE	WHEN	F3_DTCANC = '' AND F4_CREDIGV = '3' AND F3_ESPECIE NOT IN ('NCP','NDI') AND F1_TPDOC<> '25' "
clQuery += "		THEN 	SUM(F3_VALIMP1) "
clQuery += "      	WHEN	F3_DTCANC = '' AND F4_CREDIGV = '3' AND ( F3_ESPECIE IN ('NCP','NDI') OR F1_TPDOC ='25' )"
clQuery += "		THEN 	SUM(F3_VALIMP1*-1) "
clQuery += "		ELSE 0 "
clQuery += " END			AS VALORCRD3, "

clQuery += " CASE	WHEN	F3_DTCANC = '' AND F3_ESPECIE NOT IN ('NCP','NDI') AND F1_TPDOC<> '25' "
clQuery += "		THEN 	(CASE WHEN F4_CREDIGV='2' AND F4_CALCIGV='2' THEN SUM(F3_VALCONT) ELSE SUM(F3_EXENTAS) END) "
clQuery += "     	WHEN	F3_DTCANC = '' AND ( F3_ESPECIE IN ('NCP','NDI') OR F1_TPDOC ='25' ) "
clQuery += "		THEN 	SUM(F3_EXENTAS*-1) "
clQuery += "		ELSE 0 "
clQuery += " END			AS F3_EXENTAS, "

clQuery += " CASE	WHEN	F3_DTCANC = ''  AND F3_ESPECIE NOT IN ('NCP','NDI') AND F1_TPDOC<> '25' "
clQuery += "		THEN 	SUM(F3_VALIMP2) "
clQuery += "        WHEN	F3_DTCANC = ''  AND ( F3_ESPECIE IN ('NCP','NDI') OR F1_TPDOC ='25' ) "
clQuery += "		THEN 	SUM(F3_VALIMP2 * -1) "
clQuery += "		ELSE 0 "
clQuery += " END			AS F3_VALIMP2, "

clQuery += " CASE	WHEN	F3_DTCANC = '' AND F3_ESPECIE NOT IN ('NCP','NDI') AND F1_TPDOC<> '25' "
clQuery += "		THEN 	SUM(F3_VALIMP5) "
clQuery += "     	WHEN	F3_DTCANC = '' AND ( F3_ESPECIE IN ('NCP','NDI') OR F1_TPDOC ='25' ) "
clQuery += "		THEN 	SUM(F3_VALIMP5*-1) "
clQuery += "		ELSE 0 "
clQuery += " END			AS F3_VALIMP5, "

clQuery += " CASE	WHEN	F3_DTCANC = '' AND F3_ESPECIE NOT IN ('NCP','NDI') AND F1_TPDOC<> '25' "
clQuery += "		THEN 	SUM(F3_VALCONT) "
clQuery += "      	WHEN	F3_DTCANC = '' AND ( F3_ESPECIE IN ('NCP','NDI') OR F1_TPDOC ='25' ) "
clQuery += "		THEN 	SUM(F3_VALCONT*-1) "
clQuery += "		ELSE 0 "
clQuery += " END			AS F3_VALCONT, "

If lICBPER
	clQuery += " CASE	WHEN	F3_DTCANC = '' AND F3_ESPECIE NOT IN ('NCP','NDI') AND F1_TPDOC<> '25' "
	clQuery += "		THEN 	SUM(F3_VALIMP" + cICBPER + ") "
	clQuery += "      	WHEN	F3_DTCANC = '' AND ( F3_ESPECIE IN ('NCP','NDI') OR F1_TPDOC ='25' ) "
	clQuery += "		THEN 	SUM(F3_VALIMP" + cICBPER + "*-1) "
	clQuery += "		ELSE 0 "
	clQuery += " END			AS F3_VALICB, "
Else
	clQuery += "        0 AS F3_VALICB, "
EndIf

clQuery += " E2_VENCTO, "
clQuery += " E2_BAIXA, "
clQuery += " E2_PARCELA, "

clQuery += " CASE	WHEN	F3_DTCANC = '' "
clQuery += "		THEN 	F3_ESPECIE "
clQuery += "		ELSE '' "
clQuery += " END			AS F3_ESPECIE, "

clQuery += " CASE	WHEN	F3_DTCANC = '' "
clQuery += "		THEN 	F3_CLIEFOR "
clQuery += "		ELSE '' "
clQuery += " END			AS F3_CLIEFOR, "

clQuery += " CASE	WHEN	F3_DTCANC = '' "
clQuery += "		THEN 	F3_LOJA "
clQuery += "		ELSE '' "
clQuery += " END			AS F3_LOJA, "

clQuery += " F1_NODIA, F2_NODIA, "
clQuery += " COALESCE(FE_CERTDET,'') FE_CERTDET, "
clQuery += " COALESCE(FE_TIPO,'') FE_TIPO, "
clQuery += " COALESCE(FE_EMISSAO,'') FE_EMISSAO, "
clQuery += " F1_TXMOEDA, F2_TXMOEDA, "

clQuery += " CASE	WHEN	F3_DTCANC = ''  AND F3_ESPECIE NOT IN ('NCP','NDI') AND F1_TPDOC<> '25' AND F4_CREDIGV='3' "
clQuery += "		THEN 	SUM(F3_VALCONT) "
clQuery += " 		WHEN	F3_DTCANC = ''  AND ( F3_ESPECIE IN ('NCP','NDI') OR F1_TPDOC = '25' ) AND F4_CREDIGV='3' "
clQuery += "		THEN 	SUM(-1*F3_VALCONT) "
clQuery += " ELSE 0 "
clQuery += " END  AS OUTROS, F3_ENTRADA "
clQuery += " FROM	" + RetSqlName("SF3") + " SF3 "

clQuery += " LEFT JOIN  " +  RetSqlName("SA2") + " SA2 "
clQuery += " ON	A2_COD = F3_CLIEFOR "
clQuery += " AND A2_LOJA = F3_LOJA "
clQuery += " AND A2_FILIAL = '" + XFILIAL("SA2") + "'"

clQuery += " AND SA2.D_E_L_E_T_ <> '*'"

clQuery += " LEFT JOIN " + RetSqlName("SF1") + " SF1 "
clQuery += " ON F1_DOC      = F3_NFISCAL "
clQuery += " AND F1_SERIE   = F3_SERIE "
clQuery += " AND F1_ESPECIE = F3_ESPECIE "
clQuery += " AND F1_FORNECE = F3_CLIEFOR "
clQuery += " AND F1_LOJA    = F3_LOJA "
clQuery += " AND F1_FILIAL  = F3_FILIAL "

clQuery += " AND SF1.D_E_L_E_T_ <> '*'"

clQuery += " LEFT JOIN " + RetSqlName("SF2") + " SF2 "
clQuery += " ON F2_DOC        = F3_NFISCAL "
clQuery += " AND F2_SERIE     = F3_SERIE "
clQuery += " AND F2_ESPECIE   = F3_ESPECIE "
clQuery += " AND F2_CLIENTE   = F3_CLIEFOR "
clQuery += " AND F2_LOJA      = F3_LOJA "
clQuery += " AND F2_FILIAL    = F3_FILIAL "

clQuery += " AND SF2.D_E_L_E_T_ <> '*'"

clQuery += " LEFT JOIN " + RetSqlName("SE2") + " SE2 "
clQuery += " ON E2_NUM  = F3_NFISCAL "
IF EMPTY(XFILIAL("SE2"))
	clQuery += " AND E2_FILIAL = '" + XFILIAL("SE2") + "' "
ELSE
	clQuery += " AND E2_FILORIG = F3_FILIAL "
ENDIF
clQuery += " AND E2_PREFIXO = F3_SERIE "
clQuery += " AND E2_FORNECE = F3_CLIEFOR "
clQuery += " AND E2_LOJA = F3_LOJA "
clQuery += " AND E2_TIPO = F3_ESPECIE "

clQuery += " AND SE2.D_E_L_E_T_ <> '*'"

clQuery += " AND E2_PARCELA IN ( '','"+GetMv("MV_1DUP")+"')"
clQuery += " LEFT JOIN "  + RetSqlName("SF4") + " SF4 "
clQuery += " ON	F4_CODIGO = F3_TES "
clQuery += " AND F4_FILIAL = '" + XFILIAL("SF4") + "' "

clQuery += " AND SF4.D_E_L_E_T_ <> '*'"

clQuery += " LEFT JOIN " + RetSqlName("SFE") + " SFE "
clQuery += " ON FE_NFISCAL  = F3_NFISCAL "
clQuery += " AND FE_FORNECE = F3_CLIEFOR "
clQuery += " AND FE_LOJA = F3_LOJA "
clQuery += " AND FE_SERIE = F3_SERIE "

If Empty(XFILIAL("SFE"))
	clQuery += " AND FE_FILIAL = '" + XFILIAL("SFE") + "' "
Else
	clQuery += " AND FE_FILIAL = F3_FILIAL "
EndIf

clQuery += " AND FE_TIPO = 'D'  "

clQuery += " AND	SFE.D_E_L_E_T_ <> '*'"

cMesInic := SUBSTR(DtoS(MV_PAR01),5,2) //Mes Inicial Selecionado
cAnoInic := SUBSTR(DtoS(MV_PAR01),3,2) // Ano Incial Selecionado
cMesFin := SUBSTR(DtoS(MV_PAR02),5,2) //Mes Final Selecionado
cAnoFin := SUBSTR(DtoS(MV_PAR02),3,2) // Ano Final Selecionado

If Alltrim(cMesInic) == "1"
	cMesInic := "12"
	cAnoInic := Str(Val(cAno)-1)
Else
	cMesInic :=	Str(Val(cMesInic)-1)
EndIf

dDUtilInic := RetDiaUtil(cMesInic, cAnoInic) //  Retorna o Quinto dia util do mes Inicial selecionado
dDUtilFin := RetDiaUtil(cMesFin, cAnoFin) //  Retorna o Quinto dia util do proximo mes Final selecionado

clQuery += " WHERE "
If MV_PAR08==1
   clQuery += " A2_DOMICIL = '1' "
Else
	clQuery += " A2_DOMICIL = '2'  "
EndIf
clQuery += " AND (F3_TIPOMOV = 'C' "
If SF3->(ColumnPos("F3_TPDOC")) > 0

	clQuery += " AND (F3_TPDOC<>'14' AND F3_VALIMP5=0 AND (F3_ENTRADA BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"'  OR FE_EMISSAO >= '"+Dtos(mv_par01)+"' AND FE_EMISSAO <='"+Dtos(mv_par02)+"' ))" + CRLF
	clQuery += "	     OR (F3_TIPOMOV = 'C' AND F3_TPDOC<>'14' AND  F3_VALIMP5>0  AND (F3_ENTRADA BETWEEN '"+Dtos(mv_par01-120)+"' AND '"+Dtos(dDUtilFin)+"'  OR FE_EMISSAO >= '"+Dtos(mv_par01)+"' AND FE_EMISSAO <='"+Dtos(dDUtilFin)+"' ))" + CRLF
	clQuery += " 	     OR (F3_TIPOMOV = 'C'  AND F3_TPDOC = '14' AND E2_VENCTO BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' AND E2_BAIXA=' ' AND F3_ENTRADA BETWEEN '"+Dtos(mv_par01-30)+"' AND '"+Dtos(mv_par02)+"' )" + CRLF
	clQuery += "	     OR (F3_TIPOMOV = 'C'  AND F3_TPDOC = '14' AND F3_ENTRADA BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' AND E2_BAIXA=' ')" + CRLF
	clQuery += "	     OR (F3_TIPOMOV = 'C'  AND F3_TPDOC = '14' AND F3_ENTRADA BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' AND E2_BAIXA<>' ' ))" + CRLF 
	clQuery += " 	     AND ( (F3_ENTRADA BETWEEN '"+Dtos(mv_par01-365)+"' AND '"+Dtos(mv_par02)+"' AND F3_TPDOC = '14' ) OR (FE_EMISSAO > '"+Dtos(dDUtilInic)+"' AND FE_EMISSAO <='"+Dtos(dDUtilFin)+"' )" + CRLF  //--ORIGINAL
	clQuery += " 	     OR  (F3_ENTRADA BETWEEN '"+Dtos(mv_par01-120)+"' AND '"+Dtos(mv_par02)+"' ) OR (FE_EMISSAO >= '"+Dtos(mv_par01)+"' AND FE_EMISSAO <='"+Dtos(mv_par02)+"' ))" + CRLF
	clQuery += " AND ( F3_FILIAL = '"+Space(GetSx3Cache("F3_FILIAL","X3_TAMANHO"))+" ' "
	
Else

	clQuery += " AND (F1_TPDOC<>'14' AND F3_VALIMP5=0 AND (F3_ENTRADA BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"'  OR FE_EMISSAO >= '"+Dtos(mv_par01)+"' AND FE_EMISSAO <='"+Dtos(mv_par02)+"' ))" 
	clQuery += "	     OR (F3_TIPOMOV = 'C' AND  F3_VALIMP5>0  AND (F3_ENTRADA BETWEEN '"+Dtos(mv_par01-120)+"' AND '"+Dtos(mv_par02)+"'  OR FE_EMISSAO >= '"+Dtos(mv_par01)+"' AND FE_EMISSAO <='"+Dtos(mv_par02)+"' ))"
	clQuery += " 	     OR (F3_TIPOMOV = 'C' AND E2_VENCTO BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' AND E2_BAIXA=' ' AND F3_ENTRADA BETWEEN '"+Dtos(mv_par01-30)+"' AND '"+Dtos(mv_par02)+"' )" 
	clQuery += " 	     OR (F3_TIPOMOV = 'C' AND E2_BAIXA BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' AND E2_BAIXA<=E2_VENCTO )"
	clQuery += " 	     OR (F3_TIPOMOV = 'C' AND E2_BAIXA BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' AND E2_BAIXA>E2_VENCTO )"
	clQuery += "		 OR (F3_TIPOMOV = 'C' AND E2_BAIXA BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' AND F3_ENTRADA BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' AND E2_VENCTO BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' )"
	clQuery += "	     OR (F3_TIPOMOV = 'C' AND F3_ENTRADA BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' AND E2_BAIXA=' ')"
	clQuery += "	     OR (F3_TIPOMOV = 'C' AND F3_ENTRADA BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' AND E2_BAIXA>'"+Dtos(mv_par02)+"' ))" 
	clQuery += " 	     AND ( (F3_ENTRADA BETWEEN '"+Dtos(mv_par01-365)+"' AND '"+Dtos(mv_par02)+"' ) OR (FE_EMISSAO > '"+Dtos(dDUtilInic)+"' AND FE_EMISSAO <='"+Dtos(dDUtilFin)+"' )" //--ORIGINAL
	clQuery += " 	     OR  (F3_ENTRADA BETWEEN '"+Dtos(mv_par01-120)+"' AND '"+Dtos(mv_par02)+"' ) OR (FE_EMISSAO >= '"+Dtos(mv_par01)+"' AND FE_EMISSAO <='"+Dtos(mv_par02)+"' ))"
	clQuery += " AND ( F3_FILIAL = '"+Space(GetSx3Cache("F3_FILIAL","X3_TAMANHO"))+" ' "

EndIf

For nI:=1 To Len(aFiliais)
	If aFiliais[nI,1]
		clQuery += " OR F3_FILIAL =	'"+aFiliais[nI,2]+ "' "
	EndIf
Next nI
clQuery += " )"

clQuery += " AND SF3.D_E_L_E_T_ <> '*' "

clQuery += " GROUP BY	F3_ENTRADA,  "
clQuery += " 			F3_FILIAL, "
clQuery += " 			F3_EMISSAO, "
clQuery += " 			F3_SERIE, "
If lSerie2
	clQuery += " F3_SERIE2,"
EndIf
clQuery += " 			F3_NFISCAL, "
clQuery += " 			A2_TIPDOC, "
clQuery += "			A2_TIPO, "
clQuery += " 			A2_PFISICA, "
clQuery += " 			A2_CGC, "
clQuery += " 			A2_NOME, "
clQuery += " 			E2_VENCTO, "
clQuery += " 			E2_BAIXA, "
clQuery += " 			E2_PARCELA, "
clQuery += " 			F3_ESPECIE, "
clQuery += " 			F3_DTCANC, "
clQuery += "			F3_CLIEFOR, "
clQuery += "			F3_LOJA, "
clQuery += " 			F4_CREDIGV, "
clQuery += " 			F1_NODIA, "
clQuery += " 			F2_NODIA, "
clQuery += "			F1_TPDOC, "
clQuery += "			F2_TPDOC, "
clQuery += " 			FE_CERTDET, "
clQuery += " 			FE_TIPO, "
clQuery += " 			FE_EMISSAO, "
clQuery += "			F1_TXMOEDA, "
clQuery += "			F2_TXMOEDA, "
clQuery += "         F4_CALCIGV, "
clQuery += "         A2_DOMICIL, " 
clQuery += "         A2_CODNAC,  " 
clQuery += "         A2_CONVEN,  " 
If lRenta
	clQuery += "         F1_TPRENTA, " 
	clQuery += "         F2_TPRENTA,  " 
EndIf
If SF1->(ColumnPos("F1_TIPOPE")) > 0
	clQuery += "         F1_TIPOPE,  "
EndIf
clQuery += "         F1_MOEDA,   " 
clQuery += "         F2_MOEDA" 

If lMeslib
	clQuery += ",FE_MESLIB"
EndIf

clQuery += " ) TMP "
clQuery += " WHERE ((TMP.F1_TPDOC <> '14' AND TMP.F3_ENTRADA BETWEEN '" + DtoS(MV_PAR01-120) + "' AND '" + DtoS(MV_PAR02) + "' ) "
clQuery += "    OR (TMP.F1_TPDOC = '14'  AND TMP.E2_VENCTO  BETWEEN	'" + DtoS(MV_PAR01-30) + "' AND '" + DtoS(MV_PAR02)+"' AND TMP.E2_BAIXA=' ' )"
clQuery += "    OR (TMP.F1_TPDOC = '14'  AND TMP.E2_BAIXA   BETWEEN	'" + DtoS(MV_PAR01-30) + "' AND '" + DtoS(MV_PAR02) + "' ) "
clQuery += "    OR (TMP.F1_TPDOC = '14'  AND TMP.F3_ENTRADA BETWEEN	'" + DtoS(MV_PAR01-30) + "' AND '" + DtoS(MV_PAR02)+"' AND TMP.E2_BAIXA=' ')"
clQuery += "    OR (TMP.F1_TPDOC = '14'  AND TMP.F3_ENTRADA BETWEEN	'" + Dtos(MV_PAR01-30) + "' AND '"+Dtos(MV_PAR02)+"' AND TMP.E2_BAIXA>'"+Dtos(MV_PAR02)+"')"
clQuery += "    OR (TMP.F2_TPDOC <> '14' AND TMP.F3_ENTRADA BETWEEN	'" + DtoS(MV_PAR01-30) + "' AND '" + DtoS(MV_PAR02) + "'  )"
clQuery += "    OR (TMP.F3_VALIMP5 > 0 AND TMP.FE_EMISSAO > '" + DtoS(dDUtilInic) + "' AND TMP.FE_EMISSAO <='" + DtoS(dDUtilFin) + "')"
clQuery += "    OR (TMP.F3_VALIMP5 > 0 AND TMP.FE_EMISSAO >= '"+Dtos(MV_PAR01)+"' AND TMP.FE_EMISSAO <='"+Dtos(MV_PAR02)+"'))"

clQuery += " GROUP BY F3_ENTRADA, "
clQuery += "         F3_FILIAL, "
clQuery += "         F3_EMISSAO, "
clQuery += " 			F3_SERIE, "
If lSerie2
	clQuery += " F3_SERIE2,"
EndIf
clQuery += " 			F3_NFISCAL, "
clQuery += " 			A2_TIPDOC, "
clQuery += "			A2_TIPO, "
clQuery += " 			A2_PFISICA, "
clQuery += " 			A2_CGC, "
clQuery += " 			A2_NOME, "
clQuery += " 			E2_VENCTO, "
clQuery += " 			E2_BAIXA, "
clQuery += " 			E2_PARCELA, "
clQuery += " 			F3_ESPECIE, "
clQuery += "			F3_CLIEFOR, "
clQuery += "			F3_LOJA, "
clQuery += " 			F1_NODIA, "
clQuery += " 			F2_NODIA, "
clQuery += "			F1_TPDOC, "
clQuery += "			F2_TPDOC, "
clQuery += " 			FE_CERTDET, "
clQuery += " 			FE_TIPO, "
clQuery += " 			FE_EMISSAO, "
clQuery += "			F1_TXMOEDA, "
clQuery += "			F2_TXMOEDA, "
clQuery += "			A2_DOMICIL, " 
clQuery += "         A2_CODNAC,  " 
clQuery += "         A2_CONVEN,  " 
If lRenta
	clQuery += "         F1_TPRENTA, " 
	clQuery += "         F2_TPRENTA,  " 
EndIf
clQuery += "         F1_MOEDA,   " 
clQuery += "         F2_MOEDA   "

If SF1->(ColumnPos("F1_TIPOPE")) > 0
	clQuery += ", F1_TIPOPE   "
EndIf
If lMeslib
	clQuery += ",FE_MESLIB"
EndIf

clQuery += " ORDER BY	F3_ENTRADA, F3_CLIEFOR, F3_LOJA, F3_NFISCAL, F3_SERIE "

clQuery	:=	ChangeQuery(clQuery)

TcQuery clQuery New Alias "TRB3"

TcSetField("TRB3","F3_EMISSAO","D")
TcSetField("TRB3","F3_ENTRADA","D")
TcSetField("TRB3","E2_VENCTO","D")
TcSetField("TRB3","E2_BAIXA","D")
TcSetField("TRB3","FE_EMISSAO","D")
TcSetField("TRB3","BASECRD1","N",GetSx3Cache("F3_BASIMP1","X3_TAMANHO"),GetSx3Cache("F3_BASIMP1","X3_DECIMAL"))
TcSetField("TRB3","BASECRD2","N",GetSx3Cache("F3_BASIMP1","X3_TAMANHO"),GetSx3Cache("F3_BASIMP1","X3_DECIMAL"))
TcSetField("TRB3","BASECRD3","N",GetSx3Cache("F3_BASIMP1","X3_TAMANHO"),GetSx3Cache("F3_BASIMP1","X3_DECIMAL"))
TcSetField("TRB3","VALORCRD1","N",GetSx3Cache("F3_VALIMP1","X3_TAMANHO"),GetSx3Cache("F3_VALIMP1","X3_DECIMAL"))
TcSetField("TRB3","VALORCRD2","N",GetSx3Cache("F3_VALIMP1","X3_TAMANHO"),GetSx3Cache("F3_VALIMP1","X3_DECIMAL"))
TcSetField("TRB3","VALORCRD3","N",GetSx3Cache("F3_VALIMP1","X3_TAMANHO"),GetSx3Cache("F3_VALIMP1","X3_DECIMAL"))
TcSetField("TRB3","F3_VALIMP5","N",GetSx3Cache("F3_BASIMP1","X3_TAMANHO"),GetSx3Cache("F3_VALIMP5","X3_DECIMAL"))
TcSetField("TRB3","F3_EXENTAS","N",GetSx3Cache("F3_EXENTAS","X3_TAMANHO"),GetSx3Cache("F3_EXENTAS","X3_DECIMAL"))
TcSetField("TRB3","F3_VALCONT","N",GetSx3Cache("F3_VALCONT","X3_TAMANHO"),GetSx3Cache("F3_VALCONT","X3_DECIMAL"))
TcSetField("TRB3","F1_TXMOEDA","N",GetSx3Cache("F1_TXMOEDA","X3_TAMANHO"),GetSx3Cache("F1_TXMOEDA","X3_DECIMAL"))
TCSetField("TRB3","F3_VALICB","N",14,2)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq   ³ Autor ³ Ivan Haponczuk      ³ Data ³ 15.03.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Gera o arquivo magnético do livro de compras.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir - Diretorio de criacao do arquivo.                    ³±±
±±³            ³ cArq - Nome do arquivo com extensao do arquivo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Peru - Livro de compra - Arquivo Magnetico          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerArq(cDir)

Local nHdl		:= 0
Local cLin		:= ""
Local cAux		:= ""
Local cSep		:= "|"
Local lAdu		:= .F.
Local clDoc		:= ""
Local clSerie	:= ""
Local clTpDoc	:= ""
Local dlEmis	:= CTOD("  /  /  ")
Local cArq		:= ""
Local nCont		:= 0
Local nInd		:= 0
Local dFecha	:= CTOD("  /  /  ")
Local dTraFecha	:= CTOD("  /  /  ")
Local cMV_1DUP	:= padr(SuperGetMV("MV_1DUP",,"1"),GetSx3Cache("E5_PARCELA","X3_TAMANHO"))
Local cFilSE2	:= xFilial("SE2")
Local cFilSF4	:= xFilial("SF4")
Local cFilSA2	:= xFilial("SA2")
Local lGenero	:= .f.
Local ManBD     := TCGetDb()

cArq += "LE"                            // Fixo  'LE'
cArq +=  AllTrim(SM0->M0_CGC)           // Ruc
cArq +=  AllTrim(Str(Year(MV_PAR02)))   // Ano
cArq +=  AllTrim(Strzero(Month(MV_PAR02),2))  // Mes
cArq +=  "00"                            // Fixo '00'
cArq += "080100"                         // Fixo '080100'
cArq += "00"                             // Fixo '00'
cArq += "1"
TRB4->(dbGoTop())
dbSelectArea("TRB4")
If TRB4->(!EOF())
	cArq += "1"
Else
	cArq += "0"
EndIf
cArq += "1"
cArq += "1"
cArq += ".TXT" // Extensao

FOR nCont:=LEN(ALLTRIM(cDir)) TO 1 STEP -1
   IF SUBSTR(cDir,nCont,1)=='\' 
      cDir:=Substr(cDir,1,nCont)
      EXIT
   ENDIF
NEXT 

nHdl := fCreate(cDir + cArq, 0, NIL, .F.)

If nHdl <= 0
	ApMsgStop(STR0069,"") //"Ocurrió un error al crear archivo"
Else
	dbSelectArea("TRB4")
	TRB4->(dbGoTop())
	Do While TRB4->(!EOF())
		If AllTrim(TRB4->F3_ESPECIE) $ "NCP|NDI"
			if TRB4->F3_ENTRADA < MV_PAR01 .Or. TRB4->F3_ENTRADA > MV_PAR02
				TRB4->( dbSkip() )
				loop
			endif
		endif
		If AllTrim(TRB4->F1_TPDOC) $ '14'
			If TRB4->F3_ENTRADA <= TRB4->E2_VENCTO  // ENTRADA MENOR QUE VENCIMENTO OU MENOR QUE BAIXA
				If TRB4->E2_BAIXA <= TRB4->E2_VENCTO  // BAJA MENOR QUE EL VENCIMIENTO
					If TRB4->E2_BAIXA >= MV_PAR01 .And. TRB4->E2_BAIXA <= MV_PAR02
					ElseIf TRB4->E2_VENCTO >= MV_PAR01 .And. TRB4->E2_VENCTO <= MV_PAR02 .And. empty(TRB4->E2_BAIXA)
					Else
						TRB4->(DbSkip())
						Loop													
					EndIf
				ElseIf TRB4->E2_BAIXA > TRB4->E2_VENCTO	    // BAJA MAYOR QUE EL VENCIMIENTO
					IF TRB4->E2_VENCTO >= MV_PAR01 .And. TRB4->E2_VENCTO <= MV_PAR02    
				    Else 
				    	TRB4->(DbSkip())
						Loop
					EndIf
				EndIf
			ElseIf TRB4->F3_ENTRADA >= TRB4->E2_VENCTO			// F3_ENTRADA MAYOR QUE QUE EL VENCIMIENTO Y EL PAGO
				If TRB4->E2_BAIXA <= TRB4->E2_VENCTO
					If TRB4->E2_VENCTO < MV_PAR01 .And. empty(TRB4->E2_BAIXA)	//=="  /  /    "
					ElseIf TRB4->E2_BAIXA < MV_PAR01 
					Else
						TRB4->(DbSkip())
						Loop
					EndIf 
				ElseIf TRB4->E2_BAIXA > TRB4->E2_VENCTO
				 	If TRB4->F3_ENTRADA >= MV_PAR01 .AND. TRB4->F3_ENTRADA<=MV_PAR02 
				 	Else
						TRB4->(DbSkip())
						Loop		
				 	EndIf   
				EndIF
			EndIF
		Endif
		
		lImprime := .F.
		If TRB4->F3_VALIMP5 >0 //Detraccion
					
			aRet := DetIGVFnPeru(TRB4->F3_CLIEFOR,TRB4->F3_LOJA,(MV_PAR01-30),(dDUtilFin),TRB4->F3_FILIAL,TRB4->F3_ENTRADA) // Preenche o array aRet de acordo com a funcao - RETROCEDE 30 DIAS PARA QUE TOME LA TX
			aretMes:= DetIGVFnPeru(TRB4->F3_CLIEFOR,TRB4->F3_LOJA,(MV_PAR01),(dDUtilFin),TRB4->F3_FILIAL,TRB4->F3_ENTRADA) // Preenche o array aRet de acordo com a funcao		
			
			nPos :=Ascan(aRet,{|x| x[1]+x[2]+x[5] == TRB4->F3_SERIE+TRB4->F3_NFISCAL+IIf(Empty(TRB4->E2_PARCELA),cMV_1DUP,TRB4->E2_PARCELA)})
			nPosMes:=Ascan(aretMes,{|x| x[1]+x[2]+x[5] == TRB4->F3_SERIE+TRB4->F3_NFISCAL+IIf(Empty(TRB4->E2_PARCELA),cMV_1DUP,TRB4->E2_PARCELA)})
			lImprime := .F.
			
			If nPos>0 .and. TRB4->F3_ENTRADA <= dDUtilFin .AND. alltrim(TRB4->F3_ESPECIE)='NF' .AND. TRB4->E2_BAIXA <= dDUtilFin   //ADICIONE QRY->F3_ESPECIE='NF' .AND. Ctod(QRY->E2_BAIXA) <= MV_PAR02
				cPrefixo := aRet[nPos,1]//Prefixo
				cNumero  := aRet[nPos,2]// Numero do Titulo
				cParcela := aRet[nPos,5]// Parcela
				cTipo := PADR("TX",GetSx3Cache("E2_TIPO","X3_TAMANHO"))  			 // Tipo que deve ser TX
				
				If cNumero == TRB4->F3_NFISCAL //Verifica se o titulo do aRet e o mesmo do TRB4
					cProve	:= TRB4->F3_CLIEFOR
					cTienda	:= TRB4->F3_LOJA
					DbselectArea("SE2")
					SE2->(DbGoTop())
					SE2->(dbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
					If SE2->(MsSeek(cFilSE2+cProve+cTienda+cPrefixo+cNumero+cParcela+cTipo)) //Procura o titulo TX no SE2, se encontrar deve imprimir
						dFecha:=SE2->E2_BAIXA
						//---------------------------TRATAMIENTO DE LA FECHA PARA MESES ANTERIORES AL ACTUAL------------------------------------------//
					    If SUBSTR(DTOS(mv_par01),5,2) $ "05|07|08|10|12"
							dTraFecha:=(mv_par01-30)
					    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "02|04|06|09|11"
							dTraFecha:=(mv_par01-31)
					    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "01"
							dTraFecha:=(mv_par01-31)
					    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "03"
							dTraFecha:=(mv_par01-28)
					    EndIf
					    //------------------------------------------------------------------------------------------------------------------------------//
					    	IF lMeslib .and. TRB4->FE_MESLIB <>  SUBSTR(DtoS(MV_PAR01),5,2)+ SUBSTR(DtoS(MV_PAR01),1,4)  
								If !empty(TRB4->FE_MESLIB) 
									lImprime := .F.
									TRB4->(DbSkip())
									Loop
								Endif
							EndIF
					    
						If dFecha>=(mv_par01) .AND. dFecha<=(dDUtilFin) .AND. TRB4->F3_ENTRADA>=(mv_par01) .AND. TRB4->F3_ENTRADA<=(dDUtilFin)
						   lImprime := .T.
						ElseIf dFecha>(dDUtilInic) .AND. dFecha<=(dDUtilFin) .AND. TRB4->F3_ENTRADA<(mv_par01) .AND. TRB4->F3_ENTRADA>=dTraFecha
				      	   lImprime := .T.
				      	ElseIf dFecha>=(mv_par01) .AND. dFecha<=(dDUtilFin) .AND. TRB4->F3_ENTRADA<dTraFecha
				      	   lImprime := .T.
				      	Else
				      	   lImprime := .F.
						EndIf
					EndIf
				EndIf
			ElseIf nPos>0 .and. TRB4->F3_ENTRADA <= MV_PAR02 .AND. TRB4->F3_ESPECIE='NF' .AND. TRB4->E2_BAIXA > MV_PAR02   //ADICIONE QRY->F3_ESPECIE='NF' .AND. Ctod(QRY->E2_BAIXA) > MV_PAR02
				cPrefixo := aRet[nPos,1]//Prefixo
				cNumero  := aRet[nPos,2]// Numero do Titulo
				cParcela := aRet[nPos,5]// Parcela
				cTipo := PADR("TX",GetSx3Cache("E2_TIPO","X3_TAMANHO"))		// Tipo que deve ser TX
				If cNumero == TRB4->F3_NFISCAL //Verifica se o titulo do aRet e o mesmo do TRB4
					cProve:= TRB4->F3_CLIEFOR 
    				cTienda:=TRB4->F3_LOJA
					DbselectArea("SE2")
					SE2->(DbGoTop())
					SE2->(dbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
					If SE2->(MsSeek(cFilSE2+cProve+cTienda+cPrefixo+cNumero+cParcela+cTipo)) //Procura o titulo TX no SE2, se encontrar deve imprimir
						dFecha:=SE2->E2_BAIXA
						//---------------------------TRATAMIENTO DE LA FECHA PARA MESES ANTERIORES AL ACTUAL------------------------------------------//
					    If SUBSTR(DTOS(mv_par01),5,2) $ "05|07|08|10|12"
							dTraFecha:=(mv_par01-30)
					    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "02|04|06|09|11"
							dTraFecha:=(mv_par01-31)
					    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "01"
							dTraFecha:=(mv_par01-31)
					    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "03"
							dTraFecha:=(mv_par01-28)
					    EndIf
					    //------------------------------------------------------------------------------------------------------------------------------//
						If dFecha>=(mv_par01) .AND. dFecha<=(dDUtilFin) .AND. TRB4->F3_ENTRADA>=(mv_par01) .AND. TRB4->F3_ENTRADA<=(mv_par02)
						   lImprime := .T.
						ElseIf dFecha>(dDUtilInic) .AND. dFecha<=(mv_par02) .AND. TRB4->F3_ENTRADA<(mv_par01) .AND. TRB4->F3_ENTRADA>=dTraFecha
				      	   lImprime := .T.
						ElseIf dFecha>=(mv_par01) .AND. dFecha<=(mv_par02) .AND. TRB4->F3_ENTRADA<dTraFecha
				      	   lImprime := .T.
						Else
				      	   lImprime := .F.
						EndIf
					EndIf
				EndIf
			EndIf
			
			If nPosMes>0 .and. TRB4->F3_ENTRADA >= MV_PAR01 .and. TRB4->F3_ENTRADA <= MV_PAR02 .AND. TRB4->E2_BAIXA <= MV_PAR02
				cPrefixo := aretMes[nPosMes,1]//Prefixo
				cNumero  := aretMes[nPosMes,2]// Numero do Titulo
				cParcela := aretMes[nPosMes,5]// Parcela
				cTipo := PADR("TX",GetSx3Cache("E2_TIPO","X3_TAMANHO"))			// Tipo que deve ser TX
				If cNumero == TRB4->F3_NFISCAL //Verifica se o titulo do aRet e o mesmo do TRB4
					cProve:= TRB4->F3_CLIEFOR 
    				cTienda:=TRB4->F3_LOJA
					DbselectArea("SE2")
					SE2->(DbGoTop())
					SE2->(dbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
					If SE2->(MsSeek(cFilSE2+cProve+cTienda+cPrefixo+cNumero+cParcela+cTipo)) //Procura o titulo TX no SE2, se encontrar deve imp
						dFecha:=SE2->E2_BAIXA 
						//---------------------------TRATAMIENTO DE LA FECHA PARA MESES ANTERIORES AL ACTUAL------------------------------------------//
					    If SUBSTR(DTOS(mv_par01),5,2) $ "05|07|08|10|12"
							dTraFecha:=(mv_par01-30)
					    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "02|04|06|09|11"
							dTraFecha:=(mv_par01-31)
					    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "01"
							dTraFecha:=(mv_par01-31)
					    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "03"
							dTraFecha:=(mv_par01-28)
					    EndIf
					    //------------------------------------------------------------------------------------------------------------------------------//
						If dFecha>=(mv_par01) .AND. dFecha<=(dDUtilFin) .AND. TRB4->F3_ENTRADA>=(mv_par01) .AND. TRB4->F3_ENTRADA<=(mv_par02)
						   lImprime := .T.
						ElseIf dFecha>(dDUtilInic) .AND. dFecha<=(mv_par02) .AND. TRB4->F3_ENTRADA<(mv_par01) .AND. TRB4->F3_ENTRADA>=dTraFecha
				      	   lImprime := .T.
						ElseIf dFecha>=(mv_par01) .AND. dFecha<=(mv_par02) .AND. TRB4->F3_ENTRADA<dTraFecha
				      	   lImprime := .T.
						Else
				      	   lImprime := .F.
						EndIf
					EndIf
				EndIf
			ElseIf nPosMes>0 .and. TRB4->F3_ENTRADA >= MV_PAR01 .and. TRB4->F3_ENTRADA <= MV_PAR02 .AND. TRB4->E2_BAIXA > MV_PAR02
				cPrefixo := aretMes[nPosMes,1]//Prefixo
				cNumero  := aretMes[nPosMes,2]// Numero do Titulo
				cParcela := aretMes[nPosMes,5]// Parcela
				cTipo := PADR("TX",GetSx3Cache("E2_TIPO","X3_TAMANHO"))		// Tipo que deve ser TX
				If cNumero == TRB4->F3_NFISCAL //Verifica se o titulo do aRet e o mesmo do TRB4
					cProve:= TRB4->F3_CLIEFOR 
    				cTienda:=TRB4->F3_LOJA
					DbselectArea("SE2")
					SE2->(DbGoTop())
					SE2->(dbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
					If SE2->(MsSeek(cFilSE2+cProve+cTienda+cPrefixo+cNumero+cParcela+cTipo)) //Procura o titulo TX no SE2, se encontrar deve imprimir   					
						dFecha:=SE2->E2_BAIXA
						//---------------------------TRATAMIENTO DE LA FECHA PARA MESES ANTERIORES AL ACTUAL------------------------------------------//
					    If SUBSTR(DTOS(mv_par01),5,2) $ "05|07|08|10|12"
							dTraFecha:=(mv_par01-30)
					    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "02|04|06|09|11"
							dTraFecha:=(mv_par01-31)
					    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "01"
							dTraFecha:=(mv_par01-31)
					    ElseIf SUBSTR(DTOS(mv_par01),5,2) $ "03"
							dTraFecha:=(mv_par01-28)
					    EndIf
					    //------------------------------------------------------------------------------------------------------------------------------//
						If dFecha>=(mv_par01) .AND. dFecha<=(dDUtilFin) .AND. TRB4->F3_ENTRADA>=(mv_par01) .AND. TRB4->F3_ENTRADA<=(mv_par02)
						   lImprime := .T.
						ElseIf dFecha>(dDUtilInic) .AND. dFecha<=(mv_par02) .AND. TRB4->F3_ENTRADA<(mv_par01) .AND. TRB4->F3_ENTRADA>=dTraFecha
				      	   lImprime := .T.
						ElseIf dFecha>=(mv_par01) .AND. dFecha<=(mv_par02) .AND. TRB4->F3_ENTRADA<dTraFecha
				      	   lImprime := .T.
						Else
				      	   lImprime := .F.
						EndIf
					EndIf
				EndIf 
			EndIf
			
			If !lImprime // Se nao encontrar nao imprime
				TRB4->(DbSkip())
				Loop
			EndIf
		EndIf  //Detraccion
		If AllTrim(TRB4->F1_TPDOC) <> '14' .And. TRB4->F3_VALIMP5==0
			If TRB4->F3_ENTRADA < MV_PAR01
				TRB4->(DbSkip())
				Loop
			endif
		endif
		cLin := ""
		
		//01 - Periodo
		cLin += SubStr(DTOS(MV_PAR02),1,6)+"00"
		cLin += cSep
				
		//02 - Numero correlativo del registro
		If AllTrim(TRB4->F3_ESPECIE) $ "NCP|NDI"
			cLin += AllTrim(TRB4->F2_NODIA)
		Else
			if empty(AllTrim(TRB4->F1_NODIA))
				SF1->( DbSetOrder(1) ) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
				SF1->( MsSeek(TRB4->F3_FILIAL+TRB4->F3_NFISCAL+TRB4->F3_SERIE+TRB4->F3_CLIEFOR+TRB4->F3_LOJA) )
				cLin += getSegofi(SF1->F1_NODIA,SF1->F1_MOEDA, ManBD)
			else
				cLin += AllTrim(TRB4->F1_NODIA)
			endif
		EndIf
		cLin += cSep
		
        //03- Numero correlativo del registro
        If AllTrim(TRB4->F3_ESPECIE) $ "NCP|NDI|"
        	SF2->( DbSetOrder(1) ) //F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
        	If SF2->( MsSeek(TRB4->F3_FILIAL+TRB4->F3_NFISCAL+TRB4->F3_SERIE+TRB4->F3_CLIEFOR+TRB4->F3_LOJA) )
        		cLin += "M"+getLinCT2(AllTrim(SF2->F2_NODIA),SF2->F2_VALBRUT,SF2->F2_MOEDA,SF2->F2_VALFAT,.F.,TRB4->F3_FILIAL)
        	Else
        		cLin += "M"+StrZero(++nInd,9)
        	Endif
        Else
        	SF1->( DbSetOrder(1) ) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
        	If SF1->( MsSeek(TRB4->F3_FILIAL+TRB4->F3_NFISCAL+TRB4->F3_SERIE+TRB4->F3_CLIEFOR+TRB4->F3_LOJA) )
        		If AllTrim(TRB4->F1_TPDOC) $'46'
        			cLin += "M"+getLinCT2(AllTrim(SF1->F1_NODIA),SF1->F1_VALIMP1,SF1->F1_MOEDA,SF1->F1_VALIMP1,.F.,TRB4->F3_FILIAL)
        		ElseIf AllTrim(TRB4->F1_TPDOC) $'50'
        			cLin += "M"+getLinCT2(AllTrim(SF1->F1_NODIA),(SF1->F1_VALBRUT-SF1->F1_VALIMP5),SF1->F1_MOEDA,(SF1->F1_VALBRUT-SF1->F1_VALIMP5),.T.,TRB4->F3_FILIAL)
        		Else
        			cLin += "M"+getLinCT2(AllTrim(SF1->F1_NODIA),(SF1->F1_VALBRUT-SF1->F1_VALIMP5),SF1->F1_MOEDA,(SF1->F1_VALBRUT-SF1->F1_VALIMP5),.F.,TRB4->F3_FILIAL)
        		EndIf
        	Else
        		cLin += "M"+StrZero(++nInd,9)
   			EndIf
   		EndIf
   		cLin += cSep
		
		//04- Fecha de emision
		cLin += SubStr(DTOC(TRB4->F3_EMISSAO),1,6)+SubStr(DTOS(TRB4->F3_EMISSAO),1,4)
		cLin += cSep
				
		//05- Fecha de vencimento o fecha de pago 
		IF AllTrim(TRB4->F1_TPDOC) $'14' 
			dFecha := ctod(" / / ")
			If !Empty(TRB4->E2_BAIXA)
				IF TRB4->E2_BAIXA <= TRB4->E2_VENCTO	// BAJA MENOR QUE EL VENCIMIENTO
					If TRB4->E2_BAIXA >= MV_PAR01 .And. TRB4->E2_BAIXA <= MV_PAR02
						dFecha := TRB4->E2_BAIXA
					EndIf
				ElseIf TRB4->E2_BAIXA > TRB4->E2_VENCTO	    // BAJA MAYOR QUE EL VENCIMIENTO
					If TRB4->E2_VENCTO >= MV_PAR01 .And. TRB4->E2_VENCTO <= MV_PAR02
						dFecha := TRB4->E2_VENCTO
					EndIf
				EndIf
			Else
				If TRB4->E2_VENCTO >= MV_PAR01 .And. TRB4->E2_VENCTO <= MV_PAR02
					dFecha := TRB4->E2_VENCTO
				EndIf
			EndIf
			
			If Empty(dFecha)
				cLin += SubStr(DTOC(TRB4->F3_ENTRADA),1,6)+SubStr(DTOS(TRB4->F3_ENTRADA),1,4)
			Else
				cLin += SubStr(DTOC(dFecha),1,6)+SubStr(DTOS(dFecha),1,4)
			EndIf
		ElseIf AllTrim(TRB4->F1_TPDOC) $'46' //retenciones de IGV No Domiciliados
			cLin += SubStr(DTOC(TRB4->F3_ENTRADA),1,6)+SubStr(DTOS(TRB4->F3_ENTRADA),1,4)
		Else
			//--[ejemplo]---------------------------------------//
			// periodo informado	= 05						//
			// mes siguiente		= 06						//
			// condicion			= menor o igual del mes 06	//
			//--------------------------------------------------//
			nMesActual	:= month(MV_PAR01)
			nAnoActual	:= year(MV_PAR01)
			nProxMes	:= nMesActual+1
			If nProxMes>12
				nProxMes:=1
				nAnoActual++
			EndIf
			nUltDia:=lastday(ctod("01/"+strzero(nProxMes,2)+"/"+strzero(nAnoActual,4)),2)
			If TRB4->E2_VENCTO<=nUltDia	.and. !empty(TRB4->E2_VENCTO)		// menor o igual al mes siguiente del periodo informado
				cLin += SubStr(DTOC(TRB4->E2_VENCTO),1,6)+SubStr(DTOS(TRB4->E2_VENCTO),1,4)
			Else
				cLin += "01/01/0001"
			EndIf
		EndIf
		cLin += cSep
		
		cTipo:="00"
		//06- Tipo de comprobante validar com a tabela 10
		If AllTrim(TRB4->F3_ESPECIE) $ "NCP|NDI"
			cTipo:= AllTrim(TRB4->F2_TPDOC)
		Else
			cTipo:= AllTrim(TRB4->F1_TPDOC)
		EndIf
		cLin+= Iif(!Empty(cTipo),cTipo,"00")
		cLin += cSep

		// ----------------------------------------------------------------------------------- //
		// Adicionado por SISTHEL para impresion de la serie 3 ( campo customizado )		   //
		// ----------------------------------------------------------------------------------- //
		lSerie3 := .t. 
		If AllTrim(TRB4->F3_ESPECIE) $ "NCP|NDI"

			If lSerY
				SF2->( DbSetOrder(1) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
				If SF2->( MsSeek(TRB4->F3_FILIAL+TRB4->F3_NFISCAL+TRB4->F3_SERIE+TRB4->F3_CLIEFOR+TRB4->F3_LOJA) )
					if SF2->(ColumnPos("F2_YSERIE"))>0
					lSerie3 := Empty(SF2->F2_YSERIE)
					endif
				EndIf
			EndIf
			//07- Serie del comprobante(Não obrigatório)		
			If !lSerie3
				If lSerY
					if SF2->(ColumnPos("F2_YSERIE"))>0
					cAux := Alltrim(SF2->F2_YSERIE)
					endif
				EndIf
			Else
				cSerie:= TRB4->F3_SERIE
				If AllTrim(TRB4->F2_TPDOC) $ ('01/03/04/07/08') .AND. lSerie2 .AND. !Empty(TRB4->F3_SERIE2)
					cSerie:=TRB4->F3_SERIE2
				EndIf
				
				lRetnSer := .T.
				If ExistBlock("FISR12AS")
					lRetnSer:=ExecBlock("FISR12AS",.F.,.F.,{cSerie,TRB4->F1_TPDOC})
				Endif
				
				cAux := (Alltrim(Iif(lRetnSer,RetNewSer(cserie),cserie)))	
				    				    				                                                           	
				If Len(Alltrim(cAux))==3
					cAux := "0"+cAux
				EndIf
			EndIf
		Else
			If lSerY
				SF1->( DbSetOrder(1) ) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
				If SF1->( MsSeek(TRB4->F3_FILIAL+TRB4->F3_NFISCAL+TRB4->F3_SERIE+TRB4->F3_CLIEFOR+TRB4->F3_LOJA) )
					lSerie3 := Empty(SF1->F1_YSERIE)
				EndIf
			EndIf
			
			//07- Serie del comprobante(Não obrigatório)
			If !lSerie3
				If lSerY
					cAux := Alltrim(SF1->F1_YSERIE)
				EndIf
			Else
				cSerie:= TRB4->F3_SERIE
				IF lSerie2 .AND. !Empty(TRB4->F3_SERIE2)
					cSerie:=TRB4->F3_SERIE2
				EndIf
				
				lRetnSer := .T.
				If ExistBlock("FISR12AS")
					lRetnSer:=ExecBlock("FISR12AS",.F.,.F.,{cSerie,TRB4->F1_TPDOC})
				Endif
				
				cAux := (Alltrim(Iif(lRetnSer,RetNewSer(cserie),cserie)))	
				    				    				                                                           	
				If Len(Alltrim(cAux))==3
					cAux := "0"+cAux
				EndIf
			EndIf
			
		EndIf
		
		If Empty(cAux)
		   cAux:="0000"
		ElseIf AllTrim(TRB4->F1_TPDOC) $'50|52'   
		   cAux:=Right(cAux,3)
		ElseIf AllTrim(TRB4->F1_TPDOC) $ ('05')
			 cAux := "3"
		Else   
		   cAux:=IIF(Len(cAux)<4,Strzero(0,4-Len(cAux)),'')+cAux
		EndIf 
		
		//07- Serie del comprobante
		cLin += If(Empty(cAux),"0000",cAux)
		cLin += cSep
				
		//08- Ano de emision de la DUA o DSI(Não obrigatório)
        IF AllTrim(TRB4->F1_TPDOC) $'50|52'   
           cLin+=SubStr(DTOS(TRB4->F3_EMISSAO),1,4)
        Else 
       		 cLin += "" 
         EndIf
        cLin += cSep
		
		//09- Numero del comprobante
		IF AllTrim(TRB4->F1_TPDOC) $'14|05'  
	           cLin += Right(AllTrim(TRB4->F3_NFISCAL),20)
		Else
	           cLin += Right(AllTrim(TRB4->F3_NFISCAL),8)
		EndIf

		cLin += cSep
				
		//10 Numero final(Não obrigatório)
		cLin += ""
		cLin += cSep
				
		//11- Documento del provedor(Não obrigatório)
		If !Empty(TRB4->A2_TIPDOC)
			cLin += strzero(Val(TRB4->A2_TIPDOC),1)
		Else
			cLin += "0"
		EndIf
		cLin += cSep
				
		//12- Numero de RUC del provedor(Não obrigatório)
		If !Empty(TRB4->A2_CGC)
			cLin += AllTrim(TRB4->A2_CGC)
		ElseIf !Empty(TRB4->A2_PFISICA)
			cLin += AllTrim(TRB4->A2_PFISICA)
		Else	
			cLin += "0"
		EndIf
		cLin += cSep
				
		//13- Razon social del provedor(Não obrigatório)
		cLin += Subs(AllTrim(TRB4->A2_NOME),1,100)
		cLin += cSep
				
		//14- Base Imponible(Não obrigatório)
		cLin += AllTrim(StrTran(Transform(TRB4->BASECRD1,"@E 999999999.99"),",","."))
		cLin += cSep
			
		//15- Monto del imposto general a las ventas(Não obrigatório)
		cLin += AllTrim(StrTran(Transform(TRB4->VALORCRD1,"@E 999999999.99"),",","."))
		cLin += cSep
				
		//16- Base Imponible de las adquisiciones credito(Não obrigatório)
		cLin += AllTrim(StrTran(Transform(TRB4->BASECRD3,"@E 999999999.99"),",","."))
		cLin += cSep
				
		//17- Monto del imposto general a las ventas(Não obrigatório)
		cLin += AllTrim(StrTran(Transform(TRB4->VALORCRD3,"@E 999999999.99"),",","."))
		cLin += cSep
				
		//18- Base imponible de las adquisiciones sin credito(Não obrigatório)
		cLin += AllTrim(StrTran(Transform(TRB4->BASECRD2,"@E 999999999.99"),",","."))
		cLin += cSep
				
		//19- Monto del imposto general a las ventas(Não obrigatório)
		cLin += AllTrim(StrTran(Transform(TRB4->VALORCRD2,"@E 999999999.99"),",","."))
		cLin += cSep
		
		//20 Valor de las adquisiciones no gravadas(Não obrigatório)
		cLin += AllTrim(StrTran(Transform(TRB4->F3_EXENTAS,"@E 999999999.99"),",","."))
		cLin += cSep
				
		//21- Monto del impuesto selectivo al consumo(Não obrigatório)
		cLin += AllTrim(StrTran(Transform(TRB4->F3_VALIMP2,"@E 999999999.99"),",","."))
		cLin += cSep

		If nPLEPeru > 5181
			//22- Impuesto al consumo de bolsas de plástico
			cLin += AllTrim(StrTran(Transform(TRB4->F3_VALICB,"@E 999999999.99"),",","."))
			cLin += cSep
		EndIf

		//22- Outros tributos e cargos(Não obrigatório)
		cLin += AllTrim(StrTran(Transform(TRB4->OUTROS,"@E 999999999.99"),",","."))
		cLin += cSep
				
		//23- Importe total
		lAdu := .F.
		dbSelectArea("SD1")
		SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		If SD1->(MsSeek(TRB4->F3_FILIAL+TRB4->F3_NFISCAL+TRB4->F3_SERIE+TRB4->F3_CLIEFOR+TRB4->F3_LOJA))
			Do While SD1->(!EOF()) .and.;
				TRB4->F3_FILIAL+TRB4->F3_NFISCAL+TRB4->F3_SERIE+TRB4->F3_CLIEFOR+TRB4->F3_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA				
				dbSelectArea("SF4")
				SF4->(dbSetOrder(1))//F4_FILIAL+F4_CODIGO
				If SF4->(ColumnPos("F4_ADUANA")) > 0
					If SF4->( MsSeek( cFilSF4+SD1->D1_TES ) )
						If SF4->F4_ADUANA == "1"
							lAdu := .T.
							Exit

						EndIf
					EndIf
				EndIf
				SD1->(dbSkip())
			EndDo
		EndIf
		If lAdu
			cLin += AllTrim(StrTran(Transform(TRB4->BASECRD1+TRB4->VALORCRD1+TRB4->F3_EXENTAS,"@E 999999999.99"),",","."))
		Else
			cLin += AllTrim(StrTran(Transform(TRB4->F3_VALCONT,"@E 999999999.99"),",","."))
		EndIf
		cLin += cSep

		//24 - Código  de la Moneda (Tabla 4)
		// ----------------------------------------------------------------------------//
		// Adicionado por SISTHEL, vamos a jalar las monedas de la tabla XQ de la SX5
		// esta tabla es adicionada con el paquete de facturacion electronica SUNAT
		// ----------------------------------------------------------------------------//
		cLin += xFINDMO2(TRB4->F3_FILIAL,TRB4->F3_NFISCAL,TRB4->F3_SERIE,TRB4->F3_CLIEFOR,TRB4->F3_LOJA,TRB4->F3_ESPECIE)
		cLin += cSep
		
		// Necessário que a Nota tenha vínculo com o Documento Original		
		clDoc   := ""
		clSerie := ""
		clTpDoc := ""
		dlEmis  := CTOD("  /  /  ")
		If Alltrim(TRB4->F3_ESPECIE) $ "NCP|NDI"		// SF2
			dbSelectArea("SD2")
			SD2->(dbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			SD2->(MsSeek(TRB4->F3_FILIAL+TRB4->F3_NFISCAL+TRB4->F3_SERIE+TRB4->F3_CLIEFOR+TRB4->F3_LOJA))
			While TRB4->F3_FILIAL+TRB4->F3_NFISCAL+TRB4->F3_SERIE+TRB4->F3_CLIEFOR+TRB4->F3_LOJA == ;
				SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA .and.;
				Empty(clDoc) .and. SD2->(!EOF())
				
				If SD2->D2_ESPECIE == TRB4->F3_ESPECIE .and. !Empty(SD2->D2_NFORI)
					dbSelectArea("SF1")
					SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
					If SF1->(MsSeek(SD2->D2_FILIAL+SD2->D2_NFORI+SD2->D2_SERIORI+SD2->D2_CLIENTE+SD2->D2_LOJA))
						clDoc   := SF1->F1_DOC
						// ----------------------------------------------------------------------------------- //
						// Adicionado por SISTHEL para impresion de la serie 3 ( campo customizado )		   //
						// ----------------------------------------------------------------------------------- //
						If lSerY .And. !Empty(SF1->F1_YSERIE)
							clSerie := PADR(SF1->F1_YSERIE,GetSx3Cache("F1_YSERIE","X3_TAMANHO")," ")
						Else
							If Empty(Alltrim(SF1->F1_SERIE))
								clSerie := SF1->F1_SERIE2
							Else	
								clSerie := SF1->F1_SERIE
							EndIF	
							If Len(Alltrim(clSerie))==3
								clSerie := "0"+clSerie
							EndIf
						EndIf
						dlEmis  := SF1->F1_EMISSAO
						clTpDoc := SF1->F1_TPDOC
					Endif
				Endif
				SD2->(dbSkip())
			Enddo
		ElseIf Alltrim(TRB4->F3_ESPECIE) $ "NDP|NCI"		// SF1
			dbSelectArea("SD1")
			SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			SD1->(MsSeek(TRB4->F3_FILIAL+TRB4->F3_NFISCAL+TRB4->F3_SERIE+TRB4->F3_CLIEFOR+TRB4->F3_LOJA))
			While TRB4->F3_FILIAL+TRB4->F3_NFISCAL+TRB4->F3_SERIE+TRB4->F3_CLIEFOR+TRB4->F3_LOJA == ;
				SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA .and.;
				Empty(clDoc).and. SD1->(!EOF())
				
				If SD1->D1_ESPECIE == TRB4->F3_ESPECIE .and. !Empty(SD1->D1_NFORI)
					dbSelectArea("SF1")
					SF1->(dbSetOrder(2)) //F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC
					If SF1->(MsSeek(SD1->D1_FILIAL+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_NFORI))
						clDoc := SF1->F1_DOC
						If Empty(Alltrim(SF1->F1_SERIE))
							clSerie := SF1->F1_SERORI
						Else
							clSerie := SF1->F1_SERIE
						EndIF
						If Len(Alltrim(clSerie))==3
							clSerie := "0"+clSerie
						EndIf
				 		dlEmis  := SF1->F1_EMISSAO
						clTpDoc := SF1->F1_TPDOC
					EndIf
				EndIf
				SD1->(dbSkip())
			Enddo
		EndIf
											
		//25- Comprovantes que se modifica - Tipo de cambio(Não obrigatório)
		If AllTrim(TRB4->F3_ESPECIE) $ "NCP|NDI"
			cLin += AllTrim(StrTran(Transform(TRB4->F2_TXMOEDA,"@E 999999999.999"),",","."))
		Else
			cLin += AllTrim(StrTran(Transform(TRB4->F1_TXMOEDA,"@E 999999999.999"),",","."))
		EndIf
		cLin += cSep
			
		//26- Fecha de emisson del comprobante que se modifica(Não obrigatório) Deve Possuir nota original vinculada NF -> NCP/NDI
		If AllTrim(TRB4->F3_ESPECIE) $ "NCP|NDI" .And. AllTrim(TRB4->F2_TPDOC) $ "07|08|87|88|97|98" .And. !Empty(dlEmis)
			cLin += SubStr(DTOC(dlEmis),1,6)+SubStr(DTOS(dlEmis),1,4)
		ElseIf AllTrim(TRB4->F1_TPDOC) $ "07|08|87|88|97|98" .And. !Empty(dlEmis)
			cLin += SubStr(DTOC(dlEmis),1,6)+SubStr(DTOS(dlEmis),1,4)
		Else
			cLin += ""
		EndIf
		
		cLin += cSep
						
		//27- Tipo de comprobante que se modifica(Não obrigatório)
		If AllTrim(TRB4->F3_ESPECIE) $ "NCP|NDI" .AND. AllTrim(TRB4->F2_TPDOC) $ "07|08|87|88|97|98" .AND. !Empty(clTpDoc)
			cLin += AllTrim(clTpDoc)
		ElseIf AllTrim(TRB4->F1_TPDOC) $ "07|08|87|88|97|98" .AND. !Empty(clTpDoc)
			cLin += AllTrim(clTpDoc)
		Else
			cLin += "00"                                      
		EndIf	
		cLin += cSep
		clSerie:=Padl(clSerie,4,"0")
					
		//28 - Numero de serie del comprobante que se modifica(Não obrigatório)
		If AllTrim(TRB4->F3_ESPECIE) $ "NCP|NDI" .AND. AllTrim(TRB4->F2_TPDOC) $ "07|08|87|88|97|98" .AND. !Empty(clSerie)	
			If Len(Alltrim(clSerie))==3
				cLin += "0"+clSerie
			Else
				cLin += AllTrim(clSerie)
			EndIf
		ElseIf AllTrim(TRB4->F1_TPDOC) $ "07|08|87|88|97|98" .AND. !Empty(clSerie)	
			If Len(Alltrim(clSerie))==3
				cLin += "0"+clSerie
			Else
				cLin += AllTrim(clSerie)
			EndIf
		Else	
			cLin += ""
		EndIf		
		cLin += cSep
			
       //29 - Codigo de dependencia DUA(Declaracion Unica de Aduanas)(Não obrigatório)
		If clTpDoc $ "50|52"
			cLin += AllTrim(TRB4->F3_SERIE) 
		Else	
			cLin += ""
		EndIf
		cLin += cSep
			
		//30 - Numero del comprobante que se modifica(Não obrigatório) Deve Possuir nota original vinculada NF -> NCP/NDI
		If AllTrim(TRB4->F3_ESPECIE) $ "NCP|NDI" .AND. AllTrim(TRB4->F2_TPDOC) $ "07|08|87|88|97|98" .AND. !Empty(clDoc)
			cLin += Right(AllTrim(clDoc),8)		
		ElseIf AllTrim(TRB4->F1_TPDOC) $ "07|08|87|88|97|98" .AND. !Empty(clDoc)
			cLin += Right(AllTrim(clDoc),8)	
		Else	
			cLin += ""
		EndIf	
		cLin += cSep
			
		//31 - Fecha de emision de la costancia de deposito(Não obrigatório)
		If TRB4->F3_VALIMP5 <> 0 .and. !Empty(TRB4->FE_EMISSAO)
			cLin += SubStr(DTOC(TRB4->FE_EMISSAO),1,6)+SubStr(DTOS(TRB4->FE_EMISSAO),1,4)
		Else
			cLin += ""
		EndIf
		cLin += cSep
						
		//32 - Numero de la constancia de deposito detracción(Não obrigatório)
		If TRB4->F3_VALIMP5 <> 0
			cLin += AllTrim(TRB4->FE_CERTDET)
		Else
			cLin += ""
		EndIf
		cLin += cSep
						
		//33 - Marca del comprobante de pago sujeito a retencion // Tratamento OAS(Não obrigatório) 
		IF SUBSTRING(GetMv("MV_AGENTE"),1,1) $ "S/s" .AND. POSICIONE("SA2",1,cFilSA2+TRB4->F3_CLIEFOR+TRB4->F3_LOJA,"A2_AGENRET") $ '2|N';
			.AND. Empty(POSICIONE("SA2",1,cFilSA2+TRB4->F3_CLIEFOR+TRB4->F3_LOJA,"SA2->A2_BCRESOL"));	
			.AND. ( ( !Empty(TRB4->F1_TPDOC) .AND. !(TRB4->F1_TPDOC $ GetMv("MV_NRETIGV"))) .OR. ( !Empty(TRB4->F2_TPDOC) .AND. !(TRB4->F2_TPDOC $ GetMv("MV_NRETIGV"))))
			SFF->(DBGOTOP())
			While ! SFF->(EOF())
				If SFF->FF_IMPOSTO=='IGR' 
					If TRB4->F3_VALCONT > SFF->FF_IMPORTE 
						cLin += "1"
					Else
						cLin += ""
					EndIf
					EXIT
				EndIf
				SFF->(DbSkip())
			EndDo
		Else
			cLin += ""
		EndIf
		cLin += cSep
		
		//34 - Clasificación de los bienes y servicios adquiridos (Tabla 30)(Não obrigatório)
		If SF1->(ColumnPos("F1_TIPOPE")) > 0 .And. MV_PAR09 == 1
			cLin += AllTrim(TRB4->F1_TIPOPE)
		Else
			cLin += ""
		EndIf
		cLin += cSep
		
		//35 - Identificación del Contrato o del proyecto en el caso de los Operadores de las sociedades irregulares, consorcios, joint ventures u otras formas de contratos(Não obrigatório)
		cLin += ""
		cLin += cSep
		//36 - Error tipo 1: inconsistencia en el tipo de cambio(Não obrigatório)
		cLin += ""
		cLin += cSep
		//37 - Error tipo 2: inconsistencia por proveedores no habidos(Não obrigatório)
		cLin += ""
		cLin += cSep
		//38 - Error tipo 3: inconsistencia por proveedores que renunciaron a la exoneración del Apéndice I del IGV(Não obrigatório)
		cLin += ""
		cLin += cSep
		//39 - Error tipo 4: inconsistencia por DNIs que fueron utilizados en las Liquidaciones de Compra y que ya cuentan con RUC(Não obrigatório)
		cLin += ""
		cLin += cSep
		//40 - Indicador de Comprobantes de pago cancelados con medios de pago(Não obrigatório)
		cLin += ""
		cLin += cSep		
		
		//41 - Estado que identifica la oportunidad de la anotación o indicación si ésta corresponde a un ajuste.(Não obrigatório)
		
		SF3->( dbSetOrder(4) )
		SF3->( MsSeek( xFilial("SF3")+TRB4->F3_CLIEFOR+TRB4->F3_LOJA+TRB4->F3_NFISCAL+TRB4->F3_SERIE ) ) 
		
		SF4->( dbSetOrder(1) )//F4_FILIAL+F4_CODIGO
		SF4->( MsSeek( cFilSF4+SF3->F3_TES ) )
		
		If AllTrim(cTipo) == "03" .Or. SF4->F4_CREDIGV=='2'
			cLin += "0"
			cLin += cSep	
		Else	
	        If SubStr(DTOS(MV_PAR01),1,6)==SubStr(DTOS(TRB4->F3_EMISSAO),1,6)
			   cLin += "1"
			ElseIf TRB4->F3_EMISSAO >= MV_PAR01-365
			   cLin += "6"
			Else
			   cLin += "7"
			EndIf   
			   cLin += cSep		
		Endif	
		cLin += chr(13)+chr(10)
		lGenero := .t.
		fWrite(nHdl,cLin)
		TRB4->(dbSkip())
	EndDo
	fClose(nHdl)
	if !lGenero
	
		xArq := "LE"                            // Fixo  'LE'
		xArq +=  AllTrim(SM0->M0_CGC)           // Ruc
		xArq +=  AllTrim(Str(Year(MV_PAR02)))   // Ano
		xArq +=  AllTrim(Strzero(Month(MV_PAR02),2))  // Mes
		xArq +=  "00"                            // Fixo '00'
		xArq += "080100"                         // Fixo '080100'
		xArq += "00"                             // Fixo '00'
		xArq += "1"
		xArq += "0"
		xArq += "1"
		xArq += "1"
		xArq += ".TXT" // Extensao

		nStatus1 := frename(cDir+cArq,cDir+xArq,NIL,.F. )
	  	IF nStatus1 == -1
	  		If !lAutomato //Tratamiento para automatizados
	  			MsgStop(STR0151 + Str(FError(),4),"") //"Error al grabar el archivo: FError "
	   		EndIf
		EndIf	
	EndIf
	If !lAutomato //Tratamiento para automatizados
		MsgInfo(STR0064,"") //"ARCHIVO TXT GENERADO CON EXITO "
	EndIf
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq1                                ³ Data ³ 22.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Gera o arquivo magnético Não Domiciliados                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir - Diretorio de criacao do arquivo.                    ³±±
±±³            ³ cArq - Nome do arquivo com extensao do arquivo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Peru - Livro de compra - Arquivo Magnetico          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerArq1(cDir)

	Local nHdl		:= 0
	Local cLin		:= ""
	Local cSep		:= "|"
	Local cArq		:= ""
	Local nCont		:= 0
	Local nInd		:= 0
	Local cMV_1DUP	:= PadR(SuperGetMV("MV_1DUP",,"1"),GetSx3Cache("E5_PARCELA","X3_TAMANHO"))
	Local cFilSE2	:= xFilial('SE2')
	Local cFilSF3	:= xFilial("SF3")
	Local cFilSA2	:= xFilial("SA2")

	cArq += "LE"                            // Fixo  'LE'
	cArq +=  AllTrim(SM0->M0_CGC)           // Ruc
	cArq +=  AllTrim(Str(Year(MV_PAR02)))   // Ano
	cArq +=  AllTrim(Strzero(Month(MV_PAR02),2))  // Mes
	cArq +=  "00"                            // Fixo '00'
	cArq += "080200"                         // Fixo '080200'
	cArq += "00"                             // Fixo '00'
	cArq += "1"
	TRB4->(dbGoTop())
	dbSelectArea("TRB4")
	If TRB4->(!EOF())
		cArq += "1"
	Else
		cArq += "0"
	EndIf
	cArq += "1"
	cArq += "1"	
	cArq += ".TXT" // Extensao

	For nCont:=Len(ALLTRIM(cDir)) To 1 Step -1
		If Substr(cDir,nCont,1)=='\'
			cDir:=Substr(cDir,1,nCont)
			EXIT
		EndIf
	Next

	nHdl := fCreate(cDir+cArq,0,NIL,.F.)
	If nHdl <= 0
		ApMsgStop(STR0069,"") //"Ocurrió un error al crear archivo"
	Else
		TRB4->(dbGoTop())
		Do While TRB4->(!EOF())
			If AllTrim(TRB4->F1_TPDOC) $ '14'
				If TRB4->F3_ENTRADA < TRB4->E2_VENCTO //.OR. TRB4->F3_ENTRADA < TRB4->E2_BAIXA // ENTRADA MENOR QUE VENCIMENTO OU MENOR QUE BAIXA
					If TRB4->E2_BAIXA <= TRB4->E2_VENCTO
						If  (TRB4->E2_BAIXA < MV_PAR01 .OR. TRB4->E2_BAIXA > MV_PAR02) .AND. (TRB4->E2_BAIXA > dDUtilFin .OR. Empty(TRB4->E2_BAIXA))
							TRB4->(DbSkip())
							Loop
						ElseIf (TRB4->E2_VENCTO < MV_PAR01 .OR. TRB4->E2_VENCTO > MV_PAR02) .AND. (TRB4->E2_BAIXA > dDUtilFin .OR. Empty(TRB4->E2_BAIXA))
							TRB4->(DbSkip())
							Loop
						EndIf
					EndIf
				ElseIf TRB4->F3_ENTRADA < MV_PAR01 .OR. TRB4->F3_ENTRADA > MV_PAR02 //  ENTRADA MAIOR QUE VENCIMENTO E MAIOR QUE BAIXA ANALISO RECEBIMENTO
					TRB4->(DbSkip())
					Loop
				EndIf
			EndIf

			lImprime := .F.

			If TRB4->F3_VALIMP5 >0
				aRet := DetIGVFnPeru(TRB4->F3_CLIEFOR,TRB4->F3_LOJA,(dDUtilInic),(dDUtilFin),TRB4->F3_FILIAL,TRB4->F3_ENTRADA) // Preenche o array aRet de acordo com a funcao
				aretMes:= DetIGVFnPeru(TRB4->F3_CLIEFOR,TRB4->F3_LOJA,(MV_PAR01),(dDUtilFin),TRB4->F3_FILIAL,TRB4->F3_ENTRADA) // Preenche o array aRet de acordo com a funcao
				nPos :=Ascan(aRet,{|x| x[1]+x[2]+x[5] == TRB4->F3_SERIE+TRB4->F3_NFISCAL+iif(empty(TRB4->E2_PARCELA),cMV_1DUP,TRB4->E2_PARCELA)})
				nPosMes:=Ascan(aretMes,{|x| x[1]+x[2]+x[5] == TRB4->F3_SERIE+TRB4->F3_NFISCAL+iif(empty(TRB4->E2_PARCELA),cMV_1DUP,TRB4->E2_PARCELA)})
				lImprime := .F.
				If nPos>0 .and. TRB4->F3_ENTRADA < MV_PAR01
					cPrefixo := aRet[nPos,1]//Prefixo
					cNumero  := aRet[nPos,2]// Numero do Titulo
					cParcela := aRet[nPos,5]// Parcela
					cTipo := PADR("TX",GetSx3Cache("E2_TIPO","X3_TAMANHO"))  			 // Tipo que deve ser TX

					If cNumero == TRB4->F3_NFISCAL //Verifica se o titulo do aRet e o mesmo do TRB4
						DbselectArea("SE2")
						SE2->(DbGoTop())
						SE2->(dbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
						If SE2->(MsSeek(cFilSE2+cPrefixo+cNumero+cParcela+cTipo)) //Procura o titulo TX no SE2, se encontrar deve imprimir
							lImprime := .T.
						Endif
					Endif
				EndIf
				If nPosMes>0 .and. TRB4->F3_ENTRADA >= MV_PAR01 .and. TRB4->F3_ENTRADA <= dDUtilFin
					cPrefixo := aretMes[nPosMes,1]//Prefixo
					cNumero  := aretMes[nPosMes,2]// Numero do Titulo
					cParcela := aretMes[nPosMes,5]// Parcela
					cTipo := PADR("TX",GetSx3Cache("E2_TIPO","X3_TAMANHO"))  			 // Tipo que deve ser TX

					If cNumero == TRB4->F3_NFISCAL //Verifica se o titulo do aRet e o mesmo do TRB4
						DbselectArea("SE2")
						SE2->(DbGoTop())
						SE2->(dbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
						If SE2->(MsSeek(cFilSE2+cPrefixo+cNumero+cParcela+cTipo)) //Procura o titulo TX no SE2, se encontrar deve imprimir
							lImprime := .T.
						EndIf
					EndIf
				EndIf
				If !lImprime // Se nao encontrar nao imprime

					TRB4->(DbSkip())
					Loop
				EndIf
			EndIf

			cLin := ""

			//01 - Periodo
			cLin += SubStr(DTOS(MV_PAR02),1,6)+"00"
			cLin += cSep

			//02 - Numero correlativo del registro
			If AllTrim(TRB4->F3_ESPECIE) $ "NCP|NDI"
				cLin += AllTrim(TRB4->F2_NODIA)
			Else
				cLin += AllTrim(TRB4->F1_NODIA)
			EndIf
			cLin += cSep

			//03- Numero correlativo del registro
			If AllTrim(TRB4->F3_ESPECIE) $ "NCP|NDI"
				SF2->( DbSetOrder(1) ) //F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
				If SF2->( MsSeek(TRB4->F3_FILIAL+TRB4->F3_NFISCAL+TRB4->F3_SERIE+TRB4->F3_CLIEFOR+TRB4->F3_LOJA) )
					cLin += "M"+getLinCT2(AllTrim(SF2->F2_NODIA),SF2->F2_VALBRUT,SF2->F2_MOEDA,SF2->F2_VALFAT,.F.,TRB4->F3_FILIAL)
				Else
					cLin += "M"+StrZero(++nInd,9)
				EndIf
			Else
				SF1->( DbSetOrder(1) ) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
				If SF1->( MsSeek(TRB4->F3_FILIAL+TRB4->F3_NFISCAL+TRB4->F3_SERIE+TRB4->F3_CLIEFOR+TRB4->F3_LOJA) )
					If AllTrim(TRB4->F1_TPDOC)$'46'
						cLin += "M"+getLinCT2(AllTrim(SF1->F1_NODIA),SF1->F1_VALIMP1,SF1->F1_MOEDA,SF1->F1_VALIMP1,.F.,TRB4->F3_FILIAL)
					ElseIf AllTrim(TRB4->F1_TPDOC)$'50'
						cLin += "M"+getLinCT2(AllTrim(SF1->F1_NODIA),(SF1->F1_VALBRUT-SF1->F1_VALIMP5),SF1->F1_MOEDA,(SF1->F1_VALBRUT-SF1->F1_VALIMP5),.T.,TRB4->F3_FILIAL)
					Else
						cLin += "M"+getLinCT2(AllTrim(SF1->F1_NODIA),(SF1->F1_VALBRUT-SF1->F1_VALIMP6),SF1->F1_MOEDA,(SF1->F1_VALBRUT-SF1->F1_VALIMP6),.F.,TRB4->F3_FILIAL)
					EndIf
				Else
					cLin += "M"+StrZero(++nInd,9)
				EndIf
			EndIf
			cLin += cSep

			//04- Fecha de emisión del comprobante de pago o documento
			cLin += SubStr(DTOC(TRB4->F3_EMISSAO),1,6)+SubStr(DTOS(TRB4->F3_EMISSAO),1,4)
			cLin += cSep

			//05- Tipo de Comprobante de Pago o Documento del sujeto no domiciliado
			// Sólo permite los tipos de documentos "00", "91", "97" y "98"de la tabla 10
			cTipo:="00"
			If AllTrim(TRB4->F2_TPDOC) $ "00|91|97|98"
				If AllTrim(TRB4->F3_ESPECIE) $ "NCP|NDI"
					cTipo:= AllTrim(TRB4->F2_TPDOC)
				EndIf
			ElseIf AllTrim(TRB4->F1_TPDOC) $ "00|91|97|98"
				If AllTrim(TRB4->F3_ESPECIE) <> "NCP|NDI"
					cTipo:= AllTrim(TRB4->F1_TPDOC)
				EndIf
			EndIf
			cLin+= Iif(!Empty(cTipo),cTipo,"00")
			cLin += cSep

			//06- Serie del comprobante de Pago  Não obrigatório
			// ----------------------------------------------------------------------------------- //
			// Adicionado por SISTHEL para impresion de la serie 3 ( campo customizado )		   //
			// ----------------------------------------------------------------------------------- //
			cLin += IIf(Empty(TRB4->F3_SERIE),if(Empty(TRB4->F3_SERIE2),"0000",TRB4->F3_SERIE2),TRB4->F3_SERIE)
			cLin += cSep

			//07- Numero del comprobante de pago
			cLin += Right(AllTrim(TRB4->F3_NFISCAL),20)
			cLin += cSep

			//08 - Valor de las adquisiciones Não obrigatório
			cLin += AllTrim(StrTran(Transform(TRB4->F3_VALCONT,"@E 999999999.99"),",","."))
			cLin += cSep

			//09 - Otros conceptos adicionales Não obrigatório
			cLin += ""
			cLin += cSep

			//10 - Importe total de las adquisiciones registradas según comprobante de pago o documento
			cLin += AllTrim(StrTran(Transform(TRB4->F3_VALCONT,"@E 999999999.99"),",","."))
			cLin += cSep

			//11 - Tipo de Comprobante de Pago o Documento que sustenta el crédito fiscal Não obrigatório
			cLin += ""
			cLin += cSep

			//12 - Serie del comprobante de pago o documento que sustenta el crédito fiscal Não obrigatório
			cLin += ""
			cLin += cSep

			//13 - Año de emisión de la DUA o DSI que sustenta el crédito fiscal Não obrigatório
			cLin += ""
			cLin += cSep

			//14 - Número del comprobante de pago o documento o número de orden del
			//formulario físico o virtual donde conste el pago del impuesto  Não obrigatório
			cLin += ""
			cLin += cSep

			//15 - Monto de retención del IGV Não obrigatório
			SF3->( dbSetOrder(4) ) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
			If SF3->( MsSeek( cFilSF3+TRB4->F3_CLIEFOR+TRB4->F3_LOJA+TRB4->F3_NFISCAL+TRB4->F3_SERIE ) )
				cLin += AllTrim(StrTran(Transform(Round(SF3->F3_VALIMP3, 2), "@E 999999999.99"), ",", "."))
				cLin += cSep
			Else
				cLin += ""
				cLin += cSep
			EndIf

			//16 - Código  de la Moneda (Tabla 4)
			cLin += xFINDMO2(TRB4->F3_FILIAL,TRB4->F3_NFISCAL,TRB4->F3_SERIE,TRB4->F3_CLIEFOR,TRB4->F3_LOJA,TRB4->F3_ESPECIE)
			cLin += cSep

			//17 - Tipo de cambio. Obrigatório  se o campo 16 <> PEN (Nuevo Sol o Sol)
			If AllTrim(SYF->YF_ISO) == "PEN"
				cLin += AllTrim(StrTran(Transform(Round(1,3),"@E 9999.999"),",","."))
			ElseIf AllTrim(TRB4->F3_ESPECIE) $ "NCP|NDI"
				cLin += AllTrim(StrTran(Transform(Round(TRB4->F2_TXMOEDA,3),"@E 9999.999"),",","."))
			ElseIf AllTrim(TRB4->F3_ESPECIE) <> "NCP|NDI"
				cLin += AllTrim(StrTran(Transform(Round(TRB4->F1_TXMOEDA,3),"@E 9999.999"),",","."))
			EndIf
			cLin += cSep

			//18 - Pais de la residencia del sujeto no domiciliado
			cLin += AllTrim(TRB4->A2_CODNAC)
			cLin += cSep

			//19 - Apellidos y nombres, denominación o razón social  del sujeto no domiciliado. En caso de personas naturales se debe consignar los datos en el siguiente orden:
			cLin += Subs(AllTrim(TRB4->A2_NOME),1,100)
			cLin += cSep

			//20 - Domicilio en el extranjero del sujeto no domiciliado  Não obrigatório
			SA2->( dbSetOrder(1) ) //A2_FILIAL+A2_COD+A2_LOJA
			If SA2->( MsSeek( cFilSA2+TRB4->F3_CLIEFOR+TRB4->F3_LOJA ) )
				cLin += Left(AllTrim(SA2->A2_END), 100)
			Else
				cLin += ""
			EndIf
			cLin += cSep

			//21 - Número de identificación del sujeto no domiciliado
			If !Empty(TRB4->A2_CGC)
				cLin += AllTrim(TRB4->A2_CGC)
			ElseIf !Empty(TRB4->A2_PFISICA)
				cLin += AllTrim(TRB4->A2_PFISICA)
			Else
				cLin += "0"
			EndIf
			cLin += cSep

			//22 - Número de identificación fiscal del beneficiario efectivo de los pagos  Não obrigatório
			If !Empty(TRB4->A2_CGC)
				cLin += AllTrim(TRB4->A2_CGC)
			ElseIf !Empty(TRB4->A2_PFISICA)
				cLin += AllTrim(TRB4->A2_PFISICA)
			Else
				cLin += "0"
			EndIf
			cLin += cSep

			//23 - Apellidos y nombres, denominación o razón social  del beneficiario efectivo de los pagos Não obrigatório
			cLin += Subs(AllTrim(TRB4->A2_NOME), 1, 100)
			cLin += cSep
			//24 - Pais de la residencia del beneficiario efectivo de los pagos Não obrigatório
			cLin += AllTrim(TRB4->A2_CODNAC)
			cLin += cSep
			//25 - Vínculo entre el contribuyente y el residente en el extranjero Não obrigatório
			cLin += ""
			cLin += cSep
			//26 - Renta Bruta Não obrigatório
			cLin += ""
			cLin += cSep
			//27 - Deducción / Costo de Enajenación de bienes de capital Não obrigatório
			cLin += ""
			cLin += cSep
			//28 - Renta Neta Não obrigatório
			cLin += ""
			cLin += cSep

			SF3->( dbSetOrder(4) ) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
			If SF3->( MsSeek( cFilSF3+TRB4->F3_CLIEFOR+TRB4->F3_LOJA+TRB4->F3_NFISCAL+TRB4->F3_SERIE ) )
				//29 - Tasa de retención Não obrigatório
				cLin += AllTrim(StrTran(Transform(Round(SF3->F3_ALQIMP6,2), "@E 999.99"), ",", "."))
				cLin += cSep
				//30 - Impuesto retenido Não obrigatório
				cLin += AllTrim(StrTran(Transform(Round(SF3->F3_VALIMP6,2), "@E 999999999.99"), ",", "."))
				cLin += cSep
			Else
				//29 - Tasa de retención Não obrigatório
				cLin += ""
				cLin += cSep
				//30 - Impuesto retenido Não obrigatório
				cLin += ""
				cLin += cSep
			EndIf

			//31 - Convenios para evitar la doble imposición
			cLin += "0" + AllTrim(TRB4->A2_CONVEN)
			cLin += cSep
			//32 - Exoneración aplicada Não obrigatório
			cLin += ""
			cLin += cSep

			//33 - Tipo de Renta  VERIFICAR
			If Empty(AllTrim(TRB4->F1_TPRENTA))
				cLin += AllTrim(TRB4->F2_TPRENTA)
			Else
				cLin += AllTrim(TRB4->F1_TPRENTA)
			Endif
			cLin += cSep

			//34 - Modalidad del servicio prestado por el no domiciliado  Não obrigatório
			If SF1->(ColumnPos("F1_TIPOPE")) > 0 .And. MV_PAR09 == 1
				cLin += AllTrim(TRB4->F1_TIPOPE)
			Else
				cLin += ""
			EndIf
			cLin += cSep
			
			//35 - Aplicación del penultimo parrafo del Art. 76° de la Ley del Impuesto a la Renta Não obrigatório
			cLin += ""
			cLin += cSep
			//36 - Estado que identifica la oportunidad de la anotación o indicación si ésta corresponde a un ajuste.
			cLin += "0"
			cLin += cSep

			cLin += chr(13)+chr(10)

			fWrite(nHdl,cLin)
			TRB4->(dbSkip())
		EndDo
		fClose(nHdl)
		If !lAutomato //Tratamiento para autimatizados
			MsgInfo(STR0064,"") //"ARCHIVO TXT GENERADO CON EXITO "
		EndIf
	EndIf

Return Nil

/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq2   ³                            ³ Data ³ 22.02.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Arquivo em branco para no sujeitos sem movimentação        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir - Diretorio de criacao do arquivo.                    ³±±
±±³            ³ cArq - Nome do arquivo com extensao do arquivo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Peru - Livro de compra - Arquivo Magnetico          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
/*/
Static Function GerArq2(cDir)
	Local nHdl		:= 0
	Local cLin		:= ""
	Local cArq		:= ""
	Local nCont		:= 0
	
	cArq += "LE"                            	// Fixo  'LE'
	cArq +=  AllTrim(SM0->M0_CGC)           	// Ruc
	cArq +=  AllTrim(Str(Year(MV_PAR02)))   		// Ano
	cArq +=  AllTrim(Strzero(Month(MV_PAR02),2)) // Mes
	cArq +=  "00"                            	// Fixo '00'
	
	If MV_PAR06 == 1 .And. MV_PAR08 == 2
		cArq += "080200"                        // Fixo '080200'
	Else
		cArq += "080100"                        // Fixo '080100'
	EndIf
	
	cArq += "00"                             	// Fixo '00'
	cArq += "1"
	TRB3->(dbGoTop())
	dbSelectArea("TRB3")
	If TRB3->(!EOF())
		cArq += "1"
	Else
		cArq += "0"
	EndIf
	cArq += "1"
	cArq += "1"
	cArq += ".TXT" // Extensao
	
	For nCont:=Len(AllTrim(cDir)) To 1 Step -1
	   If Substr(cDir,nCont,1)=='\' 
	      cDir:=Substr(cDir,1,nCont)
	      EXIT
	   EndIf   
	Next
	
	nHdl := fCreate(cDir+cArq)
	If nHdl <= 0
		ApMsgStop(STR0069,"") //"Ocurrió un error al crear archivo"
	Else
		fWrite(nHdl,cLin)
		fClose(nHdl)
		If !lAutomato //Tratamiento para automatizados
			MsgInfo(STR0064,"") //"ARCHIVO TXT GENERADO CON EXITO "
		EndIf
	EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ZFISR012  ºAutor  ³Microsiga           º Data ³  07/17/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function xFINDMO2( cFil,cDoc,cSer,cForn,cLoj,_cEspec )

	Local nMoeda	:= 1
	Local aArea		:= GetArea()
	Local _cAlias	:= GetNextAlias()
	Local cSql004	:= ""
	Local cMoeda	:= space(3)

	If !(Alltrim(_cEspec) $ "NCP|NDI")

		cSql004:= " SELECT F1_MOEDA"
		cSql004+= " FROM "+ RetSqlName("SF1") + " SF1 "
		cSql004+= " WHERE SF1.F1_FILIAL  = '"+cFil+"' "
		cSql004+= "   AND SF1.F1_DOC     = '"+cDoc+"' "
		cSql004+= "   AND SF1.F1_SERIE   = '"+cSer+"' "
		cSql004+= "   AND SF1.F1_FORNECE = '"+cForn+"' "
		cSql004+= "   AND SF1.F1_LOJA    = '"+cLoj+"' "
		cSql004+= "   AND SF1.D_E_L_E_T_ <> '*' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql004 ), _cAlias,.T.,.T.)

		If (_cAlias)->( !eof() )
			nMoeda := (_cAlias)->F1_MOEDA
		EndIf
		
		(_cAlias)->( dbCloseArea() )

	Else

		cSql004:= " SELECT F2_MOEDA"
		cSql004+= " FROM "+ RetSqlName("SF2") + " SF2 "
		cSql004+= " WHERE SF2.F2_FILIAL  = '"+cFil+"' "
		cSql004+= "   AND SF2.F2_DOC     = '"+cDoc+"' "
		cSql004+= "   AND SF2.F2_SERIE   = '"+cSer+"' "
		cSql004+= "   AND SF2.F2_CLIENTE = '"+cForn+"' "
		cSql004+= "   AND SF2.F2_LOJA    = '"+cLoj+"' "
		cSql004+= "   AND D_E_L_E_T_ <> '*' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql004 ), _cAlias,.T.,.T.)

		If (_cAlias)->( !eof() )
			nMoeda := (_cAlias)->F2_MOEDA
		EndIf
		
		(_cAlias)->( dbCloseArea() )
	
	EndIf

	cSql004:= " SELECT X5_DESCSPA"
	cSql004+= " FROM "+ RetSqlName("SX5") + " SX5 "
	cSql004+= " WHERE SX5.X5_FILIAL  = '"+xFilial("SX5")+"' "
	cSql004+= "   AND RTRIM(LTRIM(SX5.X5_TABELA))='XQ'"
	cSql004+= "   AND RTRIM(LTRIM(SX5.X5_CHAVE))='" + Alltrim(str(nMoeda)) + "'"
	cSql004+= "   AND D_E_L_E_T_ <> '*' "	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql004 ), _cAlias,.T.,.T.)

	If (_cAlias)->( !eof() )
		cMoeda := alltrim((_cAlias)->X5_DESCSPA)
	EndIf
		
	(_cAlias)->( dbCloseArea() )

	RestArea(aArea)
	
Return( cMoeda )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ZFISR012  ºAutor  ³Microsiga           ºFecha ³  09/05/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function getLinCT2(cSegofi,nVal,nMda,nVal1,lsosegofi,cXFil)

	local cSql		:= ""
	local cMoeda	:= strzero(nMda,2)
	local cVlRed	:= alltrim(str(Round(nVal,0)))
	local nVlRed	:= alltrim(str(Round(nVal1,0)))
	local _cAlias	:= getNextAlias()
	local cLinha	:= "000000001"
	
	cSql := " SELECT CT2_LINHA,CT2_CREDIT,CT2_DEBITO"
	cSql += "   FROM "+ RetSqlName("CT2")
	cSql += "  WHERE CT2_FILIAL = '"+cXFil+"'"
	cSql += "    AND CT2_MOEDLC='"+cMoeda+"'"
	if !lsosegofi
		cSql += "    AND ROUND(CT2_VALOR,0) BETWEEN "+nVlRed+" AND "+cVlRed
	endif
	cSql += "    AND CT2_SEGOFI='"+cSegofi+"'"
	cSql += "    AND D_E_L_E_T_ <> '*' "	
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql ), _cAlias,.T.,.T.)

	If (_cAlias)->( !eof() )
		While (_cAlias)->( !eof() )
			if left((_cAlias)->CT2_DEBITO,1)=="4"
				cLinha := strzero(val((_cAlias)->CT2_LINHA),9)
				exit
			elseif left((_cAlias)->CT2_CREDIT,1)=="4"
				cLinha := strzero(val((_cAlias)->CT2_LINHA),9)
				exit
			endif
			(_cAlias)->( dbSkip() )
		End
	EndIf
		
	(_cAlias)->( dbCloseArea() )

Return(cLinha)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ZFISR012  ºAutor  ³Microsiga           º Data ³  10/02/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function getSegofi(cNodia,cMoeda,ManBD)

	local cgofi := cNodia
	local _cAlias := getNextAlias()
	local cSql := ""
	local cLp := ""
	local cKeyArr := ""
	local cKeyOri := ""
	local aCampos := {}
	local cTabla := ""
	local nX:=0
	         
	cSql := " SELECT CT2_LP,CT2_SEGOFI,CT2_KEY"
	cSql += "   FROM "+ RetSqlName("CT2")
	cSql += "  WHERE CT2_FILIAL = '"+xFilial("CT2")+"'"
	cSql += "    AND CT2_MOEDLC='"+strzero(cMoeda,2)+"'"
	cSql += "    AND CT2_NODIA='"+cgofi+"'"
	cSql += "    AND D_E_L_E_T_ = '' "	
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql ), _cAlias,.T.,.T.)

	If (_cAlias)->( !eof() )
		cLp := (_cAlias)->CT2_LP
	EndIf
		
	(_cAlias)->( dbCloseArea() )
	
	dbSelectArea("CTL")
	dbSetOrder(1) //CTL_FILIAL + CTL_LP
	
	If CTL->(dbSeek(xFilial("CTL") + cLp))
		cKeyArr := CTL->CTL_KEY
		cTabla := CTL->CTL_ALIAS
	EndIf
	
	If !Empty(cKeyArr) 
	
		aCampos := StrTokArr( cKeyArr, "+" )
		For nX := 1 To Len(aCampos)
			
			cKeyOri += (cTabla)->(&(aCampos[nX]))
		Next nX

		If ManBD $ "INFORMIX|ORACLE|DB2|OPENEDGE|POSTGRES|"
			cSql := "SELECT CT2_SEGOFI"
		Else
			cSql := "SELECT TOP 1 CT2_SEGOFI"
		EndIf
		cSql += "  FROM "+ RetSqlName("CT2")
		cSql += " WHERE CT2_KEY='"+cKeyOri+"'"
		cSql += "   AND D_E_L_E_T_=''"
		cSql += "   AND CT2_MOEDLC='" + strzero(cMoeda,2) + "'"
		//Select TOP para manejadores de BD diferentes de SQL
		If ManBD == "ORACLE"
			cSql += " AND ROWNUM <= 1" 
		ElseIf ManBD $ "POSTGRES"
			cSql += " LIMIT 1 "
		EndIf

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql ), _cAlias,.T.,.T.)
	
		If (_cAlias)->( !eof() )
			cgofi := (_cAlias)->CT2_SEGOFI
		EndIf
			
		(_cAlias)->( dbCloseArea() )

	EndIf
	
Return(cgofi)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ZFISR012  ºAutor  ³Microsiga           ºFecha ³  22/10/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Añade columnas en blanco al imprimir relatorio mediante    º±±
±±º          ³ opcion 4 - Planilla.                                       º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EspCabec(nEspacios)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nEspacios - Cantidad de espacios a insertar.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ FISR012                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function EspCabec(nEspacios)
	Local nX	:= 0
	
	For nX := 1 To nEspacios
		opPrint:PrintText(Space(1),opPrint:Row(),0010)
	Next nX
Return Nil
