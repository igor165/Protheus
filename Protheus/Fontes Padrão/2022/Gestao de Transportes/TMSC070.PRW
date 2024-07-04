#INCLUDE "Protheus.ch"
#INCLUDE "TMSC070.ch"

Static lTMC70COL := ExistBlock("TMC70COL")
Static lTMC70BUT := ExistBlock("TMC70BUT")
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMSC070   บAutor  ณTelso Carneiro      บ Data ณ  28/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta km de Entrada e Saida dos Veiculos/Motorista      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ TMSC070()                            					        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGATMS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TMSC070()                

Local cPerg    	:= "TMC070"
Local aHDados  	:= {}
Local aTitulos 	:= {}
Local aDados	:= {}
Local nI		:= 0
Local aSize	 	:= MsAdvSize()
Local aUsHDados	:= {}                                                        
Local bVerViagem:= {|| }
Local bVerCTC   := {|| }
Local Pesquisa  := {|| }
Local aButtons 	:= {}
Local oDlgKm
Local oListBox
Local nPosFil	:= 0
Local nPosVig	:= 0
Local nPosCTC	:= 0
Local aSomaButtons:= {}

Local aHlpPor1	:=  {"Nใo existe contrato para a viagem."}
Local aHlpEsp1	:=  {"No existe contrato para viaje."}
Local aHlpIng1	:=  {"There is not a contract for the trip"}

Private aSetKey := {}
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis utilizadas para parametros                               ณ
//ณmv_par01	  Filial de Origem De                         			    ณ
//ณmv_par02	  Filial de Origem At้                                    ณ
//ณmv_par03	  Data de Entrada De                                      ณ
//ณmv_par04	  Data de Entrada At้                                     ณ
//ณmv_par05	  Considera Data de Entrada ou Saida na Km do Veiculo/Motoristaณ
//ณmv_par06	  Motorista De                                            ณ
//ณmv_par07	  Motorista At้                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica as perguntas selecionadas                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PutHelp("PTMSC07001",{"Nใo hแ veiculos para a categoria ","selecionada"},{''},{''},.T.)

PutHelp("PTMSC07002",aHlpPor1,aHlpIng1,aHlpEsp1,.T.)
         
If Pergunte(cPerg,.T.)

	//-- Inclui colunas do usuario
	If lTMC70COL
		If ValType( aUsHDados := ExecBlock( 'TMC70COL', .F., .F. ) ) <> 'A'
			aUsHDados := {}
		EndIf
	EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArray com os Campos para o  Listbox, utilizados tambem na Query,   ณ
