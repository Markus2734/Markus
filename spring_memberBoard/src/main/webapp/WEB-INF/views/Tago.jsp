<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>Insert title here</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath }/resources/css/main.css">
    	<style type="text/css">
    		#mapInfo{
    			display: flex;
    		}
    		#busSttnArea{
    			border: 2px solid black;
    			border-radius: 7px;
    			padding: 5px;
    			width: 200px;
    			height: 300px;
    			margin-left: 3px;
    			overflow: scroll;	
    		}
    		#busArrInfo{
    			border: 2px solid black;
    			width: 453px;
    			height: auto;
    			overflow: scroll;
    		}
    		.busSttn{
    			border: 1px solid black;
    			border-radius: 10px;
    			padding: 5px;
    			text-align: center;
    			margin-bottom: 3px;
    			cursor: pointer;
    		}
    		.busSttn:hover{
    			background-color: lime;
    		}
    		div>button{
    			font-size: 20px;
				margin: 10px;
				width: 272px;
				height: auto;
				background-color: lime;
    		}
    		div>td, tr{
    			text-align: center;
    		}
    		.soon{
    			color: blue;
    		}
    		table>tr>button{
    			font-size: 20px;
    			width: 200px;
    		}
    		.here{
    			font-weight: bold;
    			color: blue;
    		}
    		.home{
    			background-color: aqua;
    		}
    		#stList{
    			border: 2px solid black;
    			width: 1170px;
    			height: auto;
    		}
    		#tagoBus{
    			display: flex;
    		}
    	</style>
    	<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=5f9e825dec7177a1b1fbf0f69df23821"></script>
    </head>

    <body>
        <div class="mainWrap">
            <div class="header">
                <h1>tago</h1>
            </div>
            <%@ include file="/WEB-INF/views/includes/Menu.jsp" %>

            <div class="contents">
            	<div id="tagoBus">
            		<div id="leftInfo">
						<div id="mapInfo">
							<!-- 지도 -->
							<div id="map" style="width:500px;height:300px;"></div>
							<div id="busSttnArea">
			
							</div>
							<div id="busArrInfo">
							<!-- 도착예정 버스 정보 -->
									
							</div>
						</div>
						<div id="stList">
						<!-- 정류소 목록 / 버스정류소조회_API -->
						</div>
					
            		</div>
            	</div>
            	
            </div>

        </div>
    </body>
    <script type="text/javascript">
   
    </script>
	<script src="${pageContext.request.contextPath }/resources/js/main.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.0/jquery.min.js"></script>
    <script type="text/javascript">
    	var mapContainer = document.getElementById('map'), // 지도를 표시할 div 
	    mapOption = { 
	        center: new kakao.maps.LatLng(37.4387, 126.6750), // 지도의 중심좌표
	        level: 3 // 지도의 확대 레벨
	    };
		var map = new kakao.maps.Map(mapContainer, mapOption); // 지도를 생성합니다
		// 지도에 클릭 이벤트를 등록합니다
		// 지도를 클릭하면 마지막 파라미터로 넘어온 함수를 호출합니다
		kakao.maps.event.addListener(map, 'click', function(mouseEvent) {        
		    // 클릭한 위도, 경도 정보를 가져옵니다 
		    var latlng = mouseEvent.latLng;
		    console.log("위도 : "+latlng.getLat());
		    lat = latlng.getLat();
		    console.log("경도 : "+latlng.getLng());
		    lng = latlng.getLng;
		    getBusStList(latlng.getLat(),latlng.getLng());
		}); 	
		$(document).ready(function(){
    		getBusStList(37.4387, 126.6750);
    	});
		let hereSt = 0;
		let idx = 0;
		let cityCode = 0;
		let oldMarker = null;
		let locList = "";
		let lng = 0;
		function getBusStList(lati, loti){
			$.ajax({
				type : "get",
				url : "getStList",
				data : {
					"lati" : lati,
					"loti" : loti
					},
				dataType : "json",
				success : function(result){
					console.log(result);
					let stDiv = document.querySelector("#stList");
					stDiv.innerHTML = "";
					for(let info of result){
						cityCode = info.citycode;	
						let stBtn = document.createElement('button');
						stBtn.innerText = info.nodeno+'\n'+info.nodenm;
						stBtn.setAttribute("value",info.nodeid);
						stBtn.setAttribute("onclick","getArrInfo('"+cityCode+"','"+stBtn.value+"')");
						stBtn.setAttribute("onfocus","getLoc('"+info.gpslati+"','"+info.gpslong+"')")
						stDiv.appendChild(stBtn);
						idx++;
						if(idx%4 == 0){
							let br = document.createElement('br');
							stDiv.appendChild(br);
						}
					}
				}
			});
		}
		function getArrInfo(cityCode, nodeId){
			console.log(cityCode, nodeId);
			hereSt = nodeId;
			$.ajax({
				type : "get",
				url : "getArrList",
				data : {
					"cityCode" : cityCode,
					"nodeId" : nodeId
				},
				dataType : "json",
				success : function(result){
					console.log(result);
					let arrDiv = document.querySelector("#busArrInfo");
					arrDiv.innerHTML = "";
					let arrTable = document.createElement('table');
					let arrTr1 = document.createElement('tr');
					let arrTh1 = document.createElement('th');
					arrTh1.innerText = "버스번호"
					arrTr1.appendChild(arrTh1);
					let arrTh2 = document.createElement('th');
					arrTh2.innerText = "남은정류장수"
					arrTr1.appendChild(arrTh2);
					let arrTh3 = document.createElement('th');
					arrTh3.innerText = "도착예정시간"
					arrTr1.appendChild(arrTh3);
					arrTable.appendChild(arrTr1);
					for(let info of result){
						let arrTr2 = document.createElement('tr');
						let arrTd1 = document.createElement('button');
						arrTd1.setAttribute("onclick","getNodeInfo('"+cityCode+"','"+info.routeid+"')")
						let arrTd2 = document.createElement('td');
						let arrTd3 = document.createElement('td');
						arrTd1.innerText = info.routeno+"번";
						arrTr2.appendChild(arrTd1);
						arrTd2.innerText = info.arrprevstationcnt+"번째 전";
						arrTr2.appendChild(arrTd2);
						if(parseInt(info.arrtime/60)>=2){
						arrTd3.innerText = parseInt(info.arrtime/60)+"분 후 도착예정";
						} else {
							arrTd3.innerText = "곧 도착예정";
							arrTd3.classList.add("soon");
						}
						arrTr2.appendChild(arrTd3);
						arrTable.appendChild(arrTr2);
						arrDiv.appendChild(arrTable);
					}
					
				}
			});
		}
		let nodeList = "";
		function getNodeInfo(cityCode, routeId){
			console.log(cityCode,routeId);
			$.ajax({
				type : "get",
				url : "getNodeList",
				data : {
					"cityCode" : cityCode,
					"routeId" : routeId
				},
				dataType : "json",
				success : function(result){
					nodeList=result;
				}
			});
			$.ajax({
				type : "get",
				url : "getLocList",
				data : {
					"cityCode" : cityCode,
					"routeId" : routeId
				},
				dataType : "json",
				success : function(result){
					locList = result;
					let sttnDiv = document.querySelector("#busSttnArea");
					sttnDiv.innerHTML="";
					for(let info of nodeList){
						let sttnp = document.createElement('p');
						for(let info1 of result){
							if(info1.nodeid == info.nodeid){
								sttnp.classList.add("here");
							}
						}
						if(info.nodeid == hereSt){
							sttnp.setAttribute("tabindex","-1");
							sttnp.classList.add("home");
							sttnp.setAttribute("id","here");
						};
						sttnp.classList.add("busSttn");
						sttnp.setAttribute("value",info.gpslati);
						sttnp.innerText=info.nodeno+'\n'+info.nodenm;
						sttnp.setAttribute("onclick","getLoc('"+info.gpslati+"','"+info.gpslong+"')");
						sttnDiv.appendChild(sttnp);
					}
					$("#here").focus();
				}
			});
			console.log(locList);
			console.log(nodeList);

		}
		function getLoc(gpslati, gpslong){
			 // 이동할 위도 경도 위치를 생성합니다 
		    var moveLatLon = new kakao.maps.LatLng(gpslati, gpslong);
		    
		    // 지도 중심을 부드럽게 이동시킵니다
		    // 만약 이동할 거리가 지도 화면보다 크면 부드러운 효과 없이 이동합니다
		    map.panTo(moveLatLon);   
		 	// 마커가 표시될 위치입니다 
		    var markerPosition  = new kakao.maps.LatLng(gpslati, gpslong); 

		    // 마커를 생성합니다
		    var marker = new kakao.maps.Marker({
		        position: markerPosition
		    });

		    // 마커가 지도 위에 표시되도록 설정합니다
		    console.log(oldMarker);
		    if(oldMarker != null){
				marker.setMap(null);
		    	
		    }
		    oldMarker = marker;
		   	marker.setMap(map);
		    // 아래 코드는 지도 위의 마커를 제거하는 코드입니다
		    // marker.setMap(null);    
		}
    </script>
    </html>
    