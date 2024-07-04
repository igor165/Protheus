#INCLUDE "Protheus.ch"  
#INCLUDE "ARG11R101.ch"

//---------------------------------------------------------------------------------
/*/{Protheus.doc} ARG11R101
Funcao que atualiza as tabelas da Nota Fiscal Eletrônica da Argentina

@author Rafael Iaquinto
@since 08.04.2011
@version 1.0 

@param		cUpdate		Nome do Update que deve ser executado.
			aOrdem		Array com a tabela e proxima ordem do campo 

@return		Nil
@obs		
/*/
//-----------------------------------------------------------------------
Function ARG11R101(cUpdate, aOrdem)
Local aRet      := {{},{},{},{},{},{},{},{},{}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ESTRUTURA DO ARRAY aRET:                                             ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ aRet[01] - Array com os dados SX2                                    ³
//³ aRet[02] - Array com os dados SIX                                    ³
//³ aRet[03] - Array com os dados SX3                                    ³
//³ aRet[04] - Array com os dados SX5                                    ³
//³ aRet[05] - Array com os dados SX6                                    ³
//³ aRet[06] - Array com os dados SX7                                    ³
//³ aRet[07] - Array com os dados SXA                                    ³
//³ aRet[08] - Array com os dados SXB                                    ³
//³ aRet[09] - Array com os dados SX1                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aRet[1] := NFEAtuSX2(cUpdate)
aRet[2] := NFEAtuSIX(cUpdate)
aRet[3] := NFEAtuSX3(cUpdate,@aOrdem)
aRet[4] := NFEAtuSX5(cUpdate)
aRet[5] := NFEAtuSX6(cUpdate)
aRet[6] := NFEAtuSX7(cUpdate)
aRet[7] := NFEAtuSXA(cUpdate)
aRet[8] := NFEAtuSXB(cUpdate)
aRet[9] := NFEAtuSX1(cUpdate)

//-- Atualizacao dos Helps - AINDA NÃO UTILIZADO.
ARGPtuHlp(cUpdate)

Return(aRet)     

//-----------------------------------------------------------------------
/*/{Protheus.doc} NFEAtuSX2
Retorna os dados para atualizacao do SX2 conforme update selecionado.

@author Rafael Iaquinto
@since 08.04.2011
@version 1.0 

@param		cUpdate		Nome do Update que deve ser executado.

@return		aSX2		Array com dados para atualizacao do SX2
@obs		
/*/
//-----------------------------------------------------------------------
Static Function NFEAtuSX2(cUpdate)

Local aSX2      := {}
Local cPath     := ""
Local cNome     := ""

Do Case
	
	Case "ARG11R101" $ cUpdate
		
		cNome:= SubStr(Posicione('SX2',1,'SFP','X2_ARQUIVO'),4,5)
		cPath:= Posicione('SX2',1,'SFP','X2_PATH')
		
		AAdd(aSX2,{	"CG6",; 					//Chave
						cPath,;					//Path
						"CG6"+cNome,;			//Nome do Arquivo
						"Controle Solicitacao CAEA",;	//Nome Port
						"Control Solicitud CAEA",;	//Nome Esp
						"CAEA Control Request",;	//Nome Ing
						0,;						//Delete
						"C",;					//Modo - (C)Compartilhado ou (E)Exclusivo
						"",;					//TTS
						"",;					//Rotina
						"S",;					//Pyme	
						"CG6_FILIAL+CG6_FILUSO+CG6_CAEA"})//Unico			
						
EndCase				
		
Return(aSX2)
                                                                         

//-----------------------------------------------------------------------
/*/{Protheus.doc} NFEAtuSIX
Retorna os dados para atualizacao do SIX conforme update selecionado.

@author Rafael Iaquinto
@since 08.04.2011
@version 1.0 

@param		cUpdate		Nome do Update que deve ser executado.

@return		aSIX		Array com dados para atualizacao do SIX
@obs		
/*/
//-----------------------------------------------------------------------
Static Function NFEAtuSIX(cUpdate)
Local aSIX := {}

/* Ainda nao utilizado, quando for necessario utilizar modelo abaixo como exemplo.
Do Case
	
	Case "NFE10R101" $ cUpdate
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ OPERADORAS x ROTAS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aSIX,{	"DEK",; 										//Indice
					"3",;                  							//Ordem
					"DEK_FILIAL+DEK_ROTA+DEK_FROVEI+DEK_CODOPE",;	//Chave
					"Rota + Frota + Cod. Operad. ",; 				//Descricao Port.
					"",;											//Descricao Spa.
					"",;											//Descricao Eng.
					"S",;											//Proprietario
					"",; 											//F3
					"",; 											//NickName
					"S"})											//ShowPesq
EndCase				
*/

Do Case
	
	Case "ARG11R101" $ cUpdate
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ OPERADORAS x ROTAS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aSIX,{"CG6",; 										//Indice
					"1",;                  							//Ordem
					"CG6_FILIAL+CG6_FILUSO+CG6_CAEA",;			//Chave
					"Filial + Filial Uso + CAEA",;				//Descricao Port.
					"Sucursal + Sucursal Uso + CAEA",;				//Descricao Spa.
					"",;											//Descricao Eng.
					"S",;											//Proprietario
					"",; 											//F3
					"",; 											//NickName
					"S";
					})											//ShowPesq
		aadd(aSIX,{"CG6",; 										//Indice
					"2",;                  							//Ordem
					"CG6_FILIAL+CG6_FILUSO+CG6_PERIOD+CG6_ORDEM",;//Chave
					"Filial + Filial Uso + Periodo Aut. + Ordem Quinze",;	//Descricao Port.
					"Sucursal + Sucursal Uso + Periodo Auto + Ord Quincen",;//Descricao Spa.
					"",;											//Descricao Eng.
					"S",;											//Proprietario
					"",; 											//F3
					"",; 											//NickName
					"S";
					})											//ShowPesq
					
EndCase

Return(aSIX)


