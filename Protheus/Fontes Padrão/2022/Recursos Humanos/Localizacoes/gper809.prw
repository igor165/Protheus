#INCLUDE "PROTHEUS.CH"            
#INCLUDE "GPER809.CH"      
#DEFINE   nColMax	2350   
#DEFINE   nLinMax	2900

/*
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������Ŀ��
���Fun��o    � GPER809  � Autor � Alceu Pereira         � Data � 12.03.10	         ���
������������������������������������������������������������������������������������Ĵ��
���Descri��o � Certificado de Retenciones por aportes al Sistema Privado de Pensiones���
������������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER809()                                                	         ���
������������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                       ���
������������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico - PERU                                              	     ���
������������������������������������������������������������������������������������Ĵ��
���             ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                    ���
������������������������������������������������������������������������������������Ĵ��
���Programador � Data   � FNC       �  Motivo da Alteracao 		                     ���
������������������������������������������������������������������������������������Ĵ��
���Erika K.    �06/07/10�014899/2010�Ajuste na impressao da verba de AFP - Prima.    ���
���Leandro Dr. �15/03/12�     TEQNXT�Ajuste na busca dos periodos. Gestao empresarial���
���Leandro Dr. �04/04/12�     TEQNXT�Ajuste na montagem do re. quando existe troca de���
���            �04/04/12�           �AFP.                                            ���
�������������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������������
*/

Function GPER809()   

Local cDesc1        := "" 
Local cDesc2        := "" 
Local cDesc3        := ""
Local cTit        	:= "Certificado de Retenciones por Aportes al Sistema Privado de Pensiones"

Local Cabec1        := ""
Local Cabec2        := ""
Local imprime       := .T.
Local aOrd   		:= {STR0006,STR0007,STR0008} //"Matricula"###"C.Custo"###"Nome"
Local cPerg 		:=	"GPER809"

Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 70
Private cTamanho    := "P"       
Private nomeprog    := "GPER809" 
Private nTipo       := 0
Private aReturn  	:= { 'STR0003',1,'STR0004',2,2,1,"",1 }   //Zebrado - Administracao

Private nLastKey    := 0
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "GPER809" 
Private cString 	:= "SRA"   

Private cPict1    	:= "9999999,999"  
Private cPict2		:= "999.99"
Private cNomEmp   	:= ""			//Nome da Empresa 
Private cCidade   	:= ""			//Cidade da Empresa 
Private cCgc 	  	:= ""			//CGC da Empresa 	

Private nValCVac 	:= 0          
Private nValGrat 	:= 0		
Private nValHabB 	:= 0		
Private nValVca  	:= 0          
Private nValTot1 	:= 0 
Private nValTot2 	:= 0  
Private nValRem		:= 0
Private nPerSnP		:= 0
Private nPerPen		:= 0 
Private nValPen		:= 0  
Private nPerCom		:= 0 
Private nValCom		:= 0 
Private nPerSeg		:= 0
Private nValSeg		:= 0

Private cFilialAnt 	:= ""
Private aPerAberto	:= {}
Private aPerFechado	:= {}
Private aPerTodos	:= {}
Private nOrdem 
Private aCodFol   	:= {}
Private aInfo  	  	:= {}            
Private cNumPgtIni	:= Space( GetSx3Cache("RD_SEMANA", "X3_TAMANHO") )
Private cNumPgtFim	:= Replicate( "9", Len( cNumPgtIni ) )
Private cAno		:= ""
Private nTipo		:= 0
Private cNomemp		:= ""
Private aNomEnt     := {}                

Private cFilDe      := ""
Private cFilAte     := ""              
Private cMatDe      := ""
Private cMatAte     := ""
Private cNomeDe		:= ""
Private cNomeAte	:= ""
Private cCustoDe    := ""
Private cCustoAte   := ""
Private cSit        := ""
Private cCat        := ""
Private nLin1 		:= 150          
Private nLin 		:= 300                            
Private nLinS 		:= 70
Private aVerbasAcum := {}
Private aEntidade   := {}  

Private oFont07, oFont08, oFont10, oFont10n, oFont12, oFont15 , oFont16, oFont21 
Private oPrint  

If nLastKey == 27
	Return
Endif

Pergunte(cPerg,.F.)

//wnrel:=SetPrint(cString,NomeProg,cPerg,@cTit,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,cTamanho,,.T.)   
wnrel:=SetPrint(cString,wnrel,cPerg,@cTit,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,cTamanho,,.T.)


If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

/*
��������������������������������������������������������������Ŀ
� Variaveis utilizadas para parametros                         �
� mv_par01        //  Ano?      					           � 
� mv_par02        //  Filial De?					           �
� mv_par03        //  Filial Ate?                              |
� mv_par04        //  Matricula De?                            �
� mv_par05        //  Matricula Ate?                           �
� mv_par06        //  Nome De?                      		   �
� mv_par07        //  Nome Ate?                     		   �
� mv_par08        //  Centro de Custo De?                      �
� mv_par09        //  Centro de Custo Ate?                     �
� mv_par10        //  Situacoes a Imp.?                        �
� mv_par11        //  Categorias a Imp.?                       �
� mv_par12        //  Tipo?                                    �
����������������������������������������������������������������*/

cAno		:= mv_par01    
cFilDe      := mv_par02 
cFilAte     := mv_par03
cMatDe      := mv_par04
cMatAte     := mv_par05
cNomeDe		:= mv_par06
cNomeAte	:= mv_par07
cCustoDe    := mv_par08
cCustoAte   := mv_par09
cSit        := mv_par10
cCat        := mv_par11
nTipo		:= mv_par12