//ณo qual indica a ordem de apresentacao 							          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AAdd( aHDados, 'DUV_CODVEI')			
	AAdd( aHDados, 'DA3_DESC'  )
	AAdd( aHDados, 'DUV_CODRB1')			
	AAdd( aHDados, 'DUV_CODRB2')	
	AAdd( aHDados, 'DUV_FILORI')
	AAdd( aHDados, 'DUV_VIAGEM')	
	AAdd( aHDados, 'DUV_FILSAI')	
	AAdd( aHDados, 'DUV_DATSAI')	
	AAdd( aHDados, 'DUV_HORSAI')
	AAdd( aHDados, 'DUV_ODOSAI')	
	AAdd( aHDados, 'DUV_FILENT')		
	AAdd( aHDados, 'DUV_DATENT')
	AAdd( aHDados, 'DUV_HORENT')		
	AAdd( aHDados, 'DUV_ODOENT')				
	AAdd( aHDados, 'DA4_COD'   )		
	AAdd( aHDados, 'DA4_NOME'  )			
	AAdd( aHDados, 'DTY_NUMCTC') 							  
	//-- Inclui colunas do usuario
	If lTMC70COL
		For nI := 1 To Len(aUsHDados)
			Aadd( aHDados, aUsHDados[nI,1] )
		Next nI
	EndIf
	
	nPosFil		:= Ascan(aHDados,'DUV_FILORI')
	nPosVig		:= Ascan(aHDados,'DUV_VIAGEM')
	nPosCTC	   := Ascan(aHDados,'DTY_NUMCTC')
	//-- Inclui colunas do usuario
					
	bVerViagem  := {|| TmsC070Viag(aDados[oListBox:nAT,nPosFil],aDados[oListBox:nAT,nPosVig]) }
 	Aadd(aButtons, {"CARGA"  , bVerViagem , STR0002 , STR0003 } ) //"Viagem - <F4 >"###"Viagem"
	bVerCTC     := {|| TmsC070CTC(aDados[oListBox:nAT,nPosFil],aDados[oListBox:nAT,nPosCTC]) }                
	Aadd(aButtons, {"EDIT"  , bVerCTC    , STR0004 ,STR0005} ) //"Contrato Carret. - <F5 >"###"Ctr.Carr"
	Pesquisa     := {|| Tms070Pesq(oListBox,aDados)}
 	Aadd(aButtons, {"Pesquisa"  , Pesquisa , STR0008 } ) //"Pesquisa"	
	
	//-- Inicializa Teclas de Atalhos
	Aadd(aSetKey, { VK_F4 ,  bVerViagem } )
	Aadd(aSetKey, { VK_F5 ,  bVerCTC } )
	TmsKeyOn(aSetKey)
	
	Processa({|lEnd| Tms070Proc(@lEnd,aHDados,@aDados,aUsHDados)},,STR0001,.T.)  //"Selecionando Registros ... "
	   
	If Len(aDados) > 0 
			
		aTitulos:={}
		For nI:=1 To Len(aHDados) 
			AAdd( aTitulos, RetTitle(aHDados[nI]))
		Next nI
	   
		DEFINE MSDIALOG oDlgKm TITLE STR0006  From aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL //'Consulta Km de Entrada e Saida dos Veiculos/Motoristas'
			
		oListBox := TWBrowse():New( aSize[7],00,aSize[6],aSize[5],,aTitulos,,oDlgKm,,,,,,,,,,,,,"ARRAY",.T.) 
		oListBox:SetArray( aDados )                                  
		
		// Ajusta alinhamento do TWBrowse para pegar o dialogo inteiro
		oListBox:Align := CONTROL_ALIGN_ALLCLIENT
		
		oListBox:bLine := {|| aDados[oListBox:nAT] }
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Ponto de Entrada criado para mudar os botoes da enchoicebar                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		IF lTMC70BUT
			aSomaButtons := ExecBlock( "TMC70BUT", .f., .f., {aDados,oListBox} )
			If	ValType(aSomaButtons) == 'A'
				For nI:=1 To Len(aSomaButtons)
					AAdd(aButtons,aSomaButtons[nI])
				Next nI
			EndIf
		Endif
		
		ACTIVATE MSDIALOG oDlgKm ON INIT EnchoiceBar(oDlgKm,{|| oDlgKm:End()},{|| oDlgKm:End()},, aButtons )
		
	Else
		Help(' ', 1, 'SEMDADOS')
	EndIf
		
EndIf 

Return(Nil)
           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTms070ProcบAutor  ณTelso Carneiro      บ Data ณ  28/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega os dados para a Array da Consulta                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TMSC070()                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Tms070Proc(lEnd,aHDados,aDados,aUsHDados)
Local aARea		:= GetArea()
Local cAliasTmp:= GetNextAlias()
Local cQuery	:= ''  
Local nI			:= 0
Local aTam		:= {}
Local cQueryPt  
Local cTipVei := ''

// Busca todo os tipos de veiculos cadastrado para a categoria selecionada nos parametros
cQuery := "SELECT DUT_TIPVEI "
cQuery += "  FROM "+RetSqlName("DUT")
cQuery += " WHERE D_E_L_E_T_ = ''"
cQuery += "   AND DUT_FILIAL = '" + xFilial("DUT") + "'"
cQuery += "   AND DUT_CATVEI = '" + StrZero( MV_PAR08, Len( DUT->DUT_CATVEI ) ) + "'"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB")

dbEval({|| cTipVei += IIF(Empty(TRB->DUT_TIPVEI),'',TRB->DUT_TIPVEI+"','") })
cTipVei := IIF(Empty(cTipVei),'',"'"+SUBSTR(cTipVei,1,Len(cTipVei)-2))


TRB->(dbCloseArea())