//-----------------------------------------------------------------------
/*/{Protheus.doc} NFEAtuSX3
Retorna os dados para atualizacao do SX3 conforme update selecionado.

@author Rafael Iaquinto
@since 08.04.2011
@version 1.0 

@param		cUpdate		Nome do Update que deve ser executado.

@return		aSX3		Array com dados para atualizacao do SX3
@obs		
/*/
//-----------------------------------------------------------------------
Static Function NFEAtuSX3(cUpdate, aOrdem)
Local aSX3      := {}
Local aPropCpos := {}

Local cOrdem2	:= ""

Local cTamFil	:= FWGETTAMFILIAL

Local lExist	:= .F.

Default	aOrdem	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VERIFICA AS PROPRIEDADES DOS CAMPOS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
SX3->(DbSetOrder(2))

AAdd( aPropCpos, {'FILIAL'} )
AAdd( aPropCpos, {'OBRIGATORIO-NAO ALTERAVEL'} )
AAdd( aPropCpos, {'VIRTUAL'} )
AAdd( aPropCpos, {'NORMAL'} )
AAdd( aPropCpos, {'OBRIGATORIO-ALTERAVEL'})
//--Pesquisa um campo existente para gravar o Reserv e o Usado (Campo Filial)
If SX3->( MsSeek( "A1_FILIAL" ) )
	AAdd( aPropCpos[1], {SX3->X3_USADO, SX3->X3_RESERV} )
EndIf
//--Pesquisa um campo existente para gravar o Reserv e o Usado (Campo Obrigatorio - Nao Alteravel)
If SX3->( MsSeek( "F4_TEXTO" ) )
	AAdd( aPropCpos[2], {SX3->X3_USADO, SX3->X3_RESERV} )
EndIf
//--Pesquisa um campo existente para gravar o Reserv e o Usado (Campo Virtual)
If SX3->( MsSeek( "D7_OBS" ) )
	AAdd( aPropCpos[3], {SX3->X3_USADO, SX3->X3_RESERV} )
EndIf
//--Pesquisa um campo existente para gravar o Reserv e o Usado (Campo Normal, sem obrigatoriedade)
If SX3->( MsSeek( "B1_PICMRET" ) )
	AAdd( aPropCpos[4], {SX3->X3_USADO, SX3->X3_RESERV} )
EndIf
//--Pesquisa um campo OBRIGATORIO existente para gravar o Reserv e o Usado (Campo Obrigatorio - Alteravel)
If SX3->( MsSeek( "A1_EST" ) )
	AAdd( aPropCpos[5], {SX3->X3_USADO, SX3->X3_RESERV} )
EndIf