//����������������������������������������������������
//�Define a ordem do Index que ser� usada pelo o SRA.�
//����������������������������������������������������
If nOrdem == 1
	dbSetOrder(1)
	dbSeek(cFilDe + cMatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_MAT"
	cFim     := cFilAte + cMatAte
ElseIf nOrdem == 2
	dbSetOrder(2)
	dbSeek(cFilDe + cCustoDe + cMatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
	cFim     := cFilAte + cCustoAte + cMatAte
ElseIf nOrdem == 3
	dbSetOrder(3)
	dbSeek(cFilDe + cNomeDe + cMatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
	cFim     := cFilAte + cNomeAte + cMatAte
Endif

oPrint := TMSPrinter():New("Rel") //Relatorio    

If ! oPrint:IsPrinterActive()
	oPrint:Setup()			//-- Seleciona a impressora
	If ! oPrint:IsPrinterActive()
		MsgAlert( OemToAnsi(STR0024), OemToAnsi(STR0025)) //Verifique a configuracao da impressora! ## Atencao
		Return(Nil)
	Endif
Endif

oPrint:SetPortrait()

Titulo := "Certificado de Retenciones por Aportes al Sistema Privado de Pensiones"

//RptStatus({|lEnd| IMPREL()},"T�tulo") 
RptStatus({|lEnd| IMPREL(@lEnd )},Capital(Titulo))   

	oPrint:Preview()       
                                                                       
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IMPREL    �Autor  �Alceu Pereira       � Data �  01/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
 
Static Function IMPREL(lEnd) 

Local cAcessaSRA	:= &( " { || " + ChkRH( "GPER809" , "SRA", "2" ) + " } " )     
Local nSavRec
Local nSavOrdem  
Local cFim			:= "" 
Local cFilAnt		:= "" 
Local nAux, nPos	:= 0     
Local aCodFol   	:= {}

/*
��������������������������������������������������������������Ŀ
� Variaveis para controle em ambientes TOP.                    �
����������������������������������������������������������������*/ 
Local aPerAberto	:= aPerFechado := aPerTodos := {}
Local aPerAbGan		:= aPerFeGan   := aPerTdGan	 := {} 
Local cPeriodoAnt := "!!"  
Local cNumPgtIni	:= Space( GetSx3Cache("RD_SEMANA", "X3_TAMANHO") )
Local cNumPgtFim	:= Replicate( "9", Len( cNumPgtIni ) )

	//��������������������������������������������������������������Ŀ
	//� Carrega Regua de Processamento                               �
	//����������������������������������������������������������������

oFont07	:= TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
oFont08	:= TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)		//negrito 
oFont10	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
oFont10n:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)
oFont12	:= TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)		//Normal s/negrito
oFont15	:= TFont():New("Courier New",15,15,,.T.,,,,.T.,.F.)
		
SetRegua(SRA->(RecCount()))
cFilAnt	:= SRA->RA_FILIAL

dbGoTop()
While !("SRA")->( Eof() )
		
		//��������������������������������������������������������������Ŀ
		//� Movimenta Regua de Processamento                             �
		//����������������������������������������������������������������
	 	IncRegua() 
	     
		If lEnd
			@Prow()+1,0 PSAY cCancel
			Exit
	    Endif
	
	If SRA->RA_FILIAL < cFilDe .Or. SRA->RA_FILIAL > cFilAte
		SRA->(dbSkip())
		Loop
	Endif    
	
	If (SRA->RA_NOME < cNomeDe) .Or. (SRA->RA_NOME > cNomeAte) .Or. ;
		(SRA->RA_MAT < cMatDe) .Or. (SRA->RA_MAT > cMatAte)  .Or. ;
		(SRA->RA_CC < cCustoDe)   .Or. (SRA->RA_CC > cCustoAte)
		SRA->(dbSkip())
		Loop
	EndIf
	
	fLimpaVarRel()	   // Limpa vari�veis  utilizadas no corpo do relat�rio     

	cFilialAnt := xFilial('RCH',SRA->RA_FILIAL)
		
	RetPerAno(cFilialAnt, @aPerAberto, @aPerFechado, @aPerTodos,cAno) 
	
	If Len(aPerFechado) < 1
		cFilialAnt:= xFilial('RCH')
		RetPerAno(cFilialAnt, @aPerAberto, @aPerFechado, @aPerTodos, cAno)
	Endif    
	
 	If Len(aPerFechado) < 1  
 		SRA->( dbSkip() )
 	   	Loop
 	Endif
      
	If Len(aVerbasAcum) < 1  
 		SRA->( dbSkip() )
 	   	Loop
	Endif	

	cProcesso := SRA->RA_PROCES 			

fBuscaDadosEmp()   

fBuscaEntidades()

fSomaValores()   

fMontaArray()                       

	If lAbortPrint
		@nLin,00 PSAY STR0005
   		Exit
	Endif 
        
	GeraRel() //gera primeira via se precisar gerar duas vias chamar novamente esta funcao

	SRA->(dbSkip())	
End	
		                               
	If lQuery
		If Select(SRA) > 0
		 (SRA)->(dbCloseArea())
		Endif
	EndIf		
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GeraRel   �Autor  �Alceu Pereirai      � Data �  12/20/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
 */        

Static Function GeraRel()

//����������������������������������������������������������������������������Ŀ
//�                                                                            |
//������������������������������������������������������������������������������ 
oPrint:StartPage() 			//Inicia uma nova pagina   

//oPrint:Box ( 0020, 0035, 0380, 0400 ) //BOX 
oPrint:say ( nLin1, 110, "Certificado de Retenciones por Aportes al Sistema Privado de Pensiones", oFont15 )

oPrint:say ( nLin, 60, "Exercicio"+Space(1)+cAno+Space(1)+"- Articulo 2�. De la Ley 27605" , oFont12 )

nLin := nLin + nLinS                           

oPrint:say ( nLin, 60, "Exercicio Gravable - "+Space(1)+cAno, oFont12 )    

nLin := nLin + nLinS

oPrint:say ( nLin, 60, "Razon Social Del Empleador: " +cNomEmp+Space(1)+"RUC:"+Space(1)+cCgc,oFont12 )
                    
nLin := nLin + nLinS

oPrint:say ( nLin, 60, "Certifica", oFont12)

nLin := nLin + nLinS

oPrint:say ( nLin, 60, "Que a Don (Dona) "+ SRA->RA_NOME+Space(1)+"con DNI Nro. "+SRA->RA_RG+".",oFont12 )

nLin := nLin + nLinS

oPrint:say ( nLin, 60, "Se le ha retenido por concepto de aportes al Sistema de Pensiones sobre las",oFont12 )

nLin := nLin + nLinS

oPrint:say ( nLin, 60, "siguientes remuneraciones percebidas en el periodo de: Del 01/01/"+cAno+" al",oFont12 )                     