cQuery := "SELECT DISTINCT " 
cQuery += "DUV_FILORI,DUV_VIAGEM,DUV_FILSAI,DUV_DATSAI,DUV_HORSAI, "
cQuery += "DUV_ODOSAI,DUV_FILENT,DUV_DATENT,DUV_HORENT,DUV_ODOENT, "
cQuery += "DUV_CODVEI,DA31.DA3_DESC,DUV_CODRB1,DUV_CODRB2,DA4_COD,DA4_NOME,"
cQuery += "DTY_NUMCTC "  
cQuery += " FROM "+RetSqlName("DUV") + " DUV "  

cQuery += "	JOIN "+RetSqlName("DA4")+" DA4 ON "
cQuery += "		DA4_FILIAL = '"+xFilial("DA4")+"' AND "
cQuery += "		DA4_COD >= '"+mv_par06+"' AND DA4_COD <= '"+mv_par07+"' AND "
cQuery += "		DA4.D_E_L_E_T_ = ' ' "   

cQuery += "	JOIN "+RetSqlName("DUP") +" DUP ON "               
cQuery += "		DUP_FILIAL = '"+xFilial("DUP")+"' AND DUV_FILORI = DUP_FILORI AND "
cQuery += "		DUV_VIAGEM = DUP_VIAGEM  AND  "
cQuery += "		DUP_CODVEI = DUV_CODVEI AND "
cQuery += "		DUP.D_E_L_E_T_ = ' ' AND "        
cQuery += "    DUP_CODMOT = DA4_COD "

cQuery += "	JOIN "+RetSqlName("DA3")+" DA31 ON "  
cQuery += "DA31.DA3_COD = DUV_CODVEI AND " 
cQuery += "DA31.D_E_L_E_T_ = ' ' "      

cQuery += "	JOIN "+RetSqlName("DA3")+" DA3 ON "  
If MV_PAR08 = 3 // Carreta
	cQuery += "((DA3.DA3_COD = DUV_CODRB1) OR (DA3.DA3_COD = DUV_CODRB2)) AND "
Else
	cQuery += "DA3.DA3_COD = DUV_CODVEI AND " 
EndIf

If Empty(cTipVei)
	cQuery += "DA3.DA3_TIPVEI = '' AND "
Else
	cQuery += "DA3.DA3_TIPVEI IN (" + cTipVei + ") AND "
EndIf
cQuery += "DA3.DA3_COD BETWEEN '"+mv_par09+"' AND '"+mv_par10+"' AND "
cQuery += "DA3.D_E_L_E_T_ = ' ' "      

cQuery += "LEFT JOIN "+RetSqlName("DTY")+" DTY ON "
cQuery += "DTY_FILIAL = '"+xFilial("DTY")+"' AND DUV_FILORI = DTY_FILORI AND DUV_VIAGEM = DTY_VIAGEM	AND "
cQuery += "DTY.D_E_L_E_T_ = ' ' "

cQuery += "WHERE DUV.DUV_FILIAL = '"+xFilial("DUV")+"' AND "
cQuery += "DUV.DUV_FILSAI >= '"+mv_par01+"' AND DUV.DUV_FILSAI <= '"+mv_par02+"' AND "
If mv_par05 == 1 // Entrada		
	cQuery += "	DUV.DUV_DATENT BETWEEN '"+DTOS(mv_par03)+"' AND '"+DTOS(mv_par04)+"' AND "
Else	
	cQuery += "	DUV.DUV_DATSAI BETWEEN '"+DTOS(mv_par03)+"' AND '"+DTOS(mv_par04)+"' AND "
EndIf     
If MV_PAR08 = 3 // Carreta
	cQuery += " (DUV_CODRB1 <> '' OR DUV_CODRB2 <> '') AND "
EndIf
cQuery += "	DUV.D_E_L_E_T_ = ' '"

If ExistBlock("TMC70QRY")
	cQueryPt := Execblock("TMC70QRY",.F.,.F.,cQuery)
	If Valtype(cQueryPt) == 'C' .And. cQueryPt != ""	
		cQuery := cQueryPt
	EndIf
EndIf

If Rat("ORDER BY",UPPER(cQuery)) == 0 
	cQuery += " ORDER BY DUV_CODVEI, DUV_DATSAI,DUV_HORSAI, DUV_FILSAI "
