#INCLUDE "PROTHEUS.CH"  
#INCLUDE "DEFTEF.CH"  


Function LOJA1933 ; Return  // "dummy" function - Internal Use

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJCRetornoGerenciบAutorณVENDAS CRM     บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Classe Responsavel por guarda informacoes do retorno       บฑฑ 
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Class LJCRetornoGerenciador
	
	Data c000		 
	Data c001 
	Data c002 
	Data c003 
	Data c004 
	Data c005 
	Data c006 
	Data c007 
	Data c008 
	Data c009 
	Data c010 
	Data c011 
	Data c012 
	Data c013 
	Data c014 
	Data c015 
	Data c016 
	Data c017 
	Data c018 
	Data o019 
	Data o020 
	Data o021 
	Data c022 
	Data c023 
	Data c024 
	Data c025 
	Data c026 
	Data c027 
	Data c028 
	Data o029 
	Data c030 
	Data c031 
	Data c032 
	Data c033 
	Data c034 
	Data c035 
	Data c036 
	Data c037 
	Data c038 
	Data c039 
	Data c040 
	Data c701
	Data c702
	Data c703
	Data c704
	Data c705
	Data c706
	Data c707
	Data c708
	Data c709
	Data c710
	Data o711
	Data c712
	Data o713
	Data c714
	Data o715
	Data c716
	Data c999 

	Method New() 

EndClass         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNew          บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New() Class LJCRetornoGerenciador

	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicia Objeto 		  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Self:c000 := ''
	Self:c001 := ''
	Self:c002 := ''
	Self:c003 := ''
	Self:c004 := ''
	Self:c005 := ''
	Self:c006 := ''
	Self:c007 := ''
	Self:c008 := ''
	Self:c009 := ''
	Self:c010 := ''
	Self:c011 := ''
	Self:c012 := ''
	Self:c013 := ''
	Self:c014 := ''
	Self:c015 := ''
	Self:c016 := ''
	Self:c017 := ''
	Self:c018 := ''
	Self:o019 := LJCList():New()
	Self:o020 := LJCList():New()
	Self:o021 := LJCList():New()
	Self:c022 := ''
	Self:c023 := ''
	Self:c024 := ''
	Self:c025 := ''
	Self:c026 := ''
	Self:c027 := ''
	Self:c028 := ''
	Self:o029 := LJCList():New()
	Self:c030 := ''
	Self:c031 := ''
	Self:c032 := ''
	Self:c033 := ''
	Self:c034 := ''
	Self:c035 := ''
	Self:c036 := ''
	Self:c037 := ''
	Self:c038 := ''
	Self:c039 := ''
	Self:c040 := '' 
	Self:c701 := ''
	Self:c702 := ''
	Self:c703 := ''
	Self:c704 := ''
	Self:c705 := ''
	Self:c706 := ''
	Self:c707 := ''
	Self:c708 := ''
	Self:c709 := ''
	Self:c710 := ''
	Self:o711 := LJCList():New()
	Self:c712 := ''
	Self:o713 := LJCList():New()
	Self:c714 := '' 
	Self:o715 := LJCList():New()
	Self:c716 := ''
	Self:c999 := ''


Return Self