nLin := nLin + nLinS

oPrint:say ( nLin, 60, "31/12/"+cAno+".",oFont12 )   

nLin := nLin + (nLinS * 2)

oPrint:say ( nLin, 60, "1. Rentas Brutas" , oFont12)    

nLin := nLin + nLinS  

//			Linha   Col ini  Altura   Col Fim
oPrint:box(nLin   , 60     , 1500    , 1200   )  

oPrint:say ( nLin, 65, "Concepto" , oFont12)                   

oPrint:line( nLin, 600, 1500, 600 )   //vertical   

oPrint:say ( nLin, 630, "Rem. Aseg. S/." , oFont12)                           
	
nLin := nLin + nLinS    

oPrint:say ( nLin, 65, "Comp. Vacaciones" , oFont12)                           

oPrint:say ( nLin, 630, Trans(nValCVac,cPict1), oFont12)                           

oPrint:Line(nLin,60, nLin, 1200)	  //horizontal  

nLin := nLin + nLinS  

oPrint:say ( nLin, 65, "Gratificacion" , oFont12)                           

oPrint:say ( nLin, 630, Trans(nValGrat,cPict1) , oFont12)                           

oPrint:Line(nLin,60, nLin, 1200)	  //horizontal  

nLin := nLin + nLinS  

oPrint:say ( nLin, 65, "Haber Basico" , oFont12)                           

oPrint:say ( nLin, 630, Trans(nValHabB,cPict1) , oFont12)                           

oPrint:Line(nLin,60, nLin, 1200)	  //horizontal  

nLin := nLin + nLinS  

oPrint:say ( nLin, 65, "Vacaciones" , oFont12)                           

oPrint:say ( nLin, 630, Trans(nValVca,cPict1) , oFont12)                           

oPrint:Line(nLin,60, nLin, 1200)	  //horizontal   

nLin := nLin + nLinS  

oPrint:Line(nLin,60, nLin, 1200)	  //horizontal  

nLin := nLin + nLinS    

oPrint:say ( nLin, 65, "Rem. Bruta Total" , oFont12)                           

oPrint:say ( nLin, 630, Trans(nValTot1,cPict1) , oFont12)                           

oPrint:Line(nLin,60, nLin, 1200)	  //horizontal  
			
nLin := nLin + (nLinS  *2 )
			            
oPrint:say ( nLin, 60, "(1) Remuneraciones no asegurable, afecta a solo a las retenciones de renta de", oFont12)

nLin := nLin + nLinS

oPrint:say ( nLin, 60, "5� categoria.", oFont12)     

fCriaQB()

nLin := nLin + nLinS

oPrint:say ( nLin, 60, "RETENCI�N EFECTUADA DURANTE EL A�O"+Space(1)+cAno, oFont12)     

nLin := nLin + (nLinS * 2)

oPrint:say ( nLin, 60, AllTrim(cCidade) + ","+ cValToChar(Day(dDataBase))+ Space(1) + "de" + Space(1) + AllTrim(MesExtenso(dDatabase)) + Space(1) + "del" + Space(1) + AllTrim(cAno)+"." ,oFont12)

nLin := nLin + (nLinS * 2)

oPrint:say ( nLin, 60,"Firma del representa legal", oFont12) 

nLin := nLin + (nLinS * 2)

oPrint:say ( nLin, 60,"Firma del Trabajador", oFont12)

nLin := nLin + (nLinS * 2) 

oPrint:EndPage()
                         
Return         
 


/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    � fBuscaDadosEmp� Autor � Alceu Pereira         � Data � 12.03.10  ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Busca dados da empresa                                           ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � fBuscaDadosEmp()                                            	    ���
�������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                  ���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico - PERU                                                  ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
*/
Static Function fBuscaDadosEmp()

//Busca dados da empresa 
fInfo(@aInfo,Sra->Ra_Filial)
cNomEmp  := aInfo[3]  
cCidade  := aInfo[05]   
cCgc     := aInfo[8]
//

Return

/*                                           
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    � fLimpaVarRel  � Autor � Alceu Pereira         � Data � 12.03.10  ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Limpa vari�veis usadas no While do SRA                           ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � fLimpaVarRel()                                            	    ���
�������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                  ���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico - PERU                                                  ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
*/

Static Function fLimpaVarRel()

nValCVac  := 0          
nValGrat  := 0		
nValHabB  := 0		
nValVca   := 0          
nValTot1  := 0 
nValTot2  := 0  
nValRem	  := 0
nPerSnP	  := 0
nPerPen	  := 0 
nValPen	  := 0  
nPerCom	  := 0 
nValCom	  := 0 
nPerSeg	  := 0
nValSeg	  := 0 
nLin1 		:= 150          
nLin 		:= 300                            
nLinS 		:= 70    
aPerAberto	:= {}
aPerFechado	:= {}
aPerTodos	:= {}
aNomEnt     := {}                
aVerbasAcum := {}
aEntidade   := {}

Return

/*                                           
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    � fSomaValores  � Autor � Alceu Pereira         � Data � 12.03.10  ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Soma os valores									                ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � fSomaValores()                                            	    ���
�������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                  ���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico - PERU                                                  ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
*/
Static Function fSomaValores()  

Local nCont := 0 

If (len(aVerbasAcum)>=1)                                      
	For nCont:= 1 to len(aVerbasAcum)
		If	aVerbasAcum[nCont,1] == fGetCodFol("072")     
   			nValCVac += aVerbasAcum[nCont,3] 
   		ElseIf PosSrv( aVerbasAcum[nCont,1], SRA->RA_FILIAL, "RV_TPREMU" ) $ "4" .AND. PosSrv( aVerbasAcum[nCont,1], SRA->RA_FILIAL, "RV_REFAPOR" ) $ "1"			
			nValGrat += aVerbasAcum[nCont,3]					
		Elseif aVerbasAcum[nCont,1] == fGetCodFol("031") .OR. aVerbasAcum[nCont,1] == fGetCodFol("032") .OR. aVerbasAcum[nCont,1] == fGetCodFol("033") .OR. aVerbasAcum[nCont,1] == fGetCodFol("217") .OR. aVerbasAcum[nCont,1] == fGetCodFol("218") .OR. aVerbasAcum[nCont,1] == fGetCodFol("219") .OR. aVerbasAcum[nCont,1] == fGetCodFol("220") .OR. aVerbasAcum[nCont,1] == fGetCodFol("1054")       
   			nValHabB += aVerbasAcum[nCont,3]		   
		Elseif PosSrv( aVerbasAcum[nCont,1], SRA->RA_FILIAL, "RV_REFFER" ) $ "S" .AND. PosSrv( aVerbasAcum[nCont,1], SRA->RA_FILIAL, "RV_REFAPOR" ) $ "1"			
			nValVca += aVerbasAcum[nCont,3] 		     		
   		Endif
	Next