EndIf
 	
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp)

If !(cAliasTmp)->(EOF())
	aDadosSru := (cAliasTmp)->(dbStruct())	
	For nI := 1 To Len(aDadosSru)
	   aTam := TamSx3(aDadosSru[nI,1])
		If aTam[3]<>"C"
			TcSetField(cAliasTmp,aDadosSru[nI,1],aTam[3],aTam[1],aTam[2])
		EndIf
	Next nI                                

	While  !(cAliasTmp)->(EOF())
		aDadosAux := {}
		Aadd(aDadosAux,(cAliasTmp)->DUV_CODVEI)				
		Aadd(aDadosAux,(cAliasTmp)->DA3_DESC)				
		Aadd(aDadosAux,(cAliasTmp)->DUV_CODRB1)		
		Aadd(aDadosAux,(cAliasTmp)->DUV_CODRB2)
		Aadd(aDadosAux,(cAliasTmp)->DUV_FILORI+IIf(!Empty((cAliasTmp)->DUV_FILORI)," - "+Posicione("SM0",1,cEmpAnt+(cAliasTmp)->DUV_FILORI,"M0_FILIAL"),""))
		Aadd(aDadosAux,(cAliasTmp)->DUV_VIAGEM)
		Aadd(aDadosAux,(cAliasTmp)->DUV_FILSAI+IIf(!Empty((cAliasTmp)->DUV_FILSAI)," - "+Posicione("SM0",1,cEmpAnt+(cAliasTmp)->DUV_FILSAI,"M0_FILIAL"),""))
		Aadd(aDadosAux,(cAliasTmp)->DUV_DATSAI)
		Aadd(aDadosAux,(cAliasTmp)->DUV_HORSAI)
		Aadd(aDadosAux,(cAliasTmp)->DUV_ODOSAI)			
		Aadd(aDadosAux,(cAliasTmp)->DUV_FILENT+IIf(!Empty((cAliasTmp)->DUV_FILENT)," - "+Posicione("SM0",1,cEmpAnt+(cAliasTmp)->DUV_FILENT,"M0_FILIAL"),""))
		Aadd(aDadosAux,(cAliasTmp)->DUV_DATENT)
		Aadd(aDadosAux,(cAliasTmp)->DUV_HORENT)
		Aadd(aDadosAux,(cAliasTmp)->DUV_ODOENT)		
		Aadd(aDadosAux,(cAliasTmp)->DA4_COD)
		Aadd(aDadosAux,(cAliasTmp)->DA4_NOME) 
		Aadd(aDadosAux,(cAliasTmp)->DTY_NUMCTC) 				
		If lTMC70COL
			For nI := 1 To Len(aUsHDados)
				AAdd(aDadosAux, &( aUsHDados[nI,2] ) )
			Next nI
		EndIf  
		//--Implementa as Pictures nos Dados do array 
		For nI := 1 To Len(aDadosAux)
			aDadosAux[nI]:= Alltrim(TransForm(aDadosAux[nI],PesqPict(Left(aHDados[nI],3),aHDados[nI])))
		Next nI		                                		
		Aadd(aDados,aDadosAux)
		(cAliasTmp)->(DbSkip())
	EndDo
EndIf


(cAliasTmp)->(dbCloseArea())

ResTArea(aArea)

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณTmsC070Viagณ Autor ณ Telso Carneiro       ณ Data ณ 29/03/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Visualiza a viagem                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Tmsc070Viag()                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ TMSC070                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Tmsc070Viag(cFilOri,cViagem)

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

TmsVisViag(SubStr(cFilOri,1, Len(DTQ->DTQ_FILIAL)),cViagem)

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณTmsC070CTC ณ Autor ณ Telso Carneiro       ณ Data ณ 29/03/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Visualiza a Contrato de Carreteiro                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Tmsc070CTC()                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ TMSC070                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function Tmsc070CTC(cFilOri,cNumCTC)
Local aArea	:= GetArea()
Local cSeek := ""
Private cCadastro := STR0007 //"Contrato de Carreteiro"

