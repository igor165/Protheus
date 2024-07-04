/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Compatibilidade old navigator													  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/     
if (typeof Object.create !== 'function') {
	Object.create = function (o) {
		function F() { }
		F.prototype = o;
		return new F();
	};
}
/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Globais																			  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/    
cRaiz       = 'imagens-pls/';
cAtalhos    = 'atalhos_portal/';
cPEmpBenef  = 'empbenef/';
cPPrestador = 'prestador/';
inPBlock    = undefined;
nErr        = 0;
nQtdRegTemp = 0;
numeroPaginaTemp = "";
blurPrevent = false;
cAlitab		= "";
cChave		= "";
cNoArqComp  = "";
lExcArq	    = "0";
lVisArq     = "0";
lDelExec = false;
cProcChanged =  {"codpad": {"defaultValue":"","actualValue":""}, "codpro": {"defaultValue":"","actualValue":""}}; //variavel criada para verificar quando trocar o procedimento excluir o executante vinculado

var blurPadPro = function() {
  if(this.id == "cCodPadSExe"){
	cProcChanged.codpad.actualValue = this.value;
  }else if(this.id == "cCodProSExe"){
	cProcChanged.codpro.actualValue = this.value;
  }
};

/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Class              � Autor � Alexander Santos       � Data � 28.01.2013���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Class principal														  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/    
var Class = (function () {
    function Class(definition) {
		//�������������������������������������������������������������������������
		//� cria funcao pela declaracao
		//�������������������������������������������������������������������������
        function Class(){}
		//�������������������������������������������������������������������������
		//� verifica se obj e estender outro
		//�������������������������������������������������������������������������
        var $extend = hasOwnProperty.call(definition, "extend");
		//�������������������������������������������������������������������������
		//� Temp atalho para heranca static
		//�������������������������������������������������������������������������
        var $;
		//�������������������������������������������������������������������������
		//� Verifica se tem construtor
		//�������������������������������������������������������������������������
        if (hasOwnProperty.call(definition, "constructor")) {
			//�������������������������������������������������������������������������
			//� Envolve para execucao mais rapida
			//�������������������������������������������������������������������������
            Class = constructor(definition.constructor);
        }
		//�������������������������������������������������������������������������
		//� Atribui heranca de  public static properties/methods se estender
		//�������������������������������������������������������������������������
        if ( $extend &&
             hasOwnProperty.call($ = definition.extend, "definition") &&
             hasOwnProperty.call($ = $.definition, "statics") ) {
			 
             extend.call(Class, $.statics);
        }
		//�������������������������������������������������������������������������
		//� Atribui public static properties/methods, se definida eventualmente substitui heranca static
		//�������������������������������������������������������������������������
        if (hasOwnProperty.call(definition, "statics")) {
            extend.call(Class, definition.statics);
        }
		//�������������������������������������������������������������������������
		//� Se estendeu atribui a prototype
		//�������������������������������������������������������������������������
        ($extend ?
			//�������������������������������������������������������������������������
			//� Estende a prototype a definicao do obj
			//�������������������������������������������������������������������������
            extend.call(Class.prototype = create(definition.extend.prototype), definition) :
            
            Class.prototype = create(definition)
        )
		//�������������������������������������������������������������������������
		//� Certifica que o constructor esta ok
		//�������������������������������������������������������������������������
        .constructor = Class;
		//�������������������������������������������������������������������������
		//� Definicao static public
		//�������������������������������������������������������������������������
        Class.definition = definition;
		//�������������������������������������������������������������������������
		//� Retorno da class criada
		//�������������������������������������������������������������������������
        return Class;
    }
	//�������������������������������������������������������������������������
	//� Construtor
	//�������������������������������������������������������������������������
    function constructor(constructor) {
		//�������������������������������������������������������������������������
		//� Cria o nomeador da declaracao Class function
		//�������������������������������������������������������������������������
        function Class() {
			//�������������������������������������������������������������������������
			//� Devolve caso de duplicidade
			//�������������������������������������������������������������������������
            return constructor.apply(this, arguments);
        }
        return Class;
    }
	//�������������������������������������������������������������������������
	//� Estende um contexto generico pelo __proto__ object
	//�������������������������������������������������������������������������
    function extend(__proto__) {
        for (var key in __proto__) {
            if (hasOwnProperty.call(__proto__, key)) {
                this[key] = __proto__[key];
            }
        }
        return this;
    }
	//�������������������������������������������������������������������������
	//� Atalho para object.protoype.hasOwnProperty
	//�������������������������������������������������������������������������
    var hasOwnProperty = Object.prototype.hasOwnProperty;
	//�������������������������������������������������������������������������
	//� Emulacao Object.create emulator
	//�������������������������������������������������������������������������
    var create = Object.create || (function () {
        function Object() {}
        return function (__proto__) {
            Object.prototype = __proto__;
            return new Object;
        };
    })();
	//�������������������������������������������������������������������������
	//� optional "for in" para Internet Explorer
	//� Internet Explorer nao enumerate properties/methods com nome present no Object.prototype
	//�������������������������������������������������������������������������
    if (!({toString:null}).propertyIsEnumerable("toString")) {
		//�������������������������������������������������������������������������
		//� Se acontecer, para esterder vai precidar de forcar Object.prototype names
		//�������������������������������������������������������������������������
        extend = (function ($extend) {
            function extend(__proto__) {
                for (var i = length, key; i--;) {
                    if (hasOwnProperty.call(__proto__, key = split[i])) {
                        this[key] = __proto__[key];
                    }
                }
				//�������������������������������������������������������������������������
				//� Executa o original extend em casos de outras properties/methods
				//�������������������������������������������������������������������������
                return $extend.call(this, __proto__);
            }
			//�������������������������������������������������������������������������
			//� constructor nao esta na lista  reatribui 
			//�������������������������������������������������������������������������
            var split = "hasOwnProperty.isPrototypeOf.propertyIsEnumerable.toLocaleString.toString.valueOf".split(".");
            var length = split.length;
            return extend;
        })(extend);
    }
	//�������������������������������������������������������������������������
	//� A Class e uma funcao
	//�������������������������������������������������������������������������
    Class.prototype = Function.prototype;

    return Class;

})();
/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �BrowserId          � Autor � Alexander Santos       � Data � 05.03.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Verifica o browse que esta sendo usado								  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/    
var BrowserId = {

	init: function() {
		this.browser = this.pesqString(this.dataBrowser) || "An unknown browser";
		this.versao  = this.pesqVersao(navigator.userAgent) || this.pesqVersao(navigator.appVersion) || "an unknown version";
		this.OS 	 = this.pesqString(this.infoOS) || "an unknown OS";
	},                                                 
	
	pesqString: function(data) {
	
		for (var i=0;i<data.length;i++) {
		
			var dataString 	= data[i].string;
			var dataProp 	= data[i].prop;
			
			this.versaopesqString = data[i].versao || data[i].idB;
			
			if (dataString) {
				if (dataString.indexOf(data[i].sisFab) != -1)
					return data[i].idB;
			}
			else if (dataProp)
				return data[i].idB;
		}
	},
	
	pesqVersao: function(dataString) {
		var index = dataString.indexOf(this.versaopesqString);
		if (index == -1) return;
		return parseFloat(dataString.substr(index+this.versaopesqString.length+1,3));
	},
	
	dataBrowser: [
		{
			string: navigator.userAgent,
			sisFab: "Chrome",
			idB: "CH",//Chrome
			versao: "Version"
			
		},
		{ 	string: navigator.userAgent,
			sisFab: "OmniWeb",
			idB: "OW",//OmniWeb
			versao: "OmniWeb/"
		},
		{
			string: navigator.vendor,
			sisFab: "Apple",
			idB: "SF",//Safari
			versao: "Version"
		},
		{
			prop: window.opera,
			idB: "OP",//Opera
			versao: "Version"
		},
		{
			string: navigator.vendor,
			sisFab: "iCab",
			idB: "IC",//Icab
			versao: "Version"
		},
		{
			string: navigator.vendor,
			sisFab: "KDE",
			idB: "KQ",//Konqueror
			versao: "Version"
		},
		{
			string: navigator.userAgent,
			sisFab: "Firefox",
			idB: "FF",//FireFox
			versao: "Version"
		},
		{
			string: navigator.vendor,
			sisFab: "Camino",
			idB: "CA",//Camino
			versao: "Version"
		},
		{	// for newer Netscapes (6+)
			string: navigator.userAgent,
			sisFab: "Netscape",
			idB: "NS",//Netscape
			versao: "Version"
		},
		{
			string: navigator.userAgent,
			sisFab: "MSIE",
			idB: "IE",//Internet Explorer
			versao: "MSIE"
		},
		{
			string: navigator.userAgent,
			sisFab: "Gecko",
			idB: "MZ",//Mozilla
			versao: "rv"
		},
		{ 	// for older Netscapes (4-)
			string: navigator.userAgent,
			sisFab: "Mozilla",
			idB: "NS",//Nestscape
			versao: "Mozilla"
		}
	],
	
	infoOS : [
		{
			string: navigator.platform,
			sisFab: "Win",
			idB: "Windows"
		},
		{
			string: navigator.platform,
			sisFab: "Mac",
			idB: "Mac"
		},
		{
			string: navigator.userAgent,
			sisFab: "iPhone",
			idB: "iPhone/iPod"

	    },
		{
			string: navigator.platform,
			sisFab: "Linux",
			idB: "Linux"
		}
	]

};
BrowserId.init();
/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �undecode           � Autor � Alexander Santos       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Ajuste para texto com acentua��o									  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/    
function undecode(cString) {
	cString = cString.replace(/&aacute;/g,"�")
	cString = cString.replace(/&agrave;/g,"�")
	cString = cString.replace(/&acirc;/g,"�")
	cString = cString.replace(/&atilde;/g,"�")
	cString = cString.replace(/&auml;/g,"�")
	cString = cString.replace(/&Aacute;/g,"�")
	cString = cString.replace(/&Agrave;/g,"�")
	cString = cString.replace(/&Atilde;/g,"�")
	cString = cString.replace(/&Acirc;/g,"�")
	cString = cString.replace(/&Auml;/g,"�")
	
	cString = cString.replace(/&eacute;/g,"�")
	cString = cString.replace(/&egrave;/g,"�")
	cString = cString.replace(/&ecirc;/g,"�")
	cString = cString.replace(/&euml;/g,"�")
	cString = cString.replace(/&Eacute;/g,"�")
	cString = cString.replace(/&Egrave;/g,"�")
	cString = cString.replace(/&Ecirc;/g,"�")
	cString = cString.replace(/&Euml;/g,"�")
	
	cString = cString.replace(/&iacute;/g,"�")
	cString = cString.replace(/&igrave;/g,"�")
	cString = cString.replace(/&iuml;/g,"�")
	cString = cString.replace(/&Iacute;/g,"�")
	cString = cString.replace(/&Igrave;/g,"�")
	cString = cString.replace(/&Icirc;/g,"�")
	cString = cString.replace(/&Iuml;/g,"�")
	
	cString = cString.replace(/&oacute;/g,"�")
	cString = cString.replace(/&ograve;/g,"�")
	cString = cString.replace(/&otilde;/g,"�")
	cString = cString.replace(/&ocirc;/g,"�")
	cString = cString.replace(/&ouml;/g,"�")
	cString = cString.replace(/&Oacute;/g,"�")
	cString = cString.replace(/&Ograve;/,"�")
	cString = cString.replace(/&Otilde;/g,"�")
	cString = cString.replace(/&Ocirc;/g,"�")
	cString = cString.replace(/&Ouml;/g,"�")
	
	cString = cString.replace(/&uacute;/g,"�")
	cString = cString.replace(/&ugrave;/g,"�")
	cString = cString.replace(/&uuml;/g,"�")
	cString = cString.replace(/&ucirc;/g,"�")
	cString = cString.replace(/&Ucirc;/g,"�")
	cString = cString.replace(/&Uacute;/,"�")
	cString = cString.replace(/&Ugrave;/g,"�")
	cString = cString.replace(/&Uuml;/g,"�")
	
	cString = cString.replace(/&ccedil;/g,"�")
	cString = cString.replace(/&Ccedil;/g,"�")

	cString = cString.replace(/&deg/g,"�")

return cString

}
/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �ChamaPoP           � Autor � Alexander Santos       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Mostra window pop de uma determinada tela							  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/    
function ChamaPoP(rotina,tagname,sc,tpwin,lag,alt,nFormaAbert) { 
	var largura 	= 502; 
	var altura  	= 350;
	var res_ver 	= screen.height;
	var res_hor 	= screen.width;
	var pos_ver_fin = 0;
	var pos_hor_fin = 0;
	var tipojanela 	= 0; //0=open ; 1=showModalDialog ; 2=showModelessDialog
	var nFormaAbert = ( wasDef(typeof nFormaAbert) ) ? nFormaAbert : 1; 
	
	if(rotina.search("W_PPLSXF3") != -1){
		var iframe = document.createElement("iframe");
		iframe.id = "iframeF3";
		iframe.src = rotina;
		iframe.style.width = "100%";
		iframe.style.height = "100%";
		iframe.frameBorder = "0";
		iframe.scrolling = "no";

		modalBS("Pesquisar", "", undefined, undefined, undefined, undefined, iframe);
	}else{
		//������������������������������������������������������������������������Ŀ
		//� Caso nao seja possivel testar esta propriedade recrio o obj			   �
		//�������������������������������������������������������������������������� 
		try {
			if (newWindowOpen.closed)
				newWindowOpen = null;
		} catch(e) {
			newWindowOpen = null;
		}
		
		if(nFormaAbert == 0){ //0 = atualiza a janela que estava aberta
			newWindowOpen = null;
			
		}else if(nFormaAbert == 1){ //1 = cria uma nova janela 
			
			newWindowOpen = null;
			//necess�rio para abrir v�rias janelas
			tagname = Math.floor(Math.random() * 65536).toString(); //range dos inteiros positivos (entre 0 e 65536):
		}
		
		//���������������������������������������������������������������������������������
		//� Verifica se o parametros de altura e largura foi informado true = nao informado
		//��������������������������������������������������������������������������������� 
		if ( !newWindowOpen ) { 
												 
			if ( wasDef( typeof(lag) ) )
				largura = lag;
				
			if ( wasDef( typeof(alt) ) )
				altura = alt;       
		
			if ( wasDef( typeof(tpwin) ) )
				tipojanela = tpwin;       
			//������������������������������������������������������������������������Ŀ
			//� Redefine as posicoes												   �
			//��������������������������������������������������������������������������
			pos_ver_fin = ((res_ver - altura)/2)-20
			pos_hor_fin = (res_hor - largura)/2
			//������������������������������������������������������������������������Ŀ
			//� Achar campos do f3When												   �
			//��������������������������������������������������������������������������
			while ( rotina.indexOf('~') != -1 ) {
				var nPos = rotina.indexOf('~');
				if ( nPos != -1 ) {
					var cRotinaAux 	= rotina.substr(nPos+1)
					var nPos2		= cRotinaAux.indexOf('.')
					if ( nPos2 != -1 ) {
						cCampo		= cRotinaAux.substr(0,nPos2)
						cConteudo   = getObjectID(cCampo).value;
						rotina		= rotina.substr(0,nPos)+cConteudo+cRotinaAux.substr(nPos2)
					}
				} 
			}
			//������������������������������������������������������������������������Ŀ
			//� Verifica se o navegador suporta										   �
			//��������������������������������������������������������������������������  
			if(tipojanela==1 && !window.showModalDialog)
				tipojanela=0;
				
			if(tipojanela==2 && !window.showModelessDialog)
				tipojanela=0;
			//������������������������������������������������������������������������Ŀ
			//� Abre a tela conforme o tipo											   �
			//��������������������������������������������������������������������������  
			switch (tipojanela) {
				case 0:    
						newWindowOpen = window.open(rotina,tagname,"width="+largura+",height="+altura+",top="+pos_ver_fin+",left="+pos_hor_fin+",scrollbars="+sc+",location=no,toolbar=no,status=no");
						return newWindowOpen;
						break;                                                                                                                                         
				case 1:                      
						newWindowOpen = window.showModalDialog(rotina,tagname,"dialogwidth:"+largura+"px;dialogheight:"+altura+"px;scroll:"+sc+";status:no");                                        
						
						return newWindowOpen;
						break
				case 2:            
						newWindowOpen = window.showModelessDialog(rotina,tagname,"dialogwidth:"+largura+"px;dialogheight:"+altura+"px;scroll:"+sc+";status:no");
						
						return newWindowOpen;
						break;
			}
		} else { 
		  newWindowOpen.focus();
		  return newWindowOpen;
		}
	}
}
/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �MPSelect           � Autor � Alexander Santos       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Tratamento para combos pega o texto pelo valor e valor pelo texto	  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/    
function MPSelect(oObj,cTp,cText) {
	var cReturn = "";  
	
	if (cTp == 'VT') {
		//������������������������������������������������������������������������Ŀ
		//� Pega o texto com base no valor									       �
		//��������������������������������������������������������������������������
		for (var y=0; y<oObj.options.length; y++) {
		    if ( isEmpty(oObj.value) ) return cReturn;          

			if (oObj.options[y].value == oObj.value)
				cReturn = oObj.options[y].text;          	
		}
	} else {
		//������������������������������������������������������������������������Ŀ
		//� Pega o texto com base no valor										   �
		//��������������������������������������������������������������������������
		for (var y=0; y<oObj.options.length; y++) {
		    if ( isEmpty(cText) ) return cReturn;          

			if (oObj.options[y].text == unescape(escape(cText).replace(/%u2212/g, "-")) )
				cReturn = oObj.options[y].value;	
		}
	}
	if ( isEmpty(cReturn) && !isEmpty(cText)) {
		setTC(oObj,"");
	
		oObj.options[0] = new Option(cText, cText);
		cReturn = oObj.options[0].value;	
	}
	                          
	return cReturn;
}		
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �FDisElemen         � Autor � Alexander Santos       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Desabilita campos e botoes de uma tag								  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/    
function FDisElemen(aMatEle,lB,lCF) {
	var lClearField = ( !lCF ) ? false : lCF;
	//������������������������������������������������������������������������Ŀ
	//� Monta a matriz dos elementos										   �
	//��������������������������������������������������������������������������
	aElement = aMatEle.split("|");
	//������������������������������������������������������������������������Ŀ
	//� Desabilita ou habilita												   �
	//��������������������������������������������������������������������������
	for (var x=0; x<aElement.length; x++) {
		var trs = document.getElementsByName(aElement[x]);
		//������������������������������������������������������������������������Ŀ
		//� For da tag tr														   �
		//��������������������������������������������������������������������������
		for (var i=0; i<trs.length; i++) {
			trs[i].disabled = lB;
			
			var tds = trs[i].getElementsByTagName("*");
			//������������������������������������������������������������������������Ŀ
			//� For da tag td e seus objs											   �
			//��������������������������������������������������������������������������
			for (var y=0;y<tds.length;y++) {
			
				if ( (tds[y].type != undefined || tds[y].tagName.toLowerCase() == 'img') && !isEmpty(tds[y].type) && tds[y].name != "*") {
					if (tds[y].tagName.toLowerCase() == 'img' || tds[y].type.toLowerCase() == 'button')
						 setDisable(tds[y].name,lB);
					else tds[y].disabled = lB;                                                 
					//�������������������������������������������������������������������������
					//� Desabilita e limpa o campo
					//�������������������������������������������������������������������������
					if (lClearField && tds[y].type != 'button') {
						setField(tds[y].name,"");
					}
				}	
			}
		}
	}	
}                         
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �FormatMoeda        � Autor � Alexander Santos       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Formata um campo monetariamente ao digitar o numero					  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/    
function FormatMoeda(oObj, event, milSep, decSep) {
  var sep 		= 0;
  var key 		= '';
  var i 		= j = 0;
  var len 		= len2 = 0;
  var strCheck 	= '0123456789';
  var aux 		= aux2 = '';
  var whichCode = (BrowserId.browser == 'IE') ? event.keyCode : event.which;
  
  if (oObj.value.length >= oObj.maxLength) return true;
   
  if (whichCode == 0) return true;  // tab
  if (whichCode == 13) return true;  // Enter
  if (whichCode == 8) return true;  // Delete

  key = String.fromCharCode(whichCode);  // Get key value from key code

  if (strCheck.indexOf(key) == -1) return false;  // Not a valid key

  len = oObj.value.length;

  for(i = 0; i < len; i++)
  	if ((oObj.value.charAt(i) != '0') && (oObj.value.charAt(i) != decSep)) break;
  	
  aux = '';
  for(; i < len; i++)
  	if (strCheck.indexOf(oObj.value.charAt(i))!=-1) aux += oObj.value.charAt(i);
  	
  aux += key;
  len = aux.length;

  if (len == 0) oObj.value = '';
  if (len == 1) oObj.value = '0'+ decSep + '0' + aux;
  if (len == 2) oObj.value = '0'+ decSep + aux;

  if (len > 2) {
    aux2 = '';
    for (j = 0, i = len - 3; i >= 0; i--) {
      if (j == 3) {
        aux2 += milSep;
        j = 0;
      }
      aux2 += aux.charAt(i);
      j++;
    }
    oObj.value = '';
    len2 = aux2.length;
    for (i = len2 - 1; i >= 0; i--)
    oObj.value += aux2.charAt(i);
    oObj.value += decSep + aux.substr(len - 2, len);
  }
  return false;
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �MaskMoeda          � Autor � Alexander Santos       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Atribui um int e devolve com mask		 							  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/      
function MaskMoeda( int ) {  
	var tmp = int+'';  
	
	if( tmp.length == 1 )  
		 tmp = tmp.replace(/([0-9]{1})$/g, "0,0$1");  
	else if( tmp.length == 2 ) 
		tmp = tmp.replace(/([0-9]{2})$/g, "0,$1");  
	else tmp = tmp.replace(/([0-9]{2})$/g, ",$1");  	

	if( tmp.length > 6 )  
			tmp = tmp.replace(/([0-9]{3}),([0-9]{2}$)/g, ".$1,$2");  

	return tmp;  
}  
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �TxtBoxFormat       � Autor � Alexander Santos       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Formata campo input na digitacao		 							  ���
�������������������������������������������������������������������������������������Ĵ��
���   CEP  -> 99.999-999															  ���
���   CPF  -> 999.999.999-99														  ���
���   CNPJ -> 99.999.999/9999-99													  ���
���   Data -> 99/99/9999															  ���
���   Tel  -> (99) 9999-9999														  ���
���   Hora -> 99:99																	  ���
���   PIS  -> 999.99999.99-9														  ���
���   MatUsu-> 9999.9999.999999.99-9												  ���
���   onkeypress="return TxtBoxFormat(this,'99:99',event);" 						  ���
���   onBlur="TxtBoxFormat(this,'99:99',"");" 						   		 		  ���
���   Uso <input type="textbox"														  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/      
function TxtBoxFormat(oObj, event, sMask) {
	
	var i, nCount, sValue, fldLen, mskLen,bolMask, sCod, nTecla;
  	var nTecla 	= (BrowserId.browser == 'IE') ? event.keyCode : event.which;
	
	sValue	= oObj.value;
	sValue  = sValue.toString().replace(/\D/g,"");
	fldLen  = sValue.length;
	mskLen  = sMask.length;
	i 		= 0;
	nCount 	= 0;
	sCod 	= "";
	mskLen 	= fldLen;
	
	while (i <= mskLen && mskLen > 0) { 
		bolMask = ((sMask.charAt(i) == "-") || (sMask.charAt(i) == ":") || (sMask.charAt(i) == ".") || (sMask.charAt(i) == "/"))
		bolMask = bolMask || ((sMask.charAt(i) == "(") || (sMask.charAt(i) == ")") || (sMask.charAt(i) == " ") || (sMask.charAt(i) == ","))
		
		if (bolMask) {
			sCod += sMask.charAt(i);
			mskLen++;
		} else {
			sCod += sValue.charAt(nCount);
			nCount++;
		}
		i++;
	}
	if (nTecla != 8 && nTecla != 0) {
		oObj.value = sCod;
		if (sMask.charAt(i-1) == "9") 
			 return ((nTecla > 47) && (nTecla < 58));
		else return true;
	}	
	else return true;
}                         
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �clearMark          � Autor � Alexander Santos       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Limpa mascara da string												  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/    
function clearMark(cString) {
	var er = /[^a-z0-9]/gi;
	return cString = cString.replace(er, "");
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �validaCmp	      � Autor � Alexander Santos       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Valida campo conforme mask											  ���
�������������������������������������������������������������������������������������Ĵ��
���   CEP   -> 99.999-999															  ���
���   CPF   -> 999.999.999-99														  ���
���   CNPJ  -> 99.999.999/9999-99													  ���
���   Data  -> 99/99/9999															  ���
���   Tel   -> (99) 9999-9999												  		  ���
���   Hora  -> 99:99																  ���
���   PIS   -> 999.99999.99-9														  ���
���   MatUsu-> 9999.9999.999999.99-9												  ���
���   onBlur="ValidaCmp(this,cTp,cMsg);" 									  		  ���
���   Uso <input type="textbox"														  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/    
function validaCmp(oObj, cTp, cMsg){
	var  exp = "";			
	var lRet = true;
	//������������������������������������������������������������������������Ŀ
	//� Define layout de validacao											   �
	//��������������������������������������������������������������������������
	switch (cTp) {
		case "data":
				exp = "";
				break    
		case "ano":
				exp = /^((19|20|21)?\d{2})$/
				break    
		case "mes":                        
				exp = /^[0]*[1-9]$|^[0]*1[0-2]$/
				break    
		case "dia":
				exp = /^(0[1-9]|1[0-2])|30\/(0[13-9]|1[0-2])|31$/;			
				break    
		case "hora":
				exp = /^([0-1]\d|2[0-3]):[0-5]\d$/;	
				break
		case "cep":
				exp = /\d{2}\.\d{3}\-\d{3}/;			
				break
		case "cpf":
				exp = "";			
				break
		case "cnpj":
				exp = "";			
				break
		case "pis":
				exp = "";			
				break
		case "email":
				exp = "";			
				break
		case "tel":
				exp = /\(\d{2}\)\ \d{4,5}\-\d{3,4}/;					  
				break
		case "matusu":
				exp = "";			
				break
	}
	//������������������������������������������������������������������������Ŀ
	//� Valida o campo														   �
	//��������������������������������������������������������������������������
	if ( isObject(oObj) ) {
	
	if ( !isEmpty(exp) ) {
		if(!isEmpty(oObj.value) && !exp.test(oObj.value)) {
			//Foi necess�rio usar desta forma pois o FIREFOX tem um BUG que n�o suporta .focus()
			globalvar = oObj;
			setTimeout("globalvar.focus()",250);
			alert(cMsg);			
			lRet = false;
		}                
		return lRet;           
		
	} else if (cTp=='data') {
		lRet = validarData(oObj,cMsg);
		
	} else if (cTp=='cpf') {
		lRet = validarCPF(oObj,cMsg);
		
	} else if (cTp=='cnpj') {
		lRet = validarCNPJ(oObj,cMsg);	
		
	} else if (cTp=='matusu') {
		lRet = validarMod11(oObj,cMsg);
		
	} else if (cTp=='pis')	{
		lRet = validarPIS(oObj,cMsg);
		
    } else if (cTp=='email') {
    	lRet = validarEMAIL(oObj,cMsg);
	    }

	 else
	 	lRet = false;   
    }
return lRet;		
}                                      

function validarData(oObj,cMsg) {  
    var lRet  = true;  
    var regex = new RegExp("^([0-9]{2})/([0-9]{2})/([0-9]{4})$");  
    
    if ( !isEmpty(oObj.value) ) {
    
	    var matches = regex.exec(oObj.value);  
	    lRet = (matches != null);
	    
	    if (lRet) {  
	        var day 	= parseInt(matches[1], 10);  
	        var month 	= parseInt(matches[2], 10) - 1;  
	        var year 	= parseInt(matches[3], 10);  
	        var date 	= new Date(year, month, day, 0, 0, 0, 0);  
	        lRet 		= date.getFullYear() == year && date.getMonth() == month && date.getDate() == day;  
	    }

	    if(!lRet) {
			//Foi necess�rio usar desta forma pois o FIREFOX tem um BUG que n�o suporta .focus()
			globalvar = oObj;
			setTimeout("globalvar.focus()",250);
	        alert(cMsg);
	    }
	    return lRet;  
	}    
} 
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �validarCPF		  � Autor � Alexander Santos       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Valida CPF															  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/    
function validarCPF(oObj,cMsg){
    var cpf  = oObj.value;	
    var lRet = true;
    
    if ( !isEmpty(cpf) ) {
    
        exp = /\.|\-/g	
        cpf = cpf.toString().replace( exp, "" ); 	
        var digitoDigitado = eval(cpf.charAt(9)+cpf.charAt(10));    
        var soma1=0, soma2=0;	
        var vlr =11;		
        
        for(var i=0; i<9; i++){
                soma1+=eval(cpf.charAt(i)*(vlr-1));
                soma2+=eval(cpf.charAt(i)*vlr);
                vlr--;    
        }
        
        soma1 = (((soma1*10)%11)==10 ? 0:((soma1*10)%11));
        soma2 = ((soma2+(2*soma1))%11);
        
        if (soma2 < 2)
        {
        	soma2 = 0;
        }
        else
        {
        	soma2 = 11 - soma2;
        }
        
        var digitoGerado=(soma1*10)+soma2;
        
	    if(digitoGerado != digitoDigitado) {
			//Foi necess�rio usar desta forma pois o FIREFOX tem um BUG que n�o suporta .focus()
			globalvar = oObj;
			setTimeout("globalvar.focus()",250);
	        alert(cMsg);
	        lRet = false;
	    }
	}                   
	return lRet;
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �validarCNPJ		  � Autor � Alexander Santos       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Valida CNPJ															  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/    
function validarCNPJ(ObjCnpj,cMsg){
	var cnpj = ObjCnpj.value;
	var lRet = true;

	if ( !isEmpty(cnpj) ) {
	
	    var valida = new Array(6,5,4,3,2,9,8,7,6,5,4,3,2);
	    var dig1= new Number;
	    var dig2= new Number;
	    exp = /\.|\-|\//g	
	    cnpj = cnpj.toString().replace( exp, "" );
 	    var digito = new Number(eval(cnpj.charAt(12)+cnpj.charAt(13)));
 	    
	    for(var i=0; i<valida.length; i++){
		    dig1 += (i>0? (cnpj.charAt(i-1)*valida[i]):0);
		    dig2 += cnpj.charAt(i)*valida[i];
	    }
	    
	    dig1 = (((dig1%11)<2)? 0:(11-(dig1%11)));
	    dig2 = (((dig2%11)<2)? 0:(11-(dig2%11)));
	    
	    if(((dig1*10)+dig2) != digito) {
			//Foi necess�rio usar desta forma pois o FIREFOX tem um BUG que n�o suporta .focus()
	        globalvar = ObjCnpj;
			setTimeout("globalvar.focus()",250);
	        alert(cMsg);		
	        lRet = false;
	    }
	}    
	return lRet;
}                   
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �validarMod11    � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Funcao modulo11														  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function validarMod11(oObjMAT,cMsg,nMultIni,nMultFim) {
	var i 		= 0; 
	var nModulo = 0; 
	var cChar	= '';
	var nMult	= 0; 
	var cStr	= oObjMAT.value;
	var lRet	= true;
	
    if ( !isEmpty(cStr) ) {
    
	    exp = /\.|\-/g;	
	    cStr = cStr.toString().replace( exp, "" ); 	
		
		nMultIni = ( !nMultIni ) ? 2 : nMultIni;
		nMultFim = ( !nMultFim ) ? 9 : nMultFim;
		
		nMult = nMultIni;
		cDig  = trim(cStr).substr(16,1);
		cStr  = trim(cStr).substr(0,16);
		
		for (var i=cStr.length; i>0; i--) {
			cChar = cStr.substr((i-1),1);
			if ( isNaN(cChar) ) {
				alert("Somente Numeros");
				return false;
			}
			nModulo += parseInt(cChar)*nMult;
			nMult = (nMult==nMultFim) ? 2 : nMult+1;
		}
		
		nRest = nModulo % 11;
		nRest = (nRest==0 || nRest==1) ? 0 : 11-nRest;
		
		if (cDig != nRest) {
			//Foi necess�rio usar desta forma pois o FIREFOX tem um BUG que n�o suporta .focus()
	        globalvar = oObjMAT;
			setTimeout("globalvar.focus()",250);
			alert(cMsg);
			lRet = false;
		}
	}	
	return lRet;
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �validarPIS	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Validacao do PIS													  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function validarPIS(oObjPIS,cMsg) {
	var ftap	 = "3298765432";
	var nTotal	 = 0;
	var nResto	 = 0;
	var strResto = "";
	var cNumPIS  = oObjPIS.value;	
	var lRet 	 = true;

    exp = /\.|\-/g;	
    cNumPIS = cNumPIS.toString().replace( exp, "" ); 	
			
	if ( !isEmpty(cNumPIS) ) 	{
	
		for(i=0;i<=9;i++) {
			resultado = ( cNumPIS.slice(i,i+1) ) * ( ftap.slice(i,i+1) );
			nTotal	  = nTotal+resultado;
		}
			
		nResto = (nTotal % 11)
			
		if (nResto != 0) 	{
			nResto = 11-nResto;
		}
			
		if (nResto==10 || nResto==11) {
			strResto = nResto+"";
			nResto 	 = strResto.slice(1,2);
		}
			
		if (nResto != ( cNumPIS.slice(10,11) ) ) {
	        //Foi necess�rio usar desta forma pois o FIREFOX tem um BUG que n�o suporta .focus()
	        globalvar = oObjPIS;
			setTimeout("globalvar.focus()",250);
	        alert(cMsg);
	        lRet = false;
		}             
	}
	return lRet;      
}        
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �validarEMAIL	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Validacao Email												  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function validarEMAIL(oObjEMAIL,cMsg) {  
	var cEmail = new String(oObjEMAIL.value);  
	var lRet   = true;
	var cValid = "{}()<>[]|\/&*$%?!^~`',;:=#";
    var aValid = cValid.split("");
	//�������������������������������������������������������������������������
	//� Somente quando o e-mail for informado
	//�������������������������������������������������������������������������
    if ( !isEmpty(oObjEMAIL.value) ) {
		//�������������������������������������������������������������������������
		//� Verifica se tem algum dos caracteres
		//�������������������������������������������������������������������������
		for (var i=0;i<aValid.length;i++) {    
			if ( cEmail.indexOf(aValid[i]) >= 0 ) {
				lRet = false;   
				break;                            
			}	
		}
		//�������������������������������������������������������������������������
		//� Verifica se esta faltando algum dos caracteres
		//�������������������������������������������������������������������������
		if ( (cEmail.indexOf("@") < 0) || (cEmail.indexOf("@") != cEmail.lastIndexOf("@")) )  
			lRet = false;  
		
		if (cEmail.lastIndexOf(".") < cEmail.indexOf("@"))  
			lRet = false;  
	
		if ( !lRet ) {
	        //Foi necess�rio usar desta forma pois o FIREFOX tem um BUG que n�o suporta .focus()
	        globalvar = oObjEMAIL;
			setTimeout("globalvar.focus()",250);
	        alert(cMsg);
		}                
    }
	return lRet;  
} 
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �MEObj			  � Autor � Alexander Santos       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Esconde um objeto													  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/    
function MEObj(obj,lforca,cAcao) { 
	var el 	  = getObjectID(obj); 
	var im 	  = getObjectID('I'+obj);
	var cAcao = ( !cAcao ) ? '-' : cAcao;

	if (im.src.indexOf("block.gif") == -1) {
	   if (!lforca) {
			if ( el.style.display != 'none' ) { 
				el.style.display = 'none'; 
				im.src = cRaiz + 'mais.bmp';
			} 
			else { 
				el.style.display = ''; 
				im.src = cRaiz + 'menos.bmp';
			} 
	   }else{
	        if(cAcao=='+') {
				el.style.display = 'none'; 
				im.src = cRaiz + 'mais.bmp';
			}else{	
				el.style.display = ''; 
				im.src = cRaiz + 'menos.bmp';
			}
	   }		
	}	
}  
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Desabilita Teclas  � Autor � Alexander Santos       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Desabilita tecla de f5												  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/    
var badKeys 			= new Object();
badKeys.single 			= new Object();
badKeys.single['8'] 	= 'Backspace';
badKeys.single['13']  	= 'Enter';
badKeys.single['116'] 	= 'F5 (Refresh)';
badKeys.single['122'] 	= 'F11 (Full Screen)';
badKeys.alt 			= new Object();
badKeys.alt['37'] 		= 'Alt+Left Cursor';
badKeys.alt['39'] 		= 'Alt+Right Cursor';
badKeys.ctrl 			= new Object();
badKeys.ctrl['78'] 		= 'Ctrl+N';
badKeys.ctrl['79'] 		= 'Ctrl+O';
//������������������������������������������������������������������������Ŀ
//� funcao para tratamento												   �
//��������������������������������������������������������������������������
function checkKeyCode(type, code) {
	if (badKeys[type][code]) {
		return true;
	} else {
		return false;
	}
}
function checkTecla(e) {
    var tecla;
    
    if (window.event) {
        tecla = window.event.keyCode;
    } else if (e) {
        tecla = e.which;
	}
	
	var altKey  	= e.altKey;
	var ctrlKey 	= e.ctrlKey;
	var badKeyType = "single";
	
	if (ctrlKey) {
		badKeyType = "ctrl";
	} else if (altKey) {
		badKeyType = "alt";
	}
	
	if (BrowserId.browser == 'IE') {
	    if (checkKeyCode(badKeyType, tecla)) {
	        window.event.returnValue = false;
	        window.event.keyCode = 0;
	        window.status = "Tecla desabilitada";
	    }
	} else {
		if (checkKeyCode(badKeyType, tecla)) {
	        if (e.preventDefault) {
	            e.preventDefault();
	            e.stopPropagation();
	        }
		}
	}   
}

function BloKeyEvent() {
    document.onkeydown = checkTecla;
}

function DesKeyEvent() {
    document.onkeydown = "";
}            
//��������������������������������������������������������������������������
//� contador de caracteres
//��������������������������������������������������������������������������
function textCounter(field,maxlimit,html){
	if(field.value.length > maxlimit){
		field.value = field.value.substring(0,maxlimit);
	} else {
		getObjectID(html).innerHTML = maxlimit - field.value.length;
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Modal			  � Autor � Roberto Vanderlei      � Data � 15.05.2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Mostra div modal com backgroud transparente - Pacote				  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/    


function jEnvia(){

	var varItens = document.getElementsByName("pacoteModal");
	var cPacote = "";
	var cVazio = false; 

	for( i = ((varItens.length) / 2);i < varItens.length;i++){

		if(varItens[i].value != '0'){
			if ( i > 0 ){
				cPacote += "|" + varItens[i].value;	
			}else{	
				cPacote = varItens[i].value;
			}
		}else{
			cVazio = true;
		}
	}

	cPacote += "||";

	if(cVazio){
		alert("� necess�rio escolher um pacote correspondente para cada item.");
		return false;
	}else{
		alert("Os pacotes selecionados possuem procedimentos relacionados, os procedimentos ser�o carregados e devem compor a guia.");
		callBackLib(cPacote);
	}
}

function CorFundo(posicao){
	
	if(posicao % 2 != 0){
		return "#FFFFFF";
	}else{
		return "#EDEDED";
	}
	
	//#TRANSLATE __BGCOLOR(<nI>) => Iif( MOD(<nI>,2) == 0 , "FFFFFF", "EDEDED")
}

/*Roberto - Chama Div Reponsiva para exibi��o dos pacotes.*/
function ShowModalPacote(aLinhas) {
	
	var nAltura	 = 1000;
	var aPacotes;
	var aCabecalho = Array();//{"C�digo", "Descri��o", "Pacote"};
	var cCodPro;
	var cDesPro;
	var cClassName = "TextoAut";                                                                
	
	var DivCont = getObjectID("ModalContainer");
	
	aCabecalho.push("C�digo");
	aCabecalho.push("Descri��o");
	aCabecalho.push("Pacote");
	
	if ( !isObject('ModalPage') ) 
	   alert("Estrutura para exibir a sele��o de pacotes n�o esta definida corretamente.");
	else{
		
		  
  /* A metade de sua largura. */
		var nHei = ((document.body.scrollHeight)/3) - 40;
		
		
		//nHei = 200; // 1 linha
		//nHei = 250;
		
		
		
		if((200 + (aLinhas.length * 50)) < nHei)
			nHei = (200 + ((aLinhas.length - 1) * 25));
		
		if(document.getElementById('exampleModal') == null){
		alert('Existem procedimentos que est�o vinculados a um ou mais pacotes, selecione o pacote correspondente para cada procedimento.');
		cTableRes = '<div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">';
		cTableRes += 	"<div class='col-xs-12 col-sm-6 col-md-6 col-lg-4' style='overflow-x:auto; width:98%; margin-left:0px;'>";
		cTableRes +=    	"<div id='BrwGrdAtend' class='dataTable_wrapper'>";
		//cTableRes +=        '<div class="modal-header">';
        //cTableRes +=  			'<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>';
        //cTableRes += 			'<h3 style="color:blue" class="modal-title page-header" id="gridSystemModalLabel">&nbsp;&nbsp;&raquo;Vincular Procedimento ao Pacote</h3>';
        //cTableRes += 		'</div>';
	
	
		cTableRes +=			'<table id="TabDet" class="table table-striped table-bordered table-hover dt-responsive dataTable no-footer" cellspacing="0" cellpadding="0" style="width: 100%;" role="grid">'
		
		cTableRes +=				'<thead class="cabacalho">';
		cTableRes +=					'<tr role="row">';
		cTableRes +=						"<th colspan='3'>Vincular Procedimento ao Pacote</th>";
		cTableRes +=					'</tr>';
		cTableRes +=				'</thead>';
		
		cTableRes +=				'<thead class="cabacalho">';
		cTableRes +=					'<tr role="row">';
		cTableRes +=						"<th>C�digo</th>";
		cTableRes +=						"<th>Descri��o</th>";
		cTableRes +=						"<th>Pacote</th>"
		cTableRes +=					'</tr>';
		cTableRes +=				'</thead>';
	

		
		cTableRes +=				'<tbody class="conteudo">';
		
		for (var i=1;i<aLinhas.length;i++) {
			cTableRes +=			'<tr>';
			
			aPacotes = aLinhas[i].split("~");
			
			cCodPro = aLinhas[i].split("|")[0];
			cDesPro = aLinhas[i].split("|")[1];
			
			for(var j=0; j<aCabecalho.length; j++){
				
				if(j == 0)
					cTableRes +=  '<td width="10%" bgcolor="'+ CorFundo(i) + '" class="TextoLinGrid">' + cCodPro + 	'</td>';
				
				if(j == 1)
					cTableRes +=  '<td width="30%" bgcolor="'+ CorFundo(i) + '" class="TextoLinGrid">' + cDesPro + '</td>';
								
				if((j == 2) && (i > 0)){
					cTableRes += 		'<td width="40%" BGCOLOR="'+CorFundo(i)+'">';
					cTableRes += 			'<select name="pacoteModal" id="pacoteModal" style="width:100%;background:'+CorFundo(i) + '" bgcolor="'+ CorFundo(i) + '" class="TextoLinGrid">';
					
					for(var p=0; p < aPacotes.length; p++){
						aItensPacotes = aPacotes[p].split("|");
						cTableRes 	 += '<option value="' + aItensPacotes[0] + ';' + aItensPacotes[2] + ';;' + '">' + aItensPacotes[2]  + " - " + aItensPacotes[3] + '</option>';
					}
					
					cTableRes += 			'</select>';
					cTableRes +=		'</td>';
					
				}
			}
			
			cTableRes += 			'</tr>';				
	   }
	   
		cTableRes +=				'</tbody>';
		cTableRes +=			'</table>';
		
		cTableRes += '<div class="modal-footer">';
		cTableRes += 	'<button type="button" class="btn btn-primary"  onClick="jEnvia();"  data-dismiss="modal">Finalizar</button>';
        cTableRes += 	'<button type="button" class="btn btn-default" onClick= "window.location.reload();" data-dismiss="modal">Cancelar</button>';
        cTableRes += '</div>';
		
		
		cTableRes += 		'</div>';
		cTableRes +=	'</div>';
		cTableRes +='</div>';
		
		
		DivCont.innerHTML = cTableRes;
		
		}
		
		$('#exampleModal').modal({backdrop: 'static'})  
		$("#exampleModal").modal("show");
		

	   DivCont.innerHTML = cTableRes;
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Modal			  � Autor � Alexander Santos       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Mostra div modal com backgroud transparente							  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/    
function ShowModal(cTitulo,cTexto,lS,lOld,lAlt,cPlusFunc,cCloseFunc) { 
	var lAut 	 = (cTitulo == "Autorizada" || cTitulo == "Guia gravada com sucesso.") ? true : false;
	var lSucesso = ( !lS ) ? false : lS;
	var nAltura	 = 1000;
	var cCores = "";
	var lAlerta = ( !lAlt ) ? false : lAlt; 
	
	if ( !isObject('ModalPage') ) 
	   alert("Estrutura para exibir o resultado nao esta definida corretamente");
    else { 
    	if (lOld){
    		if ( !isEmpty(cTitulo) ) {
		        var DivCont = getObjectID("ModalContainer");
    	        var cResCri = "";
				var cResTit = "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+cTitulo+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
				//������������������������������������������������������������������������Ŀ
				//� se autorizou ou nao													   �
				//��������������������������������������������������������������������������
				if (lAut || lSucesso) { 
				    cClassName = "TextoAut";                                                                                                         
				    cResCri    = '<div id="ResultFinalAut" align="center">'+cTexto+'</div><p align="center"><input name="bFechar" type="button" class="Botoes" onclick="HideModal()" value="Fecha"/></p>';
				} else {	
				    cClassName = "TextoNeg";
				    cResCri    = '<div id="ResultFinal">'+cTexto+'</div><p align="center"><input name="bFechar" type="button" class="Botoes" onclick="HideModal()" value="Fecha"/></p>';
				}
				//������������������������������������������������������������������������Ŀ
				//� Monta o resultado na tabela											   �
				//��������������������������������������������������������������������������
            	cTableRes = '<table id="ResultFinalTab"><tr><td id="TabTitulo" align="center" class="'+cClassName+'"+>'+cResTit+'</td></tr>';
				if ( !isEmpty(cResCri) ) {
					cTableRes += '<tr><td id="TabResult">'+cResCri+'</td></tr>';
					}	
		 		cTableRes += '</table>';
				//������������������������������������������������������������������������Ŀ
				//� Monta a div com a tabela											   �
				//��������������������������������������������������������������������������
				DivCont.innerHTML = cTableRes;

			}	
			//������������������������������������������������������������������������Ŀ
			//� Mostra a div														   �
			//��������������������������������������������������������������������������
			var oDiv 			= getObjectID("ModalPage");
			var nAltura			= (document.body.scrollHeight > nAltura) ? document.body.scrollHeight : nAltura;			
			oDiv.style.height	= nAltura + 2 + 'px';			
			oDiv.style.width 	= document.body.scrollWidth  + 'px';
			oDiv.style.display 	= "block";
			
			document.body.style.overflow = 'hidden';
		
			showScroll();
				
		}else
    	   
	        if ( !isEmpty(cTitulo) ) {
				//������������������������������������������������������������������������Ŀ
				//� se autorizou ou nao													   �
				//��������������������������������������������������������������������������
				
	        	if (lAlerta) { 
	        		cCores = "white~#FABE3E"
	        	} else if (lAut || lSucesso) {                                                                                                      
				    cCores = "white~#009652"
				} else {	
				    cCores = "white~#960000";
				}
				
				modalBS(cTitulo, "<p>" + cTexto + "</p>", (typeof cCloseFunc!= "undefined" && cCloseFunc!=""? cCloseFunc: "@Fechar~closeModalBS();") + (typeof cPlusFunc != "undefined" ? cPlusFunc : ""), cCores, "large");	
			}else{
				//������������������������������������������������������������������������Ŀ
				//� Mostra a div														   �
				//��������������������������������������������������������������������������
				var oDiv 			= getObjectID("ModalPage");
				var nAltura			= (document.body.scrollHeight > nAltura) ? document.body.scrollHeight : nAltura;			
				oDiv.style.height	= nAltura + 2 + 'px';			
				oDiv.style.width 	= document.body.scrollWidth  + 'px';
				oDiv.style.display 	= "block";
				
				document.body.style.overflow = 'hidden';
			
				showScroll();	
			}
		}	
}

function HideModal() {
	document.body.style.overflow = '';
	if ( isObject('ModalPage') ) {
       setTC(getObjectID("ModalContainer"),"");
       getObjectID("ModalPage").style.display = "none";
    }   
}

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �RepShowModal 	  � Autor � Roger Cangianeli       � Data � 13/02/2017���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Mostra mais de uma mensagem para a mesma modal           			  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/    
function RepShowModal(cTitulo,cTexto) {
    document.getElementById("modal-title").innerHTML = cTitulo;
    document.getElementById("modal-body").innerHTML = '<p>' + cTexto + '</p>';
    document.getElementById("modal-footer").innerHTML = "<button type='button' class='btn btn-default' onclick='closeModalBS();'>Fechar</button>";
}

function showScrollPacote() {
	var nTop = 2;
	var bt 	 = document.body.scrollTop;
	var bl 	 = document.body.scrollLeft;
	var et 	 = document.documentElement ? document.documentElement.scrollTop : null;
	var el 	 = document.documentElement ? document.documentElement.scrollLeft: null;

	if ( getObjectID("DivProc").style.display != 'none' ) {
		var oDiv = getObjectID("DivProc");
	} else {	
		var oDiv = getObjectID("ModalContainer");
	}	
	oDiv.style.top 	= (bt || et) + nTop  + 'px';
	
	// Ajuste para a correta exibi��o da DIV em resolu��o 800x600
	if (screen.width==800||screen.height==600){
	    oDiv.style.top = (bt || et) + (nTop - 50) + 'px';
	    oDiv.style.width = '550px';
	    oDiv.style.left = (el + 30) + 'px';       
	}
}
function showScroll() {
	var nTop = 200;
	var bt 	 = document.body.scrollTop;
	var bl 	 = document.body.scrollLeft;
	var et 	 = document.documentElement ? document.documentElement.scrollTop : null;
	var el 	 = document.documentElement ? document.documentElement.scrollLeft: null;

	if ( getObjectID("DivProc").style.display != 'none' ) {
		var oDiv = getObjectID("DivProc");
	} else {	
		var oDiv = getObjectID("ModalContainer");
	}	
	oDiv.style.top 	= (bt || et) + nTop  + 'px';
	
	// Ajuste para a correta exibi��o da DIV em resolu��o 800x600
	if (screen.width==800||screen.height==600){
	    oDiv.style.top = (bt || et) + (nTop - 50) + 'px';
	    oDiv.style.width = '550px';
	    oDiv.style.left = (el + 30) + 'px';       
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Move a Div no Mouse� Autor � Alexander Santos       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Leva a div divProc junto com o mouse								  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                               
var ym=0;
var xm=0;            
//������������������������������������������������������������������������Ŀ
//� div de processamento
//��������������������������������������������������������������������������
document.write('<div id="DivProc" class="DivProc" style="display:none">Aguarde&nbsp;processando...<br><i class="fa fa-spinner fa-spin fa-2x"></i></div>');

//������������������������������������������������������������������������Ŀ
//� movimento do mouse
//��������������������������������������������������������������������������
function mouseNS(e){
	ym = e.pageY-window.pageYOffset;
	xm = e.pageX;
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �MenuTab    � Autor � Alexander Santos			   � Data � 05.04.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Menu em tab abas													  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
MenuTab={
	tabClass:'MenuTab', 			// class to trigger tabbing
	listClass:'MenuTabs', 			// class of the menus
	activeClass:'active', 			// class of current link
	contentElements:'div', 			// elements to loop through
	backToLinks:/#top/, 			// pattern to check "back to top" links
	printID:'MenuTabprintview', 	// id of the print all link
	showAllLinkText:'Mostra todos', // text for the print all link
	prevNextIndicator:'doprevnext', // class to trigger prev and next links
	prevNextClass:'prevnext', 		// class of the prev and next list
	prevLabel:'previous', 			// HTML content of the prev link
	nextLabel:'next', 				// HTML content of the next link
	prevClass:'prev', 				// class for the prev link
	nextClass:'next', 				// class for the next link
	init:function(){
		var temp;
		if(!document.getElementById || !document.createTextNode){return;}
		
		var tempelm = document.getElementsByTagName('div');		
		
		for(var i=0;i<tempelm.length;i++){
		
			if(!MenuTab.cssjs('check',tempelm[i],MenuTab.tabClass)){continue;}
			
			MenuTab.initTabMenu(tempelm[i]);
			MenuTab.removeBackLinks(tempelm[i]);
			
			if(MenuTab.cssjs('check',tempelm[i],MenuTab.prevNextIndicator)){
				MenuTab.addPrevNext(tempelm[i]);
			}
			MenuTab.checkURL();
		}
		if(getObjectID(MenuTab.printID) && !getObjectID(MenuTab.printID).getElementsByTagName('a')[0]){
		
			var newlink=document.createElement('a');
			newlink.setAttribute('href','#');
			MenuTab.addEvent(newlink,'click',MenuTab.showAll,false);
			newlink.onclick=function(){return false;}
			newlink.appendChild(document.createTextNode(MenuTab.showAllLinkText));
			getObjectID(MenuTab.printID).appendChild(newlink);
		}
	},
	checkURL:function(){
		var id;
		var loc = window.location.toString();
		
		loc = /#/.test(loc)?loc.match(/#(\w.+)/)[1]:'';
		
		if( isEmpty(loc) ){return;}
		
		var elm=getObjectID(loc);
		
		if(!elm){return;}
		
		var parentMenu=elm.parentNode.parentNode.parentNode;
		
		parentMenu.currentSection=loc;
		parentMenu.getElementsByTagName(MenuTab.contentElements)[0].style.display='none';
		MenuTab.cssjs('remove',parentMenu.getElementsByTagName('a')[0].parentNode,MenuTab.activeClass);
		
		var links=parentMenu.getElementsByTagName('a');
		
		for(var i=0;i<links.length;i++){
		
			if(!links[i].getAttribute('href')){continue;}
		
			if(!/#/.test(links[i].getAttribute('href').toString())){continue;}
		
			id=links[i].href.match(/#(\w.+)/)[1];
		
			if(id==loc){
				var cur=links[i].parentNode.parentNode;
				MenuTab.cssjs('add',links[i].parentNode,MenuTab.activeClass);
				break;
			}
		}
		
		MenuTab.changeTab(elm,1);
		
		elm.focus();
		
		cur.currentLink=links[i];
		cur.currentSection=loc;
	},
	showAll:function(e){
		
		getObjectID(MenuTab.printID).parentNode.removeChild(getObjectID(MenuTab.printID));
		
		var tempelm=document.getElementsByTagName('div');		
		
		for(var i=0;i<tempelm.length;i++){
		
			if(!MenuTab.cssjs('check',tempelm[i],MenuTab.tabClass)){continue;}
		
			var sec=tempelm[i].getElementsByTagName(MenuTab.contentElements);
		
			for(var j=0;j<sec.length;j++){
				sec[j].style.display='block';
			}
		}
		var tempelm=document.getElementsByTagName('ul');		
		
		for(var i=0;i<tempelm.length;i++){
			if(!MenuTab.cssjs('check',tempelm[i],MenuTab.prevNextClass)){continue;}
			tempelm[i].parentNode.removeChild(tempelm[i]);
			i--;
		}
		MenuTab.cancelClick(e);
	},
	addPrevNext:function(menu){
		var temp;
		var sections=menu.getElementsByTagName(MenuTab.contentElements);
		
		for(var i=0;i<sections.length;i++){
		
			temp=MenuTab.createPrevNext();
		
			if(i==0){
				temp.removeChild(temp.getElementsByTagName('li')[0]);
			}
			if(i==sections.length-1){
				temp.removeChild(temp.getElementsByTagName('li')[1]);
			}
			temp.i=i;
			temp.menu=menu;
			sections[i].appendChild(temp);
		}
	},
	removeBackLinks:function(menu){
		
		var links=menu.getElementsByTagName('a');
		
		for(var i=0;i<links.length;i++){
			if(!MenuTab.backToLinks.test(links[i].href)){continue;}
			links[i].parentNode.removeChild(links[i]);
			i--;
		}
	},
	initTabMenu:function(menu){
		var id;
		var lists=menu.getElementsByTagName('ul');
		
		for(var i=0;i<lists.length;i++){
		
			if(MenuTab.cssjs('check',lists[i],MenuTab.listClass)){
				var thismenu=lists[i];
				break;
			}
		}
		if(!thismenu){return;}
		
		thismenu.currentSection='';
		thismenu.currentLink='';
		
		var links=thismenu.getElementsByTagName('a');
		
		for(var i=0;i<links.length;i++){
		
			if(!/#/.test(links[i].getAttribute('href').toString())){continue;}
		
			id=links[i].href.match(/#(\w.+)/)[1];
		
			if(getObjectID(id)){
				MenuTab.addEvent(links[i],'click',MenuTab.showTab,false);
				links[i].onclick=function(){return false;}
				MenuTab.changeTab(getObjectID(id),0);
			}
		}
		id=links[0].href.match(/#(\w.+)/)[1];
		
		if(getObjectID(id)){
			MenuTab.changeTab(getObjectID(id),1);
			thismenu.currentSection=id;
			thismenu.currentLink=links[0];
			MenuTab.cssjs('add',links[0].parentNode,MenuTab.activeClass);
		}
	},
	createPrevNext:function(){
		var temp=document.createElement('ul');
		
		temp.className=MenuTab.prevNextClass;
		temp.appendChild(document.createElement('li'));
		temp.getElementsByTagName('li')[0].appendChild(document.createElement('a'));
		temp.getElementsByTagName('a')[0].setAttribute('href','#');
		temp.getElementsByTagName('a')[0].innerHTML=MenuTab.prevLabel;
		temp.getElementsByTagName('li')[0].className=MenuTab.prevClass;
		temp.appendChild(document.createElement('li'));
		temp.getElementsByTagName('li')[1].appendChild(document.createElement('a'));
		temp.getElementsByTagName('a')[1].setAttribute('href','#');
		temp.getElementsByTagName('a')[1].innerHTML=MenuTab.nextLabel;
		temp.getElementsByTagName('li')[1].className=MenuTab.nextClass;
		MenuTab.addEvent(temp.getElementsByTagName('a')[0],'click',MenuTab.navTabs,false);
		MenuTab.addEvent(temp.getElementsByTagName('a')[1],'click',MenuTab.navTabs,false);
		temp.getElementsByTagName('a')[0].onclick=function(){return false;}
		temp.getElementsByTagName('a')[1].onclick=function(){return false;}
		return temp;
	},
	navTabs:function(e){
		
		var li=MenuTab.getTarget(e);
		var menu=li.parentNode.parentNode.menu;
		var count=li.parentNode.parentNode.i;
		var section=menu.getElementsByTagName(MenuTab.contentElements);
		var links=menu.getElementsByTagName('a');
		var othercount=(li.parentNode.className==MenuTab.prevClass)?count-1:count+1;

		section[count].style.display='none';
		MenuTab.cssjs('remove',links[count].parentNode,MenuTab.activeClass);
		section[othercount].style.display='block';
		MenuTab.cssjs('add',links[othercount].parentNode,MenuTab.activeClass);

		var parent=links[count].parentNode.parentNode;
		parent.currentLink=links[othercount];
		parent.currentSection=links[othercount].href.match(/#(\w.+)/)[1];
		MenuTab.cancelClick(e);
	},
	changeTab:function(elm,state){
		do{
			elm=elm.parentNode;
		} while(elm.nodeName.toLowerCase() != MenuTab.contentElements)
		elm.style.display=state==0?'none':'block';
	},
	showTab:function(e){
		var o=MenuTab.getTarget(e);
		if( !isEmpty(o.parentNode.parentNode.currentSection) ){
			MenuTab.changeTab(getObjectID(o.parentNode.parentNode.currentSection),0);
			MenuTab.cssjs('remove',o.parentNode.parentNode.currentLink.parentNode,MenuTab.activeClass);
		}
		var id=o.href.match(/#(\w.+)/)[1];
		o.parentNode.parentNode.currentSection=id;
		o.parentNode.parentNode.currentLink=o;
		MenuTab.cssjs('add',o.parentNode,MenuTab.activeClass);
		MenuTab.changeTab(getObjectID(id),1);
		getObjectID(id).focus();
		MenuTab.cancelClick(e);
	},
	getTarget:function(e){
		var target = window.event ? window.event.srcElement : e ? e.target : null;
		if (!target){return false;}
		if (target.nodeName.toLowerCase() != 'a'){target = target.parentNode;}
		return target;
	},
	cancelClick:function(e){
		if (window.event){
			window.event.cancelBubble = true;
			window.event.returnValue = false;
			return;
		}
		if (e){
			e.stopPropagation();
			e.preventDefault();
		}
	},
	addEvent: function(elm, evType, fn, useCapture){
		if (elm.addEventListener) 
		{
			elm.addEventListener(evType, fn, useCapture);
			return true;
		} else if (elm.attachEvent) {
			var r = elm.attachEvent('on' + evType, fn);
			return r;
		} else {
			elm['on' + evType] = fn;
		}
	},
	cssjs:function(a,o,c1,c2){
		switch (a){
			case 'swap':
				o.className=!MenuTab.cssjs('check',o,c1)?o.className.replace(c2,c1):o.className.replace(c1,c2);
			break;
			case 'add':
				if(!MenuTab.cssjs('check',o,c1)){o.className+=o.className?' '+c1:c1;}
			break;
			case 'remove':
				var rep=o.className.match(' '+c1)?' '+c1:c1;
				o.className=o.className.replace(rep,'');
			break;
			case 'check':
				var found=false;
				var temparray=o.className.split(' ');
				for(var i=0;i<temparray.length;i++){
					if(temparray[i]==c1){found=true;}
				}
				return found;
			break;
		}
	}
}
MenuTab.addEvent(window, 'load', MenuTab.init, false);
/*/               
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �IncLinhaTab� Autor � Alexander Santos			   � Data � 05.04.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Funcao para inclusao de uma linha em uma tabela/div generica		  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function IncLinhaTab(cTable,ElemCol,ElemBut,cChave,cCampoDefault,cSt,lChk,nSeqMov) {
    var i,y;
    var aMatCol		 = ElemCol.split("|");
    var aMatCamDef	 = cCampoDefault.split("|");
	var oTable		 = getObjectID(cTable);
	var nQtdLinTab 	 = oTable.rows.length;
	var lChk 		 = ( wasDef(typeof lChk) ) ? lChk : true;   
	var nSeqMov		 = ( nSeqMov ) ? nSeqMov : 0;
	var nSeqTab		 = 0;
	//������������������������������������������������������������������������Ŀ
	//� Verifica duplicidade conforme chave informada						   �
	//��������������������������������������������������������������������������
	if (nQtdLinTab != 0 && !isEmpty(cChave) ) {
		nCol 	   = 0;
		cContChave = getObjectID(cChave).value;
		
		for (var i=0; i<aMatCol.length; i++) {
		    var aMatColAux = aMatCol[i].split("$");
			if (aMatColAux[0] == cChave) nCol= i; 
		}
		//������������������������������������������������������������������������Ŀ
		//� Pega a sequencia e verifica duplicidade								   �
		//��������������������������������������������������������������������������
		for (var i=1; i<nQtdLinTab; i++) {                      
			nSeqTab = parseInt(getTC(oTable.rows[i].cells[0]),10);
			if (getTC(oTable.rows[i].cells[nCol+1]).replace(/&nbsp;/g, " ").replace( /\s*$/, "" ) ==	cContChave) {
				alert('J� existe este registro');
				return;
			}
		}
	} else {
		for (var i=1; i<nQtdLinTab; i++) {
	       nSeqTab = parseInt(getTC(oTable.rows[i].cells[0]),10);
		}
	}
	var oLinha = oTable.insertRow(-1);                                         
	//������������������������������������������������������������������������Ŀ
	//� Primeira linha monta o cabecalho									   �
	//��������������������������������������������������������������������������
	if (nQtdLinTab == 0) {
		oTable.className	= "TabDinamica";
		//������������������������������������������������������������������������Ŀ
		//� Contador colunha vazia												   �
		//��������������������������������������������������������������������������
		var oColuna 	  	= oLinha.insertCell(-1);
		oColuna.innerHTML 	= "&nbsp;";
	    oColuna.className 	= "TabCab";
		//������������������������������������������������������������������������Ŀ
		//� CheckBox colunha vazia												   �
		//��������������������������������������������������������������������������
		var oColuna 	  	= oLinha.insertCell(-1);
		oColuna.innerHTML 	= "&nbsp;";
		oColuna.className 	= "TabCab";
		//������������������������������������������������������������������������Ŀ
		//� Colunas do cabecalho												   �
		//��������������������������������������������������������������������������
		for (var i=0; i<aMatCol.length; i++) {
		    var aMatColAux = aMatCol[i].split("$");
			if ( aMatColAux[0] != 'Chk' && isObject(aMatColAux[0])  ) {
				var oColuna = oLinha.insertCell(-1);
				oColuna.className = "TabCab";
				oColuna.innerHTML = getObjectID(aMatColAux[0]).name.replace(/ /g, "&nbsp;").replace(/-/g, "&minus;")+"&nbsp;";
			}
		}
		//������������������������������������������������������������������������Ŀ
		//� Inclui outra linha													   �
		//��������������������������������������������������������������������������
		var nQtdLinTab 	= oTable.rows.length;
		var oLinha		= oTable.insertRow(-1);	
	}
	if (cSt != '1')          
	   oLinha.className = "TextoNegPeq";
	//������������������������������������������������������������������������Ŀ
	//� Insere a funcao para o duplo click e o id da linha					   �
	//��������������������������������������������������������������������������        
	if ( !isEmpty(ElemBut) && lChk == true)
		oLinha.ondblclick = function(){MosLinhaTab(cTable,oLinha.rowIndex,ElemCol,ElemBut);};
		
	oLinha.onmouseover	= function(){inCell(this, '#E8E6E7');};
	oLinha.onmouseout	= function(){outCell(this, '#FFFFFF');};
	//������������������������������������������������������������������������Ŀ
	//� Insere contador														   �
	//��������������������������������������������������������������������������
	var oColuna 		= oLinha.insertCell(-1);
	oColuna.id 			= 'Cont' + nQtdLinTab;
	nSeqTab				= ( (nSeqTab != 0) ? ++nSeqTab : nQtdLinTab )
	oColuna.innerHTML	= ( (nSeqMov != 0) ? nSeqMov : nSeqTab ) + "&nbsp;";
	//������������������������������������������������������������������������Ŀ
	//� Cria Colunas e checkbox											       �
	//��������������������������������������������������������������������������
	for (var i=0; i<aMatCol.length; i++) {
	    var aMatColAux = aMatCol[i].split("$");
		if ( aMatColAux[0] == 'Chk' || isObject(aMatColAux[0]) ) {
			var oColuna = oLinha.insertCell(-1);
			//������������������������������������������������������������������������Ŀ
			//� Cria checkbox											       		   �
			//��������������������������������������������������������������������������
			if (aMatColAux[0] == 'Chk') {
				if (lChk == true) {
					var chkBoxColElem 	= document.createElement('input');
					chkBoxColElem.type 	= 'checkbox';
					chkBoxColElem.id 	= 'chkbox' + cTable + '_' + nQtdLinTab;
					oColuna.appendChild(chkBoxColElem);
				}	
			} else {
			    cCampo = getObjectID(aMatColAux[0]);
			    //������������������������������������������������������������������������Ŀ
				//� Para campos tipo select												   �
				//��������������������������������������������������������������������������
				if (cCampo.type == "select-one") {
				   		cNewVal 		  = MPSelect(cCampo,'VT');                                                       
				   		oColuna.value 	  = cCampo.value;
				   		oColuna.innerHTML = cNewVal.replace(/ /g, "&nbsp;").replace(/-/g, "&minus;")+"&nbsp;";
				} else  oColuna.innerHTML = cCampo.value.replace(/ /g, "&nbsp;").replace(/-/g, "&minus;")+"&nbsp;";
				//������������������������������������������������������������������������Ŀ
				//� Verifica se e para limpar o campo ou atribuir valor default			   �
				//��������������������������������������������������������������������������
				lTroca=true;
				for (var y=0;y<aMatCamDef.length;y++) {
					aMatCamDefAux = aMatCamDef[y].split(";");
				    if ( aMatCamDefAux[0]==aMatColAux[0] ) {
			    		 lTroca = false;                       
				         if (aMatCamDefAux[1] != 'NIL')
				    		cCampo.value = aMatCamDefAux[1];
	    	   		     break;
				    }	
				}	     
				if (lTroca==true) 
					cCampo.value = "";              
		  	}		
		}  	
	}                                                            
}
/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �AltLinhaTab� Autor � Alexander Santos			   � Data � 05.04.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Funcao para alterar de uma linha em uma tabela/div generica	     	  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
function AltLinhaTab(cTable,ElemCol,ElemBut,cSt,cChave,cCampoDefault) {
  var nCol    	 	= 0;
  var nId		 	= 0;
  var oTable  	 	= getObjectID(cTable);
  var aMatCamDef	= cCampoDefault.split("|");
  var aMatCol 	 	= ElemCol.split("|");
  //������������������������������������������������������������������������Ŀ
  //� Pega a posicao da chave na tabela										 �
  //��������������������������������������������������������������������������
  if (cSt == '1' && !isEmpty(cChave) ) {
	  var cContChave = getObjectID(cChave).value;
	  for (var i=0; i<aMatCol.length; i++) {
	    var aMatColAux = aMatCol[i].split("$"); 
		if (aMatColAux[0] == cChave) nCol=i; 
	  }
  }	  
  //������������������������������������������������������������������������Ŀ
  //� Identifica a linha a ser alterada										 �
  //��������������������������������������������������������������������������
  for (var y=0; y < oTable.rows.length; y++) {
	if ( !isEmpty(oTable.rows[y].style.backgroundColor) ) nId=y;
	//������������������������������������������������������������������������Ŀ
	//� Verifica duplicidade conforme chave informada						   �
	//��������������������������������������������������������������������������
	if (nCol > 0 && nId != y && cSt == '1' && !isEmpty(cChave) ) {
		if (getTC(oTable.rows[y].cells[nCol+2]).replace(/&nbsp;/g, " ").replace( /\s*$/, "" ) ==	cContChave) {
			alert('J� existe este registro');
			return;
		}	
	}
  }	
  oTable.rows[nId].style.backgroundColor = "";
  //������������������������������������������������������������������������Ŀ
  //� Se autorizado e foi alterado alguma coisa volta para preto			 �
  //��������������������������������������������������������������������������
  if (cSt == '1')
	 oTable.rows[nId].style.color = "#000000";
  //������������������������������������������������������������������������Ŀ
  //� Disable e Enabled nos botoes											 �
  //��������������������������������������������������������������������������
  var aMatBut = ElemBut.split("|");
  for (var y=0; y < aMatBut.length; y++) {
  	if (y==1)
		 setDisable(aMatBut[y],true);
	else setDisable(aMatBut[y],false);
  }	
  //������������������������������������������������������������������������Ŀ
  //� Atribui o valor alterado dos campos ao grids						 	 �
  //��������������������������������������������������������������������������
  for (var y=2; y < oTable.rows[nId].cells.length; y++) {
    var aMatColAux = aMatCol[y-2].split("$");                                 
    
    cCampo = getObjectID(aMatColAux[0]); 
	//������������������������������������������������������������������������Ŀ
	//� Altera o valor na coluna											   �
	//��������������������������������������������������������������������������
    if (cSt == '1') {                                 
        //������������������������������������������������������������������������Ŀ
		//� Para campos tipo select												   �
		//��������������������������������������������������������������������������
		if (cCampo.type == "select-one") {
			 cNewVal = MPSelect(cCampo,"VT"); 
			 oTable.rows[nId].cells[y].value = cCampo.value;
			 oTable.rows[nId].cells[y].innerHTML = cNewVal.replace(/ /g, "&nbsp;").replace(/-/g, "&minus;")+"&nbsp;";
		}	 
		else oTable.rows[nId].cells[y].innerHTML = cCampo.value.replace(/ /g, "&nbsp;").replace(/-/g, "&minus;")+"&nbsp;";
	}	
	//������������������������������������������������������������������������Ŀ
	//� Verifica se e para limpar o campo ou atribuir valor default			   �
	//��������������������������������������������������������������������������
	lTroca=true;
	for (var i=0;i<aMatCamDef.length;i++) {
		aMatCamDefAux = aMatCamDef[i].split(";");
	    if ( aMatCamDefAux[0]==aMatColAux[0] ) {
    		 lTroca = false;                       
	         if (aMatCamDefAux[1] != 'NIL')
	    		cCampo.value = aMatCamDefAux[1];
   		     break;
	    }	
	}	     
	if (lTroca==true) 
		cCampo.value = "";              
  }	                                      
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �DelLinhaTab� Autor � Alexander Santos			   � Data � 05.04.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Funcao para deletar de uma linha em uma tabela/div generica	     	  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function DelLinhaTab(cTable){
	var i, cont, chkbox;
	var oTable	     = getObjectID(cTable);
	var nQtdLinTab 	 = oTable.rows.length;
	var nDel		 = 0   
	var n			 = 1
	//������������������������������������������������������������������������Ŀ
	//� Vai em todas as linhas da tabela									   �
	//��������������������������������������������������������������������������
	for (var i = 1; i < nQtdLinTab; i++) {
		chkbox 	= getObjectID("chkbox" + cTable + '_' + i);
		cont	= getObjectID("Cont" + i);
		//������������������������������������������������������������������������Ŀ
		//� Deleta os marcados e ajusta a numeracao								   �
		//��������������������������������������������������������������������������
		if (chkbox) {
			if (chkbox.checked) {                        
				++nDel;
				oTable.deleteRow(n);
			}
			else {
				chkbox.id  		= "chkbox" + cTable + '_' + n;
				cont.id   		= "Cont" + n;    
				cont.innerHTML	= ( parseInt( getTC(cont) ,10)-nDel) + "&nbsp;";
				++n;
			}
		} else {	
			++n;
		}
	}               
	nQtdLinTab = oTable.rows.length;
	//������������������������������������������������������������������������Ŀ
	//� Deleta o cabecalho apos o ultimo item								   �
	//��������������������������������������������������������������������������
	if (nQtdLinTab == 1) oTable.deleteRow(0);
	oTable.refresh;
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �MosLinhaTab� Autor � Alexander Santos			   � Data � 05.04.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Funcao para mostrar a linha da grid em campos 						  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/       
function MosLinhaTab(cTable,nId,ElemCol,ElemBut) {
  var oTable  = getObjectID(cTable);

  if (oTable.disabled == false || oTable.disabled == undefined) {
	  //������������������������������������������������������������������������Ŀ
	  //� Disable e Enabled nos botoes											 �
	  //��������������������������������������������������������������������������
	  var aMatBut = ElemBut.split("|");
	  for (var y=0; y < aMatBut.length; y++) {
	  	if (y==1)
			 setDisable(aMatBut[y],false);
		else setDisable(aMatBut[y],true);
	  }	
	  //������������������������������������������������������������������������Ŀ
	  //� Desmarca uma possivel linha marcada									 �
	  //��������������������������������������������������������������������������
	  for (var y=0; y < oTable.rows.length; y++) {
		 oTable.rows[y].style.backgroundColor = "";
	  }	
	  //������������������������������������������������������������������������Ŀ
	  //� Marca a nova linha													 �
	  //��������������������������������������������������������������������������
	  oTable.rows[nId].style.backgroundColor = "#C5D8EB";
	  //������������������������������������������������������������������������Ŀ
	  //� Carrega o conteudo da linha do grid nos campos						 �
	  //��������������������������������������������������������������������������
	  var aMatCol = ElemCol.split("|");
	  for (var y=2; y < oTable.rows[nId].cells.length; y++) {
		var aMatColAux = aMatCol[y-1].split("$");
	    if (aMatColAux[0] != "Chk") {
		  	cCampo   = getObjectID(aMatColAux[0]);
			cValCamp = oTable.rows[nId].cells[y].innerHTML.replace(/&nbsp;/g, " ").replace( /\s*$/, "" );
			//������������������������������������������������������������������������Ŀ
			//� Troca o valor do campo pelo "value" do combo						   �
			//��������������������������������������������������������������������������
			if (cCampo.type == "select-one") 
				cValCamp = MPSelect(cCampo,'TV',cValCamp);
			//������������������������������������������������������������������������Ŀ
			//� Atualiza campos														   �
			//��������������������������������������������������������������������������
			cCampo.value = cValCamp; 
		}	
	  }	 
  }                                                            
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �api Ajax	  � Autor � Alexander Santos			   � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � envio de formulario, montar select validacao de campos etc			  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/       
var Ajax = {                   
	//������������������������������������������������������������������������Ŀ
	//� metodo de inicializacao do Ajax										   �
	//��������������������������������������������������������������������������
    init: function() {
        var req;
		if (BrowserId.browser == 'IE') {
			try  {
				//������������������������������������������������������������������������Ŀ
				//� tenta carregar o Ajax no Internet Explorer					      	   � 
				//��������������������������������������������������������������������������
				req = new ActiveXObject("Msxml2.XMLHTTP");
			} catch(e) {
				try {
					//������������������������������������������������������������������������Ŀ
					//� segunda tentativa para o Internet Explorer					      	   � 
					//��������������������������������������������������������������������������
					req = new ActiveXObject("Microsoft.XMLHTTP");
				} catch(ex) {
					req = null;
				}
			}                                         
		} else {
			try {
				//������������������������������������������������������������������������Ŀ
				//� tenta carregar o Ajax no Mozilla / Netscape					      	   � 
				//��������������������������������������������������������������������������
				req = new XMLHttpRequest();
			} catch(exc) {
				req = null;
			}
		}		
        return req;
    },
	//��������������������������������������������������������������������������������������������Ŀ
	//� metodo para abrir requisicao ao servidor e enviar o retorno para uma funcao de callback    � 
	//����������������������������������������������������������������������������������������������
    open: function(pag) {
    
        var ajax = Ajax.init();
        
        if(ajax) {
            var openArgs  = arguments[1];

            if(openArgs && typeof(openArgs) == 'object') {
                var cb 			= ( typeof(openArgs.callback) 	!= 'function') 	? null : openArgs.callback;
                var sendCont 	= ( !wasDef( typeof(openArgs.post) ) ) ? null : openArgs.post;
                var cbArgs 		= ( !wasDef( typeof(openArgs.args) ) ) ? null : openArgs.args;
                var errorHandle = ( typeof(openArgs.error) 		!= 'function') 	? Ajax.defaultError : openArgs.error;
                var lShowProc	= ( !wasDef( typeof(openArgs.showProc) ) ) ? true : openArgs.showProc;
            } else {
                var cb 			= openArgs;
                var sendCont 	= arguments[2] ? arguments[2] : null;
                var cbArgs 		= arguments[3] ? arguments[3] : null;
                var errorHandle = typeof(arguments[4]) == 'function' ? arguments[4] : Ajax.defaultError;
                var lShowProc   = arguments[5] ? arguments[5] : true;
            }                                                                                           
            if(sendCont) {                   
                ajax.open("POST", pag, true);
				ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
            	ajax.setRequestHeader('encoding','ISO-8859-1');
				ajax.setRequestHeader("Cache-Control","no-store, no-cache, must-revalidate");
				ajax.setRequestHeader("Cache-Control","post-check=0, pre-check=0");
				ajax.setRequestHeader("Pragma", "no-cache");
            } else {
                ajax.open("GET", pag, true);
				ajax.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
            	ajax.setRequestHeader('encoding','ISO-8859-1');
            }            
			//���������������������������������������������Ŀ
			//� Bloqueio do teclado						    � 
			//�����������������������������������������������
			if (lShowProc) BloKeyEvent();          
			//���������������������������������������������Ŀ
			//� Verifica o status do processamento			� 
			//�����������������������������������������������
            ajax.onreadystatechange = function() {
            
                if(ajax.readyState == 4) {
                
                    if(ajax.status == 200) {
					//���������������������������������������������Ŀ
					//� Retira a div de processamento				� 
					//�����������������������������������������������
                    if( lShowProc && isObject('DivProc') ) {
                        
						var xCont = getTC(getObjectID('ModalContainer'));

						if( isEmpty(xCont) ) HideModal();
						
						getObjectID('DivProc').style.display 	= 'none';
            			document.body.style.cursor 				= 'default';
         			}
					//���������������������������������������������Ŀ
					//� DesBloqueio do teclado						� 
					//�����������������������������������������������
					if (lShowProc) DesKeyEvent();
					//���������������������������������������������Ŀ
					//� Resposta									� 
					//�����������������������������������������������
                        var resp = undecode(ajax.responseText);
						/*UNIMED Incluido esse if para carregar cbo vazio quando tem mais de 2 profissionais de saude para ser cosiderado especialidade rda. Ficha  */
						if (pag.length > 17) {
							if (pag.substring(0,16).toUpperCase() == "W_PPCBOSPSAU.APW") {
								resp = resp.substring(0,resp.lastIndexOf("|"))+'|#$'+resp.substring(resp.lastIndexOf("|")+1,resp.length);
							}
						}	
                        if(!resp) {
                            if( typeof(cb) == 'function')
                                cb(null, cbArgs);
                            return false;
                        }       
                          
                        var st 	= resp.substring(0,4);
                        var txt = resp.substring(5);
    
                        if(st == 'true') {
                            if( typeof(cb)== 'function') cb(txt, cbArgs);
                        }  else if(st == 'false') {
                            errorHandle(txt, false, cbArgs);
                            return false;
                        }  else {               
                            errorHandle(resp, true, cbArgs);
                            return false;
                        }                     
                    } else {
                        errorHandle(ajax.statusText, true, cbArgs);
                        return false;
                    }
                } else {      
 					//���������������������������������������������Ŀ
					//� Mostra a div de processamento				� 
					//�����������������������������������������������
					if ( lShowProc && isObject('DivProc') ) {
				  		ShowModal("","");        
						getObjectID('DivProc').style.display 	= 'block';
           				document.body.style.cursor 				= 'wait';
      				} 
                }   
            } 
			//����������������������������������������������
			//� onload crossbrowse safari e chrome
			//����������������������������������������������
			if (BrowserId.browser != 'IE' && lShowProc) ajax.onload = lisload();
			//����������������������������������������������
			//� send
			//����������������������������������������������
            ajax.send(sendCont);    
        }
    },                         
	//���������������������������������������������Ŀ
	//� metodo para enviar formularios HTML         � 
	//�����������������������������������������������
    send: function(f) {
        var sendArgs = arguments[1];
        
        if(sendArgs && typeof(sendArgs) == 'object') {
            var cb 			= sendArgs.callback;
            var cbArgs 		= sendArgs.cbArgs;
            var errorHandle = sendArgs.error;
            var lShowProc   = sendArgs.showProc;
        } else {
            var cb 			= sendArgs;
            var cbArgs 		= arguments[2] ? arguments[2] : null;
            var errorHandle = typeof(arguments[3]) == 'function' ? arguments[3] : null;
            var lShowProc   = arguments[5] ? arguments[5] : true;
        }
        var acao 	= f.action;
        var metodo 	= f.method;
        
        if(!acao) {
            alert("Erro: o valor action do formulario n�o foi definido");
            return false;
        }
        if(!metodo) {
            alert("Erro: o m�todo do formul�rio n�o foi definido");
            return false;
        } else metodo = metodo.toLowerCase();
        
        var send 		= new Array();
        var elementos 	= f.elements;
        for(var i = 0; i < elementos.length; i++) {
            var e = elementos[i];
            if(!e.id) continue;
            if(e.disabled) continue;
            
            var tipo = e.type.toLowerCase();
            
            if(tipo != "checkbox" && tipo != "radio")
                send[send.length] = e.id + "=" + escape(e.value);
            else if(e.checked)
                send[send.length] = e.id + "=" + escape(e.value);
        }             
        send = send.join("&"); 
        
        if(metodo == "post")
             Ajax.open(acao, {callback: cb, post: send, args: cbArgs, error: errorHandle, showProc: lShowProc});
        else Ajax.open(acao + "?" + send, {callback: cb, args: cbArgs, error: errorHandle, showProc: lShowProc});
        
        return false;
    },
	//���������������������������������������������Ŀ
	//� metodo gerenciador de erros padrao da API	� 
	//�����������������������������������������������
    defaultError: function(msg, fatal) {
        if(!fatal)
        	 alert("Erro: " + msg);
        else alert("Erro fatal: " + msg);
    }                 
}                      
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �exibeErro  	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Exibe Erro do processamento ajax									  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function exibeErro(v) {
    var aResult = v.split("|");

    if (aResult[0] != "true" && aResult[0] != "false") alert("Erro: " + aResult[0])
    else {
        if (aResult[0] == "false") {
            alert(aResult[1]);
            //������������������������������������������������������������������������
            //� Move o focu para o campo											  
            //������������������������������������������������������������������������
            if ( wasDef( typeof(cCampoRef) ) && isObject(cCampoRef) && !getObjectID(cCampoRef).disabled ) 
            	getObjectID(cCampoRef).focus();
            //������������������������������������������������������������������������
            //� Limpa campo															  
            //������������������������������������������������������������������������
            if ( wasDef( typeof(cCampoRefL) ) && isObject(cCampoRefL) && !getObjectID(cCampoRefL).disabled ) {
                getObjectID(cCampoRefL).value = "";
                cCampoRefL = "";
            }
            //������������������������������������������������������������������������
            //� Ativa campo como obrigatorio										  
            //������������������������������������������������������������������������
            if ( wasDef( typeof(cCampoRefObr) ) && isObject(cCampoRefObr) ) {                                                    
            	setFieldOB(cCampoRefObr);
            }
            //������������������������������������������������������������������������
            //� Para controle de exclusao											  
            //������������������������������������������������������������������������
            if ( wasDef( typeof(cCpoRegEsp) ) && isObject(cCpoRegEsp) && wasDef( typeof(cCpoRegCon) ) ) {
                getObjectID(cCpoRegEsp).value += cCpoRegCon + '|';
            }
        }
    }
}                      
/*/               
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �setCtrErro � Autor � Alexander Santos			   � Data � 05.04.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Seta variavel de controle de erro para funcao exibeErro				  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function setCtrErro(cTp,cField) {

if (cTp == 'focus') 
	cCampoRef = cField;
	
if (cTp == 'clear') 
	cCampoRefL = cField;

if (cTp == 'obrigatorio') 
	cCampoRefObr = cField;  
	
if (cTp == 'delete') 
	cCpoRegEsp = cField;       
	
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �lisload         � Autor � Alexander Santos	       � Data � 05.03.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Utilizada nos navegadores ff,safari e crhome						  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                      
function lisload() {
	//���������������������������������������������Ŀ
	//� Mostra a div de processamento				�
	//�����������������������������������������������
	if( isObject('DivProc') ) {
		ShowModal("","");
		getObjectID('DivProc').style.display 	= 'block';
		document.body.style.cursor 				= 'wait';
	}
} 
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �inCell/outCell  � Autor � Alexander Santos	       � Data � 05.03.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Muda a cor da linha tr												  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                      
function inCell(cell, newcolor) { cell.bgColor = newcolor; }
function outCell(cell, newcolor) { cell.bgColor = newcolor;	}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �TotvsBioStart   � Autor � Alexander Santos	       � Data � 11.01.2010���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Biometria															  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                      
//������������������������������������������������������������������������Ŀ
//� Valiavel de controle												   �
//��������������������������������������������������������������������������
var appdevice = "";

function TotvsBioStart() {
	SetDebug();
    SetCbCfg();      
	SetCbCapt();    
    SetCbVer();
	SetCbMatchFp();
    SetCbVerMatch();
    SetCbError(); 
    
	appdevice = getdevice();
	
	if( !isEmpty(appdevice) ) {
        document.totvsbioapp.TotvsBioStart();
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �SET			   � Autor � Alexander Santos	       � Data � 11.01.2010���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Funcao de Set para complemento do tratamento biometria				  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                      
function SetDebug() {
    document.totvsbioapp.SetDebug(false);
}
function SetCbCfg() {
   document.totvsbioapp.ConfigCb('SetConfig');
}
function SetCbCapt() {
    document.totvsbioapp.CaptureCb('CaptureCb');
}                      
function SetCbVer() {
    document.totvsbioapp.VerifyCb('VerifyCb');
}        
function SetCbMatchFp() {
	document.totvsbioapp.VerifyMatchFpCb('MatchFp');
}
function SetCbVerMatch() {
    document.totvsbioapp.VerifyMatchCb('MatchCb');
} 
function SetCbError() {
    document.totvsbioapp.SetCbError('ShowError');
}              
function SetConfig() {
    var aConfig = new Array(3);
    aConfig[0] = getdevice();
    aConfig[1] = getoperation();
    aConfig[2] = gettypeauth();

    return aConfig;
}
//������������������������������������������������������������������������Ŀ
//� Exibe erros da biometria											   � 
//��������������������������������������������������������������������������
function ShowError(sMsg) {

    if (sMsg.indexOf("decode64") >= 0) {

		cPar = 'N';
		return setTimeout("TotvsBioStart()", 0);
		
	} else {
		
		if (sMsg.indexOf("CAPTURE_TIMEOUT") >= 0) {
			alert('Tempo de leitura excedido!\nPosicione o dedo no sensor e confirme novamente.');
		} else {
			nErr++;		
			if (nErr < 6) {
				if (sMsg.indexOf("DEVICE_OPEN_FAIL") >= 0) {
					alert('Falha ao ativar o Sensor Biom�trico!\nVerifique se o mesmo est� conectado e se o Drive est� Instalado.');
				} else {
					if (sMsg.indexOf("suspicious") >= 0) {
						alert('Falha ao realizar a captura!\nVerifique se o dedo est� bem posicionado no sensor.');
					} else {
						alert('Falha no Sensor Biom�trico!\nCausa.:\n'+sMsg);
					}
				}
			} else {
				
				if (confirm('Falha ao ativar o Sensor Biom�trico!\nVerifique se o mesmo esta conectado e se o Drive esta Instalado.\nCausa.:\n'+sMsg+'\n\nDeseja Instalar/Reinstalar o Drive?') ) {
					self.close();
					ChamaPoP('W_PPLCHADOW.APW','DownDrv','no',0,500,400)
				}	
			}
		}
	}
	
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �GET			   � Autor � Alexander Santos	       � Data � 11.01.2010���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Funcao de GET para complemento do tratamento biometria				  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                      
function getdevice() {                                                 
	return getObjectID('appDevice').value;
}
function getoperation() {
	return getObjectID('appOperation').value;
}
function gettypeauth() {
	return "1";
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �getObjectID	   � Autor � Alexander Santos	       � Data � 24.02.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Retorna obj															  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function getObjectID(xObj) {
	if (document.getElementById) {
		return document.getElementById(xObj);
	} else if (document.all) {
		return document.all[xObj];
	}
	return null;
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �getObjectNAME   � Autor � Alexander Santos	       � Data � 24.02.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Retorna obj															  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function getObjectNAME(xObj) {
 return document.getElementsByName(xObj);
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �remove	       � Autor � Alexander Santos	       � Data � 24.02.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Remove Child													      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function remove(par) {
	if(par != null){
		par.parentNode.removeChild(par);
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �addEvent	       � Autor � Alexander Santos	       � Data � 24.02.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Add evento														      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function addEvent(obj, evType, fn){

	if (obj.addEventListener)
		obj.addEventListener(evType, fn, true);

	if (obj.attachEvent)
		obj.attachEvent("on"+evType, fn);
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �removeEvent	   � Autor � Alexander Santos	       � Data � 24.02.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Remove evento														  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function removeEvent( obj, evType, fn ) {

	if ( obj.detachEvent )
		 obj.detachEvent( 'on'+evType, fn );
	else obj.removeEventListener( evType, fn, false );
}        
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �UpLoad		   � Autor � Alexander Santos	       � Data � 24.02.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Funcao usada para upload											  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function LoadUpload(form,url_action,id_elemento_retorno,html_exibe_carregando,html_erro_http,funcao,cpar, lBoots) {
	//lBoots indica se a mensagem a ser exibida vai ser com bootstrap
	 form = ( typeof(form) == "string") ? getObjectID(form) : form;
	 
	 var erro="";
	 if( !isObject(form) ){ 
	 	erro += "O form passado n�o existe na pagina.\n";
	 } else if(form.nodeName != "FORM") {
	 	erro += "O form passado na func�o nao e um form.\n";
	 }
	 if( getObjectID(id_elemento_retorno) == null){ 
	 	erro += "O elemento passado n�o existe na p�gina.\n";
	 }
	 if(erro.length>0) {
		 alert("Erro ao chamar a fun��o Upload:\n" + erro);
	 return;
	 }
	 //�������������������������������������������������������������������������
	 //� iFrame
	 //�������������������������������������������������������������������������
	 var iframe = document.createElement("iframe");
	 iframe.setAttribute("id","iload-temp");
	 iframe.setAttribute("name","iload-temp");
	 iframe.setAttribute("width","0");
	 iframe.setAttribute("height","0");
	 iframe.setAttribute("border","0");
	 iframe.setAttribute("style","width: 0; height: 0; border: none;");
	 //�������������������������������������������������������������������������
	 //� Adicionando documento
	 //�������������������������������������������������������������������������
	 form.parentNode.appendChild(iframe);
	
	 window.frames['iload-temp'].name="iload-temp";
	 //�������������������������������������������������������������������������
	 //� Adicionando evento carregar
	 //�������������������������������������������������������������������������
	 var carregou = function() { 
	   removeEvent( getObjectID('iload-temp'),"load", carregou);
	   var cross = "javascript: ";
	   cross += "window.parent.getObjectID('" + id_elemento_retorno + "').innerHTML = document.body.innerHTML; void(0); ";
	   
	   getObjectID(id_elemento_retorno).innerHTML = html_erro_http;
	   getObjectID('iload-temp').src = cross;
	   if((lBoots !== undefined) && lBoots){
			var cDivBoots = '<div class="alert alert-danger alert-dismissible" id="alertGrid" role="alert">'
				cDivBoots += '<button type="button" class="close" aria-label="Close" onclick=$("#alertGrid").hide()><span aria-hidden="true">&times;</span></button>'
				cDivBoots += '<i style="margin-right: 10px;" class="fa fa-exclamation-triangle"></i>'
				cDivBoots += html_erro_http
				cDivBoots += '</div>'
				getObjectID(id_elemento_retorno).innerHTML = cDivBoots;
	   }else{
			getObjectID(id_elemento_retorno).innerHTML = html_erro_http;
	   }
	   getObjectID('iload-temp').src = cross;
	   //�������������������������������������������������������������������������
	   if( getObjectID('iload-temp') != null || getObjectID('iload-temp').parentNode != null){ 
		   //� Deleta o iframe
		   //�������������������������������������������������������������������������
		   setTimeout(function(){ remove(getObjectID('iload-temp'))}, 250);
		   setTimeout(function(){ funcao(cpar) }, 250);		   
		   }
	 }
	 addEvent( getObjectID('iload-temp'), "load", carregou)
	 //�������������������������������������������������������������������������
	 //� Propriedade do form
	 //�������������������������������������������������������������������������
	 form.setAttribute("target","iload-temp");
	 form.setAttribute("action",url_action);
	 form.setAttribute("method","post");
	 form.setAttribute("enctype","multipart/form-data");
	 form.setAttribute("encoding","multipart/form-data");
	 //�������������������������������������������������������������������������
	 //� Envio
	 //�������������������������������������������������������������������������
	 form.submit();
	 //�������������������������������������������������������������������������
	 //� Exibe mensagem ou texto
	 //�������������������������������������������������������������������������
	 if(html_exibe_carregando.length > 0){
		 if((lBoots !== undefined) && lBoots){
			var cDivBoots = '<div class="alert alert-info alert-dismissible" id="alertGrid" role="alert">'
				cDivBoots += '<button type="button" class="close" aria-label="Close" onclick=$("#alertGrid").hide()><span aria-hidden="true">&times;</span></button>'
				cDivBoots += '<i style="margin-right: 10px;" class="fa fa-spinner fa-spin"></i>'
				cDivBoots += html_exibe_carregando
				cDivBoots += '</div>'
				getObjectID(id_elemento_retorno).innerHTML = cDivBoots;
	    }else{
			getObjectID(id_elemento_retorno).innerHTML = html_exibe_carregando;
	    }
   		
	 }
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �trim		   	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Funcao trim	   														  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function trim(str) {
    if(typeof(str) != 'undefined')
        return str.replace(/^\s+|\s+$/g,"");
    else
        return str;
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �ltrim	   	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Funcao left trim													  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function ltrim(str) {
	return str.replace(/^\s+/,"");
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �rtrim	   	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Funcao right trim													  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function rtrim(str) {
	return str.replace(/\s+$/,"");
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �wasDef    	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � verifica se uma variavel esta no escopo								  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function wasDef(xtype) {
	return ( xtype != 'undefined');
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �isObject  	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Se o oObj existe/valido												  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/               
function isObject(xObj) {
	var lRet = false;  
	//�������������������������������������������������������������������������
	//� se e um obj valido
	//�������������������������������������������������������������������������
	if ( typeof(xObj) != 'undefined' && xObj != null ) {
		if (typeof(xObj) != "object")
			 lRet = ( getObjectID(xObj) != null );    	
		else lRet = true; 	
    }
	return lRet;
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �comboLoad  	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Monta comobox dinamicamente conforme dados enviados					  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function comboLoad(xObj,aDad,lNewLine,lSelectItem, cValDefault) {                                               
	lSelectItem = !(lSelectItem === undefined);
	//�������������������������������������������������������������������������
	//� Se o obj existir e nao for nulo
	//�������������������������������������������������������������������������
	if ( isObject(xObj) ) {
		var e 		 	= getObjectID(xObj);
		var lAddSelIte	= ( aDad.length > 1 || isEmpty(aDad) ) && ( !wasDef( typeof(lNewLine) ) ) ? true : lNewLine;
		var x			= 0;
		setTC(e,"");             
		//�������������������������������������������������������������������������
		//� Adiciona linha extra
		//�������������������������������������������������������������������������
		if ((lAddSelIte && !(e.multiple)) || lSelectItem) {
			e.options[x] = new Option("-- Selecione um Item --", "");
			x = 1;
		}	
		//�������������������������������������������������������������������������
		//� Monta o combo conforme dados enviados
		//�������������������������������������������������������������������������
		for (var i = 0; i < aDad.length; i++) {
		 	if ( !isEmpty(aDad[i]) ) {
				var aIten = aDad[i].split("$");
				
				e.options[(i+x)] = new Option(aIten[1], aIten[0]);		
				
				if (cValDefault != undefined && cValDefault != ""){
					if(aIten[0].trim() == cValDefault.trim())
						e.options[(i+x)].setAttribute("selected", 'selected')	
				}

				//e.options[(i+x)].setAttribute("selected", 'selected')	
				
				//Nova implementa��o: permite criar um ou varios atributos din�mico para cada option do combobox, onde:
				//			a partir do aIten[2] em diante ser�o as posi�oes de cada atributo, compostas por atributo#valor
				if(aIten.length >= 2){
					for(var j=2;j < aIten.length; j++){
						var item = aIten[j].split("#");
						e.options[(i+x)].setAttribute(item[0], item[1]);
					}
				}
			}			
		}
		
		if($(e).hasClass("compSelect2")){
			$(e).select2().select2('data', null);
		}
 	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �blockEsc  	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Bloqueio do ESC														  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function blockEsc(e) {
	var ev 	  = e || window.event;
  	var tecla = ev.keyCode || ev.which;
	
    if (tecla == 27) {
        ev.returnValue = false;
    }

    if (tecla == 8 && (ev.target.readOnly == true || ev.target.isDisabled == true || ev.target.tagName.toLowerCase() == "select") ) {

    	if (ev.preventDefault)
			ev.preventDefault();
		return false;
    }
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �validaFieldOb   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Valida campos obrigatorio do form									  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function validaFieldOb() {
	var oForm 	= document.forms[0];
	var oObj	= oForm.elements;	
	var nQtdObj = oForm.length;
	
	for( i=0; i < nQtdObj; i++ ){

		if (oObj[i].type == "select-one" || oObj[i].type == "text" || oObj[i].type == "password") {
		
			if ( oObj[i].className.indexOf("OB") != -1 && isEmpty( trim(oObj[i].value) ) ) {
				alert("Campo obrigat�rio n�o preenchido.");
				oObj[i].focus();
				return false;
			}
			
		}
	}
	return true
};
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �setField		   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Seta Valor em um Obj												  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function setField(xObj,xConteudo) {
	if ( isObject(xObj) )
		getObjectID(xObj).value = xConteudo;
} 
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �GetField		   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Retorna o Valor de um Obj											  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function getField(xObj) {
var xConteudo = '';

if ( isObject(xObj) )
	xConteudo = getObjectID(xObj).value;
		
return xConteudo;		
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �getTC		   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Retorna o conteudo de OBJ conforme navegador						  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function getTC(xObj) {
return (BrowserId.browser == 'IE') ? xObj.innerText.replace(/&nbsp;/g, " ").replace(/\s*$/, "") : xObj.textContent.replace(/&nbsp;/g, " ").replace(/\u00a0/g, " ").replace(/\s*$/, "");
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �setTC		   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Seta o conteudo de OBJ conforme navegador						      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function setTC(xObj,cConteudo) {
(BrowserId.browser == 'IE') ? (xObj.innerText = cConteudo) : (xObj.textContent = cConteudo);
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �BroFormFocus	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Focus dos campos do formulario										  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
var BFFocus = {
	// Propriedades do Classe
	// Metodos da Classe
	init: function() {
		// Variavel Local
		var oForm = document.forms[0];
		
		if ("onfocusin" in oForm) {
			// IE from version 9
		    if (oForm.addEventListener) {    
				oForm.addEventListener ("focusin", this.OnFocusInForm, false);
				oForm.addEventListener ("focusout", this.OnFocusOutForm, false);
		
			// IE before version 9		
			} else { 
				if (oForm.attachEvent) {     
					oForm.attachEvent ("onfocusin", this.OnFocusInForm);
					oForm.attachEvent ("onfocusout", this.OnFocusOutForm);
				}
			}
		// Firefox, Opera, Google Chrome and Safari
		} else {
			if (oForm.addEventListener) {    
				oForm.addEventListener ("focus", this.OnFocusInForm, true);
				oForm.addEventListener ("blur", this.OnFocusOutForm, true);
			}
		}
	},                                                 
	OnFocusInForm: function(event) {
		var target  = event.target ? event.target : event.srcElement;

		if (target && target.type == 'text') {
			target.style.backgroundColor = "#BCD2EE";
		}
	},                     
	OnFocusOutForm: function(event) {
		var target = event.target ? event.target : event.srcElement;

		if (target && target.type == 'text') {
			target.style.backgroundColor = "";
		}
	}
};
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �setDisable	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Coloca o obj no modo disabled ou retira								  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function setDisable(xObj,lDisable) {
	var oObj = getObjectID(xObj);

	if ( isObject(oObj) ) {
		//evita erro de campo hidden que � usado com HTTPPOST no servidor, o metodo POST n�o reconhece campos disabled, chegando NIL na webfunction 
		if(oObj.type != "hidden"){ 
			var lDisabled = (wasDef( typeof lDisable)) ? lDisable : !oObj.disabled;
			var cClass 	  = oObj.className;
		
			if (lDisabled) {
				cClass =  cClass + " disabled";
			} else {
				cClass = cClass.replace(/ disabled/g, "");
			}
			
			oObj.className = cClass;	
			oObj.disabled  = lDisabled;
		}
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �setReadOnly	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Coloca ou retira obj de somente leitura								  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function setReadOnly(xObj,xType) {
	if ( isObject(xObj) ) {
		if ( getObjectID(xObj).type != "select-one" ) {
			getObjectID(xObj).readOnly = xType;        
		}	
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �isEmpty	   	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Se o campo esta vazio												  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function isEmpty(xObj) {
	if ( xObj == null || xObj == "" ) { 
		return true; 
	} else {
		return false; 
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �setFieldOB  	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Seta obj para obrigatorio											  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function setFieldOB(xObj) {

	if ( isObject(xObj) ) {
        var oObj = getObjectID(xObj);
        
        if ( !isEmpty(oObj.className) )
			oObj.className 	= oObj.className.replace("OP","OB"); 
	}	
}
/*/               
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �gridData   � Autor � Alexander Santos			   � Data � 05.04.2007���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Funcao para carregar browse (grid) dinamicamente obj literal		  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
var gridData = new Class ({
    // Propriedade publica
	_numeroPagina:1,
	__oo:[],
	//Construtor
    constructor: function(cConteiner,cWidth,cHeight, lMostRod) {
		this.cConteiner = (cConteiner) ? cConteiner : 'BRWGrid';
		this.cWidth 	= (cWidth) ? cWidth : '700';
		this.cHeight 	= (cHeight) ? cHeight : '100';
		this.lMostRod	= (lMostRod != undefined ) ? lMostRod : true//true : ((lMostRod) ? lMostRod : true)
    },
	//Metodos publicos
	init: function(openArgs) {
		//�������������������������������������������������������������������������
		//� Argumentos enviados 
		//�������������������������������������������������������������������������
		this.cConteiner 		= ( wasDef( typeof(openArgs.cConteiner) ) ) ? openArgs.cConteiner : this.cConteiner;
		this.cWidth 			= ( wasDef( typeof(openArgs.cWidth) ) ) ? openArgs.cWidth : this.cWidth;
		this.cHeight 			= ( wasDef( typeof(openArgs.cHeight) ) ) ? openArgs.cHeight : this.cHeight;
		this.nRegPagina 		= ( wasDef( typeof(openArgs.nRegPagina) ) ) ? openArgs.nRegPagina : 0;
		this.nQtdPag 			= ( wasDef( typeof(openArgs.nQtdPag) ) ) ? openArgs.nQtdPag : 0;
		this.nQtdReg 			= ( wasDef( typeof(openArgs.nQtdReg) ) ) ? openArgs.nQtdReg : 0;
		this.aHeader 			= ( wasDef( typeof(openArgs.aHeader) ) ) ? openArgs.aHeader : [];
		this.aCols 				= ( wasDef( typeof(openArgs.aCols) ) ) ? openArgs.aCols : [];
		this.lChkBox 			= ( wasDef( typeof(openArgs.lChkBox) ) ) ? openArgs.lChkBox : false;
		this.lShowLineNumber 	= ( wasDef( typeof(openArgs.lShowLineNumber) ) ) ? openArgs.lShowLineNumber : true;
		this.aBtnFunc 			= ( wasDef( typeof(openArgs.aBtnFunc) ) ) ? eval(openArgs.aBtnFunc) : [];
		this.fFunName 			= ( wasDef( typeof(openArgs.fFunName) ) ) ? openArgs.fFunName : "";
		this.cColLeg 			= ( wasDef( typeof(openArgs.cColLeg) ) ) ? openArgs.cColLeg : "";
		this.aCorLeg 			= ( wasDef( typeof(openArgs.aCorLeg) ) ) ? eval(openArgs.aCorLeg) : [];		
		this.lMostRod	 		= ( wasDef( typeof(openArgs.lMostRod) ) ) ? openArgs.lMostRod : this.lMostRod;
		//�������������������������������������������������������������������������
		//� objeto temporiario
		//�������������������������������������������������������������������������
		var __objT				= eval('gridData.definition.__oo.___o' + this.cConteiner);
		//�������������������������������������������������������������������������
		//� Propriedades do Classe
		//�������������������������������������������������������������������������
		this.aColsCk			= ( wasDef( typeof(__objT) ) ) ? __objT.aColsCk : [];
		this.aColsUnCk			= ( wasDef( typeof(__objT) ) ) ? __objT.aColsUnCk : [];
		this.aRows				= ( wasDef( typeof(__objT) ) ) ? __objT.aRows : [];
		this.nContLin			= ( wasDef( typeof(__objT) ) ) ? __objT.nContLin : 0;
		this.cNameTab			= ( wasDef( typeof(this.cNameTab) ) ) ? this.cNameTab : 'tab'+this.cConteiner;
		//�������������������������������������������������������������������������
		//� verifica se e possivel montar o browse
		//�������������������������������������������������������������������������
		openArgs = null;
		var lRet = true;
		if (nQtdRegTemp == 0 && this.nQtdReg > 0 || (nQtdRegTemp > 0 && nQtdRegTemp != this.nQtdReg)) {
			nQtdRegTemp = this.nQtdReg;	//	Salva a quantidade de registros
		}
		
		if ( isEmpty(this.aHeader) && isEmpty(this.aCols) ) {
			var lRet = false;
		}
		return(lRet);
	},
	load: function() {
		//�������������������������������������������������������������������������
		//� verifica se e possivel montar o obj
		//�������������������������������������������������������������������������
	 	if ( !this.init(this.load.arguments[0]) ) {
	 		alert("Estrutura invalida");
	 		return false;
	 	}          
		//�������������������������������������������������������������������������
		//� Se a tabela nao existe cria
		//�������������������������������������������������������������������������
		if ( !isObject(this.cNameTab) ) { 
			//�������������������������������������������������������������������������
			//� Verifica se cria botao de navegacao
			//�������������������������������������������������������������������������
			if (this.nRegPagina > 0) {
				//�������������������������������������������������������������������������
				//� numero da pagina em hidden
				//�������������������������������������������������������������������������
				if (numeroPaginaTemp > "" && this._numeroPagina != numeroPaginaTemp) {
					this._numeroPagina = numeroPaginaTemp;	//	Corrige o N�mero da P�gina
				}
				if ( !isObject(getObjectID(this.cConteiner+'nPagina')) ) {
					var numeroPagina = document.createElement('input');
					numeroPagina.id	 	= this.cConteiner+'nPagina';
					numeroPagina.type 	= 'hidden'
					numeroPagina.value 	= this._numeroPagina;
					document.body.appendChild(numeroPagina);
				} else {
					getObjectID(this.cConteiner+'nPagina').value = this._numeroPagina;
				}				
				//�������������������������������������������������������������������������
				//� Quantidade de registro na pagina
				//�������������������������������������������������������������������������
				if (nQtdRegTemp > 0 && this.nQtdReg != nQtdRegTemp) {
					this.nQtdReg = nQtdRegTemp;	//	Corrige a Quantidade de Registros
				}
				if ( !isObject(getObjectID(this.cConteiner+'nQtdPag')) ) {
					var nQtdPagina 		= document.createElement('input');
					nQtdPagina.id	 	= this.cConteiner+'nQtdPag';
					nQtdPagina.type 	= 'hidden'
					nQtdPagina.value 	= this.nQtdPag;
					document.body.appendChild(nQtdPagina);
				} else {
					getObjectID(this.cConteiner+'nQtdPag').value = this.nQtdPag;
				}				
				//�������������������������������������������������������������������������
				//� Quantidade de registro
				//�������������������������������������������������������������������������
				if ( !isObject(getObjectID(this.cConteiner+'nQtdReg')) ) {
					var nQtdRegistro 	= document.createElement('input');
					nQtdRegistro.id	 	= this.cConteiner+'nQtdReg';
					nQtdRegistro.type 	= 'hidden'
					nQtdRegistro.value 	= this.nQtdReg;
					document.body.appendChild(nQtdRegistro);
				} else {
					getObjectID(this.cConteiner+'nQtdReg').value = this.nQtdReg;
				}				
				//�������������������������������������������������������������������������
				//� Rodape
				//�������������������������������������������������������������������������
				if (this.lMostRod) {
				var oRodape 	  		= getObjectID('Rodape'+this.cConteiner);
				$(oRodape).empty(); //apago todos elementos filhos para garantir a n�o duplicidade
				//�������������������������������������������������������������������������
				//� div pagination
				//�������������������������������������������������������������������������
				var BrwGridPagination = document.createElement('DIV');
				BrwGridPagination.id 			= this.cConteiner+'Pagination';
				BrwGridPagination.className = 'infoBarBottom left col-xs-12 col-sm-12 col-md-12 col-lg-12';
				//�������������������������������������������������������������������������
				//� div left
				//�������������������������������������������������������������������������
				//var BrwGridLeft 		= document.createElement('DIV');
				//BrwGridLeft.id 			= this.cConteiner+'Left';
				
				var BrwDivGroupPage 		= document.createElement('DIV');
				BrwDivGroupPage.id 			= this.cConteiner+'DivGroupPage';
				BrwDivGroupPage.className   = 'input-group';
				
				var BrwSpanGroupPage 		= document.createElement('SPAN');
				BrwSpanGroupPage.id 		= this.cConteiner+'SpanGroupPage1';
				BrwSpanGroupPage.className  = 'input-group-btn';
				
				var oBtn = document.createElement("button");        // Create a <button> element
				oBtn.id 		= this.cConteiner+'first';
				oBtn.setAttribute('type', 'button');
				oBtn.className = 'btn btn-default';
				oBtn.disabled	= true;
				var t = document.createTextNode("Primeiro");       // Create a text node
				oBtn.appendChild(t);           
				var cFunc = "navGridDat('" + this.cConteiner + "','" + this.fFunName + "','first')";	
				oBtn.setAttribute('onclick',cFunc);		
					
				BrwSpanGroupPage.appendChild(oBtn); 
				
				var oBtn = document.createElement("button");        // Create a <button> element
				oBtn.id 		= this.cConteiner+'prev';
				oBtn.setAttribute('type', 'button');
				oBtn.className = 'btn btn-default';
				oBtn.disabled	= true;
				var t = document.createTextNode("Anterior");       // Create a text node
				oBtn.appendChild(t);                                // Append the text to <button> 			
				var cFunc = "navGridDat('" + this.cConteiner + "','" + this.fFunName + "','prev')";
				oBtn.setAttribute('onclick',cFunc);
				
				BrwSpanGroupPage.appendChild(oBtn); 
				
				var oBtn = document.createElement("button");        // Create a <button> element
				oBtn.id 		= this.cConteiner+'next';
				oBtn.setAttribute('type', 'button');
				oBtn.className = 'btn btn-default';
				oBtn.disabled	= true;
				var t = document.createTextNode("Pr�ximo");       // Create a text node
				oBtn.appendChild(t);                                // Append the text to <button> 				
				var cFunc = "navGridDat('" + this.cConteiner + "','" + this.fFunName + "','next')";
				oBtn.setAttribute('onclick',cFunc);
				
				BrwSpanGroupPage.appendChild(oBtn); 
				
				var oBtn = document.createElement("button");        // Create a <button> element
				oBtn.id 		= this.cConteiner+'last';
				oBtn.setAttribute('type', 'button');
				oBtn.className = 'btn btn-default';
				oBtn.disabled	= true;
				var t = document.createTextNode("�ltimo");       // Create a text node
				oBtn.appendChild(t);                                // Append the text to <button> 			
				var cFunc = "navGridDat('" + this.cConteiner + "','" + this.fFunName + "','last')";
				oBtn.setAttribute('onclick',cFunc);
				
				BrwSpanGroupPage.appendChild(oBtn);
				
				var oInput = document.createElement("input");
				oInput.id = this.cConteiner+'pageNum';
				oInput.setAttribute('type', 'text');
				oInput.className = 'form-control';
				oInput.placeholder = 'N�';
				oInput.style.maxWidth = '100px';
				oInput.style.minWidth = '70px';
				oInput.onkeypress = function(event){return SomenteNumero(event)}
				
				var BrwSpanGroupPage2 		= document.createElement('SPAN');
				BrwSpanGroupPage2.id 		= this.cConteiner+'SpanGroupPage2';
				BrwSpanGroupPage2.className  = 'input-group-page-ok';
				
				var oBtn = document.createElement("button");        // Create a <button> element
				oBtn.id 		= this.cConteiner+'SetPage';
				oBtn.setAttribute('type', 'button');
				oBtn.className = 'btn btn-default';
				var t = document.createTextNode("OK");       // Create a text node
				oBtn.appendChild(t);           
				var cFunc = "navGridDat('" + this.cConteiner + "','" + this.fFunName + "','pageNum')";	
				oBtn.setAttribute('onclick',cFunc);		
					
				BrwSpanGroupPage2.appendChild(oBtn); 
				
				BrwDivGroupPage.appendChild(BrwSpanGroupPage);
				BrwDivGroupPage.appendChild(oInput);
				BrwDivGroupPage.appendChild(BrwSpanGroupPage2);
				BrwGridPagination.appendChild(BrwDivGroupPage);
				//�������������������������������������������������������������������������
				oRodape.appendChild(BrwGridPagination);
				//�������������������������������������������������������������������������
				//� div page
				//�������������������������������������������������������������������������
				var BrwGridPage 		= document.createElement('DIV');
				BrwGridPage.id 			= this.cConteiner+'Page';
				BrwGridPage.className 	= 'infoBarBottom left col-xs-12 col-sm-12 col-md-12 col-lg-12';
				BrwGridPage.innerHTML   = 'P�gina: '+this._numeroPagina+' de '+this.nQtdPag;
				oRodape.appendChild(BrwGridPage); 
				//�������������������������������������������������������������������������
				//� div total
				//�������������������������������������������������������������������������
				var BrwGridRegTot 		= document.createElement('DIV');
				BrwGridRegTot.id 		= this.cConteiner+'RegTot';
				BrwGridRegTot.className = 'infoBarBottom right col-xs-12 col-sm-12 col-md-12 col-lg-12';
				BrwGridRegTot.innerHTML = 'Total de Registro(s) : ' + this.nQtdReg;
				oRodape.appendChild(BrwGridRegTot); 
			}
		}
			//�������������������������������������������������������������������������
			//� Propriedade da div
			//�������������������������������������������������������������������������
			var oDiv = getObjectID(this.cConteiner);
			//�������������������������������������������������������������������������
			//� Propriedade da table H
			//�������������������������������������������������������������������������
			var lCab    = true;
			//�������������������������������������������������������������������������
			//� Propriedade da table
			//�������������������������������������������������������������������������
			var oTable  = document.createElement("TABLE");
			var oTHead  = document.createElement("THEAD");
			var oTBody  = document.createElement("TBODY");
			//�������������������������������������������������������������������������
			//� Class CSS da tabela, thead e tbody
			//�������������������������������������������������������������������������
			oTable.id			= this.cNameTab;
			oTable.className = "table table-striped table-bordered table-hover dt-responsive";
			oTable.cellSpacing	= "0";  
			oTable.cellPadding	= "0";
			oTable.style.width  = "100%"; 

			oTHead.className 	= "cabacalho";
			oTBody.className 	= "conteudo";
			//�������������������������������������������������������������������������
			//� Head e Body
			//�������������������������������������������������������������������������
			oTable.appendChild(oTHead);
			oTable.appendChild(oTBody);
			oDiv.appendChild(oTable);
		} else {
			var oTable 	= getObjectID(this.cNameTab);
			var lCab	= false;
		
		if (this.lMostRod) {
			if (this.nRegPagina > 0) {
				this._numeroPagina 	= getObjectID(this.cConteiner+'nPagina').value;
				
				if (this.nQtdPag==0) {
					this.nQtdPag = getObjectID(this.cConteiner+'nQtdPag').value;
					this.nQtdReg = getObjectID(this.cConteiner+'nQtdReg').value;
				} else {	
					getObjectID(this.cConteiner+'nQtdPag').value = this.nQtdPag;
					getObjectID(this.cConteiner+'nQtdReg').value = this.nQtdReg;
				}
				setTC(getObjectID(this.cConteiner+'Page'),'P�gina: '+this._numeroPagina+' de '+this.nQtdPag);
				setTC(getObjectID(this.cConteiner+'RegTot'),'Total de Registro(s) : ' + this.nQtdReg);
			}
		}
		}
		//�������������������������������������������������������������������������
		//� Cria obj head e body
		//�������������������������������������������������������������������������
	    var i,y;
		var nSeqTab	  = 0;
		var oTHead    = oTable.createTHead();	
		var oTBody    = this.getObjCols();
		var lCab      = ( lCab && this.aCols.length == 0 ) ? false : lCab;
		//�������������������������������������������������������������������������
		//� Verifica se tem linha na tabela
		//�������������������������������������������������������������������������
		this.setEmptyCols()
		//�������������������������������������������������������������������������
		//� Primeira linha monta o cabecalho									   
		//�������������������������������������������������������������������������
		if (lCab) {
			lCab = false;
			var oLinHead  = this.newHead(oTHead);
			//�������������������������������������������������������������������������
			//� Coluna contador no cabecalho
			//�������������������������������������������������������������������������
			if (this.lShowLineNumber) {
				this.newCol(true,oLinHead,"Item");
			}    
			//�������������������������������������������������������������������������
			//� Coluna checkbox no cabecalho
			//�������������������������������������������������������������������������
			if (this.lChkBox) this.newColChkBox(true,oLinHead, "chkBox"+this.cConteiner+"CabAll", true);
			//�������������������������������������������������������������������������
			//� Colunas do cabecalho												   
			//�������������������������������������������������������������������������
			for (var i = 0; i in this.aHeader; i++) {
				this.newCol(true,oLinHead,this.aHeader[i].name)
			}
		}
		//�������������������������������������������������������������������������
		//� Libera botao de navegacao
		//�������������������������������������������������������������������������
		if (this.aCols.length > 0) {
			//�������������������������������������������������������������������������
			//� Previous e First buttons
			//�������������������������������������������������������������������������				
				if (this._numeroPagina > 1) {
					
					if ( isObject(this.cConteiner+"first") ){
						var oDivFirst = getObjectID(this.cConteiner+"first");
						oDivFirst.disabled  = false;				
					}
				
					if ( isObject(this.cConteiner+"prev") ){
						var oDivPrev = getObjectID(this.cConteiner+"prev");
						oDivPrev.disabled  = false;				
					}
				}
				
				else {			
					if ( isObject(this.cConteiner+"first") ){
						var oDivFirst = getObjectID(this.cConteiner+"first");
						oDivFirst.disabled  = true;			
					}
					
					if ( isObject(this.cConteiner+"prev") ){
						var oDivPrev = getObjectID(this.cConteiner+"prev");
						oDivPrev.disabled  = true;				
					}			
				}
			//�������������������������������������������������������������������������
			//� Next e Last buttons
			//�������������������������������������������������������������������������				
				if (this.nQtdPag == this._numeroPagina) {
				
					if ( isObject(this.cConteiner+"next") ){
						var oDivNext = getObjectID(this.cConteiner+"next");
						oDivNext.disabled  = true;					
					}
					
					if ( isObject(this.cConteiner+"last") ){
						var oDivLast = getObjectID(this.cConteiner+"last");
						oDivLast.disabled  = true;					
					}
				}
				else {
					if ( isObject(this.cConteiner+"next") ){
							var oDivNext = getObjectID(this.cConteiner+"next");
							oDivNext.disabled  = false;				
						}
						
					if ( isObject(this.cConteiner+"last") ){
						var oDivLast = getObjectID(this.cConteiner+"last");
						oDivLast.disabled  = false;				
					}
				}				
			//�������������������������������������������������������������������������
			//� Sequencial do item pela pagina
			//�������������������������������������������������������������������������
			this.nContLin = (this.nRegPagina*this._numeroPagina) - this.nRegPagina;
		} else {	
			this.setEmptyDiv();
		}
		//�������������������������������������������������������������������������
		//� Nova Linha - aCols
		//�������������������������������������������������������������������������
		var lCor = true;
		for (var i = 0; i in this.aCols; i++) {
			var nLin 	 = (this.nContLin+i)+1;
			var cNameChk = "chkBox" + this.cNameTab + '_' + nLin;
			//�������������������������������������������������������������������������
			//� Nova linha
			//�������������������������������������������������������������������������
			if (lCor) {                               
				lCor = false;
				var oLinBody = this.newLineBody(oTBody,"Linha" + this.cConteiner + nLin);
			} else {
				lCor = true;
				var oLinBody = this.newLineBody(oTBody,"Linha" + this.cConteiner + nLin,"linCorF5");	
			}
			//�������������������������������������������������������������������������
			//� Insere contador														   
			//�������������������������������������������������������������������������
			if (this.lShowLineNumber) {
				this.newCol(true,oLinBody, nLin, 'Cont' + this.cConteiner + nLin )
			}
			//�������������������������������������������������������������������������
			//� Cria checkbox											       		   
			//�������������������������������������������������������������������������
			if (this.lChkBox) this.newColChkBox(false,oLinBody,cNameChk,false,this.findIdLinha(this.aCols[i]));
			//�������������������������������������������������������������������������
			//� Conteudo da coluna
			//�������������������������������������������������������������������������
			for (var y = 0; y in this.aCols[i]; y++) { 
				//�������������������������������������������������������������������������
				//� nao insere no browse o identificador de linha para uso do chkbox
				//�������������������������������������������������������������������������
				if (this.aCols[i][y].field != 'IDENLINHA') {
					//�������������������������������������������������������������������������
					//� Conteudo da coluna
					//�������������������������������������������������������������������������
					var cConteudo = isEmpty(this.aCols[i][y].value) ? '&nbsp;' : this.aCols[i][y].value;
					//�������������������������������������������������������������������������
					//� Se foi informado o identificador de btn na coluna
					//�������������������������������������������������������������������������
					var nPos = ( wasDef( typeof(cConteudo) ) ) ? cConteudo.indexOf('#') : -1;
					//�������������������������������������������������������������������������
					//� Se tem btn cria
					//�������������������������������������������������������������������������
					if ( nPos != -1 ) {                                     
						//�������������������������������������������������������������������������
						//� Procura qual e a posicao do botao na matriz this.aBtnFunc
						//�������������������������������������������������������������������������
						if ( this.aBtnFunc.length > 0 ) {
							var nPosBtn	= parseInt(cConteudo.substr(0,nPos),10);
							var cFunc = "";
							if (this.aBtnFunc.length === 1 && nPosBtn > 0)
								nPosBtn = 0;
							
							if ( nPosBtn <= this.aBtnFunc.length ) {  
								var cImgName = this.aBtnFunc[nPosBtn].img;
	
								cFunc = this.aBtnFunc[nPosBtn].funcao +  '(' + cConteudo.substr(nPos+1,cConteudo.length) + ')';
									
								//Se colocar o identificador *, significa que � string o valor do campo.
								if(cConteudo.indexOf('*') > 0) {
								  	cFunc = this.aBtnFunc[nPosBtn].funcao + '("' + cConteudo.substr(nPos + 1, cConteudo.length) + '")';		
								 }
									
									
								var cInfo 	 = wasDef( typeof(this.aBtnFunc[nPosBtn].info) ) ? this.aBtnFunc[nPosBtn].info : '';
								//�������������������������������������������������������������������������
								//� Cria a coluna de btn
								//�������������������������������������������������������������������������
								this.newColBtn(oLinBody, i, cImgName, cFunc, cInfo);
							}	
						}
					} else {
						//�������������������������������������������������������������������������
						//� Se tem legenda
						//�������������������������������������������������������������������������					
						if ( !isEmpty(this.cColLeg) && this.aCols[i][y].field == this.cColLeg) {
							var cImgCor = ''
							for (var z = 0; z in this.aCorLeg; z++) {
								if (this.aCorLeg[z].valor == cConteudo) cImgCor = this.aCorLeg[z].imgcor; 
							}					
							//�������������������������������������������������������������������������
							//� Cria legenda											       		   
							//�������������������������������������������������������������������������
							this.newColLeg(oLinBody, i, cImgCor, 'verde');	
						} else {								
							this.newCol(false,oLinBody ,cConteudo);
						}
					}	
				}
			}
		}                 
		//�������������������������������������������������������������������������
		//� cria uma instancia global do obj
		//�������������������������������������������������������������������������
		this.__oo['___o'+this.cConteiner] = Object.create(this);
		//�������������������������������������������������������������������������
		//� fim do metodo 
		//�������������������������������������������������������������������������
		setFxScroll(this.cConteiner,this.cNameTab,this.cWidth,this.cHeight);
		
		updGridSchemeColor();
	},             
	newHead: function(oTHead,cClassName) {
		//�������������������������������������������������������������������������
		//� Inclui outra linha													   
		//�������������������������������������������������������������������������
		var oLinha = oTHead.insertRow(-1);
		//�������������������������������������������������������������������������
		//� Class Css
		//�������������������������������������������������������������������������
		if ( cClassName ) oLinha.className = cClassName;
			
		return oLinha;
	},
	newLineBody: function(oTBody,cId,cClassName) {
		//�������������������������������������������������������������������������
		//� Inclui outra linha													   
		//�������������������������������������������������������������������������
		var oLinha = oTBody.insertRow(-1);	
		//�������������������������������������������������������������������������
		//� Class Css
		//�������������������������������������������������������������������������
		if ( cClassName ) oLinha.className = cClassName;

		if ( cId ) oLinha.id = cId;
		//�������������������������������������������������������������������������
		//� MouseOver e Out
		//�������������������������������������������������������������������������        
		oLinha.onmouseover	= function(){inCell(this, '#E2E4E6');};		
		oLinha.onmouseout	= function(){outCell(this, '#FFFFFF');};
		
		return oLinha;
	},
	newCol: function(lTh,oLinha,cConteudo,cContID,cClassName) {
		//�������������������������������������������������������������������������
		//� Cria coluna th ou td
		//�������������������������������������������������������������������������        
		if (lTh) {
			var oColuna = document.createElement('th'); 			
			oLinha.appendChild(oColuna); 
		} else {
			var oColuna = oLinha.insertCell(-1);
		}
		//�������������������������������������������������������������������������
		//� Class CSS
		//�������������������������������������������������������������������������        
		if ( cClassName ) oColuna.className = cClassName;
		//�������������������������������������������������������������������������
		//� Identificacao da coluna
		//�������������������������������������������������������������������������        
		if ( cContID ) oColuna.id = cContID;
		//�������������������������������������������������������������������������
		//� Conteudo na coluna
		//�������������������������������������������������������������������������        
		if ( cConteudo )
			oColuna.innerHTML = cConteudo;
		if ( (String(cConteudo).match("CMPSEQ") !== null) ){
			oColuna.style.display = "none";
		}

		return oColuna;
    },
	newColChkBox: function(lTh,oLinha,cId,lCab,cValue) {
		var cValue	 = ( !wasDef(typeof(cValue)) ) ? "" : cValue;
		var ochkBox  = document.createElement('input');
		var lChecked = false;
		var oColuna  = this.newCol(lTh,oLinha);
		
		ochkBox.type  = 'checkbox';
		ochkBox.id 	  = cId;         
		ochkBox.name  = cId;         
		ochkBox.value = cValue;         
		
		if (lCab) {
			ochkBox.setAttribute('onclick','gridData.definition.__oo.___o'+this.cConteiner+'.setChkAll(this)');	
		} else {
			ochkBox.setAttribute('onclick','gridData.definition.__oo.___o'+this.cConteiner+'.setChkIte(this)');	
			
			var lChecked = getObjectID("chkBox"+this.cConteiner+"CabAll").checked;
			//�������������������������������������������������������������������������
			//� se marcar todos foi selecionado verifica se o obj em questao estava desmarcado ou marcado e mantem o original
			//�������������������������������������������������������������������������
			if (lChecked) {
				var nPos = this.findIsMark(this.aColsUnCk,ochkBox.value);
				if (nPos != -1) lChecked = false;
			} else {
				if (this.aColsCk.length>0) {
					var nPos = this.findIsMark(this.aColsCk,ochkBox.value);
					if (nPos != -1) lChecked = true;
				}	
			}
		}
		oColuna.appendChild(ochkBox);
		oColuna.className = oColuna.className + " no-sort";
		//�������������������������������������������������������������������������
		//� se o chkall esta marcada marca todos os check box das linhas
		//�������������������������������������������������������������������������
		if (lChecked) ochkBox.setAttribute("checked","checked");	
	},
	newColBtn: function(oLinBody, nI, cBtn, cFunc, cInfo) {
		var oColuna 	= this.newCol(false,oLinBody)
		var oCenter 	= document.createElement("center");
		var oImg 		= document.createElement("img");
		oImg.id	 		= 'btn' + this.cConteiner + nI;
		oImg.className 	= 'colBtn';
		
		oImg.setAttribute('src', cRaiz + cBtn);
		oImg.setAttribute('onclick',cFunc);
		//�������������������������������������������������������������������������
		//� informacao de help do btn
		//�������������������������������������������������������������������������
		if ( cInfo ) oImg.setAttribute('alt', cInfo); 

		oCenter.appendChild(oImg);
		oColuna.appendChild(oCenter);
	},
	newColLeg: function(oLinBody, nI, cImgCor, cInfo) {
		var oColuna 	= this.newCol(false,oLinBody)
		var oCenter 	= document.createElement("center");
		var oImg;
		var id = 'iLeg' + this.cConteiner + nI;	
	
		if(cImgCor.search("icon-") == -1){
			oImg  = document.createElement("img");
			oImg.setAttribute('src', cRaiz + cImgCor);	
			if ( cInfo ) oImg.setAttribute('alt', cInfo); 
			oImg.id = id;
		}else{
			oImg = document.createElement("i");
			oImg.id = id;
			oImg.className = "fa fa-circle graph-captions " + cImgCor;
		}			
		//�������������������������������������������������������������������������
		//� informacao de help da legenda
		//�������������������������������������������������������������������������

		oCenter.appendChild(oImg);
		oColuna.appendChild(oCenter);
	},	
	getObjCols: function() {
		if(getObjectID(this.cNameTab) == null){
			return null;
		}else{
	    	this.aRows = getObjectID(this.cNameTab).getElementsByTagName('tbody')[0];
			return this.aRows;
		}
	},
	setEmptyCols: function() {
		var oTBody = this.getObjCols();
		var oTable = getObjectID(this.cNameTab);
		
		if (oTBody.rows.length>0) {
			for (var i=oTBody.rows.length; (i-1)>=0; i--) {
				oTBody.deleteRow(i-1);		
			}  
			oTBody.refresh;
			oTable.refresh;
		}
	},
	setEmptyDiv: function() {
		getObjectID(this.cConteiner).innerHTML 			= "";
		getObjectID(this.cConteiner).style.height		= "";
		var oRodape = getObjectID('Rodape'+this.cConteiner);
		$(oRodape).empty();
		this.__oo['___o'+this.cConteiner] 			= undefined;	
	},
	getNameTab: function() {
		return this.cNameTab;
	},
	setChkIte: function(x) {
		
		var nPos = -1;
		
		//se eu desmarquei o checkbox eu adiciono ele no array de desmarcados e removo ele dos marcados e vice versa
		if (!x.checked) {
			this.aColsUnCk.push(x.value);
			nPos = this.findIsMark(this.aColsCk,x.value);
			if (nPos != -1) this.aColsCk.splice(nPos,1);
		} else {
			this.aColsCk.push(x.value);
			var nPos = this.findIsMark(this.aColsUnCk,x.value);
			if (nPos != -1) this.aColsUnCk.splice(nPos,1);
		}	

	},
	setChkAll: function(x) {
		if (!this.lMostRod) {
			var oTable = $.fn.dataTable.tables("#"+$(x).closest('table')[0].id);
			oTable = $(oTable).dataTable();
			var allPages = oTable.$('tr');

			if ($(x).hasClass('allChecked')) {
				$(allPages).find('input[type="checkbox"]').prop('checked', false);
				for (var i=0; i<allPages.length; i++) {
					this.aColsUnCk.push($(allPages).find('input[type="checkbox"]')[i].value);
				}
				this.aColsCk.length = 0;
			} else {
				$(allPages).find('input[type="checkbox"]').prop('checked', true);
				for (var i=0; i<allPages.length; i++) {
					this.aColsCk.push($(allPages).find('input[type="checkbox"]')[i].value);
				}
				this.aColsUnCk.length = 0;
			}			
			$(x).toggleClass('allChecked');
		} else {	
		var nTam 	 = this.getObjCols().rows.length;
		var cNameCB	 = 'chkBox'+this.getNameTab() + '_';
		var lChk 	 = x.checked;
		var nQtdChk	 = document.getElementsByName(x.name).length;
		//�������������������������������������������������������������������������
		//� set checked para todos os objetos de mesmo nome
		//�������������������������������������������������������������������������		
		for (var i=0; i<nQtdChk; i++) {
			document.getElementsByName(x.name)[i].checked = lChk;
		}
		//�������������������������������������������������������������������������
		//� marca todos os itens da pagina
		//�������������������������������������������������������������������������		
		for (var i=0; i<nTam; i++) {
			if(isObject(getObjectID(cNameCB +( (this.nContLin + i ) +1) ))){
				getObjectID(cNameCB +( (this.nContLin + i ) +1) ).checked = lChk;
				// Adiciona ao array com o controle de checkagem				
				if (lChk) {
					this.aColsCk.push(getObjectID(cNameCB +( (this.nContLin + i ) +1) ).value);
				} else {
					this.aColsUnCk.push(getObjectID(cNameCB +( (this.nContLin + i ) +1) ).value);
				}
			}
		}


		//�������������������������������������������������������������������������
		//� se desmarcar o marca todos zera o controle de marcacao de linha
		//�������������������������������������������������������������������������		
		if (!lChk) {
					this.aColsCk.length = 0;
        	}else {
					this.aColsUnCk.length = 0;
        	}

	} //r7
	},
	findIsMark: function(aCols,cObjName) {
		var nPos  = -1;
		//�������������������������������������������������������������������������
		//� verifica se obj esta na matriz
		//�������������������������������������������������������������������������		
		for (var i=0; i<aCols.length; i++) {           
			if (aCols[i] == cObjName) {
				nPos = i;
				break;
			}	
		}
		return nPos;
	},
	findIdLinha: function(aCols) {
		var cValor = "";
		
		for (var i=0; i in aCols; i++) { 
			if (aCols[i].field == 'IDENLINHA') {
				cValor = aCols[i].value;
				break;
			}
		}	
		return cValor;
	},
	getDadCols: function(lUnCk) {
		var cResult = ''; 
		var nTam	= (lUnCk) ? this.aColsUnCk.length : this.aColsCk.length;
		
		if (lUnCk) {
			for (var i=0; i<nTam; i++) {           
				cResult += "'" + this.aColsUnCk[i] + ( ((i+1)<nTam) ? "'," : "' ")
			}
		} else {
			for (var i=0; i<nTam; i++) {           
				cResult += "'" + this.aColsCk[i] + (((i+1)<nTam) ? "'," : "' ")
			}
		}	
		return cResult;
	},			
	getChkAll: function() {
		return getObjectID("chkBox"+this.cConteiner+"CabAll").checked;
	},
	setLinhaCor: function(nLin,cCN,cCor) {
	    var cClassName 	= ( !wasDef( typeof(cCN) ) ) ? "colfixeInd" : cCN;
	    var cCorBG 		= ( !wasDef( typeof(cCN) ) ) ? "#D8E8FA" : cCor;

		getObjectID('Cont' + this.cConteiner + nLin).className 				= cClassName;
		getObjectID('Linha' + this.cConteiner + nLin).style.backgroundColor	= cCorBG;
	},
	setMarcaLinha: function(nLin) {
		var nPagina 	= getObjectID(this.cConteiner+'nPagina').value;
		var nRegPagina 	= this.nRegPagina;
		//�������������������������������������������������������������������������
		//� posiciona na linha
		//�������������������������������������������������������������������������
		getObjectID(this.cConteiner).scrollTop += ((nLin-1)*23);
		//�������������������������������������������������������������������������
		//� muda cor do da linha e idenficiador da linha
		//�������������������������������������������������������������������������
		nLin = ( (nRegPagina*nPagina) - nRegPagina ) + nLin;
		//�������������������������������������������������������������������������
		//� mudar a cor da linha
		//�������������������������������������������������������������������������
		this.setLinhaCor(nLin);   		
		
		var cFunc = 'gridData.definition.__oo.___o'+this.cConteiner+'.setDesmarcaLinha';   		
		var aMat = [ nLin,this.cConteiner ];
		setTimeout(function(){eval(cFunc)(aMat);}, 2000);
	},
	setDesmarcaLinha: function(aMat) {
		var nLin		= aMat[0];
		var cConteiner	= aMat[1];
		//�������������������������������������������������������������������������
		//� desmarca linha encontrada
		//�������������������������������������������������������������������������
		getObjectID('Cont' + cConteiner + nLin).className 				= "colfixe";
		getObjectID('Linha' + cConteiner + nLin).style.backgroundColor	= "#FFFFFF";
	},
	getPesquisaNaPagina: function(aCols,cFildPe,cDadPes,lPS) {
		var nLin 		= 0;
		var lPosScroll 	= ( !wasDef(typeof(lPS)) ) ? true : lPS;
		//�������������������������������������������������������������������������
		//� Procura na acols o conteudo a pesquisar
		//�������������������������������������������������������������������������
		for (var i=0; i in aCols; i++) {           
			if ( getColsField(aCols[i],cFildPe).indexOf(cDadPes) != -1 ) {
				if (lPosScroll) getObjectID(this.cConteiner).scrollTop = 0;
				nLin = (i+1);
				break;
		  	}
		} 
		return nLin;  
	}
});
/*/ 
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �navGridDat       � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Navegacao no grid first,prev,next,last								  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function navGridDat(cConteiner,cFunc,Target) {
	if(typeof eval(cFunc) == 'function') { 
		if (!getObjectID(cConteiner+Target).disabled) {
			
			var nQtdPag = parseInt(getObjectID(cConteiner+'nQtdPag').value);
			var oPag 	= getObjectID(cConteiner+'nPagina');
			var nPagina = parseInt(oPag.value);
			
			if(Target == 'pageNum') {
				var inputValue = parseInt(getObjectID(cConteiner+'pageNum').value);
				if ((inputValue <= 0) || (inputValue > nQtdPag) || (inputValue == null) || (inputValue == NaN)){
					nPagina = parseInt(oPag.value);
					alert('P�gina inexistente!');
					getObjectID(cConteiner+'pageNum').value = "";
				}
				else	
					nPagina = inputValue;
			}
			else{		
				switch (Target) {
					case 'first':    
						nPagina = 1;
						break;                                                                                                                                         
					case 'prev':
						if ( nPagina > 1 ) {	
							nPagina = nPagina - 1;
						}	
						break;                                                                                                                                         
					case 'next':    
						if ( nPagina < nQtdPag ) {	
							nPagina = nPagina + 1;
						}	
						break;                                                                                                                                         
					case 'last':    
						nPagina = nQtdPag;
						break;  				
				}
			}
			oPag.value = nPagina;
			numeroPaginaTemp = nPagina;	//	Salva P�gina corrente
			eval(cFunc)('0');
		}	
	}
}
/*/ 
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �navGridDatPageNum       � Autor � Karine Riquena    � Data � 29.04.2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Navegacao no grid first,prev,next,last								  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function navGridDatPageNum(cConteiner,cFunc,cInput) {
	if ((typeof eval(cFunc) == 'function') && (isObject(getObjectID(cInput)))) { 
	
			var nQtdPag = getObjectID(cConteiner+'nQtdPag').value;
			var oPag 	= getObjectID(cConteiner+'nPagina');
			var nPagina = getObjectID(cInput).value;
			
			if((nPagina > 0) && (nPagina <= nQtdPag) && (nPagina != "")){		
				oPag.value = nPagina;
				eval(cFunc)('0');
			}
			else{
				alert('P�gina inexistente');
			}
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �getGridCall      � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Navegacao no grid first,prev,next,last								  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function getGridCall(cConteiner,cFunc) {
	var result = '1';
	var oFunc = eval(cFunc);
	var cMatchFunc = oFunc.caller !== null ? oFunc.caller.toString().match(/function ([^\(]+)/) : null;
	if (oFunc.caller !== null &&  cMatchFunc !== null && cMatchFunc[1] === "navGridDat") {
		var result = '0';
	} else if ( isObject(getObjectID(cConteiner+'nPagina')) ) {
		getObjectID(cConteiner+'nPagina').value = 1;
	}
	return result;
}
/*/ 
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �setFxScroll     � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Scroll de tabela													  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function setFxScroll(cConteiner,id,cWidth,cHeight) {
	var table = getObjectID(id);
	var vHeaderAbs, vHeaderRel, hHeaderAbs, hHeaderRel,outRelDiv, midAbsinerDiv, inRelDiv, midAbsDivStyle;
	var lastScrollTop = NaN, lastScrollLeft = NaN, lastWidth = NaN, lastHeight = NaN;
	
	var testCellDim 		= null;
	var midRelinerDivStyle 	= null;
	var midRelinerDiv 		= null;
	var midAbsinerDivStyle 	= null;
	var tableDim 			= null;
	var vHeaderAbsStyle 	= null;
	var vHeaderRelStyle 	= null;
	var hHeaderAbsStyle 	= null;
	var hHeaderRelStyle 	= null;
	var inRelDivStyle 		= null;
	var outRelDivDim 		= null;
	var midAbsDiv 			= null;
	var parent 				= null;	

	var overrideStyles = {
		margin:[{keys:['margin','marginBottom','marginLeft','marginRight','marginTop'],value:'0px'}],
		padding:[{keys:['padding','paddingBottom','paddingLeft','paddingRight','paddingTop'],value:'0px'}],
		border:[
			{keys:['border','borderBottom','borderLeft','borderRight','borderTop'],value:'0px none #FFFFFF'},
			{keys:['borderWidth','borderLeftWidth','borderRightWidth','borderBottomWidth','borderTopWidth'],value:'0px'},
			{keys:['borderStyle','borderRightStyle','borderLeftStyle','borderBottomStyle','borderTopStyle'],value:'none'}
		],
		overflow:[{keys:['overflow'],value:'hidden'}],
		positionRel:[{keys:['position'],value:'relative'}],
		positionAbs:[{keys:['position'],value:'absolute'}],
		top:[{keys:['top'],value:'0px'}],
		left:[{keys:['left'],value:'0px'}],
		zIndex:[{keys:['zIndex'],value:2}]
	}	
	//�������������������������������������������������������������������������
	//� tratamento com px de obj
	//�������������������������������������������������������������������������
	function getSimpleExtPxIn(el) {
		var temp, temp2, tick = 0, getBorders = retFalse, doCompStyle = retFalse, defaultView, objList = [];

		function retFalse() {
			return false;
		}
		retFalse.elTest = retFalse;
		retFalse.iY 	= retFalse.iX = retFalse.y = retFalse.x = retFalse.w = retFalse.h = retFalse.bb = retFalse.bt = retFalse.bl = retFalse.br = 0;
		
		function gClientBorders(p, el) {
			if (el.clientWidth || el.clientHeight) {
				p.bb = (el.offsetHeight - (el.clientHeight + (p.bt = el.clientTop | 0))) | 0;
				p.br = (el.offsetWidth - (el.clientWidth + (p.bl = el.clientLeft | 0))) | 0;
			}
		}
		function getInterfaceObj(el) {
			var lastTick 	 = NaN;
			var offsetParent = getSimpleExtPxInFn(el.offsetParent) || retFalse;

			function p(doTick) {
				if (doTick) {
					tick = (1 + tick) % 0xEFFFFFFF;
				}
				if (tick != lastTick) {
					lastTick = tick;
					offsetParent();
					getBorders(p, el);
					p.iY = (p.y = (offsetParent.iY + (el.offsetTop | 0))) + p.bt;
					p.iX = (p.x = (offsetParent.iX + (el.offsetLeft | 0))) + p.bl;
					p.w = el.offsetWidth | 0;
					p.h = el.offsetHeight | 0;
				}
				return p;
			}
			p.elTest = function (elmnt) {
				return (elmnt == el);
			};
			p.iY = p.iX = p.w = p.h = p.y = p.x = p.bb = p.bt = p.bl = p.br = 0;
			return (objList[objList.length] = p);
		}
		function getSimpleExtPxInFn(el) {
			if ((!el) || (el == document)) {
				return retFalse;
			}
			for (var c = objList.length; c--;) {
				if (objList[c].elTest(el)) {
					return objList[c];
				}
			}
			return getInterfaceObj(el);
		}
		function setSpecialObj(el) {
			var lastTick = NaN;

			function p(doTick) {
				if (doTick) {
					tick = (1 + tick) % 0xEFFFFFFF;
				}
				return p;
			}
			p.elTest = function (elmnt) {
				return (elmnt == el);
			};
			p.iY = p.iX = p.w = p.h = p.y = p.x = p.bb = p.bt = p.bl = p.br = 0;
			objList[objList.length] = p;
		}
		if ((typeof el.offsetParent != 'undefined') && (typeof el.offsetTop == 'number') && (typeof el.offsetWidth == 'number')) {
		
			if ((typeof el.clientTop == 'number') && (typeof el.clientWidth == 'number')) {
				getBorders = gClientBorders;
			} else if ((defaultView = document.defaultView) && defaultView.getComputedStyle && (temp = defaultView.getComputedStyle(el, '')) && (((temp.getPropertyCSSValue) && (temp2 = temp.getPropertyCSSValue('border-top-width')) && (temp2.getFloatValue) && (doCompStyle = doComputedStyleFloat)) || ((temp.getPropertyValue) && (doCompStyle = doComputedStyleValue)))) {
				getBorders 	= gCompStyleBorders;
				temp2 		= temp = null;
			}
			if (document.documentElement) {
				setSpecialObj(document.documentElement);
			}
			if (document.body) {
				setSpecialObj(document.body);
			}
			return (getSimpleExtPxIn = getSimpleExtPxInFn)(el);
		} else {
			retThis.elTest 	= retFalse;
			retThis.iY 		= retThis.iX = retThis.y = retThis.x = retThis.w = retThis.h = retThis.bb = retThis.bt = retThis.bl = retThis.br = NaN;
			return (getSimpleExtPxIn = retThis);
		}
	}
	function setNameObj(oObj,name) {
		oObj.id = name;
		return true;
	}
	function remove(id) {
		var oObj = document.getElementById(id);
		return( oObj != null ) ? oObj.parentNode.removeChild(oObj) : false;
	}
	function setParent(cParent,oObj) {
		if (oObj.parentElement.id != cParent) {
			var oldParent = getObjectID(cParent);
			return( oldParent != null ) ? oldParent.appendChild(oObj) : false;
		} else { 
			return( true ); 
		}
	}
	//�������������������������������������������������������������������������
	//� css padrao dos objetos conforme definicao na matriz overrideStyles
	//�������������������������������������������������������������������������
	function setStyleProps(styleObj){
		var data, dArray;
		for(var c = 1;c < arguments.length;c++){
			if((data = overrideStyles[arguments[c]])){
				for(var d = data.length;d--;){
					dArray = data[d].keys;
					for(var e = dArray.length;e--;){
						styleObj[dArray[e]] = data[d].value;
					}
				}
			}
		}
		return true;
	}	
	//�������������������������������������������������������������������������
	//� posicionamento do obj onscroll
	//�������������������������������������������������������������������������
	function position(){
			var nh,nw,size,th,tw,cellWidth,celHeight,st = midAbsDiv.scrollTop, sl = midAbsDiv.scrollLeft, h = outRelDivDim(true).h, w = outRelDivDim.w;
			
			if((size = ((w != lastWidth)||(h != lastHeight)))||(st != lastScrollTop)||(sl != lastScrollLeft)){
			
				hHeaderRelStyle.left 	= (((cellWidth = (testCellDim().x - tableDim().iX)) + (lastScrollLeft = sl)) * -1)+'px';
				vHeaderRelStyle.top 	= (((celHeight = (testCellDim.y - tableDim.iY)) + (lastScrollTop = st)) * -1)+'px';
				
				if(size){
					vHeaderRelStyle.width 		= vHeaderAbsStyle.width = midAbsDivStyle.left = hHeaderAbsStyle.left = (cellWidth+'px');
					hHeaderRelStyle.height 		= hHeaderAbsStyle.height = midAbsDivStyle.top = vHeaderAbsStyle.top = (celHeight+'px');
					inRelDivStyle.left 			= (cellWidth * -1)+'px';
					inRelDivStyle.top 			= (celHeight * -1)+'px';
					midRelinerDivStyle.width 	= midAbsinerDivStyle.width = ((tw = tableDim.w) - cellWidth)+'px';
					midRelinerDivStyle.height 	= midAbsinerDivStyle.height = ((th = tableDim.h) - celHeight)+'px';
					midAbsDivStyle.height 		= vHeaderAbsStyle.height = (((nh = ((lastHeight = h) - celHeight)) > celHeight)?nh:celHeight)+'px';
					midAbsDivStyle.width 		= hHeaderAbsStyle.width = (((nw = ((lastWidth = w) - cellWidth)) > cellWidth)?nw:cellWidth)+'px';
					hHeaderRelStyle.width 		= inRelDivStyle.width = tw + 'px';
					vHeaderRelStyle.height 		= inRelDivStyle.height = th + 'px';
				}
			}
			return;
	}
	function onScroll(){
		position();
	}
	function initializeMe() {
		var newTable, testCell;
	};
	//�������������������������������������������������������������������������
	//� se a tabela existir 
	//�������������������������������������������������������������������������
	if(	table&& 
		(typeof table.scrollTop == 'number')&& 
		(typeof table.offsetHeight == 'number')&& 
		table.tagName&& 
		table.appendChild&& 
		table.cloneNode&& table.getAttribute&& 
		table.getElementsByTagName&& 
		(setParent(cConteiner,table))&&
		(parent = table.parentNode)&&	 
		parent.insertBefore ) {

		remove(cConteiner+'outRelDiv');	

		initializeMe();
	}
}
/*/ 
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    makeBrwResponsive       � Autor � Karine Riquena     � Data � 30.04.2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Fun��o para deixar a grid com layout responsivo e com fun�oes         ���
�� especiais como: ordena��o e pesquisa                                                ��
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/ 
function makeBrwResponsive(cTable, lOrder, lSearch, lPage, lInfo ){

	var oTable = getObjectID(cTable);
	$.fn.dataTable.moment( 'D/MM/YYYY' ); //formato de data para sortable na grid, verificar os formatos aceitos no plugin moment.js
	
	if (!wasDef( typeof(lPage) ) ){
		lPage=false;
	}
	if (!wasDef( typeof(lInfo) ) ){
		lInfo=false;
	}
	if ( ! $.fn.DataTable.isDataTable(oTable) ) {
  			$(oTable).dataTable( { 
					responsive: true,
					stateSave: true,
					"language": {
						"info": "P�gina _PAGE_ de _PAGES_",
						"infoFiltered": " - filtrado de _MAX_ registros",
						"infoEmpty": "Sem registros para exibir",
						"zeroRecords": "Nenhum registro encontrado",
						"lengthMenu": "Exibir _MENU_ registros",
						"search": "Pesquisar:",
						"lengthMenu": "Exibir _MENU_ registros",
						"search": "Pesquisar:",
						"paginate": {
				             "first": "Primeira",
							 "last":"Ultima",
							 "next": "Pr�xima",
							 "previous": "Anterior"
				         }
					},
					
					"columnDefs": [ {
						"targets": 'no-sort',
						"orderable": false,
					} ],
					  					
					"paging":   lPage, 
        			"ordering": lOrder,
					"info":     lInfo, //sempre false, pois utilizamos uma infobarbottom personalizada
					"searching": lSearch
			} );
		}
}
/*/ 
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �setStyle       � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Set css em um obj													  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function setStyle(el,val){
	if(el.style.setAttribute)
		 el.style.setAttribute("cssText", val );
	else el.setAttribute("style", val );
	return true;
}
/*/ 
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �getColsField    � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Retorna valor do field de uma linha do acols						  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function getColsField(aCols,cField) {
	var cConteudo = '';                      
	
	for (var i=0; i in aCols; i++) {
		if (aCols[i].field == cField) {
			cConteudo = aCols[i].value; 
			break;
		}	
	}  
	return cConteudo;
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �getGatCmp  	   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Gatilho																  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                              
function getGatCmp(cFunName, cCmpBas, aCmpCon, nTpRet, cVldGen) {
	var aCmpCon  = (aCmpCon == null) ? cCmpBas	: aCmpCon;
	var nTpRet   = (nTpRet  == null) ? 0 		: nTpRet;      
	var cVldGen  = (cVldGen == null) ? "" 		: cVldGen;
	
	var aFields = aCmpCon.split("|");     
	var cCmpCon = '';
	cCmpBasRef  = cCmpBas;                                                    
	//�������������������������������������������������������������������������
	//� Conteudo do campo
	//�������������������������������������������������������������������������
	if ( !isEmpty(cCmpBas) ) {
		for (var i = 0; i < aFields.length; i++) {
			cCmpCon += getField(aFields[i]);
		}                                  
	}
	//�������������������������������������������������������������������������
	//� Executa gatilho
	//�������������������������������������������������������������������������
    Ajax.open("W_PPLGATCMP.APW?cFunName=" + cFunName + "&cChave=" + cCmpCon + "&nTpRet=" + nTpRet + "&cVldGen=" + cVldGen , {
    		  callback: mostraGatCmp
    });
}
//�������������������������������������������������������������������������
//� Mostra gatilho
//�������������������������������������������������������������������������
function mostraGatCmp(v) {
    var aRet 		= v.split("%");
    var aResult 	= aRet[1].split("|");
    var aRetCC		= "";
    var cConteudo 	= "";
	//�������������������������������������������������������������������������
	//� Retorno com campo e conteudo
	//�������������������������������������������������������������������������
    for (var i = 0; i < aResult.length; i++) {
		//�������������������������������������������������������������������������
		//� pega o campo correspondente e conteudo
		//�������������������������������������������������������������������������
    	aRetCC = aResult[i].split("$");
		//�������������������������������������������������������������������������
		//� Verifica se o obj foi informado
		//�������������������������������������������������������������������������
    	if ( !isEmpty(aRetCC[0]) ) {
			//�������������������������������������������������������������������������
			//� Verifica se o obj exite
			//�������������������������������������������������������������������������
			if ( isObject(aRetCC[0]) ) {                                                   
				cConteudo = aRetCC[1].replace( /\?/, "" );
		    	setField( aRetCC[0], cConteudo );
		    } 
		}    
	}
	//�������������������������������������������������������������������������
	//� Se teve mensagem de erro
	//�������������������������������������������������������������������������
	if ( !isEmpty(aRet[0]) ) {             
		alert(aRet[0]);
		getObjectID(cCmpBasRef).value = '';
		getObjectID(cCmpBasRef).focus();
	}                         
	return;
}                                    
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �diferencaDias   � Autor � Alexander Santos	       � Data � 13.02.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Diferenca entre data em dias										  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                             
function diferencaDias(data1, data2, nDias) {
    dif = Date.UTC(data2.substr(6,4),data2.substr(3,2),data2.substr(0,2),0,0,0)-Date.UTC(data1.substr(6,4),data1.substr(3,2),data1.substr(0,2),0,0,0);    
    return Math.abs( ( dif / 1000 / 60 / 60 / 24) ) > (nDias+1);  
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �tabNav		   � Autor � Alexander Santos	       � Data � 20.12.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Class navegacao de folder											  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                             
var tabNav = {	
	init: function() {
		this.tabLinks	  = new Array();
		this.contentDivs  = new Array();
		  
		var tabListItems = document.getElementById('tabs').childNodes;		  
		for ( var i = 0; i < tabListItems.length; i++ ) {
		  
			if ( tabListItems[i].nodeName == "LI" ) {				
				var tabLink = tabNav.getFirstChildWithTagName( tabListItems[i], 'A' );
				var id 		= tabNav.getHash( tabLink.getAttribute('href') );
				
				tabNav.tabLinks[id] 	 = tabLink;
				tabNav.contentDivs[id] = document.getElementById( id );
			}			
		}
		var i = 0;
		for ( var id in tabNav.tabLinks ) {
		
			tabNav.tabLinks[id].onclick = tabNav.showTab;
			tabNav.tabLinks[id].onfocus = function() { this.blur() };
			
			if (i == 0) tabNav.tabLinks[id].className = 'selected';
			i++;
		}
		var i = 0;
		for ( var id in tabNav.contentDivs ) {
		
			if ( i != 0 ) tabNav.contentDivs[id].className =  'tabFC tab-pane fade'//'tabFC hide';
			i++;
			
		}
    },
	showTab: function() {
	
		var selectedId = tabNav.getHash( this.getAttribute('href') );

		for ( var id in tabNav.contentDivs ) {
			if ( id == selectedId ) {
				tabNav.tabLinks[id].className	   = 'selected';
				tabNav.contentDivs[id].className = 'tabFC tab-pane fade in active';
			} else {
				tabNav.tabLinks[id].className	   = '';
				tabNav.contentDivs[id].className = 'tabFC tab-pane fade';
			}
		}
		return false;
    },
	getFirstChildWithTagName: function(element, tagName) { 
	
		for ( var i = 0; i < element.childNodes.length; i++ ) {
			if ( element.childNodes[i].nodeName == tagName ) return element.childNodes[i];
		}
	  
    },
    getHash: function(url) {
		var hashPos = url.lastIndexOf('#');
		return url.substring(hashPos + 1);
    }
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �inProcesso	   � Autor � Alexander Santos	       � Data � 20.12.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Coloca o formulario em processamento por um tempo em segundos		  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                             
function inProcesso(nTime,cFExe) {
	var cF = eval(cFExe);
	
	if( typeof(cF) == 'function') {
		BloKeyEvent();
		ShowModal("","");        
		getObjectID('DivProc').style.display 	= 'block';
		document.body.style.cursor 				= 'wait';
		//��������������������������������������������������������������������������
		//� exectuta a primeira vez sem esperar o intervalo
		//��������������������������������������������������������������������������
		cF();
		//��������������������������������������������������������������������������
		//� cria o intervalo de execucao
		//��������������������������������������������������������������������������
	 	inPBlock = window.setInterval(cFExe+"()",(nTime*1000));
	}	
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �notInProcesso   � Autor � Alexander Santos	       � Data � 20.12.2012���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Retira o formulario de processamento conforme variavel private lFinish���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                             
function notInProcesso(v) {
	var aResult = v.split("|");
	var lFinish = eval(aResult[0]);
	var cFunJS  = eval(aResult[1]);

	if (lFinish) {
		DesKeyEvent();
		var xCont = getTC(getObjectID('ModalContainer'));
	
		if( isEmpty(xCont) ) HideModal();
	
		getObjectID('DivProc').style.display 	= 'none';
		document.body.style.cursor 				= 'default';
		
		window.clearInterval(inPBlock);
		//��������������������������������������������������������������������������
		//� se tem funcao para executar ao termino
		//��������������������������������������������������������������������������
		if (typeof(cFunJS) == 'function') {
			cFunJS();
		}
	}	
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �TotvsBioConf    � Autor � Vinicius Ledesma          � Data � 27.07.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Usada apenas para checar duas digitais armazenadas sem nova leitura    ��																  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                      
//������������������������������������������������������������������������Ŀ
//� Valiavel de controle						   �
//��������������������������������������������������������������������������
var appdevice = "";

function TotvsBioConf() {

	SetDebug();
	CallSetType();
	SetCbCapt();
	SetCbVer();
	CallSetVars();
	CallGetResult();
	SetCbError();
    
	var applet = document.getElementById('TotvsBioApp');
	
	appdevice = getdevice();
	
	if(appdevice != "") {
        document.totvsbioapp.TotvsBioStart();
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Call		   � Autor � Vinicius Ledesma 	   � Data � 28.07.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Novas Funcoes de Set para complemento do tratamento biometria	      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/                      
function CallSetVars() {
	document.totvsbioapp.VerifyMatchFpCb('SetVars');
}
function CallGetResult() {
    document.totvsbioapp.VerifyMatchCb('GetResult');
}
function CallSetType() {
    document.totvsbioapp.ConfigCb('SetType');
}

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Call		   � Autor � Everton M. Fernandes          � Data � 28.07.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Inicia o tratamento do grid											  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/   
function fGetDadGen(nRecno, cGrid, nOpc,lBotao,cSt,cValores, cCampoDefault,lBtnAtuVisible,lBtnDelVisible, lFromGrid, cFunPosExcl, cParPosExcl) {
	var lWS = true; //Esta vari�vel informa se dever� chamar o webservice para retornar os campos do grid
    var cCodPro  = "";
    var cCodPad  = "";
	var aSeqProc = {}; 
	var cSeqDel  = ""; 
	
	if(isDitacaoOffline() && isAlteraGuiaAut() && nOpc==5){
				
		if (typeof cOriMov != 'undefined' && cOriMov == "1" && aCodProc.indexOf(oGuiaOff.procedimentos[nRecno-1].cCodPro.defaultValue) >= 0) {
		
			alert("Esse procedimento n�o pode ser exclu�do pois � um procedimento originado do Atendimento");

		}else{

			if (wasDef( typeof(cSeqProc) ) ){
				aSeqProc = document.getElementById("cSeqProc").value.split('$');
				cSeqDel  = aSeqProc != "" ? aSeqProc[nRecno - 1] : "";
			}
			
			if (!wasDef( typeof(cValores) ) ){
				cValores=""
			}

			if (!wasDef( typeof(cCampoDefault) ) ){
				cCampoDefault=""
			}
			
			if (!wasDef( typeof(cSt) ) ){
				cSt="1"
			}
			
			if(nOpc==5){
				cCampoDefault =cCampoDefault.replace(/\|/g,',')
			}

			if (!wasDef( typeof(lBtnAtuVisible) ) ){
				lBtnAtuVisible="true"
			}

			if (!wasDef( typeof(lBtnDelVisible) ) ){
				lBtnDelVisible="true"
			}

			if (!wasDef( typeof(lFromGrid) ) ){
				lFromGrid="false"
			}

			if (!wasDef( typeof(cFunPosExcl) ) ){
				cFunPosExcl=""
			}

			if (!wasDef( typeof(cParPosExcl) ) ){
				cParPosExcl=""
			}

			if(nOpc == 5 && cGrid == "TabOutDesp"){
				objSubJson = getObjects(oProcOutDesp, "sequen",nRecno);
				if(objSubJson.length > 0){
					objSubJson = objSubJson[0];
					objSubJson.lDelIte = true;
					objSubJson.sequen = "";
					oProcOutDesp.procedimentos = oProcOutDesp.procedimentos.sort(function(a,b) {
						return ( (!a.lDelIte && b.lDelIte) ? -1 : (a.lDelIte && !b.lDelIte) ? 1 : 0 );
					});
					
					for(var i = 0;i<oProcOutDesp.procedimentos.length;i++){
						if(!oProcOutDesp.procedimentos[i].lDelIte){
							oProcOutDesp.procedimentos[i].sequen = (i+1).toString();
						}else{ break; }
					}
				}
			}
					
			//Se for exclus�o
			if(nOpc == 5){
				//Garante que o bot�o 'incluir' seja habilitado para inclus�o do pr�ximo item, caso o procedimento seja exclu�do enquanto estiver sendo alterado
				setDisable('bInc' + cGrid, false);
				
				if (isDitacaoOffline() && isAlteraGuiaAut()){
					if(typeof oGuiaOff != 'undefined'){
						objSubJson = getObjects(oGuiaOff, "sequen",nRecno);
						if(objSubJson.length > 0){
							objSubJson = objSubJson[0];
							objSubJson.lDelIte = true;
							objSubJson.sequen = "";
							oGuiaOff.procedimentos = oGuiaOff.procedimentos.sort(function(a,b) {
								return ( (!a.lDelIte && b.lDelIte) ? -1 : (a.lDelIte && !b.lDelIte) ? 1 : 0 );
							});
							
							//coloco os procedimentos deletados sempre no final do array e arrumo o sequencial
							for(var i = 0;i<oGuiaOff.procedimentos.length;i++){
								if(!oGuiaOff.procedimentos[i].lDelIte){
									oGuiaOff.procedimentos[i].sequen = (i+1).toString();
								}else{ break; }
							}
						}
					}else{
						for (var y = 0; y in oTabExeSer.aCols[nRecno-1]; y++) {
							if(oTabExeSer.aCols[nRecno-1][y].field == "cCodProSExe")
								cCodPro = oTabExeSer.aCols[nRecno-1][y].value;
							if(oTabExeSer.aCols[nRecno-1][y].field == "cCodPadSExe")
								cCodPad = oTabExeSer.aCols[nRecno-1][y].value;
						}
						  
						if(document.getElementById("cLstCmpAltServ") != undefined){

							if(document.getElementById("cLstCmpAltServ").value != "")
								document.getElementById("cLstCmpAltServ").value += "#";

								document.getElementById("cLstCmpAltServ").value += "cTpOperacaoOffline$E;";
								document.getElementById("cLstCmpAltServ").value += "cCodProOriginal$" + cCodPro + ";";
								document.getElementById("cLstCmpAltServ").value += "cCodPadOriginal$" + cCodPad + ";";
						}
					}
				}
			}
					
			if(typeof cTpPD == "undefined")
				cTpPD = ""; //se n�o existir a variavel eu crio (prorroga��o/internacao)

			if(nOpc==5){		
				if(cTpPD != ""){

					if(document.getElementById('cQtdDSol') != 'undefined'){

						for (var y = 0; y in oTabSolSer.aCols[nRecno-1]; y++) {
							if(oTabSolSer.aCols[nRecno-1][y].field == "cCodProSSol")
								cCodPro = oTabSolSer.aCols[nRecno-1][y].value;
							if(oTabSolSer.aCols[nRecno-1][y].field == "cQtdAutSSol")
								cQtdAut = oTabSolSer.aCols[nRecno-1][y].value;



						}

						fAtualizaDiaria("E", cQtdAut, "", "", "", cCodPro, 0);
					}
				}
			}
					
					
			if(lWS){
				//�������������������������������������������������������������������������
				//� Retorna os campos do grid e chama a fun��o de carregamento
				//�������������������������������������������������������������������������
				Ajax.open("W_PPLGETCMP.APW?cGrid=" + cGrid + "&nOpc=" + nOpc + "&nRecno=" + nRecno + "&lBotao=" + lBotao +"&cSt=" + cSt 
												   +"&cValores=" + cValores + "&cCampoDefault=" + cCampoDefault 
												   +"&lBtnAtuVisible=" + lBtnAtuVisible + "&lBtnDelVisible=" + lBtnDelVisible 
												   + "&lFromGrid=" +lFromGrid + "&cFunPosExcl=" + cFunPosExcl + "&cParPosExcl=" + cParPosExcl, {
							callback: carregaCmpGridGen, 
							error: exibeErro} );
			}
		}
	}else{
	
		if (wasDef( typeof(cSeqProc) ) ){
			aSeqProc = document.getElementById("cSeqProc").value.split('$');
			cSeqDel  = aSeqProc != "" ? aSeqProc[nRecno - 1] : "";
		}
	
		if (!wasDef( typeof(cValores) ) ){
			cValores=""
		}
	
		if (!wasDef( typeof(cCampoDefault) ) ){
			cCampoDefault=""
		}
	
		if (!wasDef( typeof(cSt) ) ){
			cSt="1"
		}
		
		if(nOpc==5){
			cCampoDefault =cCampoDefault.replace(/\|/g,',')
		}
		
		if (!wasDef( typeof(lBtnAtuVisible) ) ){
			lBtnAtuVisible="true"
		}
	
		if (!wasDef( typeof(lBtnDelVisible) ) ){
			lBtnDelVisible="true"
		}
		
		if (!wasDef( typeof(lFromGrid) ) ){
			lFromGrid="false"
		}
	
		if (!wasDef( typeof(cFunPosExcl) ) ){
			cFunPosExcl=""
		}
	
		if (!wasDef( typeof(cParPosExcl) ) ){
			cParPosExcl=""
		}

		//necess�rio para controlar corretamente o saldo de uma libera��o.
		if (typeof cSeqDel != "undefined" && cSeqDel != undefined && cSeqDel != "") { 

			document.getElementById("cSeqProc").value = "";

			for (var i = 0; i < aSeqProc.length; i++) {

				if (aSeqProc[i] != cSeqDel && aSeqProc[i] != "") {

					document.getElementById("cSeqProc").value += aSeqProc[i] + "$";
				}
			}
		}
		
		if(nOpc == 5 && cGrid == "TabOutDesp"){
			objSubJson = getObjects(oProcOutDesp, "sequen",nRecno);
			if(objSubJson.length > 0){
				objSubJson = objSubJson[0];
				objSubJson.lDelIte = true;
				objSubJson.sequen = "";
				oProcOutDesp.procedimentos = oProcOutDesp.procedimentos.sort(function(a,b) {
					return ( (!a.lDelIte && b.lDelIte) ? -1 : (a.lDelIte && !b.lDelIte) ? 1 : 0 );
				});
				
				for(var i = 0;i<oProcOutDesp.procedimentos.length;i++){
					if(!oProcOutDesp.procedimentos[i].lDelIte){
						oProcOutDesp.procedimentos[i].sequen = (i+1).toString();
					}else{ break; }
				}
			}
		}
	
		if(nOpc == 5 || nOpc == 4){
			if(cGrid == "TabExeSer" && isObject(getObjectID("cTp")) && getObjectID("cTp").value == "6" && typeof oTabExe != "string"){
				//verifico se tem algum executante no grid 
				//verifico se o codigo do procedimento ou da tabela foi alterado
				if(nOpc == 4)
					lDelExec = cProcChanged.codpad.defaultValue != cProcChanged.codpad.actualValue || cProcChanged.codpro.defaultValue != cProcChanged.codpro.actualValue
				else if(nOpc == 5)
					lDelExec = getValueByKey("nSeqRef", strZero1(nRecno, 3), oTabExe.aCols) != -1;
					
				if(lDelExec)
					modalBS("<i style='color:#639DD8;' class='fa fa-info-circle'></i>&nbsp;&nbsp;Observa��o", "<p>Os executantes vinculados a esse procedimento ser�o exclu�dos</p>", "@Fechar~closeModalBS();", "white~#84CCFF", "large");
			}
		}
	
		//Se for exclus�o
		if (nOpc == 5) {

			if (cFunPosExcl == "EXCLRECT") {
				ExcluiItensReceita();
			}

			//Garante que o bot�o 'incluir' seja habilitado para inclus�o do pr�ximo item, caso o procedimento seja exclu�do enquanto estiver sendo alterado
				
			setDisable('bInc' + cGrid, false);
			
			if (isDitacaoOffline() && isAlteraGuiaAut()){
				if(typeof oGuiaOff != 'undefined'){
					if(cGrid == "TabExe"){
						objSubJson = getObjects(oGuiaOff.executantes, "seqExe",nRecno);
						if(objSubJson.length > 0){
							objSubJson = objSubJson[0];
							objSubJson.lDelIte = true;
							objSubJson.seqExe = "";
							oGuiaOff.executantes = oGuiaOff.executantes.sort(function(a,b) {
								return ( (!a.lDelIte && b.lDelIte) ? -1 : (a.lDelIte && !b.lDelIte) ? 1 : 0 );
							});
							
							//coloco os procedimentos deletados sempre no final do array e arrumo o sequencial
							for(var i = 0;i<oGuiaOff.executantes.length;i++){
								if(!oGuiaOff.executantes[i].lDelIte){
									oGuiaOff.executantes[i].seqExe = (i+1).toString();
								}else{ break; }
							}
						}
					}else{
						objSubJson = getObjects(oGuiaOff, "sequen",nRecno);
						if(objSubJson.length > 0){
							objSubJson = objSubJson[0];
							objSubJson.lDelIte = true;
							objSubJson.sequen = "";
							oGuiaOff.procedimentos = oGuiaOff.procedimentos.sort(function(a,b) {
								return ( (!a.lDelIte && b.lDelIte) ? -1 : (a.lDelIte && !b.lDelIte) ? 1 : 0 );
							});
							
							//coloco os procedimentos deletados sempre no final do array e arrumo o sequencial
							for(var i = 0;i<oGuiaOff.procedimentos.length;i++){
								if(!oGuiaOff.procedimentos[i].lDelIte){
									oGuiaOff.procedimentos[i].sequen = (i+1).toString();
								}else{ break; }
							}
						}
					}
				}else{
					for (var y = 0; y in oTabExeSer.aCols[nRecno-1]; y++) {
						if(oTabExeSer.aCols[nRecno-1][y].field == "cCodProSExe")
							cCodPro = oTabExeSer.aCols[nRecno-1][y].value;
						if(oTabExeSer.aCols[nRecno-1][y].field == "cCodPadSExe")
							cCodPad = oTabExeSer.aCols[nRecno-1][y].value;
					}
					  
					if(document.getElementById("cLstCmpAltServ") != undefined){

						if(document.getElementById("cLstCmpAltServ").value != "")
							document.getElementById("cLstCmpAltServ").value += "#";

							document.getElementById("cLstCmpAltServ").value += "cTpOperacaoOffline$E;";
							document.getElementById("cLstCmpAltServ").value += "cCodProOriginal$" + cCodPro + ";";
							document.getElementById("cLstCmpAltServ").value += "cCodPadOriginal$" + cCodPad + ";";
					}
				}
			}
		}
	
		if(typeof cTpPD == "undefined")
			cTpPD = ""; //se n�o existir a variavel eu crio (prorroga��o/internacao)

		if(nOpc==5){		
			if(cTpPD != ""){

				if(document.getElementById('cQtdDSol') != 'undefined'){

					for (var y = 0; y in oTabSolSer.aCols[nRecno-1]; y++) {
						if(oTabSolSer.aCols[nRecno-1][y].field == "cCodProSSol")
							cCodPro = oTabSolSer.aCols[nRecno-1][y].value;
						if(oTabSolSer.aCols[nRecno-1][y].field == "cQtdAutSSol")
							cQtdAut = oTabSolSer.aCols[nRecno-1][y].value;



					}

					fAtualizaDiaria("E", cQtdAut, "", "", "", cCodPro, 0);
				}
			}
		}
	
		if(lWS){
			//�������������������������������������������������������������������������
			//� Retorna os campos do grid e chama a fun��o de carregamento
			//�������������������������������������������������������������������������
			Ajax.open("W_PPLGETCMP.APW?cGrid=" + cGrid + "&nOpc=" + nOpc + "&nRecno=" + nRecno + "&lBotao=" + lBotao +"&cSt=" + cSt 
											   +"&cValores=" + cValores + "&cCampoDefault=" + cCampoDefault 
											   +"&lBtnAtuVisible=" + lBtnAtuVisible + "&lBtnDelVisible=" + lBtnDelVisible 
											   + "&lFromGrid=" +lFromGrid + "&cFunPosExcl=" + cFunPosExcl + "&cParPosExcl=" + cParPosExcl + "&cSeqDelExec=" + ((lDelExec) ? strZero1(nRecno, 3) : '000') , {
						callback: carregaCmpGridGen, 
						error: exibeErro} );
		}
	}
}

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Call		   � Autor � Everton M. Fernandes          � Data � 28.07.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Recupera os valores da tela para colocar no Grid		 		      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/   
function carregaCmpGridGen(v) { 
	var aResult = v.split("|");
	var cGrid	= aResult[0];
	var nOpc	= aResult[1];

	var nRecno	= aResult[3];
	
	var lBotao = aResult[4];
	var cSt = aResult[5];
	var cValores = aResult[6];
	var cCampoDefault = aResult[7];

	//Guarda a string com os campos
	var aCmpAux =  aResult[2].replace("[","");
	aCmpAux =  aCmpAux.replace("]","");
	
	var lBtnAtuVisible = aResult[8];
	var lBtnDelVisible = aResult[9];
	var lFromGrid = aResult[11] == "true";
	var cFunPosExcl = aResult[12];
    var cParPosExcl = aResult[13];
	var cSeqDelExec = aResult[14];
	
	var cCampo = "";
	
	var aCmp = Array();
	//Carrega o array com os campos
	//Foi necess�rio esse while, pois o IE n�o aceita "eval"
	while(aCmpAux.length > 0){
		
		if(aCmpAux.indexOf(',')>-1){
			cCampo = aCmpAux.substring(0,aCmpAux.indexOf(','));
			aCmpAux = aCmpAux.substring(aCmpAux.indexOf(',')+1,aCmpAux.length);
		}else{
			cCampo = aCmpAux.substring(0,aCmpAux.length);
			aCmpAux = "";
		}
		
		aCmp.push(cCampo);
	}
	var nLen	= aCmp.length
	lDelExec = false;
	cProcChanged =  {"codpad": {"defaultValue":"","actualValue":""}, "codpro": {"defaultValue":"","actualValue":""}}; 
	if(cGrid == "TabExeSer" && isObject(getObjectID("cTp")) && getObjectID("cTp").value == "6"){
		$( "#cCodPadSExe" ).unbind( "blur", blurPadPro );
		$( "#cCodProSExe" ).unbind( "blur", blurPadPro );
	}
	//Carrega os valores que est�o nos campos para incluir na linha
	if(cValores == "" && nOpc!=6 && !lFromGrid){
		for (nI=0;nI<aCmp.length;nI++)
		{
			var e = document.getElementById(aCmp[nI]);
			
			if(e != null){
				//Verifica se � um combo ou um campo normal
				if($('input[name='+aCmp[nI]+']:checked').val() != undefined){
					var cTexto = trim($('input[name='+aCmp[nI]+']:checked').val());
					cValores += aCmp[nI] + "$" + cTexto + ";";
				} else if(e.options == undefined){
					cValores += aCmp[nI]+"$"+e.value + ";";
				}else{
					//sendo um combo insere "Codigo - Descri��o"
					var cCod = e.options[e.selectedIndex].value;
					var cTexto = e.options[e.selectedIndex].text;
					cValores += aCmp[nI]+ "$" + cCod + "*" + cTexto + ";";
				}
			}
		}
	}
	//Chama a Fun��o que monta a estrutura com os valores do grid
	Ajax.open("W_PPLGETGRID.APW?cGrid=" + cGrid + "&nOpc=" + nOpc + "&cCmp=" 
										+ ""  + "&cValores=" + cValores + "&nRecno=" + nRecno 
										+ "&lBotao=" + lBotao + "&cSt=" + cSt 
										+ "&lBtnAtuVisible=" + lBtnAtuVisible + "&lBtnDelVisible=" + lBtnDelVisible + "&cFunPosExcl=" + cFunPosExcl + "&cParPosExcl=" + cParPosExcl + "&cSeqDelExec="+ cSeqDelExec, {
										callback: carregaGridDatGen, 
										error: exibeErro} );

	//Carrega os inicializadores padr�o.
	if (nOpc!=6 && !lFromGrid){									
		fLimpaCmpGridGen(aCmp);
		if(cCampoDefault != ""){
			var aMatCamDef	 = cCampoDefault.split(",");
			var aMatCamDefAux = "";
			for (var y=0;y<aMatCamDef.length;y++) {
				aMatCamDefAux = aMatCamDef[y].split(";");
				if (aMatCamDefAux[1] != 'NIL'){              
					if (document.getElementById(aMatCamDefAux[0]) != null) {
						if (document.getElementById(aMatCamDefAux[1]) != null){
							document.getElementById(aMatCamDefAux[0]).value = document.getElementById(aMatCamDefAux[1]).value;
						//}else{ --NAO POSSO DEIXAR ESSE ELSE AQUI SENAO NO CAMPO APERECE aIniPar
						//	document.getElementById(aMatCamDefAux[0]).value = aMatCamDefAux[1];
						}
					}
				}
			}
		}
		
	}	                                  
	if (document.getElementById("bSave"+cGrid) != null){
		document.getElementById("bSave"+cGrid).disabled = true
	}
} 

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Call		   � Autor � Everton M. Fernandes          � Data � 28.07.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Limpa campos do grid                                                  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/   
function fLimpaCmpGridGen(aCmp,cIniPad) {    
	var nI = 0
	var cCampoDefault	 = cIniPad        
    
    for (nI=0;nI<aCmp.length;nI++)
	{
		if(typeof(aCmp[nI])=='string' && aCmp[nI] != "" ){
			if ( $('input[name='+aCmp[nI]+']:checked').val() == undefined ) {
				if (document.getElementById(aCmp[nI]).options != undefined) {
					//ComboBox
					var oObj = document.getElementById(aCmp[nI]);
					if ( $(document.getElementById(aCmp[nI])).hasClass("compSelect2"))
						$(oObj).select2().select2('val',oObj.options[0].value);
					else
						$(oObj).get(0).selectedIndex = 0;					
				} else {
					//TextBox
					document.getElementById(aCmp[nI]).value = "";
				}		
			}
		}else{
			aCmp[nI].value = "";
		}
	}
	//carrega inicializadores padroes
	if(cCampoDefault != null && cCampoDefault != "" ){
			var aMatCamDef	 = cCampoDefault.split(",");
			var aMatCamDefAux = "";
			for (var y=0;y<aMatCamDef.length;y++) {
				aMatCamDefAux = aMatCamDef[y].split(";");
				if (aMatCamDefAux[1] != 'NIL'){              
					if (document.getElementById(aMatCamDefAux[0]) != null) {
						if (document.getElementById(aMatCamDefAux[1]) != null){
							document.getElementById(aMatCamDefAux[0]).value = document.getElementById(aMatCamDefAux[1]).value;
						//}else{ -- NAO POSSO DEIXAR ESSE ELSE AQUI SENAO NO CAMPO APERECE aIniPar
						//	document.getElementById(aMatCamDefAux[0]).value = aMatCamDefAux[1];
						}
					}
				}
			}
	}
}

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Call		   � Autor � Everton M. Fernandes          � Data � 28.07.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Carrega o grid na p�gina				                              ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/   
function carregaGridDatGen(v) { 
	var aResult = v.split("|");
	var i = 0;
	//�������������������������������������������������������������������������
	//� Se existe registro define propriedades
	//�������������������������������������������������������������������������
	var nQtdReg		= aResult[0];  
	var nQtdPag 	= aResult[1];
	nRegPagina 		= aResult[2];
    var aHeader 	= eval(aResult[3]);
	var aCols 		= eval(aResult[4]);
	var cMsg 		= aResult[5];
    var lContinua	= eval(aResult[6]);
    var nPagAtual	= aResult[7];
    
    var lCSemafo	= eval(aResult[9]);
	var cGrid		= aResult[10];	
	var cOpc		= aResult[11];
	
	var lBotao		= aResult[13]
	var aLinhas		= aResult[15].split("&")
	var aBtnFunc	= ""
	var nI			= 0

    
    var lBtnAtuVisible = eval(aResult[16]);
	var lBtnDelVisible = eval(aResult[17]);
	var cCpoRelac 		= aResult[19];
	var cSeqDelExec = aResult[21];
	
	// essa parte foi feita para o relacionamento nos grids da montagem do layout generico 
	if(cCpoRelac != null && cCpoRelac != "" ){
		var e = document.getElementById(cCpoRelac); 
		var aCpoRelac 		= eval(aResult[20]);
		for (i; i < aCpoRelac.length; i++) {			
			//if (aProf.length>1 && aProf[1] != '')
			e.options[i] = new Option(aCpoRelac[i][1], aCpoRelac[i][0]);
		} 
	}else{
		cCpoRelac = fGetRelGrid(cGrid).split("~")[1];
		if ( cCpoRelac != "" && isObject( getObjectID(cCpoRelac) )){
			var e = getObjectID(cCpoRelac);
			$(e).empty().append('<option selected="SELECTED" value="SELECTED">-- Selecione um item --</option>');
		}
	}
	
	if (cOpc == '2'){
		
		for (nI=0;nI<aCmp.length;nI++)
		{
			document.getElementById(aCmp[nI]).value = aCols[0][nI];
		}
	
	}else{
			if (lBtnAtuVisible|| lBtnDelVisible)
			{				
				if (lBtnAtuVisible)
					aBtnFunc += "{info:'Alterar',img:'refresh.gif',funcao:'" + (eval(lBotao) ? "fVisRecGen" : "") + "'}";
					
				if (lBtnDelVisible)
				{
					if (lBtnAtuVisible) aBtnFunc +=  ",";	
					aBtnFunc += "{info:'Excluir',img:'004.gif',funcao:'" + (eval(lBotao) ? "fGetDadGen" : "") +"'}"
				}
				aBtnFunc = "[" + aBtnFunc + "]"; 
			}

			eval("o" + cGrid + "= new gridData(cGrid,'630','300')");
			//�������������������������������������������������������������������������
			//� Monta Browse 
			//�������������������������������������������������������������������������
			eval("o"+cGrid).load({	fFunName:'',
							nRegPagina:nRegPagina,
							nQtdReg:getField("nQtdReg"),
							nQtdPag:getField("nQtdPag"),
							lOverflow:true/*false*/,
							lShowLineNumber:true,
							lChkBox:false/*true*/,
							aBtnFunc:aBtnFunc,
							aHeader: aHeader,
							aCols: aCols,
							cColLeg:"",
							aCorLeg:"",
							cWidth:"770"});
						
	}
    for(nI=0;nI<aLinhas.length;nI++){
    	if (aLinhas[nI] != ""){
    		eval("o" + cGrid+".setLinhaCor("+ aLinhas[nI] +",'colfixeInd','#E49494')")
    	}
    }
		
	if(cSeqDelExec != "000" && cSeqDelExec != "" && cGrid == "TabExeSer" && isObject(getObjectID("cTp")) && getObjectID("cTp").value == "6"){
		 
		 if(typeof oGuiaOff != 'undefined'){
			seqRef = cSeqDelExec;
			 var oExec = $.grep( oGuiaOff.executantes, function( n, i ) {
					return n.nSeqRef.actualValue == seqRef;
			});
			 
			 for(var i=0; i<oExec.length;i++){
				oExec[i].lDelIte = true;
			 }
		 }
		 		 
		Ajax.open("W_PPLGRDEX.APW?cSeqDelExec=" + cSeqDelExec,  {
										callback: carregaGridDatGen, 
										error: exibeErro} );
	}
	
				
} 

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Call		   � Autor � Everton M. Fernandes          � Data � 28.07.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Carrega os valores da linha para os campos                  	      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/   
function fVisRecGen(nRecno,cGrid, nOpc) {    
   
	if (!wasDef( typeof(cTableR) ) ){
		var cTableR = cGrid
	}
	//Desabilita o bot�o incluir e habilita o bot�o salvar.
	setDisable("bInc" + cTableR, true);
	setDisable("bSave" + cTableR, false);
	
	Ajax.open("W_PPLVISGRID.APW?nRecno=" + nRecno + "&cGrid=" + cGrid + "&nOpc=" + nOpc, {
				callback: carregaCmpGen, 
				error: exibeErro} );
}

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Call		   � Autor � Everton M. Fernandes          � Data � 28.07.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Carrega os valores da linha para os campos                  	      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/   
function fValidRecGen(nRecno,cGrid, nOpc) {    
	Ajax.open("W_PPLVALID.APW?nRecno=" + nRecno + "&cGrid=" + cGrid + "&nOpc=" + nOpc, {
				callback: carregaCmpGen, 
				error: exibeErro} );
}

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Call		   � Autor � Everton M. Fernandes          � Data � 28.07.2011���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Recupera os valores da tela para colocar no Grid            	      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function carregaCmpGen(v) { 
	var aResult = v.split("|");
	//var cGrid	= aResult[0]
	//var nOpc	= aResult[1]
	var aCols	= eval(aResult[0])
	var nRecno	= aResult[1]
	var nLen	= aCols.length
	var cCmpRecno = aResult[2]
	var cBtn	= aResult[3]
	var nLen	=aCols.length - 1
	
	document.getElementById(cCmpRecno).value = nRecno;
	document.getElementById(cBtn).disabled = false;
	if(isDitacaoOffline() && isAlteraGuiaAut()){
		if (typeof cOriMov != "undefined" && cOriMov == "1"){
			if (aCodProc.indexOf(aCols[4].value) >= 0) {
				document.getElementById("cCodPadSExe").disabled = true;
				document.getElementById("cCodProSExe").disabled = true;
				document.getElementById("BcCodPadSExe").disabled = true;
				document.getElementById("BcCodProSExe").disabled = true;
			}
		}
	}
	for (nI=0;nI<nLen;nI++)
	{
	
		//Verifica se � um combo ou um campo normal
		if(document.getElementById(aCols[nI].field).options == undefined){
			document.getElementById(aCols[nI].field).value = aCols[nI].value;
		}else{
			//sendo um combo insere "Codigo - Descri��o"
			var cCod = aCols[nI].value.split("*")[0];
			
			if (cCod.match("markInv") !== null ){
				var aCod = cCod.split(">");
				cCod = aCod[aCod.length - 1];
			}
			//var cTexto = document.getElementById(aCmp[nI]).selectedOptions.item().text
			if ($(document.getElementById(aCols[nI].field)).hasClass("compSelect2")){
				var oObj = document.getElementById(aCols[nI].field);
				$(oObj).select2().select2('val',cCod);
			}
			
			document.getElementById(aCols[nI].field).value = cCod 
			//Para atualizar o CBOS e n�o deixar sem valor, como estava ocorrendo. Se PJ, n�o ocorre change, pois vem carregado. Se PF, d� change.
			if (isDitacaoOffline() && document.getElementById(aCols[nI].field).id == "cCbosExe" && document.getElementById(aCols[nI].field).value == "") {
				document.getElementById("cProExe").onchange();
			}
					
		}
		
		if(isObject(getObjectID("cTp")) && getObjectID("cTp").value == "6" && typeof oTabExe != "string"){
				if(aCols[nI].field == "cCodPadSExe"){
					cProcChanged.codpad.defaultValue = aCols[nI].value;
					cProcChanged.codpad.actualValue = aCols[nI].value;
					$("#cCodPadSExe").bind( "blur", blurPadPro );
				}else if(aCols[nI].field == "cCodProSExe"){
					cProcChanged.codpro.defaultValue = aCols[nI].value;
					cProcChanged.codpro.actualValue = aCols[nI].value;
					$( "#cCodProSExe" ).bind( "blur", blurPadPro );
				}
			}
		
	}
	
	//Atribuindo valores default para os campos
    _$Forminputs = $('form :input:not([type=submit][type=button])');
    for (var i = 0; i < _$Forminputs.length; i++) {
        $(_$Forminputs[i]).data('default', $(_$Forminputs[i]).val());
    }
	
} 

//������������������������������������������������������������������������
//� Checa Matricula
//������������������������������������������������������������������������
function validCmpGen(cValid,cCmp,cGatilho,cChvGat) {

	var lRet = true;
	
	if ( !isEmpty(cValid) )	 {
		lRet = eval(cValid);
		
	} 
	if(lRet){
		if ( !isEmpty(cGatilho) )	 {
			if (!isEmpty(document.getElementById(cCmp).value)){
				//getGatCmp(cFunName, cCmpBas, aCmpCon, nTpRet, cVldGen)
				return getGatCmp(cGatilho,cCmp,cChvGat,1);
			}
		}
	}else{
		return lRet;
	}
}	

//������������������������������������������������������������������������
//� inclui zeros a esquerda da string(numero)
//������������������������������������������������������������������������
function strZero(oObj, event, nLen) {
	var cStr = '';
	var cZeros = '';
	var nDif = 0;
	var nI = 0;
	
	cStr = oObj.value;
	
	nDif = nLen - cStr.length;
	
	for (nI=0;nI<nDif;nI++){
		cZeros += '0';
	}
	
	return cZeros+cStr;

}	

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Call		   � Autor � Thiago.ribas          � Data � 28.07.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Inicia o tratamento do grid											  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function fGetDGen(nRecno, cGrid, nOpc,lBotao,cSt,cValores, cCampoDefault, cMntSess, cLarBrw, cAltBrw, cUpdReg, cNoLimpa, cReadOnly, lReadOnly) {    
	cMntSess = typeof cMntSess !== 'undefined' ? cMntSess : "";
	cLarBrw = typeof cLarBrw !== 'undefined' ? cLarBrw : "630";
	cAltBrw = typeof cAltBrw !== 'undefined' ? cAltBrw : "300";
	cUpdReg = typeof cUpdReg !== 'undefined' ? cUpdReg : "1";
	
	if (cNoLimpa != undefined)
	{
		cCpNoLimpa = cNoLimpa;
	}
	else
	{
		cNoLimpa = cCpNoLimpa;
	}
	
	if (!wasDef( typeof(cValores) ) ){
		cValores=""
	}
	if (!wasDef( typeof(cCampoDefault) ) ){
		cCampoDefault=""
	}
	//�������������������������������������������������������������������������
	//� Retorna os campos do grid e chama a fun��o de carregamento
	//�������������������������������������������������������������������������
	Ajax.open("W_PPLGCMP.APW?cGrid=" + cGrid + "&nOpc=" + nOpc + "&nRecno=" + nRecno + "&lBotao=" + lBotao +"&cSt=" + cSt 
									   +"&cValores=" + cValores + "&cCampoDefault=" + cCampoDefault + "&cMontaSess=" + cMntSess
									   +"&cLarBrw=" + cLarBrw + "&cAltBrw=" + cAltBrw + "&cUpdReg=" + cUpdReg + "&cNoLimpa=" + 
									   cNoLimpa + "&cReadOnly=" + cReadOnly + "&lReadOnly=" + lReadOnly, {
				callback: carregaCGrid, 
				error: exibeErro} );
}

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Call		   � Autor � Thiago.Ribas         � Data � 28.07.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Recupera os valores da tela para colocar no Grid		 		      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/   
function carregaCGrid(v) { 
	var aResult = v.split("|");
	var cGrid	= aResult[0]
	var nOpc	= aResult[1]
	var aCmp	= eval(aResult[2])
	var nRecno	= aResult[3]
	var nLen	= aCmp.length
	var lBotao = aResult[4]
	var cSt = aResult[5]
	var cValores = aResult[6]
	var cCampoDefault = aResult[7]	
	var cLarBrw = aResult[8]
	var cAltBrw = aResult[9]
	var cUpdReg = aResult[10]
	var cNoLimpa = aResult[11]
	var cReadOnly = aResult[12]
	var lReadOnly = aResult[13]
	
	if(cValores == "" && nOpc!=6){
		for (nI=0;nI<aCmp.length;nI++)
		{
			cValores += aCmp[nI]+"$"+document.getElementById(aCmp[nI]).value.replace(",",".") + ",";
		}
	}
	//Chama a Fun��o que monta a estrutura com os valores do grid
	Ajax.open("W_PPLGGRID.APW?cGrid=" + cGrid + "&nOpc=" + nOpc + "&cCmp=" 
										+ aCmp.toString() + "&cValores=" + cValores + "&nRecno=" + nRecno 
										+ "&lBotao=" + lBotao + "&cSt=" + cSt +"&cValores=" + cValores
										+"&cLarBrw=" + cLarBrw +"&cAltBrw=" + cAltBrw +"&cUpdReg=" + cUpdReg, {
										callback: carregaGridDGen, 
										error: exibeErro} );

	if (nOpc!=6){									
		fLimpaCmpGGen(aCmp,cNoLimpa, cReadOnly, lReadOnly);
		if(cCampoDefault != ""){
			var aMatCamDef	 = cCampoDefault.split(",");
			var aMatCamDefAux = "";
			for (var y=0;y<aMatCamDef.length;y++) {
				aMatCamDefAux = aMatCamDef[y].split(";");
				if (aMatCamDefAux[1] != 'NIL'){
					document.getElementById(aMatCamDefAux[0]).value = aMatCamDefAux[1];
				}
			}
		}
		
	}	
	if (cUpdReg != "0"){
		document.getElementById("bSave"+cGrid).disabled = true
	}
} 

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Call		   � Autor � Thiago RIbas          � Data � 28.07.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Carrega o grid na p�gina				                              ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/   
function carregaGridDGen(v) { 
	var aResult = v.split("|");
	//�������������������������������������������������������������������������
	//� Se existe registro define propriedades
	//�������������������������������������������������������������������������
	var nQtdReg		= aResult[0];  
	var nQtdPag 	= aResult[1];
    var aHeader 	= eval(aResult[3]);
    var lContinua	= eval(aResult[6]);
    var cMsg 		= aResult[5];
    var nPagAtual	= aResult[7];
    //var aPesquisa	= aResult[9].split("&");
    var lCSemafo	= eval(aResult[9]);
	var cGrid		= aResult[10];	
	var cOpc		= aResult[11];
	//var aCmp		= eval(aResult[12]);
	var lBotao		= aResult[13]
	var aLinhas		= aResult[15].split("&")
	var cLarBrw = 	aResult[16]
	var cAltBrw = 	aResult[17]
	var cUpdReg = 	aResult[18]
	var aBtnFunc	= ""
	var nI			= 0

	nRegPagina 		= aResult[2]
    var aCols 		= eval(aResult[4]); 
	
	if (cOpc == '2'){
		
		for (nI=0;nI<aCmp.length;nI++)
		{
			document.getElementById(aCmp[nI]).value = aCols[0][nI];
		}
	
	}else{
			if(eval(lBotao)){
				if (cUpdReg != "0"){
					aBtnFunc = "[{info:'Alterar',img:'refresh.gif',funcao:'fVisRecGen'},{info:'Excluir',img:'004.gif',funcao:'fGetDGen'}]"
				}else{
					aBtnFunc = "[{info:'Excluir',img:'004.gif',funcao:'fGetDGen'}]"
				}
			}else{
			
				if (cUpdReg != "0"){
					aBtnFunc = "[{info:'Alterar',img:'refresh.gif',funcao:''},{info:'Excluir',img:'004.gif',funcao:''}]"
				}else{
					aBtnFunc = "[{info:'Excluir',img:'004.gif',funcao:''}]"

				}			
				
			}
		eval("o" + cGrid + "= new gridData(cGrid, '" + cLarBrw + "','" + cAltBrw + "')")
		//������������������������������������������������������������������������� 
		//� Monta Browse  eval("o" + cGrid + "= new gridData(cGrid, '630','300')")
		//�������������������������������������������������������������������������
		eval("o"+cGrid).load({	fFunName:'',
							nRegPagina:nRegPagina,
							nQtdReg:getField("nQtdReg"),
							nQtdPag:getField("nQtdPag"), 
							lOverflow:true/*false*/,
							lShowLineNumber:true,
							lChkBox:false/*true*/,
							aBtnFunc:aBtnFunc,
							aHeader: aHeader,
							aCols: aCols,
							cColLeg:"",
							aCorLeg:"",
							cWidth:cLarBrw});
	}
    for(nI=0;nI<aLinhas.length;nI++){
    	if (aLinhas[nI] != ""){
    		eval("o" + cGrid+".setLinhaCor("+ aLinhas[nI] +",'colfixeInd','#E49494')")
    	}
    }
				
} 

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Call		   � Autor � Thiago Ribas         � Data � 28.07.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Limpa campos do grid                                                  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/   
function fLimpaCmpGGen(aCmp, cNoLimpa, cReadOnly, lReadOnly) {    
	var nI = 0
	
	for (nI=0;nI<aCmp.length;nI++)
	{
		if (cNoLimpa.indexOf(aCmp[nI]) == -1)
		{
			document.getElementById(aCmp[nI]).value = "";
		}
		
		if (cNoLimpa.indexOf(aCmp[nI]+"&ReadOnly") != -1)
		{
			if (cNoLimpa.indexOf("=t") != -1)
			{
				document.getElementById(aCmp[nI]).readOnly = true;
			}
			else if (cNoLimpa.indexOf("=f") != -1)
			{
				document.getElementById(aCmp[nI]).readOnly = false;
			}
		}
	}
}

/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �whichButton          � Autor � Karine Riquena       � Data � 26.11.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Ajusta a div Context-Menu para mostrar ou esconder menu flutuante	  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
function whichButton(e, cCodMnu, action) {
		var e = e || window.event;
		var btnCode;
		var li;
		var menu = action == 'add' ? document.getElementById("context_menu_add") : document.getElementById("context_menu_del"); 

		if ('object' === typeof e) {
		btnCode = e.button;

			switch (btnCode) {
			   case 0:
				  esconder(action);
			   break;
			   case 2:
				  mostrar(e, action);
					menu.onmouseout = function(e){
							esconder(action);
					};
			   break;
			}
		}
		
		if(action == "add"){
			    li = document.getElementById("addata");
			    li.setAttribute("onclick", "AddAtalho('" + cCodMnu + "')");					
		}
		else{
			li = document.getElementById("delata");
		    li.setAttribute("onclick", "DelAtalho('" + cCodMnu + "')");
		}
}
/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Mostrar              � Autor � Karine Riquena       � Data � 26.11.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Mostrar a div context-menu              							  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
function mostrar(e, action){
    e = window.event || e;
	var menu = action == 'add' ? document.getElementById("context_menu_add") : document.getElementById("context_menu_del"); 
	
	var posx = e.clientX +window.pageXOffset - 10 +'px'; //Left Position of Mouse Pointer
    var posy = e.clientY + window.pageYOffset - 10 + 'px'; //Top Position of Mouse Pointer

	menu.style.position = 'absolute';
	menu.style.display = 'inline';
	menu.style.left = posx;
	menu.style.top = posy;
}
/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Esconder             � Autor � Karine Riquena       � Data � 26.11.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Esconder a div context-menu 								          ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/			
function esconder(action){
	setTimeout(function(){
		var menu = action == 'add' ? document.getElementById("context_menu_add") : document.getElementById("context_menu_del"); 
		menu.style.display = "none";
	}, 100);
}		
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    � DelAtalho		   � Autor � Karine Riquena        � Data � 27.11.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Deleta atalho do portal                          		 		      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/   
function DelAtalho(v) { 
	Ajax.open("W_PPLDELAT.APW?cCodMnu=" + v, {
										callback: ReloadPageWhenDel, 
										error: exibeErro} );

} 
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �Call		   � Autor �Karine Riquena                 � Data � 27.11.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Atualiza Pagina											 		      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function ReloadPageWhenDel(v) { 
	var arrayA = v.split("@");
	var obj = getObjectID("menu-shortcuts");
	var html = "";
	//A POSICAO 0 SEMPRE FICA VAZIA, POR ISSO I=1 
	if(arrayA.length > 1){
		if(isObject(obj)){
			obj.innerHTML = "";
			for(i=1; i< arrayA.length; i++){
				arrayA[i] = arrayA[i].split("|");
				html  = "<li id='" + arrayA[i][0] + "'>"
				html +=	"<a href='" + arrayA[i][4] + "' id='" + arrayA[i][0] + "' target=\"principal\" onmouseup=\"whichButton(event, this.id, 'del');\" oncontextmenu=\"event.preventDefault();\">"
				html +=	"<img src='" + arrayA[i][2] + "' title='" + arrayA[i][1] + "' class=\"atalhos-menu\">" + arrayA[i][1]
				html += "</a>"
				html +=	"</li>"	
				$(obj).append(html);
			}
		}
	}
	else{
		if(isObject(obj)){
			obj.innerHTML = "";
			html  = "<li id='noShortcut'>"
			html +=	"<a href='#'>"
			html +=	"Nenhum atalho a exibir"
			html += "</a>"
			html +=	"</li>"	
			$(obj).append(html);
		}
	}
} 
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    � AddAtalho		   � Autor � Karine Riquena        � Data � 02.12.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Adiciona atalho portal                          		 		      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/   
function AddAtalho(v) { 
     preenche_imagens(v);
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    � preenche_imagens � Autor � Karine Riquena        � Data � 02.12.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Preenche imagens da modal dialog popup              		 		  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/ 
function preenche_imagens(v){
			Ajax.open("W_PPLGETIMG.APW?cCodMnu=" + v, {
										callback: ajustaHtmlImagens, 
										error: exibeErro} );
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    � OpenPopup		   � Autor � Karine Riquena        � Data � 04.12.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Abre modal dialog popup                         		 		      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/ 
function openpopup(){
	var mask = parent.document.getElementById("mask");		
	var dialog = parent.document.getElementById("dialog");
	//centralizar a modal dialog popup
	$(dialog).css('margin-top',  0-$(dialog).height()/2);
    $(dialog).css('margin-left', 0-$(dialog).width()/2);
			$(mask).fadeIn(1000);	
			$(mask).fadeTo("slow",0.8);	
			$(dialog).fadeIn(2000);
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    � closepopup		   � Autor � Karine Riquena        � Data � 04.12.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Fecha modal dialog popup                   		 		              ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/ 	
function closepopup(){		
       var mask = parent.document.getElementById("mask");		
	   var dialog = parent.document.getElementById("dialog");
	   var title = parent.document.getElementById("titlePopup");
	   title = $(title).find("h3")[0];
	   title.textContent = "";
		$(mask).hide();
		$(dialog).hide();		
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �ajustaHtml          � Autor � Karine Riquena       � Data � 04.12.2014 ���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Monta html da popup de atalhos                  		 	          ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function ajustaHtmlImagens(v){	
    var aResult = v.split("|");
	var dialog = parent.document.getElementById("dialog");
	var popcontainer = parent.document.getElementById("popcontainer");
	var uploadComponent;
	var label;
	var codMnu;
	var tpPortal;
	var hiddenMnu;
	var hiddenImg = "<input type='hidden' value='0' id='camImg'/>";
	var urlImg;
	if(v.indexOf("Nofile") !=-1)
	{	        
	        codMnu = v.substring(6);
            hiddenMnu = "<input type='hidden' value='" + codMnu + "' id='codMnu'/>";	
		    popcontainer.style.width = "390px";
			popcontainer.style.width = "600px";
			popcontainer.style.height = "109px";
			label = "<div id='labelAta'><label class='TextoLabel'>N�o foram encontradas as imagens no diret�rio do servidor</label></div>"
			uploadComponent = "<div id='uploadImg'><label class='TextoLabel'>&nbsp;Coloque uma URL de imagem:</label><input type='text' id='urlImg' onchange = \"onChangeCamImg('txtbox');\" /><input type='button' id='BConfirmaAta' name='BConfirmaAta' value='Confirmar' class='button Botoes' onclick='GravaAtalho()'/></div>"
			popcontainer.innerHTML = "";
			popcontainer.innerHTML = hiddenMnu;
			$(popcontainer).append(label);	
			$(popcontainer).append(hiddenImg);			
			$(popcontainer).append(uploadComponent);
			openpopup();
	}
	else if(v == 'Nodirectory')
	{
			popcontainer.style.width = "390px";
			popcontainer.style.height = "90px";
			label = "<div id='labelAta'><label class='TextoLabel' style='font-size:15px !important;'>Erro! N�o foi encontrado o diret�rio do servidor!</label></div>"
			popcontainer.innerHTML = "";
			popcontainer.innerHTML = label;	
			openpopup();
	}
	else{
			codMnu = aResult[0];
			tpPortal = aResult[1];
			hiddenMnu = "<input type='hidden' value='" + codMnu + "' id='codMnu'/>"
	        popcontainer.style.width = "600px";
			popcontainer.style.height = "300px"
			var sizeArray = aResult.length;
			var div;
			var img;
			var radio;
			var caminho = tpPortal == 1 ? cPPrestador : cPEmpBenef;
			var divPai = document.createElement('div');
			label = "<div id='labelAta'><label class='TextoLabel'>Escolha uma imagem sugerida:</label></div>";
			uploadComponent = "<div id='uploadImg'><label class='TextoLabel'>&nbsp;Ou coloque uma URL de imagem:</label><input type='text' class='form-control' id='urlImg' onchange = \"onChangeCamImg('txtbox');\" /><button type='button' id='BConfirmaAta' name='BConfirmaAta' class='btn btn-default' onclick='GravaAtalho()'>confirmar</button></div>"
			popcontainer.innerHTML = "";
			popcontainer.innerHTML = hiddenMnu;
			$(popcontainer).append(hiddenImg);	
			$(popcontainer).append(label);
			divPai.setAttribute('id', 'containerImg');		
			aResult.splice(0, 2);
			aResult.splice(sizeArray-3, 1);
			for (var c in aResult) {
				div = document.createElement('div');
				div.className = "divImgs";  
				div.setAttribute('id', aResult[c]); 
				img = document.createElement('img');
				img.setAttribute('id', aResult[c]); 
				img.setAttribute('src', cRaiz + cAtalhos +  caminho + aResult[c]);
				img.className = "img-sug-ata";  
				img.innerHTML = aResult[c];
				radio = document.createElement("input"); 
				radio.className = "radioImgs";
				radio.setAttribute('type', 'radio');  
				radio.setAttribute('value', cRaiz + cAtalhos +  caminho + aResult[c]); 
				radio.setAttribute('name', 'selectImg'); 
				radio.setAttribute('id', 'radioImg'+[c]); 
				radio.setAttribute('onchange', 'onChangeCamImg(\'radio\')');
				div.appendChild(img);
				div.appendChild(radio);
				divPai.appendChild(div);
				popcontainer.appendChild(divPai);
			}
			
			$(popcontainer).append(uploadComponent);
			openpopup();
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �onChangeCamImg      � Autor � Karine Riquena       � Data � 05.12.2014 ���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � ALtera o hidden que contem o caminho do atalho que sera gravado       ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function onChangeCamImg(action){
	var valor;
	var radio = parent.document.getElementsByName("selectImg")[0];
	var urlImg = parent.document.getElementById("urlImg").value;
	//se via link
	if (action == 'txtbox'){
	     parent.document.getElementById("camImg").value = urlImg;
		//Verifico se existe radio na popup
		if (radio !== undefined){
			//se existe desmarco qualquer um que esteja marcado pois n�o pode ser informado Url e selecionar img sugerida tamb�m
			$("input:radio[name=selectImg]").attr("checked", false);
		}
	}
	//se via radio (imagem sugerida)
	else{
		//verifico se existe algo na url para limpar
		if(urlImg != "")
		{
			parent.document.getElementById("urlImg").value = "";
		}
	    //percorro cada radio button para atribuir o caminho da imagem para o que est� selecionado
		$("input:radio[name=selectImg]").each(function() {
						if ($(this).is(':checked'))
						{
								valor = $(this).val();
						}
					})
		parent.document.getElementById("camImg").value = valor;					
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �GravaAtalho		   � Autor � Karine Riquena        � Data � 05.12.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Grava o atalho no banco de dados                                      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/ 
function GravaAtalho(){
	var menu = parent.document.getElementById("codMnu").value;
	var camImg = $("#camImg");

    if(camImg.val() == 0)
	{
		alert('Informe a imagem!');
	}
	else{
		Ajax.open("W_PPLADDAT.APW?cCodMnu=" + menu + "&cCamImg=" + camImg.val(), {
										callback: reloadTopo, 
										error: exibeErro} );
	}    
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    reloadTopo		   � Autor � Karine Riquena        � Data � 05.12.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Recarrega o frame do topo para aparecer o novo atalho                 ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/ 
function reloadTopo(v){
	var obj = getObjectID("menu-shortcuts");
	var html = "";

		if(isObject(obj)){
				if(isObject(getObjectID("noShortcut")))
					obj.removeChild(getObjectID("noShortcut"));
				var arrayA = v.split("|");
				html  = "<li id='" + arrayA[0] + "'>"
				html +=	"<a href='" + arrayA[4] + "' id='" + arrayA[0] + "' target=\"principal\" onmouseup=\"whichButton(event, this.id, 'del');\" oncontextmenu=\"event.preventDefault();\">"
				html +=	"<img src='" + arrayA[2] + "' title='" + arrayA[1] + "' class=\"atalhos-menu\">&nbsp;&nbsp;&nbsp;" + arrayA[1]
				html += "</a>"
				html +=	"</li>"	
				$(obj).append(html);
		}
		else{ alert('N�o foi poss�vel adicionar o atalho!'); }	
	closepopup();
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    openNews		   � Autor � Karine Riquena            � Data � 17.12.2014���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Abre/fecha lista com as noticias disponiveis                          ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function openNews()
{
	var arrFrames = parent.document.getElementsByTagName("IFRAME");
	var element = arrFrames[1];
	var img = document.getElementById("shNews"); 
	 
	if ( element.style.display == "none" ){
		$(img).attr("src", cRaiz + 'hideNews.png');
		$(element).slideDown(500);	
	}
	else{
		$(img).attr("src", cRaiz + 'showNews.png');
        $(element).slideUp(500)	
	}

}

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    makeFrame		   � Autor � Karine Riquena            � Data � 16/01/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Monta IFRAME dentro da popup para chamar a .APH c/ o conteudo         ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function makeFrame(cName, cSrc, cScrolling, cFrameborder, cWidth, cHeight) {
   ifrm = document.createElement("IFRAME");
   ifrm.setAttribute("name", cName);
   ifrm.setAttribute("src", cSrc);
   ifrm.setAttribute("scrolling", cScrolling);
   ifrm.setAttribute("frameborder", cFrameborder);
   ifrm.style.width = cWidth+"px";
   ifrm.style.height = cHeight+"px";
   return ifrm;
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    dataAtualMaior	   � Autor � Karine Riquena        � Data � 22/01/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � N�o permite que a data informada seja maior que a data atual          ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function dataAtualMaior(oObj)
{
	   var data = oObj.value;
	   var lRet = true;
	   var d = new Date();
       var ano_atual = d.getFullYear();
       var mes_atual = d.getMonth() + 1;
       var dia_atual = d.getUTCDate();
	   var ano = 0;
	   var mes = 0;
	   var dia = 0;
	    var array_data = data.split("/") ;
		
		//formato dd/mm/aaaa
		if(array_data.length == 3){
			ano = parseInt(array_data[2]);
			mes = parseInt(array_data[1]);
			dia = parseInt(array_data[0]);
		}
		
		//formato mm/aaaa
		else if(array_data.length == 2){
			ano = parseInt(array_data[1]);
			mes = parseInt(array_data[0]);
			
			var myDate = new Date(ano, mes - 1, 1);
			lRet = !((myDate.getMonth() + 1 != mes) || (myDate.getFullYear() != ano))
		   if(!lRet){
					//Foi necess�rio usar desta forma pois o FIREFOX e o OPERA n�o suportam .focus()
					globalvar = oObj;
					setTimeout("globalvar.focus()",250);
					alert("Data invalida");
				return lRet
			}
		}
		lRet = !(ano > ano_atual || ((ano == ano_atual) && (mes > mes_atual || dia > dia_atual)))
		
		if(!lRet) {
	        //Foi necess�rio usar desta forma pois o FIREFOX tem um BUG que n�o suporta .focus()
			globalvar = oObj;
			setTimeout("globalvar.focus()",250);
	        alert('Informe uma data menor que a data atual');
	    }
		
		return lRet;
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    diffMesAno		   � Autor � Karine Riquena        � Data � 22/01/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Faz diferen�a entre a data atual e uma data qualquer informada        ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function diffMesAno(data) {
       var d = new Date();
       var ano_atual = d.getFullYear();
       var mes_atual = d.getMonth() + 1;
       var dia_atual = d.getUTCDate();
		
		var array_data = data.split("/") ;

        ano_aniversario = parseInt(array_data[2]);
        mes_aniversario = parseInt(array_data[1]);
        dia_aniversario = parseInt(array_data[0]);

        var quantos_anos = ano_atual - ano_aniversario;
		var quantos_meses = (quantos_anos * 12);
        quantos_meses -= mes_aniversario + 1;
        quantos_meses += mes_atual;
		quantos_meses = quantos_meses <= 0 ? 0 : quantos_meses % 12;
		
		if(dia_aniversario == dia_atual && mes_aniversario > mes_atual)
		      ++quantos_meses;
		else if((dia_aniversario == dia_atual && mes_aniversario == mes_atual) || (dia_aniversario < dia_atual && mes_aniversario == mes_atual))
			  quantos_meses = 0;
	    else if(dia_atual > dia_aniversario)
			 ++quantos_meses;

		
		if (mes_atual < mes_aniversario || mes_atual == mes_aniversario && dia_atual < dia_aniversario) {
			quantos_anos--;
		}
		
		var strMes = quantos_meses == 1 ? ' m�s' : ' meses';
		var strAno = quantos_anos == 1 ? ' ano' : ' anos';
		
		if(quantos_meses == 0 && quantos_anos == 0)
		    return '0 anos';
		else if(quantos_meses > 0 && quantos_anos > 0)
			return(quantos_anos.toString() + strAno + ' e ' + quantos_meses.toString() + strMes );
		else if(quantos_anos == 0)
			return quantos_meses.toString() + strMes;
		else if(quantos_meses == 0)
			return quantos_anos.toString() + strAno;
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    SomenteNumero		   � Autor � Karine Riquena        � Data � 23/01/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � N�o permite a entrada de caracteres diferentes de numero ONKEYPRESS   ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function SomenteNumero(e, separador, oObj){
	var lRet = true;
    var tecla=(window.event)?event.keyCode:e.which; 
	var teclaSep = 0
	
	if(separador !== undefined){
		if(separador == ",")
			teclaSep = 44;
		else if(separador == ".")
			teclaSep = 46;
	}
	
    if(!(tecla>47 && tecla<58)){
    	if (tecla==8 || tecla==0) 
			lRet = true;
		else if(teclaSep != 0 && ((separador == "," && teclaSep == tecla) || (separador == "." && teclaSep == tecla)))
			if(oObj.value.length > 0 && oObj.value.search(separador) == -1)
				lRet = true;
			else
				lRet = false;
		else  
			lRet =  false;
    }
	
	return lRet;
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    toggleDiv		   � Autor � Karine Riquena        		� Data � 23/01/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Esconde ou mostra Div                                                 ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function toggleDiv(idDiv){
	if(isObject(idDiv)){
		 var element = getObjectID(idDiv);

		if ( element.style.display == "none" )
			$(element).slideDown(400);
		else
			$(element).slideUp(400)
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    strZero1		   � Autor � Karine Riquena Limp       � Data � 16/06/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Completa string com zeros a esquerda                                  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function strZero1(number, length) {

    var my_string = '' + number;
    while (my_string.length < length) {
        my_string = '0' + my_string;
    }

    return my_string;
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    callSolAdt		   � Autor � Oscar Zanin   		� Data � 24/06/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Chama rotina que carrega RDA e chama modal bootstrap (sol. Aditivo)   ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function callSolAdt(){
	Ajax.open("W_PPLCBCDRDA.APW" , {
    		  callback: openSelectRdaC,
			  error: exibeErro
    });
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    loadSolConRda		   � Autor � Karine Riquena Limp   � Data � 24/06/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Chama rotina que carrega layout generico Alt Cad. RDA carregado       ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function loadSolConRda(){
	var cRDACod = document.getElementById("cRDACod").value;
	if (cRDACod == "SELECTED")
		alert("Selecione o credenciado!");
	else{
		window.frames[0].location="W_PPLSolCon.APW?cRDACod=" + cRDACod;//"//_PPLCADGEN.APW?cChave=PLSALTRDA&cRecno=" + cRecno;
		closeModalBS();
	}
}

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    openSelectRda		   � Autor � Karine Riquena Limp   � Data � 24/06/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Abre popup para selecionar a RDA desejada                             ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function openSelectRda(v){
	if (trim(v.split("|")[0]) == 'REDIRECIONAR'){
		var cRecno = trim(v.split("|")[1]);
		window.frames[0].location="W_PPLCADGEN.APW?cChave=PLSALTRDA&cRecno=" + cRecno;
	}else{	
		var aParams = v.split("|");
		var cTitle = aParams[0];
		var cContainer = aParams[1];
		var aBotoes = aParams[2];
		modalBS(cTitle, cContainer, aBotoes);
	}
}

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    openSelectRdaC		   � Autor � Karine Riquena Limp   � Data � 24/06/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Abre popup para selecionar a RDA desejada                             ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function openSelectRdaC(v) {

    if (trim(v.split("|")[0]) == 'REDIRECIONAR') {
        var cRDACod = trim(v.split("|")[1]);
        var cLocation = "W_PPLSolCon.APW?cRDACod=" + cRDACod;
        if (window.frames[0] == undefined) {
            window.frames.location = cLocation;
        } else {
            window.frames[0].location = cLocation;
        }
    } else {
        var aParams = v.split("|");
        var cTitle = aParams[0];
        var cContainer = aParams[1];
        var aBotoes = aParams[2];
        modalBS(cTitle, cContainer, aBotoes);
    }
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    modalBS    		   � Autor � Karine Riquena Limp   � Data � 24/06/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Monta e exibe popup bootstrap                                         ���
��������������������������������������������������������������������������������������ٱ�
cTitle = titulo da popup
cContainer = conteudo da popup em HTML
aBotoes = botoes da popup, formato esperado, exemplo: "@Confirmar~funcao();@Cancelar~funcao;"
cHeaderColor = cor da fonte e do header do popup, formato esperado, exemplo: 'white~green' obs: pode ser em hexadecimal tbm a cor
cfontSize = tamanho da fonte exibida no conteudo
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function modalBS(cTitle, cContainer, aBotoes, cHeaderColor, cfontSize, cExibeCloseModal, oObjIframe){
	var oBtn;
	var cFunc;
	var textNode;
	
	if(cExibeCloseModal == undefined)
       cExibeCloseModal = "S";
	if (!(aBotoes === undefined)){
		aBotoes = aBotoes.split("@");
		aBotoes.shift();
	} 
	var oHeader = document.getElementById("modal-header") != null ? document.getElementById("modal-header") : parent.document.getElementById("modal-header");
	var oTitle = document.getElementById("modal-title") != null ? document.getElementById("modal-title") : parent.document.getElementById("modal-title");
	var oBody = document.getElementById("modal-body") != null ? document.getElementById("modal-body") : parent.document.getElementById("modal-body");
	var oFooter = document.getElementById("modal-footer") != null ? document.getElementById("modal-footer") : parent.document.getElementById("modal-footer");
	var oCloseModal = document.getElementById("closeModal") != null ? document.getElementById("closeModal") : parent.document.getElementById("closeModal");

	if (oTitle == null || oBody == null ){
		//Se n�o tem a div criada, criamos ela aqui
		document.body.innerHTML += '<div class="modal fade" id="modalBS" role="dialog" data-backdrop="static" data-keyboard="false"><div class="modal-dialog" id="modal-dialog"><!-- Modal content--><div class="modal-content" id="modal-content"><div class="modal-header" id="modal-header"><button type="button" class="close" id="closeModal" data-dismiss="modal">&times;</button><h4 class="modal-title" id="modal-title"></h4></div><div class="modal-body" id="modal-body"></div><div class="modal-footer" id="modal-footer"></div></div></div></div>';
		var oHeader = document.getElementById("modal-header") != null ? document.getElementById("modal-header") : parent.document.getElementById("modal-header");
		var oTitle = document.getElementById("modal-title") != null ? document.getElementById("modal-title") : parent.document.getElementById("modal-title");
		var oBody = document.getElementById("modal-body") != null ? document.getElementById("modal-body") : parent.document.getElementById("modal-body");
		var oFooter = document.getElementById("modal-footer") != null ? document.getElementById("modal-footer") : parent.document.getElementById("modal-footer");
		var oCloseModal = document.getElementById("closeModal") != null ? document.getElementById("closeModal") : parent.document.getElementById("closeModal");
	}
	oTitle.innerHTML = "";
	oBody.innerHTML = "";
	oFooter.innerHTML = "";
	$( oTitle ).html( cTitle );
	 if(oObjIframe !== undefined){
		oBody.appendChild(oObjIframe);
		parent.iFrameResize({
				log                     : false,                  // Enable console logging
				enablePublicMethods     : true,                  // Enable methods within iframe hosted page
				enableInPageLinks       : true
		});
	 }else{
		$( oBody ).html( cContainer );
		if (!(aBotoes === undefined)){
			for (var i=0;i<aBotoes.length;i++){
					oBtn = document.createElement("button");        // Create a <button> element
					oBtn.setAttribute('type', 'button');
					oBtn.className = 'btn btn-default';
					textNode = document.createTextNode(aBotoes[i].split('~')[0].trim());       // Create a text node
					oBtn.appendChild(textNode);           
					cFunc = aBotoes[i].split('~')[1].trim();
					oBtn.setAttribute('onclick',cFunc);	
					oFooter.appendChild(oBtn);
			}
		}
	}
    if(cExibeCloseModal == 'N'){
       $(oCloseModal).css({
	      'display':'none'
       });
    }
	else
	{
		 $(oCloseModal).css({ 
		     'display':'block'
	     });
		 
		if (oCloseModal.onclick == null)
		{
			oCloseModal.onclick = 'closeModalBSZ()';
		}
	}
	if (!(cHeaderColor === undefined) && cHeaderColor != ""){
		cHeaderColor = cHeaderColor.split("~");
		if (cHeaderColor.length > 1){
			$(oTitle).css({
				'color':cHeaderColor[0]		
			});
			$(oHeader).css({
				'background-color':cHeaderColor[1],
		        'border-top-left-radius': '5px',
                'border-top-right-radius': '5px'
			});
		}
	}else{
		$(oTitle).css({
				'color':'#000000'		
			});
		
		$(oHeader).css({
				'background-color':'#ffffff',
		        'border-top-left-radius': '5px',
                'border-top-right-radius': '5px'
		});
	} 
	
	if (!(cfontSize === undefined) && cfontSize != ""){
		$(oBody).css({
			'font-size':cfontSize
		});
	}
	
	var oModalBS = document.getElementById("modalBS") != null ? document.getElementById("modalBS") : parent.document.getElementById("modalBS");
	
	var bodyMaster =document.querySelector('.pageMaster') != null ? document.querySelector('.pageMaster') : parent.document.querySelector('.pageMaster');
	//classe que desabilita o scroll da tela principal da modal
	$(bodyMaster).addClass( "modal-open" );
	
	$(oModalBS).modal('show');
	
	oBody.style.maxHeight = ($(oModalBS).height() -10)+'px';
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    closeModalBS  	   � Autor � Karine Riquena Limp   � Data � 24/06/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Fecha modal                                                           ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function closeModalBS(){
	var oCloseModal = document.getElementById("closeModal") != null ? document.getElementById("closeModal") : parent.document.getElementById("closeModal");
	//retiro a classe que desabilita o scroll da tela principal da modal
	var bodyMaster = document.querySelector('.pageMaster') != null ? document.querySelector('.pageMaster') : parent.document.querySelector('.pageMaster');
	//classe que desabilita o scroll da tela principal da modal
	$(bodyMaster).removeClass( "modal-open" );
	$(bodyMaster).addClass( "modal-closed" );
	$(oCloseModal).click();
}


/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    callAltCad		   � Autor � Karine Riquena Limp   � Data � 24/06/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Chama rotina que carrega RDA e chama modal bootstrap                  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function callAltCad(){
	Ajax.open("W_PPLVIEWRDA.APW" , {
    		  callback: fopenSelectRda,
			  error: exibeErro
    });
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    loadAltCadRda		   � Autor � Karine Riquena Limp   � Data � 24/06/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Chama rotina que carrega layout generico Alt Cad. RDA carregado       ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function loadAltCadRda(){
    var valor = trim(document.getElementById("cRdaRec").value);
	var cRecno = valor.substr(0,(valor.length-1)); 
	var tipPes = valor.substr((valor.length-1));
	if (cRecno == "SELECTED")
		alert("Selecione o credenciado!");
	else{
		if (tipPes == 'F')
			window.frames[0].location="W_PPLCADGEN.APW?cChave=PLSALTRDAF&cRecno=" + cRecno;
		else
			window.frames[0].location="W_PPLCADGEN.APW?cChave=PLSALTRDAJ&cRecno=" + cRecno;
		closeModalBS();
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    fopenSelectRda  	   � Autor � Karine Riquena Limp   � Data � 24/06/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Abre popup para selecionar a RDA desejada                             ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function fopenSelectRda(v){
	if (trim(v.split("|")[0]) == 'REDIRECIONAR'){
		var cRecno = trim(v.split("|")[1]);
		var cTp	   = trim(v.split("|")[2]);
		if (cTp != "J" && cTp != "F")
			cTp = "F";
		window.frames[0].location="W_PPLCADGEN.APW?cChave=PLSALTRDA" + cTp + "&cRecno=" + cRecno;
	}else{	
		var aParams = v.split("|");
		var cTitle = aParams[0];
		var cContainer = aParams[1];
		var aBotoes = aParams[2];	
		modalBS(cTitle, cContainer, aBotoes);
	}
}

/*Verifica se o usu�rio j� n�o possuem um protocolo em aberto*/
function ValUsu(){
	Ajax.open("W_PPLVERPRO.APW", { callback: alertPend, error: exibeErro});
}
function alertPend(v){
   var cRetorno = v.split("|")
   if (cRetorno[0] == "S")
       alert("Existe um protocolo de altera��o pendente para a fam�lia do benefici�rio.")
}

function chamaRelAltBenef(cRecno){
    setDisable('bconfirma',true);
	setDisable('bconfirmanovo',true);
    $('form :input').prop('disabled', true);
    $('.infoBarBottom :input').prop('disabled', false);
    $('form table').prop('class', $('form table').prop('class') + ' disabled');
    $('form table img').attr('onclick', 'return false');
    closeModalBS();
    ChamaPoP('W_PPLRELGEN.APW?cFunName=PLSIMPBEN&cRecno=' + cRecno,'bol','yes',0,925,605);
}

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    CarregaCidSel  	   � Autor � Roberto Arruda        � Data � 22/07/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Carrega combo de cidades atrav�s da UF                                  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function carregaCidSel(cValorUF, cCampoCID, cValorSelMun){
	document.getElementById(cCampoCID).options.length = 0;
	Ajax.open("W_PPLGETMUN.APW?cCod=" + cValorUF + "&cCampoCID=" + cCampoCID + "~" + cValorSelMun , { callback: comboCidSel, error: exibeErro});
}

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    comboCid  	   � Autor � F�bio S. dos Santos   � Data � 22/07/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Carrega combo de cidades atrav�s da UF - Retorno AJAX                 ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function comboCidSel(v){
	var aResult2 = v.split("|");

	var cCampoMun = aResult2[1].split("~")[0];
	var cValorMun = aResult2[1].split("~")[1]; 

	var e 		 	= getObjectID(cCampoMun);
	
	if (aResult2[0] == "ZERO"){
		alert(aResult2[1]);
	}else{
	
		var aArr 	= aResult2[0].split("~");
		
		var xCols = "["
		
		for(var i = 0;i<aArr.length;i++){
			xCols += '{';
			xCols +=  '1:{field:"cDescri",value:"' + aArr[i] + '"' + ' }'; //tive que fazer isso porque estava dando problema com cidade que tem ap�strofe no nome Ex: Santa B�rbara D'Oeste
			xCols += ( (aArr.length-1) != i ) ?'},' : '}]';
		}
		
	    var aCols2 	= eval(xCols);
		var nqtdTip2 = aCols2.length;	
		var nI;
	    var aDadCid = new Array(nqtdTip2);
		//var oObj = document.getElementById("cB9V_CODCID");
		var oObj = document.getElementById(cCampoMun);
        
		for (nI=0; nI < nqtdTip2; nI++)
			aDadCid[nI] = aCols2[nI][1].value;
	 
		
		//comboLoad("cB9V_CODCID",aDadCid);
		comboLoad(cCampoMun,aDadCid,undefined,undefined,cValorMun);

		//oObj.selectedIndex = 2;//cValorMun;
		//oObj.text = "111";
		//$("#"+cCampoMun+" option:contains('"+cValorMun+"')").attr('selected',true);
	}
}

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    CarregaCid  	   � Autor � F�bio S. dos Santos   � Data � 22/07/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Carrega combo de cidades atrav�s da UF                                ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function carregaCid(cCampoUF, cCampoCID){
	var cCodUf = document.getElementById(cCampoUF).value;
	
	document.getElementById(cCampoCID).options.length = 0;
	Ajax.open("W_PPLGETMUN.APW?cCod=" + cCodUf + "&cCampoCID=" + cCampoCID , { callback: comboCid, error: exibeErro});
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    comboCid  	   � Autor � F�bio S. dos Santos   � Data � 22/07/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Carrega combo de cidades atrav�s da UF - Retorno AJAX                 ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function comboCid(v){
	var aResult2 = v.split("|");
	
	if (aResult2[0] == "ZERO"){
		alert(aResult2[1]);
	}else{
	
		var aArr 	= aResult2[0].split("~");
		
		var xCols = "["
		
		for(var i = 0;i<aArr.length;i++){
			xCols += '{';
			xCols +=  '1:{field:"cDescri",value:"' + aArr[i] + '"' + ' }'; //tive que fazer isso porque estava dando problema com cidade que tem ap�strofe no nome Ex: Santa B�rbara D'Oeste
			xCols += ( (aArr.length-1) != i ) ?'},' : '}]';
		}
		
	    var aCols2 	= eval(xCols);
		var nqtdTip2 = aCols2.length;	
		var nI;
	    var aDadCid = new Array(nqtdTip2);
		//var oObj = document.getElementById("cB9V_CODCID");
		var oObj = document.getElementById(aResult2[1]);
        
		for (nI=0; nI < nqtdTip2; nI++)
			aDadCid[nI] = aCols2[nI][1].value;
	 
		
		//comboLoad("cB9V_CODCID",aDadCid);
		comboLoad(aResult2[1],aDadCid);
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    CarregaEndCEP  	   � Autor � Roberto Vanderlei   � Data �   16/11/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Carrega Endereco a partir do CEP                                      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function carregaEndCep(cCampoCEP, cCampoEndereco, cCampoBairro, cCampoCodMunicipio, cCampoMunicipio, cCampoEstado){
	var cCEP = document.getElementById(cCampoCEP).value;
	Ajax.open("W_PPLGETCEN.APW?cCep=" + cCEP + "&cCampoEndereco=" + cCampoEndereco + "&cCampoBairro=" + cCampoBairro + "&cCampoCodMunicipio=" + cCampoCodMunicipio + "&cCampoEstado=" + cCampoEstado, { callback: CarregaCmpo, error: exibeErro});
}

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    CarregaCmpo  	   � Autor � F�bio S. dos Santos   � Data � 16/11/2015    ���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Campos de endere�o do CEP da Manuten��o Benefici�rios  - Retorno AJAX ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function CarregaCmpo(v){
	var aResult1;
	var aValores;
	var aCampos;
  var nI;
  var comboCidades;
  var oPt1;
  if ((v != null) && (v.length > 0)){
		aResult1 = v.split("~");
		aValores = aResult1[0].split("|");
		aCampos  = aResult1[1].split("|");
  	for (nI=0; nI < aValores.length; nI++){
			if (aValores[nI] == null){
				aValores[nI] = ""
			}
			if (aCampos[nI] == "cB2N_CODMUN"){
				comboCidades = document.getElementById(aCampos[nI]);
				if (comboCidades != 'undefined'){
					for (i = 0; i < comboCidades.length; i++) {
						comboCidades.remove(0);
					}
				}
				//	opt0 = document.createElement("option");
				//	opt0.value = "";
				//	opt0.text  = "-- Selecione um Item --";
				//	comboCidades.add(opt0, comboCidades.options[0]);
				opt1 = document.createElement("option");
				opt1.value = aValores[nI].split("?")[0].trim();
				opt1.text  = aValores[nI].split("?")[1];
				comboCidades.add(opt1, comboCidades.options[comboCidades.length]);
				document.getElementById(aCampos[nI]).value = aValores[nI].split("?")[0].trim();
			}else{ 
				document.getElementById(aCampos[nI]).value = aValores[nI].trim();
			}
		}
	}
}

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    CarregaDadBen  	   � Autor � Roberto Vanderlei   � Data �   16/11/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Carrega Dados Ben. a partir do CPF                                      ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function CarregaDadBen(cCampoCPF){
    var lBusca = true;
    if(document.getElementById(cCampoCPF).value.length == 11)
        lBusca = validarCPF(document.getElementById("cB2N_CPFUSR"),"C.P.F inv�lido")
    else
        lBusca = validarCNPJ(document.getElementById("cB2N_CPFUSR"),"C.N.P.J inv�lido")
    if (lBusca){
       /*Preenchido em variaveis, pois futuramente pode haver a necessidade de reutilizar esse m�todo para outros layouts gen�ricos.*/
    	var cCPF = document.getElementById(cCampoCPF).value;
    	var cCmpNome         = "cB2N_NOMUSR"
        var cCmpDtNasc        = "dB2N_DATNAS"
        var cCmpRg            = "cB2N_DRGUSR"
        var cCmpOrigem        = "cB2N_ORGEM"
        var cCmpCRNA          = "cB2N_NRCRNA"
        var cCmpNomePai       = "cB2N_PAI"
        var cCmpNomeMae       = "cB2N_MAE"
        var cCmpEmail         = "cB2N_EMAIL"
        var cCmpCep           = "cB2N_CEPUSR"
        var cCmpComplemento   = "cB2N_COMEND"
        var cCmpNumero        = "cB2N_NR_END"
        var cCmpDDD           = "cB2N_DDD"
        var cCmpTelefone      = "cB2N_TELEFO"
        var cCmpSexo          = "cB2N_SEXO"
        var cCmpEstEmi        = "cB2N_RGEST"
        var cCmpUniv          = "cB2N_UNIVER"
        var cCmpEstCiv        = "cB2N_ESTCIV"
        var cCmpInval         = "cB2N_INVALI"
        var cEstado           = "cB2N_ESTADO"
        var cCampMuni         = "cB2N_CODMUN"
        var cCmpEnder         = "cB2N_ENDERE"
        var cCmpBai           = "cB2N_BAIRRO"
    	Ajax.open("W_PPLGETDBN.APW?cCpf=" + cCPF + "&cCmpNome=" + cCmpNome + "&cCmpDtNasc=" + cCmpDtNasc + "&cCmpRg=" + cCmpRg + "&cCmpOrigem=" + cCmpOrigem + "&cCmpCRNA=" + cCmpCRNA + "&cCmpNomePai=" + cCmpNomePai + "&cCmpNomeMae=" + cCmpNomeMae + "&cCmpEmail="+ cCmpEmail + "&cCmpCep=" + cCmpCep + "&cCmpComplemento=" + cCmpComplemento + "&cCmpNumero=" + cCmpNumero + "&cCmpDDD=" + cCmpDDD + "&cCmpTelefone=" + cCmpTelefone + "&cCmpSexo=" + cCmpSexo + "&cCmpEstEmi=" + cCmpEstEmi + "&cCmpUniv=" + cCmpUniv + "&cCmpEstCiv=" + cCmpEstCiv + "&cCmpInval=" + cCmpInval +"&cEstado=" + cEstado +"&cCampMuni=" + cCampMuni +"&cCmpEnder=" + cCmpEnder +"&cCmpBai=" + cCmpBai , { callback: CarregaCmpo, error: exibeErro});
    }
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    GrvBenef           �   Autor � Roberto Vanderlei   � Data �   23/11/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Exibe novamente a tela para novo preenchimento ou continua processo.  ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function GrvBenef(cTipo, cProtocolo, cRecno){
   var comboCidades;
   var tamanho;
   if(cTipo == "1"){
      closeModalBS();
      document.getElementById("cB2N_PROTOC").value = cProtocolo;
      $(':text').each(function () { $(this).val('');});
      $("select").each(function () {
            $(this).prop("selectedIndex", 0);
      });
       //$('html, body').animate({scrollTop:0}, 'slow');
      comboCidades = document.getElementById("cB2N_CODMUN");
      if(comboCidades != 'undefined'){
         tamanho = comboCidades.length-1;
         for (i = 0; i < tamanho; i++) {
            comboCidades.remove(1);
         }
      }
   }else if (cTipo == "2"){
      setDisable('bconfirma',true);
	  setDisable('bconfirmanovo',true);
      $('form :input').prop('disabled', true);
      $('.infoBarBottom :input').prop('disabled', false);
      $('form table').prop('class', $('form table').prop('class') + ' disabled');
	  $('form table img').attr('onclick', 'return false');
      closeModalBS();
      ChamaPoP('W_PPLRELGEN.APW?cFunName=PLSIMPBEN&cRecno=' + cRecno,'bol','yes',0,925,605);
      fGetAnexo(cProtocolo, cRecno, "BBA", "2");
   }
}
//Fun��es para chamada do Upload Gen�rico
function fGetAnexo(cChave, cRecno, cAlitab, cModo){
	//var cBenef		= getField('Field_BENEF');
	//var cProtocolo	= getField('Field_PROTOCOLO');
	//cRecno = getField("Field_RECNO");
	//cAlitab = "B4F";
	//cRec = getField("Field_RECNO");
	//cChave = cProtocolo + cBenef
	Ajax.open("W_PPLUPGEN.APW?cModo="+cModo+"&cRecno="+ cRecno +"&cChave="+cChave+"&NumInd=1&cAlitab=" + cAlitab + "&cExecPos=" + "ALTBBA|" + cRecno, {callback: mostraUpload, error: mostraUpload});
}
function mostraUpload(v) {
	var divIframe = document.querySelector("#iframeDiv");
	divIframe.innerHTML = v;

	modalBS("<i style='color:#639DD8;' class='fa fa-paperclip fa-lg'></i>&nbsp;&nbsp;Anexos", "<form name='frmUpl' id='frmUpl' action='' method='post'>" + divIframe.innerHTML  + "</form>", "@Fechar~window.frames[0].closePop();", "white~#84CCFF");
	if(document.getElementById("closeModal") != null)
	document.getElementById("closeModal").onclick = 'window.frames[0].closePop();';
	//pego o bot�o da tela de anexos genericas e fa�o o click para carregar a grid de documentos
	parent.document.getElementById("btn_Oculto").style.display="none";
	parent.document.getElementById("btn_Oculto").click();
}
function closePop(cRecno){
	parent.document.getElementById("closeModal").removeAttribute("onclick"); //removo a fun��o de onclick que coloquei na modal generica
	closeModalBS();
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    VerifPrimBenef       � Autor � Roberto Vanderlei   � Data �   16/11/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Verifica se � o primeiro benefici�rio, a partir do CPF.               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function VerifPrimBenef(){
   closeModalBS();
   Ajax.open("W_PPLVERBEN.APW", {callback: CarregaCPF} );
}
function CarregaCPF(v){
   var oCmpCPF = document.getElementById("cB2N_CPFUSR");
   var aResult = v.split("|");
   if(aResult[0] == "true"){
      oCmpCPF.value = aResult[1];
//      oCmpCPF.disabled = true;
      CarregaDadBen("cB2N_CPFUSR");
   }
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    CarregaVisInt  	   � Autor � Roberto Vanderlei   � Data � 24/07/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Carrega Intera��es                                                    ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function CarregaVisInt(cChave, cSeqProc, cSeqInt, cDtInteracao, cDesMot, cObservacao, cResposta,cAliasPai,cRespos){
   closeModalBS();
   Ajax.open("W_PPLSVISITE.APW?cDtInteracao="+cDtInteracao+"&cDesMot="+cDesMot+"&cObservacao="+cObservacao+"&cResposta="+cResposta+"&cSeqProc="+cSeqProc+"&cSeqInt="+cSeqInt+"&cChave="+cChave+"&cAliasPai="+cAliasPai+"&cRespos="+cRespos, {callback: CarregaGrideVisualizacao} );
}

function salvaInteracao(cResposta/*cChave,cChaveInt, cResposta*/){
   closeModalBS();
  var cRespostaZ = '';
  var nPos       = 0;
  var nInicioStr = 0;
  
  while (nPos >= 0){
	nPos = cResposta.indexOf('\n');
	
	if (nPos >= 0){
		cRespostaZ += cResposta.substr(0, nPos) + "[ENTERz]";
	}else{
		cRespostaZ += cResposta;
	}
	
	nInicioStr = nPos + 1;
	cResposta = cResposta.substr(nInicioStr);
  }
  
   Ajax.open("W_PPLSGRVITE.APW?cResposta="+cRespostaZ, {callback: alert('Resposta inserida com sucesso.')} );
}
function CarregaGrideVisualizacao(v){
  var aParams = v.split("|");
  var cTitulo = aParams[0];
  var cConteudo = aParams[1];
  var aBotoes = aParams[2];
  setTimeout(modalBS(cTitulo, cConteudo, aBotoes), 3000);
}

function salvaInteracao(cResposta, cPubl){

  var cRespostaZ = '';
  var nPos       = 0;
  var nInicioStr = 0;
  
  while (nPos >= 0){
	nPos = cResposta.indexOf('\n');
	
	if (nPos >= 0){
		cRespostaZ += cResposta.substr(0, nPos) + "[ENTERz]";
	}else{
		cRespostaZ += cResposta;
	}
	
	nInicioStr = nPos + 1;
	cResposta = cResposta.substr(nInicioStr);
  }	
   Ajax.open("W_PPLSGRVITE.APW?cResposta="+cRespostaZ+"&cPubl="+cPubl, {callback: callBackGrvInt, error: exibeErro } ); 
}

function callBackGrvInt(x){ 
	
	var linteraPend = x;
	
	if (linteraPend == 'false'){
		modalBS("Sucesso", "Todas as pend�ncias com as intera��es foram respondidas, a guia foi alterada para o status 'Em an�lise'! <br/><br/>Clique no bot�o <b>Pesquisar</b> para atualizar a tela.", "@Fechar~closeModalBS()", "white~#009652", "large");
    }
    else if (linteraPend == 'true') {
        modalBS("Sucesso", "Resposta inserida com sucesso!", "@Fechar~closeModalBS()", "white~#009652", "large");
    }
    else {
        modalBS("Falha", "N�o foi poss�vel concluir a intere��o! Tente novamente!", "@Fechar~closeModalBS()", "white~#960000", "large");
    }
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    showAlertBS      	    � Autor � Karine Riquena Limp  � Data � 10/08/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Mostra/esconde os alerts do bootstrap                                                   ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function showAlertBS(cId, cAction){

	if(getObjectID(cId)){
		var oObj = getObjectID(cId);
		if(cAction !== undefined){
			if(cAction == "show")
				$(oObj).show();
			else
				$(oObj).hide();
		}else{
			if (oObj.style.display == 'block')
				$(oObj).show();
			else
				$(oObj).hide();
		}
	}
	
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    hideAllAlert      	    � Autor � Karine Riquena Limp  � Data � 21/09/2015���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � Esconde todos os alerts do bootstrap                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function hideAllAlert()
{
	var arr = $(".alert");
	for(var i=0; i<arr.length;i++){
		showAlertBS(arr[i].id,"hide");
	}
}
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �  getValueByKey �Autor � Karine Riquena Limp   � Data � 17/09/2015     ���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o �Procura registro na grid gerada pelo PPLGETGRID                        ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
//essa fun��o considera a busca no array montado pelo PPLGETGRID
	//as keys do JSON criado s�o field e value
	//os elementos selecionados no combobox s�o marcados por field "IDENLINHA" e value <Recno do registro>
	//os recnos dos registros marcados com checkbox na grid s�o obtidos atrav�s de: oObjGrid.aColsChk
	//no exemplo nosso oObjGri.aColsChk � igual ao array: ["3","6"]
	//o array passado para essa fun��o �: oObjGrid.aCols
	//para pegar pelo recno passar os parametros: field = "IDENLINHA" value = "<Elemento do array obtido por: oObjGrid.aColsChk>"
	//para buscar qualquer outro campo, exemplo (considerando o array abaixo): field = "BI3_CODIGO" value = "0003"
	/*
				Exemplo do formato do array
	
				arr = [
							{ 0:{field:'BI3_CODIGO', value:'0003'},
							  1:{field: 'BI3_DESCRI', value:'OPCIONAL REMOCAO'},
                              2:{field: 'IDENLINHA', value:'3'} 
                            },
							
                            { 0:{field:'BI3_CODIGO', value:'0006'},
                              1:{field: 'BI3_DESCRI', value:'OPCIONAL DENTAL'},
                              2:{field: 'IDENLINHA', value:'6'} 
                            }
	            ];	
	*/
function getValueByKey(field,value,arr){
	var a,b,g=arr.length,e=[],f=[];
	if("IDENLINHA"==field){
		var d=0;
		for(a=0;a<g;a++)
				if(d=Object.keys(arr[a]).length-1,"IDENLINHA"==arr[a][d].field&&arr[a][d].value==value){
					for(b=0;b<=d;b++)
						f=[arr[a][b].field,arr[a][b].value],e.push(f);
					
					break;
				}
		}else 
			for(a=0;a<g;a++)
				for(d=Object.keys(arr[a]).length-1,b=0;b<d;b++)
					if(arr[a][b].field==field&&arr[a][b].value==value){
						for(b=0;b<=d;b++)
							f=[arr[a][b].field,arr[a][b].value],e.push(f);
						a=g+1;
						break
					}
					
		return 0<e.length?e:-1
}
//--------------------Upload do Arquivo---------------------------------INICIO
function fpreClic(FormArq)
{
	setDisable('btn_Envia', true);
	fGrvReczUpl(FormArq);
}

//Verifica se o arquivo foi informado e chama a web function
function fGrvReczUpl(FormArq)
{
	var fakeupload	= document.getElementById('Field_UPLOAD').value;	
	document.getElementById('btn_Envia').innerHTML = 'Enviando...';

	if ( isEmpty(fakeupload) )
	{
		alert('Informe o arquivo!');
		setDisable('btn_Envia', false);
		document.getElementById('btn_Envia').innerHTML = 'Enviar';
		return;
	}

	if (fakeupload != '')
	{
			//foi necess�rio utilizar dessa forma porque no anexo modo 2 n�o considera as variaveis globais 
		var recno  = FormArq.cRecno.length === undefined  ? FormArq.cRecno.value  : FormArq.cRecno[0].value;
		var chave  = FormArq.cChave.length === undefined  ? FormArq.cChave.value  : FormArq.cChave[0].value;
		var aliTab = FormArq.cAlitab.length === undefined ? FormArq.cAlitab.value : FormArq.cAlitab[0].value;
		var numInd = FormArq.cNumInd.length === undefined ? FormArq.cNumInd.value : FormArq.cNumInd[0].value;
		var noArqComp = FormArq.cNoArqComp.length === undefined ? FormArq.cNoArqComp.value : FormArq.cNoArqComp[0].value;
		FindIncUpZUpl(FormArq,'W_PPLENVUPG.APW?cRecno='+recno+'&cDirArq='+fakeupload+'&cChave='+chave+'&cAlitab='+aliTab+'&cNumInd='+numInd+'&cNoArqComp='+noArqComp,'retorno','Carregando...','Erro ao carregar');
	}

	fakeupload = '';
}

//Retorno do upload
function fcarrDoczUpl() {

	Ajax.open('W_PPLRESUPL.APW', {
				callback: MostraReszUpl, 
				error: exibeErro} );

	setDisable('btn_Envia', false);
	document.getElementById('btn_Envia').innerHTML = 'Enviar';
	fGetDoc();

	return;
}

//Controle se foi anexado algum arquivo
function MostraReszUpl(v)
{
	var aResult = v.split("|");

	document.getElementById('retorno').value = aResult[1];

	if (aResult[1] == 'Arquivo Enviado com sucesso.')
	{
		var obj = document.getElementById('anexo');
		obj.value = parseInt(obj.value)+1;
	}
	return;
}

//Passa os par�metros para a fun��o que envia o arquivo para o server
function FindIncUpZUpl(Form,cRotina,cDiv,cTxtProc,cTxtErro, cFuncao)
{
	LoadUploadzUpl(Form,cRotina,cDiv,cTxtProc,cTxtErro,fcarrDoczUpl);
	document.getElementById("Field_UPLOAD").value 	= "";
	return;
}

//Fun��o do upload do arquivo
function LoadUploadzUpl(form,url_action,id_elemento_retorno,html_exibe_carregando,html_erro_http,funcao,cpar)
{
	 form = ( typeof(form) == "string") ? getObjectID(form) : form;
	 
	 var erro="";
	 if( !isObject(form) )
	 { 
	 	erro += "O form passado n�o existe na pagina.\n";
	 } else if(form.nodeName != "FORM") {
	 	erro += "O form passado na func�o nao e um form.\n";
	 }
	 if( getObjectID(id_elemento_retorno) == null){ 
	 	erro += "O elemento passado n�o existe na p�gina.\n";
	 }
	 if(erro.length>0) {
		 alert("Erro ao chamar a fun��o Upload:\n" + erro);
	 return;
	 }
	 //�������������������������������������������������������������������������
	 //� iFrame
	 //�������������������������������������������������������������������������
	 var iframe = document.createElement("iframe");
	 iframe.setAttribute("id","iload-temp");
	 iframe.setAttribute("name","iload-temp");
	 iframe.setAttribute("width","0");
	 iframe.setAttribute("height","0");
	 iframe.setAttribute("border","0");
	 iframe.setAttribute("style","width: 0; height: 0; border: none;");
	 //�������������������������������������������������������������������������
	 //� Adicionando documento
	 //�������������������������������������������������������������������������
	 form.parentNode.appendChild(iframe);
	
	 window.frames['iload-temp'].name="iload-temp";
	 //�������������������������������������������������������������������������
	 //� Adicionando evento carregar
	 //�������������������������������������������������������������������������
	 var carregou = function() { 
	   removeEvent( getObjectID('iload-temp'),"load", carregou);
	   var cross = "javascript: ";
	   cross += "window.parent.getObjectID('" + id_elemento_retorno + "').innerHTML = document.body.innerHTML; void(0); ";
	   
	   getObjectID(id_elemento_retorno).innerHTML = html_erro_http;
	   getObjectID('iload-temp').src = cross;
	   //�������������������������������������������������������������������������
	   if( getObjectID('iload-temp') != null || getObjectID('iload-temp').parentNode != null)
		{ 
		   remove(getObjectID('iload-temp'));
		   funcao();		   
		}
	 }
	 addEvent( getObjectID('iload-temp'), "load", carregou)
	 //�������������������������������������������������������������������������
	 //� Propriedade do form
	 //�������������������������������������������������������������������������
	 form.setAttribute("target","iload-temp");
	 form.setAttribute("action",url_action);
	 form.setAttribute("method","post");
	 form.setAttribute("enctype","multipart/form-data");
	 form.setAttribute("encoding","multipart/form-data");
	 //�������������������������������������������������������������������������
	 //� Envio
	 //�������������������������������������������������������������������������
	 form.submit();
	 //�������������������������������������������������������������������������
	 //� Exibe mensagem ou texto
	 //�������������������������������������������������������������������������
	 if(html_exibe_carregando.length > 0){
   		getObjectID(id_elemento_retorno).innerHTML = html_exibe_carregando;
	 }
	return;
}
//--------------------Upload do Arquivo------------------------------------FIM


//--------------------Alimentar Browse----------------------------------INICIO

function fGetDoc() 
{
	var cBuscaTReg 	= getGridCall('Browse_Upload_Gen', 'fGetDoc' );
    var nRecno 	    = cRecnoAtu;

	cChave			= (typeof $("#cChave").val() 		   == "string" ? $("#cChave").val() : cChave);
	cAlitab				= (typeof $("#cAlitab").val()            == "string" ? $("#cAlitab").val() : cAlitab);
	cNoArqComp	= (typeof $("#cNoArqComp").val() == "string" ? $("#cNoArqComp").val() : cNoArqComp);
	lExcArq		    = (typeof $("#lExcArq").val() 		   == "string" ? $("#lExcArq").val() : lExcArq);
	lBaixar		    = (typeof $("#lBaixar").val() 		   == "string" ? $("#lBaixar").val() : "");
	
	var	cWhere   = (typeof cChave == "string" ? cChave : cChave.value) + "|"; 
			cWhere += (typeof cAlitab == "string" ? cAlitab : cAlitab.value) +"|";
			cWhere += (typeof cNoArqComp == "string" ? cNoArqComp : cNoArqComp.value) +"|";
            cWhere += ((typeof lExcArq == "string" && lExcArq == "1") || (lExcArq.value == "1")) ? "excluir" : "";
            cWhere += ((typeof lBaixar == "string" && lBaixar == "1") || (lBaixar.value == "1")) ? "baixarArquivo" : "";
			
	var cRecnoAtu	= 1;
	var nPagina		= 50;

	// Chama consulta para trazer os dados da Grid
	// fun��o PPLGETDGRI recebe os dados da fun��o PLAC9ACB, s�o passados para esta
	Ajax.open("W_PPLGETDGRI.APW?cFunName=PLAC9ACB&nPagina="+getField('Browse_Upload_Gen'+nPagina)+"&cWhere="+cWhere+"&cBuscaTReg="+cBuscaTReg+"&cChave="+cChave+"&cRecnoAtu="+cRecnoAtu, {
				callback: carregaGridDoczUpl, 
				error: exibeErro} );
}

function carregaGridDoczUpl(v) {
	
	var aResult = v.split("|");

	// Se existe registro define propriedades
    var nQtdRegs	= aResult[1];
	var nQtdDoc 	= aResult[2];
    var nRegDoc 	= aResult[3];
    var aHeader 	= eval(aResult[4]);
	var lContinua	= eval(aResult[7]);
    var aDadPeg 	= (lContinua) ? eval(aResult[5]) : aDadPeg;
    var cMsg = aResult[6];
    var lBaixar = document.getElementById('lBaixar');
	var aBtnFunc  = "";

	// Seta a quantidade total de paginas - seta somente quando nao for navegacao
	if (lContinua) 
	{
		lVisArq = (typeof $("#lVisArq").val() == "string" ? $("#lVisArq").val() : lVisArq);
		if (aDadPeg.length < 1 && lVisArq == "1") {
			parent.document.getElementsByClassName('modal-body')[0].innerHTML = 'N�o existem anexos.';			
		}else{
			// Monta Browse 
			oBrwGridDOC= new gridData('Browse_Upload_Gen',"630","200")
			
			for (var nFor=0; nFor<aDadPeg.length;nFor++){ 
				if (aDadPeg[nFor][0].value.lastIndexOf("_") > 0){
					var nIndice = aDadPeg[nFor][0].value.lastIndexOf("_"); 
					aDadPeg[nFor][0].value = aDadPeg[nFor][0].value.substring(0, nIndice );
				}
			}
			
			lExcArq		    = (lExcArq == "" ? $("#lExcArq").val() : lExcArq);
			if((typeof lExcArq == "string" && lExcArq == "1") || (lExcArq.value == "1" )){
				aBtnFunc = "[{info:'Excluir',img:'004.gif',funcao:'fUnUplGen'}]";
            }
            if (lBaixar != undefined && lBaixar.value == "1") {
                aBtnFunc = "[{info:'Baixar',img:'anexo.jpg',funcao:'fDownGen'}]";
            }
			
			//�������������������������������������������������������������������������
			//� Monta Browse 
			//�������������������������������������������������������������������������
			oBrwGridDOC.load({fFunName:'fGetDoc',
								nRegPagina:nRegDoc,
								nQtdReg:nQtdRegs,
								nQtdPag:nQtdDoc,
								lOverflow:true,
								lShowLineNumber:true,
								lChkBox:false,
								aBtnFunc:aBtnFunc,
								aHeader: aHeader,
								aCols: aDadPeg });
								
				updGridSchemeColor();  

			var oObjFile = document.getElementById('Field_UPLOAD');
			if(typeof oObjFile != "undefined" && oObjFile != null){	oObjFile.disabled = false; }
		}
	}
}

/***************EXCLUS�O GEN�RICA ANEXO DE DOCUMENTOS****************************/
function fUnUplGen(x){
	Ajax.open('W_PPLUNUPL.APW?cRecno=' + x, { callback: fDelArqGen, error: exibeErro } );
}


function fDelArqGen(v) {  
	var aResultDel = v.split("|");
	fGetDoc();
}
/****************************************************************************************************/
/***************DOWNLOAD GEN�RICO ANEXO DE DOCUMENTOS****************************/
function fDownGen(x) {
    Ajax.open('W_PPLCPARQ.APW?cRecno=' + x, { callback: fDownloadArquivoGen, error: exibeErro });
}


function fDownloadArquivoGen(v) {
    var aResult = v.split("|");
    window.open(aResult[0], '_blank');
}
/****************************************************************************************************/
/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �  mascaraCpfCnpj �Autor � Karine Riquena Limp   � Data � 05/10/2015     ���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o �Mascara para cpf e cnpj no mesmo campo                       ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function mascaraCpfCnpj(o,f){
    v_obj=o
    v_fun=f
    setTimeout('exMaskCpfCnpj()',1)
}
 /*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �  exMaskCpfCnpj �Autor � Karine Riquena Limp   � Data � 05/10/2015     ���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o �execu��o da fun��o de mascara para cpf e cnpj no mesmo campo                        ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function exMaskCpfCnpj(){
    v_obj.value=v_fun(v_obj.value)
}
 /*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �  cpfCnpj �Autor � Karine Riquena Limp   � Data � 05/10/2015     ���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o �Processa a mascara para cpf e cnpj no mesmo campo                        ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function cpfCnpj(v){
 
    //Remove tudo o que n�o � d�gito
    v=v.replace(/\D/g,"")
 
    if (v.length <= 11) { //CPF
 
        //Coloca um ponto entre o terceiro e o quarto d�gitos
        v=v.replace(/(\d{3})(\d)/,"$1.$2")
 
        //Coloca um ponto entre o terceiro e o quarto d�gitos
        //de novo (para o segundo bloco de n�meros)
        v=v.replace(/(\d{3})(\d)/,"$1.$2")
 
        //Coloca um h�fen entre o terceiro e o quarto d�gitos
        v=v.replace(/(\d{3})(\d{1,2})$/,"$1-$2")
 
    } else { //CNPJ
	
        //Coloca ponto entre o segundo e o terceiro d�gitos
        v=v.replace(/^(\d{2})(\d)/,"$1.$2")
 
        //Coloca ponto entre o quinto e o sexto d�gitos
        v=v.replace(/^(\d{2})\.(\d{3})(\d)/,"$1.$2.$3")
 
        //Coloca uma barra entre o oitavo e o nono d�gitos
        v=v.replace(/\.(\d{3})(\d)/,".$1/$2")
 
        //Coloca um h�fen depois do bloco de quatro d�gitos
        v=v.replace(/(\d{4})(\d)/,"$1-$2")
 
    }
 
    return v
 
}
//Controle se exibe prorroga��es ou n�o
function getProrrog(cNAut, cProrrog, cTp) {
   if (cProrrog.indexOf("T") != -1) {
		modalBS('', '<p>' + 'Deseja imprimir ?' + '</p>', '@Prorroga��o~window.frames[0].frameElement.contentWindow.fProrrogTrue(' + '"' + cNAut + '"' +  ' , ' + cTp + ');@Interna��o~window.frames[0].frameElement.contentWindow.fProrrogFalse(' + '"' + cNAut + '"' + ' , ' + cTp + ');');
   } else {
	   ChamaPoP('W_PPLRELGEN.APW?cFunName=PPRELST&cReimpr=1&Field_NUMAUT=' + cNAut + '&cNumGuia=' + cNAut + '&cTp=' + cTp + '&lProrrog=.F.','bol','yes',0,925,605);

   }
	
	
	
}

 /*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �   Number.prototype.toMoney(n, x, s, c)  �Autor � Karine Riquena Limp   � Data � 08/10/2015     ���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o �Formata numero para moeda em real                    ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
/**
 * Number.prototype.toMoney(n, x, d, c, s, p)
 * 
 * @param integer n: length of decimal
 * @param integer x: length of whole part
 * @param mixed   d: sections delimiter
 * @param mixed   c: decimal delimiter
 * @param mixed   s: currency symbol
 * @param boolean p: prepend currency symbol
 */
Number.prototype.toMoney = function(n, x, d, c, s, p) {
    var re = '\\d(?=(\\d{' + (x || 3) + '})+' + (n > 0 ? '\\D' : '$') + ')',
        num = this.toFixed(Math.max(0, ~~n));
    
    return (s && p ? s : '') + (c ? num.replace('.', c) : num).replace(new RegExp(re, 'g'), '$&' + (d || ',')) + (s && !p ? s : '');
};
 /*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �  controlNumberVal  �Autor � Karine Riquena Limp   � Data � 16/10/2015     ���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � FUN��O PARA O COMPONENTE NUM�RICO  DO WCHTML                 ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function controlNumberVal(obj, minValue, maxValue){
		var elem = $(obj).parent().parent().children(":input")[0];
		if( obj.name.substr(0,3) == "sub") {
				if(minValue+maxValue != 0){
					elem.value <= minValue ? elem.value = minValue : elem.value--;
				}else{
					elem.value--;
				}
		}else{
			    if(minValue+maxValue != 0){
					elem.value >= maxValue ? elem.value = maxValue : elem.value++;
				}else{
					elem.value++;
				}
		}
}
 /*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
��� Funcao    �  getObjects  �Autor � Karine Riquena Limp   � Data � 16/10/2015     ���
�������������������������������������������������������������������������������������Ĵ��
��� Descri��o � FUN��O PARA BUSCAR KEY EM UM ARRAY                 ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/
function getObjects(obj, key, val) {
    var objects = [];
    for (var i in obj) {
        if (!obj.hasOwnProperty(i)) continue;
        if (typeof obj[i] == 'object') {
            objects = objects.concat(getObjects(obj[i], key, val));
        } else if (i == key && obj[key] == val) {
            objects.push(obj);
        }
    }
    return objects;
}

//------------------------------------------------------------------------------------------
// Fun��o: chkData
// Descri��o: Fun��o para verificar se uma data � maior do que outra
// 	no caso de data de ate, a data de n�o pode ser maior que a data ate
// Autor: Karine Riquena Limp 10/10/2016
//------------------------------------------------------------------------------------------
function chkData(oDataDe, oDataAte, cFrom, lMonthYear){
	if(blurPrevent && cFrom != "de"){
		blurPrevent = false;
		return;
	}else{
	
		var oObj 
		var dDtDe = lMonthYear ? toDate("01/"+oDataDe.value)  : toDate(oDataDe.value); 
		var dDtAte = lMonthYear ? toDate("01/"+oDataAte.value)  : toDate(oDataAte.value); 
	
		if (dDtDe > dDtAte){				
	
			if(cFrom == "de"){
		
				oObj = oDataDe;
			
			}else{
		
				oObj = oDataAte;		
			
			}
			
			//modalBS("Erro", "<p>" + "A data de n�o pode ser maior que a data at�" + "</p>", "@Fechar~closeModalFocus('" + oObj.id + "');", "white~#960000", "large");	
			globalvar = oObj;
			setTimeout("globalvar.focus()",250);
		    blurPrevent = (arguments.callee.caller.name == "onblur" || arguments.callee.caller.name == "onClose") && cFrom == "de";
			alert("A data de n�o pode ser maior que a data at�");
		}
	}
}

function closeModalFocus(idObj){
	globalvar = document.getElementById(idObj) != null ? document.getElementById(idObj)  : window.frames[0].document.getElementById(idObj);
	setTimeout("globalvar.focus()",250);
	
	closeModalBS();
}

//------------------------------------------------------------------------------------------
// Fun��o: toDate
// Descri��o: Fun��o para transformar string em dd/mm/aaaa em data 
// Autor: Karine Riquena Limp 10/10/2016
//------------------------------------------------------------------------------------------
function toDate(dateStr) {
    var parts = dateStr.split("/");
    return new Date(parts[2], parts[1] - 1, parts[0]);
}

//------------------------------------------------------------------------------------------
// Fun��o: closeModalBSZ
// Descri��o: Fun��o padr�o para o bot�o fechar da modalBS gen�rica. Foi necess�rio criar para
// 			  que a tela n�o perca o scroll ao fechar o modal pelo "x"
// Autor: Oscar Zanin	Data: 22/06/2016
//------------------------------------------------------------------------------------------
function closeModalBSZ(){
	//retiro a classe que desabilita o scroll da tela principal da modal
	var bodyMaster = document.querySelector('.pageMaster') != null ? document.querySelector('.pageMaster') : parent.document.querySelector('.pageMaster');
	//classe que desabilita o scroll da tela principal da modal
	$(bodyMaster).removeClass( "modal-open" );
	$(bodyMaster).addClass( "modal-closed" );

}

//------------------------------------------------------------------------------------------
// Fun��o: changeComboVal
// Descri��o: Fun��o gen�rica para atualizar o valor do combo pelo value ou pelo text
// Autor: Karine Riquena Limp	Data: 01/11/2016
//------------------------------------------------------------------------------------------
function changeComboVal(cId, val, cProp){
    if(isObject(cId)){
        var options= document.getElementById(cId).options;
        var n=options.length;
         for (var i=0; i<n; i++) {
            //escolho se vou achar o valor do campo pelo value ou pelo text da option
            if (cProp == "value" ? options[i].value == val : options[i].text == val){
                    options[i].selected= true;
                    break;
            }
         }
    }
}

//------------------------------------------------------------------------------------------
// Fun��o: getCookie
// Descri��o: Retorna determinado cookie no browse, passando o par�metro cName
// Autor: Karine Riquena Limp	Data: 07/12/2016
//------------------------------------------------------------------------------------------
function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
}