Endif 

nValTot1 := (nValCVac + nValGrat + nValHabB + nValVca) 

Return  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RetPerAno �Autor  �Alceu Pereira       � Data �  12.03.10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function RetPerAno(cFilAux, aPerAberto, aPerFechado, aPerTodos, cAnoPar)

Local nCont                                                          
Local nAux                                                                
Local cRoteiro := ""    
Local cMes  := "01"
Local aPerFe := {}
Local aPerAb := {}
                                   
cProcesso := SRA->RA_PROCES

For nCont := 1 to 12 

	fRetPerComp( cMes , cAnoPar , cFilAux , SRA->RA_PROCES ,cRoteiro, @aPerAb , @aPerFe , @aPerTodos )  
       
	//guarda o conteudo de aPerFech, pois a cada chamada a funcao fRetPerComp zera os arrays   
	If !len(aPerFe) < 1
		For nAux:= 1 to len(aPerFe)
			aAdd(aPerFechado, aPerFe[nAux])            
	 	Next nAux
	Endif  
	
	cMes:= Right(StrZero((Val(cMes)+1)),2)
	
Next nCont   
 
If Len(aPerFechado) >= 1 

	If len(aPerFechado) >= 1
		aVerbasAcum := fBuscaAcmPer(,,,,,aPerFechado[1][1],aPerFechado[len(aPerFechado)][1],cNumPgtIni,cNumPgtFim,,.T.)
	Endif

Endif

Return 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fCriaQB      �Autor  �Alceu Pereira     � Data �  12.03.10  ���
�������������������������������������������������������������������������͹��
���Desc.     �Imprimir o quadro com as Entidades                          ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function fCriaQB(nLinB)    

Local nCont   	  := 0
Local nCont1   	  := 0
Local nCont2	  := 0 	
Local nQtdLin 	  := 0
Local nQtdLinEnt  := 0              
Local nQtdQuad 	  := 1 
Local nLinComeco  := Len(aEntidade) + 1
Local lVerif      := .T.   

For nCont := Len(aEntidade) to 1 Step - 1  
	nLinComeco--
	If nCont - 1 > 0 .AND. aEntidade[nCont][1] != aEntidade[nCont-1][1]
			aEntidade [nCont][12]  := ((nCont-1) - (nCont)) * - 1  
   	    	aEntidade [nCont][13]  := nLinComeco
	Else
		nQtdLin++  
		aEntidade [nCont][12]  := nQtdLin
   	    aEntidade [nCont][13]  := nLinComeco
	Endif
	
	
/*	If nCont > 1 .AND. aEntidade[nCont][1] != aEntidade[nCont-1][1] // Verifica a mudanca de entidade nos meses
		nQtdQuad := nQtdQuad + 1 
		For nCont1 := nLinComeco To nCont   
	   	    aEntidade [nCont1][12]  := nQtdLinEnt //Adiciona no array de entidades a quantidade de linhas que cada entidade deve ser impressa	
   	   	    aEntidade [nCont1][13]  := nLinComeco
   	   	    nCont2 := nCont1
		Next
			nLinComeco := 0   
			nQtdLinEnt := 1            
			nLinComeco := nCont 
   	Else
   		If lVerif == .T.  
   			nLinComeco := nCont         // Indica em que linha comecou a entidade dentro do array aEmpresa
   		Endif  
		nQtdLinEnt := nQtdLinEnt + 1    //Indica quantas linhas (meses) a entidade deve ser impressa 
		lVerif := .F.
 		aEntidade [nCont][12] := nQtdLinEnt 
 		aEntidade [nCont][13] := nLinComeco
	Endif	
		
		/*If nCont == nQtdLin .AND. aEntidade[nCont][1] == aEntidade[nCont-1][1]
		 	If nCont1 > 1
		 		aEntidade [nCont2-1][12] := nQtdLinEnt 
		 		aEntidade [nCont2-1][13] := nLinComeco
		 		aEntidade [nCont2-1][12]   := nQtdLinEnt 
		 		aEntidade [nCont2-1][13]   := nLinComeco		   
			Endif   
		Elseif nCont == nQtdLin
		 	aEntidade [nCont2][12] := 1	
		 	aEntidade [nCont2][13] := nLinComeco       
		Else
		 	aEntidade [nCont][12] := 1	
		 	aEntidade [nCont][13] := nLinComeco       		
		Endif*/
   //	Endif	                                
Next         
                                      
lVerif := .T.   

nQtdLin := Len(aEntidade)    