If !Empty(cNumCTC)
	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)
	
	If Empty(xFilial("DTY"))
		cSeek := xFilial("DTY")+cNumCTC
	Else
		cSeek := Substr(cFilOri,1,2)+cNumCTC
	EndIf
	
	DbSelectArea("DTY")
	DTY->(DbSetOrder(1))
	If DTY->(DBSeek(cSeek))
		Inclui := .F.
		FWExecView (, "TMSA250" , MODEL_OPERATION_VIEW , ,{|| .T. }, , , , , , , )
	EndIf
	
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)
	
Else
	Help(" ",1,"TMSC07002") //-- Nใo existe contrato para a viagem.
EndIf
RestArea(aArea)

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณTms070Pesqณ Autor ณMarcelo Alexandre      ณ Data ณ12.09.2007ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณFuncao para realizar pesquisa no listbox      		      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Tms070Pesq()                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ TMSC070                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Tms070Pesq(oListBox,aDados)

Local oDlg
Local oCbx
Local oBigGet
Local cOrd	 :=""
Local aOrd	 :={}
Local cCampo :=Space(50)
Local aArea	 :=GetArea()
Local lSeek	 :=.F.
Local nSeek	 := 0
Local nOrdem := 1
Local nTamKm := TamSx3("DUV_ODOSAI")[1]

Aadd(aOrd,STR0012)
Aadd(aOrd,STR0009)
Aadd(aOrd,STR0010)
Aadd(aOrd,STR0011) 
Aadd(aOrd,STR0014)
Aadd(aOrd,STR0015)


DEFINE MSDIALOG oDlg FROM 00,00 TO 100,490 PIXEL TITLE STR0008 //"Ordem"

@05,05 COMBOBOX oCBX VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oDlg FONT oDlg:oFont ON CHANGE nOrdem := oCbx:nAt
@22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL

DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlg ENABLE ACTION (lSeek:=.T.,oDlg:End())
DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If lSeek
	If nOrdem == 1 //-- "Fil.Origem+Viagem+Filial Saida"		
		aDados := aSort( aDados,,,{|x,y| x[1] + x[2] + x[3] < y[1] + y[2] + y[3]} )
		If !Empty(cCampo)    
		    cCampo := Alltrim(cCampo)
			nSeek  := Ascan( aDados ,{|x| PadR(x[1],2) + x[2] + PadR(x[3],2) == cCampo }) 		    
		EndIf
	ElseIf nOrdem == 2 //-- "Fil.Origem+Data Entrada+Hora Entrada+Codigo Veiculo+Km Saida+Codigo Motorista"
		aDados := aSort( aDados,,,{|x,y| x[1] + x[8] + x[9] + x[11] + StrZero(Val(x[6]),nTamKm) + x[15] < y[1] + y[8] + y[9] + y[11] + StrZero(Val(y[6]),nTamKm) + y[15]} )
		If !Empty(cCampo)            			
		    cCampo := Alltrim(cCampo)
		    nSeek  := Ascan( aDados ,{|x| PadR(x[1],2) + PadR(x[8] + x[9] + x[11] + x[6] + x[15],Len( cCampo )-2) == cCampo }) 
		EndIf		
	ElseIf nOrdem == 3 //-- "Km Saida+Fil.Origem+Data Entrada+Hora Entrada+Codigo Veiculo+Codigo Motorista"
		aDados := aSort( aDados,,,{|x,y| StrZero(Val(x[6]),nTamKm) + x[1] + x[8] + x[9] + x[11] + x[15] < StrZero(Val(y[6]),nTamKm) + y[1] + y[8] + y[9] + y[11] + y[15]} )
		If !Empty(cCampo)    
		    cCampo := Alltrim(cCampo)
		    nSeek  := Ascan( aDados ,{|x| PadR(x[6] + PadR(x[1],2) + x[8] + x[9] + x[11] + x[15],Len( cCampo )) == cCampo }) 
		EndIf		
	ElseIf nOrdem == 4 //--"Km Saida+Fil.Origem+Data Saida+Hora Saida+Codigo Veiculo+Codigo Motorista"
		aDados := aSort( aDados,,,{|x,y| StrZero(Val(x[6]),nTamKm) + x[1] + x[4] + x[5] + x[11] + x[15] <  StrZero(Val(y[6]),nTamKm) + y[1] + y[4] + y[5] + y[11] + y[15]} )
		If !Empty(cCampo)
		    cCampo := Alltrim(cCampo)
		    nSeek  := Ascan( aDados ,{|x| PadR(x[6] + PadR(x[1],2) + x[4] + x[5] + x[11] + x[15],Len( cCampo )) == cCampo }) 
		EndIf  
	ElseIf nOrdem == 5 //--"Data Entrada+Hora Entrada"
		aDados := aSort( aDados,,,{|x,y| DtoS(CtoD(x[8])) + x[9] < DtoS(CtoD(y[8])) + y[9]} )
		If !Empty(cCampo)    
		    cCampo := Alltrim(cCampo)
		    nSeek  := Ascan( aDados ,{|x| PadR(x[8] + x[9],Len( cCampo )) == cCampo }) 
		EndIf  	
	ElseIf nOrdem == 6 //--"Data Saida+Hora Saida"
		aDados := aSort( aDados,,,{|x,y| DtoS(CtoD(x[4])) + x[5] < DtoS(CtoD(y[4])) + y[5]} )
		If !Empty(cCampo)
		    cCampo := Alltrim(cCampo)
		    nSeek  := Ascan( aDados ,{|x| PadR(x[4] + x[5],Len( cCampo )) == cCampo }) 
		EndIf  	
	EndIf

    If nSeek > 0
		oListBox:nAt := nSeek
	EndIf
	oListBox:UpStable()
	oListBox:Refresh()	
 
