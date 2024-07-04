#INCLUDE "Protheus.ch"
#INCLUDE "Average.ch"

/*
Programa        : AVUPDATE01.PRW
Objetivo        : Update padrão Average
Autor           : Alessandro Alves Ferreira
Revisão         : Jean/Nilson/Rodrigo/
Data/Hora       : 19/08/2009
Revisão         : Guilherme Fernandes Pilan - GFP
Data/Hora       : 03/02/2014 - 10:12
Comentários     : Ajuste na alimentação do Log de alterações
Obs.            : 
*/

/*
Classe      : AVUPDATE01
Parametros  : Objeto de update
Retorno     : Nenhum
Objetivos   : Tratamentos de Update padrão
*/
Class AVUpdate01 of AvObject
   Data aDics
   Data aArqUpd
   Data cTexto
   Data aMenuData
   Data cTitulo
   Data cDescricao
   
   Data aChamados
   Data aDados
   Data aMenuItem
   Data aSIX
   Data aSX1
   Data aSX2
   Data aSX3
   Data aSX5
   Data aSX6
   Data aSX7
   Data aSXA
   Data aSXB
   Data aSX9
   Data aSXG //ACB - 11/02/2011 - Inclusão do grupo de campos.
   Data aVar
   Data aDel
   Data aHelpProb
   Data aHelpSol
   Data bMsgHelp
   Data cPaises
   Data oBackUp
   Data aChkFlags
   Data aTableStructs
   Data aTableData
   Data aDataDic
   Data cFileInd
   Data lSimula
   Data aDiffs
   Data lAtualizado
   Data lAtuDados
   Data aFiliais
   
   Method New()
   Method GetFiliais()
   Method Init()
   Method Processa()
   Method SXDataDic()
   Method SXGrava()
//   Method AcertaHelp(aHelp,cTipo)
   Method MontaSXs(oUpd)
   Method LerLinha(hFile,cVar,nSize)
   Method AbreMenu(cModulo)
   Method CriaMenu()
   Method MenuBackup()
   Method TableStruct()
   Method TableData()
   Method DelTableData()
   Method GrvTableData()
   Method GrvTableReg()
   Method SetP10Struct()
   Method SetP11Struct()
   Method AcertaDados()
   Method GravaMenuItem()
   Method GravaDir()
   Method GravaHelp(aDados,aStruct)
   Method AtuMenu()
   Method InitVar()
   Method GravaTable()
   Method CargaSX()
   //Method ShowDiffs()
   
EndClass

Class AvUpdBkp01 of AvObject
   Data cUpdate
   Data cArquivo
   Data cCodBkp
   Data aEstru   
   
   Method New()
   Method GrvBackUp()
   Method Recupera()
   Method Recuperacao()
   Method GetMainFunction()
   
End Class

Function AVUpdate01()
Return AVUpdate01():New()

Method New() Class AVUpdate01   
Local i := 0
   _Super:New()
   
   ::setClassName("AVUpdate01")
   ::cTexto   := ""
   ::cTitulo    := ""
   ::cDescricao := ""
   ::aArqUpd  := {}
   ::aDics    := {}
   ::aMenuItem:= {}
   ::aMenuData:= {}
   ::aChkFlags:= {}
   ::aChamados:= {}
   ::aTableStructs := {}
   ::aTableData := {}
   ::aDataDic   := {}
   ::lAtualizado:= .F.
   ::lAtuDados := .F.
   ::lSimula    := .F.
   ::aDiffs     := {}
   ::aFiliais   := {}
   
   //Legado a ser mantido
   ::aDel     := {}
   ::aSIX     := {}
   ::aSX1     := {}
   ::aSX2     := {}
   ::aSX3     := {}
   ::aSX5     := {}
   ::aSX6     := {}
   ::aSX7     := {}
   ::aSXA     := {}
   ::aSXB     := {}
   ::aSX9     := {}
   ::aSXG     := {} //ACB - 11/02/2011 - Inclusão do grupo de campos
   ::aDados   := {}   
   ::aHelpProb:= {}
   ::aHelpSol := {}
   
   ::bMsgHelp := {|i,aHelp,cTipo| "Help "+If(cTipo=="P","problema","solução")+": " + aHelp[i][1]}
   ::cPaises  := "ARG/BOL/BRA/CHI/COL/COS/DOM/EQU/EUA/MEX/PAN/PAR/PER/POR/PTG/URU/VEN"
   
   ::cFileInd := "AvUpidxSX9"
   
   aAdd(::aDics,{"HELP",;                               //cAliSx    - Alias do Dicionário
                 "Help de campos/programa",;                      //Descricao - Descricao do Dicionário
				 0,;                                     //Ind       - Indice da Chave Unica
				  ,;                                     //bArqUpd   - Arquivo a ser atualizado fisicamente no Banco de Dados
				 {"NOME"},; //aObrig    - Campos que devem estar preenchidos para inclusão
				 {}; //Campos que não são critério de Atualização no Dicionário
				 })
   //   
   aAdd(::aDics,{"DIRETORIO",;                               //cAliSx    - Alias do Dicionário
                 "Pasta no Servidor do Protheus",;                      //Descricao - Descricao do Dicionário
				 0,;                                     //Ind       - Indice da Chave Unica
				  ,;                                     //bArqUpd   - Arquivo a ser atualizado fisicamente no Banco de Dados
				 {"CAMINHO_DIRETORIO"},; //aObrig    - Campos que devem estar preenchidos para inclusão
				 {}; //Campos que não são critério de Atualização no Dicionário
				 })

   aAdd(::aDics,{"MENU"  ,;                               //cAliSx    - Alias do Dicionário
                 "Menu do Sistema",;                      //Descricao - Descricao do Dicionário
				 0 ,;                                     //Ind       - Indice da Chave Unica
				   ,;                                     //bArqUpd   - Arquivo a ser atualizado fisicamente no Banco de Dados
				 {"Modulo","Function","CAMINHO","FUNCAO_SUPERIOR","Title","Type"},; //aObrig    - Campos que devem estar preenchidos para inclusão
				 {},; //Campos que não são critério de Atualização no Dicionário
				 {"Modulo","Function"}})
   
   //                                                                                                                        
   aAdd(::aDics,{"SIX"  ,;                     //cAliSx    - Alias do Dicionário
                 "Índices",;                   //Descricao - Descricao do Dicionário
				 1 ,;                          //Ind       - Indice da Chave Unica
				 "INDICE",;                    //bArqUpd   - Arquivo a ser atualizado fisicamente no Banco de Dados
				 {"INDICE","ORDEM","CHAVE","DESCRICAO"},; //aObrig    - Campos que devem estar preenchidos para inclusão
				 {}; //Campos que não são critério de Atualização no Dicionário
				 })
				 
   aAdd(::aDics,{"SX1"  ,;     
                 "Perguntas"          ,;       
				 1 ,;
				 ,;
				 {"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_TIPO","X1_TAMANHO","X1_VAR01"}    ,;
				 {};
				 })
				 
   aAdd(::aDics,{"SX2"  ,;
                 "Tabelas"            ,;
				 1 ,;
				 "X2_CHAVE",;
				 {"X2_CHAVE","X2_ARQUIVO","X2_NOME","X2_MODO"},;
				 {"X2_ARQUIVO","X2_MODO","X2_MODOUN","X2_MODOEMP"};      // GFP - 06/09/2012 - Inclusão dos campos X2_MODOUN e X2_MODOEMP
				 })
				 
   aAdd(::aDics,{"SX3"  ,;
                 "Campos"             ,;
				 2 ,;
				 "X3_ARQUIVO",;
				 {"X3_CAMPO","X3_ARQUIVO","X3_TIPO","X3_TAMANHO","X3_TITULO","X3_DESCRIC"} ,;
                 {}	;
				 })
				 
   aAdd(::aDics,{"SXA"  ,;
                 "Pastas"             ,;
				 1 ,;
				 ,;
				 {"XA_ALIAS","XA_ORDEM","XA_DESCRIC"},;
				 {};
				 })
				 
   aAdd(::aDics,{"SX5"  ,;
                 "Tabelas Genéricas"  ,;
				 1 ,;
				 "'SX5'",;
				 {"X5_TABELA","X5_CHAVE","X5_DESCRI"},;
				 {};
				 })
				 
   aAdd(::aDics,{"SX6"  ,;
                 "Parâmetros"         ,;
				 1 ,;
				 ,;
				 {"X6_VAR","X6_TIPO","X6_DESCRIC"},;
                 {"X6_CONTEUD","X6_CONTSPA","X6_CONTENG"};
				 })
				 
   aAdd(::aDics,{"SX7"  ,;
                 "Gatilhos"           ,;
				 1 ,;
				 ,;
				 {"X7_CAMPO","X7_SEQUENC","X7_CDOMIN","X7_REGRA","X7_TIPO"},;
				 {};
				 })
				 
   aAdd(::aDics,{"SXB"  ,;
                 "Consultas Padrão"   ,;
				 1 ,;
				 ,;
				 {"XB_ALIAS","XB_TIPO","XB_SEQ"},;
				 {};
				 })
				 
   aAdd(::aDics,{"SX9"  ,;
                 "Relacionamentos"    ,;
				 1,;
				 ,;
				 {"X9_DOM","X9_CDOM","X9_IDENT","X9_EXPDOM","X9_EXPCDOM"},;
				 {};
				 })
				 
   //ACB - 11/02/2011 - Inclusão do grupo de campos SXG
   aAdd(::aDics,{"SXG"  ,;
                 "Grupo de Campos"  ,;
                 1 ,;//indice
                 ,;
                 {"XG_GRUPO","XG_DESCRI","XG_SIZEMAX","XG_SIZEMIN","XG_SIZE"},; // ,"XG_PICTURE"},;
                 {"XG_SIZE"};
                 })
   
   Self:aVar :=	{{"EIC",17},;
         	   	{"EEC",29},;              
	            {"EDC",50},;                  
	            {"EFF",30},;                  
	            {"ECO",31},;                  
	            {"ESS",85},; //RRC - 03/07/2013                 
	            {"TODOS_MODULOS","TODOS_MODULOS"},;   //TODOS_MODULOS = Todos os modulos.      
    	        {"TODOS_AVG","TODOS_AVG"},;       //TODOS_AVG     = Modulos EIC, EEC, EDC, EFF, ECO, ESS
	            {"BASICO_AVG","BASICO_AVG"},;      //BASICO_AVG    = Modulos EIC, EEC, EDC
	            {"EIC_USADO","EIC_USADO"},;
	            {"EEC_USADO","EEC_USADO"},;
	            {"EDC_USADO","EDC_USADO"},;
	            {"EFF_USADO","EFF_USADO"},;
	            {"ECO_USADO","ECO_USADO"},;
	            {"ESS_USADO","ESS_USADO"},; //RRC - 03/07/2013  
	            {"EIC_NUSADO","EIC_NUSADO"},;
	            {"EEC_NUSADO","EEC_NUSADO"},;
	            {"EDC_NUSADO","EDC_NUSADO"},;
	            {"EFF_NUSADO","EFF_NUSADO"},;
	            {"ECO_NUSADO","ECO_NUSADO"},;
	            {"ESS_NUSADO","ESS_NUSADO"},; //RRC - 03/07/2013 
	            {"NAO_USADO","NAO_USADO"}  ,;
	            {"TAB", CHR(9)+CHR(9)+CHR(9)+CHR(9)},;
	            {"FO_READWRITE",2},;
	            {"FO_EXCLUSIVE",16},;
	            {"BLOCK_READ", 1024},;
	            {"ENTER", CHR(13) + CHR(10)},;
	            {"NOME"   ,2^0},;
	            {"TIPO"   ,2^1},;
	            {"TAM"    ,2^2},;
	            {"DEC"    ,2^3},;
	            {"ORDEM"  ,2^4},;
	            {"OBRIGAT",2^5},;
	            {"USO"    ,2^6},;
	            {"LOCALIZACOES","ARG/BOL/CHI/COL/COS/DOM/EQU/EUA/MEX/PAN/PAR/PER/POR/PTG/URU/VEN"},;
	            {"BRASIL" ,"BRA"}}
	            //LOCALIZAÇÕES -> Países em que pode ser aplicado o update, se escolhido apenas um ou  
	            //                alguns países, colocar as siglas na variável cPaises no próprio update. 
            
   For i := 1 To Len(Self:aVar)
	   _SetOwnerPrvt(Self:aVar[i][1], Self:aVar[i][2])
   Next i

   Set(_SET_DELETED,.T.)
   
   Self:SetP11Struct()
Return Self


Method GetFiliais(lTelaFil,lOpen) Class AVUpdate01
Local aFiliais := {}   
Local lOpenEnv := Select("SX2") == 0
Default lOpen := Select("SM0") > 0 .OR. ( lOpen := MyOpenSm0Ex() )
Default lTelaFil := .T.

  If lOpen
     dbSelectArea("SM0")
     If lOpenEnv
         dbGotop()
   	     While !Eof() 
  	        If (nPos := Ascan(aFiliais,{ |x| x[2] == M0_CODIGO })) == 0 
			   Aadd(aFiliais,{Recno(),M0_CODIGO,{{Recno(),M0_CODFIL}}})
            Else
               aAdd(aFiliais[nPos][3],{Recno(),M0_CODFIL})
	     	 EndIf
		    dbSkip()
   	     EndDo
     Else
         aFiliais := {}                        
	     aAdd(aFiliais,{Recno(),M0_CODIGO,{{Recno(),M0_CODFIL}}})
     EndIf
    
      
     if empty(self:aFiliais)
        Self:aFiliais := aClone(aFiliais)
        If lTelaFil
            SelEmp(@Self:aFiliais)
         endif
      endif
   EndIf

Return 

Method Init(oUpd,lBlind) Class AVUpdate01
Local lEnd 
Local cFile :="", cMask := "Arquivos Texto (*.TXT) |*.txt|"

Private aAvRelease    := StrToKarr(GetRPORelease(),".")//THTS - 27/06/2017
Private oSay1, oGet1

If ValType(lBlind) <> "L"
   lBlind := .F.
EndIf

If ValType(oUpd) == "U"

   cArqEmp := "SigaMat.Emp"
   __cInterNet := Nil

   Private cMessage
   Private aArqUpd	 := {}
   Private aREOPEN	 := {}
   Private cDescr
   Private oMainWnd
   Private oProcess

   Begin Sequence

      lHistorico	:= .T.
      
      bHist         := {|| lBlind .OR. Self:lSimula .Or. MsgYesNo("Deseja efetuar a atualizacao do Dicionário? Esta rotina deve ser utilizada em modo exclusivo."+;
                                            "Faça um backup dos dicionários e da Base de Dados antes da atualização.",;
                                            "Atenção") }
      
      lEmpenho		:= .F.
      lAtuMnu		:= .F.
      
      If !lBlind
          /* DESCONTINUADA ATUALIZAÇÂO DE DICIONARIOS NO PROTHEUS 12 VIA PROGRAMA
          oMainWnd := MsDialog():New(0,0,600,800,"Atualização do Dicionário - "+Self:cTitulo,,,,,,,,,.T.,,,,,)

             cDescr := "<center><font size=5>"+StrTran(Self:cTitulo,Chr(13)+Chr(10),"<BR>")+"</font></center><BR><BR>"
             cDescr += "<font size=4>"+StrTran(Self:cDescricao,Chr(13)+Chr(10),"<BR>")+"</font>" 
             
             nAltura := oMainWnd:nHeight/2
             
             oPrc := TPanel():New(01,01,"",oMainWnd,,,,,,oMainWnd:nWidth,25/100*nAltura)
             oPrc:Align := CONTROL_ALIGN_TOP
             
             oSeg := TPanel():New(01,01,"",oMainWnd,,,,,,oMainWnd:nWidth,65/100*nAltura)
             oSeg:Align := CONTROL_ALIGN_ALLCLIENT  
             
             oSeg1 := TPanel():New(01,01,"",oMainWnd,,,,,,oMainWnd:nWidth,10/100*nAltura)
             oSeg1:Align := CONTROL_ALIGN_BOTTOM
             
             oSay1 := TSay():New(2,2,{|| cDescr},oPrc,,,,,,.T.,,,400,300,,,,,,.T.)
             oSay1:lWordWrap := .T.
             oSay1:Align := CONTROL_ALIGN_TOP
             
             
             @ 2,2 GET oGet1 VAR Self:cTexto MEMO SIZE 300,400 OF oSeg PIXEL READONLY
             oGet1:lWordWrap := .T.
             oGet1:EnableVScroll(.T.)
             oGet1:EnableHScroll(.T.)
             oGet1:Align := CONTROL_ALIGN_ALLCLIENT 
             
             oMainWnd:bInit := {|| oMainWnd:nHeight := 600,oMainWnd:nWidth := 800,oMainWnd:Center(.T.), if(lHistorico := Eval(bHist),(oProcess:Activate(),),Final("Atualização cancelada.")), }
             
             oProcess := MsNewProcess():New({|lEnd| ::Processa(@lEnd,lBlind) },"UPDATE - "+Self:cTitulo,"",.T.)    
            
             oTButton1 := TButton():New( 002, 310, "Grava Log",oSeg1,{||(cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,::cTexto)))},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
             oTButton2 := TButton():New( 002, 350, "Finalizar",oSeg1,{||oMainWnd:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
 
          oMainWnd:Activate()
          */
      Else
         ::Processa(,lBlind)
      EndIf
      
   End Sequence

Else
   oUpd:cTitulo    := Self:cTitulo
   oUpd:cDescricao := Self:cDescricao
   
   If !oUpd:lSimula
      ::MontaSXs(oUpd)
   Else
      oUpd:aChamados  := Self:aChamados
      oUpd:aDados     := Self:aDados
   EndIf
EndIf

Return .T.

Method Processa(lEnd,lBlind) Class AVUpdate01
Local aFiliais := {}
Local cFile :="", cMask := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno := 0  , nI    := 0, nX    := 0
Local lOpen  := .F., i     := 0, j
Local lOpenEnv := Select("SX2") == 0
Local cRetIn
Local lCompart := .F.
Private nL := CHR(13) + CHR(10)
Private lTela := !lBlind
Private bAtuRegua := {|nRegua,cTexto| if(lTela,(&("oProcess:IncRegua"+AllTrim(Str(nRegua))+"('"+cTexto+"')"), ProcessMessage()),)}
Private bAtuTela  := {|| if(lTela,(oMainWnd:Refresh(), oSay1:Refresh()),)}
Private lSXInclui := .T. //THTS - 19/07/2017 - Define se deve incluir ou alterar os dicionarios