For nCont := 1  to nQtdLin

			nLin := nLin + (nLinS  * 2) 	
	
			oPrint:say ( nLin, 60, aEntidade[nCont][1], oFont12)    
		
			nLin := nLin + nLinS    
           
			oPrint:Line(nLin,60, nLin, 2100)	  //horizontal  
			
		   	oPrint:Line(nLin , 60 , nLin + (nLinS * (aEntidade[nCont][12] + 1) ) , 60)	//1a vertical  
				
			oPrint:say ( nLin, 68, "Mes", oFont12)      		
		
			oPrint:Line(nLin , 300 , nLin + (nLinS * (aEntidade[nCont][12] + 1) ) , 300)	//2a vertical  
		                                     
			oPrint:say ( nLin, 308, "Remuneracion", oFont12)   
			
			oPrint:Line(nLin , 640 , nLin + (nLinS * (aEntidade[nCont][12] + 1) ) , 640)	 //3a vertical  
		
			oPrint:say ( nLin, 648, "Sist. Nac. Pens.", oFont12)      						

			oPrint:Line(nLin , 1080 , nLin + (nLinS * (aEntidade[nCont][12] + 1) ) , 1080)	 //4a vertical  
		
			oPrint:say ( nLin, 1088, "Pens. Jub.", oFont12)      				
		
			oPrint:Line(nLin , 1420 , nLin + (nLinS * (aEntidade[nCont][12] + 1) ) , 1420) //5a vertical  
		
			oPrint:say ( nLin, 1428, "Com. Porc", oFont12)      				
		
			oPrint:Line(nLin , 1760 , nLin + (nLinS * (aEntidade[nCont][12] + 1) ) , 1760) //6a vertical  
		
			oPrint:say ( nLin, 1768, "Seg. Inv.", oFont12)      				
		
			oPrint:Line(nLin , 2100 , nLin + (nLinS * (aEntidade[nCont][12] + 1) ) , 2100) //7a vertical  */
			
			nLin := nLin + nLinS
			
			oPrint:Line(nLin,60, nLin, 2100)	  //horizontal  	
			
			oPrint:Line(nLin , 860 , nLin + (nLinS * (aEntidade[nCont][12]) ) , 860) //1a vertical  do meio*/
			                                                                                                 
			oPrint:Line(nLin , 1250 , nLin + (nLinS * (aEntidade[nCont][12]) ) , 1250) //2a vertical  do meio*/
			
			oPrint:Line(nLin , 1590 , nLin + (nLinS * (aEntidade[nCont][12]) ) , 1590) //3a vertical  do meio*/
			
			oPrint:Line(nLin , 1930 , nLin + (nLinS * (aEntidade[nCont][12]) ) , 1930) //4a vertical  do meio*/
		    
			For nCont1 := 1 to aEntidade[nCont][12]  
			//{"Entidade11" , "Dezembro" , 0.00   , 3.89   , 1000000 , 10   , 2000000 , 6.25   , 3000000 , 0.88    , 60.30    , 0          , 0      ,   "N"  })  
		   		oPrint:say ( nLin, 60,   aEntidade[nCont][2] , oFont12) // Mes
								
				oPrint:say ( nLin, 310,  StrTran(AllTrim(Trans(aEntidade[nCont][3],cPict1)),",",".")  , oFont10) //Valor 						   		
		   		oPrint:say ( nLin, 640,  StrTran(AllTrim(Trans(aEntidade[nCont][4],cPict2)),",",".")  , oFont10) //Perc.
		   		oPrint:say ( nLin, 900,  StrTran(AllTrim(Trans(aEntidade[nCont][5],cPict1)),",",".")  , oFont10)  //Valor
		   	  	oPrint:say ( nLin, 1110, StrTran(AllTrim(Trans(aEntidade[nCont][6],cPict2)),",",".")  , oFont10)  //Perc
		   	  	oPrint:say ( nLin, 1260, StrTran(AllTrim(Trans(aEntidade[nCont][7],cPict1)),",",".")  , oFont10)  //Valor/ 
		   	    oPrint:say ( nLin, 1430, StrTran(AllTrim(Trans(aEntidade[nCont][8],cPict2)),",",".")  , oFont10)  //Perc/ 
		   	    oPrint:say ( nLin, 1600, StrTran(AllTrim(Trans(aEntidade[nCont][9],cPict1)),",",".")  , oFont10)  //Valor/ 
   		   	    oPrint:say ( nLin, 1780, StrTran(AllTrim(Trans(aEntidade[nCont][10],cPict2)),",",".") , oFont10)  //Perc/  
   		   	    oPrint:say ( nLin, 1950, StrTran(AllTrim(Trans(aEntidade[nCont][11],cPict1)),",",".")  , oFont10)  //Valor/ 
		   		                                    
				nCont += 1
		   		nLin  := nLin + nLinS
		   		                                  
				oPrint:Line(nLin,60, nLin, 2100)	  //horizontal  
			Next
			If nCont < nQtdLin .or. ( nCont == nQtdLin .and. ( aEntidade[nCont][12] > 0 ) )
				nCont -= 1    
			Endif
Next

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fMontaArray  �Autor  �Alceu Pereira     � Data �  12.03.10  ���
�������������������������������������������������������������������������͹��
���Desc.     �Montar array de dados para serem impressos                  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                       

Static Function fMontaArray()
Local nCont := 0  
Local cEntidade := ""  

//Corpo do array aEntidade
//Aadd( aEntidade , {"Entidade11" , "Dezembro" , 0.00   , 3.89   , 1000000 , 10   , 2000000 , 6.25   , 3000000 , 0.88    , 60.30    , 0          , 0      ,   "N"  }) 

For nCont := 1 to 12 
	Aadd( aEntidade , {""  ,"" , 0, 0  , 0, 0 , 0, 0 , 0 , 0 , 0, 0, 0 }) 
Next 	