EndIf

RestArea(aArea)

Return Nil 
                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMS070Vei บAutor  ณCICERO J. SILVA     บ Data ณ  09.JUN.2009บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta padrao para o cadastro de Veiculos                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TMS070Vei()
Local lRet      := .T.
Local cAliasQry := ''
Local cQuery    := ''
Local aTitle    := {}
Local aItens    := {}
Local nSelec    := 0

AAdd( aTitle, RetTitle( 'DA3_COD' ) )
AAdd( aTitle, RetTitle( 'DA3_DESC' ) )
AAdd( aTitle, RetTitle( 'DA3_PLACA' ) )
AAdd( aTitle, RetTitle( 'DUT_DESCRI' ) )

//--Query para consistir Veiculo X Categoria
cQuery := "SELECT DA3.DA3_COD, DA3.DA3_PLACA, DA3.DA3_DESC, DUT.DUT_DESCRI "
cQuery += "FROM " + RetSQLTab('DA3') + ', ' + RetSQLTab('DUT') 
cQuery += "WHERE DA3.DA3_FILIAL = '" + xFilial('DA3') + "' AND "
cQuery += "      DA3.D_E_L_E_T_ = '' AND "
cQuery += "      DUT.DUT_FILIAL = '" + xFilial('DUT') + "' AND "
cQuery += "      DUT.DUT_CATVEI = '" + StrZero( MV_PAR08, Len( DUT->DUT_CATVEI ) ) + "' AND "
cQuery += "      DUT.DUT_TIPVEI = DA3.DA3_TIPVEI AND "
cQuery += "      DUT.D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)

//--Processa a Query...
cAliasQry := GetNextAlias()
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry )

If !(cAliasQry)->( Eof() )
	While !(cAliasQry)->( Eof() )
		AAdd( aItens, { 	(cAliasQry)->DA3_COD,;
								(cAliasQry)->DA3_DESC,;
								(cAliasQry)->DA3_PLACA,;
								(cAliasQry)->DUT_DESCRI } )
		
		(cAliasQry)->( DbSkip() )
	End
	(cAliasQry)->( DbCloseArea() )
Else
	HELP('',1,'TMSC07001')//"Nใo hแ veiculos para a categoria selecionada"
	lRet := .F.
Endif

If lRet

	nSelec := TmsF3Array( aTitle, aItens, 'Veiculos X Categorias', .F. )

	If nSelec <> 0
		VAR_IXB := aItens[nSelec,1]
		lRet    := .T.
	Else
		lRet    := .F.
	EndIf	
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMC70LFil บAutor  ณMicrosiga           บ Data ณ  06/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TMC70LFil()
	MV_PAR09 := Space(TamSX3("DA3_COD")[1])
	MV_PAR10 := Space(TamSX3("DA3_COD")[1])
Return .T.