Do Case
			
	Case "ARG11R101" $ cUpdate
			
		cOrdem:=RetornaOrdem("CG6",@aOrdem)
		IF (cOrdem == "01")
			lExist  := .F.
		Else		 
			cOrdem2 := GetOrdem('CG6_FILIAL')
			lExist  := .T.			
		EndIf
		Aadd(aSX3,{"CG6",;						//Arquivo
					IIf(lExist,cOrdem2,cOrdem),;//Ordem
					"CG6_FILIAL",;				//Campo
					"C",;						//Tipo
					cTamFil,;					//Tamanho
					0,;					   		//Decimal
					"Filial",;			       	//Titulo
					"Sucursal",;				//Titulo SPA
					"Branch",;					//Titulo ENG
					"Filial do Sistema",;    //Descricao
					"Surcusal de Sistema",;	//Descricao SPA
					"System Branch",;			//Descricao ENG
					"@!",;						//Picture
					"",;						//VALID
					aPropCpos[1][2][1],;		//USADO
					"",;						//RELACAO
					"",;	   					//F3
					1,;		   					//NIVEL
					aPropCpos[1][2][2],;		//RESERV
					"",;						//CHECK
					"",;						//TRIGGER
					"S",;						//PROPRI
					"N",;						//BROWSE
					"A",;						//VISUAL
					"R",;						//CONTEXT
					"",;						//OBRIGAT
					"",;						//VLDUSER
					"",;						//CBOX
					"",;						//CBOX SPA
					"",;						//CBOX ENG
					"",;						//PICTVAR
					"",;						//WHEN
					"",;						//INIBRW
					"",;						//SXG
					"",;						//FOLDER
					"N"})						//PYME
					
			aPHelpPor := {"Filial do Sistema."}					              
			              		              						   					
			aPHelpEng := {"System Branch."}						  		 	 				 	  			 	 
					 	 
			aPHelpSpa := {"Sucursal del sistema."}	 					  
						  					  				  
		
			PutHelp("PCG6_FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
        
        
        cOrdem2 := GetOrdem('CG6_FILUSO')
        IF Empty(cOrdem2)
			cOrdem := Soma1(cOrdem)
			lExist  := .F.
		Else
			lExist  := .T.			
		EndIf
		
		Aadd(aSX3,{"CG6",;						//Arquivo
					IIf(lExist,cOrdem2,cOrdem),;//Ordem
					"CG6_FILUSO",;				//Campo
					"C",;						//Tipo
					Len(FWGETCODFILIAL),;						//Tamanho
					0,;					   		//Decimal
					"Filial Uso",;  			//Titulo
					"Sucursal Uso",;			//Titulo SPA
					"Branch Use",;		    	//Titulo ENG
					"Filial de uso do CAEA",;  //Descricao
					"Sucursal del Uso del CAEA",;//Descricao SPA
					"Branch of CAEA Use",;	//Descricao ENG
					"@!",;						//Picture
					"",;						//VALID
					aPropCpos[4][2][1],;		//USADO
					"",;						//RELACAO
					"",;	   					//F3
					1,;		   					//NIVEL
					aPropCpos[4][2][2],;		//RESERV
					"",;						//CHECK
					"",;						//TRIGGER
					"S",;						//PROPRI
					"S",;						//BROWSE
					"A",;						//VISUAL
					"R",;						//CONTEXT
					"",;						//OBRIGAT
					"",;						//VLDUSER
					"",;						//CBOX
					"",;						//CBOX SPA
					"",;						//CBOX ENG
					"",;						//PICTVAR
					"",;						//WHEN
					"",;						//INIBRW
					"",;						//SXG
					"",;						//FOLDER
					"S"})						//PYME
					
		aPHelpPor := {"Filial de uso.                          "}             
              		              
		aPHelpEng := {"Use Branch.                             "}		 	 				 	  			 	  
				 	 
		aPHelpSpa := {"Sucursal de uso.                        "}
						  					  				  
		
		PutHelp("PCG6_FILUSO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
        
        				
		cOrdem2 := GetOrdem('CG6_CAEA')
        IF Empty(cOrdem2)
			cOrdem := Soma1(cOrdem)
			lExist  := .F.
		Else
			lExist  := .T.			
		EndIf
		
		Aadd(aSX3,{ "CG6",;					//Arquivo
					IIf(lExist,cOrdem2,cOrdem),;//Ordem
					"CG6_CAEA",;				//Campo
					"C",;						//Tipo
					014,;						//Tamanho
					0,;					   		//Decimal
					"Nr. CAEA.",;	           	//Titulo
					"Nro. CAEA.",;			//Titulo SPA
					"CAEA Number",;			//Titulo ENG
					"Numero do CAEA",;       //Descricao
					"Nro. del CAEA",; 		//Descricao SPA
					"Number of CAEA",;		//Descricao ENG
					"@!",;						//Picture
					"",;						//VALID
					aPropCpos[4][2][1],;		//USADO
					"",;						//RELACAO
					"",;	   					//F3
					1,;		   					//NIVEL
					aPropCpos[4][2][2],;		//RESERV
					"",;						//CHECK
					"",;						//TRIGGER
					"S",;						//PROPRI
					"S",;						//BROWSE
					"A",;						//VISUAL
					"R",;						//CONTEXT
					"",;						//OBRIGAT
					"",;						//VLDUSER
					"",;						//CBOX
					"",;						//CBOX SPA
					"",;						//CBOX ENG
					"",;						//PICTVAR
					"",;						//WHEN
					"",;						//INIBRW
					"",;						//SXG
					"",;						//FOLDER
					"S"})						//PYME		
					
		aPHelpPor := {"Numero de autorização antecipado - CAEA."}             
		              		              
		aPHelpEng := {"Advance authorization number - CAEA     "}					  		 	 				 	  			 	 
				 	 
		aPHelpSpa := {"Numero de autorizacion anticipado       ",;
					  "- CAEA.                                 "}					  		
					  
		PutHelp("PCG6_CAEA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		
		cOrdem2 := GetOrdem('CG6_CAEASM')
        IF Empty(cOrdem2)
			cOrdem := Soma1(cOrdem)
			lExist  := .F.
		Else
			lExist  := .T.			
		EndIf
		
		Aadd(aSX3,{	"CG6",;						//Arquivo
					IIf(lExist,cOrdem2,cOrdem),;//Ordem
					"CG6_CAEASM",;			//Campo
					"C",;						//Tipo
					001,;						//Tamanho
					2,;					   		//Decimal
					"CAEA Mov.",;			    //Titulo
					"CAEA Mov.",;				//Titulo SPA
					"CAEA Tran.",;			//Titulo ENG
					"CAEA Movimento",;		//Descricao
					"CAEA Movimento",;		//Descricao SPA
					"CAEA Transaction",;		//Descricao ENG
					"@!",;						//Picture
					'Vazio() .Or. Pertence("12")',;//VALID
					aPropCpos[4][2][1],;		//USADO
					"",;						//RELACAO
					"",;	   					//F3
					1,;		   					//NIVEL
					aPropCpos[4][2][2],;		//RESERV
					"",;						//CHECK
					"",;						//TRIGGER
					"S",;						//PROPRI
					"S",;						//BROWSE
					"A",;						//VISUAL
					"R",;						//CONTEXT
					"",;						//OBRIGAT
					"",;						//VLDUSER
					"1=Sem Movimento;2=Com Movimento",;//CBOX
					"1=Sin movimiento;2=Con movimiento",;//CBOX SPA
					"1=No Transaction;2=With Transaction",;//CBOX ENG
					"",;						//PICTVAR
					"",;						//WHEN
					"",;						//INIBRW
					"",;						//SXG
					"",;						//FOLDER
					"S"})						//PYME
					
					
 		aPHelpPor := {"Informe se o CAEA foi utilizado em algum ",;
					  "comprovante.                             "}		
					   	 				  
		aPHelpEng := {"Enter whether the CAEA was used in some   ",;
		              "receipt.                                 "}					  
					    
		aPHelpSpa := {"Informe si el CAEA se utilizo en algun   ",;
					   	"comprobante.                           "}
					  					   
					  
		PutHelp("PCG6_CAEA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		
					  
		cOrdem2 := GetOrdem('CG6_PERIODO')
        IF Empty(cOrdem2)
			cOrdem := Soma1(cOrdem)
			lExist  := .F.
		Else
			lExist  := .T.			
		EndIf
		Aadd(aSX3,{	"CG6",;						//Arquivo
					IIf(lExist,cOrdem2,cOrdem),;//Ordem
					"CG6_PERIODO",;				//Campo
					"C",;						//Tipo
					006,;						//Tamanho
					0,;					   		//Decimal
					"Periodo Aut.",;		    //Titulo
					"Periodo Auto",;			//Titulo SPA
					"Authrztn.Per",;			//Titulo ENG
					"Ano e Mês Autorização",;//Descricao
					"Ano mes autorizaction",;//Descricao SPA
					"Authorization Yer/Month",;//Descricao ENG
					"@!",;						//Picture
					"",;						//VALID
					aPropCpos[4][2][1],;		//USADO
					"",;						//RELACAO
					"",;	   					//F3
					1,;		   					//NIVEL
					aPropCpos[4][2][2],;		//RESERV
					"",;						//CHECK
					"",;						//TRIGGER
					"S",;						//PROPRI
					"S",;						//BROWSE
					"A",;						//VISUAL
					"R",;						//CONTEXT
					"",;						//OBRIGAT
					"",;						//VLDUSER
					"",;						//CBOX
					"",;						//CBOX SPA
					"",;						//CBOX ENG
					"",;						//PICTVAR
					"",;						//WHEN
					"",;						//INIBRW
					"",;						//SXG
					"",;						//FOLDER
					"S"})						//PYME
					
		aPHelpPor := {"Ano e mês de autorização do CAEA.      "}
					   				  
		aPHelpEng := {"Year and month of CAEA authorization.  "}
				 	 
		aPHelpSpa := {"Ano y mes de autorizacion del CAEA.    "}
					  
		PutHelp("PCG6_PERIODO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		

		cOrdem2 := GetOrdem('CG6_ORDEM')
        IF Empty(cOrdem2)
			cOrdem := Soma1(cOrdem)
			lExist  := .F.
		Else
			lExist  := .T.			
		EndIf
		Aadd(aSX3,{	"CG6",;					//Arquivo
					IIf(lExist,cOrdem2,cOrdem),;//Ordem
					"CG6_ORDEM",;				//Campo
					"C",;						//Tipo
					1,;							//Tamanho
					0,;					   		//Decimal
					"Ordem Quinze",;         //Titulo
					"Ord Quincen",;   		//Titulo SPA
					"Fortngt.Ordr",;			//Titulo ENG
					"Ordem da quinzena no mês",;//Descricao
					"Orden quincena en el mes",;//Descricao SPA
					"Order of Month Forthight",;//Descricao ENG
					"@!",;						//Picture
					'Vazio() .Or. Pertence("12")',;	//VALID
					aPropCpos[4][2][1],;		//USADO
					"",;						//RELACAO
					"",;	   					//F3
					1,;		   					//NIVEL
					aPropCpos[4][2][2],;		//RESERV
					"",;						//CHECK
					"",;						//TRIGGER
					"S",;						//PROPRI
					"S",;						//BROWSE
					"A",;						//VISUAL
					"R",;						//CONTEXT
					"",;						//OBRIGAT
					"",;						//VLDUSER
					"1=Primeira Quinzena;2=Segunda Quinzena",;//CBOX
					"1=Primeira quincena;2=Segunda quincena",;//CBOX SPA
					"1=First Forthight;2=Second Forthight",;//CBOX ENG
					"",;						//PICTVAR
					"",;						//WHEN
					"",;						//INIBRW
					"",;						//SXG
					"",;						//FOLDER
					"S"})						//PYME
					
		aPHelpPor := {"Quinzena de validade do CAEA.           "}
					   					  
		aPHelpEng := {"CAEA fortnight validity.                "}
					  	 	 				 	  			 	  				 	 
		aPHelpSpa := {"Quincena de validez del CAEA.           "}
		
		PutHelp("PCG6_ORDEM",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		
		
		cOrdem2 := GetOrdem('CG6_FHCPRC')
        IF Empty(cOrdem2)
			cOrdem := Soma1(cOrdem)
			lExist  := .F.
		Else
			lExist  := .T.			
		EndIf
		
		Aadd(aSX3,{	"CG6",;						//Arquivo
					IIf(lExist,cOrdem2,cOrdem),;//Ordem
					"CG6_FHCPRC",;				//Campo
					"D",;						//Tipo					
					008,;						//Tamanho
					0,;					   		//Decimal
					"Data Proc.",;		    //Titulo
					"Fech. proced.",;			//Titulo SPA
					"Procssng Dt.",;			//Titulo ENG
					"Data de Processamento",;//Descricao
					"Fecha de procesamiento",;//Descricao SPA
					"Date of Processing",;//Descricao ENG
					"",;						//Picture
					"",;						//VALID
					aPropCpos[4][2][1],;		//USADO
					"",;						//RELACAO
					"",;	   					//F3
					1,;		   					//NIVEL
					aPropCpos[2][2][2],;		//RESERV
					"",;						//CHECK
					"",;						//TRIGGER
					"S",;						//PROPRI
					"S",;						//BROWSE
					"A",;						//VISUAL
					"R",;						//CONTEXT
					"",;						//OBRIGAT
					"",;						//VLDUSER
					"",;						//CBOX
					"",;						//CBOX SPA
					"",;						//CBOX ENG
					"",;						//PICTVAR
					"",;						//WHEN
					"",;						//INIBRW
					"",;						//SXG
					"",;						//FOLDER
					"S"})						//PYME 
					
		aPHelpPor := {"Data de processamento do CAEA, data que ",;
					  "o CAEA foi silicitado para AFIP.        "} 	
					  				  
		aPHelpEng := {"CAEA processing date, date the CAEA was ",;
					  "requested for AFIP.                     "}
					  
		aPHelpSpa := {"Fecha de procesamiento del CAEA, fecha  ",;
					  "en que se solicito el CAEA para AFIP.   "}		
					
		PutHelp("PCG6_FHCPRC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		
		
		cOrdem2 := GetOrdem('CG6_FHCVDE')
        IF Empty(cOrdem2)
			cOrdem := Soma1(cOrdem)
			lExist  := .F.
		Else
			lExist  := .T.			
		EndIf
		
		Aadd(aSX3,{	"CG6",;						//Arquivo
					IIf(lExist,cOrdem2,cOrdem),;//Ordem
					"CG6_FHCVDE",;				//Campo
					"D",;						//Tipo					
					008,;						//Tamanho
					0,;					   		//Decimal
					"Vig. Desde.",;		    //Titulo
					"De Vigencia",;			//Titulo SPA
					"Validity Dt.",;  		//Titulo ENG
					"Data de Vigencia Inicial",;//Descricao
					"Fecha de vigencia inicial",;//Descricao SPA
					"Validity Dt.",;			//Descricao ENG
					"",;						//Picture
					"",;						//VALID
					aPropCpos[4][2][1],;		//USADO
					"",;						//RELACAO
					"",;	   					//F3
					1,;		   					//NIVEL
					aPropCpos[2][2][2],;		//RESERV
					"",;						//CHECK
					"",;						//TRIGGER
					"S",;						//PROPRI
					"S",;						//BROWSE
					"A",;						//VISUAL
					"R",;						//CONTEXT
					"",;						//OBRIGAT
					"",;						//VLDUSER
					"",;						//CBOX
					"",;						//CBOX SPA
					"",;						//CBOX ENG
					"",;						//PICTVAR
					"",;						//WHEN
					"",;						//INIBRW
					"",;						//SXG
					"",;						//FOLDER
					"S"})						//PYME 
					
		aPHelpPor := {"Data de vigência inicial para utilização",;
					  "do CAEA.                                "} 	
					  				  
		aPHelpEng := {"Validity start date for the CAEA use.   "}					  
					  	 	 				 	  			 	  				 	 
		aPHelpSpa := {"Fecha de vigencia inicial para          "}

					
		PutHelp("PCG6_FHCVDE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	   								
		
		cOrdem2 := GetOrdem('CG6_FHCVAT')
        IF Empty(cOrdem2)
			cOrdem := Soma1(cOrdem)
			lExist  := .F.
		Else
			lExist  := .T.			
		EndIf
		Aadd(aSX3,{	"CG6",;						//Arquivo
					IIf(lExist,cOrdem2,cOrdem),;//Ordem
					"CG6_FHCVAT",;				//Campo
					"D",;						//Tipo					
					008,;						//Tamanho
					0,;					   		//Decimal
					"Vig. Ate.",;			    //Titulo
					"A Fch. Vigen.",;			//Titulo SPA
					"End Val. Dat",;			//Titulo ENG
					"Data de Vigencia Final",;//Descricao
					"Fecha de vigencia final",;//Descricao SPA
					"End Validity Date",;	//Descricao ENG
					"",;						//Picture
					"",;						//VALID
					aPropCpos[4][2][1],;		//USADO
					"",;						//RELACAO
					"",;	   					//F3
					1,;		   					//NIVEL
					aPropCpos[2][2][2],;		//RESERV
					"",;						//CHECK
					"",;						//TRIGGER
					"S",;						//PROPRI
					"S",;						//BROWSE
					"A",;						//VISUAL
					"R",;						//CONTEXT
					"",;						//OBRIGAT
					"",;						//VLDUSER
					"",;						//CBOX
					"",;						//CBOX SPA
					"",;						//CBOX ENG
					"",;						//PICTVAR
					"",;						//WHEN
					"",;						//INIBRW
					"",;						//SXG
					"",;						//FOLDER
					"S"})						//PYME 
					
		aPHelpPor := {"Data de vigência final para utilização  ",;
					  "do CAEA.                                "} 		
					  			  
		aPHelpEng := {"Validity end date to use the CAEA.      "}
 
		aPHelpSpa := {"Fecha de vigencia final para utilizacion",;
			          " del CAEA.                              "}
					
		PutHelp("PCG6_FHCVAT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
					
		
		cOrdem2 := GetOrdem('CG6_FHCTOP')
        IF Empty(cOrdem2)
			cOrdem := Soma1(cOrdem)
			lExist  := .F.
		Else
			lExist  := .T.			
		EndIf
		Aadd(aSX3,{	"CG6",;						//Arquivo
					IIf(lExist,cOrdem2,cOrdem),;//Ordem
					"CG6_FHCTOP",;				//Campo
					"D",;						//Tipo					
					008,;						//Tamanho
					0,;					   		//Decimal
					"Dt. Limite",;		    //Titulo
					"Fch. Limite",;			//Titulo SPA
					"Limit Date",;						//Titulo ENG
					"Data Limite para informar",;//Descricao
					"Fecha limite para informa",;//Descricao SPA
					"Imput Limit Date",;//Descricao ENG
					"",;						//Picture
					"",;						//VALID
					aPropCpos[4][2][1],;		//USADO
					"",;						//RELACAO
					"",;	   					//F3
					1,;		   					//NIVEL
					aPropCpos[2][2][2],;		//RESERV
					"",;						//CHECK
					"",;						//TRIGGER
					"S",;						//PROPRI
					"S",;						//BROWSE
					"A",;						//VISUAL
					"R",;						//CONTEXT
					"",;						//OBRIGAT
					"",;						//VLDUSER
					"",;						//CBOX
					"",;						//CBOX SPA
					"",;						//CBOX ENG
					"",;						//PICTVAR
					"",;						//WHEN
					"",;						//INIBRW
					"",;						//SXG
					"",;						//FOLDER
					"S"})						//PYME 
					
		aPHelpPor := {"Data limite para se informar os         ",;
					  "comprvovantes onde se uitlizou ou CAEA. "}						             
		              		              
					   					  
		aPHelpEng := {"Limit date to enter the receipts where  ",;
				  	  "the CAEA was used.                      "}
				  	   	 				 	  			 	 
				 	 
		aPHelpSpa := {"Data limite para se informar os         ",;
					  "comprvovantes onse se uitlizou ou CAEA. "}
		
		PutHelp("PCG6_FHCTOP",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
			
		
		cOrdem2 := GetOrdem('CG6_XMLPTO')
        IF Empty(cOrdem2)
			cOrdem := Soma1(cOrdem)
			lExist  := .F.
		Else
			lExist  := .T.			
		EndIf
		Aadd(aSX3,{"CG6",;						//Arquivo
					IIf(lExist,cOrdem2,cOrdem),;//Ordem
					"CG6_XMLPTO",;				//Campo
					"M",;						//Tipo
					10,;						//Tamanho
					0,;					   		//Decimal
					"XML Pt. Vend",;	       	//Titulo
					"XML Pt. Vent",;				//Titulo SPA
					"POS XML",;				//Titulo ENG
					"XML dos Pontos de Venda",; //Descricao
					"XML de puntos de venda",;//Descricao SPA
					"XML of Points of Sale",;//Descricao ENG
					"",;						//Picture
					"",;						//VALID
					aPropCpos[4][2][1],;		//USADO
					"",;						//RELACAO
					"",;	   					//F3
					1,;		   					//NIVEL
					aPropCpos[2][2][2],;		//RESERV
					"",;						//CHECK
					"",;						//TRIGGER
					"S",;						//PROPRI
					"N",;						//BROWSE
					"A",;						//VISUAL
					"R",;						//CONTEXT
					"",;						//OBRIGAT
					"",;						//VLDUSER
					"",;						//CBOX
					"",;						//CBOX SPA
					"",;						//CBOX ENG
					"",;						//PICTVAR
					"",;						//WHEN
					"",;						//INIBRW
					"",;						//SXG
					"",;						//FOLDER
					"N"})						//PYME
					
		aPHelpPor := {"XML com os pontos de venda que          ",;
				      "utilizaram o número do CAEA no período. "}						             
		              		              
					   					  
		aPHelpEng := {"XML with points of sale that use the    ",;
					  "CAEA number in the period.              "}
		
		aPHelpSpa := {"XML con los puntos de venta que         ",;
			          "utilizaron el numero del CAEA en el     ",;
			          "periodo.                                "}
						
			
			PutHelp("PCG6_XMLPTO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
				
EndCase

Return(aSX3)     


//-----------------------------------------------------------------------
/*/{Protheus.doc} NFEAtuSX5
Retorna os dados para atualizacao do SX5 conforme update selecionado.

@author Rafael Iaquinto
@since 08.04.2011
@version 1.0 

@param		cUpdate		Nome do Update que deve ser executado.

@return		aSX5		Array com dados para atualizacao do SX5
@obs		
/*/
//----------------------------------------------------------------------
Static Function NFEAtuSX5(cUpdate)
Local aSX5    := {}

// Ainda nao utilizado, quando for necessario utilizar modelo abaixo como exemplo.
/*
Do Case
		
	Case "NFE10R104" $ cUpdate
		SX5->(dbSetOrder(1))
		If SX5->(!MsSeek(xFilial('SX5')+'78'))
			aadd(aSX5,{	'78',; //Tabela
							'01',; //Chave
							'000000001',; // Descricao
							'000000001' ,; // Espanhol
							'000000001'}) // Ingles
	
			
		
		EndIf
EndCase
*/

Return(aSX5)

//-----------------------------------------------------------------------
/*/{Protheus.doc} NFEAtuSX6
Retorna os dados para atualizacao do SX6 conforme update selecionado.

@author Rafael Iaquinto
@since 08.04.2011
@version 1.0 

@param		cUpdate		Nome do Update que deve ser executado.

@return		aSX6		Array com dados para atualizacao do SX6
@obs		
/*/
//---------------------------------------------------------------------- 
Static Function NFEAtuSX6(cUpdate)
Local aSX6 := {}
// Ainda nao utilizado, quando for necessario utilizar modelo abaixo como exemplo.
/*
Do Case
	Case "NFE10R101" $ cUpdate
		AAdd( aSX6,	{ 	"  ",;		   											//--X6_FIL
						"MV_IMPADIC",;											//--X6_VAR
						"L",;													//--X6_TIPO
						"Define se sera impresso as informacoes adicionais ",;	//--X6_DESCRIC
						"Define se sera impresso as informacoes adicionais ",;	//--X6_DSCSPA
						"Define se sera impresso as informacoes adicionais ",;	//--X6_DSCENG
						"do produto no DANFE.                              ",;  //--X6_DESC1
						"do produto no DANFE.                              ",;	//--X6_DSCSPA1
						"do produto no DANFE.                              ",;	//--X6_DSCENG1
						"",;													//--X6_DESC2
						"",;													//--X6_DSCSPA2
						"",;													//--X6_DSCENG2
						".F.",;													//--X6_CONTEUD
						".F.",;													//--X6_CONTSPA
						".F.",;													//--X6_CONTENG				
						"S",;													//--X6_PROPRI
						"N",;													//--X6_PYME
						"",;													//--X6_VALID
						"",;													//--X6_INIT
						"",;													//--X6_DEFPOR
						"",;													//--X6_DEFSPA
						"" })													//--X6_DEFENG 
						
	Case "NFE10R102" $ cUpdate
				
				AAdd( aSX6,	{ 	"  ",;		   									//--X6_FIL
						"MV_SPEDCOL",;											//--X6_VAR
						"C",;													//--X6_TIPO
						"Informar se utiliza TOTVS Colaboração             ",;	//--X6_DESCRIC
						"Informar se utiliza TOTVS Colaboração             ",;	//--X6_DSCSPA
						"Informar se utiliza TOTVS Colaboração             ",;	//--X6_DSCENG
						"S = SIM ou N = Não                                ",;  //--X6_DESC1
						"S = SIM ou N = Não                                ",;	//--X6_DSCSPA1
						"S = SIM ou N = Não                                ",;	//--X6_DSCENG1
						"",;													//--X6_DESC2
						"",;													//--X6_DSCSPA2
						"",;													//--X6_DSCENG2
						"N",;													//--X6_CONTEUD
						"N",;													//--X6_CONTSPA
						"N",;													//--X6_CONTENG				
						"S",;													//--X6_PROPRI
						"N",;													//--X6_PYME
						"",;													//--X6_VALID
						"",;													//--X6_INIT
						"",;													//--X6_DEFPOR
						"",;													//--X6_DEFSPA
						"" })													//--X6_DEFENG 	 						
	
EndCase
*/
Return(aSX6)


//-----------------------------------------------------------------------
/*/{Protheus.doc} NFEAtuSX7
Retorna os dados para atualizacao do SX7 conforme update selecionado.

@author Rafael Iaquinto
@since 08.04.2011
@version 1.0 

@param		cUpdate		Nome do Update que deve ser executado.

@return		aSX7		Array com dados para atualizacao do SX7
@obs		
/*/
//---------------------------------------------------------------------- 
Static Function NFEAtuSX7(cUpdate)

Local aSX7    := {}

/* Ainda nao utilizado, quando for necessario utilizar modelo abaixo como exemplo.
Do Case
	Case "NFE10R101" $ cUpdate 

		dbSelectArea("SX7")
		SX7->(DbSetOrder(1))
		If !SX7->(MsSeek("DA3_FILBAS"))
			aadd(aSX7,{	"DA3_FILBAS",; //Campo
						"001",;				//Sequencia
						"Posicione('SX6',1,M->DA3_FILBAS+'MV_CDRORI','X6_CONTEUD')",;		//Regra
						"DA3_FILBAS",;     	//Campo Dominio
						"P",;              	//Tipo
						"N",;  				//Posiciona?
						"",;				//Alias
						0,;					//Ordem do Indice
						"",;				//Chave
						"S",;				//Proprietario
						""})				//Condicao
		Endif
		If !SX7->(MsSeek("DA4_FILBAS"))
			aadd(aSX7,{	"DA4_FILBAS",; //Campo
						"001",;				//Sequencia
						"Posicione('SX6',1,M->DA4_FILBAS+'MV_CDRORI','X6_CONTEUD')",;		//Regra
						"DA4_FILBAS",;     	//Campo Dominio
						"P",;              	//Tipo
						"N",;  				//Posiciona?
						"",;				//Alias
						0,;					//Ordem do Indice
						"",;				//Chave
						"S",;				//Proprietario
						""})				//Condicao
		Endif  
EndCase
*/	

Return(aSX7)  



//-----------------------------------------------------------------------
/*/{Protheus.doc} NFEAtuSXA
Retorna os dados para atualizacao do SXA conforme update selecionado.

@author Rafael Iaquinto
@since 08.04.2011
@version 1.0 

@param		cUpdate		Nome do Update que deve ser executado.

@return		aSXA		Array com dados para atualizacao do SXA
@obs		
/*/
//---------------------------------------------------------------------- 
Static Function NFEAtuSXA(cUpdate)

Local aSXA    := {}

/* Ainda nao utilizado, quando for necessario utilizar modelo abaixo como exemplo.
Do Case
	Case "NFE10R101" $ cUpdate 

		SXA->(dbSetOrder(1))
		
		//Pastas para Cadastro de Endereco de Cliente
		If SXA->(!dbSeek("DUL"+"1"))
			Aadd(aSXA,{"DUL",;		//Alias
				"1",;						//Ordem
				"Cadastrais",;			//Descricao Port.
				"",;						//Descricao Esp.
				"",;						//Descricao Eng.
				"S"})						//Propeitario
		EndIf
		
		//Pastas para Cadastro do Redespachante
		If SXA->(!dbSeek("DUL"+"2"))
			Aadd(aSXA,{"DUL",;		//Alias
				"2",;						//Ordem
				"Redespachante",;		//Descricao Port.
				"",;						//Descricao Esp.
				"",;						//Descricao Eng.
				"S"})						//Propeitario
		EndIf
EndCase
*/		

Return(aSXA)  
      

//-----------------------------------------------------------------------
/*/{Protheus.doc} NFEAtuSXB
Retorna os dados para atualizacao do SXB conforme update selecionado.

@author Rafael Iaquinto
@since 08.04.2011
@version 1.0 

@param		cUpdate		Nome do Update que deve ser executado.

@return		aSXB		Array com dados para atualizacao do SXB
@obs		
/*/
//---------------------------------------------------------------------- 
Static Function NFEAtuSXB(cUpdate)

Local aSXB := {}

/* Ainda nao utilizado, quando for necessario utilizar modelo abaixo como exemplo.
Do Case
	Case "NFE10R101" $ cUpdate 
		//------------------------------------------------
		// Consulta DD7
		//------------------------------------------------
		aAdd( aSXB, { ;
			'DD7'																	, ; // Alias
			'1'																	, ; // Tipo
			'01'																	, ; // Sequencia
			'RE'																	, ; // Coluna
			'Aeroportos x Regiao'											, ; // Descricao
			'Aeropuerto vs Region'											, ; // Descricao SPA
			'Airports x Region'											, ; // Descricao ENG
			'DD7'																	} ) // Contem
		
		aAdd( aSXB, { ;
			'DD7'																	, ; // Alias
			'2'																	, ; // Tipo
			'01'																	, ; // Sequencia
			'01'																	, ; // Coluna
			''																		, ; // Descricao
			''																		, ; // Descricao SPA
			''																		, ; // Descricao ENG
			'TmsA320DD7()'														} ) // Contem
		
		aAdd( aSXB, { ;
			'DD7'																	, ; // Alias
			'5'																	, ; // Tipo
			'01'																	, ; // Sequencia
			''																		, ; // Coluna
			''																		, ; // Descricao
			''																		, ; // Descricao SPA
			''																		, ; // Descricao ENG
			'DD7->DD7_CODAER'													} ) // Contem

*/
	
Return(aSXB)


//-----------------------------------------------------------------------
/*/{Protheus.doc} NFEAtuSX1
Retorna os dados para atualizacao do SX1 conforme update selecionado.

@author Douglas Parreja
@since 11/02/2014
@version 1.0 

@param		cUpdate		Nome do Update que deve ser executado.

@return		aSX1		Array com dados para atualizacao do SX1
@obs		
/*/
//---------------------------------------------------------------------- 

Static Function NFEAtuSX1(cUpdate)

Local aSX1 := {}

Do Case	
	Case "NFE11R155" $ cUpdate
		
		AAdd( aSX1,	{ "AUTONFE",;								//--X1_GRUPO
						"01",;										//--X1_ORDEM
						"Serie",;									//--X1_PERGUNT
						"",;										//--X1_PERSPA
						"",; 										//--X1_PERENG
						"mv_ch1",;									//--X1_VARIAVL
						"C",; 										//--X1_TIPO
						03,; 										//--X1_TAMANHO
						00,; 										//--X1_DECIMAL
						00,;										//--X1_PRESEL
						"G",;	  									//--X1_GSC
						"",;	   									//--X1_VALID
						"mv_par01",;								//--X1_VAR01
						"",;		  								//--X1_DEF01
						"",;			   							//--X1_DEFSPA				
						"",;										//--X1_DEFENG1
						"",;										//--X1_CNT01
						"",;										//--X1_VAR02
						"",;										//--X1_DEF02
						"",;										//--X1_DEFSPA2
						"",;										//--X1_DEFENG2
						"",;										//--X1_CNT02
						"",;										//--X1_VAR03
						"",;										//--X1_DEF03
						"",;										//--X1_DEFSPA3
						"",;										//--X1_DEFENG3
						"",;										//--X1_CNT03
						"",;										//--X1_VAR04
						"",;										//--X1_DEF04
						"",;										//--X1_DEFSP4
						"",;										//--X1_DEFENG4
						"",;										//--X1_CNT04
						"",;										//--X1_VAR05
						"",;										//--X1_DEF05
						"",;										//--X1_DEFSPA5
						"",;										//--X1_DEFENG5
						"",;										//--X1_CNT05
						"",;										//--X1_F3
						"",;										//--X1_PYME
						"",;										//--X1_GRPSXG
						"",;										//--X1_HELP
						"",;										//--X1_PICTURE
						"" })										//--X1_IDFIL
												
EndCase


Return(aSX1)
                                      

//-------------------------------------------------------------------------
/*/{Protheus.doc} ARGPtuHlp
Retorna a atualizacao do Help de campo conforme update selecionado.

@author Rafael Iaquinto
@since 08.04.2011
@version 1.0 

@param		cUpdate		Nome do Update que deve ser executado.

@return		.T.			Retorno logico padrao.
@obs		
/*/
//---------------------------------------------------------------------- 

Static Function ARGPtuHlp(cUpdate)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajustando os Helps de Campos                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Ainda não utilizado, quando for necessário utilizar o exemplo abaixo.
/*
Do Case	
	Case "NFE10R101" $ cUpdate
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ HELPS -> CAMPOS DA TABELA DEK ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PutHelp('',{'Descrever a Inf. Adicionais do Produto.','Este conteudo sera levado para a tag','<infAdprod> do XML da NF-e.'},{''},{''},.T.)
	
EndCase
*/	                                                                          


Return(.T.)

//-------------------------------------------------------------------------
/*/{Protheus.doc} ARG11R10Des
Retorna a Descricao de todos Updates para argentina.

@author Rafael Iaquinto
@since 08.04.2011
@version 1.0 

@param		cUpdate		Nome do Update que deve ser executado.

@return		aRet		Array com as informaçoes dos UDATES.
@obs		
/*/
//---------------------------------------------------------------------- 
Function ARG11R10Des()
Local aRet := {}
Local cTab := "" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ESTRUTURA DO ARRAY aRET:                                             ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ aRet[01] - (C) Numero sequencial conrforme implementado.            ³
//³ aRet[02] - (C) Nome da Function                                      ³
//³ aRet[03] - (C) Descritivo do Update                                  ³
//³ aRet[04] - (L) Situacao para determinar se o Update ja foi executado ³
//³ aRet[05] - (C) Numero do Chamado / Numero do BOPS       +             ³
//³ aRet[06] - (C) Boletim tecnico publicado no FTP (Nome do Arquivo)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSELECTAREA('SX6')
                                                                                              
//UPDATE ARG11R101
cTab:= Posicione('SX2',1,'CG6','X2_ARQUIVO')
AAdd(aRet, {"01",'ARG11R101', STR0001 ,Iif (!Empty(cTab),.T.,.F.),STR0002}) //"Criação da tabela CG6 - Controle de solicitação de CAEA"###"Controle de Solicitação de CAEA" 

/*OBSERVAÇÃO - Quando o parâmetro for do tipo C (Criado com conteúdo vazio) ou do tipo L - 
utilizar o modelo que verifica o parâmetro na SX6, desta forma o Status mudará para 'Executado'
Ex: NFE10R107*/

Return( aRet )

Static Function RetornaOrdem(cTabela, aOrdem)
 
Local aAreaSX3 := SX3->(GetArea())
Local nX:= aScan(aOrdem,{ |x| x[1] == cTabela})

If nX > 0
	cProxOrdem:= Soma1(aOrdem[nX][2])
	aOrdem[nX][2]:= cProxOrdem 
Else
	dbSelectArea("SX3")
	dbSetOrder(1)
	If MsSeek(cTabela)
		Do While SX3->X3_ARQUIVO == cTabela .And. !SX3->(Eof())
			cOrdem := SX3->X3_ORDEM
			SX3->(dbSkip())
		Enddo
	Else
		cOrdem := "00"
	EndIf
	cProxOrdem := Soma1(cOrdem)
	aadd(aOrdem,{cTabela,cProxOrdem})
EndIf

SX3->(RestArea(aAreaSX3))

Return cProxOrdem

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetOrdem
Retorna a ordem do campo na SX3

@author Natalia Sartori
@since 04.07.2012
@version 1.00 

@param		cCampo		Nome do campo a ser pesquisado

@return		cOrdem		Ordem do campo (X3_ORDEM)
/*/
//-----------------------------------------------------------------------                       
Static Function GetOrdem(cCampo)

Local cOrdem := ""
Local aAreaSX3 := SX3->(GetArea())
	
	dbSelectArea("SX3")
	dbSetOrder(2)
	If MsSeek(cCampo)
		cOrdem := SX3->X3_ORDEM		
	EndIf

	SX3->(RestArea(aAreaSX3))

Return cOrdem