For nCont := 1 to Len(aVerbasAcum)
	If	Right((AVERBASACUM[nCont][4]),02) == "01"
			cEntidade := VerEntidadeMes("01")
			aEntidade [1] [1] := cEntidade  //Entidade   			
			If aEntidade [1] [2] != STR0012 
				aEntidade [1] [2] := STR0012  //Janeiro   
			Endif
		If aVerbasAcum[nCont,1] == fGetCodFol("1040") 
			aEntidade [1] [3] += aVerbasAcum[nCont,3]    //Valor 
   		Elseif aVerbasAcum[nCont,1] == fGetCodFol("1148") .OR. aVerbasAcum[nCont,1] == fGetCodFol("1116") .OR. aVerbasAcum[nCont,1] == fGetCodFol("859") 	
			If SRA->RA_JUBILAC == "S"
				aEntidade [1] [4] += aVerbasAcum[nCont,2]    //Porcentagem 
   				aEntidade [1] [5] += aVerbasAcum[nCont,3]    //Valor 				
        	Else
				aEntidade [1] [6] += aVerbasAcum[nCont,2]    //Porcentagem 
	   			aEntidade [1] [7] += aVerbasAcum[nCont,3]    //Valor 
	   		Endif	
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1146") 
			aEntidade [1] [8] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [1] [9] += aVerbasAcum[nCont,3]    //Valor 
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1145") 
			aEntidade [1] [10] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [1] [11] += aVerbasAcum[nCont,3]    //Valor 
	   	Endif
	ElseIf	Right((AVERBASACUM[nCont][4]),02) == "02"
			cEntidade := VerEntidadeMes("02")
			aEntidade [2] [1] := cEntidade  //Entidade   			
			If aEntidade [2] [2] != STR0013
				aEntidade [2] [2] := STR0013  //Fevereiro   
			Endif	
		If aVerbasAcum[nCont,1] == fGetCodFol("1040") 
			aEntidade [2] [3] += aVerbasAcum[nCont,3]    //Valor 
   		Elseif aVerbasAcum[nCont,1] == fGetCodFol("1148") .OR. aVerbasAcum[nCont,1] == fGetCodFol("1116") .OR. aVerbasAcum[nCont,1] == fGetCodFol("859") 	
			If SRA->RA_JUBILAC == "S"
				aEntidade [2] [4] += aVerbasAcum[nCont,2]    //Porcentagem 
   				aEntidade [2] [5] += aVerbasAcum[nCont,3]    //Valor 				
        	Else
				aEntidade [2] [6] += aVerbasAcum[nCont,2]    //Porcentagem 
	   			aEntidade [2] [7] += aVerbasAcum[nCont,3]    //Valor 
	   		Endif	
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1146") 
			aEntidade [2] [8] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [2] [9] += aVerbasAcum[nCont,3]    //Valor 
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1145") 
			aEntidade [2] [10] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [2] [11] += aVerbasAcum[nCont,3]    //Valor 
	   	Endif	   	
	ElseIf	Right((AVERBASACUM[nCont][4]),02) == "03"    
			cEntidade := VerEntidadeMes("03")
			aEntidade [3] [1] := cEntidade  //Entidade   						
			If aEntidade [3] [2] != STR0014 
				aEntidade [3] [2] := STR0014  //Marco   
			Endif	
		If aVerbasAcum[nCont,1] == fGetCodFol("1040") 
			aEntidade [3] [3] += aVerbasAcum[nCont,3]    //Valor 
   		Elseif aVerbasAcum[nCont,1] == fGetCodFol("1148") .OR. aVerbasAcum[nCont,1] == fGetCodFol("1116") .OR. aVerbasAcum[nCont,1] == fGetCodFol("859") 	
			If SRA->RA_JUBILAC == "S"
				aEntidade [3] [4] += aVerbasAcum[nCont,2]    //Porcentagem 
   				aEntidade [3] [5] += aVerbasAcum[nCont,3]    //Valor 				
        	Else
				aEntidade [3] [6] += aVerbasAcum[nCont,2]    //Porcentagem 
	   			aEntidade [3] [7] += aVerbasAcum[nCont,3]    //Valor 
	   		Endif	
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1146") 
			aEntidade [3] [8] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [3] [9] += aVerbasAcum[nCont,3]    //Valor 
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1145") 
			aEntidade [3] [10] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [3] [11] += aVerbasAcum[nCont,3]    //Valor 
	   	Endif	   	
	ElseIf	Right((AVERBASACUM[nCont][4]),02) == "04"    
			cEntidade := VerEntidadeMes("04")
			aEntidade [4] [1] := cEntidade  //Entidade   						
			If aEntidade [4] [2] != STR0015 
				aEntidade [4] [2] := STR0015  //Abril   
			Endif	
		If aVerbasAcum[nCont,1] == fGetCodFol("1040") 
			aEntidade [4] [3] += aVerbasAcum[nCont,3]    //Valor 
   		Elseif aVerbasAcum[nCont,1] == fGetCodFol("1148") .OR. aVerbasAcum[nCont,1] == fGetCodFol("1116") .OR. aVerbasAcum[nCont,1] == fGetCodFol("859") 	
			If SRA->RA_JUBILAC == "S"
				aEntidade [4] [4] += aVerbasAcum[nCont,2]    //Porcentagem 
   				aEntidade [4] [5] += aVerbasAcum[nCont,3]    //Valor 				
        	Else
				aEntidade [4] [6] += aVerbasAcum[nCont,2]    //Porcentagem 
	   			aEntidade [4] [7] += aVerbasAcum[nCont,3]    //Valor 
	   		Endif	
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1146") 
			aEntidade [4] [8] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [4] [9] += aVerbasAcum[nCont,3]    //Valor 
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1145") 
			aEntidade [4] [10] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [4] [11] += aVerbasAcum[nCont,3]    //Valor 
	   	Endif	   	
	ElseIf	Right((AVERBASACUM[nCont][4]),02) == "05"    
			cEntidade := VerEntidadeMes("05")
			aEntidade [5] [1] := cEntidade  //Entidade   						
			If aEntidade [5] [2] != STR0016 
				aEntidade [5] [2] := STR0016  //Maio   
			Endif	
		If aVerbasAcum[nCont,1] == fGetCodFol("1040") 
			aEntidade [5] [3] += aVerbasAcum[nCont,3]    //Valor 
   		Elseif aVerbasAcum[nCont,1] == fGetCodFol("1148") .OR. aVerbasAcum[nCont,1] == fGetCodFol("1116") .OR. aVerbasAcum[nCont,1] == fGetCodFol("859") 	
			If SRA->RA_JUBILAC == "S"
				aEntidade [5] [4] += aVerbasAcum[nCont,2]    //Porcentagem 
   				aEntidade [5] [5] += aVerbasAcum[nCont,3]    //Valor 				
        	Else
				aEntidade [5] [6] += aVerbasAcum[nCont,2]    //Porcentagem 
	   			aEntidade [5] [7] += aVerbasAcum[nCont,3]    //Valor 
	   		Endif	
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1146") 
			aEntidade [5] [8] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [5] [9] += aVerbasAcum[nCont,3]    //Valor 
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1145") 
			aEntidade [5] [10] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [5] [11] += aVerbasAcum[nCont,3]    //Valor 
	   	Endif	   	
	ElseIf	Right((AVERBASACUM[nCont][4]),02) == "06"    
			cEntidade := VerEntidadeMes("06")
			aEntidade [6] [1] := cEntidade  //Entidade   						
			If aEntidade [6] [2] != STR0017 
				aEntidade [6] [2] := STR0017  //Junho   
			Endif	
		If aVerbasAcum[nCont,1] == fGetCodFol("1040") 
			aEntidade [6] [3] += aVerbasAcum[nCont,3]    //Valor 
   		Elseif aVerbasAcum[nCont,1] == fGetCodFol("1148") .OR. aVerbasAcum[nCont,1] == fGetCodFol("1116") .OR. aVerbasAcum[nCont,1] == fGetCodFol("859") 	
			If SRA->RA_JUBILAC == "S"
				aEntidade [6] [4] += aVerbasAcum[nCont,2]    //Porcentagem 
   				aEntidade [6] [5] += aVerbasAcum[nCont,3]    //Valor 				
        	Else
				aEntidade [6] [6] += aVerbasAcum[nCont,2]    //Porcentagem 
	   			aEntidade [6] [7] += aVerbasAcum[nCont,3]    //Valor 
	   		Endif	
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1146") 
			aEntidade [6] [8] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [6] [9] += aVerbasAcum[nCont,3]    //Valor 
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1145") 
			aEntidade [6] [10] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [6] [11] += aVerbasAcum[nCont,3]    //Valor 
	   	Endif
	ElseIf	Right((AVERBASACUM[nCont][4]),02) == "07"    
			cEntidade := VerEntidadeMes("07")
			aEntidade [7] [1] := cEntidade  //Entidade   						
			If aEntidade [7] [2] != STR0018 
				aEntidade [7] [2] := STR0018  //Julho   
			Endif	
		If aVerbasAcum[nCont,1] == fGetCodFol("1040") 
			aEntidade [7] [3] += aVerbasAcum[nCont,3]    //Valor 
   		Elseif aVerbasAcum[nCont,1] == fGetCodFol("1148") .OR. aVerbasAcum[nCont,1] == fGetCodFol("1116") .OR. aVerbasAcum[nCont,1] == fGetCodFol("859") 	
			If SRA->RA_JUBILAC == "S"
				aEntidade [7] [4] += aVerbasAcum[nCont,2]    //Porcentagem 
   				aEntidade [7] [5] += aVerbasAcum[nCont,3]    //Valor 				
        	Else
				aEntidade [7] [6] += aVerbasAcum[nCont,2]    //Porcentagem 
	   			aEntidade [7] [7] += aVerbasAcum[nCont,3]    //Valor 
	   		Endif	
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1146") 
			aEntidade [7] [8] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [7] [9] += aVerbasAcum[nCont,3]    //Valor 
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1145") 
			aEntidade [7] [10] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [7] [11] += aVerbasAcum[nCont,3]    //Valor 
	   	Endif	   		   	
	ElseIf	Right((AVERBASACUM[nCont][4]),02) == "08"    
			cEntidade := VerEntidadeMes("08")
			aEntidade [8] [1] := cEntidade  //Entidade   									
			If aEntidade [8] [2] != STR0019
				aEntidade [8] [2] := STR0019  //Agosto   
			Endif	
		If aVerbasAcum[nCont,1] == fGetCodFol("1040") 
			aEntidade [8] [3] += aVerbasAcum[nCont,3]    //Valor 
   		Elseif aVerbasAcum[nCont,1] == fGetCodFol("1148") .OR. aVerbasAcum[nCont,1] == fGetCodFol("1116") .OR. aVerbasAcum[nCont,1] == fGetCodFol("859") 	
			If SRA->RA_JUBILAC == "S"
				aEntidade [8] [4] += aVerbasAcum[nCont,2]    //Porcentagem 
   				aEntidade [8] [5] += aVerbasAcum[nCont,3]    //Valor 				
        	Else           
				aEntidade [8] [6] += aVerbasAcum[nCont,2]    //Porcentagem 
	   			aEntidade [8] [7] += aVerbasAcum[nCont,3]    //Valor 
	   		Endif	
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1146") 
			aEntidade [8] [8] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [8] [9] += aVerbasAcum[nCont,3]    //Valor 
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1145") 
			aEntidade [8] [10] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [8] [11] += aVerbasAcum[nCont,3]    //Valor 
	   	Endif	   	
	ElseIf	Right((AVERBASACUM[nCont][4]),02) == "09"    
			cEntidade := VerEntidadeMes("09")
			aEntidade [9] [1] := cEntidade  //Entidade   												
			If aEntidade [9] [2] != STR0020
				aEntidade [9] [2] := STR0020  //Setembro   
			Endif	
		If aVerbasAcum[nCont,1] == fGetCodFol("1040") 
			aEntidade [9] [3] += aVerbasAcum[nCont,3]    //Valor 
   		Elseif aVerbasAcum[nCont,1] == fGetCodFol("1148") .OR. aVerbasAcum[nCont,1] == fGetCodFol("1116") .OR. aVerbasAcum[nCont,1] == fGetCodFol("859") 	
			If SRA->RA_JUBILAC == "S"
				aEntidade [9] [4] += aVerbasAcum[nCont,2]    //Porcentagem 
   				aEntidade [9] [5] += aVerbasAcum[nCont,3]    //Valor 				
        	Else
				aEntidade [9] [6] += aVerbasAcum[nCont,2]    //Porcentagem 
	   			aEntidade [9] [7] += aVerbasAcum[nCont,3]    //Valor 
	   		Endif	
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1146") 
			aEntidade [9] [8] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [9] [9] += aVerbasAcum[nCont,3]    //Valor 
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1145") 
			aEntidade [9] [10] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [9] [11] += aVerbasAcum[nCont,3]    //Valor 
	   	Endif	   	
	ElseIf	Right((AVERBASACUM[nCont][4]),02) == "10"    
			cEntidade := VerEntidadeMes("10")
			aEntidade [10] [1] := cEntidade  //Entidade   												
			If aEntidade [10] [2] != STR0021
				aEntidade [10] [2] := STR0021  //Outubro   
			Endif
		If aVerbasAcum[nCont,1] == fGetCodFol("1040") 
			aEntidade [10] [3] += aVerbasAcum[nCont,3]    //Valor 
   		Elseif aVerbasAcum[nCont,1] == fGetCodFol("1148") .OR. aVerbasAcum[nCont,1] == fGetCodFol("1116") .OR. aVerbasAcum[nCont,1] == fGetCodFol("859") 	
			If SRA->RA_JUBILAC == "S"
				aEntidade [10] [4] += aVerbasAcum[nCont,2]    //Porcentagem 
   				aEntidade [10] [5] += aVerbasAcum[nCont,3]    //Valor 				
        	Else
				aEntidade [10] [6] += aVerbasAcum[nCont,2]    //Porcentagem 
	   			aEntidade [10] [7] += aVerbasAcum[nCont,3]    //Valor 
	   		Endif	
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1146") 
			aEntidade [10] [8] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [10] [9] += aVerbasAcum[nCont,3]    //Valor 
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1145") 
			aEntidade [10] [10] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [10] [11] += aVerbasAcum[nCont,3]    //Valor 
	   	Endif	   	
	ElseIf	Right((AVERBASACUM[nCont][4]),02) == "11"    
			cEntidade := VerEntidadeMes("11")
			aEntidade [11] [1] := cEntidade  //Entidade   															
			If aEntidade [11] [2] != STR0022 
				aEntidade [11] [2] := STR0022  //Novembro   
			Endif	
		If aVerbasAcum[nCont,1] == fGetCodFol("1040") 
			aEntidade [11] [3] += aVerbasAcum[nCont,3]    //Valor 
   		Elseif aVerbasAcum[nCont,1] == fGetCodFol("1148") .OR. aVerbasAcum[nCont,1] == fGetCodFol("1116") .OR. aVerbasAcum[nCont,1] == fGetCodFol("859") 	
			If SRA->RA_JUBILAC == "S"
				aEntidade [11] [4] += aVerbasAcum[nCont,2]    //Porcentagem 
   				aEntidade [11] [5] += aVerbasAcum[nCont,3]    //Valor 				
        	Else
				aEntidade [11] [6] += aVerbasAcum[nCont,2]    //Porcentagem 
	   			aEntidade [11] [7] += aVerbasAcum[nCont,3]    //Valor 
	   		Endif	
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1146") 
			aEntidade [11] [8] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [11] [9] += aVerbasAcum[nCont,3]    //Valor 
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1145") 
			aEntidade [11] [10] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [11] [11] += aVerbasAcum[nCont,3]    //Valor 
	   	Endif	   	
	ElseIf	Right((AVERBASACUM[nCont][4]),02) == "12"      
			cEntidade := VerEntidadeMes("12")
			aEntidade [12] [1] := cEntidade  //Entidade   																		
			If aEntidade [12] [2] != STR0023 
				aEntidade [12] [2] := STR0023 //Dezembro    
			Endif	
		If aVerbasAcum[nCont,1] == fGetCodFol("1040") 
			aEntidade [12] [3] += aVerbasAcum[nCont,3]    //Valor 
   		Elseif aVerbasAcum[nCont,1] == fGetCodFol("1148") .OR. aVerbasAcum[nCont,1] == fGetCodFol("1116") .OR. aVerbasAcum[nCont,1] == fGetCodFol("859") 	
			If SRA->RA_JUBILAC == "S"
				aEntidade [12] [4] += aVerbasAcum[nCont,2]    //Porcentagem 
   				aEntidade [12] [5] += aVerbasAcum[nCont,3]    //Valor 				
        	Else
				aEntidade [12] [6] += aVerbasAcum[nCont,2]    //Porcentagem 
	   			aEntidade [12] [7] += aVerbasAcum[nCont,3]    //Valor           
	   		Endif	
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1146") 
			aEntidade [12] [8] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [12] [9] += aVerbasAcum[nCont,3]    //Valor 
	   	ElseIf	aVerbasAcum[nCont,1] == fGetCodFol("1145") 
			aEntidade [12] [10] += aVerbasAcum[nCont,2]    //Porcentagem 
	   		aEntidade [12] [11] += aVerbasAcum[nCont,3]    //Valor 
	   	Endif	   	
	Endif