Begin Sequence 
                                                                
   If lOpenEnv//.AND. !IsInCallStack("U_UTTESWHG") //AAF 10/01/2017 - Liberação do compatibilizador de tamanho de campos para a P12.
               //AAF 24/10/2017 - Bloqueio do update U_UTTESWHG devido a dicionarios no SGBD
      /* Bloqueio da execução do compatibilizador para a P12 */ 
      BlockUpd12()
      ::Warning("Update não executado.")
      ::ShowErrors(.T.,.F.)
      oGet1:Refresh()
      Return .F.
   EndIf
  
   If ( lOpen := Select("SM0") > 0 .OR. MyOpenSm0Ex() )
   
      Self:GetFiliais(lTela,lOpen)

      If lTela
         oProcess:SetRegua1(Len(Self:aFiliais)+2)
      EndIf
      
	  If lOpen .OR. !lOpenEnv
	     For nI := 1 To Len(Self:aFiliais)
		     SM0->(dbGoto(Self:aFiliais[nI,1]))
			 Eval(bAtuRegua,1,"Processando dicionarios da empresa "+Alltrim(str(nI))+" / "+Alltrim(str(Len(self:aFiliais))))
			 
			 If lTela
   			    oProcess:SetRegua2(7)
   	         EndIf
   	         
			 Eval(bAtuRegua,2,"Abrindo dicionarios")
			 
			 If lOpenEnv
    		    RpcSetType(3) 
			    RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas automáticas
			 
			    Eval(bAtuRegua,2,"Indexando SX9")  
			 
			    //AOM - 20/07/11
			    If File(GetSrvProfString("ROOTPATH","")+"\system\"+ ::cFileInd + TEOrdBagExt()) 
			       FErase(::cFileInd+TEOrdBagExt())  
   			    EndIf
			    If lBlind  
      			    SX9->(dbCreateIndex(::cFileInd+TEOrdBagExt(),"X9_DOM+X9_CDOM+X9_IDENT",&("{|| X9_DOM+X9_CDOM+X9_IDENT}")))
   	   	   	    Else
                   IndRegua("SX9",::cFileInd+TEOrdBagExt(),"X9_DOM+X9_CDOM+X9_IDENT")
                EndIf
                SX9->(dbSetIndex(::cFileInd+TEOrdBagExt()))
			 EndIf			 
 			 lMsFinalAuto := .F.
 			 
			 //::cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			 //::cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)
			 ::Warning(Replicate("-",128)+CHR(13)+CHR(10),,,.F.)
			 ::Warning("Empresa : "+SM0->M0_CODIGO+" - "+SM0->M0_NOME+CHR(13)+CHR(10))
	  		 Eval(bAtuTela)
	  		 
	  		 If !cPaisLoc $ ::cPaises
    			//::cTexto += "Este update não pode ser utilizado para empresa/filial desta localização."
				::Warning("Este update não pode ser utilizado para empresa/filial desta localização.")
	  		    Loop
	  		 EndIf

	  		 Self:InitVar()
	  		 	 
	  		 /* Neste ponto o sistema disparará as funções
	  		    contidas no array aChamados para cada 
	  		    módulo. */
			 Eval(bAtuRegua,2,"Carregando alteracoes de dicionarios")
			 
	  		 For i := 1 To Len(::aChamados)
  	  		    nModulo := ::aChamados[i,1]
       	        
       	        Self:SetP11Struct(,.T.)			    
			    cRetIn := EVAL( ::aChamados[i,2],Self)
                //THTS - 19/07/2017 - Caso seja informada a posicao 3, pega o valor dela, caso contrario, mantera o funcionamento padrao.
                If Len(::aChamados[i]) > 2 .And. ValType(::aChamados[i,3]) == "L"
                    lSXInclui := ::aChamados[i,3]
                Else
                    lSXInclui := .T.
                EndIf
			    
                Self:SXDataDic()
			    			    
			    IF ValType(cRetIn) == "C"
			       //::cTexto += cRetIn+CHR(13)+CHR(10)
				   ::Warning(cRetIn+CHR(13)+CHR(10))
			       Eval(bAtuTela)
			    ENDIF
			 Next

			 Eval(bAtuRegua,2,"Atualizando dicionarios")
             
             Self:SXDataDic() //Utilizado quando o avupdate é carregado antes da execucao do metodo init
             Self:SXGrava()

			 Eval(bAtuRegua,2,"Atualizando estrutura do banco de dados")
          Eval(bAtuTela)
             // Nopado débitos técnicos MFR 19/01/2022 OSSME-6500
             /*
			 If lOpenEnv
			     
				 #IFDEF TOP
			        ::aArqUpd := GetDBTables(::aArqUpd)
				 #ENDIF
				 				 
   	   		     __SetX31Mode(.F.)
			     For nX := 1 To Len(::aArqUpd)
		    		 If Select(::aArqUpd[nx])>0
			    		dbSelectArea(::aArqUpd[nx])
				    	dbCloseArea()
    				 EndIf
						
	    			 If (nAt := At(cArqTab,::aArqUpd[nx]+"E/")) > 0
		    		    cArqTab := SubStr(cArqTab,1,nAt)+SubStr(cArqTab,nAt+Len(::aArqUpd[nx]+"E")+"/")
			    	 EndIf
				     If (nAt := At(cArqTab,::aArqUpd[nx]+"C/")) > 0
    				    cArqTab := SubStr(cArqTab,1,nAt)+SubStr(cArqTab,nAt+Len(::aArqUpd[nx]+"C")+"/")
	    			 EndIf
		    			
			    	 cArqTab += Posicione("SX2",1,::aArqUpd[nx],"X2_CHAVE")+Posicione("SX2",1,::aArqUpd[nx],"X2_MODO")+"/"
				     //EndIf
				 
    				 If SX2->(dbSetOrder(1),dbSeek(Self:aArqUpd[nx])) .AND. SX3->(dbSetOrder(1),dbSeek(Self:aArqUpd[nx])) .AND. SIX->(dbSetOrder(1),dbSeek(Self:aArqUpd[nx]))
     	    		  	 MsDelIndex(::aArqUpd[nx],__cRDD) //Recriar indices
   	    			 X31UpdTable(::aArqUpd[nx])
   		       EndIf
				 
				     If __GetX31Error() //.OR. !ChkFile(::aArqUpd[nx])
    					If !lBlind
   	    				   Alert(__GetX31Trace())
		    			   Aviso("Atencao","Ocorreu um erro desconhecido durante a atualizacao da tabela : "+;
			    		      ::aArqUpd[nx] +;
				    	      ". Verifique a integridade do dicionario e da tabela.",{"Continuar"},2) 
					    EndIf
					      
    					//::cTexto += "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "+::aArqUpd[nx] +CHR(13)+CHR(10)
						::Warning("Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "+::aArqUpd[nx] +CHR(13)+CHR(10))
	    			 EndIf
		    	 Next nX
          EndIf */
             
			 Eval(bAtuRegua,2,"Atualizando dados das tabelas do sistema")
			 Eval(bAtuTela)
			 
			 For i := 1 To Len(Self:aFiliais[nI][3])
			    If Self:aFiliais[nI][3][i][1] > 0
			       SM0->(dbGoto(Self:aFiliais[nI][3][i][1]))
			    EndIf
			    cFilAnt := Self:aFiliais[nI][3][i][2]

	  		    lCompart := .F.
	  		    For j := 1 To Len(::aDados)
                   //cRetIn := EVAL( ::aDados[j],Self)
                   If Valtype(::aDados[j]) <> "A"
   	  		          ::aDados[j] := {::aDados[j],.T.}
	  		       EndIf
	  		       
	  		       cRetIn := EVAL( ::aDados[j][1],Self)
	  		       
	  		       If (lCompart := !::aDados[j][2])
	  		          Exit
	  		       EndIf
			      
			       If ValType(cRetIn) == "C"
			          //::cTexto += cRetIn+CHR(13)+CHR(10)
					  ::Warning(cRetIn+CHR(13)+CHR(10))
			          Eval(bAtuTela)
			       EndIf
			    Next j
			    
			    If lCompart
			       Exit
			    EndIf
			    
			 Next i

             Self:GravaTable()
			 Eval(bAtuTela)
			 
			 Eval(bAtuRegua,2,"Concluindo atualizacao na filial ")
			 
			 For i := 1 To Len(Self:aChkFlags)
			    cFunction := AllTrim(Self:aChkFlags[i][1])
				cFlag     := AllTrim(Self:aChkFlags[i][2])
				
				If !Empty(cFunction)
				   cExec := cFunction+"("+if(!Empty(cFlag),"'"+cFlag+"'","")+")"
				   
				   Private oLogFlags := AvObject():New()
				   
         		   lRetFlag := &(cExec)
			       
				   //::cTexto += "Flag ("+cFunction+")("+cFlag+"): "+if(lRetFlag,"LIGADO","DESLIGADO")+ENTER
				   ::Warning("Flag ("+cFunction+")("+cFlag+"): "+if(lRetFlag,"LIGADO","DESLIGADO")+ENTER)
				   If !lRetFlag
				      For i := 1 To Len(oLogFlags:aWarning)
				         //::cTexto += "...Motivo "+AllTrim(Str(i))+": "+oLogFlags:aWarning[i]+ENTER
						 ::Warning("...Motivo "+AllTrim(Str(i))+": "+oLogFlags:aWarning[i]+ENTER)
				         Eval(bAtuTela)
				      Next i
				   EndIf
				EndIf
			 Next i
			 
          /* DESCONTINUADA ATUALIZAÇÂO DE DICIONARIOS NO PROTHEUS 12 VIA PROGRAMA
			 If ::lSimula .AND. lTela
			    ::ShowDiffs()
			 EndIf
          */
			 
			 If lOpenEnv
  			    SX9->(dbCloseArea())
			    FErase(::cFileInd+TEOrdBagExt()) //AOM - 20/07/11 - Informado o tipo do arquivo a ser deletado
			 EndIf

			 Eval(bAtuTela)
			 
			 If lOpenEnv
   			    RpcClearEnv()
			    
  			    If !( lOpen := MyOpenSm0Ex() )
				   Exit
			    EndIf
			 EndIf
		 Next nI
		 
 		 Eval(bAtuRegua,1,"Atualizando Menu do Sistema")
         For nI := 1 To Len(::aMenuData)
            If ::aMenuData[nI][3] .AND. !::lSimula
               //::MenuBackup(::aMenuData[nI][1])
               ::CriaMenu(::aMenuData[nI][1])
            EndIf
         Next nI
		 
 		 Eval(bAtuRegua,1,"Concluido!")
		 //::cTexto += Self:GetStrErrors()
		 ::Warning(Self:GetStrErrors())
		 Eval(bAtuTela)
		 
		 If lTela .And. Type("oGet1") == "O"                
   		    oGet1:Refresh()
		 EndIf
 		
	  EndIf		
   EndIf 	
   
   If lTela                  //NCF - 20/06/2014

      //** AAF 28/07/2015 - Grava o log no servidor.
	  If !lIsDir("\comex\")
   	     If !(MakeDir("\comex\") == 0)
		    Self:Error("Falha ao criar o diretório \comex\ no servidor para armazenamento deste log.")
		 EndIf
	  EndIf

	  If !lIsDir("\comex\updates\")
   	     If !(MakeDir("\comex\updates\") == 0)
		    Self:Error("Falha ao criar o diretório \comex\updates\ no servidor para armazenamento deste log.")
		 EndIf
	  EndIf

	  If lIsDir("\comex\updates\")
	     //Pega o nome do update
		 nProc := 1
		 Do While !Empty(ProcName(nProc))
		    nProc++
		 EndDo

         Do While (cArq := "\comex\updates\"+ProcName(nProc-1)+"-"+DTOS(Date())+StrTran(Time(),":")+".log",File(cArq))
         EndDo

         nHdl := EasyCreateFile(cArq)

		 Self:GetStrErrors(,nHdl)

		 FClose(nHdl)
      EndIf
      //**

      ::ShowErrors(.T.,.F.)
      If Type("oGet1") == "O"
         oGet1:Refresh()
      EndIf
   EndIf
   
End Sequence

Return(.T.)

Method TableStruct(cTable,aTableStruct,nIndex) Class AvUpdate01
Local nPosDic
Local lDic := (nPosDic := aScan(Self:aDics,{|X| AllTrim(X[1]) == AllTrim(cTable)}))>0
Local nPosStru, i, aMnu, nPosMnu

If lDic
   Default nIndex := Self:aDics[nPosDic][3]
EndIf

If ValType(cTable) == "C" .AND. ValType(nIndex) == "N" .AND. ValType(aTableStruct) == "A"
   
   If AllTrim(cTable) == "MENU"
      aMnu := MenuStruct()
      For i := 1 To Len(aTableStruct)
         If (nPosMnu := aScan(aMnu,{|X| Upper(AllTrim(X[1])) == Upper(AllTrim(aTableStruct[i]))})) > 0
            aTableStruct[i] := aMnu[nPosMnu]
         EndIf
      Next i
   EndIf
   
   If (nPosStru := aScan(Self:aTableStructs,{|X| AllTrim(X[1]) == AllTrim(cTable)})) == 0
      Default nIndex := 1   
      aAdd(Self:aTableStructs,{cTable,nIndex,aTableStruct})
   Else
      Default nIndex := Self:aTableStructs[nPosStru][2]
      Self:aTableStructs[nPosStru] := {cTable,nIndex,aTableStruct}
      //::Error("Chamada incorreta do metodo TableStruct. A estrutura para a tabela "+cTable+" ja esta definida. Fonte:"+Procname(1)+" linha "+AllTrim(Str(Procline(1))))
   EndIf
Else
   ::Error("Chamada incorreta do metodo TableStruct. Fonte:"+Procname(1)+" linha "+AllTrim(Str(Procline(1))))
EndIf

Return Nil

Method DelTableData(cTable,aDados,aArray) Class AvUpdate01
Return Self:TableData(cTable,aDados,.T.,,aArray) 

Method TableData(cTable,aDados,lDel,lAtualizar,aArray) Class AvUpdate01
Local i, j, nPosStru
Local cCampos := "X3_USADO/X3_RESERV/X7_ORDEM"
Local cErro := ""
Local cChamada
Local cChave
Local cIdxKey := ""
Local lDic := aScan(Self:aDics,{|X| AllTrim(X[1]) == AllTrim(cTable)})>0
Default lDel := .F.
If lDic .AND. If(!(AllTrim(Upper(cTable)) == "SX5"),.T.,(Posicione("SX2",1,"SX5","X2_MODO") == "C" .And. Empty(Self:aDados)))  // GFP - 25/09/2012 - Update deve considerar SX5 como carga padrão.
   Default aArray := Self:aDataDic
Else
   Default aArray := Self:aTableData
EndIf

Default lAtualizar := .T. // Incluir ou Alterar

If ValType(cTable) == "C" .AND. ValType(aDados) == "A"
   If (nPosStru := aScan(Self:aTableStructs,{|X| AllTrim(X[1]) == AllTrim(cTable)})) > 0
      
      If Len(aDados) > 0 .AND. ValType(aDados[1]) <> "A"
         aDados := {aDados}
      EndIf

      If !lDic .And. Select(cTable) == 0
         ChkFile(cTable)
      EndIf
      
      For i := 1 To Len(aDados)
          
         If Len(aDados[i]) == Len(Self:aTableStructs[nPosStru][3])
            
            lOk := .T.
            
            If lOK
           
               If lDel
                  //Deixa as exclusoes nas primeiras posicoes
               
                  nPosInc := aScan(aArray,{|X| !X[3]})
                  aAdd(aArray,NIL)
               
                  If nPosInc == 0
                     nPosInc := Len(aArray)
                  EndIf
                  
                  aIns(aArray,nPosInc)
                  aArray[nPosInc] := {cTable,aDados[i],lDel,aClone(Self:aTableStructs[nPosStru]),lAtualizar}
               Else

                  aStruct := aClone(Self:aTableStructs[nPosStru])
                  //Adiciona filial se nao estiver na estrutura
                  If !lDic  //.And. Posicione("SX2",1,cTable,"X2_MODO") == "E"
                     If Select(cTable) == 0
                        ChkFile(cTable)
                     EndIf

                     If (cTable)->(FieldPos(cTable+"_FILIAL")) > 0
                        cFilCpo := cTable+"_FILIAL"
                     ElseIf (cTable)->(FieldPos(SubStr(cTable,2,2)+"_FILIAL")) > 0
                        cFilCpo := SubStr(cTable,2,2)+"_FILIAL"
                     Else
                        cErro := "Campo Filial nao cadastrado para a tabela "+cTable
                        lOk := .F.
                     EndIf
        
                     If (nPosFil := aScan(aStruct[3],{|X| AllTrim(X) == cFilCpo})) == 0
                        aAdd(aStruct[3],cFilCpo)
                        aAdd(aDados[i],xFilial(cTable))
                     Else
                        aDados[i][nPosFil] := xFilial(cTable)
                     EndIf
                  Else
                     If cTable == "SX6"
                        If (nPosFil := aScan(aStruct[3],{|X| AllTrim(X) == "X6_FIL"})) > 0 
                           If ValType(aDados[i][nPosFil]) == "U"
                              aDados[i][nPosFil] := xFilial(cTable)
                           EndIf
                        Else
                           aAdd(aStruct[3],"X6_FIL")
                           aAdd(aDados[i],xFilial(cTable))
                        EndIf
                     EndIf

                     If cTable == "SX5" 
                        If (nPosFil := aScan(aStruct[3],{|X| AllTrim(X) == "X5_FILIAL"})) > 0 
                           If ValType(aDados[i][nPosFil]) == "U"
                              aDados[i][nPosFil] := xFilial(cTable)
                           EndIf
                        Else
                           aAdd(aStruct[3],"X5_FILIAL")
                           aAdd(aDados[i],xFilial(cTable))
                        EndIf
                     EndIf 
                  EndIf
                  
                  
                  // Tratamento para incluir o SXG no inicio do vetor aArray
                  If cTable == "SXG"
                     aAdd(aArray,NIL)
                     aIns(aArray,1)
                     aArray[1] := {cTable,aDados[i],lDel,aClone(Self:aTableStructs[nPosStru]),lAtualizar}
                  Else
                     nPosInc := aScan(aArray,{ |X| X[1] == "SIX"})
                     aAdd(aArray,NIL)
                  
                     If nPosInc == 0
                        nPosInc := Len(aArray)
                     EndIf
                  
                     aIns(aArray,nPosInc)
                 
                     //aArray[nPosInc] := {cTable,aDados[i],lDel,aClone(Self:aTableStructs[nPosStru]),lAtualizar}
                     aArray[nPosInc] := {cTable,aDados[i],lDel,aClone(aStruct),lAtualizar}
                  EndIf
                     
               EndIf
            EndIf
         ElseIf isInCallStack("SXDATADIC")
            cErro := "Chamada incorreta do metodo TableData. A estrutura para a tabela "+cTable+" esta definida com "+AllTrim(Str(Len(Self:aTableStructs[nPosStru][3])))+;
                    " campos e o registro adicionado possui "+AllTrim(Str(Len(aDados[i])))+" campos para a chave #CHAVE#"
         Else
            cErro := "Chamada incorreta do metodo TableData. A estrutura para a tabela "+cTable+" esta definida com "+AllTrim(Str(Len(Self:aTableStructs[nPosStru][3])))+;
                    " campos e o registro adicionado possui "+AllTrim(Str(Len(aDados[i])))+" campos. #CHAMADA#"
         EndIf
         
         If !Empty(cErro)
            If !cTable $ "MENU/DIRETORIO/HELP"
               cIndex   := (cTable)->(dbSetOrder(Self:aTableStructs[nPosStru][2]),IndexKey())
               aCposInd := {}
               cIdxKey := IndexKey()
               For j := 1 To Len(Self:aTableStructs[nPosStru][3])
                  If Self:aTableStructs[nPosStru][3][j] $ cIndex
                     aAdd(aCposInd,{j,Self:aTableStructs[nPosStru][3][j]})
                  EndIf
               Next j
               

            ElseIf cTable == "MENU"
               aCposInd := {{1,"Modulo"},{2,"Function"}}
            ElseIf cTable == "DIRETORIO"
               aCposInd := {{1,"CAMINHO_DIRETORIO"}}
            ElseIf cTable == "HELP" 
               aCposInd := {{1,"NOME"}}
            EndIf

            cChamada := "Fonte:"+Procname(1)+" linha "+AllTrim(Str(Procline(1)))
            cChave   := GetTextRegKey(aCposInd,aDados[i],lDic)
   
            Self:Error(StrTran(StrTran(cErro,"#CHAMADA#",cChamada),"#CHAVE#",cChave))
            cErro := ""
         EndIf
         
      Next i
   Else
      cErro := "Chamada incorreta do metodo TableData. A estrutura para a tabela "+cTable+" nao esta definida. #CHAMADA#"
   EndIf
Else
   cErro := "Chamada incorreta do metodo TableData. #CHAMADA#"
EndIf

If !Empty(cErro)
   cChamada := "Fonte:"+Procname(1)+" linha "+AllTrim(Str(Procline(1)))   
   Self:Error(StrTran(StrTran(cErro,"#CHAMADA#",cChamada),"#CHAVE#",cChave))
EndIf

Return Nil

Method GrvTableData(aTable) Class AvUpdate01
Local i, j, lProc
Local lRet := .F.
Local lAtualizar
Local nPosFil
Local cPos
Local nPerc
Local nAuxPerc := 0
Local nProcMsg := 0
Local aDifUsado := {}
Local aDifReserv := {} 
local cIndKey := ""
Local nSinal := 0
Local cCpo := ""
Local aX3Ord := {}
Local nVirg := 0
Local nParent := 0
Local aSXBanco := {}  //THTS - 06/07/2017 - Array contendo as informacoes a serem processadas de dicionario nos bancos
Local cAvRelease:= aAvRelease[2] + Right(aAvRelease[3],2)
Local bEngExec  
Local nPosSX
Local nPosInd

Private lSXBanco := FindFunction("EngSX3"+cAvRelease) .And. cAvRelease <= "117"//MPDicInDB() //THTS - 06/07/2017 - Verifica se vai executar as novas funcoes de dicionario nos bancos

For i := 1 To len(aTable)
   cTable   := aTable[i][1] 
   if Select(cTable) == 0
      ChkFile(cTable)
   end if 
next
Begin Transaction

If lTela
   oProcBD:SetRegua1(100)
   oProcBD:SetRegua2(100)
EndIf

//FSM - 21/08/2012
If aScan(aTable, {|x| UPPER(AllTrim(x[1])) == "SIX" } ) > 0
   AcertaIndice(aTable)
EndIf

nAuxPerc := 0
nProcMsg := Seconds()
nTotal := Len(aTable)
cTotal := Str(nTotal)

For i := 1 To nTotal
   cTable   := aTable[i][1]
   aDados   := aTable[i][2]
   lDel     := aTable[i][3]
   aIgnora  := {}

   cPos := Alltrim(STR(i))
   nPerc := INT((i/Len(aTable))*100)
   if lTela .AND. nPerc > nAuxPerc  

      oProcBD:IncRegua1("Progresso:  " +STR(nPerc)+ " %")
     
      nAuxPerc := nPerc
   endif
   
   //nPosStru := aScan(Self:aTableStructs,{|X| X[1] == cTable})
   nIndex   := aTable[i][4][2]//Self:aTableStructs[nPosStru][2]
   aStruct  := aTable[i][4][3]//aClone(Self:aTableStructs[nPosStru][3])   
   nPosDic  := aScan(Self:aDics,{|X| AllTrim(X[1]) == AllTrim(cTable)})
   lProc    := .T.
   lAtualizar := aTable[i][5] 
   
   If !cTable $ "MENU/DIRETORIO/HELP"  
      
      cIndex   := (cTable)->(dbSetOrder(nIndex),IndexKey())
      aCposInd := {}
      For j := 1 To Len(aStruct)
         If aStruct[j] $ cIndex
            aAdd(aCposInd,{j,aStruct[j]})
         EndIf
      Next j
     
      dbSelectArea(cTable)
   ElseIf cTable == "MENU"
      aCposInd := Self:aDics[nPosDic][7]
   EndIf

   lProc := lProc .AND. Self:AcertaDados(cTable,aStruct,aDados)
   
   If nPosDic == 0
      aObrig := EasyGetObrig(cTable)
   Else
      aIgnora := Self:aDics[nPosDic][6]
      
      //lProc := lProc .AND. Self:Compatibiliza()
      If cTable == "SX3" .AND. lProc 
         lProc := .F.
         /*
         If !AcertaUsado(aStruct,aDados)
            ::Error("Não foi possivel gravar o X3_USADO para a chave "+GetTextRegKey(aCposInd,aDados,nPosDic > 0))
         ElseIf !AcertaReserv(aStruct,aDados)
            ::Error("Não foi possivel gravar o X3_RESERV para a chave "+GetTextRegKey(aCposInd,aDados,nPosDic > 0))
         Else
         */
            If FindFunction("FWSizeFilial")
               AcertaFilial(aStruct, aDados)//RMD - 15/08/2012 - Tratamento para o campo filial
            EndIf
            lProc := .T.
         //EndIf
      elseif cTable == "SIX" .AND. lProc .AND. !lDel .AND. !::lSimula
    
         If (nPosInd := aScan(aStruct,{|X| AllTrim(X) == "CHAVE"})) > 0 
            cIndKey := alltrim(aDados[nPosInd])  /*:TODO*/
            Do While Len(AllTrim(cIndKey)) > 0 // enquanto houver chave a ser tratada
                aX3Ord := Saveord("SX3",2)
                nSinal := At("+",cIndKey)
                If nSinal > 0  
                cCpo := AllTrim(SubStr(cIndKey,1,nSinal-1))  
                else
                cCpo := AllTrim(cIndKey) //separa o último campo da chave.
                If Len(cCpo) = 0
                    Exit
                EndIf
                cIndKey := ""
                endif
                cIndKey := SubStr(cIndKey,nSinal+1)// recorta a chave, tirando o campo que foi separado, juntamente com o '+'
                
                nVirg := At(",",cCpo)
                nParent := At(")",cCpo)
                
                if nVirg > 0
                    cCpo := AllTrim(SubStr(cCpo,5,nVirg-5))// separa um campo da chave
                elseif nParent > 0
                    cCpo := AllTrim(SubStr(cCpo,6,nParent-6))// separa um campo da chave
                Endif        
                
    
                if !Sx3->(dbseek(cCpo))
                lProc := .F.
                //SELF:cTexto += ("Campo " + alltrim(cCpo) + " não encontrado no dicionário SX3 para criação do indice " + alltrim(aDados[3]) + "." + char(13) + char(10)) 
                Self:Error(("Campo " + alltrim(cCpo) + " não encontrado no dicionário SX3 para criação do indice " + alltrim(aDados[3]) + "." + char(13) + char(10)))
                endif
            EndDo
        EndIf
      EndIf
      aObrig:={}
      IF lSxInclui
         aObrig := Self:aDics[nPosDic][5]
      EndIf   
   EndIf
   
   If lProc
      If cTable == "MENU"
         lRet := Self:GravaMenuItem(lDel,aDados,aStruct,aIgnora,aObrig) .OR. lRet
      ElseIf cTable == "DIRETORIO"
         lRet := Self:GravaDir(aDados,aStruct) .OR. lRet
      ElseIf cTable == "HELP"
         lRet := Self:GravaHelp(aDados,aStruct) .OR. lRet
      Else 
         lRet := Self:GrvTableReg(cTable,cIndex,aCposInd,aStruct,aDados,aIgnora,aObrig,lDel,lAtualizar,aSXBanco) .OR. lRet //THTS - 06/07/2017 - Adicionada aSXBanco
      EndIf
   EndIf
   
   
  If Seconds() - nProcMsg > 1
     ProcessMessage() 
     nProcMsg := Seconds()
 EndIf  
 

Next i

//THTS - 06/07/2017 - Chamada da funcao
If lSXBanco .And. Len(aSXBanco) > 0
    For nPosSX := 1 To Len(aSXBanco)

        bEngExec  := &("{|x| Eng" + aSXBanco[nPosSX][1] + cAvRelease + "(x) }")
        Eval(bEngExec,aSXBanco[nPosSX][2])

    Next
EndIf

End Transaction

Return lRet

Method GrvTableReg(cTable,cIndex,aCposInd,aStruct,aDados,aIgnora,aObrig,lDel,lAtualizar,aSXBanco) Class AvUpdate01
Local j, cChave
Local nRecDel := 0
Local nRecInc := 0
Local nPosDic := aScan(Self:aDics,{|X| AllTrim(X[1]) == AllTrim(cTable)})
Local lRet    := .F.
Local lGrava  := .T.
Local cOperacao := ""
Local nRecSeek
Local cPrefixoD := Upper(IF(Left(cTable,1) == "S",Right(cTable,2),Right(cTable,3)))    // GFP - 25/09/2012
//THTS - 06/07/2017
Local nPosTab   := 0 
Local nPosChave := 0
Local aSXDados  := {}
Local cSXChave  := ""
Local nSX       := 0 
Local nPosDOM   := aScan(aStruct,{|x| x == "X9_DOM"})
Local nPosIDENT := aScan(aStruct,{|x| x == "X9_IDENT"})
Local nPosCDOM  := aScan(aStruct,{|x| x == "X9_CDOM"})
Local nPosEXPDOM:= aScan(aStruct,{|x| x == "X9_EXPDOM"})
Local nPosEXPCDO:= aScan(aStruct,{|x| x == "X9_EXPCDOM"})
Begin Sequence
   
   dbSelectArea(cTable)
   
   //Carrega chave do indice
   For j := 1 To Len(aCposInd)
      &("M->"+AllTrim(aCposInd[j][2])) := aDados[aCposInd[j][1]]
   Next j
   
   If cTable == "SXB" .AND. Type("M->XB_COLUNA") == "U"
      M->XB_COLUNA := Space(Len(SXB->XB_COLUNA))
   EndIf
   
   //Monta chave
   cChave := M->(&((cTable)->(cIndex)))
   nRegs := 0
   dbSeek(cChave)
   nRecSeek := RecNo()
   Do While !Eof() .AND. cChave == &(cIndex)
      If cTable == "SX9" .And. !Empty(nPosDOM) .And. !Empty(nPosIDENT) .And. !Empty(nPosCDOM) .And. !Empty(nPosEXPDOM) .And. !Empty(nPosEXPCDO)
         If SX9->X9_DOM == aDados[nPosDOM] .And. SX9->X9_IDENT == aDados[nPosIDENT] .And. SX9->X9_CDOM == aDados[nPosCDOM] .And. Alltrim(SX9->X9_EXPDOM) == Alltrim(aDados[nPosEXPDOM]) .And. Alltrim(SX9->X9_EXPCDOM) == Alltrim(aDados[nPosEXPCDO])
            nRegs++
            nRecSeek := SX9->(Recno())
         EndIf
         dbSkip()
      Else
         nRegs++
         dbSkip()
      EndIf
   EndDo
   dbGoTo(nRecSeek)
   
   If nRegs == 0
      If !lDel
         cOperacao := " incluido."
         
         //AAF 24/09/2012 - Primeiro acertar os dados, depois checar a obrigatoriedade

         /* DESCONTINUADA ATUALIZAÇÂO DE DICIONARIOS NO PROTHEUS 12 VIA PROGRAMA
         If cTable == "SX3"
            lGrava := lGrava .AND. AcertaOrdem(aStruct,aDados, .T.) .And. AcertaTamanho(aStruct,aDados) .AND. AcertaGrpCpo(aStruct,aDados)  // GFP - 14/03/2013
         ElseIf cTable == "SX2"
            lGrava := lGrava .AND. AcertaArquivo(aStruct,aDados)
         EndIf
         */

         If lGrava
            For j := 1 To Len(aObrig)
               If (nPosCp := aScan(aStruct,{|X| AllTrim(X) == AllTrim(aObrig[j])})) == 0 .OR. Empty(aDados[nPosCp])
                  lGrava := .F.
                  Self:Error("Conteudo nao informado para o campo obrigatorio "+aObrig[j]+" da tabela "+cTable+".")
                  EXIT
               EndIf
            Next j
         EndIf
         
         If ::lSimula .AND. lTela
            For j := 1 To Len(aStruct)
               If aDados[j] <> NIL .AND. !"FILIAL" $ aStruct[j] .AND. !Empty(aDados[j])
                  aAdd(::aDiffs,{cTable,cChave,aStruct[j],"***INCLUSAO***",aDados[j]}) //{ALIAS,CHAVE,CAMPO,DICIONARIO_ATUAL,DICIONARIO_FUTURO}
               EndIf
            Next j
         EndIf
      Else
         ::Error("Registro nao encontrado para exclusao na Tabela = "+cTable+" com a chave "+GetTextRegKey(aCposInd,aDados,nPosDic > 0))
         BREAK
      EndIf
   ElseIf nRegs == 1 .And. lAtualizar
     
      /* DESCONTINUADA ATUALIZAÇÂO DE DICIONARIOS NO PROTHEUS 12 VIA PROGRAMA
      If cTable == "SX3"
            lGrava := lGrava .AND. AcertaOrdem(aStruct,aDados, .F.) .And. AcertaTamanho(aStruct,aDados)
      EndIf
      */
      
      If nPosDic == 0
         RegToMemory(cTable,.F.,.F.,.F.)
      Else
         For j := 1 To FCount()
            &("M->"+FieldName(j)) := FieldGet(j)
         Next j
      EndIf
   
      If !lDel
         lGrava := .F.
         //Compara conteudo existente com o conteudo a ser gravado
         For j := 1 To Len(aStruct)
            If aDados[j] <> NIL .AND. aScan(aIgnora,{|X| AllTrim(aStruct[j]) == AllTrim(X)}) == 0 .AND. (aStruct[j] <> "X3_GRPSXG" .OR. (nPosX3Cpo := aScan(aStruct,{|X| AllTrim(X) == "X3_CAMPO"})) == 0 .OR. !"FILIAL" $ aDados[nPosX3Cpo])
               If /*nPosDic # 0 .AND.*/ (cTable)->(FieldPos(aStruct[j])) > 0 //FSM - 17/08/2012 //FSY - 13/01/2014 - Removido a condição (nPosDic # 0), pois a atualização da carga padrão nao estava sendo efetuada
                  If ValType(&("M->"+AllTrim(aStruct[j]))) <> ValType(aDados[j])
                     Self:Error("O campo "+AllTrim(aStruct[j])+" da tabela "+cTable+" é do tipo '"+ ValType(&("M->"+AllTrim(aStruct[j])))+;
                                "' e o conteudo recebido é do tipo '"+ValType(aDados[j])+"' com a chave "+GetTextRegKey(aCposInd,aDados,nPosDic > 0))
                     Exit
                  ElseIf  If( Alltrim(aStruct[j]) $ "X3_USADO|X3_RESERV|X3_OBRIGAT" .And. lSXBanco , &("M->"+AllTrim(aStruct[j])) <> (aDados[j]) , &("M->"+AllTrim(aStruct[j])) <> aDados[j] ) //NCF - 18/07/2018  /*&("M->"+AllTrim(aStruct[j])) <> aDados[j]*/
                     lGrava := .T.
                     If !(::lSimula .AND. lTela)
                        EXIT
                     Else
                        aAdd(::aDiffs,{cTable,cChave,aStruct[j],&("M->"+AllTrim(aStruct[j])),aDados[j]}) //{ALIAS,CHAVE,CAMPO,DICIONARIO_ATUAL,DICIONARIO_FUTURO}
                     EndIf
                  EndIf
               EndIf
            EndIf
         Next j
         
         cOperacao := " atualizado."
      Else
      
         If ::lSimula .AND. lTela
            For j := 1 To Len(aStruct)
               If aDados[j] <> NIL .AND. !"FILIAL" $ aStruct[j] .AND. !Empty(&("M->"+AllTrim(aStruct[j])))
                  aAdd(::aDiffs,{cTable,cChave,aStruct[j],&("M->"+AllTrim(aStruct[j])),"***EXCLUSAO***"}) //{ALIAS,CHAVE,CAMPO,DICIONARIO_ATUAL,DICIONARIO_FUTURO}
               EndIf
            Next j
         EndIf
      
         cOperacao := " excluido."
      EndIf
   ElseIf !lAtualizar
      lGrava := .F.
   Else
      Self:Error("Chave informada para registro da tabela "+cTable+" nao e unico. Chave informada: "+GetTextRegKey(aCposInd,aDados,nPosDic > 0))//(cTable)->(cIndex))//Chave nao e unica
      BREAK
   EndIf
   
   //** AAF 17/01/2014 - Sempre atualizar o banco
   If nPosDic > 0 .AND. ValType(Self:aDics[nPosDic][4]) == "C" .AND. !::lSimula
      cArq := &(Self:aDics[nPosDic][4])
      If aScan(Self:aArqUpd,{|X| AllTrim(Upper(X)) == AllTrim(Upper(cArq))}) == 0
         aAdd(Self:aArqUpd, cArq)
      EndIf
   EndIf
   //**
   
   If !lGrava
      BREAK
   EndIf
   //THTS - 06/07/2017 - Adicionada validacao lSXBanco, mas continua executando forma antiga quando nao for os dicionarios abaixo
   If lSXInclui .And. (!(lSXBanco .And. (cTable $ "SIX|SX2" .OR. (cTable == "SX3" .AND. nRegs == 1))) .And. (cTable <> "SX3" .OR. (aScan(aStruct,{|X| X == "X3_CONTEXT"}) > 0 .And. M->X3_CONTEXT == "V") .or. (aScan(aStruct,{|X| X == "X3_ORDEM"}) > 0) .Or. (aScan(aStruct,{|X| X == "X3_FOLDER"}) > 0) .Or. (aScan(aStruct,{|X| X == "X3_TITULO"}) > 0)) .And. nRegs == 1 .AND. !::lSimula)
      nRecDel := RecNo()
      RecLock(cTable,.F.)
      If nPosDic > 0 .AND. ValType(Self:aDics[nPosDic][4]) == "C" .AND. !::lSimula
         cArq := &(Self:aDics[nPosDic][4])
         If !Empty(cArq) .And. aScan(Self:aArqUpd,{|X| AllTrim(Upper(X)) == AllTrim(Upper(cArq))}) == 0
            aAdd(Self:aArqUpd, cArq)
         EndIf
      EndIf
      dbDelete()
      MsUnLock()
   EndIf
   
   If !lDel .AND. !::lSimula
      //RecLock(cTable,.T.) Movido para dar o reclock somente na execucao do modelo antigo
      //Carrega todo conteudo a ser gravado
      For j := 1 To Len(aStruct)
         If aDados[j] <> NIL .AND. (nRegs == 0 .Or. aScan(aIgnora,{|X| AllTrim(aStruct[j]) == AllTrim(X)}) == 0) .And. (nPosDic # 0 .Or. (cTable)->(FieldPos(aStruct[j])) > 0)  //FSM - 17/08/2012
            &("M->"+AllTrim(aStruct[j])) := aDados[j]
         Elseif nRegs == 0 //Tratamento para inclusao em caso de campos não determinados na estrutura
            &("M->"+AllTrim(aStruct[j])) := AvConvert("U",ValType((cTable)->(FieldGet(FieldPos(aStruct[j])))))
         EndIf
      Next j
      
      If lSXBanco .And. (cTable $ "SIX|SX2" .OR. (cTable == "SX3" .AND. nRegs == 1)) //THTS - 06/07/2017 - Utilizacao das novas funcoes de dicionarios no banvo de dados

         If (nPosTab := aScan(aSXBanco,{|X| X[1] == cTable})) > 0 //Ja existe o Dicionario no aSXBanco

            aSXDados := AvEngSX(cTable,aStruct)
            cSXChave := ""
            For nPosChave := 1 To Len(aSXDados[1])//Chave
                cSXChave += "Y[1,"+ Alltrim(Str(nPosChave)) + "] == '" + aSXDados[1][nPosChave] +"'"
                If nPosChave < Len(aSXDados[1])
                    cSXChave += " .And. "
                EndIf
            Next

            If (nPosChave := aScan(aSXBanco[nPosTab,2],{|Y| &(cSXChave) })) > 0
                For nSX := 1 To Len(aSXDados[2])
                    aAdd(aSXBanco[nPosTab,2,nPosChave,2],aSXDados[2,nSX])
                Next
            Else
                aAdd(aSXBanco[nPosTab,2],aSXDados) //Trata as novas funcoes para dicionarios no banco
            EndIf

         Else //Nao existe o Dicionario no aSXBanco
            aAdd(aSXBanco,{cTable,{AvEngSX(cTable,aStruct)}}) //Trata as novas funcoes para dicionarios no banco
         EndIf
      ElseIf cTable <> "SX3" .OR. (aScan(aStruct,{|X| X == "X3_CONTEXT"}) > 0 .And. M->X3_CONTEXT == "V") .or. (aScan(aStruct,{|X| X == "X3_ORDEM"}) > 0) .Or. (aScan(aStruct,{|X| X == "X3_FOLDER"}) > 0) .Or. (aScan(aStruct,{|X| X == "X3_TITULO"}) > 0)
         RecLock(cTable,lSXInclui .or. nRegs == 0) //THTS - 19/07/2017 - Opcao para incluir ou alterar o dicionario
         AvReplace("M",cTable)

         If (cTable)->(FieldPos(cPrefixoD+"_FILIAL")) != 0   // GFP - 25/09/2012 - Forçar gravação do campo Filial com o aDados pois o AvReplace grava outra filial.
            (cTable)->&(cPrefixoD+"_FILIAL") := M->&(cPrefixoD+"_FILIAL")
         EndIf

         If nPosDic > 0 .AND. ValType(Self:aDics[nPosDic][4]) == "C" .AND. !::lSimula
            cArq := &(Self:aDics[nPosDic][4])
            If !Empty(cArq) .And. aScan(Self:aArqUpd,{|X| AllTrim(Upper(X)) == AllTrim(Upper(cArq))}) == 0
                aAdd(Self:aArqUpd, cArq)
            EndIf
         EndIf
         MsUnLock()
         nRecInc := RecNo()
        
      EndIf
   EndIf
   
   If !::lSimula
      If nPosDic > 0// FSY - Apresenta o texto só quando for atualização de dicionario de dados. - 26/06/2012 
         ::lAtualizado := .T.  
         //::cTexto += "Registro da Tabela = "+cTable+" com a chave "+GetTextRegKey(aCposInd,aDados,nPosDic > 0)+cOperacao+Chr(13)+Chr(10)
		 ::Warning("Registro da Tabela = "+cTable+" com a chave "+GetTextRegKey(aCposInd,aDados,nPosDic > 0)+cOperacao+Chr(13)+Chr(10))
      Else
         ::lAtuDados := .T. // FSY - Variavel utilizada para verificar atualização de dados de Alias - 28/06/2012
      EndIf
   EndIf 

   lRet := .T. 
   Eval(bAtuTela)
   
End Sequence

Return lRet

Method SetP10Struct(cDic,lForce) Class AvUpdate01
Local nPosStru, i
Local aDicsSX := {}
Local aStruSx
Default lForce := .F.

   aAdd(aDicsSX,{"HELP",{"NOME","PROBLEMA","SOLUCAO"}})

   aAdd(aDicsSX,{"DIRETORIO",{"CAMINHO_DIRETORIO"}})

   aAdd(aDicsSX,{"MENU",MenuStruct()})
   
   aAdd(aDicsSX,{"SIX",{ "INDICE"   ,"ORDEM"     ,"CHAVE"     ,"DESCRICAO" ,"DESCSPA"   ,"DESCENG"   ,"PROPRI"    ,"F3"        ,"NICKNAME" ,"SHOWPESQ"}})
   
   aAdd(aDicsSX,{"SX1",{"X1_GRUPO"  ,"X1_ORDEM"  ,"X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL" ,;
                        "X1_GSC"    ,"X1_VALID"  ,"X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2",;
                        "X1_DEFENG2","X1_CNT02"  ,"X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4",;
                        "X1_DEFENG4","X1_CNT04"  ,"X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_PYME"   ,"X1_GRPSXG" ,;
                        "X1_HELP"   ,"X1_PICTURE","X1_IDFIL"}})

   aAdd(aDicsSX,{"SX2",{ "X2_CHAVE"  ,"X2_PATH"   ,"X2_ARQUIVO","X2_NOME"   ,"X2_NOMESPA","X2_NOMEENG","X2_ROTINA" ,"X2_MODO"   ,"X2_DELET" ,;
                         "X2_TTS"    ,"X2_UNICO"  ,"X2_PYME"   ,"X2_MODULO" }})
   
   aAdd(aDicsSX,{"SX3",{ "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
                  "X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
                  "X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
                  "X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME",;
                  "X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD"}})
                  
   /* ATENÇÃO: NÃO ALTERAR A ESTRUTURA DO DICIONÁRIO
      Caso tenha problemas com o update utilizado, fixar a estrutura do SX3 no programa do update, e não no AVUPDATE01.
   If SX3->(FieldPos("X3_TELA")) > 0
      aAdd(aDicsSX[Len(aDicsSX)],"X3_TELA")
   EndIf
   */
   
   aAdd(aDicsSX,{"SXA",{ "XA_ALIAS"  ,"XA_ORDEM"  ,"XA_DESCRIC","XA_DESCSPA","XA_DESCENG","XA_PROPRI" }})
   
   aAdd(aDicsSX,{"SX5",{ "X5_FILIAL" ,"X5_TABELA" ,"X5_CHAVE"  ,"X5_DESCRI" ,"X5_DESCSPA","X5_DESCENG"}})
   
   aAdd(aDicsSX,{"SX6",{ "X6_FIL"    ,"X6_VAR"     ,"X6_TIPO"    ,"X6_DESCRIC" ,"X6_DSCSPA"  ,"X6_DSCENG"  ,"X6_DESC1"  ,"X6_DSCSPA1" ,"X6_DSCENG1" ,;
                         "X6_DESC2"  ,"X6_DSCSPA2" ,"X6_DSCENG2" ,"X6_CONTEUD" ,"X6_CONTSPA" ,"X6_CONTENG" ,"X6_PROPRI" ,"X6_PYME"}})
   
   aAdd(aDicsSX,{"SX7",{ "X7_CAMPO"  ,"X7_SEQUENC" ,"X7_REGRA" ,"X7_CDOMIN" ,"X7_TIPO", "X7_SEEK", "X7_ALIAS", "X7_ORDEM", "X7_CHAVE", "X7_CONDIC","X7_PROPRI"}})
   
   aAdd(aDicsSX,{"SXB",{ "XB_ALIAS" ,"XB_TIPO" ,"XB_SEQ"  ,"XB_COLUNA" ,"XB_DESCRI" ,"XB_DESCSPA" ,"XB_DESCENG" ,"XB_CONTEM" }})
   
   aAdd(aDicsSX,{"SX9",{ "X9_DOM"   ,"X9_IDENT" ,"X9_CDOM" ,"X9_EXPDOM" ,"X9_EXPCDOM" ,"X9_PROPRI" ,"X9_LIGDOM" ,"X9_LIGCDOM" ,"X9_CONDSQL" ,"X9_USEFIL" ,"X9_ENABLE" }})
   
   aAdd(aDicsSX,{"SXG",{ "XG_GRUPO" ,"XG_DESCRI" ,"XG_DESSPA" ,"XG_DESENG" ,"XG_SIZEMAX" ,"XG_SIZEMIN" ,"XG_SIZE" ,"XG_PICTURE" }})
   
   //aEval(Self:aDics,{|aDic| if(aDic[1] <> "MENU",(aStruSx := {}, aEval((aDic[1])->(DBStruct()),{|x| aAdd(aStruSx,x[1])}), aAdd(aDicsSX,{aDic[1],aClone(aStruSx)})),)})
   
   If ValType(cDic) == "C" .AND. (i := aScan(aDicsSX,{|X| AllTrim(X[1]) == AllTrim(cDic)})) > 0
      aDicsSX := {aDicsSX[i]}
   EndIf
   
   For i := 1 To Len(aDicsSX)
      If lForce .OR. ValType(cDic) == "C" .OR. (nPosStru := aScan(Self:aTableStructs,{|X| AllTrim(X[1]) == AllTrim(aDicsSX[i][1])})) == 0
         nPosDic := aScan(Self:aDics,{|X| AllTrim(X[1]) == AllTrim(aDicsSX[i][1])})
         Self:TableStruct(aDicsSX[i][1],aDicsSX[i][2],Self:aDics[nPosDic][3])
      EndIf
   Next i
   
Return Nil

Method SetP11Struct(cDic,lForce) Class AvUpdate01
Local nPosStru, i
Local aDicsSX := {}
Local aStruSx
Default lForce := .F.

   aAdd(aDicsSX,{"HELP",{"NOME","PROBLEMA","SOLUCAO"}})

   aAdd(aDicsSX,{"DIRETORIO",{"CAMINHO_DIRETORIO"}})

   aAdd(aDicsSX,{"MENU",MenuStruct()})
   
   aAdd(aDicsSX,{"SIX",{ "INDICE"   ,"ORDEM"     ,"CHAVE"     ,"DESCRICAO" ,"DESCSPA"   ,"DESCENG"   ,"PROPRI"    ,"F3"        ,"NICKNAME" ,"SHOWPESQ"}})
   
   aAdd(aDicsSX,{"SX1",{"X1_GRUPO"  ,"X1_ORDEM"  ,"X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL" ,;
                        "X1_GSC"    ,"X1_VALID"  ,"X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2",;
                        "X1_DEFENG2","X1_CNT02"  ,"X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4",;
                        "X1_DEFENG4","X1_CNT04"  ,"X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_PYME"   ,"X1_GRPSXG" ,;
                        "X1_HELP"   ,"X1_PICTURE","X1_IDFIL"}})

   aAdd(aDicsSX,{"SX2",{ "X2_CHAVE"  ,"X2_PATH"   ,"X2_ARQUIVO","X2_NOME"   ,"X2_NOMESPA","X2_NOMEENG","X2_ROTINA" ,"X2_MODO","X2_MODOUN","X2_MODOEMP",;
                         "X2_DELET"  ,"X2_TTS"    ,"X2_UNICO"  ,"X2_PYME"   ,"X2_MODULO", "X2_DISPLAY"}})
   
   aAdd(aDicsSX,{"SX3",{ "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
                  "X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
                  "X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
                  "X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME",;
                  "X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD","X3_TELA"}})
   
   aAdd(aDicsSX,{"SXA",{ "XA_ALIAS"  ,"XA_ORDEM"  ,"XA_DESCRIC","XA_DESCSPA","XA_DESCENG","XA_PROPRI" }})
   
   aAdd(aDicsSX,{"SX5",{ "X5_FILIAL" ,"X5_TABELA" ,"X5_CHAVE"  ,"X5_DESCRI" ,"X5_DESCSPA","X5_DESCENG"}})
   
   aAdd(aDicsSX,{"SX6",{ "X6_FIL" , "X6_VAR" , "X6_TIPO" , "X6_DESCRIC" , "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1" , "X6_DSCSPA1" , "X6_DSCENG1" , "X6_DESC2" , ;
                         "X6_DSCSPA2" , "X6_DSCENG2" , "X6_CONTEUD" , "X6_CONTSPA" , "X6_CONTENG" , "X6_PROPRI" , "X6_PYME" , "X6_VALID" , "X6_INIT" ,;
                         "X6_DEFPOR" , "X6_DEFSPA" , "X6_DEFENG" }})

   aAdd(aDicsSX,{"SX7",{ "X7_CAMPO"  ,"X7_SEQUENC" ,"X7_REGRA" ,"X7_CDOMIN" ,"X7_TIPO", "X7_SEEK", "X7_ALIAS", "X7_ORDEM", "X7_CHAVE", "X7_CONDIC","X7_PROPRI"}})
   
   aAdd(aDicsSX,{"SXB",{ "XB_ALIAS" ,"XB_TIPO" ,"XB_SEQ"  ,"XB_COLUNA" ,"XB_DESCRI" ,"XB_DESCSPA" ,"XB_DESCENG" ,"XB_CONTEM", "XB_WCONTEM"}})
   
   aAdd(aDicsSX,{"SX9",{ "X9_DOM" , "X9_IDENT" , "X9_CDOM" , "X9_EXPDOM" , "X9_EXPCDOM" , "X9_PROPRI" , "X9_LIGDOM" , "X9_LIGCDOM" , "X9_CONDSQL" , "X9_USEFIL" , "X9_ENABLE" , "X9_VINFIL" , "X9_CHVFOR"}})

   aAdd(aDicsSX,{"SXG",{ "XG_GRUPO" ,"XG_DESCRI" ,"XG_DESSPA" ,"XG_DESENG" ,"XG_SIZEMAX" ,"XG_SIZEMIN" ,"XG_SIZE" ,"XG_PICTURE" }})
   
   //aEval(Self:aDics,{|aDic| if(aDic[1] <> "MENU",(aStruSx := {}, aEval((aDic[1])->(DBStruct()),{|x| aAdd(aStruSx,x[1])}), aAdd(aDicsSX,{aDic[1],aClone(aStruSx)})),)})

   If ValType(cDic) == "C" .AND. (i := aScan(aDicsSX,{|X| AllTrim(X[1]) == AllTrim(cDic)})) > 0
      aDicsSX := {aDicsSX[i]}
   EndIf
   
   For i := 1 To Len(aDicsSX)
      If lForce .OR. ValType(cDic) == "C" .OR. (nPosStru := aScan(Self:aTableStructs,{|X| AllTrim(X[1]) == AllTrim(aDicsSX[i][1])})) == 0
         nPosDic := aScan(Self:aDics,{|X| AllTrim(X[1]) == AllTrim(aDicsSX[i][1])})
         Self:TableStruct(aDicsSX[i][1],aDicsSX[i][2],Self:aDics[nPosDic][3])
      EndIf
   Next i
   
Return Nil

Method SXDataDic() Class AVUpdate01
Local i:=0, j:=0, oSX
Local nCont     := 0
Private oObj    := Self

   For i := 1 To Len(Self:aDics)
      
      If Self:aDics[i][1] == "MENU"
         aArray := Self:aMenuItem
      ElseIf Self:aDics[i][1] == "DIRETORIO"
         aArray := {}
      ElseIf Self:aDics[i][1] == "HELP"
         aArray := {}
      Else
         aArray := &("oObj:a"+Self:aDics[i][1])
      EndIf
      
      For j := 1 To Len(aArray)
         Self:TableData(Self:aDics[i][1],aArray[j],.F., ,Self:aDataDic)
      Next j
      
      aSize(aArray,0)
   Next i
   
   For i := 1 To Len(Self:aHelpProb)
      cProb := ""
      For j := 1 To Len(Self:aHelpProb[i][2])
         cProb += Self:aHelpProb[i][2][j]
      Next j
      Self:TableData("HELP",{Self:aHelpProb[i][1],cProb,""},.F., ,Self:aDataDic)
   Next i

   For i := 1 To Len(Self:aHelpSol)
      cProb := ""
      For j := 1 To Len(Self:aHelpSol[i][2])
         cProb += Self:aHelpSol[i][2][j]
      Next j
      Self:TableData("HELP",{Self:aHelpSol[i][1],"",cProb},.F., ,Self:aDataDic)
   Next i
   
   For i := 1 To Len(Self:aDel)
      Self:DelTableData(Self:aDel[i][1],Self:aDel[i][2],Self:aDataDic)
   Next i
   aSize(Self:aDel,0)
   aSize(Self:aHelpSol,0)
   aSize(Self:aHelpProb,0)
   
   
Return .T.

Method SXGrava() Class AvUpdate01
Local bGrvTabData := {||::GrvTableData(Self:aDataDic)}
Private cTexto  := ""
Private oProcBD

If lTela
   oProcBD := MsNewProcess():New(bGrvTabData,"Atualizando o Dicionário de dados","Aplicando as atualizações no dicionário de dados",.T.)
EndIf

If (lTela .AND. !oProcBD:Activate() .OR. !lTela .AND. !Eval(bGrvTabData)) .And. !Self:lAtualizado
   cTexto += "Não foi necessária nenhuma atualização de dicionários." + ENTER
EndIf
   
//::cTexto += cTexto
::Warning(cTexto)
Eval(bAtuTela)
Return .T.

Method GravaTable() Class AvUpdate01
Local bGrvTabData := {||::GrvTableData(Self:aTableData)}
Private cTexto  := ""
Private oProcBD

If lTela
   oProcBD := MsNewProcess():New(bGrvTabData,"Atualizando as tabelas nas filiais","Aplicando as atualizações nas tabelas das filiais",.T.)
EndIf

If (lTela .AND. !oProcBD:Activate() .OR. !lTela .AND. !Eval(bGrvTabData)) .And. !Self:lAtuDados
   cTexto += "Não foi necessária nenhuma atualização de tabelas." + ENTER
EndIf
   
//::cTexto += cTexto
::Warning(cTexto)
Eval(bAtuTela)
Return .T.

Method AcertaDados(cAlias,aStru,aDados) Class AvUpdate01
Local i := 0, j:=0, lProc := .T.
Local nPosNum := 0, nPosMod := 0, nPosFun := 0, nPosCam := 0, nPosTip := 0, nPosNome := 0, nPosProb := 0, nPosSol := 0
Local cDiretorio := ""
Local aVar := {{"SIGAEIC",17},;
               {"SIGAEEC",29},;
               {"SIGAEDC",50},;
               {"SIGAEFF",30},;
               {"SIGAECO",31},;
               {"SIGAESS",85}} //RRC - 03/07/2013
Local nPosFil

   If !cAlias $ "MENU/DIRETORIO/HELP"
      dbSelectArea(cAlias)
   EndIf

   lProc := .T.
   
   If cAlias == "MENU"

      nPosMod := aScan(aStru,{|X| Upper(AllTrim(X[1])) == "MODULO"})
      If ValType(aDados[nPosMod]) <> "C" 
        aDados[nPosMod] := ConvMod(aDados[nPosMod]) 
      EndIf
      nPosNum := aScan(aVar,{|X| X[1] == aDados[nPosMod]})
      If nPosNum == 0 .Or. Empty(aDados[nPosMod])
         ::Error("Nao foi encontrado o módulo: " + AllTrim(aDados[nPosMod]) + ".")
         lProc := .F.
      EndIf

      nPosFun := aScan(aStru,{|X| Upper(AllTrim(X[1])) == "FUNCTION"})
      nPosTip := aScan(aStru,{|X| Upper(AllTrim(X[1])) == "TIPO"})
      If nPosTip > 0 .AND. !FindFunction(if(aDados[nPosTip]=="3","U_","")+aDados[nPosFun])
         ::Error("Nao foi localizado a função: " + AllTrim(aDados[nPosFun])+ " no repositório.")
         lProc := .F.
      EndIf

      nPosFun := aScan(aStru,{|X| Upper(AllTrim(X[1])) == "FUNCAO_SUPERIOR"})
      nPosCam := aScan(aStru,{|X| Upper(AllTrim(X[1])) == "CAMINHO"})
      If nPosFun > 0 .AND. Empty(aDados[nPosFun]) .And. nPosCam > 0 .AND. Empty(aDados[nPosCam])
         ::Error("Não foi informado o caminho ou a função como referencia para a inclusão do menu.")
         lProc := .F.
      EndIf

   ElseIf cAlias == "DIRETORIO"

      nPosCam := aScan(aStru,{|X| Upper(AllTrim(X)) == "CAMINHO_DIRETORIO"})
      If nPosCam > 0
         cDiretorio := aDados[nPosCam]
      EndIf
      
      //TEM que ser caracter
      If !(ValType(cDiretorio) == "C")
         ::Error("O caminho dever ser informado com escopo de variável igual a caracter.")
         lProc := .F.

      //Nao pode ter um drive
      //Nao pode ter caracteres especiais , \/ estes terá que confirma com alessandro
      ElseIf ":" $ cDiretorio .Or. "*" $ cDiretorio .Or. "?" $ cDiretorio .Or. "<" $ cDiretorio .Or. ">" $ cDiretorio .Or. "|" $ cDiretorio .Or. "!" $ cDiretorio
         ::Error("Os nomes dos diretorios não devem conter os seguintes caracteres: <>:*?|!")
         lProc := .F.
      EndIf

      //Se for Linux, inverter as barras
      If IsSrvUnix()
         cDiretorio := StrTran(cDiretorio, "\", "/")
      EndIf
   ElseIf cAlias == "HELP"
   
      nPosNome := aScan(aStru,{|X| Upper(AllTrim(X)) == "NOME"})
      nPosProb := aScan(aStru,{|X| Upper(AllTrim(X)) == "PROBLEMA"})
      nPosSol  := aScan(aStru,{|X| Upper(AllTrim(X)) == "SOLUCAO"})
      If nPosNome == 0 .Or. !(ValType(aDados[nPosNome]) == "C")
         ::Error("O nome do help deve ser informado com escopo de variável igual a caracter.")
         lProc := .F.
      EndIf
      
      //TEM QUE SER STRING NAO VAZIA (PELO MENOS OU PROBLEMA OU SOLUCAO NAO VAZIO)
      // Verificando ser foi informado o problema ou a solução, pelo menos um deles
      If (nPosProb == 0 .Or. Empty(aDados[nPosProb])) .And. (nPosSol == 0 .Or. Empty(aDados[nPosSol]))
         ::Error("Nao foi informado o problema ou solucao para o help: " + AllTrim(aDados[nPosNome]) + ".")
         lProc := .F.
      ElseIf Len(aDados) == 2 // verificando se foi informado somente uma opção
         If Empty(aDados[2]) .And. !(ValType(aDados[2]) == "C")
            ::Error("O help deve ser informado com escopo de variável igual a caracter para: " + AllTrim(aDados[nPosNome]) + ".")
            lProc := .F.
         EndIf
      ElseIf Len(aDados) == 3 // verificando se foram informado as duas opções
         If !(ValType(aDados[2]) == "C") .Or. !(ValType(aDados[3]) == "C")
            ::Error("O help deve ser informado com escopo de variável igual a caracter para: " + AllTrim(aDados[nPosNome]) + ".")
            lProc := .F.
         EndIf
      EndIf

   EndIf

   If lProc
      If !cAlias $ "MENU/DIRETORIO/HELP"
         For j:=1 to Len(aStru)
            If (nPosSX := FieldPos(aStru[j]) ) > 0 .AND. ValType(FieldGet(nPosSX)) == "C" .AND. ValType(aDados[j]) == "C" .And. Len(FieldGet(nPosSX)) > 0
               If !AllTrim(aStru[j]) $ "X3_USADO/" //AAF 12/09/2014 - Exceção devido ao uso das variaveis de definição do usado do campo.
                  aDados[j] := IncSpace(aDados[j],Len(FieldGet(nPosSX)),.F.)
               EndIf
            ElseIf (nPosSX := FieldPos(aStru[j]) ) > 0 .AND. ValType(FieldGet(nPosSX)) == "N" .AND. ValType(aDados[j]) == "C"
               aDados[j] := Val(aDados[j])
            EndIf
         Next j
      ElseIf cAlias == "MENU"
        aDados[nPosMod] := aVar[nPosNum][2]
      EndIf
   Endif

Return lProc

Static Function AcertaHelp(cNome,cHelp,cTipo)
Local aHelp    := {}
Local cHelpAux := ""
Local cCpoAtu  := ""
Local cHelpAdd := ""
Local cAvRelease  := aAvRelease[2] + Right(aAvRelease[3],2) //THTS - 27/06/2017 - Versao do Release
Local bHelpExec:= &("{|w,x,y,z| EngHLP"+cAvRelease+"(w,x,y,z) }")
Begin Sequence

   If Len(cHelp) <= 40
      aHelp := {cHelp}
   Else
      cHelpAux := AllTrim(cHelp)
      While !Empty(cHelpAux)
         cHelpAdd := SubStr(cHelpAux,1,40)
         aAdd(aHelp,cHelpAdd)
         cHelpAux := SubStr(cHelpAux,Len(cHelpAdd)+1,Len(cHelpAux))
      EndDo
   EndIf

   If !(RTrim(BuscaHelp(cNome,cTipo)) == RTrim(cHelp))//FDR - 16/02/12
      If aAvRelease[3] <= "007" //Release 12.1.007 ### THTS - 27/06/2017 - ALterada funcao para release acima do 12.1.07 para dicionario em SGBD
        PutHelp(cTipo+cNome,aHelp,aHelp,aHelp,.T.)
      Else
        Eval(bHelpExec,cTipo+cNome,aHelp,aHelp,aHelp)
      EndIf
      cCpoAtu := cHelp
   Endif

End Sequence
   
Return cCpoAtu

Method MontaSXs(oUpd) Class AVUpdate01
Local i := 0                                      
Local nOldMod := if(Type("nModulo")<>"U",nModulo,NIL)

FOR i := 1 TO LEN(::aChamados)
   nModulo := ::aChamados[i,1]
   oUpd:SetP11Struct(,.T.)
   EVAL(::aChamados[i][2],oUpd)
   oUpd:SXDataDic()
NEXT

nModulo := nOldMod

Return

Method LerLinha(hFile,cVar,nSize) Class AVUpdate01

Local cBuffer := ""
Local cAux    := ""
Local nBytes  := BLOCK_READ
Local nEndLine:= 0
Local nPos    := 0

Begin Sequence
   
   While (nEndLine := At(CRLF,cAux)) == 0 .And. (nPos:=fSeek(hFile,0,1))<nSize
      IF nBytes > (nSize-nPos)
         nBytes := (nSize-nPos)
      Endif
      cBuffer := Space(nBytes)
      fRead(hFile,@cBuffer,nBytes)
      cAux += cBuffer
   Enddo
   
   IF nPos < nSize
      nVolta := (Len(cAux)+1) - nEndLine
      nVolta -= 2
      fSeek(hFile,-nVolta,1)
      cVar := Substr(cAux,1,nEndLine-1)
   ELSE
      cVar := cAux
   ENDIF
   
End Sequence

Return(Len(cVar)+2) // +2 por causa do CRLF
  
   Method New(cArquivo) Class AvUpdBkp01 
      Default cArquivo := "AVUPDBKP"
      
      ::cUpdate  := ::GetMainFunction()
      ::cArquivo := cArquivo
      ::cCodBkp  := ""
      ::aEstru   := {}
      
      aAdd(::aEstru,{"CODIGO"  ,"C",6 ,0})
      aAdd(::aEstru,{"UPDATE"  ,"C",10,0})
      aAdd(::aEstru,{"DT_UPD"  ,"D",8 ,0})
      aAdd(::aEstru,{"HORA"    ,"C",5 ,0})
      aAdd(::aEstru,{"ALIAS"   ,"C",3 ,0})
      aAdd(::aEstru,{"OLDRECNO","N",9 ,0})
      aAdd(::aEstru,{"NEWRECNO","N",9 ,0})

   Return Self
   
   Method GrvBackUp(cAliasDic,nOldRec,nNewRec) Class AvUpdBkp01
      Local cOldAlias := Alias()
      
      If !::lError
         RecLock("AVUPDBKP",.T.)
         AVUPDBKP->CODIGO   := ::cCodBkp
         AVUPDBKP->UPDATE   := ::cUpdate
         AVUPDBKP->DT_UPD   := date()
         AVUPDBKP->HORA     := time()
         AVUPDBKP->ALIAS    := cAliasDic
         AVUPDBKP->OLDRECNO := nOldRec
         AVUPDBKP->NEWRECNO := nNewRec
         AVUPDBKP->(MsUnLock())
      EndIf

      If !Empty(cOldAlias)
         dbSelectArea(cOldAlias)
      EndIf
   Return nil
   
   Method Recupera(cCodBkp) Class AvUpdBkp01
      Local cOldAlias := Alias()
      Local cTexto := ""
      
      if !::lError
      
         Set(_SET_DELETED,.F.)
      
         AVUPDBKP->(dbSeek(cCodBkp))
         cTexto := "Revertida atualização do update "+AVUPDBKP->UPDATE
         Do While AVUPDBKP->(!EoF() .AND. CODIGO == cCodBkp)
            If ChkFile(AVUPDBKP->ALIAS)
               dbSelectArea(AVUPDBKP->ALIAS)
            
               If AVUPDBKP->NEWRECNO > 0
                  dbGoTo(AVUPDBKP->NEWRECNO)
                  RecLock(AVUPDBKP->ALIAS,.F.,.T.)
                  dbDelete()
                  MsUnLock()
               EndIf
            
               If AVUPDBKP->OLDRECNO > 0
                  dbGoTo(AVUPDBKP->OLDRECNO)
                  If Deleted()
                     RecLock(AVUPDBKP->ALIAS,.F.)
                     dbRecall()
                     MsUnLock()
                  EndIf
               EndIf
            EndIf
            
            RecLock("AVUPDBKP",.F.)
            AVUPDBKP->(dbDelete())
            AVUPDBKP->(MsUnLock())
            
            AVUPDBKP->(dbSkip())
         EndDo
         
         Set(_SET_DELETED,.T.)
      EndIf
      
      If !Empty(cOldAlias)
         dbSelectArea(cOldAlias)
      EndIf
      
   Return cTexto
   
   Method GetMainFunction() Class AvUpdBkp01
      Local i := 1, cFunction
      
      Do While !Empty(procname(i))
         i++
      EndDo
      
      If left(procname(i-1),2) == "U_"
         cFunction := SubStr(procname(i-1),3)
      Else
         cFunction := procname(i-1)
      EndIf
      
   Return cFunction

   Method Recuperacao() Class AvUpdBkp01
      Local cTexto := ""
      
      Define MsDialog oDlg Title "Selecione a atualização a ser revertida." From 3,0 to 340,417 Pixel

         //Tamanho da tela
         nAltura  := int((oDlg:nBottom-oDlg:nTop)/2)
         nLargura := int((oDlg:nRight-oDlg:nLeft)/2)
         
         //Separação da tela em dois paineis com 20% e 80% da tela respectivamente
         oPanel1 := TPanel():New(0, 0, "",oDlg, , .F., .F., , , nLargura, 9*nAltura/10, , )
         oPanel2 := TPanel():New(0, 0, "",oDlg, , .F., .F., , , nLargura, 1*nAltura/10, , )

         oPanel2:Align := CONTROL_ALIGN_BOTTOM
         oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

         aCampos := {{"MARCA" ,,""},;
                     {"CODIGO",,"Codigo Atualizacao"},;
                     {"UPDATE",,"Programa Update"},;
                     {"DT_UPD",,"Data da Atualizacao"},;
                     {"HORA"  ,,"Hora"} }
         
         aStru := AVUPDBKP->(dbStruct())
         aAdd(aStru,{"MARCA","C",2,0})

         cWorkFile := E_CriaTrab(,aStru, "WORK") //THTS - 28/09/2017 - TE-6431 - Temporario no Banco de Dados

         AVUPDBKP->(dbGoTop())
         AVUPDBKP->(dbEval({||WORK->(dbAppend()),AvReplace("AVUPDBKP","WORK")},{||AVSeekLast(CODIGO)}))
         WORK->(dbGoTop())
         
         Private cMarca := GetMark()
         
         oMsSelect := MsSelect():New("WORK","MARCA",,aCampos,,cMarca,{0,0,2.25*nAltura/5,nLargura},,,oPanel1)
         oMsSelect:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
         oMsSelect:bAval := {|| if(Empty(WORK->MARCA),WORK->MARCA := cMarca,WORK->MARCA := ""),oMsSelect:oBrowse:Refresh()}

         lRecupera := .F.
         Define SButton From 0,145+30 Type 1 Action (lRecupera := .T.,oDlg:End()) Enable Of oPanel2 Pixel
	     Define SButton From 0,145 Type 2 Action oDlg:End() Enable Of oPanel2 Pixel
	  Activate MsDialog oDlg Center	
      If lRecupera
         WORK->(dbEval({|| cTexto += ::Recupera(CODIGO) },{|| !Empty(WORK->MARCA) }))
      EndIf
      
   Return cTexto

Method AbreMenu(cModulo) Class AvUpdate01
Local aMenu
Local cFile, cLine := "" , hFile, nSize, lRet:= .T.
Local nLidos := 0

Begin Sequence

   If aScan(Self:aMenuData,{|X| X[1] == cModulo}) > 0
      Break
   Else
      aAdd(Self:aMenuData,{cModulo,{},.F.})
      aMenu := Self:aMenuData[Len(Self:aMenuData)][2]
   EndIf

   //Seleciona o arquivo de menu a ser alterado.
   cFile := cModulo + ".xnu"

   hFile := EasyOpenFile(cFile,FO_READWRITE)                    

   IF fError() <> 0
      lRet := .F.
      Break
   Endif

   //Verifica o Tamaqnho total do arquivo
   nSize := fSeek(hFile,0,2)

   //Posiciona no Inicio do Arquivo
   FSeek(hFile,0)      
   ProcRegua(nSize)
   //Carrega o arquivo.
   Do While nLidos < nSize
      IncProc("Carregando arquivo: " + Alltrim(cFile))
      nLidos += Self:LerLinha(hFile,@cLine,nSize)
      IF Empty(cLine)
         Loop
      Endif
      aAdd(aMenu,Alltrim(cLine)) 
   EndDo

   //Fecha arquivo
   FClose(hFile)
   
End Sequence

Return lRet

Method MenuBackup(cModulo) Class AvUpdate01
Local cDir,cArquivo
Local lRet := .T.

Begin Sequence

   cDir:=Upper(GetSrvProfString("STARTPATH",""))
   cArquivo := cDir+cModulo+"_OLD.XNU"
   If File(cArquivo)
      FErase(cArquivo)
   EndIf

   //Renomeia o menu antigo
   FRename(cDir+cModulo + ".XNU", cDir+cModulo + "_OLD.XNU")

   IF fError() <> 0
      ::Error("Não foi encontrado o arquivo " + cModulo + ".xnu.")
      lRet := .F.
      Break
   EndIf
      
End Sequence

Return lRet
               
Method CriaMenu(cModulo) Class AvUpdate01
Local hFile, cFile, nPos, aMenu, nInc
Local cBuffer := ""
Local lRet    := .T.

Begin Sequence

   If (nPos := aScan(Self:aMenuData,{|X| X[1] == cModulo})) > 0
      aMenu := Self:aMenuData[nPos][2]
      
      cFile := cModulo + ".xnu"
      hFile := EasyCreateFile(cFile,0)
      
      IF fError() <> 0
         ::Error("Não foi possível criar o arquivo"+cFile+".")
         lRet := .F.
         Break
      EndIf
      
      ProcRegua(len(aMenu))
      
      For nInc := 1 to Len(aMenu)
         IncProc("Atualizando Menu" + AllTrim(cModulo) + "... ")      
         cBuffer += aMenu[nInc] + ENTER
      Next

      Fwrite(hFile,cBuffer,Len(cBuffer))  
      
      IF fError() <> 0
         ::Error("Não foi possível carregar o arquivo"+cFile+".")
         lRet := .F.
         Break
      EndIf
      
      fClose(hFile) 
   EndIf
   
End Sequence

Return lRet

Method GravaMenuItem(lDel,aDados,aStrut,aIgnora,aObrig) Class AvUpdate01
Local n, i, j , k, nPos
Local lObrig := .T.
Local lCaminho := .T.
Local nModulo, cModulo 
Local nOcor
Default lDel := .F.

Begin Sequence
   
   //Valida se os campos da chave estão preenchidos
   If !lDel    
      aCampo := {"Modulo","Function"}
      For j := 1 To Len(aCampo)
         If Empty(aDados[aScan(aStrut,{|X| Upper(AllTrim(X[1])) == Upper(AllTrim(aCampo[j]))})])
            ::Error("Falha no update - Campo "+AllTrim(aCampo[j])+" não especificado para item de menu.")
            lObrig:=.F.
            EXIT
         EndIf
      Next j
   EndIf
            
   nModulo := aDados[aScan(aStrut,{|X| Upper(AllTrim(X[1])) == "MODULO"})]
   cModulo := ConvMod(nModulo)
   If !Self:AbreMenu(cModulo)
      ::Error("Não foi encontrado o arquivo " + cModulo + ".xnu.")
      Break
   EndIf
      
   aMenu  := ::aMenuData[aScan(::aMenuData,{|X| X[1] == cModulo})][2]
      
   nPosCam  := aScan(aStrut,{|X| Upper(AllTrim(X[1])) == "CAMINHO"})
   If nPosCam > 0 .AND. !Empty(aCaminho := aDados[nPosCam]) .And. !Empty(aMenu)
      aRange := {1,Len(aMenu)}
      For j:=1 To Len(aCaminho)
         nOcor := 0
         For k := 1 To j
            If Upper(AllTrim(aCaminho[j])) == Upper(AllTrim(aCaminho[k]))
               nOcor++
            EndIf
         Next k
      
         aRange:= FindPosTag(aMenu, "Menu",aRange, aCaminho[j],nOcor)
         If Empty(aRange)
            ::Error("O caminho '" + AllTrim(aCaminho[j]) +  "' informado não se encontra no menu: " + cModulo + ".")
            lCaminho := .F.
         EndIf
         If !lCaminho
            Break
         EndIf
      Next j
   EndIf
      
   aDadosOld := BuscaDados(aMenu,MenuStruct(),aDados[aScan(aStrut,{|X| Upper(AllTrim(X[1])) == "FUNCTION"})])
      
   aDadosNew := {}
   aMnuStr := MenuStruct()
   For j := 1 To Len(aMnuStr)
      if (nPosStr := aScan(aStrut,{|Y| AllTrim(Y[1]) == AllTrim(aMnuStr[j][1])})) >0
         aAdd(aDadosNew,aDados[nPosStr])
      Else
         aAdd(aDadosNew,NIL)
      EndIf
   Next j
      
   lFound  := Len(aDadosOld) > 0
      
   If !lObrig .AND. !lDel
      lAtu   := .F.
   Else
      lAtu   := .F.
		 
      If lFound
         If !lDel
            For n:=1 to Len(MenuStruct())
               //Manter campos restantes com conteudo atual e o conteudo dos parametros já existentes.
               If ValType(aDadosNew[n]) == "U" .OR. aScan(aIgnora,{|X| AllTrim(MenuStruct()[n]) == AllTrim(X)}) > 0//::cAliSx == "SX6" .AND. ::aStruSX[n] $ "X6_CONTEUD/X6_CONTSPA/X6_CONTENG"
                  aDadosNew[n] := aDadosOld[n]
               ElseIf ValType(aDadosOld[n]) == "C" .AND. ValType(aDadosOld[n]) == ValType(aDadosNew[n]) .AND. !(aDadosOld[n] = aDadosNew[n])
                  lAtu := .T.
               ElseIf ValType(aDadosOld[n]) == "A" .AND. ValType(aDadosOld[n]) == ValType(aDadosNew[n]) .AND.;
                      (Len(aDadosOld[n]) <> Len(aDadosNew[n]) .OR. (aEval(aDadosOld[n],{|X,k| lAtu := lAtu .OR. !Upper(AllTrim(X)) == Upper(AllTrim(aDadosNew[n][k]))}),lAtu))
                      lAtu := .T.
               EndIf
            Next n
         Else
            lAtu := .T.
         EndIf
      ElseIf !lDel
         //Valida se os campos obrigatorios para inclusão estão preenchidos
         For j := 1 To Len(aObrig)
            nPos := aScan(MenuStruct(),{|X| Upper(AllTrim(X[1])) == Upper(AllTrim(aObrig[j]))})
            if nPos == 0 .OR. Empty(aDadosNew[nPos]) 
               ::Warning("Inclusão de menu - Campo "+AllTrim(aObrig[j])+" não especificado.")
               lObrig:=.F.
               EXIT
            EndIf
         Next j
            
         For j := 1 To Len(MenuStruct())
            If !Empty(MenuStruct()[j][5]) .AND. Empty(aDadosNew[j])
               aDadosNew[j] := MenuStruct()[j][5]
            ENdIf
         Next j
            
         lAtu := .T.
      EndIf
   EndIf
      
   If lAtu
      Self:AtuMenu(aMenu,aDadosNew,lDel)
         
      bMsg := {|aSX| ' Menu: '  + AllTrim(ConvMod(aSX[1])) + ' Titulo: ' + AllTrim(aSX[5,1]) + ' Função: ' + AllTrim(aSX[2]) }
      If lFound
         //::cTexto += Eval(bMsg,aDadosNew) + ENTER
		 ::Warning(Eval(bMsg,aDadosNew) + ENTER)
      Else
         //::cTexto += Eval(bMsg,aDadosNew) + ENTER
		 ::Warning(Eval(bMsg,aDadosNew) + ENTER)
      EndIf
      Eval(bAtuTela)   
      Self:aMenuData[aScan(Self:aMenuData,{|X| X[1] == cModulo})][3] := .T.

      ::lAtualizado := .T. 
   EndIf

End Sequence

Return .T.

Method GravaDir(aDados,aStruct) Class AvUpdate01
Local cDiretorio := ""
Local cBarra     := "\"
Local cAtual     := ""
Local cHistorico := ""
Local cAux       := ""
Local cRootPath  := Lower(GetSrvProfString("ROOTPATH","")) + cBarra
Local nPosCam    := 0
Local nPos       := 0
Local nRet       := 0
Local lRet       := .F.

Begin Sequence

   If IsSrvUnix()
      cBarra := "/"
   EndIf

   nPosCam := aScan(aStruct,{|X| Upper(AllTrim(X)) == "CAMINHO_DIRETORIO"})
   If nPosCam > 0
      cDiretorio := Lower(aDados[nPosCam])
   EndIf

   cDiretorio := StrTran(cDiretorio, Replic(cBarra,2),cBarra)

   If (nPos := At(cBarra, cDiretorio)) < Len(cDiretorio)
      cDiretorio := cDiretorio + cBarra
   EndIf

   If (nPos := At(cBarra, cDiretorio)) > 1
      cDiretorio := cBarra + cDiretorio
   EndIf

   cDiretorio := StrTran(cDiretorio, Replic(cBarra,2),cBarra) // FDR - 05/02/13 - Tratamento das barras duplicadas tambem apos das verificações

   nPos := 1
   // If !lIsDir(cDiretorio)
   If !EasyIsDir(cDiretorio,cBarra) //FDR - 05/02/13 - A função lIsDir na chamada com o ambiente em Linux nao funciona corretamente, pois a função Directory nao esta retornando corretamente o vetor de diretorios.

      Do While nPos > 0 .AND. !::lSimula
         // Criando cada diretorio da string
         cAux       := Lower(SubStr(cDiretorio, nPos+1, Len(cDiretorio)))
         cAtual     := cBarra + Lower(SubStr(cAux, 1, At(cBarra,cAux) - 1 ))
         cHistorico += cAtual
         cDiretorio := StrTran(cDiretorio, cAtual,"")
         If !Empty(cDiretorio)
            nRet := MakeDir(cHistorico)
         EndIf
         nPos := At(cBarra, cDiretorio)
      EndDo

      If nRet != 0
         //::cTexto += "O diretório '" + AllTrim(Lower(aDados[nPosCam])) + "' não pode ser criado devido ao retorno '" + AllTrim(Str(nRet)) + "' da função MakeDir()." + ENTER
		 ::Warning("O diretório '" + AllTrim(Lower(aDados[nPosCam])) + "' não pode ser criado devido ao retorno '" + AllTrim(Str(nRet)) + "' da função MakeDir()." + ENTER)
      Else
         //::cTexto += "O diretório '" + AllTrim(Lower(aDados[nPosCam])) + "' foi criado com sucesso." + ENTER
		 ::Warning("O diretório '" + AllTrim(Lower(aDados[nPosCam])) + "' foi criado com sucesso." + ENTER)
         ::lAtualizado := .T.
         lRet := .T.
      EndIf
      Eval(bAtuTela)
   EndIf

End Sequence

Return lRet


Method GravaHelp(aDados,aStruct) Class AvUpdate01
Local cTipo := "" , cNome := "" , cHelp := "" , cCpoAtu := ""
Local nPosNome := 0 , nPosProb := 0 , nPosSol := 0 
Local lRet := .F.

Begin Sequence

   nPosNome := aScan(aStruct,{|X| Upper(AllTrim(X)) == "NOME"})
   nPosProb := aScan(aStruct,{|X| Upper(AllTrim(X)) == "PROBLEMA"})
   nPosSol  := aScan(aStruct,{|X| Upper(AllTrim(X)) == "SOLUCAO"})
   
   If nPosNome > 0 .And. !Empty(aDados[nPosNome])
      cNome := aDados[nPosNome]
   EndIf

   If nPosProb > 0 .And. !Empty(aDados[nPosProb])
      cTipo   := "P"
      cHelp   := aDados[nPosProb] 
      cCpoAtu := AcertaHelp(cNome,cHelp,cTipo)
      If Len(cCpoAtu) > 0
         //::cTexto += "O help problema '" + AllTrim(Upper(aDados[nPosNome])) + "' foi atualizado com: '" + AllTrim(cCpoAtu) +"'."+ ENTER
		 ::Warning("O help problema '" + AllTrim(Upper(aDados[nPosNome])) + "' foi atualizado com: '" + AllTrim(cCpoAtu) +"'."+ ENTER)
         ::lAtualizado := .T.
         lRet := .T. 
         Eval(bAtuTela)
      EndIf
   EndIf
   
   If nPosSol > 0 .And. !Empty(aDados[nPosSol])
      cTipo   := "S"
      cHelp   := aDados[nPosSol]
      cCpoAtu := AcertaHelp(cNome,cHelp,cTipo)
      If Len(cCpoAtu) > 0
         //::cTexto += "O help solucao '" + AllTrim(Upper(aDados[nPosNome])) + "' foi atualizado com: '" + AllTrim(cCpoAtu) +"'."+ ENTER
		 ::Warning("O help solucao '" + AllTrim(Upper(aDados[nPosNome])) + "' foi atualizado com: '" + AllTrim(cCpoAtu) +"'."+ ENTER)
         ::lAtualizado := .T.
         lRet := .T.
         Eval(bAtuTela)
      EndIf 
   EndIf

End Sequence

Return lRet
 
Static Function BuscaDados(aMenu,aStrut,cFunction)
Local aReg := {}
Local nPosIni, nPosFim, nPos, i, j

aRange := FindPosTag(aMenu, "MenuItem", {1,Len(aMenu)}, cFunction)

If Len(aRange) > 0
   nPosIni := aRange[1]
   nPosFim := aRange[2]
   
   aReg := Array(Len(aStrut))
   
   For i := 1 To Len(aStrut)
      
      If ValType(aStrut[i][2]) <> "U"
      
         nPos := nPosIni
         Do While nPos <= nPosFim
            
            aStru := aClone(aStrut[i])
            If ValType(aStrut[i][2]) == "C"
               aStru[2] := {aStru[2]}
            EndIf
            
            For j := 1 To Len(aStru[2])
               If (nAt1 := At(Upper("<"+aStru[2][j]+">"),Upper(aMenu[nPos]))) > 0 .AND.;
                  (nAt2 := At(Upper("</"+If( (nAt:=At(" ",aStru[2][j])) >0 , SubStr(aStru[2][j],1, nAt - 1) ,  aStru[2][j])+">"),Upper(aMenu[nPos]))) > 0
                  nAt1 += At(">",SubStr(Upper(aMenu[nPos]),nAt1))
            
                  If aStru[3] == "A"
                     If ValType(aReg[i]) <> "A"
                        aReg[i] := {}
                     EndIf
                     aAdd(aReg[i],SubStr(aMenu[nPos],nAt1,nAt2-nAt1))
                  Else
                     aReg[i] := SubStr(aMenu[nPos],nAt1,nAt2-nAt1)
                  EndIf
               EndIf
            Next j
            
            nPos++
         EndDo
      EndIf
   Next i
      
EndIf

Return aClone(aReg)

Method AtuMenu(aMenu,aDados,lDel) Class AvUpdate01
Local nPosFunc, nCont, nPosFim := 0, nPosIni:= 1, nTab := 2, nOcor
Local nPosPai := 0, aPos := {}
Local i := 0, j := 0, k := 0
Local aCaminho := {}
Local cTexto := ""

// Procurando a nova função
aPos := FindPosTag(aMenu, "MenuItem", {1,Len(aMenu)}, aDados[aScan(MenuStruct(),{|X| Upper(AllTrim(X[1])) == "FUNCTION"})])

If !Empty(aPos)
   nPosIni := aPos[1]
   nPosFim := aPos[2]

   For i := 1 To nPosFim-nPosIni+1
      aDel(aMenu,nPosIni)
   Next i
   aSize(aMenu,Len(aMenu)-(nPosFim-nPosIni+1))
EndIf

// Procurando a função superior caso necessario
If nPosFim == 0
   aPos := FindPosTag(aMenu, "MenuItem", {1,Len(aMenu)}, aDados[aScan(MenuStruct(),{|X| Upper(AllTrim(X[1])) == "FUNCAO_SUPERIOR"})])
   If !Empty(aPos)
      nPosIni := aPos[2]+1
      nPosFim := aPos[2]
   EndIf
Endif

// Procurando pelo Caminho
aCaminho := aDados[aScan(MenuStruct(),{|X| Upper(AllTrim(X[1])) == "CAMINHO"})]
If nPosFim == 0 .AND. !Empty(aCaminho)   
   aRange := {1 , Len(aMenu)}
   For i := 1 To Len(aCaminho)
      nOcor := 0
      For k := 1 To i
         If Upper(AllTrim(aCaminho[i])) == Upper(AllTrim(aCaminho[k]))
            nOcor++
         EndIf
      Next k

      aRange := FindPosTag(aMenu, "Menu", aRange, aCaminho[i],nOcor)
   Next
   
   If !Empty(aRange)
      nPosIni := aRange[2]
      nPosFim := nPosIni-1
   EndIf
EndIf

If nPosFim > 0 .AND. !lDel
      
   If !Empty(aCaminho)
      nTab := Len(aCaminho)
   EndIf
   
   aAdd(aMenu,NIL)
   aAdd(aMenu,NIL)
   
   aIns(aMenu,nPosIni)
   aIns(aMenu,nPosIni)
   
   aMenu[nPosIni]   := Replic(CHR(9),nTab+1) + '<MenuItem Status="Enable">'
   aMenu[nPosIni+1] := Replic(CHR(9),nTab+1) + '</MenuItem>'
   
   aStruOrd := aClone(MenuStruct())
   aStruOrd := ASORT(aStruOrd,,,{|X,Y| X[4] < Y[4]})
   
   nCont := 0
   For i := 1 To Len(aStruOrd)
   
      k := aScan(MenuStruct(),{|X| X[1] == aStruOrd[i][1]})
      
      If aStruOrd[i][3] == "C"
         cTexto := "<"+aStruOrd[i][2]+">"+AvConvert(ValType(aDados[k]),"C",,aDados[k])+"</"+ If((nAt:=At(" ",aStruOrd[i][2])) > 0,SubStr(aStruOrd[i][2],1,nAt-1),aStruOrd[i][2]) + ">"
         
         aAdd(aMenu,NIL)
         aIns(aMenu,nPosIni+1+nCont)
         aMenu[nPosIni+1+nCont] := Replic(CHR(9),nTab+2) + cTexto
         nCont++
      ElseIf aStruOrd[i][3] == "A"
         
         If ValType(aStruOrd[i][2]) <> "A"
            aStruct := Array(Len(aDados[k]))
            aFill(aStruct,aStruOrd[i][2])
         Else
            aStruct := aStruOrd[i][2]
         EndIf
         
         For j := 1 To Len(aStruct)
            cTexto := "<"+aStruct[j]+">"+aDados[k][j]+"</"+If((nAt:=At(" ",aStruct[j])) > 0,SubStr(aStruct[j],1,nAt-1),aStruct[j]) +">"
         
            aAdd(aMenu,NIL)
            aIns(aMenu,nPosIni+1+nCont)
            aMenu[nPosIni+1+nCont] := Replic(CHR(9),nTab+2) +  cTexto
            nCont++
         Next j
      EndIf
               
   Next i
        
EndIf

Return Nil

Static Function ConvMod(xModulo)
Local nPosMod := 0 
Local cModulo
Local aVar := {{"SIGAEIC",17},;
               {"SIGAEEC",29},; 
               {"SIGAEDC",50},;
               {"SIGAEFF",30},;
               {"SIGAECO",31},;
               {"SIGAESS",85}} //RRC - 03/07/2013

   If Empty(xModulo)
      cModulo := ""
   ElseIf ValType(xModulo) == "N"
      nPosMod := aScan(aVar,{|X| X[2] == xModulo})
      cModulo := aVar[nPosMod][1]
   ElseIf ValType(xModulo) == "C"
      cModulo := xModulo
   EndIf

Return cModulo

Static Function FindPosTag(aMenu, cTag, aRange, cDescr, nOcorrencia)
Local nPosFim := 0, nPosIni := 0
Local aRet := {}, nPosDescr := 0, nSaldo := 0
Local i:=0
Default nOcorrencia := 1

Begin Sequence

   If !Empty(cDescr)
      For i := 1 To nOcorrencia
         nPosDescr := aScan(aMenu,{|X| AllTrim(Upper(cDescr)) $ AllTrim(Upper(X))},Max(aRange[1],nPosDescr+1),aRange[2])
      Next i
   Else
      aRet := {}
      BREAK
   EndIf

   nPosIni := nPosDescr
   Do While nPosIni >= aRange[1]
      If Upper("<" + cTag + " ") $ AllTrim(Upper(aMenu[nPosIni]))
         nSaldo := 1
         EXIT
      EndIf
      nPosIni--
   EndDo

   If nPosIni < aRange[1]
      aRet := {}
      BREAK
   EndIf
   
   nPosFim := nPosDescr-1
   
   // FSM - 01/11/2011
   Do While nPosFim < aRange[2] .AND. nSaldo > 0
      nPosFim++
      If Upper("<" + cTag + " ") $ AllTrim(Upper(aMenu[nPosFim]))
         nSaldo++
      EndIf
      If Upper("</" + cTag + ">") $ AllTrim(Upper(aMenu[nPosFim]))
         nSaldo--
      EndIf
   EndDo

   If nPosFim > aRange[2]
      aRet := {}
      BREAK
   EndIf

   aRet := {nPosIni,nPosFim}
End Sequence

Return aClone(aRet)

Static Function BuscaHelp(cCampo, cTipo)
Local i := 0
Local cRet := ""
Local aHelp
Local cArqHlp := RetHlpFile()

If Empty(cCampo)
   cCampo := ""
EndIF

aHelp := ReadHelp(cArqHlp,cCampo,cTipo)

For i := 1 to Len(aHelp)
//   cRet += AllTrim(aHelp[i])+If(!Empty(aHelp[i]),CHR(13)+CHR(10),"")
   cRet += aHelp[i]
Next

Return cRet

Static Function SetX3Uso(cUsado, aModIn, aModOut, lTodos,lOnlyIn, lChave)
Local nInc
Default lOnlyIn := .F.
Default aModIn  := {}
Default aModOut := {}

If ValType(cUsado) <> "C"
   Return Nil
EndIf

If ValType(aModIn) == "N"
   aModIn := {aModIn}
EndIf
If ValType(aModOut) == "N"
   aModOut := {aModOut}
EndIf

If (ValType(lTodos) == "L" .Or. Len(aModIn) > 0 .Or. Len(aModOut) > 0 .OR. ValType(lChave) == "L")
   //*** Converte o conteúdo para String tratável.
   cUsado := X3TreatUso(cUsado)
   cUsado := FirstBitOff(cUsado)
   //***
   
   If ValType(lTodos) == "L"
      //Marca a opção 'Usado por Todos os Módulos'.
      
      cUsaux := Space(100)
      cUsado := Stuff(cUsado, 1, 100, cUsaux)   
      
      //For nInc := 1 To 100
      //   cUsado := Left(cUsado, nInc - 1) + " " + SubStr(cUsado, nInc + 1) //BCO 09/04/12
      //Next
      
      //Desmarca o uso do campo em módulos específicos.
      If Empty(SubStr(cUsado, 100, 1))
         cUsado := Left(cUsado, 99) + If(lTodos, "x", " ") + SubStr(cUsado, 101)
      EndIf
   Else
      //Remove o usado dos outros módulos
      If lOnlyIn
         cUsaux := Space(100)
         cUsado := Stuff(cUsado, 1, 100, cUsaux)  //BCO - 09/04/12
         //For nInc := 1 To 100
         //   cUsado := Left(cUsado, nInc - 1) + " " + SubStr(cUsado, nInc + 1)
         //Next
      EndIf
      //Marca o campo como usado nos módulos informados.
      For nInc := 1 To Len(aModIn)
         cUsado := Left(cUsado, aModIn[nInc] - 1) + "x" + SubStr(cUsado, aModIn[nInc] + 1)
      Next
      //Remove o uso dos campos nos módulos informados.
      For nInc := 1 To Len(aModOut)
         cUsado := Left(cUsado, aModOut[nInc] - 1) + " " + SubStr(cUsado, aModOut[nInc] + 1)
      Next
      //Desmarca a opção 'Usado por Todos os Módulos'.
      If (Len(aModIn) > 0 .Or. Len(aModOut) > 0) .And. !Empty(SubStr(cUsado, 100, 1))
         cUsado := Left(cUsado, 99) + " " + SubStr(cUsado, 101)
      EndIf
   EndIf
   
   If ValType(lChave) == "L"
      cUsado := Left(cUsado, 100) + if(lChave,"x"," ") + SubStr(cUsado, 102)
   EndIf
   
   //*** Retorna string ao formato anterior.
   cUsado := FirstBitOn(cUsado)
   cUsado := X3TreatUso(cUsado)
   //***
   
EndIf 

Return cUsado

/* DESCONTINUADA ATUALIZAÇÂO DE DICIONARIOS NO PROTHEUS 12 VIA PROGRAMA
Static Function AcertaOrdem(aStruct,aDados, lInclui)
Local nPosOrd := aScan(aStruct,{|X| AllTrim(X) == "X3_ORDEM"})
Local nPosArq := aScan(aStruct,{|X| AllTrim(X) == "X3_ARQUIVO"})
Local nOrd := IndexOrd()

If nPosOrd > 0 .AND. nPosArq > 0 .AND. !Empty(aDados[nPosArq]) .AND. Empty(aDados[nPosOrd])
   
   If lInclui
      dbSetOrder(1)
      AvSeekLast(aDados[nPosArq])   
      aDados[nPosOrd] := RetAsc(Val(RetAsc(SX3->X3_ORDEM,2,.F.))+1,2,.T.)
	  dbSetOrder(nOrd)
   Else
      aDados[nPosOrd] := NIL
   EndIf
EndIf

Return .T.
*/

/* DESCONTINUADA ATUALIZAÇÂO DE DICIONARIOS NO PROTHEUS 12 VIA PROGRAMA
Static Function AcertaTamanho(aStruct,aDados)
Local nPosGrp := aScan(aStruct,{|X| AllTrim(X) == "X3_GRPSXG"})
Local nPosTam := aScan(aStruct,{|X| AllTrim(X) == "X3_TAMANHO"})
Local nPosCpo := aScan(aStruct,{|X| AllTrim(X) == "X3_CAMPO"})
Local aOrd := SaveOrd({"SX3","SXG"})
Local cGrpCpo := ""

If nPosTam > 0 .And. ValType(aDados[nPosTam]) <> "U"
   If nPosGrp > 0
      cGrpCpo := aDados[nPosGrp]
   Else
      SX3->(DbSetOrder(2))
      If SX3->(DbSeek(AvKey(aDados[nPosCpo],"X3_CAMPO")))
         cGrpCpo := SX3->X3_GRPSXG
      EndIf
   EndIf

   If !Empty(cGrpCpo) .And. SXG->(DbSeek(AvKey(cGrpCpo,"XG_GRUPO")))
      aDados[nPosTam] := SXG->XG_SIZE
   EndIf

EndIf

RestOrd(aOrd,.T.)

Return .T.
*/

/* DESCONTINUADA ATUALIZAÇÂO DE DICIONARIOS NO PROTHEUS 12 VIA PROGRAMA
Static Function AcertaArquivo(aStruct,aDados)
Local cArquivo := ""
Local nPosChv  := aScan(aStruct,{|X| AllTrim(X) == "X2_CHAVE"})
Local nPosArq  := aScan(aStruct,{|X| AllTrim(X) == "X2_ARQUIVO"})
Local nOrd     := IndexOrd()

If nPosChv > 0 .And. nPosArq > 0 .And. !Empty(aDados[nPosChv])// .And. !Empty(aDados[nPosArq]) - AAF - 24/09/2012 - Campo arquivo pode gravado automaticamente.
   SX2->(DbSetOrder(1))
   SX2->(DbSeek("EEC"))
   cArquivo := SubStr(RetSQLName("EEC"),Len(aDados[nPosChv])+1,Len(RetSQLName("EEC")))
   aDados[nPosArq] := aDados[nPosChv] + cArquivo
EndIf

dbSetOrder(nOrd)

Return .T.
*/

Static Function ReadHelp( cFile, cCampo, cTipo)
Local cChaveP   := ''
Local cChave1	:= ''
Local cChave2	:= ''
Local cChave3	:= ''
Local cHelp		:= ''
Local aHelp		:= {}
Local nRet, cX, nAT
Local lError	:= .F.
Local ni

cChaveP := cTipo+AllTrim(cCampo)
nRet := SPF_SEEK( cFile, cChaveP, 1 )
If nRet > 0
   lError := .F.
   If ( SPF_GETFIELDS( cFile, nRet, @cChave1, @cChave2, @cChave3, @cHelp) < 0 )
      lError := .T.
   EndIf
EndIf              

IF !lError .and. Subs(cHelp,1,1) == chr(255) //Pega o Help que fica no lugar
   cX := Subs(cHelp,2)
   nAT := AT(Chr(255),cX)
   cX := Alltrim(Subs(cX,1,nAT-1))
   cChaveP := cTipo+AllTrim(cX)
   nRet := SPF_SEEK( cFile, cChaveP, 1 )
   If nRet > 0
      lError := .F.
      If ( SPF_GETFIELDS( cFile, nRet, @cChave1, @cChave2, @cChave3, @cHelp) < 0 )
         lError := .T.
      EndIf
   EndIf
Endif	   

cHelp := RTrim(Strtran(cHelp,CHR(198),"„"))
For ni := 1 to Len(cHelp) STEP 40
   cLine := Subs(cHelp,ni,40)
   cLine := Padr(cLine,40)
   AADD(aHelp,cLine)
Next

Return aClone(aHelp)

/* DESCONTINUADA ATUALIZAÇÂO DE DICIONARIOS NO PROTHEUS 12 VIA PROGRAMA
Static Function AcertaUsado(aStruct,aDados)
Local nPos
Local cStrUsado
Local nOrd := IndexOrd()
Local lRet := .T.
Local cPar

nPos   := aScan(aStruct,{|X| AllTrim(X) == AllTrim("X3_USADO")})

If nPos > 0

   nPosCp := aScan(aStruct,{|X| AllTrim(X) == AllTrim("X3_CAMPO")})
   SX3->(dbSetOrder(2))
   SX3->(dbSeek(aDados[nPosCp]))


   //NCF - 26/07/2018 - Fazer a transformação correta do USADO quando dicionários no banco e LocalFiles = SQLITE
   cStrUsado := if(!Empty(SX3->X3_USADO), If( lSXBanco , X3TreatUso(SX3->X3_USADO) , SX3->X3_USADO ) ,"€€€ð€€À€€€€€€€")
   aDados[nPos] := alltrim(aDados[nPos])
   
    cPar := aDados[nPos]

    If EIC_USADO $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado, EIC)
    EndIf
    If EEC_USADO $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado, EEC)
    EndIf
    If EDC_USADO $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado, EDC)
    EndIf
    If ECO_USADO $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado, ECO)
    EndIf
    If EFF_USADO $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado, EFF)
    EndIf
    If ESS_USADO $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado, ESS)
    EndIf
    If EIC_NUSADO $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado,, {EIC})
    EndIf
    If EEC_NUSADO $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado,, {EEC})
    EndIf
    If EDC_NUSADO $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado,, {EDC})
    EndIf
    If ECO_NUSADO $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado,, {ECO})
    EndIf
    If EFF_NUSADO $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado,, {EFF})
    EndIf
    If ESS_NUSADO $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado,, {ESS})
    EndIf
    If TODOS_AVG $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado, {EIC, EEC, EFF, ECO, EDC, ESS}) //RRC - 03/07/2013 - Inclusão do ESS
    EndIf
    If TODOS_MODULOS $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado,,, .T.)
    EndIf
    If BASICO_AVG $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado, {EIC, EEC, EDC})
    EndIf
    If NAO_USADO $ aDados[nPos]
        cStrUsado := SetX3Uso(cStrUsado,,, .F.) 
    EndIf

    aDados[nPos] := cStrUsado

   IF CAMPO_NAO_CHAVE $ cPar
      aDados[nPos] := SetX3Uso(aDados[nPos],,,,,.F.)
   ElseIf CAMPO_CHAVE $ cPar
      aDados[nPos] := SetX3Uso(aDados[nPos],,,,,.T.)
   EndIf
   
   aDados[nPos] := If( lSXBanco , X3TreatUso(aDados[nPos]) , aDados[nPos] ) 

   If aDados[nPos] <> NIL .AND. ValType(aDados[nPos]) <> "C"
      lRet := .F.
   EndIf
   
EndIf

SX3->(dbSetOrder(nOrd))

Return lRet
*/

/* DESCONTINUADA ATUALIZAÇÂO DE DICIONARIOS NO PROTHEUS 12 VIA PROGRAMA
//** TDF - 23/03/2011 - Revisão da rotina para acerto do "X3_RESERV"
Static Function AcertaReserv(aStruct,aDados)
Local nPos := aScan(aStruct,{|X| AllTrim(X) == AllTrim("X3_RESERV")})
Local i := 0
Local j := 0
Local nOrd := IndexOrd()
Local lRet := .T.

If nPos > 0 .AND. ValType(aDados[nPos]) == "N"
   
   nPosCp := aScan(aStruct,{|X| AllTrim(X) == AllTrim("X3_CAMPO")})
   If !SX3->(dbSetOrder(2),dbSeek(aDados[nPosCp]))
      SX3->(dbSeek(aDados[nPosCp]))
   EndIf
   
   nValor       := aDados[nPos]
   aDados[nPos] := SX3->X3_RESERV
   
   //aDados[nPos] := Reservado(SX3->X3_RESERV,.F.,/*lAltNome/.T.,/*lAltTipo/.T.,/*lAltTam/.T.,/*lAltDec/.T.,/*lAltOrdem/.T.,/*lObrigat/.T.,/*lAltUso/.T.)

   //AAF 11/09/2014 - O Reserv de ser conforme as opções passadas no tabledata, qualquer opção que não tenha sido passada deve ser desabilitada.
   aDados[nPos] := Reservado("",.F.,/*lAltNome/.T.,/*lAltTipo/.T.,/*lAltTam/.T.,/*lAltDec/.T.,/*lAltOrdem/.T.,/*lObrigat/.T.,/*lAltUso/.T.)
   
   i := 6 //Numero de parametros de reserv
   While nValor > 0
      j := 2^i

      If nValor >= j
         Do Case
            Case j == 1//NOME
               aDados[nPos] := Reservado(aDados[nPos],.T.,/*lAltNome/.T.,/*lAltTipo/,/*lAltTam/,/*lAltDec/,/*lAltOrdem/,/*lObrigat/,/*lAltUso/)
            Case j == 2//TIPO
               aDados[nPos] := Reservado(aDados[nPos],.T.,/*lAltNome/,/*lAltTipo/.T.,/*lAltTam/,/*lAltDec/,/*lAltOrdem/,/*lObrigat/,/*lAltUso/)
            Case j == 4//TAM
               aDados[nPos] := Reservado(aDados[nPos],.T.,/*lAltNome/,/*lAltTipo/,/*lAltTam/.T.,/*lAltDec/,/*lAltOrdem/,/*lObrigat/,/*lAltUso/)
            Case j == 8//DEC
               aDados[nPos] := Reservado(aDados[nPos],.T.,/*lAltNome/,/*lAltTipo/,/*lAltTam/,/*lAltDec/.T.,/*lAltOrdem/,/*lObrigat/,/*lAltUso/)
            Case j == 16//ORDEM
               aDados[nPos] := Reservado(aDados[nPos],.T.,/*lAltNome/,/*lAltTipo/,/*lAltTam/,/*lAltDec/,/*lAltOrdem/.T.,/*lObrigat/,/*lAltUso/)
            Case j == 32//OBRIGAT
               aDados[nPos] := Reservado(aDados[nPos],.T.,/*lAltNome/,/*lAltTipo/,/*lAltTam/,/*lAltDec/,/*lAltOrdem/,/*lObrigat/.T.,/*lAltUso/)
            Case j == 64//USO
               aDados[nPos] := Reservado(aDados[nPos],.T.,/*lAltNome/,/*lAltTipo/,/*lAltTam/,/*lAltDec/,/*lAltOrdem/,/*lObrigat/,/*lAltUso/.T.)
                        
         End Case
         nValor -= j
      EndIf      
      
      i--
   EndDo   

   If aDados[nPos] <> NIL .AND. ValType(aDados[nPos]) <> "C"
      lRet := .F.
   EndIf

EndIf

dbSetOrder(nOrd)

Return lRet
*/
/* DESCONTINUADA ATUALIZAÇÂO DE DICIONARIOS NO PROTHEUS 12 VIA PROGRAMA
*----------------------------------------------------------------------------------------------------*
Static Function Reservado(uReserv,lAtiva,lAltNome,lAltTipo,lAltTam,lAltDec,lAltOrdem,lObrigat,lAltUso)
*----------------------------------------------------------------------------------------------------*
//** TDF - 23/03/2011 - Revisão da rotina para acerto do "X3_RESERV"
 Local cReserv    := ""  ,;
       cReservAx1 := ""  ,;
       cReservAx2 := ""  ,;
       cChar      := ""
 
 Default lAtiva    := .T.

   If lAtiva
      cChar := "x"
   Else
      cChar := " "
   EndIf
   If !MPDicInDB()

      cReservAx1 := Left(&("Bin"+'2'+"Str('"+uReserv+"')"),16)
      cReservAx2 += SubStr(cReservAx1,1,1)
      cReservAx2 += if(ValType(lAltNome) == "L" .AND. lAltNome,  cChar, SubStr(cReservAx1,2,1))
      cReservAx2 += IIF(ValType(lAltTipo) == "L" .AND. lAltTipo,  cChar, SubStr(cReservAx1,3,1))
      cReservAx2 += IIF(ValType(lAltTam) == "L" .AND. lAltTam,   cChar, SubStr(cReservAx1,4,1))
      cReservAx2 += IIF(ValType(lAltDec) == "L" .AND. lAltDec,   cChar, SubStr(cReservAx1,5,1))
      cReservAx2 += SubStr(cReservAx1,6,1)
      cReservAx2 += IIF(ValType(lAltOrdem) == "L" .AND. lAltOrdem, cChar, SubStr(cReservAx1,7,1))
      cReservAx2 += IIF(ValType(lObrigat) == "L" .AND. lObrigat,  cChar, SubStr(cReservAx1,8,1))
      cReservAx2 += SubStr(cReservAx1,9,1)
      cReservAx2 += IIF(ValType(lAltUso) == "L" .AND. lAltUso,   cChar, SubStr(cReservAx1,10,1))
      cReservAx2 += SubStr(cReservAx1,11,6)
      cReservAx2 := Left(FirstBitOff(cReservAx2),8)
      cReserv := &("X3" + "Reserv" + "(cReservAx2)")

   Else

      cReservAx1 := uReserv
      cReservAx2 += if(ValType(lAltNome) == "L" .AND. lAltNome,  cChar, SubStr(cReservAx1,1,1))
      cReservAx2 += IIF(ValType(lAltTipo) == "L" .AND. lAltTipo,  cChar, SubStr(cReservAx1,2,1))
      cReservAx2 += IIF(ValType(lAltTam) == "L" .AND. lAltTam,   cChar, SubStr(cReservAx1,3,1))
      cReservAx2 += IIF(ValType(lAltDec) == "L" .AND. lAltDec,   cChar, SubStr(cReservAx1,4,1))
      cReservAx2 += SubStr(cReservAx1,5,1)
      cReservAx2 += IIF(ValType(lAltOrdem) == "L" .AND. lAltOrdem, cChar, SubStr(cReservAx1,6,1))
      cReservAx2 += IIF(ValType(lObrigat) == "L" .AND. lObrigat,  cChar, SubStr(cReservAx1,7,1))
      cReservAx2 += IIF(ValType(lAltUso) == "L" .AND. lAltUso,   cChar, SubStr(cReservAx1,8,1))
      cReservAx2 += SubStr(cReservAx1,9,8)
      cReserv := cReservAx2
      
   endif

Return cReserv
*/

Static Function MyOpenSM0Ex()
Local lOpen := .F. 
Local nLoop := 0 

Begin Sequence
Do While .T.
   For nLoop := 1 To 5
       OpenSM0Excl() 
	   If !Empty( Select( "SM0" ) ) 
	      lOpen := .T. 
		  dbSetIndex("SIGAMAT.IND") 
		  Exit	
	   EndIf
	   Sleep( 500 ) 
   Next nLoop 

   If !lOpen
      If GetPvProfString("General", "BuildKillUsers", "0", GetAdv97()) == "1" .AND.;
	  MsgYesNo("Parece que há outros usuários ou rotinas agendadas utilizando o sistema. "+;
	  "Para aplicar o update é necessário acesso exclusivo. Deseja derrubar os outros usuários?")
	     aEval(GetUserInfoArray(),{|X| if( !Empty(X[5]) .AND. !Empty(X[6]) .AND. X[3] <> ThreadID(), KillUser(X[1],X[2],X[3],X[6]), ) })
         LOOP
	  EndIf
	  
      Aviso( "Atencao", "Nao foi possível a abertura da tabela de empresas de forma exclusiva.", { "Ok" }, 2 )
   EndIf
   
   EXIT
EndDo

End Sequence

Return(lOpen)


Static Function MenuStruct()
Local aStruSx := {}
   aAdd(aStruSx,{"Modulo","Module","C",6,})
   aAdd(aStruSx,{"Function","Function","C",2,})
   aAdd(aStruSx,{"Caminho",,"U",8,})
   aAdd(aStruSx,{"FUNCAO_SUPERIOR",,"U",9,})
   aAdd(aStruSx,{"Title",{'Title lang="pt"',;
                          'Title lang="es"',;
                          'Title lang="en"'},"A",1,})
   aAdd(aStruSx,{"Type","Type","C",3,})
   aAdd(aStruSx,{"Tables","Tables","A",4,})
   aAdd(aStruSx,{"Access","Access","C",5,"xxxxxxxxxx"})
   aAdd(aStruSx,{"Owner","Owner","C",7,"0"})
Return aClone(aStruSX)

Static Function GetTextRegKey(aCposInd,aDados,lDic)
Local cDescr := ""
Local j
Default lDic := .F.

   For j := 1 To Len(aCposInd)
      If aCposInd[j][1] <= Len(aDados) .AND. ValType(aDados[aCposInd[j][1]]) == "C"
         If lDic
            cDescr += aCposInd[j][2] + " = " + aDados[aCposInd[j][1]] +", "
         Else
            cDescr += AvSX3(aCposInd[j][2],AV_TITULO) + " = " + aDados[aCposInd[j][1]] +", "
         EndIf
      EndIf
   Next j
   cDescr := Left(cDescr,Len(cDescr)-2)
   
Return cDescr


Method InitVar() Class AVUpdate01   
Local aVar:= {}
Local i := 0
   
   aVar := {{"EIC",17},;            
            {"EEC",29},;              
            {"EDC",50},;                  
            {"EFF",30},;                  
            {"ECO",31},;
            {"ESS",85},; //RRC - 03/07/2013                
            {"TODOS_MODULOS","TODOS_MODULOS"},;   //TODOS_MODULOS = Todos os modulos.      
            {"TODOS_AVG","TODOS_AVG"},;       //TODOS_AVG     = Modulos EIC, EEC, EDC, EFF, ECO, ESS
            {"BASICO_AVG","BASICO_AVG"},;      //BASICO_AVG    = Modulos EIC, EEC, EDC
            {"EIC_USADO","EIC_USADO"},;
            {"EEC_USADO","EEC_USADO"},;
            {"EDC_USADO","EDC_USADO"},;
            {"EFF_USADO","EFF_USADO"},;
            {"ECO_USADO","ECO_USADO"},;
            {"ESS_USADO","ESS_USADO"},; //RRC - 03/07/2013 
            {"EIC_NUSADO","EIC_NUSADO"},;
            {"EEC_NUSADO","EEC_NUSADO"},;
            {"EDC_NUSADO","EDC_NUSADO"},;
            {"EFF_NUSADO","EFF_NUSADO"},;
            {"ECO_NUSADO","ECO_NUSADO"},;
            {"ESS_NUSADO","ESS_NUSADO"},; //RRC - 03/07/2013 
            {"NAO_USADO","NAO_USADO"}  ,;
            {"CAMPO_NAO_CHAVE","_CAMPO_NAO_CHAVE"},;
            {"CAMPO_CHAVE","_CAMPO_CHAVE"},;
            {"TAB", CHR(9)+CHR(9)+CHR(9)+CHR(9)},;
            {"FO_READWRITE",2},;
            {"FO_EXCLUSIVE",16},;
            {"BLOCK_READ", 1024},;
            {"ENTER", CHR(13) + CHR(10)},;
            {"NOME"   ,2^0},;
            {"TIPO"   ,2^1},;
            {"TAM"    ,2^2},;
            {"DEC"    ,2^3},;
            {"ORDEM"  ,2^4},;
            {"OBRIGAT",2^5},;
            {"USO"    ,2^6},;
            {"LOCALIZACOES","ARG/BOL/CHI/COL/COS/DOM/EQU/EUA/MEX/PAN/PAR/PER/POR/PTG/URU/VEN"},;
            {"BRASIL" ,"BRA"}}
            
   For i := 1 To Len(aVar)
      _SetOwnerPrvt(aVar[i][1], aVar[i][2])
   Next i

Return .T.


Static Function SelEmp(aFiliais)

Local oOK := LoadBitmap(GetResources(),'br_verde')
Local oNO := LoadBitmap(GetResources(),'br_vermelho') 
Local i
Local aBrowse := {}

DEFINE MSDIALOG oDlg TITLE "Seleção de Empresas " FROM 60,80 TO 450,500 PIXEL

   oPanel:= tPanel():New(20,25,'Selecione abaixo as empresas em que deverão ser aplicadas as atualizações: ',oDlg,,.T.,,,,20,20)
   oPanel:align:=CONTROL_ALIGN_TOP  
                
                
   
   oBrowse := TWBrowse():New(30,25,250,250,,{'','Codigo'},{20,30},;
                              oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   
   For i := 1 to len(aFiliais)
	   aAdd(aBrowse,{.T.,aFiliais[i][2]}) //Adiciona as empresas no Browse
   next                             
   
   oBrowse:SetArray(aBrowse)
   oBrowse:bLine := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),aBrowse[oBrowse:nAt,02]}}

    // Troca a imagem no duplo click do mouse
   oBrowse:bLDblClick := {|| aBrowse[oBrowse:nAt][1] := !aBrowse[oBrowse:nAt][1],; 
                             oBrowse:DrawSelect()}
                             
                             
   // Botão OK 
   oButton:=tButton():New(20,35,'OK',oDlg,{||alteraSMO(aBrowse,@aFiliais),oDlg:end()},,20,20,,,,.T.) // chama função que altera o aFiliais
   
   oButton:Align:=CONTROL_ALIGN_BOTTOM                                                          
   
   oBrowse:align:=CONTROL_ALIGN_ALLCLIENT        
Activate MSDialog oDlg CENTERED 




Return nil


Static Function alteraSMO(aBrowse,aFiliais)
local i
local j

  For i := 1 To Len(aBrowse)
     If !aBrowse[i][1] // Empresas não escolhidas
        nPosSM0 := aScan(aFiliais,{|X| X[2] == aBrowse[i][2]}) // retorna a posição do registro que não sera alterado pelo update
        aDel(aFiliais,nPosSM0) // deleta o registro que não será alterado do aFiliais
        aSize(aFiliais,Len(aFiliais)-1) // redimensiona o Array
     EndIf
  Next
  
return nil

/*
Função    : AcertaFilial()   
Objetivos : Forçar a gravação do campo Filial sempre com o tamanho definido para o grupo de empresas.
Parametros: Nenhum
Retorno   : Nil
Autor     : Rodrigo Mendes Diaz
Data      : 01/08/2012
*/

Static Function AcertaFilial(aStruct, aDados)
Local nPosTam, nPosCampo
    
	//Verifica no aStruct se possui o campo "X3_CAMPO", se o conteúdo refere-se a um campo Filial e se possui do campo "X3_TAMANHO"
	If (nPosCampo := aScan(aStruct,{|X| AllTrim(X) == AllTrim("X3_CAMPO")})) > 0 .And.;
	   At("_FILIAL", aDados[nPosCampo]) > 0 .And.;
	   (nPosTam := aScan(aStruct,{|X| AllTrim(X) == AllTrim("X3_TAMANHO")})) > 0
	   	//Força o uso do FWSizeFilial() para definir o tamanho de qualquer campo Filial, independente do que foi definido no update.
		aDados[nPosTam] := FWSizeFilial()
	EndIf

Return Nil


/*
Função    : AcertaIndice()   
Objetivos : Ajustar o compatibilizador para garantir que todas as ordens dos indices estejam corretas.
Parametros: aTabel - atualizações do compatibilizador
Retorno   : Nil
Autor     : Felipe Sales Martinez - FSM
Data      : 22/08/2012 - 16:40
*/
Static Function AcertaIndice(aTable)
Local aDadosAtu := aClone(aTable)
Local aOrd      := SaveOrd("SIX")
Local aUpdate   := {}
Local cCpoAlias := ""
Local cAlias := ""
Local cOrd   := ""
Local ni     := 0
Local nj     := 0
Local nMax   := 0

For nI := 1 To Len(aDadosAtu)
    If AllTrim(Upper(aDadosAtu[nI][1])) == "SIX"

       If aDadosAtu[nI][3] //DelTableData
          loop
       EndIf

       cAlias := aDadosAtu[nI][2][1]
       cOrd   := aDadosAtu[nI][2][2] + "/"
       nMax   := Val(RetAsc(aDadosAtu[nI][2][2], 1,.F.))
    
       If (nPos := aScan(aUpdate,{ |X| X[1] == cAlias } ) ) > 0
          aUpdate[nPos][2] += cOrd
          aUpdate[nPos][3] := Max(nMax, aUpdate[nPos][3])
       Else
          aAdd(aUpdate, {cAlias, cOrd, nMax})
       EndIf
      
    EndIf
Next

SIX->(DBSetOrder(1))
For nI := 1 To len(aUpdate)
    cAlias := UPPER(AllTrim(aUpdate[nI][1]))
    nMax := aUpdate[nI][3]
    For nj := 1 To nMax-1
        cOrd := RetAsc( AllTrim(Str(nJ)),1,.T.)
        If !(cOrd $ aUpdate[nI][2]) .And. !SIX->(DBSeek(cAlias+cOrd))
           cCpoAlias := IF( At("S", cAlias)==1 , SubStr(cAlias, 2), cAlias )
           aAdd( aTable , {"SIX",{cAlias, cOrd, cCpoAlias+"_FILIAL","Filial","N"},.F.,{"SIX",1,{"INDICE","ORDEM","CHAVE","DESCRICAO","SHOWPESQ"}},.T.} )
        EndIf
    Next
Next

RestOrd(aOrd)

Return Nil 


Function EasyIsDir(cCaminho,cBarra)
Local lIsDir := .F.
Local aDir := {}

Default cCaminho := ""
Default cBarra := "\"

If IsSrvUnix()
   cBarra := "/"
EndIf

If !empty(cCaminho) .and. !(Replic(cBarra,2)$cCaminho)
	cCaminho := alltrim(cCaminho)
	If Right(cCaminho,1) == cBarra
		cCaminho := SubStr(cCaminho,1,len(cCaminho)-1)
	EndIf
	
	If !IsSrvUnix() // Funcao Directory funciona somente quando o server esta em windows.
       aDir := Directory(cCaminho,"D")
    EndIf
	If ValType(aDir) == "A"
	   lIsDir :=(Ascan( aDir,{|_Vet | "D" $ _Vet[5] } ) > 0)
	EndIf
EndIf
Return lIsDir

/* DESCONTINUADA ATUALIZAÇÂO DE DICIONARIOS NO PROTHEUS 12 VIA PROGRAMA
Function AcertaGrpCpo(aStruct,aDados)   // GFP - 14/03/2013
Local nPosGrp := aScan(aStruct,{|X| AllTrim(X) == "X3_GRPSXG"})
Local lFilial := aScan(aDados ,{|X| "_FILIAL" $ AllTrim(X)}) > 0

If lFilial .AND. nPosGrp > 0
   aDados[nPosGrp] := "033"
EndIf

Return .T.
*/

Static Function GetDBTables(aTabs)
Local aDBTabs := {}
Local i

For i:= 1 To Len(aTabs)                    //NCF - 30/10/2014 - Compatibilidade com SGBD ORACLE
   If SX2->(dbSeek(aTabs[i])) .AND. MsFile(Alltrim(RetSQLName(aTabs[i])),,"TOPCONN")
      aAdd(aDBTabs,aTabs[i])
   EndIf
Next i

Return aDBTabs

Method CargaSX(cTabela) Class AVUpdate01
Local lRet := .T.
Local lTop := .F.
Local cX2_ARQUIVO

#IFDEF TOP
   lTop := .T.
#ENDIF

BEGIN SEQUENCE

If !lTop
   lRet := .F.
   BREAK
EndIf

If !SX2->(dbSeek(cTabela))
   Self:Error("Tabela "+cTabela+" não possui dicionário de dados para realização da carga inicial.")
   lRet := .T.
   BREAK   
EndIf
cX2_ARQUIVO := Alltrim(RetSQLName(cTabela))
           //NCF - 30/10/2014 - Compatibilidade com SGBD ORACLE
If !MsFile(cX2_ARQUIVO,,"TOPCONN") .AND. !ChkFile(cTabela)
   Self:Error("Tabela "+cX2_ARQUIVO+" não existe e não foi possível cria-la para realizar a sua carga inicial.")
   lRet := .T.
   BREAK  
EndIf

(cTabela)->(dbGoTop())
If !(cTabela)->(Eof())
   lRet := .T.
   BREAK
EndIf

(cTabela)->(dbCloseArea())
cArqTab := Left(cArqTab,At(cTabela,cArqTab)-1)+SubStr(cArqTab,At(cTabela,cArqTab)+5)
TcRefresh(cX2_ARQUIVO)
            //NCF - 30/10/2014 - Compatibilidade com SGBD ORACLE
If !MsErase(cX2_ARQUIVO,,"TOPCONN")
   Self:Error("Não foi possível excluir a tabela "+cX2_ARQUIVO+" para realizar a sua carga inicial.")
   lRet := .F.
   BREAK
EndIf
TcRefresh(cX2_ARQUIVO)

If !ChkFile(cTabela)
   Self:Error("Não foi possível criar a tabela "+cX2_ARQUIVO+" para realizar a sua carga inicial.")
   lRet := .F.
   BREAK
EndIf

(cTabela)->(dbGoTop())
If !(cTabela)->(Eof())
   lRet := .T.
Else
   Self:Error("Não foi possível excluir a tabela "+cX2_ARQUIVO+" para realizar a sua carga inicial.")
EndIf

::Warning("Carga da tabela "+cTabela+" realizada com sucesso!")

END SEQUENCE

Return lRet

/* DESCONTINUADA ATUALIZAÇÂO DE DICIONARIOS NO PROTHEUS 12 VIA PROGRAMA
Method ShowDiffs() Class AVUpdate01
Local cLog    := ""
Local aHeader := {"ALIAS","CHAVE","CAMPO","DICIONARIO_ATUAL","DICIONARIO_FUTURO"}
Local i

If Len(::aDiffs) > 0 .AND. MsgYesNo("Deseja visualizar as diferenças entre o ambiente e as atualizações a serem efetuadas?")
   aEval(aHeader,{|X| cLog += X+";"})   
   cLog := ::cTitulo + ENTER +  Left(cLog,Len(cLog)-1)+ENTER
   
   For i := 1 To Len(::aDiffs)
      aEval(::aDiffs[i],{|X| cLog += '"'+StrTran(cValToChar(X),'"','""')+'";'})
      cLog := Left(cLog,Len(cLog)-1)+ENTER
   Next i
   
   cTmpArq := GetTempPath(.T.) + CriaTrab(,.F.) + ".CSV"
   MemoWrite(cTmpArq,cLog)

   ShellExecute( "Open", cTmpArq,"" ,"" , 1 )
EndIf

Return Nil
*/

User Function AVUPDCHK()
Private oMainWnd
Private cDescr
Private cUpdate := Space(10)

oMainWnd := MsDialog():New(0,0,200,400,"Comparação update x ambiente",,,,,,,,,.T.,,,,,)

nAltura := oMainWnd:nHeight/2

oPrc := TPanel():New(01,01,"",oMainWnd,,,,,,oMainWnd:nWidth,25/100*nAltura)
oPrc:Align := CONTROL_ALIGN_TOP

oSeg := TPanel():New(01,01,"",oMainWnd,,,,,,oMainWnd:nWidth,25/100*nAltura)
oSeg:Align := CONTROL_ALIGN_ALLCLIENT

oSeg1 := TPanel():New(01,01,"",oMainWnd,,,,,,oMainWnd:nWidth,12.5/100*nAltura)
oSeg1:Align := CONTROL_ALIGN_ALLCLIENT

oSeg2 := TPanel():New(01,01,"",oMainWnd,,,,,,oMainWnd:nWidth,12.5/100*nAltura)
oSeg2:Align := CONTROL_ALIGN_BOTTOM

cDescr := "Este programa é utilizado para comparar os dicionários atuais do ambiente com as alterações realizadas por um update compatibilizador. "
cDescr += "Entre com o nome do programa do compatibilizador para simular sua execução."

oSay1 := TSay():New(2,2,{|| cDescr},oPrc,,,,,,.T.,,,200,150,,,,,,.T.)
oSay1:lWordWrap := .T.
oSay1:Align := CONTROL_ALIGN_TOP

@ 2,2 GET oGet1 VAR cUpdate SIZE 200,10 OF oSeg1 PIXEL

oMainWnd:bInit := {|| oMainWnd:nHeight := 200,oMainWnd:nWidth := 400,oMainWnd:Center(.T.) }

oTButton1 := TButton():New( 002, 00, "Executar",oSeg2,{|| SimUpd(cUpdate)},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
oTButton2 := TButton():New( 002, 50, "Finalizar",oSeg2,{||oMainWnd:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

oMainWnd:Activate()

Return Nil

Static Function SimUpd(cUpdate)
Private oPrvtUpd := AvUpdate01():New()
oPrvtUpd:lSimula:= .T.

cUpdate := Upper(AllTrim(cUpdate))

If Left(cUpdate,2) <> "U_"
   cUpdate := "U_"+cUpdate
EndIf

If At(cUpdate,"(") > 1 .AND. At(cUpdate,")") > At(cUpdate,"(")
   cUpdate := Left(cUpdate,At(cUpdate,"(")-1)
EndIf

If FindFunction(cUpdate)
   
   TRY
      &(cUpdate+"(oPrvtUpd)")
      oPrvtUpd:Init()
      
   CATCH oErro
   
      MsgInfo("Erro ao executar o programa compatibilizador informado ("+cUpdate+")"+StrTran(oErro:errorstack,Chr(10),Chr(13)+Chr(10)))
      Eval(ErrorBlock(),oErro)
      
   ENDTRY
   
Else
   MsgInfo("Programa compatibilizador não encontrado neste repositório ("+cUpdate+")")
EndIf

Return Nil


/*
Função    : AvEngSX()   
Objetivos : Executar as funcoes de gravacao dos dicionarios em Banco de Dados
Parametros: 
Retorno   : Nil
Autor     : Tiago Henrique Tudisco dos Santos - THTS
Data      : 06/07/2017
*/
Static Function AvEngSX(cTable,aStruct)

Local aEngStruct:= EngCpoAlt(cTable) //Campos que podem alterar para o dicionario
Local aEngChave := aEngStruct[1] //Campos chave
Local aEngCampos:= aEngStruct[2] //Campos que podem ser alterados
Local aEngDados := {}
Local aChave    := {}
Local aValorCpo := {}
Local aValores  := {}
Local nI

For nI := 1 To Len(aEngChave)
    aAdd(aChave,&("M->"+aEngChave[nI]))
Next

For nI := 1 To Len(aStruct)
    If aScan(aEngCampos,{|X| aStruct[nI] == AllTrim(X)}) > 0
        aAdd(aValorCpo,aStruct[nI])
        aAdd(aValorCpo,&("M->"+aStruct[nI]))

        aAdd(aValores,aValorCpo)
        aValorCpo:={}
    EndIf
Next

aAdd(aEngDados, aChave )
aAdd(aEngDados, aValores )

Return aEngDados

/*
Função    : EngCpoAlt()   
Objetivos : Monta o array com os campos que podem ser alterados para o dicionario especifico
Parametros: cTable - Tabela que tera os campos verificados
Retorno   : Nil
Autor     : Tiago Henrique Tudisco dos Santos - THTS
Data      : 06/07/2017
*/
Static Function EngCpoAlt(cTable)

Local aChave    := {}
Local aCamposAlt:= {}

Do Case

    Case cTable == "SIX" //Indice

        aAdd(aChave,"INDICE")
        aAdd(aChave,"ORDEM")

        aAdd(aCamposAlt,"F3"          )
        aAdd(aCamposAlt,"NICKNAME"    )
        aAdd(aCamposAlt,"PROPRI"      )
        aAdd(aCamposAlt,"SHOWPESQ"    )

    Case cTable == "SX1" //Perguntas
    
        
    Case cTable == "SX2" //Tabelas

        aAdd(aChave,"X2_CHAVE")

        aAdd(aCamposAlt,"X2_DISPLAY"  )
        aAdd(aCamposAlt,"X2_MODULO"   )
        aAdd(aCamposAlt,"X2_NOME"     )
        aAdd(aCamposAlt,"X2_NOMEENG"  )
        aAdd(aCamposAlt,"X2_NOMESPA"  )
        aAdd(aCamposAlt,"X2_POSLGT"   )
        aAdd(aCamposAlt,"X2_PYME"     )
        aAdd(aCamposAlt,"X2_ROTINA"   )
        aAdd(aCamposAlt,"X2_SYSOBJ"   )

    Case cTable == "SX3" //Campos

        aAdd(aChave,"X3_CAMPO")

        aAdd(aCamposAlt,"X3_AGRUP")
        aAdd(aCamposAlt,"X3_BROWSE")
        aAdd(aCamposAlt,"X3_CBOX")
        aAdd(aCamposAlt,"X3_CBOXENG")
        aAdd(aCamposAlt,"X3_CBOXSPA")
        aAdd(aCamposAlt,"X3_CHECK")
        aAdd(aCamposAlt,"X3_CHKSQL")
        aAdd(aCamposAlt,"X3_CONDSQL")
        aAdd(aCamposAlt,"X3_CONTEXT")
        aAdd(aCamposAlt,"X3_DESCENG")
        aAdd(aCamposAlt,"X3_DESCRIC")
        aAdd(aCamposAlt,"X3_DESCSPA")
        aAdd(aCamposAlt,"X3_F3")
        aAdd(aCamposAlt,"X3_FOLDER")
        aAdd(aCamposAlt,"X3_GRPSXG")
        aAdd(aCamposAlt,"X3_IDXFLD")
        aAdd(aCamposAlt,"X3_IDXSRV")
        aAdd(aCamposAlt,"X3_INIBRW")
        aAdd(aCamposAlt,"X3_MODAL")
        aAdd(aCamposAlt,"X3_NIVEL")
        aAdd(aCamposAlt,"X3_ORTOGRA")
        aAdd(aCamposAlt,"X3_PICTURE")
        aAdd(aCamposAlt,"X3_PICTVAR")
        aAdd(aCamposAlt,"X3_POSLGT")
        aAdd(aCamposAlt,"X3_PROPRI")
        aAdd(aCamposAlt,"X3_PYME")
        aAdd(aCamposAlt,"X3_RELACAO")
        aAdd(aCamposAlt,"X3_RESERV")
        aAdd(aCamposAlt,"X3_TELA")
        aAdd(aCamposAlt,"X3_TITENG")
        aAdd(aCamposAlt,"X3_TITSPA")
        aAdd(aCamposAlt,"X3_TITULO")
        aAdd(aCamposAlt,"X3_TRIGGER")
        aAdd(aCamposAlt,"X3_USADO")
        aAdd(aCamposAlt,"X3_VALID")
        aAdd(aCamposAlt,"X3_VISUAL")
        aAdd(aCamposAlt,"X3_WHEN")

    Case cTable == "SX5" //Tabelas Genericas
        
        aAdd(aChave,"X5_FILIAL")
        aAdd(aChave,"X5_TABELA")
        aAdd(aChave,"X5_CHAVE")

        aAdd(aCamposAlt,"X5_DESCRI")
        aAdd(aCamposAlt,"X5_DESCSPA")
        aAdd(aCamposAlt,"X5_DESCENG")

    Case cTable == "SX6" //Parametros


    Case cTable == "SX7" //Gatilhos

        aAdd(aChave,"X7_CAMPO")
        aAdd(aChave,"X7_SEQUENC")

        aAdd(aCamposAlt,"X7_ALIAS")
        aAdd(aCamposAlt,"X7_CDOMIN")
        aAdd(aCamposAlt,"X7_CHAVE")
        aAdd(aCamposAlt,"X7_CONDIC")
        aAdd(aCamposAlt,"X7_ORDEM")
        aAdd(aCamposAlt,"X7_PROPRI")
        aAdd(aCamposAlt,"X7_REGRA")
        aAdd(aCamposAlt,"X7_SEEK")
        aAdd(aCamposAlt,"X7_TIPO")

    Case cTable == "SX9" //Relacionamento entre Tabelas

        aAdd(aChave,"X9_CDOM")
        aAdd(aChave,"X9_DOM")

        aAdd(aCamposAlt,"X9_CHVFOR")
        aAdd(aCamposAlt,"X9_CONDSQL")
        aAdd(aCamposAlt,"X9_ENABLE")
        aAdd(aCamposAlt,"X9_EXPCDOM")
        aAdd(aCamposAlt,"X9_EXPDOM")
        aAdd(aCamposAlt,"X9_IDENT")
        aAdd(aCamposAlt,"X9_LIGCDOM")
        aAdd(aCamposAlt,"X9_LIGDOM")
        aAdd(aCamposAlt,"X9_PROPRI")
        aAdd(aCamposAlt,"X9_USEFIL")
        aAdd(aCamposAlt,"X9_VINFIL")

    Case cTable == "SXA" //Pastas e Agrupamento de Campos

        aAdd(aChave,"XA_ALIAS")
        aAdd(aChave,"XA_ORDEM")

        aAdd(aCamposAlt,"XA_AGRUP")
        aAdd(aCamposAlt,"XA_DESCENG")
        aAdd(aCamposAlt,"XA_DESCRIC")
        aAdd(aCamposAlt,"XA_DESCSPA")
        aAdd(aCamposAlt,"XA_PROPRI")
        aAdd(aCamposAlt,"XA_TIPO")

    Case cTable == "SXB" //Consulta Padrao

        aAdd(aChave,"XB_ALIAS")
        aAdd(aChave,"XB_TIPO")
        aAdd(aChave,"XB_SEQ")
        aAdd(aChave,"XB_COLUNA")

        aAdd(aCamposAlt,"XB_CONTEM")
        aAdd(aCamposAlt,"XB_DESCENG")
        aAdd(aCamposAlt,"XB_DESCRI")
        aAdd(aCamposAlt,"XB_DESCSPA")
        aAdd(aCamposAlt,"XB_WCONTEM")

    Case cTable == "XXA" //Regras de dependência entre campos

        aAdd(aChave,"XXA_DOM")
        aAdd(aChave,"XXA_CDOM")

        aAdd(aCamposAlt,"XXA_DESCRI")
        aAdd(aCamposAlt,"XXA_DSCENG")
        aAdd(aCamposAlt,"XXA_DSCSPA")
        aAdd(aCamposAlt,"XXA_SEQUEN")
        aAdd(aCamposAlt,"XXA_TYPE")

End Case

Return {aChave,aCamposAlt}