Next  

Return .T.          

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �fBuscaEntidades �Autor  �Alceu Pereira � Data �  12.03.10    ���
��������������������������������������������������������������������������͹��
���Desc.     �Montar array de dados com nomes das entidades                ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/                       
Static Function fBuscaEntidades()

Local nPos := 0          
Local cEntidade := ""

SR9->(dbGoTop())
	While SR9->( !EOF() ) 
		If SRA->RA_FILIAL + SRA->RA_MAT  ==  SR9->R9_FILIAL+SR9->R9_MAT .AND. ("RA_CODAFP" $ SR9->R9_CAMPO) 
			nPos := FPOSTAB("S004", allTrim(SR9->R9_DESC) ,"==", 4 )
			cEntidade := FTABELA("S004", NPOS, 5)
			Aadd( aNomEnt ,{ cEntidade,SR9->R9_DATA})
		Endif	
		SR9->( dbSkip() )
	EndDo								

Return .T.

/*      
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �VerEntidadeMes  �Autor  �Alceu Pereira � Data �  12.03.10    ���
��������������������������������������������������������������������������͹��
���Desc.     �Verifica se foi feita alguma contribuicao para Entidade(s) no��� 
���			 �Mes.	  													   ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/                       
Static Function VerEntidadeMes(cMes)  
Local cEntidade  := ""    
Local nCont      := 0       

If Len(aNomEnt) = 0 
	nPos := FPOSTAB("S004", allTrim(SRA->RA_CODAFP) ,"==", 4 )
	cEntidade := FTABELA("S004", NPOS, 5)
Else
	For nCont := 1 to Len(aNomEnt)
		If Val(cMes) <= Val(SubStr(Dtoc(aNomEnt[nCont][2]),4,2)) .And. Val(cAno) <= Val("20"+SubStr(Dtoc(aNomEnt[1][2]),7,2)) 
			cEntidade := AllTrim(aNomEnt[nCont][1])	
		Endif
	Next                           
Endif

If Empty(cEntidade) .or. len(cEntidade) == 0
	nPos := FPOSTAB("S004", allTrim(SRA->RA_CODAFP) ,"==", 4 )
	cEntidade := FTABELA("S004", NPOS, 5)
Endif

Return(cEntidade)   